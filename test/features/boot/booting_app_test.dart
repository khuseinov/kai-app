import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:kai_app/app.dart';
import 'package:kai_app/core/routing/router.dart';
import 'package:kai_app/features/boot/presentation/pages/booting_app.dart';
import 'package:kai_app/features/boot/presentation/pages/splash_screen.dart';

void main() {
  group('BootingApp', () {
    Future<ProviderContainer> fakeBootstrap() async {
      // Simulate a realistic async init without touching Hive/files.
      await Future<void>.delayed(const Duration(milliseconds: 50));
      return ProviderContainer(
        overrides: [
          routerProvider.overrideWithValue(
            GoRouter(
              routes: [
                GoRoute(
                  path: '/',
                  builder: (_, __) => const SizedBox.shrink(),
                ),
              ],
            ),
          ),
        ],
      );
    }

    testWidgets('shows SplashScreen while bootstrapping then switches to KaiApp',
        (tester) async {
      // Disable tickers so the looping splash animation does not prevent
      // pumpAndSettle from completing.
      await tester.pumpWidget(
        TickerMode(
          enabled: false,
          child: BootingApp(
            bootstrap: fakeBootstrap,
            minSplashVisibleDuration: Duration.zero,
          ),
        ),
      );

      // First frame shows the canonical splash.
      expect(find.byType(SplashScreen), findsOneWidget);

      // Advance time until the fake bootstrap finishes and the cross-fade ends.
      await tester.pumpAndSettle();

      // The AnimatedSwitcher has switched to the real app branch.
      final switcher = tester.widget<AnimatedSwitcher>(
        find.byType(AnimatedSwitcher),
      );
      expect(switcher.child, isA<UncontrolledProviderScope>());
      expect(
        (switcher.child! as UncontrolledProviderScope).child,
        isA<KaiApp>(),
      );
    });

    testWidgets('still shows splash after a short pump', (tester) async {
      await tester.pumpWidget(
        TickerMode(
          enabled: false,
          child: BootingApp(
            bootstrap: fakeBootstrap,
            minSplashVisibleDuration: Duration.zero,
          ),
        ),
      );
      await tester.pump(const Duration(milliseconds: 100));
      expect(find.byType(SplashScreen), findsOneWidget);
    });
  });
}
