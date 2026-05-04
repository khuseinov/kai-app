import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../api/api_client.dart';
import '../design/components/kai_connectivity_pill.dart';
import '../network/health_poller.dart';
import 'connectivity_status_provider.dart';

/// Single shared HealthPoller. Started on first watch, disposed when no
/// listeners remain (autoDispose semantics handled by Riverpod).
final healthPollerProvider = Provider<HealthPoller>((ref) {
  final dio = ref.watch(dioProvider);
  final poller = HealthPoller(dio)..start();
  ref.onDispose(poller.dispose);
  return poller;
});

/// Stream of backend health states (one per /health probe).
final backendHealthProvider = StreamProvider<HealthState>((ref) {
  return ref.watch(healthPollerProvider).stream;
});

/// Combined device + backend connectivity for the AppBar pill.
///
/// Priority order:
/// 1. Device offline → offline (red).
/// 2. Backend unreachable → offline (red).
/// 3. Backend degraded → degraded (yellow).
/// 4. Backend healthy → online (green).
/// 5. Unknown (no probe yet) → online (avoid scary default).
final connectivityPillStateProvider = Provider<ConnectivityPillState>((ref) {
  final isOnline = ref.watch(isOnlineProvider).asData?.value ?? true;
  if (!isOnline) return ConnectivityPillState.offline;
  final health = ref.watch(backendHealthProvider).asData?.value;
  return switch (health) {
    HealthState.healthy => ConnectivityPillState.online,
    HealthState.degraded => ConnectivityPillState.degraded,
    HealthState.unreachable => ConnectivityPillState.offline,
    null => ConnectivityPillState.online,
  };
});
