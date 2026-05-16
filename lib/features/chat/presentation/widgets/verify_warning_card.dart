import 'package:flutter/material.dart';

import '../../../../core/design/theme/theme_extensions.dart';
import '../../../../core/design/tokens/kai_spacing.dart';

/// APP-VERIFY-1: VerifyStep warning card (CC-6).
///
/// Shown below the Kai response when source_warnings[] contains [VERIFY] entries.
/// Collapsed by default; expands to show each failed travel check.
class VerifyWarningCard extends StatelessWidget {
  final List<String> sourceWarnings;

  const VerifyWarningCard({super.key, required this.sourceWarnings});

  @override
  Widget build(BuildContext context) {
    final verifyItems =
        sourceWarnings.where((w) => w.startsWith('[VERIFY]')).toList();
    if (verifyItems.isEmpty) return const SizedBox.shrink();

    final colors = context.kaiColors;
    final typography = context.kaiTypography;

    final displayItems = verifyItems
        .map((w) => w.replaceFirst(RegExp(r'^\[VERIFY\]\s*'), ''))
        .toList();

    final decoration = BoxDecoration(
      color: colors.warning.withValues(alpha: 0.06),
      borderRadius: BorderRadius.circular(8),
      border: Border.all(color: colors.warning.withValues(alpha: 0.30)),
    );

    final header = Row(
      children: [
        Icon(Icons.verified_outlined, size: 14, color: colors.warning),
        const SizedBox(width: KaiSpacing.xxs),
        Text(
          'Kai проверка: ${displayItems.length} замечани${displayItems.length == 1 ? 'е' : 'я'}',
          style: typography.labelMedium.copyWith(
            color: colors.warning,
            fontWeight: FontWeight.w600,
          ),
        ),
      ],
    );

    Widget itemList() => Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: displayItems.map((item) {
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
                      item,
                      style: typography.bodySmall
                          .copyWith(color: colors.textSecondary),
                    ),
                  ),
                ],
              ),
            );
          }).toList(),
        );

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
          children: [itemList()],
        ),
      ),
    );
  }
}
