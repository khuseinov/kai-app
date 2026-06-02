import 'package:flutter/material.dart';

import '../../../design_system/theme/kai_theme.dart';
import '../../../design_system/tokens/kai_tokens.dart';

/// Tone variants for [KaiForkChip].
///
/// - [bad]     → `c.negative` text on `c.negativeWash` background.
/// - [neutral] → `c.ink3` text on `c.surface2` background + 0.8px `c.line` border.
/// - [ok]      → `c.positive` text on `c.positiveWash` background.
/// - [warn]    → `c.warning` text on `c.warningWash` background.
enum KaiForkChipTone {
  /// Bad / invalid state — negativeWash bg + negative text.
  bad,

  /// No semantic state — surface2 bg + ink3 text + 0.8px line border.
  neutral,

  /// Good / valid state — positiveWash bg + positive text.
  ok,

  /// Caution state — warningWash bg + warning text (e.g. "толпы↑").
  warn,
}

/// Fork-card visa-status pill atom.
///
/// Spec: `new-design/fork.html .chip` — 8px/600 JetBrains Mono, UPPERCASE,
/// 0.04em tracking (smaller than [KaiChip.status] which is 12px), [KaiRadius.brPill],
/// padding 2v/6h. Used inside [KaiForkCard] to surface visa/weather/crowd
/// facts at a glance.
///
/// Canon literals — deliberately sub-token font size:
/// - Font: 8px / w600 / JetBrains Mono, uppercase, ls 0.04em (no token at this size)
/// - Padding: 2px vertical, 6px horizontal (below [KaiSpace.s1])
class KaiForkChip extends StatelessWidget {
  const KaiForkChip(
    this.label, {
    this.tone = KaiForkChipTone.neutral,
    super.key,
  });

  /// The text to display. Rendered UPPERCASE (canon `.chip` text-transform).
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
        bgColor = c.surface2; // canon: .chip.neu bg surface2 (#F3F3F1)
        // canon: .chip.neu has a 0.8px line border
        border = Border.all(color: c.line, width: 0.8);
      case KaiForkChipTone.ok:
        textColor = c.positive;
        bgColor = c.positiveWash;
        border = null;
      case KaiForkChipTone.warn:
        textColor = c.warning;
        bgColor = c.warningWash;
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
        label.toUpperCase(), // canon: .chip text-transform uppercase
        style: TextStyle(
          fontFamily: 'JetBrainsMono', // canon: .chip mono (8px/600)
          fontSize: 8,
          fontWeight: FontWeight.w600,
          letterSpacing: 8 * 0.04, // canon: 0.04em tracking
          height: 1.0,
          color: textColor,
        ),
      ),
    );
  }
}
