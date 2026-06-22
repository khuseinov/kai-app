import 'dart:convert';

import 'package:crypto/crypto.dart';
import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';

/// Handles auth headers for private Hugging Face Spaces and backend admin endpoints.
///
/// Private HF Spaces require `Authorization: Bearer <HF_TOKEN>` on every request
/// to pass the HF edge proxy. The backend's admin/health endpoints
/// (`/sessions`, `/user`, `/health`) authenticate via `X-Internal-Token`.
///
/// Both tokens can be provided at the same time: HF ingress consumes the
/// `Authorization` header, while FastAPI checks `X-Internal-Token` first.
class AuthInterceptor extends Interceptor {
  const AuthInterceptor({
    String? hfToken,
    String? internalToken,
  })  : _hfToken = hfToken,
        _internalToken = internalToken;

  final String? _hfToken;
  final String? _internalToken;

  @override
  void onRequest(
    RequestOptions options,
    RequestInterceptorHandler handler,
  ) {
    final hfToken = _hfToken;
    final internalToken = _internalToken;

    if (_diagnosticsEnabled) {
      debugPrint(
        '[KAI_DIAGNOSTICS] AuthInterceptor (before): '
        '${_redactHeaders(options.headers)}',
      );
    }

    if (hfToken != null && hfToken.isNotEmpty) {
      // Required by Hugging Face Spaces when the Space is private.
      options.headers['Authorization'] = 'Bearer $hfToken';
    } else if (internalToken != null && internalToken.isNotEmpty) {
      // Backward-compatible behaviour for public/local deployments.
      options.headers['Authorization'] = 'Bearer $internalToken';
    }

    if (internalToken != null && internalToken.isNotEmpty) {
      // Used by FastAPI's `require_internal_auth` for admin endpoints.
      // Sent even when HF_TOKEN is set, because HF ingress may strip or
      // validate the Authorization header before forwarding to FastAPI.
      options.headers['X-Internal-Token'] = internalToken;
    }

    if (_diagnosticsEnabled) {
      debugPrint(
        '[KAI_DIAGNOSTICS] AuthInterceptor (after): '
        '${_redactHeaders(options.headers)}',
      );
    }

    handler.next(options);
  }
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
  if (redacted.containsKey('X-Internal-Token')) {
    redacted['X-Internal-Token'] = _sha256Prefix(redacted['X-Internal-Token']! as String);
  }
  return redacted;
}
