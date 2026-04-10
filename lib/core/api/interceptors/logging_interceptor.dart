import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'dart:developer' as developer;

class LoggingInterceptor extends Interceptor {
  @override
  void onRequest(RequestOptions options, RequestInterceptorHandler handler) {
    if (!options.headers.containsKey('x-correlation-id')) {
      options.headers['x-correlation-id'] = DateTime.now().millisecondsSinceEpoch.toString();
    }
    developer.log('--> ${options.method} ${options.uri}', name: 'API');
    handler.next(options);
  }

  @override
  void onResponse(Response response, ResponseInterceptorHandler handler) {
    final correlationId = response.headers.value('x-correlation-id') ??
        response.requestOptions.headers['x-correlation-id'] ??
        '-';
    developer.log(
      '<-- ${response.statusCode} ${response.requestOptions.uri} [corr=$correlationId]',
      name: 'API',
    );
    handler.next(response);
  }

  @override
  void onError(DioException err, ErrorInterceptorHandler handler) {
    final correlationId =
        err.requestOptions.headers['x-correlation-id'] ?? '-';
    developer.log(
      '<-- Error [corr=$correlationId] ${err.response?.statusCode} ${err.requestOptions.uri}: ${err.message}',
      name: 'API',
      error: err.error,
    );
    handler.next(err);
  }
}

final loggingInterceptorProvider = Provider<LoggingInterceptor>((ref) {
  return LoggingInterceptor();
});
