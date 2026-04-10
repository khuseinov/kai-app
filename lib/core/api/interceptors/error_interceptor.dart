import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../api_exceptions.dart';

class ErrorInterceptor extends Interceptor {
  @override
  void onError(DioException err, ErrorInterceptorHandler handler) {
    KaiApiException exception;
    
    if (err.error is KaiApiException) {
      exception = err.error as KaiApiException;
    } else {
      switch (err.type) {
        case DioExceptionType.connectionTimeout:
        case DioExceptionType.sendTimeout:
        case DioExceptionType.receiveTimeout:
          exception = const TimeoutException('Request timed out');
          break;
        case DioExceptionType.badResponse:
          final statusCode = err.response?.statusCode;
          if (statusCode == 401 || statusCode == 403) {
            exception = const UnauthorizedException('Unauthorized access');
          } else if (statusCode == 429) {
            final retryAfter = err.response?.headers.value('retry-after');
            exception = RateLimitException(
              'Too many requests — slow down',
              retryAfterSeconds: retryAfter != null ? int.tryParse(retryAfter) : null,
            );
          } else if (statusCode == 503 || statusCode == 504) {
            exception = const ServiceUnavailableException(
              'Kai is temporarily unavailable. Please try again in a moment.',
            );
          } else if (statusCode != null && statusCode >= 500) {
            exception = ServerException('Server error', statusCode: statusCode);
          } else {
            exception = UnknownException('Unknown HTTP error: $statusCode');
          }
          break;
        case DioExceptionType.connectionError:
          exception = const NetworkException('Connection error');
          break;
        default:
          exception = UnknownException(err.message ?? 'Unknown error');
      }
    }
    
    return handler.reject(
      DioException(
        requestOptions: err.requestOptions,
        error: exception,
        response: err.response,
        type: err.type,
      ),
    );
  }
}

final errorInterceptorProvider = Provider<ErrorInterceptor>((ref) {
  return ErrorInterceptor();
});
