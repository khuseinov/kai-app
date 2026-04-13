import 'package:flutter/material.dart';
import '../theme/theme_extensions.dart';

enum KaiButtonVariant {
  primary,
  secondary,
  outline,
  ghost,
}

enum KaiButtonSize {
  small,
  medium,
  large,
}

class KaiButton extends StatelessWidget {
  final String text;
  final VoidCallback? onPressed;
  final KaiButtonVariant variant;
  final KaiButtonSize size;
  final Widget? icon;
  final bool isLoading;

  const KaiButton({
    super.key,
    required this.text,
    this.onPressed,
    this.variant = KaiButtonVariant.primary,
    this.size = KaiButtonSize.medium,
    this.icon,
    this.isLoading = false,
  });

  const KaiButton.primary({
    super.key,
    required this.text,
    this.onPressed,
    this.size = KaiButtonSize.medium,
    this.icon,
    this.isLoading = false,
  }) : variant = KaiButtonVariant.primary;

  const KaiButton.secondary({
    super.key,
    required this.text,
    this.onPressed,
    this.size = KaiButtonSize.medium,
    this.icon,
    this.isLoading = false,
  }) : variant = KaiButtonVariant.secondary;

  const KaiButton.outline({
    super.key,
    required this.text,
    this.onPressed,
    this.size = KaiButtonSize.medium,
    this.icon,
    this.isLoading = false,
  }) : variant = KaiButtonVariant.outline;

  const KaiButton.ghost({
    super.key,
    required this.text,
    this.onPressed,
    this.size = KaiButtonSize.medium,
    this.icon,
    this.isLoading = false,
  }) : variant = KaiButtonVariant.ghost;

  @override
  Widget build(BuildContext context) {
    final colors = context.kaiColors;
    final typography = context.kaiTypography;

    // Determine padding and font size based on size
    EdgeInsetsGeometry padding;
    TextStyle textStyle;
    double iconSize;

    switch (size) {
      case KaiButtonSize.small:
        padding = const EdgeInsets.symmetric(horizontal: 12, vertical: 8);
        textStyle = typography.labelSmall;
        iconSize = 14;
        break;
      case KaiButtonSize.medium:
        padding = const EdgeInsets.symmetric(horizontal: 16, vertical: 12);
        textStyle = typography.labelMedium;
        iconSize = 18;
        break;
      case KaiButtonSize.large:
        padding = const EdgeInsets.symmetric(horizontal: 24, vertical: 16);
        textStyle = typography.labelLarge;
        iconSize = 20;
        break;
    }

    // Common child content
    final child = isLoading
        ? SizedBox(
            width: iconSize,
            height: iconSize,
            child: CircularProgressIndicator(
              strokeWidth: 2,
              color: variant == KaiButtonVariant.primary
                  ? colors.onPrimary
                  : colors.primary,
            ),
          )
        : Row(
            mainAxisSize: MainAxisSize.min,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              if (icon != null) ...[
                IconTheme(
                  data: IconThemeData(size: iconSize),
                  child: icon!,
                ),
                const SizedBox(width: 8),
              ],
              Text(
                text,
                style: textStyle.copyWith(fontWeight: FontWeight.w600),
              ),
            ],
          );

    // Build specific button variant
    switch (variant) {
      case KaiButtonVariant.primary:
        return ElevatedButton(
          onPressed: onPressed,
          style: ElevatedButton.styleFrom(
            backgroundColor: colors.primary,
            foregroundColor: colors.onPrimary,
            elevation: 0,
            shadowColor: Colors.transparent,
            padding: padding,
            shape:
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(6)),
          ),
          child: child,
        );
      case KaiButtonVariant.secondary:
        return ElevatedButton(
          onPressed: onPressed,
          style: ElevatedButton.styleFrom(
            backgroundColor: colors.surfaceContainer,
            foregroundColor: colors.textPrimary,
            elevation: 0,
            shadowColor: Colors.transparent,
            padding: padding,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(6),
              side: BorderSide(color: colors.cloudLight),
            ),
          ),
          child: child,
        );
      case KaiButtonVariant.outline:
        return OutlinedButton(
          onPressed: onPressed,
          style: OutlinedButton.styleFrom(
            foregroundColor: colors.textPrimary,
            padding: padding,
            side: BorderSide(color: colors.cloudLight),
            shape:
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(6)),
          ),
          child: child,
        );
      case KaiButtonVariant.ghost:
        return TextButton(
          onPressed: onPressed,
          style: TextButton.styleFrom(
            foregroundColor: colors.textSecondary,
            padding: padding,
            shape:
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(6)),
          ),
          child: child,
        );
    }
  }
}
