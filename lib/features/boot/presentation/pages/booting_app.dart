import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:kai_app/app.dart';
import 'package:kai_app/bootstrap.dart';
import 'package:kai_app/design_system/theme/kai_theme.dart';
import 'package:kai_app/features/boot/presentation/pages/splash_screen.dart';
import 'package:kai_app/features/boot/presentation/widgets/splash_config.dart';

/// App entry point — runs [bootstrap] in the background and mounts the real
/// [KaiApp] as soon as the provider container is ready.
///
/// While bootstrap is in flight the canonical [SplashScreen] is shown. Once
/// [bootstrap] completes we enforce a minimum visible duration so the splash
/// lockup pulse is always seen, then cross-fade to the real app.
///
/// If [bootstrap] throws, a minimal error surface is shown; this is a fast-fail.
/// We do not retry because the only known failure (corrupted Hive) is not
/// recoverable from the UI layer.
class BootingApp extends StatefulWidget {
  const BootingApp({
    this.bootstrap,
    this.minSplashVisibleDuration = kSplashMinVisibleDuration,
    super.key,
  });

  /// Initialization routine. Overridable for widget tests.
  final Future<ProviderContainer> Function()? bootstrap;

  /// Minimum time the splash screen should remain visible on a cold start.
  /// Overridable for widget tests.
  final Duration minSplashVisibleDuration;

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
    final start = DateTime.now();
    try {
      final container = await (widget.bootstrap ?? bootstrap)();

      // Enforce the minimum splash-visible duration so the lockup pulse is
      // never skipped, even on a fast device.
      final elapsed = DateTime.now().difference(start);
      final remaining = widget.minSplashVisibleDuration - elapsed;
      if (remaining > Duration.zero && mounted) {
        await Future<void>.delayed(remaining);
      }

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

    return ProviderScope(
      child: MaterialApp(
        debugShowCheckedModeBanner: false,
        builder: (context, child) {
          final mediaQuery = MediaQuery.of(context);
          return MediaQuery(
            data: mediaQuery.copyWith(
              textScaler: mediaQuery.textScaler.clamp(
                minScaleFactor: 1,
              ),
            ),
            child: child!,
          );
        },
        home: KaiTheme(
          child: Builder(
            builder: (context) {
              final bg = KaiTheme.of(context).colors.bg;
              return ColoredBox(
                color: bg,
                child: AnimatedSwitcher(
                  duration: kSplashCrossFadeDuration,
                  switchInCurve: Curves.easeInOut,
                  switchOutCurve: Curves.easeInOut,
                  child: _container == null
                      ? const _SplashShell(key: ValueKey('splash'))
                      : UncontrolledProviderScope(
                          container: _container!,
                          child: const KaiApp(key: ValueKey('app')),
                        ),
                ),
              );
            },
          ),
        ),
      ),
    );
  }
}

/// Wraps the canonical splash in a [Scaffold] so the text widgets get a
/// [Material] ancestor. Without this, MaterialApp's debug fallback paints a
/// yellow underline under any text that lacks a Material/Scaffold parent.
class _SplashShell extends StatelessWidget {
  const _SplashShell({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: KaiTheme.of(context).colors.bg,
      body: const SplashScreen(),
    );
  }
}
