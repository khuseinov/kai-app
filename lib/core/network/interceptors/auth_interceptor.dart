import 'dart:convert';

import 'package:crypto/crypto.dart';
import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:kai_app/core/network/session_token_store.dart';

/// Access-token getter, injected so this interceptor doesn't depend on
/// Riverpod directly. Returns null when signed out.
typedef AccessTokenGetter = Future<String?> Function();

/// Attaches per-user identity (kai-auth JWT) and HF-Space edge auth.
///
/// Two distinct concerns share the `Authorization` header, in priority order:
/// 1. kai-auth access token (per-user identity — `require_user_identity` on
///    the backend) when [AccessTokenGetter] resolves one.
/// 2. `hfToken` fallback, required by private Hugging Face Spaces so their
///    edge proxy forwards the request to the container at all.
///
/// ponytail: these two collide if a signed-in user's request ever needs to
/// pass through a *private* HF Space edge — that edge wants an HF PAT in the
/// same header a kai-auth JWT now occupies. Not solved here: the real target
/// topology is a VPS behind Caddy (ADR-0013, no such edge), and kai-auth
/// isn't deployed on the HF Space at all yet. Revisit if/when both are true
/// on the same host — see APP-AUTH-1.
class AuthInterceptor extends Interceptor {
  AuthInterceptor({
    String? hfToken,
    String? voiceGatewayApiKey,
    String? voiceGatewayBaseUrl,
    AccessTokenGetter? getAccessToken,
    SessionTokenStore? sessionTokenStore,
  })  : _hfToken = hfToken,
        _voiceGatewayApiKey = voiceGatewayApiKey,
        _voiceGatewayBaseUrl = voiceGatewayBaseUrl,
        _getAccessToken = getAccessToken,
        _injectedStore = sessionTokenStore;

  final String? _hfToken;
  final String? _voiceGatewayApiKey;
  final String? _voiceGatewayBaseUrl;
  final AccessTokenGetter? _getAccessToken;
  final SessionTokenStore? _injectedStore;

  Dio? _dio;

  SessionTokenStore get _store => _injectedStore ?? sessionTokenStore;

  /// Wire this interceptor to its host Dio so a 401 can be retried once
  /// after a token refresh, re-entering the full interceptor chain — same
  /// pattern as [RetryInterceptor.attach].
  void attach(Dio dio) => _dio = dio;

  static const _retriedKey = 'x-kai-auth-retried';

  @override
  Future<void> onRequest(
    RequestOptions options,
    RequestInterceptorHandler handler,
  ) async {
    // ponytail: Bypass authentication for local browser Blob URLs to avoid browser security blocking them.
    if (options.path.startsWith('blob:')) {
      handler.next(options);
      return;
    }

    if (_diagnosticsEnabled) {
      debugPrint(
        '[KAI_DIAGNOSTICS] AuthInterceptor (before): '
        '${_redactHeaders(options.headers)}',
      );
    }

    // Never let this throw: dio types onRequest as `void Function(...)` and
    // calls it fire-and-forget, so an async throw escapes into the zone and
    // the handler's completer is never completed — the request then hangs
    // forever (connect/receive timeouts live further down the chain and never
    // arm). A getter that blows up is treated as signed out: the request goes
    // out unauthenticated and comes back 401, which is a normal, visible error.
    String? accessToken;
    try {
      accessToken = await _getAccessToken?.call();
    } catch (_) {
      accessToken = null;
    }
    // Two separate concerns, two separate headers (APP-AUTH-1):
    //  - Authorization = how to get PAST the front door. On a private HF Space
    //    the HF edge proxy demands the HF PAT here or it drops the request
    //    before it reaches the container. On a VPS (behind Caddy, no edge)
    //    hfToken is empty and this is simply absent.
    //  - X-Kai-Access-Token = WHO the user is (the kai-auth JWT). A dedicated
    //    header so it never fights the edge for Authorization on HF. kai-core
    //    reads this (raw, no "Bearer "), falling back to Authorization on a
    //    VPS where that carries the JWT.
    if (_hfToken != null && _hfToken.isNotEmpty) {
      options.headers['Authorization'] = 'Bearer $_hfToken';
    }
    if (accessToken != null && accessToken.isNotEmpty) {
      options.headers['X-Kai-Access-Token'] = accessToken;
    }

    final voiceGatewayApiKey = _voiceGatewayApiKey;
    final voiceGatewayBaseUrl = _voiceGatewayBaseUrl;
    if (voiceGatewayApiKey != null &&
        voiceGatewayApiKey.isNotEmpty &&
        voiceGatewayBaseUrl != null &&
        voiceGatewayBaseUrl.isNotEmpty &&
        _isVoiceGatewayRequest(options, voiceGatewayBaseUrl)) {
      options.headers['X-Internal-API-Key'] = voiceGatewayApiKey;
    }

    // SEC-2 (T-03): attach the signed session token bound to this request's
    // session, so it survives once the backend enables require_session_token.
    // No-op until the server has issued a token for this session.
    final sessionId = _sessionIdOf(options);
    if (sessionId != null) {
      final sessionToken = _store.tokenFor(sessionId);
      if (sessionToken != null) {
        options.headers['X-Session-Token'] = sessionToken;
      }
    }

    if (_diagnosticsEnabled) {
      debugPrint(
        '[KAI_DIAGNOSTICS] AuthInterceptor (after): '
        '${_redactHeaders(options.headers)}',
      );
    }

    handler.next(options);
  }

