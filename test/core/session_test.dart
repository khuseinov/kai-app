import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:kai_app/core/session/anonymous_session_provider.dart';

/// Map-backed [FlutterSecureStorage] fake — keeps tests off the platform
/// channel which would otherwise throw `MissingPluginException` in unit tests.
class _FakeSecureStorage implements FlutterSecureStorage {
  final Map<String, String> store = {};

  @override
  Future<String?> read({
    required String key,
    AppleOptions? iOptions,
    AndroidOptions? aOptions,
    LinuxOptions? lOptions,
    WindowsOptions? wOptions,
    WebOptions? webOptions,
    AppleOptions? mOptions,
  }) async =>
      store[key];

  @override
  Future<void> write({
    required String key,
    required String? value,
    AppleOptions? iOptions,
    AndroidOptions? aOptions,
    LinuxOptions? lOptions,
    WindowsOptions? wOptions,
    WebOptions? webOptions,
    AppleOptions? mOptions,
  }) async {
    if (value == null) {
      store.remove(key);
    } else {
      store[key] = value;
    }
  }

  // Unused in tests — keep noSuchMethod-style stubs minimal.
  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

void main() {
  group('anonymousSessionProvider', () {
    test('first read generates a uuid and persists it', () async {
      final fake = _FakeSecureStorage();
      const generatedId = '00000000-0000-0000-0000-000000000123';
      final container = ProviderContainer(
        overrides: [
          secureStorageProvider.overrideWithValue(fake),
          uuidGeneratorProvider.overrideWithValue(() => generatedId),
        ],
      );
      addTearDown(container.dispose);

      final id = await container.read(anonymousSessionProvider.future);
      expect(id, generatedId);
      expect(fake.store[kAnonymousSessionStorageKey], generatedId);
    });

    test('second read returns the same uuid from storage', () async {
      final fake = _FakeSecureStorage();
      const existingId = 'persisted-uuid-abc';
      fake.store[kAnonymousSessionStorageKey] = existingId;

      final container = ProviderContainer(
        overrides: [
          secureStorageProvider.overrideWithValue(fake),
          uuidGeneratorProvider.overrideWithValue(
            () => fail('uuid generator must not be called when stored exists'),
          ),
        ],
      );
      addTearDown(container.dispose);

      final id = await container.read(anonymousSessionProvider.future);
      expect(id, existingId);
    });

    test('two reads in same container yield identical id', () async {
      final fake = _FakeSecureStorage();
      const generatedId = 'gen-once-id';
      var calls = 0;
      final container = ProviderContainer(
        overrides: [
          secureStorageProvider.overrideWithValue(fake),
          uuidGeneratorProvider.overrideWithValue(() {
            calls += 1;
            return generatedId;
          }),
        ],
      );
      addTearDown(container.dispose);

      final first = await container.read(anonymousSessionProvider.future);
      final second = await container.read(anonymousSessionProvider.future);
      expect(first, generatedId);
      expect(second, generatedId);
      expect(calls, 1, reason: 'cached value reused within container lifetime');
    });
  });
}
