import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../network/dio_client.dart';
import '../network/interceptors/auth_interceptor.dart';
import '../network/interceptors/connectivity_interceptor.dart';
import '../network/interceptors/error_interceptor.dart';
import '../network/interceptors/logging_interceptor.dart';
import '../network/interceptors/retry_interceptor.dart';
import '../repositories/chat_repository.dart';
import '../repositories/mock_chat_repository.dart';
import '../repositories/mock_session_repository.dart';
import '../repositories/real_chat_repository.dart';
import '../repositories/real_session_repository.dart';
import '../repositories/session_repository.dart';
import '../repositories/memory_repository.dart';
import '../repositories/mock_memory_repository.dart';
import '../repositories/real_memory_repository.dart';
import '../storage/entities/memory_fact.dart';
import '../storage/entities/settings.dart';
import '../storage/hive_setup.dart';
import '../telemetry/telemetry_service.dart';

/// Env-loaded configuration. Populated by [bootstrap] via flutter_dotenv.
class EnvConfig {
  const EnvConfig({required this.apiBaseUrl, this.useRealChat = false});

  final String apiBaseUrl;

  /// When `true`, [chatRepositoryProvider] and [sessionRepositoryProvider]
  /// use the real Hive/Dio-backed implementations instead of mocks.
  final bool useRealChat;

  /// Read from `dotenv.env`, falling back to the default API URL.
  factory EnvConfig.fromDotenv() {
    final url = dotenv.maybeGet('API_BASE_URL') ?? 'https://api.wize.travel';
    final useReal = dotenv.maybeGet('USE_REAL_CHAT') == 'true';
    return EnvConfig(apiBaseUrl: url, useRealChat: useReal);
  }
}

/// Env configuration. Overridden in [bootstrap] / tests as needed.
final envProvider = Provider<EnvConfig>(
  (ref) => EnvConfig.fromDotenv(),
);

/// Single Dio client wired with the full interceptor chain.
///
/// Order matters: connectivity first (fail fast offline), auth, logging,
/// retry (re-fires the request, so must sit before error normalisation),
/// error last (normalises whatever bubbles up).
///
/// [RetryInterceptor] is attached to the constructed Dio so retries re-enter
/// the full chain instead of escaping via a bare Dio.
final dioProvider = Provider<Dio>((ref) {
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
});

/// Active theme mode. Toggled from the theme showcase screen.
final themeModeProvider = StateProvider<ThemeMode>((ref) => ThemeMode.system);

/// Chat repository. Switches between mock and real based on [EnvConfig.useRealChat].
final chatRepositoryProvider = Provider<ChatRepository>((ref) {
  final env = ref.watch(envProvider);
  if (env.useRealChat) {
    return RealChatRepository.withDio(ref.watch(dioProvider));
  }
  return MockChatRepository();
});

/// Session repository. Switches between mock and real based on [EnvConfig.useRealChat].
final sessionRepositoryProvider = Provider<SessionRepository>((ref) {
  final env = ref.watch(envProvider);
  if (env.useRealChat) return RealSessionRepository();
  return MockSessionRepository();
});

/// Telemetry service — swap NoOp for a real provider before launch.
final telemetryProvider = Provider<TelemetryService>((ref) {
  return const NoOpTelemetryService();
});

/// Memory repository. Switches between mock and real based on [EnvConfig.useRealChat].
final memoryRepositoryProvider = Provider<MemoryRepository>((ref) {
  final env = ref.watch(envProvider);
  if (env.useRealChat) return RealMemoryRepository();
  return MockMemoryRepository();
});

/// Notifier provider for memory facts list.
final memoryFactsNotifierProvider =
    NotifierProvider<MemoryFactsNotifier, List<MemoryFact>>(
        MemoryFactsNotifier.new);

class MemoryFactsNotifier extends Notifier<List<MemoryFact>> {
  @override
  List<MemoryFact> build() {
    _load();
    return const [];
  }

  Future<void> _load() async {
    final repo = ref.read(memoryRepositoryProvider);
    state = await repo.getMemoryFacts();
  }

  Future<void> addFact(MemoryFact fact) async {
    final repo = ref.read(memoryRepositoryProvider);
    await repo.saveMemoryFact(fact);
    await _load();
  }

  Future<void> deleteFact(String id) async {
    final repo = ref.read(memoryRepositoryProvider);
    await repo.deleteMemoryFact(id);
    await _load();
  }

  Future<void> clearAll() async {
    final repo = ref.read(memoryRepositoryProvider);
    await repo.clearAllMemory();
    await _load();
  }
}

/// Notifier provider for global memory enabled state.
final memoryEnabledNotifierProvider =
    NotifierProvider<MemoryEnabledNotifier, bool>(MemoryEnabledNotifier.new);

class MemoryEnabledNotifier extends Notifier<bool> {
  @override
  bool build() {
    _load();
    return true;
  }

  Future<void> _load() async {
    final repo = ref.read(memoryRepositoryProvider);
    state = await repo.isMemoryEnabled();
  }

  Future<void> toggle(bool enabled) async {
    final repo = ref.read(memoryRepositoryProvider);
    await repo.setMemoryEnabled(enabled);
    state = enabled;
  }
}
