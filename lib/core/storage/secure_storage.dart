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
}

final secureStorageProvider = Provider<SecureStorage>((ref) {
  return const SecureStorage(FlutterSecureStorage());
});
