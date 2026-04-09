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
    developer.log('<-- ${response.statusCode} ${response.requestOptions.uri}', name: 'API');
    handler.next(response);
  }

  @override
  void onError(DioException err, ErrorInterceptorHandler handler) {
    developer.log('<-- Error ${err.message} ${err.requestOptions.uri}', name: 'API', error: err.error);
    handler.next(err);
  }
}

final loggingInterceptorProvider = Provider<LoggingInterceptor>((ref) {
  return LoggingInterceptor();
});
