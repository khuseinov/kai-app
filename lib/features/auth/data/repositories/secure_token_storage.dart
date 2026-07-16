import 'dart:convert';

import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:kai_app/features/auth/domain/entities/token_pair.dart';

/// Persists the kai-auth [TokenPair] in the platform secure keystore
/// (Keychain / Keystore) — deliberately not Hive/SharedPreferences.
///
/// One key holding one JSON blob, not a field per key: the refresh token is
/// single-use and rotating, so a pair that tears — a process death between two
/// of four independent keystore writes, leaving a NEW access token beside the
/// OLD refresh token — would send an already-spent refresh token on the next
/// expiry. kai-auth reads that as reuse and revokes the whole family, signing
/// the user out of every device. A single write cannot half-land.
class SecureTokenStorage {
  SecureTokenStorage({FlutterSecureStorage? storage})
      : _storage = storage ?? const FlutterSecureStorage();

  final FlutterSecureStorage _storage;

  static const _kTokens = 'kai_auth_tokens';

  Future<void> save(TokenPair tokens) async {
    await _storage.write(
      key: _kTokens,
      value: jsonEncode({
        'access_token': tokens.accessToken,
        'refresh_token': tokens.refreshToken,
        'expires_at': tokens.expiresAt.toIso8601String(),
        'user_id': tokens.userId,
      }),
    );
  }

  Future<TokenPair?> read() async {
    final raw = await _storage.read(key: _kTokens);
    if (raw == null) return null;

    final Object? decoded;
    try {
      decoded = jsonDecode(raw);
    } on FormatException {
      return null;
    }
    if (decoded is! Map) return null;

    final accessToken = decoded['access_token'];
    final refreshToken = decoded['refresh_token'];
    final expiresAtRaw = decoded['expires_at'];
    final userId = decoded['user_id'];
    if (accessToken is! String ||
        refreshToken is! String ||
        expiresAtRaw is! String ||
        userId is! String) {
      return null;
    }
    final expiresAt = DateTime.tryParse(expiresAtRaw);
    if (expiresAt == null) return null;

    return TokenPair(
      accessToken: accessToken,
      refreshToken: refreshToken,
      expiresAt: expiresAt,
      userId: userId,
    );
  }

  Future<void> clear() => _storage.delete(key: _kTokens);
}
