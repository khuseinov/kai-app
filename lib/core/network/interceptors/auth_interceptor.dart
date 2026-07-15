import 'dart:convert';

import 'package:crypto/crypto.dart';
import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:kai_app/core/network/session_token_store.dart';

/// Handles auth headers for private Hugging Face Spaces.
///
/// Private HF Spaces require `Authorization: Bearer <HF_TOKEN>` on every request
/// to pass the HF edge proxy. Per-user identity (kai-auth JWT) and voice-gateway
/// auth are handled separately — see APP-AUTH-1 for the kai-auth Bearer token
/// this interceptor will attach once real sign-in ships.
class AuthInterceptor extends Interceptor {
  const AuthInterceptor({
    String? hfToken,
    String? voiceGatewayApiKey,
    String? voiceGatewayBaseUrl,
    SessionTokenStore? sessionTokenStore,
  })  : _hfToken = hfToken,
        _voiceGatewayApiKey = voiceGatewayApiKey,
        _voiceGatewayBaseUrl = voiceGatewayBaseUrl,
        _injectedStore = sessionTokenStore;

  final String? _hfToken;
  final String? _voiceGatewayApiKey;
  final String? _voiceGatewayBaseUrl;
  final SessionTokenStore? _injectedStore;

  SessionTokenStore get _store => _injectedStore ?? sessionTokenStore;

  @override
  void onRequest(
    RequestOptions options,
    RequestInterceptorHandler handler,
  ) {
    // ponytail: Bypass authentication for local browser Blob URLs to avoid browser security blocking them.
    if (options.path.startsWith('blob:')) {
      handler.next(options);
      return;
    }

    final hfToken = _hfToken;

    if (_diagnosticsEnabled) {
      debugPrint(
        '[KAI_DIAGNOSTICS] AuthInterceptor (before): '
        '${_redactHeaders(options.headers)}',
      );
    }

    if (hfToken != null && hfToken.isNotEmpty) {
      // Required by Hugging Face Spaces when the Space is private.
      options.headers['Authorization'] = 'Bearer $hfToken';
    }
    // Per-user identity (kai-auth JWT) attaches here once APP-AUTH-1 ships —
    // no more X-Internal-Token/shared-secret Authorization fallback.

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
  if (redacted.containsKey('X-Internal-API-Key')) {
    redacted['X-Internal-API-Key'] = _sha256Prefix(redacted['X-Internal-API-Key']! as String);
  }
  return redacted;
}
