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
import 'package:kai_app/features/auth/data/datasources/auth_remote_source.dart';
import 'package:kai_app/features/auth/data/repositories/auth_repository_impl.dart';
import 'package:kai_app/features/auth/data/repositories/mock_session_repository.dart';
import 'package:kai_app/features/auth/data/repositories/secure_token_storage.dart';
import 'package:kai_app/features/auth/data/repositories/session_repository_impl.dart';
import 'package:kai_app/features/auth/domain/repositories/auth_repository.dart';
import 'package:kai_app/features/auth/domain/repositories/session_repository.dart';
import 'package:kai_app/features/auth/presentation/providers/auth_notifier.dart';
import 'package:kai_app/features/memory/data/repositories/memory_repository_impl.dart';
import 'package:kai_app/features/memory/data/repositories/mock_memory_repository.dart';
import 'package:kai_app/features/memory/domain/repositories/memory_repository.dart';
import 'package:kai_app/features/room/data/repositories/chat_repository_impl.dart';
import 'package:kai_app/features/room/data/repositories/mock_chat_repository.dart';
import 'package:kai_app/features/room/domain/repositories/chat_repository.dart';
import 'package:kai_app/features/settings/data/models/settings.dart';
import 'package:kai_app/features/voice/data/services/livekit_voice_session.dart';
import 'package:kai_app/features/voice/data/services/opus_encoder_service.dart';
import 'package:kai_app/features/voice/data/services/soloud_player_service.dart';
import 'package:kai_app/features/voice/data/services/streaming_recorder_service.dart';
import 'package:kai_app/features/voice/data/services/voice_vad_service.dart' show VoiceVadServiceImpl;
import 'package:kai_app/features/voice/data/services/ws_voice_client.dart';
import 'package:kai_app/features/voice/domain/services/audio_player_service.dart';
import 'package:kai_app/features/voice/domain/services/voice_vad_service.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:uuid/uuid.dart';

part 'root.g.dart';

/// Env-loaded configuration. Populated by `bootstrap` via flutter_dotenv.
class EnvConfig {
  const EnvConfig({
    required this.apiBaseUrl,
    this.authBaseUrl,
    this.voiceGatewayBaseUrl,
    this.voiceGatewayApiKey,
    this.voiceTransport = 'ws',
    this.useRealChat = true,
    this.hfToken,
    this.hfTokenProvided = false,
    this.googleServerClientId,
    this.googleIosClientId,
  });

  factory EnvConfig.fromDotenv() {
    final isTest = !kIsWeb && io.Platform.environment.containsKey('FLUTTER_TEST');
    final defaultUseReal = !isTest;
    try {
      final url = dotenv.maybeGet('API_BASE_URL') ?? 'https://rustamkhuseinov-kai.hf.space';
      final authBaseUrl = _nonEmpty(dotenv.maybeGet('AUTH_BASE_URL'));
      final voiceGatewayUrl = dotenv.maybeGet('VOICE_GATEWAY_BASE_URL');
      final voiceGatewayKey = dotenv.maybeGet('VOICE_GATEWAY_API_KEY')?.trim();
      final voiceTransport = dotenv.maybeGet('VOICE_TRANSPORT')?.trim() ?? 'ws';
      final useReal = dotenv.maybeGet('USE_REAL_CHAT') != null
          ? dotenv.maybeGet('USE_REAL_CHAT') == 'true'
          : defaultUseReal;
      final rawHfToken = dotenv.maybeGet('HF_TOKEN')?.trim();
      final hfToken = (rawHfToken != null && rawHfToken.isNotEmpty) ? rawHfToken : null;
      final hfTokenProvided = hfToken != null;
      final googleServerClientId = _nonEmpty(dotenv.maybeGet('GOOGLE_SERVER_CLIENT_ID'));
      final googleIosClientId = _nonEmpty(dotenv.maybeGet('GOOGLE_IOS_CLIENT_ID'));

      if (EnvConfig.diagnosticsEnabled) {
        debugPrint(
          '[KAI_DIAGNOSTICS] EnvConfig loaded: '
          'apiBaseUrl=$url, '
          'voiceGatewayBaseUrl=$voiceGatewayUrl, '
          'voiceGatewayApiKeyEmpty=${voiceGatewayKey == null || voiceGatewayKey.isEmpty}, '
          'hfTokenProvided=$hfTokenProvided, '
          'hfTokenPrefix=${_sha256Prefix(hfToken)}, '
          'googleServerClientIdProvided=${googleServerClientId != null}',
        );
      }

      return EnvConfig(
        apiBaseUrl: url,
        authBaseUrl: authBaseUrl,
        voiceGatewayBaseUrl: voiceGatewayUrl,
        voiceGatewayApiKey: voiceGatewayKey,
        voiceTransport: voiceTransport,
        useRealChat: useReal,
        hfToken: hfToken,
        hfTokenProvided: hfTokenProvided,
        googleServerClientId: googleServerClientId,
        googleIosClientId: googleIosClientId,
      );
    } catch (_) {
      return EnvConfig(
        apiBaseUrl: 'https://rustamkhuseinov-kai.hf.space',
        useRealChat: defaultUseReal,
      );
    }
  }

