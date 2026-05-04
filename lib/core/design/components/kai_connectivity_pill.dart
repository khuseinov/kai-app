import 'package:flutter/material.dart';

import '../theme/theme_extensions.dart';
import '../tokens/kai_spacing.dart';

/// Visual state of the connectivity pill shown in the chat AppBar.
enum ConnectivityPillState { online, degraded, offline }

/// Small dot+label pill showing combined device/backend connectivity.
///
/// - online: device has network AND `/health` returns 2xx
/// - degraded: device has network but `/health` returns 5xx
/// - offline: device has no network OR `/health` is unreachable
class KaiConnectivityPill extends StatelessWidget {
  final ConnectivityPillState state;

  const KaiConnectivityPill({super.key, required this.state});

  @override
  Widget build(BuildContext context) {
    final colors = context.kaiColors;
    final typography = context.kaiTypography;

    final (color, label, key) = switch (state) {
      ConnectivityPillState.online => (
          colors.oceanPrimary,
          'online',
          const Key('connectivity_pill_online'),
        ),
      ConnectivityPillState.degraded => (
          colors.warning,
          'degraded',
          const Key('connectivity_pill_degraded'),
        ),
      ConnectivityPillState.offline => (
          colors.error,
          'offline',
          const Key('connectivity_pill_offline'),
        ),
    };

    return Padding(
      key: key,
      padding: const EdgeInsets.symmetric(horizontal: KaiSpacing.s),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 8,
            height: 8,
            decoration: BoxDecoration(color: color, shape: BoxShape.circle),
          ),
          const SizedBox(width: 6),
          Text(label, style: typography.labelSmall.copyWith(color: color)),
        ],
      ),
    );
  }
}
