import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:kai_app/design_system/atoms/kai_button.dart';
import 'package:kai_app/design_system/atoms/kai_tide_curve.dart';
import 'package:kai_app/features/onboarding/presentation/pages/onboarding_page.dart';
import 'package:kai_app/features/onboarding/presentation/widgets/kai_onboarding_card.dart';
import 'package:kai_app/features/onboarding/presentation/widgets/kai_step_indicator.dart';

import '../../../test_helpers.dart';

Future<void> _pump(
  WidgetTester tester,
  Widget child, {
  ThemeMode mode = ThemeMode.light,
}) async {
  // KaiOnboardingCard uses Spacer() — must NOT be inside ScrollView.
  // buildTestWidget wraps in Scaffold which gives bounded height context.
  await tester.pumpWidget(buildTestWidget(child, themeMode: mode));
  await tester.pump();
}

Future<void> _pumpTransition(WidgetTester tester) async {
  for (var i = 0; i < 10; i++) {
    await tester.pump(const Duration(milliseconds: 50));
  }
}

void main() {
  group('KaiOnboardingCard', () {
    // ── Step rendering ───────────────────────────────────────────────────────

    testWidgets('step 0 (welcome) renders without throwing',
        (WidgetTester tester) async {
      await _pump(tester, const KaiOnboardingCard(stepIndex: 0));
      expect(find.byType(KaiOnboardingCard), findsOneWidget);
      expect(find.text('Познакомьтесь с Kai.'), findsOneWidget);
    });

    testWidgets('step 1 (tide) renders without throwing',
        (WidgetTester tester) async {
      await _pump(tester, const KaiOnboardingCard(stepIndex: 1));
      expect(find.byType(KaiOnboardingCard), findsOneWidget);
      expect(find.text('Линия вверху — это Kai.'), findsOneWidget);
      await tester.pump(const Duration(milliseconds: 100));
    });

    testWidgets('step 2 (gestures) renders without throwing',
        (WidgetTester tester) async {
      await _pump(tester, const KaiOnboardingCard(stepIndex: 2));
      expect(find.byType(KaiOnboardingCard), findsOneWidget);
      expect(find.text('Три жеста.'), findsOneWidget);
    });

    testWidgets('step 3 (context) renders without throwing',
        (WidgetTester tester) async {
      await _pump(tester, const KaiOnboardingCard(stepIndex: 3));
      expect(find.byType(KaiOnboardingCard), findsOneWidget);
      expect(find.textContaining('Два факта'), findsOneWidget);
    });

    // ── Canon button variant per step ────────────────────────────────────────
    //
    // All steps use a large tide button that rests as solid ink-1
    // (neutralAtRest: true) and reveals the tide gradient on press/hover.
    //

    testWidgets('step 0 CTA is a neutral-at-rest tide button',
        (WidgetTester tester) async {
      await _pump(tester, const OnboardingPage());

      final buttonFinder = find.byType(KaiButton);
      expect(buttonFinder, findsOneWidget);

      final button = tester.widget<KaiButton>(buttonFinder);
      expect(button.neutralAtRest, isTrue);
      expect(button.size, KaiButtonSize.lg);

      final containers = tester.widgetList<Container>(find.descendant(
        of: buttonFinder,
        matching: find.byType(Container),
      ),);
      final hasGradientOnKaiButton = containers.any((c) {
        final deco = c.decoration;
        return deco is BoxDecoration && deco.gradient != null;
      });
      expect(hasGradientOnKaiButton, isFalse,
          reason: 'Step 0 CTA at rest must not have a gradient when neutralAtRest is true',);
    });

    testWidgets('step 1 CTA is a neutral-at-rest tide button',
        (WidgetTester tester) async {
      await _pump(tester, const OnboardingPage());
      // Advance to step 1
      await tester.tap(find.text('Продолжить'));
      await _pumpTransition(tester);

      final buttonFinder = find.byType(KaiButton);
      expect(buttonFinder, findsOneWidget);
      final button = tester.widget<KaiButton>(buttonFinder);
      expect(button.neutralAtRest, isTrue);
      expect(button.size, KaiButtonSize.lg);
      final containers = tester.widgetList<Container>(find.descendant(
        of: buttonFinder,
        matching: find.byType(Container),
      ),);
      final hasGradient = containers.any((c) {
        final deco = c.decoration;
        return deco is BoxDecoration && deco.gradient != null;
      });
      expect(hasGradient, isFalse,
          reason: 'Step 1 CTA at rest must not have a gradient when neutralAtRest is true',);
    });

    testWidgets('step 2 CTA is a neutral-at-rest tide button',
        (WidgetTester tester) async {
      await _pump(tester, const OnboardingPage());
      // Advance to step 1, then step 2
      await tester.tap(find.text('Продолжить'));
      await _pumpTransition(tester);
      await tester.tap(find.text('Понятно'));
      await _pumpTransition(tester);

      final buttonFinder = find.byType(KaiButton);
      expect(buttonFinder, findsOneWidget);
      final button = tester.widget<KaiButton>(buttonFinder);
      expect(button.neutralAtRest, isTrue);
      expect(button.size, KaiButtonSize.lg);
      final containers = tester.widgetList<Container>(find.descendant(
        of: buttonFinder,
        matching: find.byType(Container),
      ),);
      final hasGradient = containers.any((c) {
        final deco = c.decoration;
        return deco is BoxDecoration && deco.gradient != null;
      });
      expect(hasGradient, isFalse,
          reason: 'Step 2 CTA at rest must not have a gradient when neutralAtRest is true',);
    });

    testWidgets('step 3 CTA is a neutral-at-rest tide button',
        (WidgetTester tester) async {
      await _pump(tester, const OnboardingPage());
      // Advance to step 3
      await tester.tap(find.text('Продолжить'));
      await _pumpTransition(tester);
      await tester.tap(find.text('Понятно'));
      await _pumpTransition(tester);
      await tester.tap(find.text('Продолжить'));
      await _pumpTransition(tester);

      final buttonFinder = find.byType(KaiButton);
      expect(buttonFinder, findsOneWidget);
      final button = tester.widget<KaiButton>(buttonFinder);
      expect(button.neutralAtRest, isTrue);
      expect(button.size, KaiButtonSize.lg);
      final containers = tester.widgetList<Container>(find.descendant(
        of: buttonFinder,
        matching: find.byType(Container),
      ),);
      final hasGradient = containers.any((c) {
        final deco = c.decoration;
        return deco is BoxDecoration && deco.gradient != null;
      });
      expect(hasGradient, isFalse,
          reason: 'Step 3 CTA at rest must not have a gradient when neutralAtRest is true',);
    });

    // ── Callback wiring ──────────────────────────────────────────────────────

    testWidgets('Onboarding Screen transition flow works',
        (WidgetTester tester) async {
      await _pump(tester, const OnboardingPage());

      // Welcome page (step 0)
      expect(find.text('Познакомьтесь с Kai.'), findsOneWidget);
      final indicator = tester.widget<KaiStepIndicator>(find.byType(KaiStepIndicator));
      expect(indicator.active, 0);

      // Tap to Step 1
      await tester.tap(find.text('Продолжить'));
      await _pumpTransition(tester);
      expect(find.text('Линия вверху — это Kai.'), findsOneWidget);
      final indicator1 = tester.widget<KaiStepIndicator>(find.byType(KaiStepIndicator));
      expect(indicator1.active, 1);

      // Tap to Step 2
      await tester.tap(find.text('Понятно'));
      await _pumpTransition(tester);
      expect(find.text('Три жеста.'), findsOneWidget);
      final indicator2 = tester.widget<KaiStepIndicator>(find.byType(KaiStepIndicator));
      expect(indicator2.active, 2);

      // Tap to Step 3
      await tester.tap(find.text('Продолжить'));
      await _pumpTransition(tester);
      expect(find.textContaining('Два факта'), findsOneWidget);
      final indicator3 = tester.widget<KaiStepIndicator>(find.byType(KaiStepIndicator));
      expect(indicator3.active, 3);
    });

    // ── KaiTideCurve present (brand mark) ────────────────────────────────────

    testWidgets('KaiTideCurve is present in step 1 (tide legend)',
        (WidgetTester tester) async {
      await _pump(tester, const KaiOnboardingCard(stepIndex: 1));
      await tester.pump(const Duration(milliseconds: 100));
      expect(find.byType(KaiTideCurve), findsWidgets);
    });

    // ── Dark mode smoke ───────────────────────────────────────────────────────

    testWidgets('dark mode renders step 0 without error',
        (WidgetTester tester) async {
      await _pump(
        tester,
        const KaiOnboardingCard(stepIndex: 0),
        mode: ThemeMode.dark,
      );
      expect(find.text('Познакомьтесь с Kai.'), findsOneWidget);
    });
  });
}
