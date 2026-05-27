import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/providers/root.dart';
import '../tokens/kai_tokens.dart';

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
  const KaiTheme({super.key, required this.child});

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
