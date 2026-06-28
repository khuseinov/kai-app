import 'package:dio/dio.dart';

/// Normalised network failure category.
enum NetworkFailure {
  timeout,
  serverError,
  clientError,
  parseError,
  offline,
  cancelled,
  unknown,
}

/// Typed error wrapping a [DioException] with a normalised [NetworkFailure].
///
/// Throw this from repositories so business logic never branches on raw
/// HTTP status codes.
class NetworkException implements Exception {
  const NetworkException({
    required this.failure,
    required this.statusCode,
    required this.message,
    this.cause,
  });

  final NetworkFailure failure;
  final int? statusCode;
  final String message;
  final Object? cause;

  @override
  String toString() =>
      'NetworkException($failure, status=$statusCode): $message';
}

/// Maps raw Dio errors into [NetworkException].
class ErrorInterceptor extends Interceptor {
  @override
  void onError(DioException err, ErrorInterceptorHandler handler) {
    final status = err.response?.statusCode;
    NetworkFailure failure;
    switch (err.type) {
      case DioExceptionType.connectionTimeout:
      case DioExceptionType.sendTimeout:
      case DioExceptionType.receiveTimeout:
        failure = NetworkFailure.timeout;
      case DioExceptionType.connectionError:
        failure = NetworkFailure.offline;
      case DioExceptionType.cancel:
        failure = NetworkFailure.cancelled;
      case DioExceptionType.badCertificate:
      case DioExceptionType.unknown:
        failure = NetworkFailure.unknown;
      case DioExceptionType.badResponse:
        if (status != null && status >= 500) {
          failure = NetworkFailure.serverError;
        } else if (status != null && status >= 400) {
          failure = NetworkFailure.clientError;
        } else {
          failure = NetworkFailure.unknown;
        }
    }

    var message = err.message ?? failure.name;
    final data = err.response?.data;
    if (data is Map && data['detail'] is String) {
      message = data['detail'] as String;
    }

    final wrapped = DioException(
      requestOptions: err.requestOptions,
      response: err.response,
      type: err.type,
      error: NetworkException(
        failure: failure,
        statusCode: status,
        message: message,
        cause: err.error,
      ),
      message: err.message,
      stackTrace: err.stackTrace,
    );
    handler.next(wrapped);
  }
}
