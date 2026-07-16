import 'package:flutter_secure_storage/test/test_flutter_secure_storage_platform.dart';
import 'package:flutter_secure_storage_platform_interface/flutter_secure_storage_platform_interface.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:kai_app/features/auth/data/datasources/auth_remote_source.dart';
import 'package:kai_app/features/auth/data/repositories/auth_repository_impl.dart';
import 'package:kai_app/features/auth/data/repositories/secure_token_storage.dart';
import 'package:kai_app/features/auth/domain/entities/token_pair.dart';
import 'package:kai_app/features/auth/domain/repositories/auth_repository.dart';

/// Counts refresh calls and returns a fresh canned [TokenPair] each time —
/// exercises [AuthRepositoryImpl]'s expiry/single-flight logic without a real
/// kai-auth backend. `logout`/exchange* are unused here and left as the real
/// (bare-Dio, unreachable-host) implementation, which fails fast and is
/// swallowed by `AuthRemoteSource.logout`'s own best-effort catch.
class _CountingAuthRemoteSource extends AuthRemoteSource {
  _CountingAuthRemoteSource() : super(baseUrl: 'http://127.0.0.1:0');

  int refreshCalls = 0;

  /// When set, [refresh] throws this instead of returning a pair.
  Object? refreshError;

  @override
  Future<TokenPair> refresh(String refreshToken) async {
    refreshCalls++;
    final error = refreshError;
    if (error != null) throw error;
    return TokenPair(
      accessToken: 'new-access-$refreshCalls',
      refreshToken: 'new-refresh-$refreshCalls',
      expiresAt: DateTime.now().add(const Duration(minutes: 15)),
      userId: 'user-1',
    );
  }
}

/// Fails every write — stands in for a keystore that rejects us mid-refresh.
class _FailingStorage implements SecureTokenStorage {
  @override
  Future<void> save(TokenPair tokens) async =>
      throw Exception('keystore write failed');

  @override
  Future<TokenPair?> read() async => null;

  @override
  Future<void> clear() async {}
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

    // The contract is "null when signed out or refresh fails" — never a throw.
    // AuthInterceptor calls this from dio's fire-and-forget async callback, so
    // an escaping error is not just an error: the handler is never completed
    // and the request hangs forever with no timeout to rescue it.
    test('returns null (never throws) when refresh is rejected', () async {
      await seed(expired: true);
      remote.refreshError = const AuthException('invalid refresh token');

      await expectLater(repo.validAccessToken(), completion(isNull));
    });

    test('concurrent caller also gets null when the shared refresh fails',
        () async {
      await seed(expired: true);
      remote.refreshError = const AuthException('invalid refresh token');

      // The second caller awaits the first's in-flight future — that await is
      // the one that used to rethrow with no guard at all.
      final results = await Future.wait([
        repo.validAccessToken(),
        repo.validAccessToken(),
      ]);

      expect(results, [null, null]);
      expect(remote.refreshCalls, 1);
    });

    test('returns null when a non-AuthException escapes the refresh', () async {
      await seed(expired: true);
      remote.refreshError = TypeError();

      await expectLater(repo.validAccessToken(), completion(isNull));
    });

    test('returns null when persisting the refreshed pair throws', () async {
      final failing = AuthRepositoryImpl(
        remote: remote,
        storage: _FailingStorage(),
      );
      await storage.save(
        TokenPair(
          accessToken: 'seed-access',
          refreshToken: 'seed-refresh',
          expiresAt: DateTime.now().subtract(const Duration(minutes: 1)),
          userId: 'user-1',
        ),
      );
      // Restore through the real storage, then let the failing one break save().
      final restored = await AuthRepositoryImpl(
        remote: remote,
        storage: storage,
      ).restoreSession();
      expect(restored, isNotNull);

      await failing.restoreSession();
      await expectLater(failing.validAccessToken(), completion(isNull));
    });

    test('a failed refresh reports the session as lost exactly once', () async {
      var lost = 0;
      final watched = AuthRepositoryImpl(
        remote: remote,
        storage: storage,
        onSessionLost: () => lost++,
      );
      await storage.save(
        TokenPair(
          accessToken: 'seed-access',
          refreshToken: 'seed-refresh',
          expiresAt: DateTime.now().subtract(const Duration(minutes: 1)),
          userId: 'user-1',
        ),
      );
      await watched.restoreSession();
      remote.refreshError = const AuthException('refresh token expired');

      expect(await watched.validAccessToken(), isNull);

      // Without this callback the teardown is invisible to AuthNotifier: the
      // UI keeps showing the account and never offers sign-in again.
      expect(lost, 1);
    });
  });
}
