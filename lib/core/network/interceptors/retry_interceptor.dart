import 'dart:async';
import 'dart:math' as math;

import 'package:dio/dio.dart';

/// Retries transient failures with exponential backoff.
///
/// Base delay 500ms, multiplier 2.0, max 3 retries.
/// Skips 401/403/429 (handled elsewhere — not transient).
///
/// Must be wired to its host Dio via [attach] so retries re-enter the full
/// interceptor chain (auth, logging, error normalisation). Without [attach]
/// retries are dropped to `handler.next(err)` rather than escaping the chain
/// via a bare Dio.
class RetryInterceptor extends Interceptor {
  RetryInterceptor({
    this.baseDelay = const Duration(milliseconds: 500),
    this.multiplier = 2.0,
    this.maxRetries = 3,
  });

  Dio? _dio;
  final Duration baseDelay;
  final double multiplier;
  final int maxRetries;

  /// Wire this interceptor to its host Dio so retries re-enter the full
  /// interceptor chain. Call from the provider that constructs the Dio.
  void attach(Dio dio) => _dio = dio;

  static const String _attemptKey = 'x-retry-attempt';

  bool _shouldRetry(DioException err) {
    final status = err.response?.statusCode;
    if (status == 401 || status == 403 || status == 429) return false;
    switch (err.type) {
      case DioExceptionType.connectionTimeout:
      case DioExceptionType.sendTimeout:
      case DioExceptionType.receiveTimeout:
      case DioExceptionType.connectionError:
        return true;
      case DioExceptionType.badResponse:
        // Retry 5xx only.
        return status != null && status >= 500 && status < 600;
      case DioExceptionType.badCertificate:
      case DioExceptionType.cancel:
      case DioExceptionType.unknown:
        return false;
    }
  }

  @override
  Future<void> onError(
    DioException err,
    ErrorInterceptorHandler handler,
  ) async {
    final attempt = (err.requestOptions.extra[_attemptKey] as int?) ?? 0;
    if (attempt >= maxRetries || !_shouldRetry(err)) {
      handler.next(err);
      return;
    }

    final dio = _dio;
    if (dio == null) {
      // Not attached — refuse to escape the interceptor chain via a bare Dio.
      handler.next(err);
      return;
    }

    final delayMs =
        (baseDelay.inMilliseconds * math.pow(multiplier, attempt)).toInt();
    await Future<void>.delayed(Duration(milliseconds: delayMs));

    final next = err.requestOptions;
    next.extra[_attemptKey] = attempt + 1;

    try {
      final response = await dio.fetch<dynamic>(next);
      handler.resolve(response);
    } on DioException catch (e) {
      handler.next(e);
    }
  }
}
