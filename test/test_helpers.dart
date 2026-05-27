import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:kai_app/core/providers/root.dart';
import 'package:kai_app/design_system/theme/kai_theme.dart';

/// Wraps [child] with [ProviderScope], [KaiTheme], [MediaQuery], and
/// [Scaffold] so that any design-system widget under test has full access to
/// tokens, theme, and layout constraints.
///
/// Pass [themeMode] to test dark-mode behaviour; defaults to [ThemeMode.light].
Widget buildTestWidget(
  Widget child, {
  ThemeMode themeMode = ThemeMode.light,
}) {
  return ProviderScope(
    overrides: <Override>[
      themeModeProvider.overrideWith((ref) => themeMode),
    ],
    child: MaterialApp(
      home: KaiTheme(
        child: Scaffold(body: child),
      ),
    ),
  );
}
