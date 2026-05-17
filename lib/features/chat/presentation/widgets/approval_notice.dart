import 'package:flutter/material.dart';
import '../../../../core/design/theme/theme_extensions.dart';

/// Generic pending-approval notice (no injection signal).
class ApprovalNotice extends StatelessWidget {
  final String? type;

  const ApprovalNotice({super.key, this.type});

  @override
  Widget build(BuildContext context) {
    final colors = context.kaiColors;
    final typography = context.kaiTypography;
    final label = type == 'simulation'
        ? 'Требуется подтверждение симуляции'
        : 'Требуется подтверждение';

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
      decoration: BoxDecoration(
        color: colors.warning.withValues(alpha: 0.10),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: colors.warning.withValues(alpha: 0.35)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.verified_user_outlined, size: 14, color: colors.warning),
          const SizedBox(width: 6),
          Flexible(
            child: Text(
              label,
              style: typography.labelMedium.copyWith(color: colors.warning),
            ),
          ),
        ],
      ),
    );
  }
}

/// APP-INJ-CONFIRM-1: shown instead of [ApprovalNotice] when a pending
/// confirmation was triggered by an injection signal. Shows the flagged
/// fragment and its source before asking to proceed.
class InjectionWarningCard extends StatelessWidget {
  final String fragment;
  final String? source;

  const InjectionWarningCard({
    super.key,
    required this.fragment,
    this.source,
  });

  @override
  Widget build(BuildContext context) {
    final colors = context.kaiColors;
    final typography = context.kaiTypography;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
      decoration: BoxDecoration(
        color: colors.error.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: colors.error.withValues(alpha: 0.35)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.warning_amber_rounded, size: 14, color: colors.error),
              const SizedBox(width: 6),
              Flexible(
                child: Text(
                  source != null
                      ? 'Подозрительный фрагмент из $source'
                      : 'Подозрительный фрагмент',
                  style: typography.labelMedium.copyWith(
                    color: colors.error,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 4),
          Text(
            '«$fragment»',
            style: typography.bodySmall.copyWith(
              color: colors.textPrimary,
              fontStyle: FontStyle.italic,
            ),
            maxLines: 3,
            overflow: TextOverflow.ellipsis,
          ),
          const SizedBox(height: 4),
          Text(
            'Продолжить?',
            style: typography.labelSmall.copyWith(color: colors.textTertiary),
          ),
        ],
      ),
    );
  }
}
