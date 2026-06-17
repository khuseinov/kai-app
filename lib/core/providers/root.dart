import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:kai_app/core/network/dio_client.dart';
import 'package:kai_app/core/network/interceptors/auth_interceptor.dart';
import 'package:kai_app/core/network/interceptors/connectivity_interceptor.dart';
import 'package:kai_app/core/network/interceptors/error_interceptor.dart';
import 'package:kai_app/core/network/interceptors/logging_interceptor.dart';
import 'package:kai_app/core/network/interceptors/retry_interceptor.dart';
import 'package:kai_app/features/auth/data/repositories/mock_session_repository.dart';
import 'package:kai_app/features/auth/data/repositories/session_repository_impl.dart';
import 'package:kai_app/features/auth/domain/repositories/session_repository.dart';
import 'package:kai_app/features/memory/data/repositories/memory_repository_impl.dart';
import 'package:kai_app/features/memory/data/repositories/mock_memory_repository.dart';
import 'package:kai_app/features/memory/domain/repositories/memory_repository.dart';
import 'package:kai_app/features/room/data/repositories/chat_repository_impl.dart';
import 'package:kai_app/features/room/data/repositories/mock_chat_repository.dart';
import 'package:kai_app/features/room/domain/repositories/chat_repository.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'root.g.dart';

/// Env-loaded configuration. Populated by [bootstrap] via flutter_dotenv.
class EnvConfig {
  const EnvConfig({required this.apiBaseUrl, this.useRealChat = false});

  /// Read from `dotenv.env`, falling back to the default API URL.
  factory EnvConfig.fromDotenv() {
    final url = dotenv.maybeGet('API_BASE_URL') ?? 'https://api.wize.travel';
    final useReal = dotenv.maybeGet('USE_REAL_CHAT') == 'true';
    return EnvConfig(apiBaseUrl: url, useRealChat: useReal);
  }

  final String apiBaseUrl;

  /// When `true`, [chatRepositoryProvider] and [sessionRepositoryProvider]
  /// use the real Hive/Dio-backed implementations instead of mocks.
  final bool useRealChat;
}

/// Env configuration. Overridden in [bootstrap] / tests as needed.
@Riverpod(keepAlive: true)
EnvConfig env(EnvRef ref) {
  return EnvConfig.fromDotenv();
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
      AuthInterceptor(),
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
  @override
  ThemeMode build() => ThemeMode.system;

  void setThemeMode(ThemeMode mode) {
    state = mode;
  }
}

// Backward-compatible alias for app.dart and theme references
final themeModeProvider = themeModeNotifierProvider;

/// Chat repository. Switches between mock and real based on [EnvConfig.useRealChat].
@Riverpod(keepAlive: true)
ChatRepository chatRepository(ChatRepositoryRef ref) {
  final env = ref.watch(envProvider);
  if (env.useRealChat) {
    return RealChatRepository.withDio(ref.watch(dioProvider));
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
