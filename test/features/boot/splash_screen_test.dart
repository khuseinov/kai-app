import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
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
  setUpAll(() async {
    final fontData = File('assets/fonts/Manrope.ttf').readAsBytesSync();
    final loader = FontLoader('Manrope')
      ..addFont(Future.value(ByteData.view(fontData.buffer)));
    await loader.load();
  });

  group('SplashScreen', () {
    testWidgets('renders logo, wordmark and tagline lockup', (tester) async {
      await tester.pumpWidget(buildTestWidget(const SplashScreen()));

      expect(find.byType(KaiLogo), findsOneWidget);
      expect(find.text('kai'), findsOneWidget);
      expect(
        find.text('ваш компаньон путешественника'),
        findsOneWidget,
      );
      expect(find.text('by Wize'), findsNothing);
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
      expect(
        find.text('ваш компаньон путешественника'),
        findsOneWidget,
      );
    });

    testWidgets('plays a single scale pulse and stops', (tester) async {
      await tester.pumpWidget(buildTestWidget(const SplashScreen()));

      final state = tester.state<SplashScreenState>(find.byType(SplashScreen));
      expect(state.pulseController.isAnimating, isTrue);

      await tester.pump(kSplashPulseDuration + const Duration(milliseconds: 16));
      expect(state.pulseController.isCompleted, isTrue);
      expect(state.pulseController.value, 1.0);
    });

    testWidgets('keeps pulse controller idle when animations are disabled',
        (tester) async {
      await tester.pumpWidget(
        MediaQuery(
          data: const MediaQueryData(disableAnimations: true),
          child: buildTestWidget(const SplashScreen()),
        ),
      );

      final state = tester.state<SplashScreenState>(find.byType(SplashScreen));
      expect(state.pulseController.isAnimating, isFalse);
      expect(state.pulseController.value, 1.0);
    });

    testWidgets('golden frames show scale pulse and static lockup',
        (tester) async {
      await tester.pumpWidget(
        buildTestWidget(_frame(const SplashScreen())),
      );

      // t=0: scale at start.
      await expectLater(
        find.byType(SplashScreen),
        matchesGoldenFile('goldens/splash_t0.png'),
      );

      // t=800ms: mid-pulse.
      await tester.pump(const Duration(milliseconds: 800));
      await expectLater(
        find.byType(SplashScreen),
        matchesGoldenFile('goldens/splash_t800.png'),
      );

      // t=1200ms: peak scale (~1.06).
      await tester.pump(const Duration(milliseconds: 400));
      await expectLater(
        find.byType(SplashScreen),
        matchesGoldenFile('goldens/splash_t1200.png'),
      );

      // t=2400ms: pulse complete, static final frame.
      await tester.pump(const Duration(milliseconds: 1200));
      await expectLater(
        find.byType(SplashScreen),
        matchesGoldenFile('goldens/splash_t2400.png'),
      );
    });
  });
}
