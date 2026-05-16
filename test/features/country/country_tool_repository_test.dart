import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:kai_app/core/api/api_client.dart';
import 'package:kai_app/core/models/tool_source.dart';
import 'package:kai_app/core/providers/settings_provider.dart';
import 'package:kai_app/features/country/data/country_tool_repository.dart';
import 'package:kai_app/features/country/domain/country_tool_result.dart';

// ── Fake helpers ───────────────────────────────────────────────────────────

const _settings = AppSettings(apiBaseUrl: 'http://fake');

// Dio() factory returns a concrete DioForNative. Since sendMessage is
// overridden, the Dio instance is never actually invoked.
class _FakeApiClient extends ApiClient {
  final Map<String, dynamic> response;

  _FakeApiClient(this.response) : super(Dio());

  @override
  Future<Map<String, dynamic>> sendMessage({
    required String message,
    required String userId,
    required String sessionId,
  }) async =>
      response;
}

class _CapturingApiClient extends ApiClient {
  final Map<String, dynamic> response;
  final void Function(String)? onSend;
  final void Function(String)? onSession;

  _CapturingApiClient({
    required this.response,
    this.onSend,
    this.onSession,
  }) : super(Dio());

  @override
  Future<Map<String, dynamic>> sendMessage({
    required String message,
    required String userId,
    required String sessionId,
  }) async {
    onSend?.call(message);
    onSession?.call(sessionId);
    return response;
  }
}

// ── Unit tests ─────────────────────────────────────────────────────────────

void main() {
  // ── APP-D3 ────────────────────────────────────────────────────────────────

  test('fetch returns CountryToolResult with content', () async {
    final repo = CountryToolRepository(
      _FakeApiClient({
        'response': 'Виза не требуется для Таиланда.',
        'sources': <dynamic>[],
      }),
      _settings,
    );

    final result = await repo.fetch(iso2: 'TH', tool: 'visa_checker');

    expect(result, isA<CountryToolResult>());
    expect(result.content, 'Виза не требуется для Таиланда.');
    expect(result.sources, isEmpty);
  });

  test('fetch parses sources list correctly', () async {
    final repo = CountryToolRepository(
      _FakeApiClient({
        'response': 'Информация о безопасности.',
        'sources': [
          {
            'tool': 'risk_assessment',
            'source': 'mfa.gov.ru',
            'source_display_name': 'МИД России',
            'fetched_at': '2026-05-16T10:00:00Z',
            'expires_at': '2026-05-17T10:00:00Z',
          }
        ],
      }),
      _settings,
    );

    final result = await repo.fetch(iso2: 'TH', tool: 'risk_assessment');

    expect(result.sources, hasLength(1));
    expect(result.sources.first, isA<ToolSource>());
    expect(result.sources.first.source, 'mfa.gov.ru');
    expect(result.sources.first.sourceDisplayName, 'МИД России');
    expect(result.sources.first.fetchedAt, '2026-05-16T10:00:00Z');
  });

  test('fetch handles missing sources key gracefully', () async {
    final repo = CountryToolRepository(
      _FakeApiClient({'response': 'Данные.'}),
      _settings,
    );

    final result = await repo.fetch(iso2: 'JP', tool: 'cost_estimator');
    expect(result.sources, isEmpty);
  });

  test('fetch treats null response field as empty string', () async {
    final repo = CountryToolRepository(
      _FakeApiClient({'response': null, 'sources': <dynamic>[]}),
      _settings,
    );

    final result = await repo.fetch(iso2: 'TH', tool: 'cost_estimator');
    expect(result.content, '');
  });

  test('fetch throws ArgumentError for unknown tool', () async {
    final repo = CountryToolRepository(
      _FakeApiClient({'response': 'ok'}),
      _settings,
    );

    expect(
      () => repo.fetch(iso2: 'TH', tool: 'nonexistent_tool'),
      throwsA(isA<ArgumentError>()),
    );
  });

  test('fetch uses Russian country name in prompt for known iso2', () async {
    String? captured;
    final repo = CountryToolRepository(
      _CapturingApiClient(
        response: {'response': 'ok', 'sources': <dynamic>[]},
        onSend: (msg) => captured = msg,
      ),
      _settings,
    );

    await repo.fetch(iso2: 'TH', tool: 'visa_checker');

    expect(captured, contains('Таиланд'));
    expect(captured, contains('TH'));
  });

  test('fetch falls back to iso2 code for unknown country', () async {
    String? captured;
    final repo = CountryToolRepository(
      _CapturingApiClient(
        response: {'response': 'ok', 'sources': <dynamic>[]},
        onSend: (msg) => captured = msg,
      ),
      _settings,
    );

    await repo.fetch(iso2: 'ZZ', tool: 'emergency_contacts');
    expect(captured, contains('ZZ'));
  });

  test('fetch uses country_iso_tool session ID pattern', () async {
    String? capturedSession;
    final repo = CountryToolRepository(
      _CapturingApiClient(
        response: {'response': 'ok', 'sources': <dynamic>[]},
        onSession: (s) => capturedSession = s,
      ),
      _settings,
    );

    await repo.fetch(iso2: 'JP', tool: 'health_requirements');
    expect(capturedSession, 'country_JP_health_requirements');
  });

  test('countryToolProvider family returns distinct futures per key', () {
    final container = ProviderContainer(
      overrides: [
        countryToolRepositoryProvider.overrideWith(
          (_) => CountryToolRepository(
            _FakeApiClient({'response': 'ok', 'sources': <dynamic>[]}),
            _settings,
          ),
        ),
      ],
    );
    addTearDown(container.dispose);

    final p1 = container.read(countryToolProvider(('TH', 'visa_checker')));
    final p2 = container.read(countryToolProvider(('JP', 'visa_checker')));

    // Different iso2 keys produce independent AsyncValue instances
    expect(p1, isNot(same(p2)));
  });
}
