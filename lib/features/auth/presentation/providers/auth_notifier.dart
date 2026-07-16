import 'package:kai_app/core/providers/root.dart';
import 'package:kai_app/features/auth/domain/entities/auth_user.dart';
import 'package:kai_app/features/auth/domain/repositories/auth_repository.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'auth_notifier.g.dart';

/// Current signed-in Kai account, or null when signed out.
///
/// `null` data (not an [AsyncError]) is the signed-out state — an empty
/// restored session is a normal outcome, not a failure. Genuine sign-in/
/// refresh failures surface as [AsyncError]; a user-cancelled native sign-in
/// sheet reverts to whatever state preceded the attempt instead.
@Riverpod(keepAlive: true)
class AuthNotifier extends _$AuthNotifier {
  @override
  Future<AuthUser?> build() {
    return ref.watch(authRepositoryProvider).restoreSession();
  }

  Future<void> signInWithGoogle() => _signIn((repo) => repo.signInWithGoogle());

  Future<void> signInWithApple() => _signIn((repo) => repo.signInWithApple());

  /// The session was torn down from under us (refresh rejected — expired, or
  /// the family was revoked server-side). The repository has already cleared
  /// its tokens; this just makes the UI agree, so the user is offered sign-in
  /// again instead of staring at a stale account row.
  void onSessionLost() {
    if (state.valueOrNull == null) return;
    state = const AsyncValue.data(null);
  }

  Future<void> signOut() async {
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(() async {
      await ref.read(authRepositoryProvider).signOut();
      return null;
    });
  }

  Future<void> _signIn(
    Future<AuthUser> Function(AuthRepository repo) signIn,
  ) async {
    final repo = ref.read(authRepositoryProvider);
    final legacyUserId = ref.read(anonymousUserIdProvider);
    final previous = state;
    state = const AsyncValue.loading();
    final AuthUser user;
    try {
      user = await signIn(repo);
    } on AuthException catch (e, st) {
      if (e.cancelled) {
        state = previous;
        return;
      }
      state = AsyncValue.error(e, st);
      return;
    } catch (e, st) {
      // Not just AuthException: a keystore write, a malformed 200 from
      // kai-auth, or Apple returning a null identityToken all throw plain
      // errors. Letting one escape leaves state stuck on loading forever,
      // which renders the sign-in button permanently disabled with no
      // message — unrecoverable without an app restart.
      state = AsyncValue.error(e, st);
      return;
    }

    // Publish before claiming: signIn() already committed the tokens, so the
    // interceptor is attaching the new access token from here on. Until this
    // line lands, userIdProvider still reports the anonymous id — and a
    // request carrying the new token with the old id is exactly what kai-core
    // 403s on. claimLegacyUser is a network round-trip, so that would be a
    // wide-open window, not a microtask.
    state = AsyncValue.data(user);

    // Best-effort: the sign-in itself already succeeded. A failure here (409
    // when this legacy id belongs to another account, or the box simply being
    // offline) must not report the sign-in as failed while the tokens stay
    // persisted — that desyncs the UI into "signed out" while every request
    // goes out authenticated.
    try {
      await repo.claimLegacyUser(legacyUserId);
    } catch (_) {
      // ponytail: silent. Nothing consumes the alias yet (kai-core doesn't
      // read user_aliases), so a failed claim costs the user nothing today.
      // Surface it once history migration actually depends on it.
    }
  }
}