  /// Whether diagnostics logging is enabled for this build.
  static bool get diagnosticsEnabled =>
      !kReleaseMode || const bool.fromEnvironment('KAI_DIAGNOSTICS');

  final String apiBaseUrl;

  /// Base URL of the kai-auth service. When set (e.g. a Render deploy at
  /// `https://kai-auth-xxx.onrender.com`), sign-in goes there directly instead
  /// of the main API host. Null → falls back to [apiBaseUrl] (kai-auth
  /// co-located on the HF Space).
  final String? authBaseUrl;

  /// Base URL of the voice-gateway microservice.
  /// When omitted, voice features are unavailable.
  final String? voiceGatewayBaseUrl;

  /// API key for voice-gateway endpoints (`X-Internal-API-Key`).
  final String? voiceGatewayApiKey;

  /// Voice transport: `ws` (baseline duplex WebSocket) or `livekit`
  /// (WebRTC via LiveKit; auto-falls back to `ws` when the token endpoint
  /// answers 503 — LIVEKIT_ENABLED off server-side).
  final String voiceTransport;

  /// When `true`, `chatRepositoryProvider` and `sessionRepositoryProvider`
  /// use the real Hive/Dio-backed implementations instead of mocks.
  final bool useRealChat;

  /// Hugging Face access token. Required when the Space is private so that
  /// the HF edge proxy forwards requests to the container.
  final String? hfToken;

  /// `true` when [hfToken] was loaded from the `HF_TOKEN` environment variable.
  final bool hfTokenProvided;

  /// Web/server OAuth client id — verifies the Google id_token audience both
  /// client-side (`GoogleSignIn.initialize`) and server-side (kai-auth's
  /// allowlist). Null until the founder provisions a Google Cloud project.
  final String? googleServerClientId;

  /// iOS-specific OAuth client id. Optional — `google_sign_in` falls back to
  /// reading it from Info.plist / GoogleService-Info.plist when omitted.
  final String? googleIosClientId;
}

String _sha256Prefix(String? value) {
  if (value == null || value.isEmpty) return '<empty>';
  final hash = sha256.convert(utf8.encode(value)).toString();
  return hash.length >= 8 ? hash.substring(0, 8) : hash;
}

String? _nonEmpty(String? value) {
  final trimmed = value?.trim();
  return (trimmed == null || trimmed.isEmpty) ? null : trimmed;
}

/// Env configuration. Overridden in `bootstrap` / tests as needed.
@Riverpod(keepAlive: true)
EnvConfig env(EnvRef ref) {
  return EnvConfig.fromDotenv();
}

/// The id kai-core knows this caller by — the one every `user_id` we send must
/// carry.
///
/// Signed in, this MUST be the kai-auth account id, because it is exactly the
/// `sub` of the JWT [AuthInterceptor] puts on the same request, and kai-core's
/// `require_user_identity` compares the two and 403s on any mismatch. Sending
/// the anonymous id below while holding a real token therefore fails *every*
/// /sessions, /user/* and /schedules call.
///
/// Signed out, it is the anonymous id: those routes reject it with 401 anyway
/// (no bearer token), but /chat still identifies the caller by it.
@Riverpod(keepAlive: true)
String userId(UserIdRef ref) {
  final account = ref.watch(authNotifierProvider).valueOrNull;
  if (account != null) return account.id;
  return ref.watch(anonymousUserIdProvider);
}

