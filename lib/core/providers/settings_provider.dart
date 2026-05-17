import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../config/env_config.dart';
import '../storage/local_storage.dart';
import '../storage/secure_storage.dart';

class AppSettings {
  final String apiBaseUrl;
  final String? apiKey;
  final String? userName;
  final bool isOnboarded;
  final String userId;
  final ThemeMode themeMode;
  final bool reduceMotion;

  const AppSettings({
    required this.apiBaseUrl,
    this.apiKey,
    this.userName,
    this.isOnboarded = false,
    this.userId = 'local-user',
    this.themeMode = ThemeMode.system,
    this.reduceMotion = false,
  });

  AppSettings copyWith({
    String? apiBaseUrl,
    String? apiKey,
    String? userName,
    bool? isOnboarded,
    String? userId,
    ThemeMode? themeMode,
    bool? reduceMotion,
  }) {
    return AppSettings(
      apiBaseUrl: apiBaseUrl ?? this.apiBaseUrl,
      apiKey: apiKey ?? this.apiKey,
      userName: userName ?? this.userName,
      isOnboarded: isOnboarded ?? this.isOnboarded,
      userId: userId ?? this.userId,
      themeMode: themeMode ?? this.themeMode,
      reduceMotion: reduceMotion ?? this.reduceMotion,
    );
  }
}

class SettingsNotifier extends StateNotifier<AppSettings> {
  final LocalStorage _localStorage;
  final SecureStorage _secureStorage;

  SettingsNotifier(this._localStorage, this._secureStorage)
      : super(
          AppSettings(
            apiBaseUrl: EnvConfig.apiBaseUrl,
            apiKey: null, // loaded async
            userName: _localStorage.userName,
            isOnboarded: _localStorage.isOnboarded,
            userId: _localStorage.userId,
            themeMode: _localStorage.themeMode ?? ThemeMode.system,
            reduceMotion: _localStorage.reduceMotion,
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

  Future<void> setApiKey(String? key) async {
    if (key != null && key.trim().isNotEmpty) {
      await _secureStorage.writeApiKey(key.trim());
      state = state.copyWith(apiKey: key.trim());
    } else {
      await _secureStorage.deleteApiKey();
      state = state.copyWith(apiKey: null);
    }
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

  void setThemeMode(ThemeMode mode) {
    _localStorage.themeMode = mode;
    state = state.copyWith(themeMode: mode);
  }

  void setReduceMotion(bool value) {
    _localStorage.reduceMotion = value;
    state = state.copyWith(reduceMotion: value);
  }
}

final settingsProvider =
    StateNotifierProvider<SettingsNotifier, AppSettings>((ref) {
  return SettingsNotifier(
    ref.watch(localStorageProvider),
    ref.watch(secureStorageProvider),
  );
});
