import 'package:flutter/material.dart';
import 'package:kai_app/design_system/theme/kai_theme.dart';

/// Voice-mode karaoke word-reveal atom.
///
/// Renders a list of words inline with three distinct states:
/// - **spoken** (index < currentIndex): full white `Color(0xFFFFFFFF)` or `c.ink1`
/// - **now** (index == currentIndex): text on tide-3 amber highlight bg
///   `Color(0x47F4B589)` with `KaiRadius.br1` corners
/// - **next** (index > currentIndex): dim white `Color(0x52FFFFFF)` or `c.ink4`
///
/// Canon `.karaoke`: 16px / w500 / Manrope.
/// Canon `.now`: bg rgba(#F4B589, 0.28) = Color(0x47F4B589), r4, pad 1v / 5h.
/// Canon `.next`: rgba(white, 0.32) = Color(0x52FFFFFF).
class KaiKaraokeText extends StatelessWidget {
  const KaiKaraokeText({
    required this.words,
    required this.currentIndex,
    super.key,
  });

  /// All words in the sentence to display.
  final List<String> words;

  /// Index of the word currently being spoken. Words before this index are
  /// "spoken" (bright), words after are "next" (dim).
  final int currentIndex;

  // ── Fixed dark-surface colours (literals, NOT theme tokens) ─────────────────
  // Spoken word: full white.
  static const Color _spokenColor = Color(0xFFFFFFFF);
  // Now word text: also full white (readable on the amber highlight bg).
  static const Color _nowTextColor = Color(0xFFFFFFFF);
  // Now word highlight background: tide-3 (#F4B589) at ~28% opacity.
  // Canon: rgba(#F4B589, 0.28) → alpha = round(0.28 * 255) = 71 = 0x47.
  static const Color _nowBgColor = Color(0x47F4B589);
  // Next word: white at ~32% opacity.
  // Canon: rgba(white, 0.32) → alpha = round(0.32 * 255) = 82 = 0x52.
  static const Color _nextColor = Color(0x52FFFFFF);

  // ── Canon layout literals ────────────────────────────────────────────────────
  // Canon .karaoke: 16px / w500 / Manrope, ls -0.01em, line-height 1.5 (24px).
  static const double _fontSize = 16;
  static const FontWeight _fontWeight = FontWeight.w500;
  static const String _fontFamily = 'Manrope';
  static const double _letterSpacing = 16 * -0.01; // canon: -0.01em
  static const double _lineHeight = 1.5; // canon: 24px / 16px
  // Canon .now padding: 1px vertical, 5px horizontal.
  static const EdgeInsets _nowPadding =
      EdgeInsets.symmetric(horizontal: 5, vertical: 1);
  // Canon .now corner radius: 4px (literal — below KaiRadius.br1=6px).
  static const BorderRadius _nowRadius =
      BorderRadius.all(Radius.circular(4));

  @override
  Widget build(BuildContext context) {
    return Wrap(
      spacing: 4,
      runSpacing: 4,
      children: [
        for (int i = 0; i < words.length; i++) _buildWord(i, context),
      ],
    );
  }

  Widget _buildWord(int index, BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final c = KaiTheme.of(context).colors;

    final spokenColor = isDark ? _spokenColor : c.ink1;
    final nowTextColor = isDark ? _nowTextColor : c.ink1;
    final nextColor = isDark ? _nextColor : c.ink4;

    if (index == currentIndex) {
      // "Now" word — highlighted with tide-3 amber bg.
      return Container(
        padding: _nowPadding,
        decoration: const BoxDecoration(
          color: _nowBgColor,
          borderRadius: _nowRadius,
        ),
        child: Text(
          words[index],
          style: TextStyle(
            fontFamily: _fontFamily,
            fontSize: _fontSize,
            fontWeight: _fontWeight,
            letterSpacing: _letterSpacing,
            height: _lineHeight,
            color: nowTextColor,
          ),
        ),
      );
    }

    final color = index < currentIndex ? spokenColor : nextColor;
    return Text(
      words[index],
      style: TextStyle(
        fontFamily: _fontFamily,
        fontSize: _fontSize,
        fontWeight: _fontWeight,
        letterSpacing: _letterSpacing,
        height: _lineHeight,
        color: color,
      ),
    );
  }
}
