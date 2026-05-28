import 'package:flutter/material.dart';

import '../../theme/kai_theme.dart';
import '../../tokens/kai_tokens.dart';

/// v3 badge atom.
///
/// Two constructors:
/// - [KaiBadge.dot()] — a 6px filled circle with a 2px surface-colored ring.
///   Canon: nav memory dot from `new-design/nav.html`.
///   Sizes: 6px dot + 2px ring on each side = 10px outer diameter. These are
///   canon literals — document them here rather than aliasing to space tokens.
/// - [KaiBadge.count(int count)] — a pill showing a number: `accent` background,
///   white text in [KaiType.micro], min 16px height, horizontal padding for
///   multi-digit numbers. Counts > 99 are capped to "99+".
///
/// Colors come from the active theme via [KaiTheme.of].
class KaiBadge extends StatelessWidget {
  /// Small filled dot — 6px accent circle inside a 10px surface-colored ring.
  ///
  /// [color] overrides the fill color (defaults to `accent`).
  const KaiBadge.dot({this.color, super.key})
      : _variant = _KaiBadgeVariant.dot,
        _count = 0;

  /// Numeric pill badge — accent background, white count text.
  ///
  /// Counts above 99 display as "99+".
  const KaiBadge.count(int count, {super.key})
      : _variant = _KaiBadgeVariant.count,
        _count = count,
        color = null;

  /// Optional fill-color override (dot variant only). Defaults to `accent`.
  final Color? color;

  final _KaiBadgeVariant _variant;
  final int _count;

  @override
  Widget build(BuildContext context) {
    switch (_variant) {
      case _KaiBadgeVariant.dot:
        return _buildDot(context);
      case _KaiBadgeVariant.count:
        return _buildCount(context);
    }
  }

  Widget _buildDot(BuildContext context) {
    final tokens = KaiTheme.of(context);
    final dotColor = color ?? tokens.colors.accent;
    final ringColor = tokens.colors.surface;

    // Outer 10px surface-colored circle acts as the 2px ring around the 6px dot.
    // 6px dot + 2px ring on each side = 10px total diameter.
    return Container(
      constraints: const BoxConstraints.tightFor(width: 10, height: 10),
      decoration: BoxDecoration(
        color: ringColor,
        shape: BoxShape.circle,
      ),
      alignment: Alignment.center,
      child: Container(
        constraints: const BoxConstraints.tightFor(width: 6, height: 6),
        decoration: BoxDecoration(
          color: dotColor,
          shape: BoxShape.circle,
        ),
      ),
    );
  }

  Widget _buildCount(BuildContext context) {
    final tokens = KaiTheme.of(context);
    final label = _count > 99 ? '99+' : '$_count';

    return Container(
      constraints: const BoxConstraints(minWidth: 16, minHeight: 16),
      padding: const EdgeInsets.symmetric(horizontal: 5),
      decoration: BoxDecoration(
        color: tokens.colors.accent,
        borderRadius: BorderRadius.circular(8),
      ),
      alignment: Alignment.center,
      child: Text(
        label,
        style: KaiType.micro(color: Colors.white),
      ),
    );
  }
}

enum _KaiBadgeVariant { dot, count }
