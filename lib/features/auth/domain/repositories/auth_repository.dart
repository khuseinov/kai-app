import 'package:kai_app/features/auth/domain/entities/auth_user.dart';

/// Thrown when a sign-in/refresh/claim call is rejected by kai-auth, or the
/// native provider SDK fails.
class AuthException implements Exception {
  const AuthException(this.message, {this.cancelled = false});

  final String message;

  /// true when the user dismissed the native sign-in sheet — callers should
  /// treat this as a silent no-op, not an error to surface.
  final bool cancelled;

  @override
  String toString() => 'AuthException($message)';
}

/// Native Google/Apple sign-in, kai-auth token lifecycle, and legacy
/// anonymous-id migration (APP-AUTH-1).
abstract class AuthRepository {
  /// Loads any persisted token pair from secure storage. Returns the
  /// restored user, or null when signed out / no valid session.
  Future<AuthUser?> restoreSession();

  /// Runs native Google sign-in, exchanges the id_token with kai-auth.
  /// Throws [AuthException] on cancellation or rejection.
  Future<AuthUser> signInWithGoogle();

  /// Runs native Apple sign-in, exchanges the identity_token with kai-auth.
  /// Throws [AuthException] on cancellation or rejection.
  Future<AuthUser> signInWithApple();

  /// One-time migration: binds the pre-auth anonymous [legacyUserId] to the
  /// now-authenticated account so existing session/memory history is kept.
  /// Safe to call more than once (kai-auth's `/claim` is idempotent).
  Future<void> claimLegacyUser(String legacyUserId);

  /// Revokes the current refresh-token family and clears local storage.
  Future<void> signOut();

  /// A valid access token, refreshing first if expired. Null when signed out
  /// or refresh fails (callers should treat that as signed-out).
  Future<String?> validAccessToken();
}
