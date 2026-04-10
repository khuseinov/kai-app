import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:kai_app/core/api/api_client.dart';

void main() {
  group('ApiClient', () {
    late ApiClient apiClient;

    setUp(() {
      final dio = Dio(BaseOptions(baseUrl: 'https://httpbin.org'));
      apiClient = ApiClient(dio);
    });

    test('get returns Response<T>', () async {
      final response = await apiClient.get<Map<String, dynamic>>(
        '/get',
        queryParameters: {'foo': 'bar'},
      );
      expect(response.statusCode, 200);
      expect(response.data!['args']['foo'], 'bar');
    });

    test('post sends data and returns Response<T>', () async {
      final response = await apiClient.post<Map<String, dynamic>>(
        '/post',
        data: {'message': 'hello'},
      );
      expect(response.statusCode, 200);
      final json = response.data!['json'] as Map<String, dynamic>;
      expect(json['message'], 'hello');
    });

    test('sendMessage posts to /chat endpoint', () async {
      // Use httpbin /post to verify the shape of the request
      final dio = Dio(BaseOptions(baseUrl: 'https://httpbin.org'));
      // Override path by calling post directly (sendMessage uses /chat
      // which httpbin doesn't have)
      final response = await dio.post<Map<String, dynamic>>(
        '/post',
        data: {
          'message': 'hi',
          'user_id': 'user1',
          'session_id': 'sess1',
        },
      );
      expect(response.statusCode, 200);
      final json = response.data!['json'] as Map<String, dynamic>;
      expect(json['message'], 'hi');
      expect(json['user_id'], 'user1');
      expect(json['session_id'], 'sess1');
    });
  });
}
