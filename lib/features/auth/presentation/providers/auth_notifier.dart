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
    final previous = state;
    state = const AsyncValue.loading();
    try {
      state = AsyncValue.data(await signIn(repo));
    } on AuthException catch (e, st) {
      if (e.cancelled) {
        state = previous;
        return;
      }
      state = AsyncValue.error(e, st);
    } catch (e, st) {
      // Not just AuthException: a keystore write, a malformed 200 from
      // kai-auth, or Apple returning a null identityToken all throw plain
      // errors. Letting one escape leaves state stuck on loading forever,
      // which renders the sign-in button permanently disabled with no
      // message — unrecoverable without an app restart.
      state = AsyncValue.error(e, st);
    }
  }
}
