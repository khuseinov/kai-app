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
    return KaiTheme(
      child: MaterialApp.router(
        debugShowCheckedModeBanner: false,
        title: 'KAI',
        themeMode: mode,
        theme: KaiThemeExt.materialLight(),
        darkTheme: KaiThemeExt.materialDark(),
        routerConfig: router,
      ),
    );
  }
}
