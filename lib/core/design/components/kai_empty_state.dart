import 'package:flutter/material.dart';
import '../theme/theme_extensions.dart';
import '../tokens/kai_spacing.dart';

/// A generic empty state widget with an icon, title, optional subtitle,
/// and optional action widget.
class KaiEmptyState extends StatelessWidget {
  final String title;
  final String? subtitle;
  final IconData icon;
  final Widget? action;

  const KaiEmptyState({
    super.key,
    required this.title,
    this.subtitle,
    this.icon = Icons.inbox_outlined,
    this.action,
  });

  @override
  Widget build(BuildContext context) {
    final colors = context.kaiColors;
    final typography = context.kaiTypography;

    return Padding(
      padding: const EdgeInsets.all(KaiSpacing.screenPadding),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            icon,
            size: 48.0,
            color: colors.textTertiary,
          ),
          const SizedBox(height: KaiSpacing.m),
          Text(
            title,
            style: typography.titleMedium.copyWith(color: colors.textPrimary),
            textAlign: TextAlign.center,
          ),
          if (subtitle != null) ...[
            const SizedBox(height: KaiSpacing.xs),
            Text(
              subtitle!,
              style: typography.bodyMedium.copyWith(color: colors.textSecondary),
              textAlign: TextAlign.center,
            ),
          ],
          if (action != null) ...[
            const SizedBox(height: KaiSpacing.l),
            action!,
          ],
        ],
      ),
    );
  }
}
