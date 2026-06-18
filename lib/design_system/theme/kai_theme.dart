import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:kai_app/core/providers/root.dart';
import 'package:kai_app/design_system/tokens/kai_tokens.dart';

/// Resolves Brightness from ThemeMode + system brightness.
Brightness _resolveBrightness(ThemeMode mode, Brightness systemBrightness) {
  switch (mode) {
    case ThemeMode.light:
      return Brightness.light;
    case ThemeMode.dark:
      return Brightness.dark;
    case ThemeMode.system:
      return systemBrightness;
  }
}

/// Exposes [KaiTokens] resolved for the current theme via InheritedWidget.
///
/// Subscribe via `KaiTheme.of(context).colors.bg` (etc).
/// Mounted high in the tree, above MaterialApp. Reads themeMode from Riverpod.
class KaiTheme extends ConsumerWidget {
  const KaiTheme({required this.child, super.key});

  final Widget child;

  /// Resolve tokens for the calling context.
  static KaiTokens of(BuildContext context) {
    final inherited =
        context.dependOnInheritedWidgetOfExactType<_KaiThemeScope>();
    assert(inherited != null, 'KaiTheme.of called outside a KaiTheme');
    return inherited!.tokens;
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final mode = ref.watch(themeModeProvider);
    final systemBrightness = MediaQuery.platformBrightnessOf(context);
    final brightness = _resolveBrightness(mode, systemBrightness);
    final tokens =
        brightness == Brightness.dark ? KaiTokens.dark : KaiTokens.light;
    return _KaiThemeScope(tokens: tokens, child: child);
  }
}

class _KaiThemeScope extends InheritedWidget {
  const _KaiThemeScope({required this.tokens, required super.child});

  final KaiTokens tokens;

  @override
  bool updateShouldNotify(_KaiThemeScope oldWidget) =>
      tokens != oldWidget.tokens;
}

extension KaiScaleExtension on BuildContext {
  /// Resolves the visual scale factor for layout offsets, paddings, and margins.
  ///
  /// Clamped to [0.95, 1.10] to allow compacting on small screens but prevent
  /// huge empty gaps on large tablets/desktops.
  double get scale {
    final s = MediaQuery.sizeOf(this).shortestSide;
    final scaleFactor = switch (s) {
      < 360 => 0.95,
      < 430 => 1.00,
      < 600 => 1.05,
      _ => 1.10,
    };
    return scaleFactor.clamp(0.95, 1.10);
  }

  /// Resolves the scale factor specifically for font sizes.
  ///
  /// Never drops below 1.0 to prevent illegibly small/tiny text on small viewports.
  /// Caps at 1.10 to prevent oversized letters.
  double get textScale => scale.clamp(1.0, 1.10);
}

