import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../config/env_config.dart';
import '../storage/local_storage.dart';
import '../storage/secure_storage.dart';

class AppSettings {
  final String apiBaseUrl;
  final String? apiKey;
  final String? language;
  final String? userName;
  final bool isOnboarded;
  final String userId;

  const AppSettings({
    required this.apiBaseUrl,
    this.apiKey,
    this.language,
    this.userName,
    this.isOnboarded = false,
    this.userId = 'local-user',
  });

  AppSettings copyWith({
    String? apiBaseUrl,
    String? apiKey,
    String? language,
    String? userName,
    bool? isOnboarded,
    String? userId,
  }) {
    return AppSettings(
      apiBaseUrl: apiBaseUrl ?? this.apiBaseUrl,
      apiKey: apiKey ?? this.apiKey,
      language: language ?? this.language,
      userName: userName ?? this.userName,
      isOnboarded: isOnboarded ?? this.isOnboarded,
      userId: userId ?? this.userId,
    );
  }
}

class SettingsNotifier extends StateNotifier<AppSettings> {
  final LocalStorage _localStorage;
  final SecureStorage _secureStorage;

  SettingsNotifier(this._localStorage, this._secureStorage)
      : super(
          AppSettings(
            // EnvConfig.apiBaseUrl now points to Nginx (port 80) on VPS.
            // Falls back to VPS IP if no override is stored locally.
            apiBaseUrl: _localStorage.apiBaseUrl ?? EnvConfig.apiBaseUrl,
            apiKey: null, // loaded async
            language: _localStorage.language,
            userName: _localStorage.userName,
            isOnboarded: _localStorage.isOnboarded,
            userId: _localStorage.userId,
          ),
        ) {
    _loadApiKey();
  }

  Future<void> _loadApiKey() async {
    final apiKey = await _secureStorage.readApiKey();
    if (apiKey != null) {
      state = state.copyWith(apiKey: apiKey);
    }
  }

  Future<void> setApiBaseUrl(String? url) async {
    final effectiveUrl =
        (url != null && url.trim().isNotEmpty) ? url.trim() : null;
    _localStorage.apiBaseUrl = effectiveUrl;
    state = state.copyWith(
      apiBaseUrl: effectiveUrl ?? EnvConfig.apiBaseUrl,
    );
  }

  Future<void> setApiKey(String? key) async {
    if (key != null && key.trim().isNotEmpty) {
      await _secureStorage.writeApiKey(key.trim());
      state = state.copyWith(apiKey: key.trim());
    } else {
      await _secureStorage.deleteApiKey();
      state = state.copyWith(apiKey: null);
    }
  }

  void setLanguage(String? lang) {
    _localStorage.language = lang;
    state = state.copyWith(language: lang);
  }

  void setUserName(String? name) {
    _localStorage.userName = name;
    state = state.copyWith(userName: name);
  }

  void setOnboarded(bool value) {
    _localStorage.isOnboarded = value;
    state = state.copyWith(isOnboarded: value);
  }

  void setUserId(String id) {
    _localStorage.userId = id;
    state = state.copyWith(userId: id);
  }
}

final settingsProvider =
    StateNotifierProvider<SettingsNotifier, AppSettings>((ref) {
  return SettingsNotifier(
    ref.watch(localStorageProvider),
    ref.watch(secureStorageProvider),
  );
});
