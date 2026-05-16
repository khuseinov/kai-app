import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/api/api_client.dart' show ApiClient, apiClientProvider;
import '../../../core/models/tool_source.dart';
import '../../../core/providers/settings_provider.dart';
import '../domain/country_tool_result.dart';
import 'country_cache.dart';
import 'country_iso_list.dart';

/// Structured prompt templates for each of the 6 travel tools.
final _prompts = {
  'visa_checker': (String name, String iso2) =>
      'Визовые требования для $name ($iso2) для гражданина России: '
      'нужна ли виза, тип визы, стоимость, срок и способ оформления. '
      'Кратко и точно.',
  'risk_assessment': (String name, String iso2) =>
      'Уровень безопасности в $name ($iso2) сейчас: '
      'индекс преступности, политическая стабильность, актуальные предупреждения МИД. '
      'Кратко и точно.',
  'route_planner': (String name, String iso2) =>
      'Как добраться из России или Европы в $name ($iso2): '
      'прямые рейсы, стыковки, время в пути, альтернативные маршруты. '
      'Кратко и точно.',
  'cost_estimator': (String name, String iso2) =>
      'Средний бюджет туриста в $name ($iso2) в день в долларах США: '
      'жильё (бюджет/средний/премиум), питание, транспорт, аттракции. '
      'Кратко и точно.',
  'health_requirements': (String name, String iso2) =>
      'Медицинские требования и рекомендации для поездки в $name ($iso2): '
      'обязательные и рекомендованные прививки, страховка, качество медпомощи. '
      'Кратко и точно.',
  'emergency_contacts': (String name, String iso2) =>
      'Экстренные контакты в $name ($iso2): '
      'полиция, скорая помощь, пожарная служба, горячая линия для туристов, '
      'адрес российского посольства. '
      'Только конкретные номера.',
};

class CountryToolRepository {
  final ApiClient _api;
  final AppSettings _settings;
  final CountryCache? _cache;

  CountryToolRepository(this._api, this._settings, [this._cache]);

  Future<CountryToolResult> fetch({
    required String iso2,
    required String tool,
  }) async {
    final promptFn = _prompts[tool];
    if (promptFn == null) throw ArgumentError('Unknown tool: $tool');

    // Return fresh cached result if available.
    final fresh = _cache?.getFresh(iso2, tool);
    if (fresh != null) return fresh;

    final country = kCountryList.where((c) => c.iso2 == iso2).firstOrNull;
    final name = country?.name ?? iso2;
    final prompt = promptFn(name, iso2);

    try {
      final response = await _api.sendMessage(
        message: prompt,
        userId: _settings.userId,
        sessionId: 'country_${iso2}_$tool',
      );

      final content = (response['response'] as String?) ?? '';
      final rawSources = response['sources'];
      final sources = rawSources is List
          ? rawSources
              .whereType<Map<String, dynamic>>()
              .map(ToolSource.fromJson)
              .toList()
          : <ToolSource>[];

      final result = CountryToolResult(content: content, sources: sources);
      await _cache?.save(iso2, tool, result);
      return result;
    } catch (_) {
      // Offline fallback — serve stale cached data rather than an error.
      final stale = _cache?.getStale(iso2, tool);
      if (stale != null) return stale;
      rethrow;
    }
  }
}

final countryToolRepositoryProvider = Provider<CountryToolRepository>((ref) {
  return CountryToolRepository(
    ref.watch(apiClientProvider),
    ref.watch(settingsProvider),
    ref.watch(countryCacheProvider),
  );
});

/// FutureProvider.family — keyed by (iso2, tool), auto-cached by Riverpod.
final countryToolProvider =
    FutureProvider.family<CountryToolResult, (String, String)>(
        (ref, params) async {
  final (iso2, tool) = params;
  return ref.watch(countryToolRepositoryProvider).fetch(iso2: iso2, tool: tool);
});
