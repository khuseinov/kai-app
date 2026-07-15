import 'package:flutter_secure_storage/test/test_flutter_secure_storage_platform.dart';
import 'package:flutter_secure_storage_platform_interface/flutter_secure_storage_platform_interface.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:kai_app/features/auth/data/datasources/auth_remote_source.dart';
import 'package:kai_app/features/auth/data/repositories/auth_repository_impl.dart';
import 'package:kai_app/features/auth/data/repositories/secure_token_storage.dart';
import 'package:kai_app/features/auth/domain/entities/token_pair.dart';

/// Counts refresh calls and returns a fresh canned [TokenPair] each time —
/// exercises [AuthRepositoryImpl]'s expiry/single-flight logic without a real
/// kai-auth backend. `logout`/exchange* are unused here and left as the real
/// (bare-Dio, unreachable-host) implementation, which fails fast and is
/// swallowed by `AuthRemoteSource.logout`'s own best-effort catch.
class _CountingAuthRemoteSource extends AuthRemoteSource {
  _CountingAuthRemoteSource() : super(baseUrl: 'http://127.0.0.1:0');

  int refreshCalls = 0;

  @override
  Future<TokenPair> refresh(String refreshToken) async {
    refreshCalls++;
    return TokenPair(
      accessToken: 'new-access-$refreshCalls',
      refreshToken: 'new-refresh-$refreshCalls',
      expiresAt: DateTime.now().add(const Duration(minutes: 15)),
      userId: 'user-1',
    );
  }
}

void main() {
  late SecureTokenStorage storage;
  late _CountingAuthRemoteSource remote;
  late AuthRepositoryImpl repo;

  setUp(() {
    FlutterSecureStoragePlatform.instance =
        TestFlutterSecureStoragePlatform(<String, String>{});
    storage = SecureTokenStorage();
    remote = _CountingAuthRemoteSource();
    repo = AuthRepositoryImpl(remote: remote, storage: storage);
  });

  Future<void> seed({required bool expired}) async {
    await storage.save(
      TokenPair(
        accessToken: 'seed-access',
        refreshToken: 'seed-refresh',
        expiresAt: expired
            ? DateTime.now().subtract(const Duration(minutes: 1))
            : DateTime.now().add(const Duration(minutes: 15)),
        userId: 'user-1',
      ),
    );
    await repo.restoreSession();
  }

  group('AuthRepositoryImpl.validAccessToken', () {
    test('non-expired token is returned without refreshing', () async {
      await seed(expired: false);

      final token = await repo.validAccessToken();

      expect(token, 'seed-access');
      expect(remote.refreshCalls, 0);
    });

    test('expired token triggers exactly one refresh', () async {
      await seed(expired: true);

      final token = await repo.validAccessToken();

      expect(token, 'new-access-1');
      expect(remote.refreshCalls, 1);
    });

    test('concurrent calls share one in-flight refresh', () async {
      await seed(expired: true);

      // Refresh tokens are single-use/rotating server-side — a second
      // concurrent caller re-sending the already-rotated token would look
      // like reuse to kai-auth and revoke the whole family. Both calls must
      // resolve to the SAME refreshed pair, from exactly one remote call.
      final results = await Future.wait([
        repo.validAccessToken(),
        repo.validAccessToken(),
      ]);

      expect(results[0], isNotNull);
      expect(results[0], results[1]);
      expect(remote.refreshCalls, 1);
    });

    test('signOut clears the cached token', () async {
      await seed(expired: false);

      await repo.signOut();
      final token = await repo.validAccessToken();

      expect(token, isNull);
    });
  });
}
