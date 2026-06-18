import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:kai_app/core/providers/root.dart';
import 'package:kai_app/design_system/theme/kai_theme.dart';
import 'package:kai_app/l10n/app_localizations.dart';

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
      themeModeProvider.overrideWith(() => MockThemeModeNotifier(themeMode)),
    ],
    child: MaterialApp(
      localizationsDelegates: AppLocalizations.localizationsDelegates,
      supportedLocales: const [Locale('ru'), Locale('en')],
      locale: const Locale('ru'),
      home: Builder(
        builder: (context) {
          final data = MediaQuery.of(context);
          return MediaQuery(
            data: data.copyWith(
              size: const Size(360, 640),
            ),
            child: KaiTheme(
              child: Scaffold(body: child),
            ),
          );
        },
      ),
    ),
  );
}

class MockThemeModeNotifier extends ThemeModeNotifier {
  MockThemeModeNotifier(this._initialMode);
  final ThemeMode _initialMode;
  @override
  ThemeMode build() => _initialMode;
}
