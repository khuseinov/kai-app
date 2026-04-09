import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive/hive.dart';

class ApiClient {
  late final Dio _dio;

  ApiClient({String? baseUrl, String? apiKey}) {
    _dio = Dio(BaseOptions(
      baseUrl: baseUrl ?? 'http://10.0.2.2:8000', // Android emulator → host
      connectTimeout: const Duration(seconds: 60),
      receiveTimeout: const Duration(seconds: 130),
      headers: {
        'Content-Type': 'application/json',
        if (apiKey != null) 'X-API-Key': apiKey,
      },
    ));

    _dio.interceptors.add(LogInterceptor(
      requestBody: true,
      responseBody: true,
      logPrint: (o) => debugPrint(o.toString()),
    ));
  }

  Future<Map<String, dynamic>> sendMessage({
    required String message,
    required String userId,
    required String sessionId,
  }) async {
    final response = await _dio.post('/chat', data: {
      'message': message,
      'user_id': userId,
      'session_id': sessionId,
    });
    return response.data as Map<String, dynamic>;
  }

  Future<Map<String, dynamic>> checkHealth() async {
    final response = await _dio.get('/health/full');
    return response.data as Map<String, dynamic>;
  }
}

final apiClientProvider = Provider<ApiClient>((ref) {
  final settings = Hive.box('settings');
  final baseUrl = settings.get('api_base_url') as String? ??
      'http://10.0.2.2:8000';
  final apiKey = settings.get('api_key') as String?;
  return ApiClient(baseUrl: baseUrl, apiKey: apiKey);
});
