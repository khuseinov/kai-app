/// Authenticated Kai account (kai-auth `users` row).
final class AuthUser {
  const AuthUser({
    required this.id,
    this.email,
    this.displayName,
  });

  final String id;
  final String? email;
  final String? displayName;
}
