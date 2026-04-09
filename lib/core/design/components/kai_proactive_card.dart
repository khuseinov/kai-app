import 'package:flutter/material.dart';
import '../theme/theme_extensions.dart';
import 'kai_card.dart';
import 'kai_button.dart';

enum AlertSeverity { info, warning, critical }

class KaiProactiveCard extends StatelessWidget {
  final String title;
  final String description;
  final AlertSeverity severity;
  final IconData icon;
  final String? primaryActionLabel;
  final VoidCallback? onPrimaryAction;
  final VoidCallback? onDismiss;

  const KaiProactiveCard({
    super.key,
    required this.title,
    required this.description,
    this.severity = AlertSeverity.info,
    required this.icon,
    this.primaryActionLabel,
    this.onPrimaryAction,
    this.onDismiss,
  });

  @override
  Widget build(BuildContext context) {
    final colors = context.kaiColors;
    final typography = context.kaiTypography;

    Color iconColor;
    switch (severity) {
      case AlertSeverity.info:
        iconColor = colors.primary;
        break;
      case AlertSeverity.warning:
        iconColor = colors.warning;
        break;
      case AlertSeverity.critical:
        iconColor = colors.error;
        break;
    }

    return KaiCard(
      highlighted: severity == AlertSeverity.critical,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: iconColor.withOpacity(0.1),
                  shape: BoxShape.circle,
                ),
                child: Icon(icon, color: iconColor, size: 24),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  title,
                  style: typography.titleMedium,
                ),
              ),
              if (onDismiss != null)
                IconButton(
                  icon: Icon(Icons.close, color: colors.textSecondary, size: 20),
                  onPressed: onDismiss,
                  splashRadius: 20,
                ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            description,
            style: typography.bodyMedium,
          ),
          if (primaryActionLabel != null) ...[
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                KaiButton(
                  label: primaryActionLabel!,
                  onPressed: onPrimaryAction ?? () {},
                  type: KaiButtonType.primary,
                ),
              ],
            )
          ],
        ],
      ),
    );
  }
}
