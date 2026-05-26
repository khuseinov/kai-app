import 'package:flutter/painting.dart';

/// Radius scale — soft-but-precise.
///
/// Source: `new-design/design-tokens.json § radius`.
class KaiRadius {
  const KaiRadius._();

  static const double r1 = 6; // tags, small chips
  static const double r2 = 10; // inputs
  static const double r3 = 14; // buttons
  static const double r4 = 20; // cards, bubbles
  static const double r5 = 28; // sheets, hero surfaces
  static const double pill = 999;

  static BorderRadius get br1 => BorderRadius.circular(r1);
  static BorderRadius get br2 => BorderRadius.circular(r2);
  static BorderRadius get br3 => BorderRadius.circular(r3);
  static BorderRadius get br4 => BorderRadius.circular(r4);
  static BorderRadius get br5 => BorderRadius.circular(r5);
  static BorderRadius get brPill => BorderRadius.circular(pill);
}
