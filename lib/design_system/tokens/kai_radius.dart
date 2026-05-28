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

  // Extra fill-in values used by canon HTML (8px and 12px sites) that fall
  // between the primary scale steps. Placed after pill to keep r1–r5/pill
  // as a contiguous named block; numeric suffix reflects the pixel value.
  static const double r8 = 8; // detail-row actions, small surfaces
  static const double r12 = 12; // nav new-chat button, system note, settings group

  static const BorderRadius br1 = BorderRadius.all(Radius.circular(r1));
  static const BorderRadius br2 = BorderRadius.all(Radius.circular(r2));
  static const BorderRadius br3 = BorderRadius.all(Radius.circular(r3));
  static const BorderRadius br4 = BorderRadius.all(Radius.circular(r4));
  static const BorderRadius br5 = BorderRadius.all(Radius.circular(r5));
  static const BorderRadius brPill = BorderRadius.all(Radius.circular(pill));
  static const BorderRadius br8 = BorderRadius.all(Radius.circular(r8));
  static const BorderRadius br12 = BorderRadius.all(Radius.circular(r12));
}
