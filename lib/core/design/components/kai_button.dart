import 'package:flutter/material.dart';
import '../theme/theme_extensions.dart';
import '../tokens/kai_radii.dart';

enum KaiButtonType { primary, secondary, ghost }

class KaiButton extends StatelessWidget {
  final String label;
  final VoidCallback onPressed;
  final KaiButtonType type;
  final bool isLoading;
  final IconData? icon;

  const KaiButton({
    super.key,
    required this.label,
    required this.onPressed,
    this.type = KaiButtonType.primary,
    this.isLoading = false,
    this.icon,
  });

  @override
  Widget build(BuildContext context) {
    final colors = context.kaiColors;
    final typography = context.kaiTypography;

    Color backgroundColor;
    Color textColor;
    BorderSide? border;

    switch (type) {
      case KaiButtonType.primary:
        backgroundColor = colors.primary;
        textColor = Colors.white;
        break;
      case KaiButtonType.secondary:
        backgroundColor = colors.surface;
        textColor = colors.textPrimary;
        border = BorderSide(color: colors.glassBorder);
        break;
      case KaiButtonType.ghost:
        backgroundColor = Colors.transparent;
        textColor = colors.primary;
        break;
    }

    return Semantics(
      button: true,
      label: label,
      child: Material(
        color: backgroundColor,
        borderRadius: KaiRadii.button,
        shape: border != null ? RoundedRectangleBorder(borderRadius: KaiRadii.button, side: border) : null,
        child: InkWell(
          onTap: isLoading ? null : onPressed,
          borderRadius: KaiRadii.button,
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
            alignment: Alignment.center,
            child: isLoading
                ? SizedBox(
                    height: 20,
                    width: 20,
                    child: CircularProgressIndicator(strokeWidth: 2, color: textColor),
                  )
                : Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      if (icon != null) ...[
                        Icon(icon, color: textColor, size: 20),
                        const SizedBox(width: 8),
                      ],
                      Text(
                        label,
                        style: typography.labelLarge.copyWith(color: textColor),
                      ),
                    ],
                  ),
          ),
        ),
      ),
    );
  }
}
