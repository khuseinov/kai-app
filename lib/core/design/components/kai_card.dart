import 'package:flutter/material.dart';

import '../theme/theme_extensions.dart';

/// Standard surface card used across KAI screens.
///
/// Defaults match the most common pattern: surface background, cloudLight
/// border, 12 px radius, 16 px padding. Pass [highlighted] for accent
/// (oceanPrimary border + 5 % wash) or override individual props for
/// special cases.
class KaiCard extends StatelessWidget {
  final Widget child;
  final EdgeInsetsGeometry padding;
  final bool highlighted;

  /// Override background tint. Defaults to surface (or highlighted wash).
  final Color? backgroundColor;

  /// Override border. Pass [Border.fromBorderSide(BorderSide.none)] to drop
  /// the outline entirely (e.g. settings sections).
  final BoxBorder? border;

  /// Corner radius. Defaults to 12.
  final double borderRadius;

  const KaiCard({
    super.key,
    required this.child,
    this.padding = const EdgeInsets.all(16),
    this.highlighted = false,
    this.backgroundColor,
    this.border,
    this.borderRadius = 12,
  });

  /// Borderless variant — surface block without outline (settings groups,
  /// drawer rows, info containers).
  const KaiCard.flat({
    super.key,
    required this.child,
    this.padding = const EdgeInsets.all(16),
    this.backgroundColor,
    this.borderRadius = 12,
  })  : highlighted = false,
        border = const Border.fromBorderSide(BorderSide.none);

  @override
  Widget build(BuildContext context) {
    final colors = context.kaiColors;

    final effectiveBg = backgroundColor ??
        (highlighted ? colors.oceanPrimary.withValues(alpha: 0.05) : colors.surface);

    final effectiveBorder = border ??
        Border.all(
          color: highlighted ? colors.oceanPrimary : colors.cloudLight,
          width: highlighted ? 1.5 : 1.0,
        );

    return Container(
      padding: padding,
      decoration: BoxDecoration(
        color: effectiveBg,
        borderRadius: BorderRadius.circular(borderRadius),
        border: effectiveBorder,
      ),
      child: child,
    );
  }
}
