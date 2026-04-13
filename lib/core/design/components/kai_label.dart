import 'package:flutter/material.dart';
import '../theme/theme_extensions.dart';

enum KaiLabelVariant {
  primary,
  secondary,
  success,
  warning,
  error,
}

class KaiLabel extends StatelessWidget {
  final String text;
  final KaiLabelVariant variant;
  final Widget? icon;

  const KaiLabel(
    this.text, {
    super.key,
    this.variant = KaiLabelVariant.secondary,
    this.icon,
  });

  @override
  Widget build(BuildContext context) {
    final colors = context.kaiColors;
    final typography = context.kaiTypography;

    Color backgroundColor;
    Color textColor;
    var borderColor = Colors.transparent;

    switch (variant) {
      case KaiLabelVariant.primary:
        backgroundColor = colors.oceanPrimary.withValues(alpha: 0.1);
        textColor = colors.oceanPrimary;
        borderColor = colors.oceanPrimary.withValues(alpha: 0.2);
        break;
      case KaiLabelVariant.secondary:
        backgroundColor = colors.surfaceContainer;
        textColor = colors.textSecondary;
        borderColor = colors.cloudLight;
        break;
      case KaiLabelVariant.success:
        backgroundColor = colors.success.withValues(alpha: 0.1);
        textColor = colors.success;
        borderColor = colors.success.withValues(alpha: 0.2);
        break;
      case KaiLabelVariant.warning:
        backgroundColor = colors.warning.withValues(alpha: 0.1);
        textColor = colors.warning;
        borderColor = colors.warning.withValues(alpha: 0.2);
        break;
      case KaiLabelVariant.error:
        backgroundColor = colors.error.withValues(alpha: 0.1);
        textColor = colors.error;
        borderColor = colors.error.withValues(alpha: 0.2);
        break;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: borderColor),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (icon != null) ...[
            IconTheme(
              data: IconThemeData(color: textColor, size: 14),
              child: icon!,
            ),
            const SizedBox(width: 6),
          ],
          Text(
            text,
            style: typography.labelSmall.copyWith(
              color: textColor,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}
