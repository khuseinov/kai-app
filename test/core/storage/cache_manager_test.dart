import 'package:flutter_test/flutter_test.dart';
import 'package:hive/hive.dart';
import 'package:hive_test/hive_test.dart';
import 'package:kai_app/core/storage/cache_manager.dart';

void main() {
  setUp(() async {
    await setUpTestHive();
  });

  tearDown(() async {
    await tearDownTestHive();
  });

  group('CacheManager', () {
    test('stores and retrieves a value', () async {
      final box = await Hive.openBox('cache');
      final cache = CacheManager(box);
      await cache.set('key1', 'value1', ttl: const Duration(minutes: 5));
      expect(cache.get<String>('key1'), 'value1');
      await box.close();
    });

    test('returns null for missing key', () async {
      final box = await Hive.openBox('cache');
      final cache = CacheManager(box);
      expect(cache.get<String>('missing'), isNull);
      await box.close();
    });

    test('returns null for expired key', () async {
      final box = await Hive.openBox('cache');
      final cache = CacheManager(box);
      await cache.set(
        'key1',
        'value1',
        ttl: const Duration(milliseconds: 1),
      );
      await Future.delayed(const Duration(milliseconds: 10));
      expect(cache.get<String>('key1'), isNull);
      await box.close();
    });

    test('removes expired key from box on get', () async {
      final box = await Hive.openBox('cache');
      final cache = CacheManager(box);
      await cache.set(
        'expired',
        'data',
        ttl: const Duration(milliseconds: 1),
      );
      await Future.delayed(const Duration(milliseconds: 10));
      cache.get<String>('expired');
      expect(box.containsKey('expired'), isFalse);
      expect(box.containsKey('expired_ttl'), isFalse);
      await box.close();
    });

    test('removes key manually', () async {
      final box = await Hive.openBox('cache');
      final cache = CacheManager(box);
      await cache.set('key1', 'value1');
      await cache.remove('key1');
      expect(cache.get<String>('key1'), isNull);
      expect(box.containsKey('key1'), isFalse);
      await box.close();
    });

    test('clears all entries', () async {
      final box = await Hive.openBox('cache');
      final cache = CacheManager(box);
      await cache.set('a', 1);
      await cache.set('b', 2);
      await cache.clear();
      expect(cache.get<int>('a'), isNull);
      expect(cache.get<int>('b'), isNull);
      await box.close();
    });

    test('handles different value types', () async {
      final box = await Hive.openBox('cache');
      final cache = CacheManager(box);
      await cache.set('int', 42);
      await cache.set('list', [1, 2, 3]);
      await cache.set('map', {'k': 'v'});
      expect(cache.get<int>('int'), 42);
      expect(cache.get<List>('list'), [1, 2, 3]);
      expect(cache.get<Map>('map'), {'k': 'v'});
      await box.close();
    });
  });
}
