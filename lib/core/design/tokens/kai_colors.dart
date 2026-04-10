import 'package:flutter/material.dart';

/// Define semantic color tokens for Kai App
class KaiColors extends ThemeExtension<KaiColors> {
  // Brand / Accents
  final Color primary;
  final Color onPrimary;
  
  // Voice & 3D Visualizer States (For Canvas Background)
  final Color stateListening;
  final Color stateThinking;
  final Color stateSpeaking;
  
  // Backgrounds (Pure Minimalism)
  final Color background;
  final Color surface;
  final Color surfaceContainer;
  
  // Text
  final Color textPrimary;
  final Color textSecondary;
  final Color textTertiary;

  // Glassmorphism
  final Color glassBorder;

  // Semantic
  final Color success;
  final Color warning;
  final Color error;

  const KaiColors({
    required this.primary,
    required this.onPrimary,
    required this.stateListening,
    required this.stateThinking,
    required this.stateSpeaking,
    required this.background,
    required this.surface,
    required this.surfaceContainer,
    required this.textPrimary,
    required this.textSecondary,
    required this.textTertiary,
    required this.glassBorder,
    required this.success,
    required this.warning,
    required this.error,
  });

  /// Light Theme Implementation
  factory KaiColors.light() {
    return const KaiColors(
      primary: Color(0xFF0F172A), // Almost black for high contrast elements
      onPrimary: Color(0xFFFFFFFF),
      stateListening: Color(0xFF06B6D4), // Cyan
      stateThinking: Color(0xFF8B5CF6), // Violet
      stateSpeaking: Color(0xFF14B8A6), // Teal
      background: Color(0xFFFFFFFF), // Pure white canvas
      surface: Color(0xFFFFFFFF),    // Pure white components
      surfaceContainer: Color(0xFFF3F4F6), // Very light gray for bottom sheets
      textPrimary: Color(0xFF111827), // Near black
      textSecondary: Color(0xFF4B5563), // Medium gray
      textTertiary: Color(0xFF9CA3AF),  // Light gray
      glassBorder: Color(0x1A000000), // 10% black for subtle glass border
      success: Color(0xFF10B981),
      warning: Color(0xFFF59E0B),
      error: Color(0xFFEF4444),
    );
  }

  /// Dark Theme Implementation
  factory KaiColors.dark() {
    return const KaiColors(
      primary: Color(0xFFFFFFFF), // Pure white for high contrast
      onPrimary: Color(0xFF000000),
      stateListening: Color(0xFF22D3EE),
      stateThinking: Color(0xFFA78BFA),
      stateSpeaking: Color(0xFF2DD4BF),
      background: Color(0xFF000000), // Pure black canvas (OLED friendly)
      surface: Color(0xFF000000),    // Pure black components
      surfaceContainer: Color(0xFF131314), // Dark gray for sheets (Gemini style)
      textPrimary: Color(0xFFF9FAFB),
      textSecondary: Color(0xFF9CA3AF),
      textTertiary: Color(0xFF4B5563),
      glassBorder: Color(0x1AFFFFFF), // 10% white for subtle glass border
      success: Color(0xFF34D399),
      warning: Color(0xFFFBBF24),
      error: Color(0xFFF87171),
    );
  }

  @override
  ThemeExtension<KaiColors> copyWith({
    Color? primary,
    Color? onPrimary,
    Color? stateListening,
    Color? stateThinking,
    Color? stateSpeaking,
    Color? background,
    Color? surface,
    Color? surfaceContainer,
    Color? textPrimary,
    Color? textSecondary,
    Color? textTertiary,
    Color? glassBorder,
    Color? success,
    Color? warning,
    Color? error,
  }) {
    return KaiColors(
      primary: primary ?? this.primary,
      onPrimary: onPrimary ?? this.onPrimary,
      stateListening: stateListening ?? this.stateListening,
      stateThinking: stateThinking ?? this.stateThinking,
      stateSpeaking: stateSpeaking ?? this.stateSpeaking,
      background: background ?? this.background,
      surface: surface ?? this.surface,
      surfaceContainer: surfaceContainer ?? this.surfaceContainer,
      textPrimary: textPrimary ?? this.textPrimary,
      textSecondary: textSecondary ?? this.textSecondary,
      textTertiary: textTertiary ?? this.textTertiary,
      glassBorder: glassBorder ?? this.glassBorder,
      success: success ?? this.success,
      warning: warning ?? this.warning,
      error: error ?? this.error,
    );
  }

  @override
  ThemeExtension<KaiColors> lerp(
    covariant ThemeExtension<KaiColors>? other,
    double t,
  ) {
    if (other is! KaiColors) {
      return this;
    }
    return KaiColors(
      primary: Color.lerp(primary, other.primary, t)!,
      onPrimary: Color.lerp(onPrimary, other.onPrimary, t)!,
      stateListening: Color.lerp(stateListening, other.stateListening, t)!,
      stateThinking: Color.lerp(stateThinking, other.stateThinking, t)!,
      stateSpeaking: Color.lerp(stateSpeaking, other.stateSpeaking, t)!,
      background: Color.lerp(background, other.background, t)!,
      surface: Color.lerp(surface, other.surface, t)!,
      surfaceContainer: Color.lerp(surfaceContainer, other.surfaceContainer, t)!,
      textPrimary: Color.lerp(textPrimary, other.textPrimary, t)!,
      textSecondary: Color.lerp(textSecondary, other.textSecondary, t)!,
      textTertiary: Color.lerp(textTertiary, other.textTertiary, t)!,
      glassBorder: Color.lerp(glassBorder, other.glassBorder, t)!,
      success: Color.lerp(success, other.success, t)!,
      warning: Color.lerp(warning, other.warning, t)!,
      error: Color.lerp(error, other.error, t)!,
    );
  }
}
