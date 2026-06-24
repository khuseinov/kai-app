import 'dart:async';
import 'dart:convert';
import 'dart:io' as io;

import 'package:crypto/crypto.dart';
import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
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
import 'package:kai_app/features/voice/data/repositories/voice_repository_impl.dart';
import 'package:kai_app/features/voice/data/services/just_audio_player_service.dart';
import 'package:kai_app/features/voice/data/services/record_audio_recorder_service.dart';
import 'package:kai_app/features/voice/domain/repositories/voice_repository.dart';
import 'package:kai_app/features/voice/domain/services/audio_player_service.dart';
import 'package:kai_app/features/voice/domain/services/audio_recorder_service.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:uuid/uuid.dart';

part 'root.g.dart';

/// Env-loaded configuration. Populated by `bootstrap` via flutter_dotenv.
class EnvConfig {
  const EnvConfig({
    required this.apiBaseUrl,
    this.voiceGatewayBaseUrl,
    this.voiceGatewayApiKey,
    this.useRealChat = true,
    this.internalHealthToken,
    this.hfToken,
    this.hfTokenProvided = false,
  });

  factory EnvConfig.fromDotenv() {
    final isTest = !kIsWeb && io.Platform.environment.containsKey('FLUTTER_TEST');
    final defaultUseReal = !isTest;
    try {
      final url = dotenv.maybeGet('API_BASE_URL') ?? 'https://rustamkhuseinov-kai.hf.space';
      final voiceGatewayUrl = dotenv.maybeGet('VOICE_GATEWAY_BASE_URL');
      final voiceGatewayKey = dotenv.maybeGet('VOICE_GATEWAY_API_KEY')?.trim();
      final useReal = dotenv.maybeGet('USE_REAL_CHAT') != null
          ? dotenv.maybeGet('USE_REAL_CHAT') == 'true'
          : defaultUseReal;
      final internalToken = dotenv.maybeGet('INTERNAL_HEALTH_TOKEN') ?? '2ddd1306da666a79a2eb56988b5fe84c042e4ea4d7c61ff689e42e2b1e96efba';
      final rawHfToken = dotenv.maybeGet('HF_TOKEN')?.trim();
      final hfToken = (rawHfToken != null && rawHfToken.isNotEmpty) ? rawHfToken : null;
      final hfTokenProvided = hfToken != null;

      if (EnvConfig.diagnosticsEnabled) {
        debugPrint(
          '[KAI_DIAGNOSTICS] EnvConfig loaded: '
          'apiBaseUrl=$url, '
          'voiceGatewayBaseUrl=$voiceGatewayUrl, '
          'voiceGatewayApiKeyEmpty=${voiceGatewayKey == null || voiceGatewayKey.isEmpty}, '
          'hfTokenProvided=$hfTokenProvided, '
          'hfTokenPrefix=${_sha256Prefix(hfToken)}, '
          'internalTokenEmpty=${internalToken.isEmpty}, '
          'internalTokenPrefix=${_sha256Prefix(internalToken)}',
        );
      }

      return EnvConfig(
        apiBaseUrl: url,
        voiceGatewayBaseUrl: voiceGatewayUrl,
        voiceGatewayApiKey: voiceGatewayKey,
        useRealChat: useReal,
        internalHealthToken: internalToken,
        hfToken: hfToken,
        hfTokenProvided: hfTokenProvided,
      );
    } catch (_) {
      return EnvConfig(
        apiBaseUrl: 'https://rustamkhuseinov-kai.hf.space',
        useRealChat: defaultUseReal,
        internalHealthToken: '2ddd1306da666a79a2eb56988b5fe84c042e4ea4d7c61ff689e42e2b1e96efba',
      );
    }
  }

  /// Whether diagnostics logging is enabled for this build.
  static bool get diagnosticsEnabled =>
      !kReleaseMode || const bool.fromEnvironment('KAI_DIAGNOSTICS');

  final String apiBaseUrl;

  /// Base URL of the voice-gateway microservice.
  /// When omitted, voice features are unavailable.
  final String? voiceGatewayBaseUrl;

  /// API key for voice-gateway endpoints (`X-Internal-API-Key`).
  final String? voiceGatewayApiKey;

  /// When `true`, `chatRepositoryProvider` and `sessionRepositoryProvider`
  /// use the real Hive/Dio-backed implementations instead of mocks.
  final bool useRealChat;

  /// Token for backend admin/health endpoints (e.g. INTERNAL_HEALTH_TOKEN).
  final String? internalHealthToken;

  /// Hugging Face access token. Required when the Space is private so that
  /// the HF edge proxy forwards requests to the container.
  final String? hfToken;

  /// `true` when [hfToken] was loaded from the `HF_TOKEN` environment variable.
  final bool hfTokenProvided;
}

String _sha256Prefix(String? value) {
  if (value == null || value.isEmpty) return '<empty>';
  final hash = sha256.convert(utf8.encode(value)).toString();
  return hash.length >= 8 ? hash.substring(0, 8) : hash;
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
      AuthInterceptor(
        hfToken: env.hfToken,
        internalToken: env.internalHealthToken,
        voiceGatewayApiKey: env.voiceGatewayApiKey,
        voiceGatewayBaseUrl: env.voiceGatewayBaseUrl,
      ),
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
      hfToken: env.hfToken,
      internalHealthToken: env.internalHealthToken,
    );
  }
  return MockChatRepository();
}

/// Session repository. Switches between mock and real based on [EnvConfig.useRealChat].
@Riverpod(keepAlive: true)
SessionRepository sessionRepository(SessionRepositoryRef ref) {
  final env = ref.watch(envProvider);
  if (env.useRealChat) {
    return RealSessionRepository.withDio(
      ref.watch(dioProvider),
      userId: ref.watch(userIdProvider),
    );
  }
  return MockSessionRepository();
}

/// Memory repository. Switches between mock and real based on [EnvConfig.useRealChat].
@Riverpod(keepAlive: true)
MemoryRepository memoryRepository(MemoryRepositoryRef ref) {
  final env = ref.watch(envProvider);
  if (env.useRealChat) {
    return MemoryRepositoryImpl.withDio(
      ref.watch(dioProvider),
      userId: ref.watch(userIdProvider),
    );
  }
  return MockMemoryRepository();
}

/// Voice repository. Requires [EnvConfig.voiceGatewayBaseUrl] to be set.
@Riverpod(keepAlive: true)
VoiceRepository voiceRepository(VoiceRepositoryRef ref) {
  final env = ref.watch(envProvider);
  final baseUrl = env.voiceGatewayBaseUrl ?? '';
  return VoiceRepositoryImpl(
    dio: ref.watch(dioProvider),
    baseUrl: baseUrl,
  );
}

/// Audio recorder service.
@Riverpod(keepAlive: true)
AudioRecorderService audioRecorderService(AudioRecorderServiceRef ref) {
  return RecordAudioRecorderService();
}

/// Audio player service.
@Riverpod(keepAlive: true)
AudioPlayerService audioPlayerService(AudioPlayerServiceRef ref) {
  return JustAudioPlayerService();
}
