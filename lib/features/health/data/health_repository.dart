import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/api/api_client.dart';
import '../../../core/api/api_exceptions.dart';

enum HealthStatus { healthy, unhealthy, checking }

class HealthRepository {
  final ApiClient _apiClient;
  final Duration checkInterval;

  HealthRepository(
    this._apiClient, {
    this.checkInterval = const Duration(seconds: 30),
  });

  Future<bool> checkHealth() async {
    try {
      final response = await _apiClient.get<Map<String, dynamic>>('/health');
      return response.statusCode == 200;
    } on KaiApiException {
      return false;
    } catch (_) {
      return false;
    }
  }
}

final healthRepositoryProvider = Provider<HealthRepository>((ref) {
  return HealthRepository(ref.watch(apiClientProvider));
});

final healthStatusProvider = StateNotifierProvider<HealthNotifier, HealthStatus>((ref) {
  return HealthNotifier(ref.watch(healthRepositoryProvider));
});

class HealthNotifier extends StateNotifier<HealthStatus> {
  final HealthRepository _repo;
  Timer? _timer;

  HealthNotifier(this._repo) : super(HealthStatus.checking) {
    _startPolling();
  }

  void _startPolling() {
    _check();
    _timer = Timer.periodic(_repo.checkInterval, (_) => _check());
  }

  Future<void> _check() async {
    state = HealthStatus.checking;
    final healthy = await _repo.checkHealth();
    if (mounted) {
      state = healthy ? HealthStatus.healthy : HealthStatus.unhealthy;
    }
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }
}
