import 'package:dio/dio.dart';
import 'package:kai_app/features/auth/domain/entities/token_pair.dart';
import 'package:kai_app/features/auth/domain/repositories/auth_repository.dart';

/// Raw Dio calls against kai-auth `/v1/auth/*`
/// (`services/auth/openapi.yaml` v0.2.0 in the kai-agent repo — frozen wire
/// contract).
///
/// Uses its own bare Dio, outside the app-API client's interceptor chain —
/// same reasoning as `LivekitSessionFactory` in root.dart: the token exchange
/// itself must not depend on `AuthInterceptor`, which in turn depends on this
/// repository's output.
class AuthRemoteSource {
  AuthRemoteSource({required String baseUrl})
      : _dio = Dio(BaseOptions(baseUrl: baseUrl));

  final Dio _dio;

  Future<TokenPair> exchangeGoogle({
    required String idToken,
    required String nonce,
  }) {
    return _exchange('/v1/auth/google', {
      'id_token': idToken,
      'nonce': nonce,
    });
  }

  Future<TokenPair> exchangeApple({
    required String identityToken,
    required String nonce,
    String? fullName,
  }) {
    return _exchange('/v1/auth/apple', {
      'identity_token': identityToken,
      'nonce': nonce,
      if (fullName != null && fullName.isNotEmpty) 'full_name': fullName,
    });
  }

  Future<TokenPair> refresh(String refreshToken) {
    return _exchange('/v1/auth/refresh', {'refresh_token': refreshToken});
  }

  Future<void> logout(String refreshToken) async {
    try {
      await _dio.post<void>(
        '/v1/auth/logout',
        data: {'refresh_token': refreshToken},
      );
    } on DioException catch (_) {
      // Best-effort: kai-auth treats an unknown/expired token as a no-op 204
      // too. Local storage is cleared by the caller regardless of outcome.
    }
  }

  /// Binds [legacyUserId] to the account owning [accessToken]. Returns the
  /// authenticated user_id it was aliased to (per `ClaimResponse`).
  Future<String> claimLegacyUser(
    String legacyUserId,
    String accessToken,
  ) async {
    try {
      final response = await _dio.post<Map<String, dynamic>>(
        '/v1/auth/claim',
        data: {'legacy_user_id': legacyUserId},
        options: Options(headers: {'Authorization': 'Bearer $accessToken'}),
      );
      return response.data!['user_id'] as String;
    } on DioException catch (e) {
      throw AuthException(_detailOf(e) ?? 'claim failed');
    }
  }

  Future<TokenPair> _exchange(String path, Map<String, dynamic> body) async {
    try {
      final response =
          await _dio.post<Map<String, dynamic>>(path, data: body);
      final data = response.data!;
      return TokenPair(
        accessToken: data['access_token'] as String,
        refreshToken: data['refresh_token'] as String,
        expiresAt: DateTime.now().add(
          Duration(seconds: data['expires_in'] as int),
        ),
        userId: data['user_id'] as String,
      );
    } on DioException catch (e) {
      throw AuthException(_detailOf(e) ?? 'sign-in failed');
    }
  }

  String? _detailOf(DioException e) {
    final data = e.response?.data;
    if (data is Map && data['detail'] is String) {
      return data['detail'] as String;
    }
    return null;
  }
}
