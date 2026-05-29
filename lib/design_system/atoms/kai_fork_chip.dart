import 'package:flutter/material.dart';

import '../theme/kai_theme.dart';
import '../tokens/kai_tokens.dart';

/// Tone variants for [KaiForkChip].
///
/// - [bad]     → `c.negative` text on `c.negativeWash` background.
/// - [neutral] → `c.ink3` text on `c.surface3` background + `c.line` border.
/// - [ok]      → `c.positive` text on `c.positiveWash` background.
enum KaiForkChipTone {
  /// Bad / invalid state — negativeWash bg + negative text.
  bad,

  /// No semantic state — surface3 bg + ink3 text + line border.
  neutral,

  /// Good / valid state — positiveWash bg + positive text.
  ok,
}

/// Fork-card visa-status pill atom.
///
/// Spec: `new-design/fork.html .chip` — 8px/600 Manrope (smaller than
/// [KaiChip.status] which uses 12px JetBrains Mono), [KaiRadius.brPill],
/// padding 2v/6h. Used inside [KaiForkCard] to surface visa/weather/crowd
/// facts at a glance.
///
/// Canon literals — deliberately sub-token font size:
/// - Font: 8px / w600 / Manrope (no token exists at this size)
/// - Padding: 2px vertical, 6px horizontal (below [KaiSpace.s1])
class KaiForkChip extends StatelessWidget {
  const KaiForkChip(
    this.label, {
    this.tone = KaiForkChipTone.neutral,
    super.key,
  });

  /// The text to display. Rendered as-is (no uppercase transform).
  final String label;

  /// Color tone of the chip. Defaults to [KaiForkChipTone.neutral].
  final KaiForkChipTone tone;

  @override
  Widget build(BuildContext context) {
    final c = KaiTheme.of(context).colors;

    final Color textColor;
    final Color bgColor;
    final Border? border;

    switch (tone) {
      case KaiForkChipTone.bad:
        textColor = c.negative;
        bgColor = c.negativeWash;
        border = null;
      case KaiForkChipTone.neutral:
        textColor = c.ink3;
        bgColor = c.surface3;
        // canon: .chip.neu has a 1px line border
        border = Border.all(color: c.line, width: 1);
      case KaiForkChipTone.ok:
        textColor = c.positive;
        bgColor = c.positiveWash;
        border = null;
    }

    return Container(
      // canon: padding: 2px 6px
      padding: const EdgeInsets.symmetric(
        horizontal: 6, // canon literal — below KaiSpace.s1 (4px) + 2px
        vertical: 2, // canon literal — tighter than KaiSpace.s1
      ),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: KaiRadius.brPill,
        border: border,
      ),
      child: Text(
        label,
        style: const TextStyle(
          fontFamily: 'Manrope',
          fontSize: 8, // canon: fork.html .chip font-size 8px/600
          fontWeight: FontWeight.w600,
          height: 1.0,
        ).copyWith(color: textColor),
      ),
    );
  }
}
