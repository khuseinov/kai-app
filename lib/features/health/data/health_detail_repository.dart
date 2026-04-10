import 'dart:async';
import 'dart:convert';

import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/api/api_client.dart';

/// Detailed health model from /health/detail endpoint.
class DetailedHealth {
  final String status;
  final Map<String, ServiceHealth> services;
  final DateTime checkedAt;

  const DetailedHealth({
    required this.status,
    required this.services,
    required this.checkedAt,
  });

  factory DetailedHealth.fromJson(Map<String, dynamic> json) {
    final servicesJson = json['services'] as Map<String, dynamic>? ?? {};
    return DetailedHealth(
      status: json['status'] as String? ?? 'unknown',
      services: servicesJson.map(
        (key, value) => MapEntry(
          key,
          ServiceHealth.fromJson(key, value as Map<String, dynamic>),
        ),
      ),
      checkedAt: DateTime.now(),
    );
  }

  /// Fallback: parse simple /health response (status + top-level service keys).
  factory DetailedHealth.fromSimpleJson(Map<String, dynamic> json) {
    final services = <String, ServiceHealth>{};
    for (final entry in json.entries) {
      if (entry.key == 'status' || entry.key == 'service') continue;
      final val = entry.value;
      services[entry.key] = ServiceHealth(
        name: entry.key,
        status: val == 'ok' ? 'ok' : 'error',
        latencyMs: null,
        message: val is String ? val : jsonEncode(val),
      );
    }
    return DetailedHealth(
      status: json['status'] as String? ?? 'unknown',
      services: services,
      checkedAt: DateTime.now(),
    );
  }
}

class ServiceHealth {
  final String name;
  final String status;
  final int? latencyMs;
  final String? message;

  const ServiceHealth({
    required this.name,
    required this.status,
    this.latencyMs,
    this.message,
  });

  factory ServiceHealth.fromJson(String name, Map<String, dynamic> json) {
    return ServiceHealth(
      name: name,
      status: json['status'] as String? ?? 'unknown',
      latencyMs: json['latency_ms'] as int?,
      message: json['message'] as String?,
    );
  }

  bool get isOk => status == 'ok' || status == 'healthy';
}

class HealthDetailNotifier extends StateNotifier<AsyncValue<DetailedHealth>> {
  final ApiClient _apiClient;
  Timer? _timer;

  HealthDetailNotifier(this._apiClient) : super(const AsyncValue.loading()) {
    _check();
    _timer = Timer.periodic(const Duration(seconds: 30), (_) => _check());
  }

  Future<void> refresh() => _check();

  Future<void> _check() async {
    try {
      // Try /health/detail first, fall back to /health
      Map<String, dynamic>? data;
      try {
        final r = await _apiClient.get<Map<String, dynamic>>('/health/detail');
        data = r.data;
        if (data != null && data.containsKey('services')) {
          state = AsyncValue.data(DetailedHealth.fromJson(data));
          return;
        }
      } catch (_) {
        // /health/detail not available — use simple /health
      }

      final r = await _apiClient.get<Map<String, dynamic>>('/health');
      data = r.data ?? {};
      state = AsyncValue.data(DetailedHealth.fromSimpleJson(data));
    } catch (e, st) {
      state = AsyncValue.error(e, st);
    }
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }
}

final healthDetailProvider =
    StateNotifierProvider<HealthDetailNotifier, AsyncValue<DetailedHealth>>(
  (ref) => HealthDetailNotifier(ref.watch(apiClientProvider)),
);
