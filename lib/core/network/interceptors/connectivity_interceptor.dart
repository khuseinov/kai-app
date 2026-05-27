import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:dio/dio.dart';

/// Thrown by [ConnectivityInterceptor] when the device reports no
/// connectivity at request time.
class OfflineException implements Exception {
  const OfflineException([this.message = 'Device is offline']);
  final String message;

  @override
  String toString() => 'OfflineException: $message';
}

/// Rejects requests with [OfflineException] when there's no network.
class ConnectivityInterceptor extends Interceptor {
  ConnectivityInterceptor({Connectivity? connectivity})
      : _connectivity = connectivity ?? Connectivity();

  final Connectivity _connectivity;

  @override
  Future<void> onRequest(
    RequestOptions options,
    RequestInterceptorHandler handler,
  ) async {
    final result = await _connectivity.checkConnectivity();
    final offline = result.isEmpty ||
        result.every((r) => r == ConnectivityResult.none);
    if (offline) {
      handler.reject(
        DioException(
          requestOptions: options,
          type: DioExceptionType.connectionError,
          error: const OfflineException(),
          message: 'Device is offline',
        ),
        true,
      );
      return;
    }
    handler.next(options);
  }
}
