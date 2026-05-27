import 'package:flutter/painting.dart';

/// Resolved color tokens for one theme (light or dark).
///
/// Source of truth: `new-design/colors_and_type.css` + `new-design/design-tokens.json`.
class KaiColorTokens {
  const KaiColorTokens({
    required this.bg,
    required this.surface,
    required this.surface2,
    required this.surface3,
    required this.ink1,
    required this.ink2,
    required this.ink3,
    required this.ink4,
    required this.line,
    required this.lineStrong,
    required this.accent,
    required this.accentDeep,
    required this.accentWash,
    required this.accentLine,
    required this.positive,
    required this.positiveWash,
    required this.warning,
    required this.warningWash,
    required this.negative,
    required this.negativeWash,
  });

  // Surfaces — warm near-whites (light) / deep warm slates (dark)
  final Color bg;
  final Color surface;
  final Color surface2;
  final Color surface3;

  // Ink — text colors, warm-tinted
  final Color ink1;
  final Color ink2;
  final Color ink3;
  final Color ink4;

  // Lines — 1px hairlines
  final Color line;
  final Color lineStrong;

  // Accent — single solid for primary actions
  final Color accent;
  final Color accentDeep;
  final Color accentWash;
  final Color accentLine;

  // Semantic — muted, never alarming
  final Color positive;
  final Color positiveWash;
  final Color warning;
  final Color warningWash;
  final Color negative;
  final Color negativeWash;
}

/// Factory entrypoint for KaiColorTokens.
class KaiColors {
  const KaiColors._();

  /// Light palette — warm near-whites, never pure #FFF for the page background.
  static const KaiColorTokens light = KaiColorTokens(
    bg: Color(0xFFFAFAF9),
    surface: Color(0xFFFFFFFF),
    surface2: Color(0xFFF3F3F1),
    surface3: Color(0xFFECECEA),
    ink1: Color(0xFF111114),
    ink2: Color(0xFF43434A),
    ink3: Color(0xFF76767E),
    ink4: Color(0xFFA8A8AE),
    line: Color(0xFFE8E8E5),
    lineStrong: Color(0xFFD2D2CE),
    accent: Color(0xFF2C5BE5),
    accentDeep: Color(0xFF1E48C7),
    accentWash: Color(0xFFEEF2FD),
    accentLine: Color(0xFFC3D2F6),
    positive: Color(0xFF1B8E4E),
    positiveWash: Color(0xFFE6F4ED),
    warning: Color(0xFFB57A0B),
    warningWash: Color(0xFFFBF1DC),
    negative: Color(0xFFC44A3C),
    negativeWash: Color(0xFFF8E6E3),
  );

  /// Dark palette — deep warm slates, never pure black.
  /// rgba alphas converted to ARGB: 0.12 ≈ 0x1F, 0.28 ≈ 0x47.
  static const KaiColorTokens dark = KaiColorTokens(
    bg: Color(0xFF0E0E11),
    surface: Color(0xFF16161A),
    surface2: Color(0xFF1E1E23),
    surface3: Color(0xFF25252A),
    ink1: Color(0xFFF5F5F2),
    ink2: Color(0xFFC8C8C2),
    ink3: Color(0xFF8E8E88),
    ink4: Color(0xFF5C5C58),
    line: Color(0xFF2A2A2F),
    lineStrong: Color(0xFF3A3A3F),
    accent: Color(0xFF5C8EFF),
    accentDeep: Color(0xFF4275E5),
    // rgba(92, 142, 255, 0.12) → 0x1F5C8EFF
    accentWash: Color(0x1F5C8EFF),
    // rgba(92, 142, 255, 0.28) → 0x475C8EFF
    accentLine: Color(0x475C8EFF),
    positive: Color(0xFF3DBE7A),
    // rgba(61, 190, 122, 0.12) → 0x1F3DBE7A
    positiveWash: Color(0x1F3DBE7A),
    warning: Color(0xFFD69E3E),
    // rgba(214, 158, 62, 0.12) → 0x1FD69E3E
    warningWash: Color(0x1FD69E3E),
    negative: Color(0xFFE66F60),
    // rgba(230, 111, 96, 0.12) → 0x1FE66F60
    negativeWash: Color(0x1FE66F60),
  );
}
