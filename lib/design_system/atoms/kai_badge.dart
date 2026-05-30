import 'package:flutter/material.dart';

import '../theme/kai_theme.dart';
import '../tokens/kai_tokens.dart';

/// Tone variants for [KaiBadge.dot].
///
/// - [accent]   → `accent` fill (default, primary notification dot).
/// - [positive] → `positive` fill.
/// - [warning]  → `warning` fill.
/// - [negative] → `negative` fill.
enum KaiBadgeTone {
  /// Default accent color — primary notification.
  accent,

  /// Semantic positive / success dot.
  positive,

  /// Semantic warning dot.
  warning,

  /// Semantic negative / error dot.
  negative,
}

/// v3 badge atom.
///
/// Three constructors:
/// - [KaiBadge.dot()] — a 6px filled circle with a 2px surface-colored ring.
///   Canon: nav memory dot from `new-design/nav.html`.
///   Sizes: 6px dot + 2px ring on each side = 10px outer diameter. These are
///   canon literals — document them here rather than aliasing to space tokens.
/// - [KaiBadge.count(int count)] — a pill showing a number: `accent` background,
///   white text in [KaiType.micro], min 16px height, horizontal padding for
///   multi-digit numbers. Counts > 99 are capped to "99+".
/// - [KaiBadge.tide()] — an 8px gradient dot using [KaiTide.gradientCorner]
///   (with the 2px surface ring like `.dot`). For the "Kai saved a memory"
///   signal. Outer diameter: 12px.
///
/// Colors come from the active theme via [KaiTheme.of].
class KaiBadge extends StatelessWidget {
  /// Small filled dot — 6px accent circle inside a 10px surface-colored ring.
  ///
  /// [tone] controls the fill color (default [KaiBadgeTone.accent]).
  /// [color] overrides the fill color explicitly; takes priority over [tone].
  const KaiBadge.dot({
    this.tone = KaiBadgeTone.accent,
    this.color,
    super.key,
  })  : _variant = _KaiBadgeVariant.dot,
        _count = 0;

  /// Numeric pill badge — accent background, white count text.
  ///
  /// Counts above 99 display as "99+".
  const KaiBadge.count(int count, {super.key})
      : _variant = _KaiBadgeVariant.count,
        _count = count,
        tone = KaiBadgeTone.accent,
        color = null;

  /// Tide gradient dot — 8px dot using [KaiTide.gradientCorner] inside a
  /// 12px surface-colored ring. Used as the "Kai saved a memory" signal.
  const KaiBadge.tide({super.key})
      : _variant = _KaiBadgeVariant.tide,
        _count = 0,
        tone = KaiBadgeTone.accent,
        color = null;

  /// Tone for the dot fill (dot variant only). Defaults to [KaiBadgeTone.accent].
  final KaiBadgeTone tone;

  /// Optional fill-color override (dot variant only). Explicit color wins over tone.
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
      case _KaiBadgeVariant.tide:
        return _buildTide(context);
    }
  }

  Widget _buildDot(BuildContext context) {
    final tokens = KaiTheme.of(context);
    final ringColor = tokens.colors.surface;

    // Explicit color override wins over tone.
    final Color dotColor;
    if (color != null) {
      dotColor = color!;
    } else {
      final c = tokens.colors;
      switch (tone) {
        case KaiBadgeTone.accent:
          dotColor = c.accent;
        case KaiBadgeTone.positive:
          dotColor = c.positive;
        case KaiBadgeTone.warning:
          dotColor = c.warning;
        case KaiBadgeTone.negative:
          dotColor = c.negative;
      }
    }

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

    // R1 fix: wrap in IntrinsicWidth so the pill hugs its content. A bare
    // Container with `alignment: center` is greedy and balloons to the parent's
    // bounded width (the Storybook "huge badge" bug). IntrinsicWidth forces a
    // tight width (max(content, 16px)); `alignment: center` then centres the
    // digit within that tight box without expanding.
    return IntrinsicWidth(
      child: Container(
        constraints: const BoxConstraints(
          minWidth: KaiSpace.s4,
          minHeight: KaiSpace.s4,
        ),
        // 4px horizontal inset — a deliberate sub-grid value for a tight numeric
        // badge; no narrower spacing token exists.
        padding: const EdgeInsets.symmetric(horizontal: KaiSpace.s1),
        decoration: BoxDecoration(
          color: tokens.colors.accent,
          borderRadius: KaiRadius.br8,
        ),
        alignment: Alignment.center,
        child: Text(
          label,
          style: KaiType.micro(color: Colors.white),
        ),
      ),
    );
  }

  Widget _buildTide(BuildContext context) {
    final ringColor = KaiTheme.of(context).colors.surface;

    // 8px dot + 2px ring on each side = 12px outer diameter.
    return Container(
      constraints: const BoxConstraints.tightFor(width: 12, height: 12),
      decoration: BoxDecoration(
        color: ringColor,
        shape: BoxShape.circle,
      ),
      alignment: Alignment.center,
      child: Container(
        constraints: const BoxConstraints.tightFor(width: 8, height: 8),
        decoration: const BoxDecoration(
          gradient: KaiTide.gradientCorner,
          shape: BoxShape.circle,
        ),
      ),
    );
  }
}

enum _KaiBadgeVariant { dot, count, tide }
