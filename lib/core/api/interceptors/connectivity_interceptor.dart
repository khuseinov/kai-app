import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../api_exceptions.dart';
import '../../network/connectivity_service.dart';

class ConnectivityInterceptor extends Interceptor {
  final ConnectivityService _connectivityService;

  ConnectivityInterceptor(this._connectivityService);

  @override
  void onRequest(RequestOptions options, RequestInterceptorHandler handler) {
    if (!_connectivityService.isOnline) {
      return handler.reject(
        DioException(
          requestOptions: options,
          error: const OfflineException(),
          type: DioExceptionType.connectionError,
        ),
      );
    }
    handler.next(options);
  }
}

final connectivityInterceptorProvider = Provider<ConnectivityInterceptor>((ref) {
  return ConnectivityInterceptor(ref.watch(connectivityServiceProvider));
});
