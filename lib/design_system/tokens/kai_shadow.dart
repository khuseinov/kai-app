import 'package:flutter/painting.dart';

/// Shadow tokens — soft depth cues keyed to the tide palette.
///
/// Source: extracted from hardcoded values in [KaiButton] and the design audit.
/// All shadows derive from tide-2 sea-glass (#2BA8C9) at varying alpha levels.
class KaiShadow {
  const KaiShadow._();

  /// Soft drop shadow used on tide-gradient (primary) buttons.
  ///
  /// Color: rgba(43, 168, 201, 0.18) — tide-2 sea-glass at alpha 0x2E (46/255 ≈ 0.18).
  /// Source: [KaiButton.tide] BoxDecoration.boxShadow (previously hardcoded inline).
  static const List<BoxShadow> button = [
    BoxShadow(
      color: Color(0x2E2BA8C9),
      blurRadius: 8,
      offset: Offset(0, 2),
    ),
  ];

  /// Emphasis glow for money-gate / hero surfaces.
  ///
  /// Color: rgba(43, 168, 201, 0.384) — tide-2 sea-glass at alpha 0x62 (98/255 ≈ 0.384).
  /// Exact blur radius to be canon-confirmed when KaiButton.tide(emphasis: glow)
  /// is built in W1; 16 is a sensible starting default for a diffuse glow.
  static const List<BoxShadow> glow = [
    BoxShadow(
      color: Color(0x622BA8C9),
      blurRadius: 16,
      offset: Offset(0, 0),
    ),
  ];
}
