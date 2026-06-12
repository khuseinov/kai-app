import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'design_system/theme/kai_theme.dart';
import 'design_system/theme/kai_theme_ext.dart';
import 'features/dev/storybook/storybook_screen.dart';
import 'l10n/app_localizations.dart';

/// Standalone entry point for the Flutter Storybook.
///
/// Run with:
///   flutter run -d chrome -t lib/main_storybook.dart
void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  runApp(
    ProviderScope(
      child: MaterialApp(
        debugShowCheckedModeBanner: false,
        title: 'KAI Storybook',
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        supportedLocales: AppLocalizations.supportedLocales,
        theme: KaiThemeExt.materialLight(),
        darkTheme: KaiThemeExt.materialDark(),
        builder: (context, child) {
          final mediaQuery = MediaQuery.of(context);
          return MediaQuery(
            data: mediaQuery.copyWith(
              textScaler: mediaQuery.textScaler.clamp(minScaleFactor: 1.0),
            ),
            child: KaiTheme(child: child ?? const SizedBox.shrink()),
          );
        },
        home: const StorybookScreen(),
      ),
    ),
  );
}
