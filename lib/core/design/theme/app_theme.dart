import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../tokens/kai_colors.dart';
import '../tokens/kai_radii.dart';
import '../tokens/kai_shadows.dart';
import '../tokens/kai_typography.dart';

class AppTheme {
  static ThemeData get light {
    final colors = KaiColors.light();
    final typography =
        KaiTypography.regular(colors.textPrimary, colors.textSecondary);
    final shadows = KaiShadows.light();

    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.light,
      colorScheme: ColorScheme.light(
        primary: colors.primary,
        surface: colors.surface,
        error: colors.error,
        onPrimary: colors.onPrimary,
        onSurface: colors.textPrimary,
      ),
      scaffoldBackgroundColor: colors.background,
      textTheme: GoogleFonts.interTextTheme(),
      extensions: [colors, typography, shadows],
      appBarTheme: AppBarTheme(
        centerTitle: true,
        backgroundColor: colors.background, // Solid background
        elevation: 0,
        scrolledUnderElevation: 0,
        iconTheme: IconThemeData(color: colors.textPrimary),
        titleTextStyle: typography.titleLarge,
      ),
      inputDecorationTheme: InputDecorationTheme(
        border: const OutlineInputBorder(
          borderRadius: KaiRadii.s,
          borderSide: BorderSide.none, // Minimalist: no borders
        ),
        enabledBorder: const OutlineInputBorder(
          borderRadius: KaiRadii.s,
          borderSide: BorderSide.none,
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: KaiRadii.s,
          borderSide: BorderSide(
              color: colors.primary,
              width: 2), // Only underline/border on focus
        ),
        filled: true,
        fillColor: colors.surfaceContainer, // Muted gray container
      ),
      cardTheme: CardThemeData(
        elevation: 0,
        color: colors.surfaceContainer, // Flat cards
        shape: const RoundedRectangleBorder(borderRadius: KaiRadii.card),
      ),
      bottomSheetTheme: BottomSheetThemeData(
        backgroundColor: colors.surfaceContainer, // Muted sheets
        elevation: 0,
        shape: const RoundedRectangleBorder(borderRadius: KaiRadii.bottomSheet),
      ),
    );
  }

  static ThemeData get dark {
    final colors = KaiColors.dark();
    final typography =
        KaiTypography.regular(colors.textPrimary, colors.textSecondary);
    final shadows = KaiShadows.dark();

    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.dark,
      colorScheme: ColorScheme.dark(
        primary: colors.primary,
        surface: colors.surface,
        error: colors.error,
        onPrimary: colors.onPrimary,
        onSurface: colors.textPrimary,
      ),
      scaffoldBackgroundColor: colors.background,
      textTheme: GoogleFonts.interTextTheme(
          ThemeData(brightness: Brightness.dark).textTheme),
      extensions: [colors, typography, shadows],
      appBarTheme: AppBarTheme(
        centerTitle: true,
        backgroundColor: colors.background,
        elevation: 0,
        scrolledUnderElevation: 0,
        iconTheme: IconThemeData(color: colors.textPrimary),
        titleTextStyle: typography.titleLarge,
      ),
      inputDecorationTheme: InputDecorationTheme(
        border: const OutlineInputBorder(
          borderRadius: KaiRadii.s,
          borderSide: BorderSide.none,
        ),
        enabledBorder: const OutlineInputBorder(
          borderRadius: KaiRadii.s,
          borderSide: BorderSide.none,
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: KaiRadii.s,
          borderSide: BorderSide(color: colors.primary, width: 2),
        ),
        filled: true,
        fillColor: colors.surfaceContainer,
      ),
      cardTheme: CardThemeData(
        elevation: 0,
        color: colors.surfaceContainer,
        shape: const RoundedRectangleBorder(borderRadius: KaiRadii.card),
      ),
      bottomSheetTheme: BottomSheetThemeData(
        backgroundColor: colors.surface,
        elevation: 0,
        shape: const RoundedRectangleBorder(borderRadius: KaiRadii.bottomSheet),
      ),
    );
  }
}
