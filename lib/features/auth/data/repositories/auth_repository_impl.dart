import 'dart:convert';
import 'dart:math';

import 'package:crypto/crypto.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:kai_app/features/auth/data/datasources/auth_remote_source.dart';
import 'package:kai_app/features/auth/data/repositories/secure_token_storage.dart';
import 'package:kai_app/features/auth/domain/entities/auth_user.dart';
import 'package:kai_app/features/auth/domain/entities/token_pair.dart';
import 'package:kai_app/features/auth/domain/repositories/auth_repository.dart';
import 'package:sign_in_with_apple/sign_in_with_apple.dart';

/// [AuthRepository] backed by native Google/Apple sign-in + kai-auth
/// (`services/auth/openapi.yaml` v0.2.0).
class AuthRepositoryImpl implements AuthRepository {
  AuthRepositoryImpl({
    required AuthRemoteSource remote,
    required SecureTokenStorage storage,
    String? googleServerClientId,
    String? googleIosClientId,
  })  : _remote = remote,
        _storage = storage,
        _googleServerClientId = googleServerClientId,
        _googleIosClientId = googleIosClientId;

  final AuthRemoteSource _remote;
  final SecureTokenStorage _storage;
  final String? _googleServerClientId;
  final String? _googleIosClientId;

  TokenPair? _tokens;
  bool _googleInitialized = false;
  Future<TokenPair>? _refreshInFlight;

  // ponytail: GoogleSignIn.instance.initialize() is documented to be called
  // exactly once per process — repeated calls aren't supported by the v7
  // API. So this nonce is fixed for the app's running lifetime rather than
  // rotated per sign-in attempt. The server still does an exact-match check
  // against whatever the client sends, so replay protection holds across
  // app restarts; it just doesn't rotate within one still-running session.
  // Upgrade: rotate if the package ever exposes a re-init/dispose path.
  late final String _googleNonce = _randomNonce();

  @override
  Future<AuthUser?> restoreSession() async {
    final tokens = await _storage.read();
    if (tokens == null) return null;
    _tokens = tokens;
    return AuthUser(id: tokens.userId);
  }

  @override
  Future<AuthUser> signInWithGoogle() async {
    await _ensureGoogleInitialized();
    final GoogleSignInAccount account;
    try {
      account = await GoogleSignIn.instance.authenticate();
    } on GoogleSignInException catch (e) {
      if (e.code == GoogleSignInExceptionCode.canceled) {
        throw const AuthException('cancelled', cancelled: true);
      }
      throw AuthException(e.description ?? 'google sign-in failed');
    }
    final idToken = account.authentication.idToken;
    if (idToken == null) {
      throw const AuthException('google sign-in returned no id_token');
    }
    final tokens = await _remote.exchangeGoogle(
      idToken: idToken,
      nonce: _googleNonce,
    );
    return _commit(
      tokens,
      displayName: account.displayName,
      email: account.email,
    );
  }

  @override
  Future<AuthUser> signInWithApple() async {
    final rawNonce = _randomNonce();
    final hashedNonce = sha256.convert(utf8.encode(rawNonce)).toString();
    final AuthorizationCredentialAppleID credential;
    try {
      credential = await SignInWithApple.getAppleIDCredential(
        scopes: [
          AppleIDAuthorizationScopes.email,
          AppleIDAuthorizationScopes.fullName,
        ],
        nonce: hashedNonce,
      );
    } on SignInWithAppleAuthorizationException catch (e) {
      if (e.code == AuthorizationErrorCode.canceled) {
        throw const AuthException('cancelled', cancelled: true);
      }
      throw AuthException(e.message);
    }
    final fullName = [credential.givenName, credential.familyName]
        .whereType<String>()
        .where((s) => s.isNotEmpty)
        .join(' ');
    final tokens = await _remote.exchangeApple(
      identityToken: credential.identityToken!,
      nonce: rawNonce,
      fullName: fullName.isEmpty ? null : fullName,
    );
    return _commit(
      tokens,
      displayName: fullName.isEmpty ? null : fullName,
      email: credential.email,
    );
  }

  @override
  Future<void> claimLegacyUser(String legacyUserId) async {
    final tokens = _tokens;
    if (tokens == null) return;
    await _remote.claimLegacyUser(legacyUserId, tokens.accessToken);
  }

  @override
  Future<void> signOut() async {
    final tokens = _tokens;
    _tokens = null;
    await _storage.clear();
    if (tokens != null) {
      await _remote.logout(tokens.refreshToken);
    }
  }

  @override
  Future<String?> validAccessToken() async {
    final tokens = _tokens;
    if (tokens == null) return null;
    if (!tokens.isExpired) return tokens.accessToken;

    // Single-flight: the refresh token is single-use/rotating, so concurrent
    // callers must share one in-flight refresh rather than each burning it —
    // a second call with the now-already-rotated token would be treated by
    // kai-auth as reuse and revoke the whole family.
    final inFlight = _refreshInFlight;
    if (inFlight != null) {
      final refreshed = await inFlight;
      return refreshed.accessToken;
    }

    final future = _remote.refresh(tokens.refreshToken);
    _refreshInFlight = future;
    try {
      final refreshed = await future;
      _tokens = refreshed;
      await _storage.save(refreshed);
      return refreshed.accessToken;
    } on AuthException {
      _tokens = null;
      await _storage.clear();
      return null;
    } finally {
      _refreshInFlight = null;
    }
  }

  Future<AuthUser> _commit(
    TokenPair tokens, {
    String? displayName,
    String? email,
  }) async {
    _tokens = tokens;
    await _storage.save(tokens);
    return AuthUser(id: tokens.userId, displayName: displayName, email: email);
  }

  Future<void> _ensureGoogleInitialized() async {
    if (_googleInitialized) return;
    await GoogleSignIn.instance.initialize(
      clientId: _googleIosClientId,
      serverClientId: _googleServerClientId,
      nonce: _googleNonce,
    );
    _googleInitialized = true;
  }

  String _randomNonce([int length = 32]) {
    const charset =
        'ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789-._';
    final random = Random.secure();
    return List.generate(
      length,
      (_) => charset[random.nextInt(charset.length)],
    ).join();
  }
}
