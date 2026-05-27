import 'package:flutter/material.dart';

import '../tokens/kai_tokens.dart';

/// Material `ThemeExtension` carrying [KaiColorTokens] for the active theme,
/// so any Material widget can read Kai tokens via
/// `Theme.of(context).extension<KaiThemeExt>()`.
class KaiThemeExt extends ThemeExtension<KaiThemeExt> {
  const KaiThemeExt({required this.colors});

  final KaiColorTokens colors;

  @override
  KaiThemeExt copyWith({KaiColorTokens? colors}) =>
      KaiThemeExt(colors: colors ?? this.colors);

  @override
  KaiThemeExt lerp(ThemeExtension<KaiThemeExt>? other, double t) {
    if (other is! KaiThemeExt) return this;
    // No interpolation between palettes — discrete switch.
    return t < 0.5 ? this : other;
  }

  /// Full Material `ThemeData` for light mode wired with KAI tokens.
  static ThemeData materialLight() => _buildMaterialTheme(
        tokens: KaiTokens.light,
        brightness: Brightness.light,
      );

  /// Full Material `ThemeData` for dark mode wired with KAI tokens.
  static ThemeData materialDark() => _buildMaterialTheme(
        tokens: KaiTokens.dark,
        brightness: Brightness.dark,
      );
}

ThemeData _buildMaterialTheme({
  required KaiTokens tokens,
  required Brightness brightness,
}) {
  final c = tokens.colors;
  final colorScheme = ColorScheme(
    brightness: brightness,
    primary: c.accent,
    onPrimary: brightness == Brightness.light
        ? const Color(0xFFFFFFFF)
        : const Color(0xFF0E0E11),
    secondary: c.accent,
    onSecondary: brightness == Brightness.light
        ? const Color(0xFFFFFFFF)
        : const Color(0xFF0E0E11),
    error: c.negative,
    onError: brightness == Brightness.light
        ? const Color(0xFFFFFFFF)
        : const Color(0xFF0E0E11),
    surface: c.surface,
    onSurface: c.ink1,
    surfaceContainerHighest: c.surface2,
    outline: c.line,
    outlineVariant: c.lineStrong,
  );

  return ThemeData(
    useMaterial3: true,
    brightness: brightness,
    colorScheme: colorScheme,
    scaffoldBackgroundColor: c.bg,
    canvasColor: c.bg,
    fontFamily: 'Manrope',
    extensions: <ThemeExtension<dynamic>>[
      KaiThemeExt(colors: c),
    ],
    appBarTheme: AppBarTheme(
      backgroundColor: c.bg,
      foregroundColor: c.ink1,
      elevation: 0,
      surfaceTintColor: Colors.transparent,
    ),
  );
}