  @override
  void onResponse(
    Response<dynamic> response,
    ResponseInterceptorHandler handler,
  ) {
    // SEC-2 (T-03): capture the token the backend minted for this session.
    final sessionId = _sessionIdOf(response.requestOptions);
    if (sessionId != null) {
      _store.save(sessionId, response.headers.value('x-session-token'));
    }
    handler.next(response);
  }

  @override
  Future<void> onError(
    DioException err,
    ErrorInterceptorHandler handler,
  ) async {
    final dio = _dio;
    final getAccessToken = _getAccessToken;
    final alreadyRetried =
        err.requestOptions.extra[_retriedKey] as bool? ?? false;

    if (err.response?.statusCode != 401 ||
        dio == null ||
        getAccessToken == null ||
        alreadyRetried) {
      handler.next(err);
      return;
    }

    // Identity now rides in X-Kai-Access-Token (see onRequest), so refresh and
    // compare THAT — not Authorization (which carries the static HF edge PAT).
    // validAccessToken() refreshes when expired; if the token it returns is
    // unchanged from what this request already sent, refresh failed (signed
    // out) — no point retrying.
    final priorToken = err.requestOptions.headers['X-Kai-Access-Token'] as String?;
    final String? freshToken;
    try {
      freshToken = await getAccessToken();
    } catch (_) {
      // Same hang risk as onRequest — see there. A refresh that throws means
      // we cannot retry, so surface the original 401 rather than stall.
      handler.next(err);
      return;
    }
    if (freshToken == null || priorToken == freshToken) {
      handler.next(err);
      return;
    }

    final next = err.requestOptions;
    next.headers['X-Kai-Access-Token'] = freshToken;
    next.extra[_retriedKey] = true;

    try {
      final response = await dio.fetch<dynamic>(next);
      handler.resolve(response);
    } on DioException catch (e) {
      handler.next(e);
    }
  }

  /// Resolve the session id a request belongs to: from the `/chat` body, or
  /// the `/sessions/{id}/messages` path. Returns null when neither applies.
  String? _sessionIdOf(RequestOptions options) {
    final data = options.data;
    if (data is Map && data['session_id'] is String) {
      return data['session_id'] as String;
    }
    final match =
        RegExp('/sessions/([^/]+)/messages').firstMatch(options.path);
    return match?.group(1);
  }
}

bool _isVoiceGatewayRequest(RequestOptions options, String baseUrl) {
  final path = options.path;
  if (path.startsWith(baseUrl)) return true;
  // When Dio baseUrl is the main backend and voice gateway is a separate host,
  // requests to the voice gateway are made with a full URL in `path`.
  if (path.startsWith('http') && path.contains('/voice/')) return true;
  return false;
}

bool get _diagnosticsEnabled =>
    !kReleaseMode || const bool.fromEnvironment('KAI_DIAGNOSTICS');

String _sha256Prefix(String? value) {
  if (value == null || value.isEmpty) return '<empty>';
  final hash = sha256.convert(utf8.encode(value)).toString();
  return hash.length >= 8 ? hash.substring(0, 8) : hash;
}

Map<String, dynamic> _redactHeaders(Map<String, dynamic> headers) {
  final redacted = Map<String, dynamic>.of(headers);
  if (redacted.containsKey('Authorization')) {
    final rawValue = redacted['Authorization']! as String;
    final token = rawValue.startsWith('Bearer ') ? rawValue.substring(7) : rawValue;
    redacted['Authorization'] = 'Bearer ${_sha256Prefix(token)}';
  }
  if (redacted.containsKey('X-Kai-Access-Token')) {
    redacted['X-Kai-Access-Token'] =
        _sha256Prefix(redacted['X-Kai-Access-Token']! as String);
  }
  if (redacted.containsKey('X-Internal-API-Key')) {
    redacted['X-Internal-API-Key'] = _sha256Prefix(redacted['X-Internal-API-Key']! as String);
  }
  return redacted;
}
