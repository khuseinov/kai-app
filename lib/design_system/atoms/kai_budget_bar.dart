import 'package:flutter/material.dart';

import '../theme/kai_theme.dart';
import '../tokens/kai_tokens.dart';

/// A single segment in a [KaiBudgetBar].
///
/// [fraction] must be in the range `0.0 – 1.0`. The sum of all segment
/// fractions should be ≤ 1.0; any remainder shows the background track.
class KaiBudgetSegment {
  const KaiBudgetSegment({
    required this.fraction,
    required this.color,
    required this.label,
  });

  /// Proportional width — e.g. `0.45` fills 45 % of the track.
  final double fraction;

  /// Fill color for this segment.
  final Color color;

  /// Human-readable label shown in the optional legend row.
  final String label;
}

/// Segmented horizontal progress bar for budget breakdowns.
///
/// Spec: `new-design/trip-detail.html .budget-bar` — pill track
/// (`KaiRadius.brPill`, bg `surface3`, given [height]) containing proportional
/// coloured segments. Segment proportions are implemented as `Expanded(flex:
/// (fraction * 1000).round())` children inside a `ClipRRect(brPill)` so the
/// track corners clip all segment corners uniformly.
///
/// When [showLegend] is true, a legend row is rendered below the track: each
/// segment is represented by a small colour swatch and its [KaiBudgetSegment.label].
class KaiBudgetBar extends StatelessWidget {
  const KaiBudgetBar({
    required this.segments,
    this.height = 8,
    this.showLegend = false,
    super.key,
  });

  /// Budget segments to render. May sum to less than 1.0 — remainder is shown
  /// as the `surface3` background track.
  final List<KaiBudgetSegment> segments;

  /// Height of the pill track in logical pixels. Defaults to 8.
  final double height;

  /// When true, renders a legend row below the track with a colour swatch and
  /// label for each segment. Labels use KaiType.small/micro sizing.
  final bool showLegend;

  @override
  Widget build(BuildContext context) {
    final c = KaiTheme.of(context).colors;

    // Clamp total fraction to 1.0 so segments never overflow the track.
    final total =
        segments.fold<double>(0, (acc, s) => acc + s.fraction).clamp(0.0, 1.0);
    final remainder = 1.0 - total;
    // Convert fractions to integer flex weights (× 1000 for precision).
    final segmentFlexes =
        segments.map((s) => (s.fraction * 1000).round()).toList();
    final remainderFlex = (remainder * 1000).round();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        // ── Track ──────────────────────────────────────────────────────────────
        SizedBox(
          height: height,
          child: ClipRRect(
            borderRadius: KaiRadius.brPill,
            child: ColoredBox(
              color: c.surface3,
              child: Row(
                children: [
                  for (var i = 0; i < segments.length; i++)
                    if (segmentFlexes[i] > 0)
                      Expanded(
                        flex: segmentFlexes[i],
                        child: ColoredBox(color: segments[i].color),
                      ),
                  if (remainderFlex > 0)
                    Expanded(
                      flex: remainderFlex,
                      child: ColoredBox(color: c.surface3),
                    ),
                ],
              ),
            ),
          ),
        ),

        // ── Legend ─────────────────────────────────────────────────────────────
        if (showLegend) ...[
          const SizedBox(height: KaiSpace.s2),
          Wrap(
            spacing: KaiSpace.s3,
            runSpacing: KaiSpace.s2,
            children: [
              for (final seg in segments)
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // Colour swatch — 8×8 rounded square
                    Container(
                      width: 8,
                      height: 8,
                      decoration: BoxDecoration(
                        color: seg.color,
                        borderRadius: KaiRadius.br1,
                      ),
                    ),
                    const SizedBox(width: KaiSpace.s1),
                    Text(
                      seg.label,
                      style: TextStyle(
                        fontFamily: 'Manrope',
                        fontSize: 11,
                        fontWeight: FontWeight.w400,
                        color: c.ink3,
                        height: 1.2,
                      ),
                    ),
                  ],
                ),
            ],
          ),
        ],
      ],
    );
  }
}
