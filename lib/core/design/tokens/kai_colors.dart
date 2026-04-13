import 'package:flutter/material.dart';

class KaiColors extends ThemeExtension<KaiColors> {
  // Brand Colors (Kai Ocean)
  final Color oceanPrimary;
  final Color oceanLight;
  final Color oceanDark;

  // Neutral Scales (Anthropic)
  final Color slateDark;
  final Color slateMedium;
  final Color slateLight;

  final Color cloudDark;
  final Color cloudMedium;
  final Color cloudLight;

  final Color ivoryDark;
  final Color ivoryMedium;
  final Color ivoryLight;

  // Semantic & State Colors
  final Color stateListening;
  final Color stateThinking;
  final Color stateSpeaking;

  final Color success;
  final Color warning;
  final Color error;

  // Theme Mapping
  final Color background;
  final Color surface;
  final Color surfaceContainer;
  final Color textPrimary;
  final Color textSecondary;
  final Color textTertiary;
  final Color glassBorder;
  final Color primary;
  final Color onPrimary;

  const KaiColors({
    required this.oceanPrimary,
    required this.oceanLight,
    required this.oceanDark,
    required this.slateDark,
    required this.slateMedium,
    required this.slateLight,
    required this.cloudDark,
    required this.cloudMedium,
    required this.cloudLight,
    required this.ivoryDark,
    required this.ivoryMedium,
    required this.ivoryLight,
    required this.stateListening,
    required this.stateThinking,
    required this.stateSpeaking,
    required this.success,
    required this.warning,
    required this.error,
    required this.background,
    required this.surface,
    required this.surfaceContainer,
    required this.textPrimary,
    required this.textSecondary,
    required this.textTertiary,
    required this.glassBorder,
    required this.primary,
    required this.onPrimary,
  });

  factory KaiColors.light() {
    const oceanPrimary = Color(0xFF0284C7);
    const oceanLight = Color(0xFFE0F2FE);
    const oceanDark = Color(0xFF0C4A6E);

    const slateDark = Color(0xFF191919);
    const slateMedium = Color(0xFF262625);
    const slateLight = Color(0xFF40403E);

    const cloudDark = Color(0xFF666663);
    const cloudMedium = Color(0xFF91918D);
    const cloudLight = Color(0xFFBFBFBA);

    const ivoryDark = Color(0xFFE5E4DF);
    const ivoryMedium = Color(0xFFF0F0EB);
    const ivoryLight = Color(0xFFFAFAF7);

    return const KaiColors(
      oceanPrimary: oceanPrimary,
      oceanLight: oceanLight,
      oceanDark: oceanDark,
      slateDark: slateDark,
      slateMedium: slateMedium,
      slateLight: slateLight,
      cloudDark: cloudDark,
      cloudMedium: cloudMedium,
      cloudLight: cloudLight,
      ivoryDark: ivoryDark,
      ivoryMedium: ivoryMedium,
      ivoryLight: ivoryLight,

      stateListening: Color(0xFF06B6D4), // Cyan
      stateThinking: Color(0xFF8B5CF6), // Violet
      stateSpeaking: Color(0xFF14B8A6), // Teal

      success: Color(0xFF10B981), // Emerald
      warning: Color(0xFFF59E0B),
      error: Color(0xFFBF4D43), // Figma Error

      background: ivoryMedium,
      surface: ivoryLight,
      surfaceContainer: ivoryDark,

      textPrimary: slateDark,
      textSecondary: slateMedium,
      textTertiary: cloudDark,

      glassBorder: Color(0x1A191919), // 10% slate dark
      primary: oceanPrimary,
      onPrimary: ivoryLight,
    );
  }

  factory KaiColors.dark() {
    const oceanPrimary = Color(0xFF0EA5E9);
    const oceanLight = Color(0xFFE0F2FE);
    const oceanDark = Color(0xFF0C4A6E);

    const slateDark = Color(0xFF191919);
    const slateMedium = Color(0xFF262625);
    const slateLight = Color(0xFF40403E);

    const cloudDark = Color(0xFF666663);
    const cloudMedium = Color(0xFF91918D);
    const cloudLight = Color(0xFFBFBFBA);

    const ivoryDark = Color(0xFFE5E4DF);
    const ivoryMedium = Color(0xFFF0F0EB);
    const ivoryLight = Color(0xFFFAFAF7);

    return const KaiColors(
      oceanPrimary: oceanPrimary,
      oceanLight: oceanLight,
      oceanDark: oceanDark,
      slateDark: slateDark,
      slateMedium: slateMedium,
      slateLight: slateLight,
      cloudDark: cloudDark,
      cloudMedium: cloudMedium,
      cloudLight: cloudLight,
      ivoryDark: ivoryDark,
      ivoryMedium: ivoryMedium,
      ivoryLight: ivoryLight,

      stateListening: Color(0xFF22D3EE),
      stateThinking: Color(0xFFA78BFA),
      stateSpeaking: Color(0xFF2DD4BF),

      success: Color(0xFF34D399),
      warning: Color(0xFFFBBF24),
      error: Color(0xFFBF4D43),

      background: slateDark,
      surface: slateMedium,
      surfaceContainer: slateLight,

      textPrimary: ivoryLight,
      textSecondary: ivoryMedium,
      textTertiary: cloudLight,

      glassBorder: Color(0x1AFAFAF7), // 10% ivory light
      primary: oceanPrimary,
      onPrimary: slateDark,
    );
  }

