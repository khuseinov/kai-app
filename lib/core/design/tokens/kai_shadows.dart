import 'package:flutter/material.dart';

class KaiShadows extends ThemeExtension<KaiShadows> {
  final List<BoxShadow> soft;
  final List<BoxShadow> medium;
  final List<BoxShadow> floating;
  final List<BoxShadow> glassGlow;

  const KaiShadows({
    required this.soft,
    required this.medium,
    required this.floating,
    required this.glassGlow,
  });

  factory KaiShadows.light() {
    return const KaiShadows(
      soft: [
        BoxShadow(color: Color(0x0A000000), offset: Offset(0, 2), blurRadius: 8),
      ],
      medium: [
        BoxShadow(color: Color(0x0F000000), offset: Offset(0, 4), blurRadius: 16),
      ],
      floating: [
        BoxShadow(color: Color(0x14000000), offset: Offset(0, 8), blurRadius: 24, spreadRadius: -4),
      ],
      glassGlow: [
        BoxShadow(color: Color(0x1A0D9488), offset: Offset(0, 4), blurRadius: 32, spreadRadius: 0),
      ],
    );
  }

  factory KaiShadows.dark() {
    return const KaiShadows(
      soft: [
        BoxShadow(color: Color(0x1A000000), offset: Offset(0, 2), blurRadius: 8),
      ],
      medium: [
        BoxShadow(color: Color(0x26000000), offset: Offset(0, 4), blurRadius: 16),
      ],
      floating: [
        BoxShadow(color: Color(0x33000000), offset: Offset(0, 8), blurRadius: 24, spreadRadius: -4),
      ],
      glassGlow: [
        BoxShadow(color: Color(0x3314B8A6), offset: Offset(0, 4), blurRadius: 32, spreadRadius: 0),
      ],
    );
  }

  @override
  ThemeExtension<KaiShadows> copyWith({
    List<BoxShadow>? soft,
    List<BoxShadow>? medium,
    List<BoxShadow>? floating,
    List<BoxShadow>? glassGlow,
  }) {
    return KaiShadows(
      soft: soft ?? this.soft,
      medium: medium ?? this.medium,
      floating: floating ?? this.floating,
      glassGlow: glassGlow ?? this.glassGlow,
    );
  }

  @override
  ThemeExtension<KaiShadows> lerp(ThemeExtension<KaiShadows>? other, double t) {
    if (other is! KaiShadows) return this;
    return KaiShadows(
      soft: BoxShadow.lerpList(soft, other.soft, t) ?? soft,
      medium: BoxShadow.lerpList(medium, other.medium, t) ?? medium,
      floating: BoxShadow.lerpList(floating, other.floating, t) ?? floating,
      glassGlow: BoxShadow.lerpList(glassGlow, other.glassGlow, t) ?? glassGlow,
    );
  }
}
