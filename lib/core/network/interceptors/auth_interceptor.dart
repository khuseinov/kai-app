import 'package:dio/dio.dart';

/// Injects the internal health token when configured.
///
/// Normal chat endpoints do not require auth, but admin/health endpoints
/// (`/sessions`, `/user`, `/health`) use it via `require_internal_auth`.
class AuthInterceptor extends Interceptor {
  const AuthInterceptor({String? token}) : _token = token;

  final String? _token;

  @override
  void onRequest(
    RequestOptions options,
    RequestInterceptorHandler handler,
  ) {
    final token = _token;
    if (token != null && token.isNotEmpty) {
      options.headers['Authorization'] = 'Bearer $token';
    }
    handler.next(options);
  }
}
