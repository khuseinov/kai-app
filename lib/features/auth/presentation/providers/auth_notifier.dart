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
    final legacyUserId = ref.read(userIdProvider);
    final previous = state;
    state = const AsyncValue.loading();
    try {
      final user = await signIn(repo);
      await repo.claimLegacyUser(legacyUserId);
      state = AsyncValue.data(user);
    } on AuthException catch (e, st) {
      if (e.cancelled) {
        state = previous;
        return;
      }
      state = AsyncValue.error(e, st);
    }
  }
}
