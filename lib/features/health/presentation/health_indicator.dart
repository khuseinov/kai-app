import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/design/theme/theme_extensions.dart';
import '../data/health_repository.dart';

class HealthIndicator extends ConsumerWidget {
  const HealthIndicator({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final status = ref.watch(healthStatusProvider);
    final colors = context.kaiColors;

    final Color dotColor;
    switch (status) {
      case HealthStatus.healthy:
        dotColor = colors.success;
      case HealthStatus.unhealthy:
        dotColor = colors.error;
      case HealthStatus.checking:
        dotColor = colors.warning;
    }

    return Tooltip(
      message: status.name,
      child: Container(
        width: 8,
        height: 8,
        decoration: BoxDecoration(
          color: dotColor,
          shape: BoxShape.circle,
        ),
      ),
    );
  }
}
