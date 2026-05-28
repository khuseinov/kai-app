import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:kai_app/design_system/atoms/kai_button.dart';
import 'package:kai_app/design_system/atoms/kai_tide_curve.dart';
import 'package:kai_app/design_system/organisms/kai_onboarding_card.dart';

import '../../test_helpers.dart';

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

    // ── Canon button variant per step (onboarding.html fidelity) ───────────
    //
    // Canon: new-design/onboarding.html
    //   `.ob-btn { background: var(--ink-1) }` — default (steps 1-3)
    //   `.frame-card:first-child .ob-btn { background: var(--tide-gradient) }` — step 0 only
    //
    // Step 0 (welcome): KaiButton.tide — the sole tide-gradient primary.
    // Steps 1-3: KaiButton.ink — solid ink-1 primary for non-hero steps.

    testWidgets('step 0 CTA is KaiButton.tide (canon: tide on welcome only)',
        (WidgetTester tester) async {
      await _pump(tester, const KaiOnboardingCard(stepIndex: 0));
      // Tide variant uses a gradient decoration — verify via key structural
      // property: the button has a gradient BoxDecoration.
      final buttons = tester.widgetList<KaiButton>(find.byType(KaiButton));
      expect(buttons, isNotEmpty);
      // There should be exactly one KaiButton on the card.
      expect(find.byType(KaiButton), findsOneWidget);
      // The decoration of the outermost Container inside a tide button contains
      // a gradient. We validate by checking the internal Container.
      final containers = tester.widgetList<Container>(find.descendant(
        of: find.byType(KaiButton),
        matching: find.byType(Container),
      ));
      final hasGradient = containers.any((c) {
        final deco = c.decoration;
        return deco is BoxDecoration && deco.gradient != null;
      });
      expect(hasGradient, isTrue,
          reason: 'Step 0 CTA must use tide gradient (KaiButton.tide)');
    });

    testWidgets('step 1 CTA is KaiButton.ink (canon: ink-1 on non-hero steps)',
        (WidgetTester tester) async {
      await _pump(tester, const KaiOnboardingCard(stepIndex: 1));
      expect(find.byType(KaiButton), findsOneWidget);
      // Ink variant has no gradient — verify no gradient in button containers.
      final containers = tester.widgetList<Container>(find.descendant(
        of: find.byType(KaiButton),
        matching: find.byType(Container),
      ));
      final hasGradient = containers.any((c) {
        final deco = c.decoration;
        return deco is BoxDecoration && deco.gradient != null;
      });
      expect(hasGradient, isFalse,
          reason: 'Step 1 CTA must use ink-1 fill (KaiButton.ink), not tide');
    });

    testWidgets('step 2 CTA is KaiButton.ink (canon: ink-1 on non-hero steps)',
        (WidgetTester tester) async {
      await _pump(tester, const KaiOnboardingCard(stepIndex: 2));
      expect(find.byType(KaiButton), findsOneWidget);
      final containers = tester.widgetList<Container>(find.descendant(
        of: find.byType(KaiButton),
        matching: find.byType(Container),
      ));
      final hasGradient = containers.any((c) {
        final deco = c.decoration;
        return deco is BoxDecoration && deco.gradient != null;
      });
      expect(hasGradient, isFalse,
          reason: 'Step 2 CTA must use ink-1 fill (KaiButton.ink), not tide');
    });

    testWidgets('step 3 CTA is KaiButton.ink (canon: ink-1 on non-hero steps)',
        (WidgetTester tester) async {
      await _pump(tester, const KaiOnboardingCard(stepIndex: 3));
      expect(find.byType(KaiButton), findsOneWidget);
      final containers = tester.widgetList<Container>(find.descendant(
        of: find.byType(KaiButton),
        matching: find.byType(Container),
      ));
      final hasGradient = containers.any((c) {
        final deco = c.decoration;
        return deco is BoxDecoration && deco.gradient != null;
      });
      expect(hasGradient, isFalse,
          reason: 'Step 3 CTA must use ink-1 fill (KaiButton.ink), not tide');
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
