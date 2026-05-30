import 'package:flutter/material.dart';

import '../theme/kai_theme.dart';
import '../tokens/kai_tokens.dart';

/// Fork-card rating row atom.
///
/// Renders a row of [max] small circles: the first [score] are filled with
/// [fillColor] (defaults to tide-2 `KaiTide.stop2`); the remaining are filled
/// with `c.surface3`. When [showLabel] is true, a trailing "n/max" label is
/// rendered (canon `.fc-score .sl`).
///
/// Canon: `new-design/fork.html .fc-score` — 5×5px circles, 3px gap; filled
/// dots are tide-2 (#2BA8C9), not positive green.
///
/// Canon literals:
/// - Dot size: 5×5px (below [KaiSpace.s1])
/// - Gap between dots: 3px (below [KaiSpace.s1])
/// - Label `.sl`: JetBrains Mono 8.5px/500, ink3
class KaiForkScoreDots extends StatelessWidget {
  const KaiForkScoreDots({
    required this.score,
    this.max = 5,
    this.fillColor,
    this.showLabel = false,
    super.key,
  }) : assert(score >= 0, 'score must be >= 0'),
       assert(max > 0, 'max must be > 0');

  /// Number of filled dots (clamped to [max] at build time).
  final int score;

  /// Total number of dots. Defaults to 5.
  final int max;

  /// Fill color for the scored dots. Defaults to tide-2 ([KaiTide.stop2]).
  final Color? fillColor;

  /// When true, render a trailing "n/max" label (canon `.sl`).
  final bool showLabel;

  @override
  Widget build(BuildContext context) {
    final c = KaiTheme.of(context).colors;
    // canon: .d.f fill = tide-2 (#2BA8C9), not positive green.
    final activeFill = fillColor ?? KaiTide.stop2;
    final filled = score.clamp(0, max);

    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        for (int i = 0; i < max; i++) ...[
          if (i > 0) const SizedBox(width: 3), // canon: 3px gap
          _Dot(filled: i < filled, fillColor: activeFill, emptyColor: c.surface3),
        ],
        if (showLabel) ...[
          const SizedBox(width: 6), // canon: gap before .sl
          Text(
            '$filled/$max',
            style: TextStyle(
              fontFamily: 'JetBrainsMono', // canon: .sl 8.5px/500 mono ink3
              fontSize: 8.5,
              fontWeight: FontWeight.w500,
              color: c.ink3,
            ),
          ),
        ],
      ],
    );
  }
}

// ---------------------------------------------------------------------------
// Internal dot widget
// ---------------------------------------------------------------------------

class _Dot extends StatelessWidget {
  const _Dot({
    required this.filled,
    required this.fillColor,
    required this.emptyColor,
  });

  final bool filled;
  final Color fillColor;
  final Color emptyColor;

  @override
  Widget build(BuildContext context) {
    return Container(
      // canon: 5×5px circles
      width: 5,
      height: 5,
      decoration: BoxDecoration(
        color: filled ? fillColor : emptyColor,
        shape: BoxShape.circle,
      ),
    );
  }
}
