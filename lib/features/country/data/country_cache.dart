import 'dart:convert';

import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/models/tool_source.dart';
import '../../../core/storage/cache_manager.dart';
import '../domain/country_tool_result.dart';

/// Hive-backed offline cache for country tool results.
///
/// Two TTL tiers:
///   - fresh  — respects backend `expires_at` (or 7-day fallback); used for
///              normal reads so stale data is never shown when fresh data fits.
///   - stale  — 30-day fallback; returned only when an API call fails (offline).
class CountryCache {
  final CacheManager _cm;

  static const _fallbackTtl = Duration(days: 7);
  static const _staleTtl = Duration(days: 30);

  CountryCache(this._cm);

  Future<void> save(String iso2, String tool, CountryToolResult result) async {
    final payload = _encode(result);
    final ttl = _ttlFromSources(result.sources);
    await _cm.set(_freshKey(iso2, tool), payload, ttl: ttl);
    await _cm.set(_staleKey(iso2, tool), payload, ttl: _staleTtl);
  }

  CountryToolResult? getFresh(String iso2, String tool) =>
      _decode(_cm.get<String>(_freshKey(iso2, tool)));

  CountryToolResult? getStale(String iso2, String tool) =>
      _decode(_cm.get<String>(_staleKey(iso2, tool)));

  // ── Internals ──────────────────────────────────────────────────────────────

  static String _freshKey(String iso2, String tool) => 'ctry_${iso2}_$tool';
  static String _staleKey(String iso2, String tool) => 'ctry_s_${iso2}_$tool';

  static String _encode(CountryToolResult r) => jsonEncode({
        'content': r.content,
        'sources': r.sources.map((s) => s.toJson()).toList(),
      });

  static CountryToolResult? _decode(String? raw) {
    if (raw == null) return null;
    try {
      final map = jsonDecode(raw) as Map<String, dynamic>;
      return CountryToolResult(
        content: map['content'] as String,
        sources: (map['sources'] as List)
            .whereType<Map<String, dynamic>>()
            .map(ToolSource.fromJson)
            .toList(),
      );
    } catch (_) {
      return null;
    }
  }

  static Duration _ttlFromSources(List<ToolSource> sources) {
    for (final s in sources) {
      if (s.expiresAt == null) continue;
      try {
        final expiry = DateTime.parse(s.expiresAt!);
        final now = DateTime.now();
        if (expiry.isAfter(now)) return expiry.difference(now);
      } catch (_) {
        continue;
      }
    }
    return _fallbackTtl;
  }
}

final countryCacheProvider = Provider<CountryCache>((ref) {
  return CountryCache(ref.watch(cacheManagerProvider));
});
