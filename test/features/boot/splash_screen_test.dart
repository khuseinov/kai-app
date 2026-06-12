import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:kai_app/design_system/atoms/atoms.dart';
import 'package:kai_app/features/boot/splash_config.dart';
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
    testWidgets('renders logo, wordmark and by Wize label', (tester) async {
      await tester.pumpWidget(buildTestWidget(const SplashScreen()));

      expect(find.byType(KaiLogo), findsOneWidget);
      expect(find.text('kai'), findsOneWidget);
      expect(find.text('by Wize'), findsOneWidget);
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

    testWidgets('draws brand curve and fades in text', (tester) async {
      await tester.pumpWidget(buildTestWidget(const SplashScreen()));

      final state = tester.state<SplashScreenState>(find.byType(SplashScreen));
      expect(state.drawController.isAnimating, isTrue);

      // Text fade starts after an 800 ms overlap delay.
      await tester.pump(const Duration(milliseconds: 800));
      expect(state.fadeController.isAnimating, isTrue);

      // Advance past the end of both animations.
      await tester.pump(kSplashDrawDuration);
      expect(state.drawController.isCompleted, isTrue);

      // Text fade completes.
      await tester.pump(kSplashTextFadeDuration);
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
      expect(state.drawController.isAnimating, isFalse);
      expect(state.fadeController.isAnimating, isFalse);
      expect(state.drawController.value, 1.0);
      expect(state.fadeController.value, 1.0);
    });

    testWidgets('golden frames show curve draw and fade-in', (tester) async {
      await tester.pumpWidget(
        buildTestWidget(_frame(const SplashScreen())),
      );

      // t=0: curve empty, text fully transparent.
      await expectLater(
        find.byType(SplashScreen),
        matchesGoldenFile('goldens/splash_t0.png'),
      );

      // t=700ms: curve roughly half-drawn; text still fading in.
      await tester.pump(const Duration(milliseconds: 700));
      await expectLater(
        find.byType(SplashScreen),
        matchesGoldenFile('goldens/splash_t700.png'),
      );

      // t=1400ms: curve fully drawn; text fade well under way.
      await tester.pump(const Duration(milliseconds: 700));
      await expectLater(
        find.byType(SplashScreen),
        matchesGoldenFile('goldens/splash_t1400.png'),
      );

      // t=2200ms: text fade complete, static final frame.
      await tester.pump(const Duration(milliseconds: 800));
      await expectLater(
        find.byType(SplashScreen),
        matchesGoldenFile('goldens/splash_t2200.png'),
      );
    });
  });
}
