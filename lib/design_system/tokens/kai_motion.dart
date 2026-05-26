import 'package:flutter/animation.dart';

/// Motion tokens — durations + easing curves.
///
/// Source: `new-design/design-tokens.json § motion`.
class KaiMotion {
  const KaiMotion._();

  // Durations
  static const Duration standard = Duration(milliseconds: 240);
  static const Duration ambient = Duration(milliseconds: 2600);
  static const Duration micro = Duration(milliseconds: 120);

  // Easing curves
  /// Material 3 emphasized — for UI panels, sheets, drawers.
  static const Curve standardCurve = Cubic(0.2, 0, 0, 1);

  /// Symmetric ease for breathing animations — tide pulse, brand cycles.
  static const Curve ambientCurve = Cubic(0.4, 0, 0.6, 1);

  /// Symmetric ease. Identical to [ambientCurve] by design — Kai's exit motion
  /// matches enter to preserve the calm aesthetic (no snappier-than-enter).
  /// Matches `new-design/design-tokens.json § motion` which has them identical.
  static const Curve exitCurve = Cubic(0.4, 0, 0.6, 1);

  /// For stroke flow, gradient slide.
  static const Curve linearCurve = Curves.linear;
}
