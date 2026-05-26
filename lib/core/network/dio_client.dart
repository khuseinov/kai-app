import 'package:dio/dio.dart';

/// Factory for the app's Dio client with sane default timeouts.
///
/// Connect timeout: 30s, receive timeout: 300s (for long-running LLM streams).
Dio buildDioClient({
  required String baseUrl,
  required List<Interceptor> interceptors,
}) {
  final dio = Dio(
    BaseOptions(
      baseUrl: baseUrl,
      connectTimeout: const Duration(seconds: 30),
      receiveTimeout: const Duration(seconds: 300),
      headers: <String, dynamic>{
        'Content-Type': 'application/json',
        'Accept': 'application/json',
      },
    ),
  );
  dio.interceptors.addAll(interceptors);
  return dio;
}
