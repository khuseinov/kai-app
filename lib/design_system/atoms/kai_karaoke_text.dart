import 'package:flutter/material.dart';

import '../tokens/kai_radius.dart';

/// Voice-mode karaoke word-reveal atom.
///
/// Renders a list of words inline with three distinct states:
/// - **spoken** (index < currentIndex): full white `Color(0xFFFFFFFF)`
/// - **now** (index == currentIndex): white text on tide-3 amber highlight bg
///   `Color(0x47F4B589)` with `KaiRadius.br1` corners
/// - **next** (index > currentIndex): dim white `Color(0x52FFFFFF)`
///
/// **Dark-surface only.** This widget is designed to sit on the always-dark
/// voice field (#08080A). All colours are fixed white/tide literals —
/// NOT theme tokens — and will not adapt to light mode.
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
  // Canon .karaoke: 16px / w500 / Manrope.
  static const double _fontSize = 16;
  static const FontWeight _fontWeight = FontWeight.w500;
  static const String _fontFamily = 'Manrope';
  // Canon .now padding: 1px vertical, 5px horizontal.
  static const EdgeInsets _nowPadding =
      EdgeInsets.symmetric(horizontal: 5, vertical: 1);

  @override
  Widget build(BuildContext context) {
    return Wrap(
      spacing: 4,
      runSpacing: 4,
      children: [
        for (int i = 0; i < words.length; i++) _buildWord(i),
      ],
    );
  }

  Widget _buildWord(int index) {
    if (index == currentIndex) {
      // "Now" word — highlighted with tide-3 amber bg.
      return Container(
        padding: _nowPadding,
        decoration: const BoxDecoration(
          color: _nowBgColor,
          borderRadius: KaiRadius.br1,
        ),
        child: Text(
          words[index],
          style: const TextStyle(
            fontFamily: _fontFamily,
            fontSize: _fontSize,
            fontWeight: _fontWeight,
            color: _nowTextColor,
          ),
        ),
      );
    }

    final color = index < currentIndex ? _spokenColor : _nextColor;
    return Text(
      words[index],
      style: TextStyle(
        fontFamily: _fontFamily,
        fontSize: _fontSize,
        fontWeight: _fontWeight,
        color: color,
      ),
    );
  }
}
