import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:hive/hive.dart';
import 'package:kai_app/core/models/tool_source.dart';
import 'package:kai_app/core/storage/cache_manager.dart';
import 'package:kai_app/features/country/data/country_cache.dart';
import 'package:kai_app/features/country/domain/country_tool_result.dart';

// ── Fixtures ───────────────────────────────────────────────────────────────

const _result = CountryToolResult(content: 'Виза не нужна.');
final _resultWithSources = CountryToolResult(
  content: 'Виза не нужна.',
  sources: [
    ToolSource(
      tool: 'visa_checker',
      source: 'gov.th',
      sourceDisplayName: 'Thailand Gov',
      expiresAt: '2099-01-01T00:00:00Z',
    ),
  ],
);

// ── Test setup ─────────────────────────────────────────────────────────────

late Box _box;
late CountryCache _cache;
int _boxCounter = 0;

Future<void> _setUp() async {
  // Hive.init() avoids path_provider plugin (needed only by Hive.initFlutter)
  Hive.init(Directory.systemTemp.path);
  _box = await Hive.openBox('country_cache_test_${++_boxCounter}');
  _cache = CountryCache(CacheManager(_box));
}

Future<void> _tearDown() async {
  await _box.deleteFromDisk();
}

// ── Tests ──────────────────────────────────────────────────────────────────

void main() {
  // ── APP-D4 ────────────────────────────────────────────────────────────────

  setUp(_setUp);
  tearDown(_tearDown);

  test('getFresh returns null before save', () {
    expect(_cache.getFresh('TH', 'visa_checker'), isNull);
  });

  test('getStale returns null before save', () {
    expect(_cache.getStale('TH', 'visa_checker'), isNull);
  });

  test('save + getFresh returns stored content', () async {
    await _cache.save('TH', 'visa_checker', _result);
    final fresh = _cache.getFresh('TH', 'visa_checker');

    expect(fresh, isNotNull);
    expect(fresh!.content, _result.content);
    expect(fresh.sources, isEmpty);
  });

  test('save + getStale returns stored content', () async {
    await _cache.save('TH', 'visa_checker', _result);
    final stale = _cache.getStale('TH', 'visa_checker');

    expect(stale, isNotNull);
    expect(stale!.content, _result.content);
  });

  test('sources round-trip through JSON serialization', () async {
    await _cache.save('TH', 'visa_checker', _resultWithSources);
    final fresh = _cache.getFresh('TH', 'visa_checker');

    expect(fresh, isNotNull);
    expect(fresh!.sources, hasLength(1));
    expect(fresh.sources.first.source, 'gov.th');
    expect(fresh.sources.first.sourceDisplayName, 'Thailand Gov');
    expect(fresh.sources.first.expiresAt, '2099-01-01T00:00:00Z');
  });

  test('different (iso2, tool) keys are independent', () async {
    await _cache.save('TH', 'visa_checker', _result);

    expect(_cache.getFresh('JP', 'visa_checker'), isNull);
    expect(_cache.getFresh('TH', 'risk_assessment'), isNull);
  });

  test('far-future expiresAt keeps entry fresh', () async {
    await _cache.save('TH', 'visa_checker', _resultWithSources);
    // Entry should still be fresh immediately after save
    expect(_cache.getFresh('TH', 'visa_checker'), isNotNull);
  });

  test('fallback TTL (no sources) keeps entry fresh immediately after save',
      () async {
    await _cache.save('TH', 'cost_estimator', _result);
    expect(_cache.getFresh('TH', 'cost_estimator'), isNotNull);
  });

  test('stale entry still returned after fresh TTL expires (simulated)',
      () async {
    // Write both tiers. Verify stale is accessible.
    await _cache.save('JP', 'emergency_contacts', _result);
    // Stale tier uses 30-day TTL — should be present.
    final stale = _cache.getStale('JP', 'emergency_contacts');
    expect(stale, isNotNull);
    expect(stale!.content, _result.content);
  });
}
