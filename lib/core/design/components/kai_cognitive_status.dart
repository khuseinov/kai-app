import 'package:flutter/material.dart';
import '../theme/theme_extensions.dart';
import '../tokens/kai_radii.dart';

class KaiCognitiveStatus extends StatelessWidget {
  final String currentStep;
  final double progress; // 0.0 to 1.0

  const KaiCognitiveStatus({
    super.key,
    required this.currentStep,
    required this.progress,
  });

  @override
  Widget build(BuildContext context) {
    final colors = context.kaiColors;
    final typography = context.kaiTypography;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: colors.surface,
        borderRadius: KaiRadii.button,
        border: Border.all(color: colors.glassBorder),
      ),
      child: Row(
        children: [
          SizedBox(
            width: 16,
            height: 16,
            child: CircularProgressIndicator(
              value: progress,
              strokeWidth: 2,
              backgroundColor: colors.textSecondary.withOpacity(0.2),
              valueColor: AlwaysStoppedAnimation<Color>(colors.stateThinking),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              currentStep,
              style: typography.labelMedium.copyWith(color: colors.textSecondary),
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    );
  }
}