  @override
  ThemeExtension<KaiColors> copyWith({
    Color? oceanPrimary,
    Color? oceanLight,
    Color? oceanDark,
    Color? slateDark,
    Color? slateMedium,
    Color? slateLight,
    Color? cloudDark,
    Color? cloudMedium,
    Color? cloudLight,
    Color? ivoryDark,
    Color? ivoryMedium,
    Color? ivoryLight,
    Color? stateListening,
    Color? stateThinking,
    Color? stateSpeaking,
    Color? success,
    Color? warning,
    Color? error,
    Color? background,
    Color? surface,
    Color? surfaceContainer,
    Color? textPrimary,
    Color? textSecondary,
    Color? textTertiary,
    Color? glassBorder,
    Color? primary,
    Color? onPrimary,
  }) {
    return KaiColors(
      oceanPrimary: oceanPrimary ?? this.oceanPrimary,
      oceanLight: oceanLight ?? this.oceanLight,
      oceanDark: oceanDark ?? this.oceanDark,
      slateDark: slateDark ?? this.slateDark,
      slateMedium: slateMedium ?? this.slateMedium,
      slateLight: slateLight ?? this.slateLight,
      cloudDark: cloudDark ?? this.cloudDark,
      cloudMedium: cloudMedium ?? this.cloudMedium,
      cloudLight: cloudLight ?? this.cloudLight,
      ivoryDark: ivoryDark ?? this.ivoryDark,
      ivoryMedium: ivoryMedium ?? this.ivoryMedium,
      ivoryLight: ivoryLight ?? this.ivoryLight,
      stateListening: stateListening ?? this.stateListening,
      stateThinking: stateThinking ?? this.stateThinking,
      stateSpeaking: stateSpeaking ?? this.stateSpeaking,
      success: success ?? this.success,
      warning: warning ?? this.warning,
      error: error ?? this.error,
      background: background ?? this.background,
      surface: surface ?? this.surface,
      surfaceContainer: surfaceContainer ?? this.surfaceContainer,
      textPrimary: textPrimary ?? this.textPrimary,
      textSecondary: textSecondary ?? this.textSecondary,
      textTertiary: textTertiary ?? this.textTertiary,
      glassBorder: glassBorder ?? this.glassBorder,
      primary: primary ?? this.primary,
      onPrimary: onPrimary ?? this.onPrimary,
    );
  }

  @override
  ThemeExtension<KaiColors> lerp(ThemeExtension<KaiColors>? other, double t) {
    if (other is! KaiColors) return this;
    return KaiColors(
      oceanPrimary: Color.lerp(oceanPrimary, other.oceanPrimary, t)!,
      oceanLight: Color.lerp(oceanLight, other.oceanLight, t)!,
      oceanDark: Color.lerp(oceanDark, other.oceanDark, t)!,
      slateDark: Color.lerp(slateDark, other.slateDark, t)!,
      slateMedium: Color.lerp(slateMedium, other.slateMedium, t)!,
      slateLight: Color.lerp(slateLight, other.slateLight, t)!,
      cloudDark: Color.lerp(cloudDark, other.cloudDark, t)!,
      cloudMedium: Color.lerp(cloudMedium, other.cloudMedium, t)!,
      cloudLight: Color.lerp(cloudLight, other.cloudLight, t)!,
      ivoryDark: Color.lerp(ivoryDark, other.ivoryDark, t)!,
      ivoryMedium: Color.lerp(ivoryMedium, other.ivoryMedium, t)!,
      ivoryLight: Color.lerp(ivoryLight, other.ivoryLight, t)!,
      stateListening: Color.lerp(stateListening, other.stateListening, t)!,
      stateThinking: Color.lerp(stateThinking, other.stateThinking, t)!,
      stateSpeaking: Color.lerp(stateSpeaking, other.stateSpeaking, t)!,
      success: Color.lerp(success, other.success, t)!,
      warning: Color.lerp(warning, other.warning, t)!,
      error: Color.lerp(error, other.error, t)!,
      background: Color.lerp(background, other.background, t)!,
      surface: Color.lerp(surface, other.surface, t)!,
      surfaceContainer:
          Color.lerp(surfaceContainer, other.surfaceContainer, t)!,
      textPrimary: Color.lerp(textPrimary, other.textPrimary, t)!,
      textSecondary: Color.lerp(textSecondary, other.textSecondary, t)!,
      textTertiary: Color.lerp(textTertiary, other.textTertiary, t)!,
      glassBorder: Color.lerp(glassBorder, other.glassBorder, t)!,
      primary: Color.lerp(primary, other.primary, t)!,
      onPrimary: Color.lerp(onPrimary, other.onPrimary, t)!,
    );
  }
}
