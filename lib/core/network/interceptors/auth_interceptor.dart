import 'package:dio/dio.dart';

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

    handler.next(options);
  }
}
