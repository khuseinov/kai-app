import 'package:flutter_test/flutter_test.dart';
import 'package:hive/hive.dart';
import 'package:hive_test/hive_test.dart';
import 'package:kai_app/core/providers/root.dart';
import 'package:kai_app/core/storage/hive_setup.dart';
import 'package:kai_app/features/auth/domain/entities/auth_user.dart';
import 'package:kai_app/features/auth/presentation/providers/auth_notifier.dart';
import 'package:riverpod/riverpod.dart';

/// The id we put in `user_id` and the `sub` of the JWT AuthInterceptor attaches
/// to the same request MUST be the same string: kai-core's
/// `require_user_identity` compares them with compare_digest and 403s on any
/// mismatch. Sending the anonymous Hive id while signed in therefore fails
/// every /sessions, /user/* and /schedules call — deterministically, not as an
/// edge case. These tests pin that agreement.
void main() {
  setUp(() async {
    await setUpTestHive();
    await Hive.openBox<String>(HiveSetup.userIdBoxName);
  });

  tearDown(() async {
    await tearDownTestHive();
  });

  ProviderContainer containerFor(AsyncValue<AuthUser?> authState) {
    return ProviderContainer(
      overrides: [
        authNotifierProvider.overrideWith(() => _StubAuthNotifier(authState)),
      ],
    );
  }

  test('signed in: reports the kai-auth account id, not the anonymous one',
      () {
    final container = containerFor(
      const AsyncValue.data(AuthUser(id: 'kai-auth-account-uuid')),
    );
    addTearDown(container.dispose);

    expect(container.read(userIdProvider), 'kai-auth-account-uuid');
    expect(
      container.read(userIdProvider),
      isNot(container.read(anonymousUserIdProvider)),
    );
  });

  test('signed out: falls back to the stable anonymous id', () {
    final container = containerFor(const AsyncValue.data(null));
    addTearDown(container.dispose);

    expect(container.read(userIdProvider), container.read(anonymousUserIdProvider));
  });

  test('still restoring: uses the anonymous id rather than nothing', () {
    final container = containerFor(const AsyncValue.loading());
    addTearDown(container.dispose);

    expect(container.read(userIdProvider), container.read(anonymousUserIdProvider));
  });

  test('flips to the account id when sign-in lands', () async {
    final container = ProviderContainer();
    addTearDown(container.dispose);
    // Nothing signed in yet.
    final anon = container.read(anonymousUserIdProvider);
    expect(container.read(userIdProvider), anon);

    container.read(authNotifierProvider.notifier).state =
        const AsyncValue.data(AuthUser(id: 'account-after-sign-in'));

    expect(container.read(userIdProvider), 'account-after-sign-in');
  });

  test('the anonymous id is stable across reads', () {
    final container = ProviderContainer();
    addTearDown(container.dispose);

    final first = container.read(anonymousUserIdProvider);
    expect(container.read(anonymousUserIdProvider), first);
    expect(first, isNotEmpty);
  });
}

class _StubAuthNotifier extends AuthNotifier {
  _StubAuthNotifier(this._initial);

  final AsyncValue<AuthUser?> _initial;

  @override
  Future<AuthUser?> build() async {
    state = _initial;
    return _initial.valueOrNull;
  }
}
