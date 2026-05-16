import 'package:flutter/material.dart';

import '../../../../core/design/theme/theme_extensions.dart';
import '../../../../core/design/tokens/kai_colors.dart';
import '../../../../core/design/tokens/kai_spacing.dart';
import '../../../../core/models/chat_message.dart';

/// API-INJ-SIGNALS-1 / APP-A4: Safety block transparency banner.
///
/// Shown when the most recent Kai message carries a blockReason or
/// injectionFragment. Branches on blockReason to display the correct
/// title and color for each safety block type.
class SafetyBlockBanner extends StatelessWidget {
  final ChatMessage? latestMessage;

  const SafetyBlockBanner({super.key, required this.latestMessage});

  @override
  Widget build(BuildContext context) {
    final msg = latestMessage;
    if (msg == null || msg.isUser) return const SizedBox.shrink();

    final blockReason = msg.blockReason?.trim();
    final fragment = msg.injectionFragment?.trim();

    if ((blockReason == null || blockReason.isEmpty) &&
        (fragment == null || fragment.isEmpty)) {
      return const SizedBox.shrink();
    }

    final colors = context.kaiColors;
    final typography = context.kaiTypography;

    final config = _bannerConfig(blockReason, colors);

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
        color: config.color.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: config.color.withValues(alpha: 0.45)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(config.icon, color: config.color, size: 18),
          const SizedBox(width: KaiSpacing.xs),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  config.title,
                  style: typography.labelMedium.copyWith(
                    color: config.color,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                if (config.showFragment &&
                    fragment != null &&
                    fragment.isNotEmpty) ...[
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
                  if (msg.injectionSource?.isNotEmpty == true) ...[
                    const SizedBox(height: 2),
                    Text(
                      'Источник: ${msg.injectionSource}',
                      style: typography.labelSmall
                          .copyWith(color: colors.textTertiary),
                    ),
                  ],
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }

  _BannerConfig _bannerConfig(String? blockReason, KaiColors colors) {
    return switch (blockReason) {
      'social_engineering' => _BannerConfig(
          title: 'Попытка социальной инженерии',
          icon: Icons.psychology_alt_outlined,
          color: colors.warning,
          showFragment: false,
        ),
      'goal_alignment' => _BannerConfig(
          title: 'Запрос вне области Kai',
          icon: Icons.gps_off_outlined,
          color: colors.stateThinking,
          showFragment: false,
        ),
      'pii' => _BannerConfig(
          title: 'Запрос содержит личные данные',
          icon: Icons.person_off_outlined,
          color: colors.oceanPrimary,
          showFragment: false,
        ),
      _ => _BannerConfig(
          title: 'Обнаружен подозрительный фрагмент',
          icon: Icons.shield_outlined,
          color: colors.warning,
          showFragment: true,
        ),
    };
  }
}

class _BannerConfig {
  final String title;
  final IconData icon;
  final Color color;
  final bool showFragment;

  const _BannerConfig({
    required this.title,
    required this.icon,
    required this.color,
    required this.showFragment,
  });
}
