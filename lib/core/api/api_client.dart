import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../config/env_config.dart';
import '../providers/settings_provider.dart';
import 'interceptors/auth_interceptor.dart';
import 'interceptors/connectivity_interceptor.dart';
import 'interceptors/error_interceptor.dart';
import 'interceptors/logging_interceptor.dart';
import 'interceptors/retry_interceptor.dart';

class ApiClient {
  final Dio dio;

  ApiClient(this.dio);

  Future<Response<T>> get<T>(String path, {Map<String, dynamic>? queryParameters}) {
    return dio.get<T>(path, queryParameters: queryParameters);
  }

  Future<Response<T>> post<T>(String path, {dynamic data}) {
    return dio.post<T>(path, data: data);
  }

  Future<Map<String, dynamic>> sendMessage({
    required String message,
    required String userId,
    required String sessionId,
  }) async {
    final response = await dio.post<Map<String, dynamic>>(
      '/chat',
      data: {
        'message': message,
        'user_id': userId,
        'session_id': sessionId,
      },
    );
    return response.data!;
  }
}

final dioProvider = Provider<Dio>((ref) {
  final settings = ref.watch(settingsProvider);

  final dio = Dio(BaseOptions(
    baseUrl: settings.apiBaseUrl,
    connectTimeout: EnvConfig.connectTimeout,
    receiveTimeout: EnvConfig.receiveTimeout,
  ));

  dio.interceptors.addAll([
    ref.watch(connectivityInterceptorProvider),
    ref.watch(authInterceptorProvider),
    RetryInterceptor(dio: dio),
    ref.watch(loggingInterceptorProvider),
    ref.watch(errorInterceptorProvider),
  ]);

  return dio;
});

final apiClientProvider = Provider<ApiClient>((ref) {
  return ApiClient(ref.watch(dioProvider));
});
