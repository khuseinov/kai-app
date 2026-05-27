import 'package:flutter/material.dart';

import '../atoms/kai_icon.dart';
import '../theme/kai_theme.dart';
import '../tokens/kai_tokens.dart';

/// Severity variant of an inline system note. Source: `components.html § 03.8`
/// (`.bub.system`, `.bub.system.warning`, `.bub.system.negative`).
enum SystemNoteType { neutral, warning, negative }

/// Inline system note bubble — full-width pill in the chat feed.
///
/// Canon: `new-design/components.html § 03.8 .bub.system`:
///
/// ```
/// align-self: stretch
/// padding: 11px 14px
/// border-radius: 12px
/// font-size: 13.5px / line-height 1.5 / ink-2
/// gap (icon→text): 10px
/// icon: 16×16 left, top-aligned (margin-top 2)
/// bold prefix: <strong>Внимание —</strong> (Manrope 600), rest is regular
/// ```
///
/// Backgrounds + foregrounds by variant:
///
/// | Variant   | bg              | fg color (text + icon) |
/// |-----------|-----------------|------------------------|
/// | neutral   | surface-2       | ink-2                  |
/// | warning   | warning-wash    | warning                |
/// | negative  | negative-wash   | negative               |
///
/// Used in `components.html § 03.8` to surface inline cautions like
/// "Внимание — сайт посольства не обновлялся 6 месяцев" alongside Kai's reply,
/// without breaking the conversational flow into a separate alert.
class KaiSystemNote extends StatelessWidget {
  const KaiSystemNote({
    required this.message,
    this.type = SystemNoteType.neutral,
    this.bold,
    this.icon = KaiIconName.alert,
    super.key,
  });

  final SystemNoteType type;

  /// Body text. Rendered as the regular-weight span when [bold] is set, or
  /// as the whole note when [bold] is null.
  final String message;

  /// Optional emphasised prefix (e.g. "Внимание —"). Rendered Manrope 600,
  /// followed by [message] in regular weight on the same line.
  final String? bold;

  /// Override icon — default is `KaiIconName.alert` (triangle, matches HTML
  /// `.bub.system.warning` inline SVG).
  final KaiIconName icon;

  @override
  Widget build(BuildContext context) {
    final c = KaiTheme.of(context).colors;
    final palette = _palette(c, type);

    return Container(
      // Canon: align-self: stretch — caller is responsible for full-width
      // placement. We render width: double.infinity via constraints.
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 11),
      decoration: BoxDecoration(
        color: palette.bg,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Icon 16×16, top-aligned with margin-top 2 (canon `.bub.system svg
          // { flex-shrink: 0; margin-top: 2px }`).
          Padding(
            padding: const EdgeInsets.only(top: 2),
            child: KaiIcon(icon, size: 16, color: palette.fg),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Text.rich(
              TextSpan(
                style: TextStyle(
                  fontFamily: 'Manrope',
                  fontSize: 13.5,
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

// ─── Palette ────────────────────────────────────────────────────────────────

class _SystemNotePalette {
  const _SystemNotePalette({required this.bg, required this.fg});

  final Color bg;
  final Color fg;
}

_SystemNotePalette _palette(KaiColorTokens c, SystemNoteType type) {
  switch (type) {
    case SystemNoteType.neutral:
      return _SystemNotePalette(bg: c.surface2, fg: c.ink2);
    case SystemNoteType.warning:
      return _SystemNotePalette(bg: c.warningWash, fg: c.warning);
    case SystemNoteType.negative:
      return _SystemNotePalette(bg: c.negativeWash, fg: c.negative);
  }
}
