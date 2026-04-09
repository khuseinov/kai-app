import 'package:flutter/material.dart';
import '../tokens/kai_colors.dart';
import '../tokens/kai_typography.dart';
import '../tokens/kai_shadows.dart';

extension KaiThemeExtensions on ThemeData {
  KaiColors get kaiColors => extension<KaiColors>()!;
  KaiTypography get kaiTypography => extension<KaiTypography>()!;
  KaiShadows get kaiShadows => extension<KaiShadows>()!;
}

class KaiContextExtensions {
  static KaiColors colorsOf(BuildContext context) => Theme.of(context).extension<KaiColors>()!;
  static KaiTypography typographyOf(BuildContext context) => Theme.of(context).extension<KaiTypography>()!;
  static KaiShadows shadowsOf(BuildContext context) => Theme.of(context).extension<KaiShadows>()!;
}

extension BuildContextKaiTheme on BuildContext {
  KaiColors get kaiColors => KaiContextExtensions.colorsOf(this);
  KaiTypography get kaiTypography => KaiContextExtensions.typographyOf(this);
  KaiShadows get kaiShadows => KaiContextExtensions.shadowsOf(this);
}
