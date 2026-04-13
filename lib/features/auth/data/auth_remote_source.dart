import '../../../core/api/api_client.dart';

class AuthRemoteSource {
  final ApiClient _apiClient;
  AuthRemoteSource(this._apiClient);

  Future<Map<String, dynamic>> register({
    required String email,
    required String password,
    String? name,
  }) async {
    final response = await _apiClient.post(
      '/auth/register',
      data: {
        'email': email,
        'password': password,
        if (name != null) 'name': name,
      },
    );
    return response.data as Map<String, dynamic>;
  }

  Future<Map<String, dynamic>> login({
    required String email,
    required String password,
  }) async {
    final response = await _apiClient.post(
      '/auth/login',
      data: {
        'email': email,
        'password': password,
      },
    );
    return response.data as Map<String, dynamic>;
  }

  Future<Map<String, dynamic>> refreshToken(String refreshToken) async {
    final response = await _apiClient.post(
      '/auth/refresh',
      data: {
        'refresh_token': refreshToken,
      },
    );
    return response.data as Map<String, dynamic>;
  }

  Future<void> logout(String accessToken) async {
    await _apiClient.post(
      '/auth/logout',
      data: {
        'access_token': accessToken,
      },
    );
  }
}
