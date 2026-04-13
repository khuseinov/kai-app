import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

// Define typography tokens for Kai App following Anthropic Foundation
class KaiTypography extends ThemeExtension<KaiTypography> {
  final TextStyle displayLarge;
  final TextStyle displayMedium;
  final TextStyle displaySmall;
  final TextStyle headlineLarge;
  final TextStyle headlineMedium;
  final TextStyle headlineSmall;
  final TextStyle titleLarge;
  final TextStyle titleMedium;
  final TextStyle titleSmall;
  final TextStyle bodyLarge;
  final TextStyle bodyMedium;
  final TextStyle bodySmall;
  final TextStyle labelLarge;
  final TextStyle labelMedium;
  final TextStyle labelSmall;

  const KaiTypography({
    required this.displayLarge,
    required this.displayMedium,
    required this.displaySmall,
    required this.headlineLarge,
    required this.headlineMedium,
    required this.headlineSmall,
    required this.titleLarge,
    required this.titleMedium,
    required this.titleSmall,
    required this.bodyLarge,
    required this.bodyMedium,
    required this.bodySmall,
    required this.labelLarge,
    required this.labelMedium,
    required this.labelSmall,
  });

  factory KaiTypography.regular(Color textPrimary, Color textSecondary) {
    return KaiTypography(
      // Display: Copernicus Fallback (Playfair Display)
      displayLarge: GoogleFonts.playfairDisplay(
          fontSize: 57,
          fontWeight: FontWeight.w400,
          letterSpacing: -0.25,
          color: textPrimary),
      displayMedium: GoogleFonts.playfairDisplay(
          fontSize: 45, fontWeight: FontWeight.w400, color: textPrimary),
      displaySmall: GoogleFonts.playfairDisplay(
          fontSize: 36, fontWeight: FontWeight.w400, color: textPrimary),

      // Headline: Tiempos Fallback (Merriweather)
      headlineLarge: GoogleFonts.merriweather(
          fontSize: 32, fontWeight: FontWeight.w500, color: textPrimary),
      headlineMedium: GoogleFonts.merriweather(
          fontSize: 28, fontWeight: FontWeight.w500, color: textPrimary),
      headlineSmall: GoogleFonts.merriweather(
          fontSize: 24, fontWeight: FontWeight.w500, color: textPrimary),

      // Title: Tiempos Fallback (Merriweather)
      titleLarge: GoogleFonts.merriweather(
          fontSize: 22, fontWeight: FontWeight.w600, color: textPrimary),
      titleMedium: GoogleFonts.merriweather(
          fontSize: 16,
          fontWeight: FontWeight.w600,
          letterSpacing: 0.15,
          color: textPrimary),
      titleSmall: GoogleFonts.merriweather(
          fontSize: 14,
          fontWeight: FontWeight.w600,
          letterSpacing: 0.1,
          color: textPrimary),

      // Body: Styrene Fallback (Inter)
      bodyLarge: GoogleFonts.inter(
          fontSize: 16,
          fontWeight: FontWeight.w400,
          letterSpacing: 0.15,
          color: textSecondary),
      bodyMedium: GoogleFonts.inter(
          fontSize: 14,
          fontWeight: FontWeight.w400,
          letterSpacing: 0.25,
          color: textSecondary),
      bodySmall: GoogleFonts.inter(
          fontSize: 12,
          fontWeight: FontWeight.w400,
          letterSpacing: 0.4,
          color: textSecondary),

      // Label: Styrene Fallback (Inter)
      labelLarge: GoogleFonts.inter(
          fontSize: 14,
          fontWeight: FontWeight.w500,
          letterSpacing: 0.1,
          color: textPrimary),
      labelMedium: GoogleFonts.inter(
          fontSize: 12,
          fontWeight: FontWeight.w500,
          letterSpacing: 0.5,
          color: textPrimary),
      labelSmall: GoogleFonts.inter(
          fontSize: 11,
          fontWeight: FontWeight.w500,
          letterSpacing: 0.5,
          color: textPrimary),
    );
  }

  @override
  ThemeExtension<KaiTypography> copyWith() {
    return this;
  }

  @override
  ThemeExtension<KaiTypography> lerp(
      ThemeExtension<KaiTypography>? other, double t) {
    if (other is! KaiTypography) {
      return this;
    }
    return KaiTypography(
      displayLarge: TextStyle.lerp(displayLarge, other.displayLarge, t)!,
      displayMedium: TextStyle.lerp(displayMedium, other.displayMedium, t)!,
      displaySmall: TextStyle.lerp(displaySmall, other.displaySmall, t)!,
      headlineLarge: TextStyle.lerp(headlineLarge, other.headlineLarge, t)!,
      headlineMedium: TextStyle.lerp(headlineMedium, other.headlineMedium, t)!,
      headlineSmall: TextStyle.lerp(headlineSmall, other.headlineSmall, t)!,
      titleLarge: TextStyle.lerp(titleLarge, other.titleLarge, t)!,
      titleMedium: TextStyle.lerp(titleMedium, other.titleMedium, t)!,
      titleSmall: TextStyle.lerp(titleSmall, other.titleSmall, t)!,
      bodyLarge: TextStyle.lerp(bodyLarge, other.bodyLarge, t)!,
      bodyMedium: TextStyle.lerp(bodyMedium, other.bodyMedium, t)!,
      bodySmall: TextStyle.lerp(bodySmall, other.bodySmall, t)!,
      labelLarge: TextStyle.lerp(labelLarge, other.labelLarge, t)!,
      labelMedium: TextStyle.lerp(labelMedium, other.labelMedium, t)!,
      labelSmall: TextStyle.lerp(labelSmall, other.labelSmall, t)!,
    );
  }
}
