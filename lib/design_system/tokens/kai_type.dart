import 'package:flutter/painting.dart';

/// Type scale — Manrope (humanist) + JetBrains Mono.
///
/// Source: `new-design/design-tokens.json § type` + `colors_and_type.css`.
///
/// Each style is a factory taking a [Color] — colour depends on the active
/// theme, not on the type itself.
///
/// CSS uses `letter-spacing: -0.035em` etc. — em-relative. Flutter's
/// `letterSpacing` is absolute logical pixels, so we precompute `fontSize * em`.
class KaiType {
  const KaiType._();

  /// 72/600 — display-grade hero copy.
  static TextStyle hero({required Color color}) => TextStyle(
        fontFamily: 'Manrope',
        fontSize: 72,
        fontWeight: FontWeight.w600,
        height: 0.96,
        letterSpacing: 72 * -0.035,
        color: color,
      );

  /// 56/600 — display.
  static TextStyle display({required Color color}) => TextStyle(
        fontFamily: 'Manrope',
        fontSize: 56,
        fontWeight: FontWeight.w600,
        height: 1.02,
        letterSpacing: 56 * -0.025,
        color: color,
      );

  /// 36/600 — h1.
  static TextStyle h1({required Color color}) => TextStyle(
        fontFamily: 'Manrope',
        fontSize: 36,
        fontWeight: FontWeight.w600,
        height: 1.1,
        letterSpacing: 36 * -0.022,
        color: color,
      );

  /// 24/600 — h2.
  static TextStyle h2({required Color color}) => TextStyle(
        fontFamily: 'Manrope',
        fontSize: 24,
        fontWeight: FontWeight.w600,
        height: 1.2,
        letterSpacing: 24 * -0.015,
        color: color,
      );

  /// 18/600 — h3.
  static TextStyle h3({required Color color}) => TextStyle(
        fontFamily: 'Manrope',
        fontSize: 18,
        fontWeight: FontWeight.w600,
        height: 1.3,
        letterSpacing: 18 * -0.01,
        color: color,
      );

  /// 20/400 — lead paragraph.
  static TextStyle lead({required Color color}) => TextStyle(
        fontFamily: 'Manrope',
        fontSize: 20,
        fontWeight: FontWeight.w400,
        height: 1.5,
        letterSpacing: 20 * -0.005,
        color: color,
      );

  /// 16/400 — body.
  static TextStyle body({required Color color}) => TextStyle(
        fontFamily: 'Manrope',
        fontSize: 16,
        fontWeight: FontWeight.w400,
        height: 1.55,
        letterSpacing: 0,
        color: color,
      );

  /// 14/400 — small.
  static TextStyle small({required Color color}) => TextStyle(
        fontFamily: 'Manrope',
        fontSize: 14,
        fontWeight: FontWeight.w400,
        height: 1.5,
        letterSpacing: 0,
        color: color,
      );

  /// 12/500 — micro. Caller is responsible for UPPERCASE transform.
  static TextStyle micro({required Color color}) => TextStyle(
        fontFamily: 'Manrope',
        fontSize: 12,
        fontWeight: FontWeight.w500,
        height: 1.4,
        letterSpacing: 12 * 0.02,
        color: color,
      );

  /// 12/400 — monospace.
  static TextStyle mono({required Color color}) => TextStyle(
        fontFamily: 'JetBrainsMono',
        fontSize: 12,
        fontWeight: FontWeight.w400,
        height: 1.4,
        letterSpacing: 0,
        color: color,
      );
}
