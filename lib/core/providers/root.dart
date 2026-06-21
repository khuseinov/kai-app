import 'dart:async';

import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:hive/hive.dart';
import 'package:kai_app/core/network/dio_client.dart';
import 'package:kai_app/core/network/interceptors/auth_interceptor.dart';
import 'package:kai_app/core/network/interceptors/connectivity_interceptor.dart';
import 'package:kai_app/core/network/interceptors/error_interceptor.dart';
import 'package:kai_app/core/network/interceptors/logging_interceptor.dart';
import 'package:kai_app/core/network/interceptors/retry_interceptor.dart';
import 'package:kai_app/core/storage/hive_setup.dart';
import 'package:kai_app/features/auth/data/repositories/mock_session_repository.dart';
import 'package:kai_app/features/auth/data/repositories/session_repository_impl.dart';
import 'package:kai_app/features/auth/domain/repositories/session_repository.dart';
import 'package:kai_app/features/memory/data/repositories/memory_repository_impl.dart';
import 'package:kai_app/features/memory/data/repositories/mock_memory_repository.dart';
import 'package:kai_app/features/memory/domain/repositories/memory_repository.dart';
import 'package:kai_app/features/room/data/repositories/chat_repository_impl.dart';
import 'package:kai_app/features/room/data/repositories/mock_chat_repository.dart';
import 'package:kai_app/features/room/domain/repositories/chat_repository.dart';
import 'package:kai_app/features/settings/data/models/settings.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:uuid/uuid.dart';

part 'root.g.dart';

/// Env-loaded configuration. Populated by `bootstrap` via flutter_dotenv.
class EnvConfig {
  const EnvConfig({
    required this.apiBaseUrl,
    this.useRealChat = false,
    this.internalHealthToken,
  });

  /// Read from `dotenv.env`, falling back to sensible defaults.
  factory EnvConfig.fromDotenv() {
    final url = dotenv.maybeGet('API_BASE_URL') ?? 'https://api.wize.travel';
    final useReal = dotenv.maybeGet('USE_REAL_CHAT') == 'true';
    final token = dotenv.maybeGet('INTERNAL_HEALTH_TOKEN');
    return EnvConfig(
      apiBaseUrl: url,
      useRealChat: useReal,
      internalHealthToken: token,
    );
  }

  final String apiBaseUrl;

  /// When `true`, `chatRepositoryProvider` and `sessionRepositoryProvider`
  /// use the real Hive/Dio-backed implementations instead of mocks.
  final bool useRealChat;

  /// Token for backend admin/health endpoints (e.g. INTERNAL_HEALTH_TOKEN).
  final String? internalHealthToken;
}

/// Env configuration. Overridden in `bootstrap` / tests as needed.
@Riverpod(keepAlive: true)
EnvConfig env(EnvRef ref) {
  return EnvConfig.fromDotenv();
}

/// Stable anonymous user id. Generated once and persisted in Hive.
@Riverpod(keepAlive: true)
String userId(UserIdRef ref) {
  final box = HiveSetup.userIds;
  var uid = box.get(HiveSetup.userIdKey);
  if (uid == null || uid.isEmpty) {
    uid = const Uuid().v4();
    unawaited(box.put(HiveSetup.userIdKey, uid));
  }
  return uid;
}

/// Single Dio client wired with the full interceptor chain.
@Riverpod(keepAlive: true)
Dio dio(DioRef ref) {
  final env = ref.watch(envProvider);
  final retry = RetryInterceptor();
  final dio = buildDioClient(
    baseUrl: env.apiBaseUrl,
    interceptors: [
      ConnectivityInterceptor(),
      AuthInterceptor(token: env.internalHealthToken),
      LoggingInterceptor(),
      retry,
      ErrorInterceptor(),
    ],
  );
  retry.attach(dio);
  return dio;
}

/// Active theme mode. Toggled from the theme showcase screen.
@Riverpod(keepAlive: true)
class ThemeModeNotifier extends _$ThemeModeNotifier {
  // ponytail: Simple conversion between AppThemeMode and ThemeMode keeps persistence code dry and safe for unit tests.
  @override
  ThemeMode build() {
    if (Hive.isBoxOpen(HiveSetup.settingsBoxName)) {
      final settings = HiveSetup.settings.get(HiveSetup.settingsKey) ?? const AppSettings();
      return _toThemeMode(settings.themeMode);
    }
    return ThemeMode.system;
  }

  Future<void> setThemeMode(ThemeMode mode) async {
    state = mode;
    if (Hive.isBoxOpen(HiveSetup.settingsBoxName)) {
      final settings = HiveSetup.settings.get(HiveSetup.settingsKey) ?? const AppSettings();
      await HiveSetup.settings.put(
        HiveSetup.settingsKey,
        settings.copyWith(themeMode: _toAppThemeMode(mode)),
      );
    }
  }

  ThemeMode _toThemeMode(AppThemeMode mode) {
    switch (mode) {
      case AppThemeMode.system:
        return ThemeMode.system;
      case AppThemeMode.light:
        return ThemeMode.light;
      case AppThemeMode.dark:
        return ThemeMode.dark;
    }
  }

  AppThemeMode _toAppThemeMode(ThemeMode mode) {
    switch (mode) {
      case ThemeMode.system:
        return AppThemeMode.system;
      case ThemeMode.light:
        return AppThemeMode.light;
      case ThemeMode.dark:
        return AppThemeMode.dark;
    }
  }
}

// Backward-compatible alias for app.dart and theme references
final themeModeProvider = themeModeNotifierProvider;

/// Chat repository. Switches between mock and real based on [EnvConfig.useRealChat].
@Riverpod(keepAlive: true)
ChatRepository chatRepository(ChatRepositoryRef ref) {
  final env = ref.watch(envProvider);
  if (env.useRealChat) {
    return RealChatRepository.withDio(
      ref.watch(dioProvider),
      userId: ref.watch(userIdProvider),
    );
  }
  return MockChatRepository();
}

/// Session repository. Switches between mock and real based on [EnvConfig.useRealChat].
@Riverpod(keepAlive: true)
SessionRepository sessionRepository(SessionRepositoryRef ref) {
  final env = ref.watch(envProvider);
  if (env.useRealChat) return RealSessionRepository();
  return MockSessionRepository();
}

/// Memory repository. Switches between mock and real based on [EnvConfig.useRealChat].
@Riverpod(keepAlive: true)
MemoryRepository memoryRepository(MemoryRepositoryRef ref) {
  final env = ref.watch(envProvider);
  if (env.useRealChat) return MemoryRepositoryImpl();
  return MockMemoryRepository();
}
