import 'package:flutter/material.dart';
import '../tokens/kai_colors.dart';
import '../tokens/kai_radii.dart';
import '../tokens/kai_shadows.dart';
import '../tokens/kai_typography.dart';
import 'theme_extensions.dart'; // To ensure we can use extensions if needed internally

class AppTheme {
  static ThemeData get light {
    final colors = KaiColors.light();
    final typography = KaiTypography.regular(colors.textPrimary, colors.textSecondary);
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
      fontFamily: 'Google Sans', // Switched to Google's preferred font style
      extensions: [colors, typography, shadows],
      
      // Override basic Material components to match Google Minimalism
      appBarTheme: AppBarTheme(
        centerTitle: true,
        backgroundColor: colors.background, // Solid background, no glass
        elevation: 0,
        scrolledUnderElevation: 0, // Material 3 disable scroll shadow
        iconTheme: IconThemeData(color: colors.textPrimary),
        titleTextStyle: typography.titleLarge,
      ),
      
      inputDecorationTheme: InputDecorationTheme(
        border: OutlineInputBorder(
          borderRadius: KaiRadii.s,
          borderSide: BorderSide.none, // Minimalist: no borders
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: KaiRadii.s,
          borderSide: BorderSide.none,
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: KaiRadii.s,
          borderSide: BorderSide(color: colors.primary, width: 2), // Only underline/border on focus
        ),
        filled: true,
        fillColor: colors.surfaceContainer, // Muted gray container
      ),
      
      cardTheme: CardThemeData(
        elevation: 0,
        color: colors.surfaceContainer, // Flat cards
        shape: RoundedRectangleBorder(borderRadius: KaiRadii.card),
      ),
      
      bottomSheetTheme: BottomSheetThemeData(
        backgroundColor: colors.surfaceContainer, // Muted sheets
        elevation: 0,
        shape: RoundedRectangleBorder(borderRadius: KaiRadii.bottomSheet),
      ),
    );
  }

  static ThemeData get dark {
    final colors = KaiColors.dark();
    final typography = KaiTypography.regular(colors.textPrimary, colors.textSecondary);
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
      scaffoldBackgroundColor: colors.background, // Pure OLED black
      fontFamily: 'Google Sans', // Switched from SF Pro to match Google vibe
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
        border: OutlineInputBorder(
          borderRadius: KaiRadii.s,
          borderSide: BorderSide.none,
        ),
        enabledBorder: OutlineInputBorder(
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
        shape: RoundedRectangleBorder(borderRadius: KaiRadii.card),
      ),

      bottomSheetTheme: BottomSheetThemeData(
        backgroundColor: colors.surface,
        shape: RoundedRectangleBorder(borderRadius: KaiRadii.bottomSheet),
      ),
    );
  }
}
