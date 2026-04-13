import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class SecureStorage {
  final FlutterSecureStorage _storage;

  const SecureStorage(this._storage);

  Future<void> writeApiKey(String key) async {
    await _storage.write(key: 'api_key', value: key);
  }

  Future<String?> readApiKey() async {
    return await _storage.read(key: 'api_key');
  }

  Future<void> deleteApiKey() async {
    await _storage.delete(key: 'api_key');
  }

  Future<void> writeTokens(
      {required String accessToken, String? refreshToken}) async {
    await _storage.write(key: 'access_token', value: accessToken);
    if (refreshToken != null) {
      await _storage.write(key: 'refresh_token', value: refreshToken);
    }
  }

  Future<({String access, String? refresh})?> readTokens() async {
    final access = await _storage.read(key: 'access_token');
    if (access == null) return null;
    final refresh = await _storage.read(key: 'refresh_token');
    return (access: access, refresh: refresh);
  }

  Future<void> clearTokens() async {
    await _storage.delete(key: 'access_token');
    await _storage.delete(key: 'refresh_token');
  }
}

final secureStorageProvider = Provider<SecureStorage>((ref) {
  return const SecureStorage(FlutterSecureStorage());
});
