import 'package:dio/dio.dart';

/// Auth interceptor — currently pass-through.
///
// TODO(phase-2): inject anonymous session header on every request once
/// `lib/core/session/anonymous_session.dart` is wired.
class AuthInterceptor extends Interceptor {
  @override
  void onRequest(
    RequestOptions options,
    RequestInterceptorHandler handler,
  ) {
    // Pass-through in phase 1. No auth headers yet.
    handler.next(options);
  }
}
