import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive/hive.dart';

class LocalStorage {
  final Box _settings;
  final Box _history;

  LocalStorage(this._settings, this._history);

  // Settings
  String? get language => _settings.get('language') as String?;
  set language(String? v) => v != null ? _settings.put('language', v) : _settings.delete('language');

  String? get userName => _settings.get('user_name') as String?;
  set userName(String? v) => v != null ? _settings.put('user_name', v) : _settings.delete('user_name');

  bool get isOnboarded => _settings.get('onboarded') as bool? ?? false;
  set isOnboarded(bool v) => _settings.put('onboarded', v);

  String? get apiBaseUrl => _settings.get('api_base_url') as String?;
  set apiBaseUrl(String? v) => v != null ? _settings.put('api_base_url', v) : _settings.delete('api_base_url');

  String? get apiKey => _settings.get('api_key') as String?;
  set apiKey(String? v) => v != null ? _settings.put('api_key', v) : _settings.delete('api_key');

  String get userId => _settings.get('user_id') as String? ?? 'local-user';
  set userId(String v) => _settings.put('user_id', v);

  // Chat history
  List<Map> get sessions {
    final raw = _history.get('sessions');
    if (raw == null) return [];
    return (raw as List).cast<Map>();
  }

  Future<void> clearHistory() async {
    await _history.clear();
  }
}

final localStorageProvider = Provider<LocalStorage>((ref) {
  return LocalStorage(
    Hive.box('settings'),
    Hive.box('chat_history'),
  );
});
