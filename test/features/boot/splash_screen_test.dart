import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:kai_app/design_system/atoms/atoms.dart';
import 'package:kai_app/features/boot/splash_screen.dart';

import '../../test_helpers.dart';

/// Fixed iPhone-style viewport for golden screenshots.
Widget _frame(Widget child) {
  return Center(
    child: SizedBox(
      width: 390,
      height: 844,
      child: child,
    ),
  );
}

void main() {
  group('SplashScreen', () {
    testWidgets('renders logo, wordmark and tagline', (tester) async {
      await tester.pumpWidget(buildTestWidget(const SplashScreen()));

      expect(find.byType(KaiLogo), findsOneWidget);
      expect(find.text('kai'), findsOneWidget);
      expect(find.text('ваш компаньон путешественника'), findsOneWidget);
    });

    testWidgets('adapts to dark mode', (tester) async {
      await tester.pumpWidget(
        buildTestWidget(
          const SplashScreen(),
          themeMode: ThemeMode.dark,
        ),
      );

      expect(find.byType(KaiLogo), findsOneWidget);
      expect(find.text('kai'), findsOneWidget);
    });

    testWidgets('loops glyph pulse and fades in text', (tester) async {
      await tester.pumpWidget(buildTestWidget(const SplashScreen()));

      final state = tester.state<SplashScreenState>(find.byType(SplashScreen));
      expect(state.pulseController.isAnimating, isTrue);
      expect(state.pulseController.status, AnimationStatus.forward);
      expect(state.fadeController.isAnimating, isTrue);
      expect(state.fadeController.status, AnimationStatus.forward);

      // Advance to the end of one pulse cycle; the controller should still be
      // animating because it loops.
      await tester.pump(const Duration(milliseconds: 2400));
      expect(state.pulseController.isAnimating, isTrue);

      // Text fade completes.
      await tester.pump(const Duration(milliseconds: 600));
      expect(state.fadeController.isCompleted, isTrue);
    });

    testWidgets('keeps controllers idle when animations are disabled',
        (tester) async {
      await tester.pumpWidget(
        MediaQuery(
          data: const MediaQueryData(disableAnimations: true),
          child: buildTestWidget(const SplashScreen()),
        ),
      );

      final state = tester.state<SplashScreenState>(find.byType(SplashScreen));
      expect(state.pulseController.isAnimating, isFalse);
      expect(state.fadeController.isAnimating, isFalse);
      expect(state.fadeController.value, 0.0);
    });

    testWidgets('golden frames show pulse loop and fade-in', (tester) async {
      await tester.pumpWidget(
        buildTestWidget(_frame(const SplashScreen())),
      );

      // t=0: logo at rest, text fully transparent.
      await expectLater(
        find.byType(SplashScreen),
        matchesGoldenFile('goldens/splash_t0.png'),
      );

      // t=600ms: text fade-in complete; logo still near rest.
      await tester.pump(const Duration(milliseconds: 600));
      await expectLater(
        find.byType(SplashScreen),
        matchesGoldenFile('goldens/splash_t600.png'),
      );

      // t=1200ms: mid-point of the 2400ms pulse loop -> logo scaled up.
      await tester.pump(const Duration(milliseconds: 600));
      await expectLater(
        find.byType(SplashScreen),
        matchesGoldenFile('goldens/splash_t1200.png'),
      );

      // t=2400ms: end of one pulse loop -> logo back at rest, still animating.
      await tester.pump(const Duration(milliseconds: 1200));
      await expectLater(
        find.byType(SplashScreen),
        matchesGoldenFile('goldens/splash_t2400.png'),
      );
    });
  });
}
