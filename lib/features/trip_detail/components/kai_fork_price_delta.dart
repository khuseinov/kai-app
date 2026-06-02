import 'package:flutter/material.dart';

import '../../../design_system/theme/kai_theme.dart';
import '../../../design_system/tokens/kai_tokens.dart';

/// Direction of a price change.
///
/// - [up]   → price rose (more expensive → `negative` coral palette).
/// - [down] → price fell (cheaper → `positive` green palette).
enum KaiPriceDirection { up, down }

/// Fork-card price-change pill — canon `new-design/fork.html .fc-delta`.
///
/// JetBrains Mono 8.5px/600, padding 1.5v/5h, [KaiRadius.brPill]. Sits next to
/// the price in `.fc-price-row`. Semantics are travel-cost-oriented: a price
/// going **up** is bad (coral), going **down** is good (green) — the inverse of
/// a stock ticker.
class KaiForkPriceDelta extends StatelessWidget {
  const KaiForkPriceDelta(this.label, {required this.direction, super.key});

  /// Delta text, e.g. "+\$500" / "−\$500".
  final String label;

  /// Whether the price rose ([KaiPriceDirection.up]) or fell down.
  final KaiPriceDirection direction;

  @override
  Widget build(BuildContext context) {
    final c = KaiTheme.of(context).colors;
    final up = direction == KaiPriceDirection.up;
    // up = costlier → negative; down = cheaper → positive.
    final fg = up ? c.negative : c.positive;
    final bg = up ? c.negativeWash : c.positiveWash;

    return Container(
      // canon: .fc-delta padding 1.5px vertical / 5px horizontal
      padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 1.5),
      decoration: BoxDecoration(color: bg, borderRadius: KaiRadius.brPill),
      child: Text(
        label,
        style: TextStyle(
          fontFamily: 'JetBrainsMono', // canon: .fc-delta mono 8.5px/600
          fontSize: 8.5,
          fontWeight: FontWeight.w600,
          color: fg,
          height: 1.0,
        ),
      ),
    );
  }
}
