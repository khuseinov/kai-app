/// Spacing scale — 4px base, 11-step.
///
/// Source: `new-design/design-tokens.json § space`.
///
/// Values are `double` so they compose into `const EdgeInsets`, `const SizedBox`,
/// etc. directly. Underlying values match the JSON token integers exactly.
class KaiSpace {
  const KaiSpace._();

  static const double s1 = 4;
  static const double s2 = 8;
  static const double s3 = 12;
  static const double s4 = 16;
  static const double s5 = 20;
  static const double s6 = 24;
  static const double s7 = 32;
  static const double s8 = 40;
  static const double s9 = 56;
  static const double s10 = 80;
  static const double s11 = 120;
}
