import 'package:flutter/material.dart';

import '../../theme/kai_theme.dart';

/// Primitive themed container — the building block for cards, wells, and
/// sheet bodies in v3.
///
/// Wraps [child] in a [Container] with a token-driven [BoxDecoration].
/// Caller supplies the background [color] (e.g. `KaiTheme.of(ctx).colors.surface`).
///
/// Canon usages:
/// - Chat bench: `color: colors.surface`, `border: true`, `radius: KaiRadius.br4`
/// - Quiet well:  `color: colors.surface3`, `border: true`
/// - Sheet body:  `color: colors.surface`, `radius: KaiRadius.br5` (top corners only),
///               optional [shadow]
///
/// Design rationale for the API: the color is required (not a default) because
/// `KaiSurface` is intentionally dumb — it never reads the theme for color on
/// its own, so callers must be explicit. This avoids surprises when the same
/// widget is reused on different surface layers. Border color and the 1px width
/// are always the `line` token when enabled; overriding that would break canon.
class KaiSurface extends StatelessWidget {
  const KaiSurface({
    super.key,
    required this.child,
    required this.color,
    this.radius,
    this.border = false,
    this.shadow,
    this.padding,
  });

  /// Background fill — pass a surface token from [KaiTheme.of(context).colors].
  final Color color;

  /// Optional border radius — pass e.g. `KaiRadius.br4`.
  final BorderRadius? radius;

  /// When `true`, draws a 1px `Border.all` in the theme `line` color.
  final bool border;

  /// Optional box shadows — pass e.g. `KaiShadow.button`.
  final List<BoxShadow>? shadow;

  /// Optional inner padding applied between the decoration and the child.
  final EdgeInsetsGeometry? padding;

  final Widget child;

  @override
  Widget build(BuildContext context) {
    final lineColor = KaiTheme.of(context).colors.line;
    return Container(
      padding: padding,
      decoration: BoxDecoration(
        color: color,
        borderRadius: radius,
        border: border ? Border.all(color: lineColor) : null,
        boxShadow: shadow,
      ),
      child: child,
    );
  }
}
