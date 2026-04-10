import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/api/api_client.dart';
import '../../../core/storage/secure_storage.dart';
import '../data/auth_remote_source.dart';
import '../data/auth_repository.dart';
import 'auth_state.dart';

class AuthNotifier extends StateNotifier<AuthState> {
  final AuthRepository _repository;

  AuthNotifier(this._repository) : super(const AuthInitial()) {
    _checkAuth();
  }

  Future<void> _checkAuth() async {
    state = const AuthLoading();
    final isLoggedIn = await _repository.tryAutoLogin();
    // For now, since we don't have persisted user data, always unauthenticated
    // When backend is ready, we'd fetch user profile here
    state = isLoggedIn ? const Unauthenticated() : const Unauthenticated();
  }

  Future<void> login({required String email, required String password}) async {
    state = const AuthLoading();
    try {
      final result = await _repository.login(email: email, password: password);
      state = Authenticated(result.user);
    } catch (e) {
      state = AuthError('Ошибка входа: $e');
    }
  }

  Future<void> register({
    required String email,
    required String password,
    String? name,
  }) async {
    state = const AuthLoading();
    try {
      final result = await _repository.register(
        email: email,
        password: password,
        name: name,
      );
      state = Authenticated(result.user);
    } catch (e) {
      state = AuthError('Ошибка регистрации: $e');
    }
  }

  Future<void> logout() async {
    await _repository.logout();
    state = const Unauthenticated();
  }
}

// Providers
final authRemoteSourceProvider = Provider<AuthRemoteSource>((ref) {
  return AuthRemoteSource(ref.watch(apiClientProvider));
});

final authRepositoryProvider = Provider<AuthRepository>((ref) {
  return AuthRepository(
    ref.watch(authRemoteSourceProvider),
    ref.watch(secureStorageProvider),
  );
});

final authNotifierProvider = StateNotifierProvider<AuthNotifier, AuthState>((ref) {
  return AuthNotifier(ref.watch(authRepositoryProvider));
});
