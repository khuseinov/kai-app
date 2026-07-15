import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:kai_app/features/auth/domain/entities/token_pair.dart';

/// Persists the kai-auth [TokenPair] in the platform secure keystore
/// (Keychain / Keystore) — deliberately not Hive/SharedPreferences.
class SecureTokenStorage {
  SecureTokenStorage({FlutterSecureStorage? storage})
      : _storage = storage ?? const FlutterSecureStorage();

  final FlutterSecureStorage _storage;

  static const _kAccessToken = 'kai_auth_access_token';
  static const _kRefreshToken = 'kai_auth_refresh_token';
  static const _kExpiresAt = 'kai_auth_expires_at';
  static const _kUserId = 'kai_auth_user_id';

  Future<void> save(TokenPair tokens) async {
    await Future.wait([
      _storage.write(key: _kAccessToken, value: tokens.accessToken),
      _storage.write(key: _kRefreshToken, value: tokens.refreshToken),
      _storage.write(
        key: _kExpiresAt,
        value: tokens.expiresAt.toIso8601String(),
      ),
      _storage.write(key: _kUserId, value: tokens.userId),
    ]);
  }

  Future<TokenPair?> read() async {
    final accessToken = await _storage.read(key: _kAccessToken);
    final refreshToken = await _storage.read(key: _kRefreshToken);
    final expiresAtRaw = await _storage.read(key: _kExpiresAt);
    final userId = await _storage.read(key: _kUserId);
    if (accessToken == null ||
        refreshToken == null ||
        expiresAtRaw == null ||
        userId == null) {
      return null;
    }
    final expiresAt = DateTime.tryParse(expiresAtRaw);
    if (expiresAt == null) return null;
    return TokenPair(
      accessToken: accessToken,
      refreshToken: refreshToken,
      expiresAt: expiresAt,
      userId: userId,
    );
  }

  Future<void> clear() async {
    await Future.wait([
      _storage.delete(key: _kAccessToken),
      _storage.delete(key: _kRefreshToken),
      _storage.delete(key: _kExpiresAt),
      _storage.delete(key: _kUserId),
    ]);
  }
}
