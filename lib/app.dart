import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:kai_app/core/providers/root.dart';
import 'package:kai_app/core/routing/router.dart';
import 'package:kai_app/design_system/theme/kai_theme.dart';
import 'package:kai_app/design_system/theme/kai_theme_ext.dart';
import 'package:kai_app/l10n/app_localizations.dart';

class KaiApp extends ConsumerWidget {
  const KaiApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final router = ref.watch(routerProvider);
    final mode = ref.watch(themeModeProvider);
    return MaterialApp.router(
      debugShowCheckedModeBanner: false,
      title: 'KAI',
      localizationsDelegates: AppLocalizations.localizationsDelegates,
      supportedLocales: AppLocalizations.supportedLocales,
      themeMode: mode,
      theme: KaiThemeExt.materialLight(),
      darkTheme: KaiThemeExt.materialDark(),
      routerConfig: router,
      // KaiTheme sits inside MaterialApp so MediaQuery.platformBrightnessOf
      // (called from KaiTheme.build) has the MediaQuery ancestor MaterialApp
      // inserts. Outside MaterialApp it would throw on the first frame.
      builder: (context, child) {
        final mediaQuery = MediaQuery.of(context);
        return MediaQuery(
          data: mediaQuery.copyWith(
            textScaler: mediaQuery.textScaler.clamp(
              minScaleFactor: 1,
            ),
          ),
          child: KaiTheme(child: child ?? const SizedBox.shrink()),
        );
      },
    );
  }
}
