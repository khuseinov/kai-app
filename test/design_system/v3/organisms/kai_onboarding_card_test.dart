import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:kai_app/design_system/v3/atoms/kai_button.dart';
import 'package:kai_app/design_system/v3/atoms/kai_tide_curve.dart';
import 'package:kai_app/design_system/v3/organisms/kai_onboarding_card.dart';

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

    // ── R1 audit: CTA is a KaiButton, NOT a bespoke container ───────────────

    testWidgets('CTA is a KaiButton on step 0 (welcome)',
        (WidgetTester tester) async {
      await _pump(tester, const KaiOnboardingCard(stepIndex: 0));
      expect(find.byType(KaiButton), findsOneWidget);
    });

    testWidgets('CTA is a KaiButton on step 1', (WidgetTester tester) async {
      await _pump(tester, const KaiOnboardingCard(stepIndex: 1));
      expect(find.byType(KaiButton), findsOneWidget);
    });

    testWidgets('CTA is a KaiButton on step 2', (WidgetTester tester) async {
      await _pump(tester, const KaiOnboardingCard(stepIndex: 2));
      expect(find.byType(KaiButton), findsOneWidget);
    });

    testWidgets('CTA is a KaiButton on step 3', (WidgetTester tester) async {
      await _pump(tester, const KaiOnboardingCard(stepIndex: 3));
      expect(find.byType(KaiButton), findsOneWidget);
    });

    // ── Callback wiring ──────────────────────────────────────────────────────

    testWidgets('"Продолжить" fires onNext on step 2',
        (WidgetTester tester) async {
      var nexts = 0;
      await _pump(
        tester,
        KaiOnboardingCard(stepIndex: 2, onNext: () => nexts++),
      );
      await tester.tap(find.text('Продолжить'));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 50));
      expect(nexts, 1);
    });

    testWidgets('"Начать использовать Kai" fires onComplete on step 3',
        (WidgetTester tester) async {
      var fired = 0;
      await _pump(
        tester,
        KaiOnboardingCard(stepIndex: 3, onComplete: () => fired++),
      );
      await tester.tap(find.text('Начать использовать Kai'));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 50));
      expect(fired, 1);
    });

    testWidgets('"Понятно" on step 1 fires onNext', (WidgetTester tester) async {
      var nexts = 0;
      await _pump(
        tester,
        KaiOnboardingCard(stepIndex: 1, onNext: () => nexts++),
      );
      await tester.tap(find.text('Понятно'));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 50));
      expect(nexts, 1);
    });

    testWidgets('"Продолжить" on step 0 fires onNext',
        (WidgetTester tester) async {
      var nexts = 0;
      await _pump(
        tester,
        KaiOnboardingCard(stepIndex: 0, onNext: () => nexts++),
      );
      await tester.tap(find.text('Продолжить'));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 50));
      expect(nexts, 1);
    });

    // ── KaiTideCurve present (brand mark) ────────────────────────────────────

    testWidgets('KaiTideCurve is present in step 1 (tide legend)',
        (WidgetTester tester) async {
      await _pump(tester, const KaiOnboardingCard(stepIndex: 1));
      await tester.pump(const Duration(milliseconds: 100));
      expect(find.byType(KaiTideCurve), findsWidgets);
    });

    // ── Step dots ────────────────────────────────────────────────────────────

    testWidgets('dots indicator shows 4 AnimatedContainer dots',
        (WidgetTester tester) async {
      await _pump(tester, const KaiOnboardingCard(stepIndex: 0));
      final dotFinder = find.descendant(
        of: find.byType(KaiOnboardingCard),
        matching: find.byWidgetPredicate(
          (widget) => widget is AnimatedContainer && widget.child == null,
        ),
      );
      expect(dotFinder, findsNWidgets(4));
    });

    testWidgets('active dot index matches stepIndex',
        (WidgetTester tester) async {
      await _pump(tester, const KaiOnboardingCard(stepIndex: 2));
      expect(find.byType(KaiOnboardingCard), findsOneWidget);
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
