import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/design/theme/theme_extensions.dart';
import '../data/health_repository.dart';
import 'health_dashboard_screen.dart';

class HealthIndicator extends ConsumerWidget {
  const HealthIndicator({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final status = ref.watch(healthStatusProvider);
    final colors = context.kaiColors;

    final (dotColor, label) = switch (status) {
      HealthStatus.healthy   => (colors.success, 'All systems operational'),
      HealthStatus.unhealthy => (colors.error,   'Server unreachable'),
      HealthStatus.checking  => (colors.warning,  'Checking...'),
    };

    return Tooltip(
      message: label,
      child: GestureDetector(
        onTap: () => Navigator.push(
          context,
          MaterialPageRoute<void>(
            builder: (_) => const HealthDashboardScreen(),
          ),
        ),
        child: Container(
          width: 10,
          height: 10,
          decoration: BoxDecoration(
            color: dotColor,
            shape: BoxShape.circle,
            boxShadow: status == HealthStatus.healthy
                ? [BoxShadow(color: dotColor.withAlpha(100), blurRadius: 6, spreadRadius: 1)]
                : null,
          ),
        ),
      ),
    );
  }
}
