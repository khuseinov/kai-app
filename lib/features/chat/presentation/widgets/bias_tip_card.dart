import 'package:flutter/material.dart';

import '../../../../core/design/theme/theme_extensions.dart';
import '../../../../core/design/tokens/kai_spacing.dart';

/// APP-A3: Bias detector suggestion card.
///
/// Shown below the Kai response when bias_suggestions[] is non-empty.
/// Collapses to an expansion tile when there are more than 2 tips.
class BiasTipCard extends StatelessWidget {
  final List<String> suggestions;

  const BiasTipCard({super.key, required this.suggestions});

  @override
  Widget build(BuildContext context) {
    if (suggestions.isEmpty) return const SizedBox.shrink();

    final colors = context.kaiColors;
    final typography = context.kaiTypography;

    final header = Row(
      children: [
        Icon(Icons.lightbulb_outline, size: 14, color: colors.warning),
        const SizedBox(width: KaiSpacing.xxs),
        Text(
          'Kai замечает:',
          style: typography.labelMedium.copyWith(
            color: colors.warning,
            fontWeight: FontWeight.w600,
          ),
        ),
      ],
    );

    Widget bulletList(List<String> items) => Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: items.map((tip) {
            return Padding(
              padding: const EdgeInsets.only(top: KaiSpacing.xxs),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('· ',
                      style: typography.bodySmall
                          .copyWith(color: colors.textSecondary)),
                  Expanded(
                    child: Text(
                      tip,
                      style: typography.bodySmall
                          .copyWith(color: colors.textSecondary),
                    ),
                  ),
                ],
              ),
            );
          }).toList(),
        );

    final decoration = BoxDecoration(
      color: colors.warning.withValues(alpha: 0.06),
      borderRadius: BorderRadius.circular(8),
      border: Border.all(color: colors.warning.withValues(alpha: 0.30)),
    );

    if (suggestions.length <= 2) {
      return Container(
        padding: const EdgeInsets.symmetric(
          horizontal: KaiSpacing.s,
          vertical: KaiSpacing.xs,
        ),
        decoration: decoration,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [header, bulletList(suggestions)],
        ),
      );
    }

    return ClipRRect(
      borderRadius: BorderRadius.circular(8),
      child: Container(
        decoration: decoration,
        child: ExpansionTile(
          tilePadding: const EdgeInsets.symmetric(
            horizontal: KaiSpacing.s,
            vertical: 0,
          ),
          childrenPadding: const EdgeInsets.only(
            left: KaiSpacing.s,
            right: KaiSpacing.s,
            bottom: KaiSpacing.xs,
          ),
          title: header,
          initiallyExpanded: false,
          iconColor: colors.warning,
          collapsedIconColor: colors.textTertiary,
          children: [bulletList(suggestions)],
        ),
      ),
    );
  }
}
