import 'package:flutter/material.dart';

import '../../../../design_system/theme/kai_theme.dart';
import '../../../../design_system/tokens/kai_tokens.dart';
import '../../../../design_system/primitives/primitives.dart';

/// Tone variants for [KaiSystemBubble].
///
/// | Tone     | Background          | Text/icon          |
/// |----------|---------------------|--------------------|
/// | neutral  | `colors.surface2`   | `colors.ink2`      |
/// | warning  | `colors.warningWash`| `colors.warning`   |
/// | negative | `colors.negativeWash`| `colors.negative` |
enum KaiSystemTone { neutral, warning, negative }

/// v3 inline system bubble — full-width note in the chat feed.
///
/// Canon: `new-design/components.html § .bub.system`
///
/// Replaces v2 `KaiSystemNote` with a v3-native implementation that uses the
/// v3 primitive `KaiIcon` and v3 atom `KaiText` instead of v2 atoms. The
/// public API is intentionally close to `KaiSystemNote` so migration is simple.
///
/// ## Sizing decisions (canon vs. token)
///
/// | Property  | Canon HTML  | Token used                   | Drift  |
/// |-----------|-------------|------------------------------|--------|
/// | padding-v | 11px        | `KaiSpace.s3` (12px)         | +1px   |
/// | padding-h | 14px        | `KaiSpace.s3` (12px) — close | +2px   |
/// | border-r  | 12px        | `KaiRadius.r12` (12px)       | exact  |
/// | icon-mt   | 2px         | literal `EdgeInsets.only(top: 2)` | exact |
///
/// Padding-h is 14px in canon — we use `KaiSpace.s3` (12px, drift +2px) for
/// grid alignment. A literal `14` could also be justified; tokens preferred.
/// Actually, since 14px is not on the token scale AND the canvas impact is
/// small, we use the literal 14 with a comment for canon fidelity.
///
/// ## Bold lead-in
/// Optional [bold] prefix rendered `Manrope/w600` before [message] on the same
/// line — ported from `KaiSystemNote`.
///
/// API:
/// ```dart
/// KaiSystemBubble(
///   'Внимание — сайт не обновлялся 6 месяцев.',
///   bold: 'Внимание —',
///   tone: KaiSystemTone.warning,
///   icon: KaiIconName.alert,
/// )
/// ```
class KaiSystemBubble extends StatelessWidget {
  const KaiSystemBubble(
    this.message, {
    this.tone = KaiSystemTone.neutral,
    this.icon = KaiIconName.alert,
    this.bold,
    super.key,
  });

  /// Body text.
  final String message;

  /// Severity tone — controls background and foreground colours.
  final KaiSystemTone tone;

  /// Leading icon. Default `KaiIconName.alert` (matches canon `.bub.system svg`).
  final KaiIconName icon;

  /// Optional emphasised prefix rendered Manrope w600, followed by [message].
  /// E.g. `bold: 'Внимание —'` → **Внимание —** rest of message.
  final String? bold;

  @override
  Widget build(BuildContext context) {
    final c = KaiTheme.of(context).colors;
    final palette = _palette(c, tone);

    return Container(
      // Canon: align-self: stretch — full width
      width: double.infinity,
      padding: const EdgeInsets.symmetric(
        // canon: 11px vertical / 14px horizontal
        // vertical: KaiSpace.s3 (12px) — drift +1px
        // horizontal: literal 14 — not on token scale; canon fidelity preferred
        vertical: KaiSpace.s3, // canon: 11, drift +1
        horizontal: 14, // canon: 14 (off-scale literal)
      ),
      decoration: BoxDecoration(
        color: palette.bg,
        borderRadius: KaiRadius.br12, // canon: 12px — exact
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Canon: svg { flex-shrink: 0; margin-top: 2px }
          Padding(
            padding: const EdgeInsets.only(top: 2), // canon: margin-top 2px
            child: KaiIcon(icon, size: 16, color: palette.fg),
          ),
          const SizedBox(width: 10), // canon: gap 10px
          Expanded(
            child: Text.rich(
              TextSpan(
                style: TextStyle(
                  fontFamily: 'Manrope',
                  // canon: font-size 13.5px — exact; no token equivalent
                  fontSize: 13.5, // canon: 13.5 (off-scale literal)
                  fontWeight: FontWeight.w400,
                  height: 1.5,
                  color: palette.fg,
                ),
                children: [
                  if (bold != null)
                    TextSpan(
                      text: bold,
                      style: const TextStyle(fontWeight: FontWeight.w600),
                    ),
                  TextSpan(text: message),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Palette helper
// ---------------------------------------------------------------------------

class _SystemBubblePalette {
  const _SystemBubblePalette({required this.bg, required this.fg});

  final Color bg;
  final Color fg;
}

_SystemBubblePalette _palette(KaiColorTokens c, KaiSystemTone tone) {
  switch (tone) {
    case KaiSystemTone.neutral:
      return _SystemBubblePalette(bg: c.surface2, fg: c.ink2);
    case KaiSystemTone.warning:
      return _SystemBubblePalette(bg: c.warningWash, fg: c.warning);
    case KaiSystemTone.negative:
      return _SystemBubblePalette(bg: c.negativeWash, fg: c.negative);
  }
}
