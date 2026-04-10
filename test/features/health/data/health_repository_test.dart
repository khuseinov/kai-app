import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:kai_app/core/api/api_client.dart';
import 'package:kai_app/core/api/api_exceptions.dart';
import 'package:kai_app/features/health/data/health_repository.dart';

class FakeApiClient extends ApiClient {
  Response<Map<String, dynamic>>? _getResponse;
  Object? _getError;

  FakeApiClient() : super(Dio());

  void setGetResponse(Map<String, dynamic> data, {int statusCode = 200}) {
    _getResponse = Response<Map<String, dynamic>>(
      data: data,
      statusCode: statusCode,
      requestOptions: RequestOptions(path: '/health'),
    );
  }

  void setGetError(Object error) {
    _getError = error;
  }

  @override
  Future<Response<T>> get<T>(String path, {Map<String, dynamic>? queryParameters}) async {
    if (_getError != null) throw _getError!;
    return _getResponse! as Response<T>;
  }
}

void main() {
  group('HealthRepository', () {
    test('checkHealth returns true when status 200', () async {
      final apiClient = FakeApiClient();
      apiClient.setGetResponse({'status': 'ok'});
      final repo = HealthRepository(apiClient);

      expect(await repo.checkHealth(), isTrue);
    });

    test('checkHealth returns false when status 500', () async {
      final apiClient = FakeApiClient();
      apiClient.setGetResponse({'error': 'unhealthy'}, statusCode: 500);
      final repo = HealthRepository(apiClient);

      expect(await repo.checkHealth(), isFalse);
    });

    test('checkHealth returns false on KaiApiException', () async {
      final apiClient = FakeApiClient();
      apiClient.setGetError(const NetworkException('No connection'));
      final repo = HealthRepository(apiClient);

      expect(await repo.checkHealth(), isFalse);
    });

    test('checkHealth returns false on DioException', () async {
      final apiClient = FakeApiClient();
      apiClient.setGetError(DioException(
        requestOptions: RequestOptions(path: '/health'),
        type: DioExceptionType.connectionError,
      ));
      final repo = HealthRepository(apiClient);

      expect(await repo.checkHealth(), isFalse);
    });

    test('checkHealth returns false on generic Exception', () async {
      final apiClient = FakeApiClient();
      apiClient.setGetError(Exception('Something went wrong'));
      final repo = HealthRepository(apiClient);

      expect(await repo.checkHealth(), isFalse);
    });
  });
}
