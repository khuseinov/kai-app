import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive/hive.dart';

class LocalStorage {
  final Box _settings;
  final Box _history;

  LocalStorage(this._settings, this._history);

  // Settings
  String? get userName => _settings.get('user_name') as String?;
  set userName(String? v) =>
      v != null ? _settings.put('user_name', v) : _settings.delete('user_name');

  bool get isOnboarded => _settings.get('onboarded') as bool? ?? false;
  set isOnboarded(bool v) => _settings.put('onboarded', v);

  String? get apiKey => _settings.get('api_key') as String?;
  set apiKey(String? v) =>
      v != null ? _settings.put('api_key', v) : _settings.delete('api_key');

  String get userId => _settings.get('user_id') as String? ?? 'local-user';
  set userId(String v) => _settings.put('user_id', v);

  ThemeMode? get themeMode {
    final raw = _settings.get('theme_mode') as String?;
    if (raw == null) return null;
    return ThemeMode.values.firstWhere(
      (m) => m.name == raw,
      orElse: () => ThemeMode.system,
    );
  }

  set themeMode(ThemeMode? v) => v != null
      ? _settings.put('theme_mode', v.name)
      : _settings.delete('theme_mode');

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
