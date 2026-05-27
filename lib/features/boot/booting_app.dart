import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../app.dart';
import '../../bootstrap.dart';
import '../../design_system/theme/kai_theme.dart';
import 'splash_screen.dart';

/// App entry point — shows the Kai splash while [bootstrap] runs, then swaps
/// in the real [KaiApp] when the provider container is ready.
///
/// Three phases:
/// - `bootstrap` in flight → `SplashScreen` over a temporary `ProviderScope`
///   (the splash needs a scope so `KaiTheme.of` can read `themeModeProvider`).
/// - `bootstrap` returned → real `KaiApp` mounted under the resolved
///   `UncontrolledProviderScope` so providers built during boot stay live.
/// - `bootstrap` threw → minimal error surface; this is a fast-fail. We do
///   not retry because the only known failure (corrupted Hive) is not
///   recoverable from the UI layer.
class BootingApp extends StatefulWidget {
  const BootingApp({super.key});

  @override
  State<BootingApp> createState() => _BootingAppState();
}

class _BootingAppState extends State<BootingApp> {
  ProviderContainer? _container;
  Object? _error;

  @override
  void initState() {
    super.initState();
    _start();
  }

  Future<void> _start() async {
    try {
      final container = await bootstrap();
      if (!mounted) {
        container.dispose();
        return;
      }
      setState(() => _container = container);
    } catch (e) {
      if (!mounted) return;
      setState(() => _error = e);
    }
  }

  @override
  void dispose() {
    _container?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (_error != null) {
      return MaterialApp(
        debugShowCheckedModeBanner: false,
        home: Scaffold(
          body: Center(
            child: Padding(
              padding: const EdgeInsets.all(24),
              child: Text(
                'Boot error: $_error',
                style: const TextStyle(fontFamily: 'Manrope'),
                textAlign: TextAlign.center,
              ),
            ),
          ),
        ),
      );
    }
    if (_container == null) {
      // Splash phase — temporary ProviderScope so KaiTheme can read
      // themeModeProvider. This scope is discarded when bootstrap returns;
      // the real container takes over.
      return const ProviderScope(
        child: MaterialApp(
          debugShowCheckedModeBanner: false,
          home: KaiTheme(child: SplashScreen()),
        ),
      );
    }
    return UncontrolledProviderScope(
      container: _container!,
      child: const KaiApp(),
    );
  }
}
