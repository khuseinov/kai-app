import 'package:flutter/material.dart';

import '../../../../core/design/theme/theme_extensions.dart';
import '../../../../core/design/tokens/kai_spacing.dart';
import '../../../../core/models/chat_message.dart';

/// API-INJ-SIGNALS-1: B-12 Stop-Show-Ask transparency banner.
///
/// Shown when the most recent Kai message carries [injectionFragment] +
/// [injectionSource] — i.e. CritiqueStep detected an injection-like fragment
/// and blocked the answer. The banner surfaces *why* delivery was blocked so
/// the user does not perceive Kai as misbehaving.
class SafetyBlockBanner extends StatelessWidget {
  final ChatMessage? latestMessage;

  const SafetyBlockBanner({super.key, required this.latestMessage});

  @override
  Widget build(BuildContext context) {
    final msg = latestMessage;
    if (msg == null || msg.isUser) return const SizedBox.shrink();

    final fragment = msg.injectionFragment?.trim();
    if (fragment == null || fragment.isEmpty) return const SizedBox.shrink();

    final source = msg.injectionSource?.trim();
    final colors = context.kaiColors;
    final typography = context.kaiTypography;

    return Container(
      margin: const EdgeInsets.symmetric(
        horizontal: KaiSpacing.screenPadding,
        vertical: KaiSpacing.xxs,
      ),
      padding: const EdgeInsets.symmetric(
        horizontal: KaiSpacing.m,
        vertical: KaiSpacing.xs,
      ),
      decoration: BoxDecoration(
        color: colors.warning.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: colors.warning.withValues(alpha: 0.45)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(Icons.shield_outlined, color: colors.warning, size: 18),
          const SizedBox(width: KaiSpacing.xs),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Обнаружен подозрительный фрагмент',
                  style: typography.labelMedium.copyWith(
                    color: colors.warning,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  '«$fragment»',
                  style: typography.labelSmall.copyWith(
                    color: colors.textPrimary,
                    fontStyle: FontStyle.italic,
                  ),
                  maxLines: 3,
                  overflow: TextOverflow.ellipsis,
                ),
                if (source != null && source.isNotEmpty) ...[
                  const SizedBox(height: 2),
                  Text(
                    'Источник: $source',
                    style: typography.labelSmall
                        .copyWith(color: colors.textTertiary),
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }
}
