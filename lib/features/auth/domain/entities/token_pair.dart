/// kai-auth access + refresh token pair (`services/auth/openapi.yaml` v0.2.0
/// `TokenPair`, kai-agent repo).
final class TokenPair {
  const TokenPair({
    required this.accessToken,
    required this.refreshToken,
    required this.expiresAt,
    required this.userId,
  });

  final String accessToken;
  final String refreshToken;

  /// Wall-clock expiry, computed client-side from `expires_in` at receipt.
  final DateTime expiresAt;
  final String userId;

  /// 30s safety margin so an in-flight request doesn't cross the real
  /// server-side expiry mid-air.
  bool get isExpired =>
      DateTime.now().isAfter(expiresAt.subtract(const Duration(seconds: 30)));
}