/// Stable anonymous id. Generated once and persisted in Hive. Identifies the
/// caller before sign-in (and on `/chat`, which is still body-identity), so it
/// stays readable on its own, independent of [userId] above.
@Riverpod(keepAlive: true)
String anonymousUserId(AnonymousUserIdRef ref) {
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
  final auth = AuthInterceptor(
    hfToken: env.hfToken,
    voiceGatewayApiKey: env.voiceGatewayApiKey,
    voiceGatewayBaseUrl: env.voiceGatewayBaseUrl,
    getAccessToken: () => ref.read(authRepositoryProvider).validAccessToken(),
  );
  final dio = buildDioClient(
    baseUrl: env.apiBaseUrl,
    interceptors: [
      ConnectivityInterceptor(),
      auth,
      LoggingInterceptor(),
      retry,
      ErrorInterceptor(),
    ],
  );
  retry.attach(dio);
  auth.attach(dio);
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

/// Secure keystore for the kai-auth token pair.
@Riverpod(keepAlive: true)
SecureTokenStorage secureTokenStorage(SecureTokenStorageRef ref) {
  return SecureTokenStorage();
}

/// kai-auth `/v1/auth/*` client — bare Dio, outside the app-API interceptor
/// chain (see [AuthRemoteSource] doc comment for why).
@Riverpod(keepAlive: true)
AuthRemoteSource authRemoteSource(AuthRemoteSourceRef ref) {
  final env = ref.watch(envProvider);
  final authBase = env.authBaseUrl ?? env.apiBaseUrl;
  // The HF edge PAT is only for getting past a private HF Space edge. A
  // separate public auth host (Render) neither needs it nor should receive it
  // (don't leak the HF token to a third-party host's logs).
  final hfToken = authBase == env.apiBaseUrl ? env.hfToken : null;
  return AuthRemoteSource(baseUrl: authBase, hfToken: hfToken);
}

/// Google/Apple sign-in + kai-auth token lifecycle.
@Riverpod(keepAlive: true)
AuthRepository authRepository(AuthRepositoryRef ref) {
  final env = ref.watch(envProvider);
  return AuthRepositoryImpl(
    remote: ref.watch(authRemoteSourceProvider),
    storage: ref.watch(secureTokenStorageProvider),
    googleServerClientId: env.googleServerClientId,
    googleIosClientId: env.googleIosClientId,
    onSessionLost: () =>
        ref.read(authNotifierProvider.notifier).onSessionLost(),
  );
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

/// Audio player service.
@Riverpod(keepAlive: true)
AudioPlayerService audioPlayerService(AudioPlayerServiceRef ref) {
  return SoloudPlayerService();
}

/// Streaming recorder service (PCM16 mic stream for live voice WS).
@Riverpod(keepAlive: true)
StreamingRecorderService streamingRecorderService(StreamingRecorderServiceRef ref) {
  return StreamingRecorderService();
}

/// Client-side VAD for barge-in detection during TTS playback.
@Riverpod(keepAlive: true)
VoiceVadService voiceVadService(VoiceVadServiceRef ref) {
  return VoiceVadServiceImpl();
}

/// Constructs the Opus encoder for a live-voice session (loads native
/// libopus via FFI). Seam so tests can inject a pure-Dart fake.
typedef OpusEncoderFactory = Future<OpusEncoderService> Function();

/// Factory seam for [OpusEncoderService].
@Riverpod(keepAlive: true)
OpusEncoderFactory opusEncoderFactory(OpusEncoderFactoryRef ref) {
  return createOpusEncoderService;
}

/// Constructs a [WsVoiceClient] per live-voice connection attempt.
typedef WsVoiceClientFactory = WsVoiceClient Function({
  required String wsUrl,
  required String apiKey,
  String? hfToken,
});

/// Factory seam for [WsVoiceClient] so VoiceNotifier's WS event handling and
/// reconnect logic are testable with an injected fake client.
@Riverpod(keepAlive: true)
WsVoiceClientFactory wsVoiceClientFactory(WsVoiceClientFactoryRef ref) {
  return ({required String wsUrl, required String apiKey, String? hfToken}) =>
      WsVoiceClient(wsUrl: wsUrl, apiKey: apiKey, hfToken: hfToken);
}

typedef LivekitSessionFactory = Future<LivekitVoiceSession> Function({
  required String userId,
  required String sessionId,
});

/// Factory seam for [LivekitVoiceSession] — tests inject a fake so the
/// native WebRTC stack is never touched. Throws [LivekitUnavailableException]
/// when the gateway's token endpoint is disabled; VoiceNotifier then falls
/// back to the WS transport.
@Riverpod(keepAlive: true)
LivekitSessionFactory livekitSessionFactory(LivekitSessionFactoryRef ref) {
  return ({required String userId, required String sessionId}) {
    final env = ref.read(envProvider);
    return LivekitVoiceSessionImpl.connect(
      // Plain Dio: the voice gateway lives on its own base URL, outside the
      // app-API client's interceptor chain.
      dio: Dio(),
      gatewayBaseUrl: env.voiceGatewayBaseUrl ?? '',
      apiKey: env.voiceGatewayApiKey ?? '',
      userId: userId,
      sessionId: sessionId,
      hfToken: env.hfToken,
    );
  };
}
