import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'core/providers/root.dart';
import 'core/routing/router.dart';
import 'design_system/theme/kai_theme.dart';
import 'design_system/theme/kai_theme_ext.dart';

class KaiApp extends ConsumerWidget {
  const KaiApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final router = ref.watch(routerProvider);
    final mode = ref.watch(themeModeProvider);
    return MaterialApp.router(
      debugShowCheckedModeBanner: false,
      title: 'KAI',
      themeMode: mode,
      theme: KaiThemeExt.materialLight(),
      darkTheme: KaiThemeExt.materialDark(),
      routerConfig: router,
      // KaiTheme sits inside MaterialApp so MediaQuery.platformBrightnessOf
      // (called from KaiTheme.build) has the MediaQuery ancestor MaterialApp
      // inserts. Outside MaterialApp it would throw on the first frame.
      builder: (context, child) =>
          KaiTheme(child: child ?? const SizedBox.shrink()),
    );
  }
}
