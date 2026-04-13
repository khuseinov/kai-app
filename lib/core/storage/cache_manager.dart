import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive/hive.dart';

class CacheManager {
  final Box _box;

  CacheManager(this._box);

  static const _ttlSuffix = '_ttl';

  Future<void> set(String key, dynamic value,
      {Duration ttl = const Duration(minutes: 30)}) async {
    await _box.put(key, value);
    await _box.put(
        '$key$_ttlSuffix', DateTime.now().add(ttl).millisecondsSinceEpoch);
  }

  T? get<T>(String key) {
    if (!_box.containsKey(key)) return null;
    if (_isExpired(key)) {
      // Fire-and-forget cleanup; return stale value is worse than returning null
      _box.delete(key);
      _box.delete('$key$_ttlSuffix');
      return null;
    }
    return _box.get(key) as T?;
  }

  Future<void> remove(String key) async {
    await _box.delete(key);
    await _box.delete('$key$_ttlSuffix');
  }

  bool _isExpired(String key) {
    final expiresAt = _box.get('$key$_ttlSuffix') as int?;
    if (expiresAt == null) return false;
    return DateTime.now().millisecondsSinceEpoch > expiresAt;
  }

  Future<void> clear() async {
    await _box.clear();
  }
}

final cacheManagerProvider = Provider<CacheManager>((ref) {
  return CacheManager(Hive.box('cache'));
});
