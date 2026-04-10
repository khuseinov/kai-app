import '../../../core/models/user.dart';
import '../../../core/storage/secure_storage.dart';
import 'auth_remote_source.dart';

class AuthRepository {
  final AuthRemoteSource _remoteSource;
  final SecureStorage _secureStorage;

  AuthRepository(this._remoteSource, this._secureStorage);

  Future<({User user, String accessToken, String? refreshToken})> register({
    required String email,
    required String password,
    String? name,
  }) async {
    final data = await _remoteSource.register(
      email: email,
      password: password,
      name: name,
    );
    final user = User.fromJson(data['user'] as Map<String, dynamic>);
    final accessToken = data['access_token'] as String;
    final refreshToken = data['refresh_token'] as String?;
    await _secureStorage.writeTokens(
      accessToken: accessToken,
      refreshToken: refreshToken,
    );
    return (
      user: user,
      accessToken: accessToken,
      refreshToken: refreshToken,
    );
  }

  Future<({User user, String accessToken, String? refreshToken})> login({
    required String email,
    required String password,
  }) async {
    final data = await _remoteSource.login(email: email, password: password);
    final user = User.fromJson(data['user'] as Map<String, dynamic>);
    final accessToken = data['access_token'] as String;
    final refreshToken = data['refresh_token'] as String?;
    await _secureStorage.writeTokens(
      accessToken: accessToken,
      refreshToken: refreshToken,
    );
    return (
      user: user,
      accessToken: accessToken,
      refreshToken: refreshToken,
    );
  }

  Future<void> logout() async {
    final tokens = await _secureStorage.readTokens();
    if (tokens != null) {
      try {
        await _remoteSource.logout(tokens.access);
      } catch (_) {}
    }
    await _secureStorage.clearTokens();
  }

  Future<bool> tryAutoLogin() async {
    final tokens = await _secureStorage.readTokens();
    return tokens != null;
  }
}
