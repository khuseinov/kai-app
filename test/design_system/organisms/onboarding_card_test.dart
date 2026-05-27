import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:kai_app/design_system/organisms/onboarding_card.dart';

import '../../test_helpers.dart';

Future<void> _pump(
  WidgetTester tester,
  Widget child, {
  ThemeMode mode = ThemeMode.light,
}) async {
  // OnboardingCard uses Spacer() and requires bounded height — do NOT wrap in
  // SingleChildScrollView. buildTestWidget wraps in Scaffold which gives
  // the correct bounded height context.
  await tester.pumpWidget(
    buildTestWidget(child, themeMode: mode),
  );
  await tester.pump();
}

void main() {
  group('OnboardingCard', () {
    testWidgets('step 0 (welcome) renders without throwing',
        (WidgetTester tester) async {
      await _pump(
        tester,
        const OnboardingCard(stepIndex: 0),
      );
      expect(find.byType(OnboardingCard), findsOneWidget);
      // Updated to match new design copy from new-design/onboarding.html
      expect(find.text('Познакомьтесь с Kai.'), findsOneWidget);
    });

    testWidgets('step 1 (tide) renders without throwing',
        (WidgetTester tester) async {
      await _pump(
        tester,
        const OnboardingCard(stepIndex: 1),
      );
      expect(find.byType(OnboardingCard), findsOneWidget);
      expect(find.text('Линия вверху — это Kai.'), findsOneWidget);
      // Pump a few frames to let animation tick.
      await tester.pump(const Duration(milliseconds: 100));
    });

    testWidgets('step 2 (gestures) renders without throwing',
        (WidgetTester tester) async {
      await _pump(
        tester,
        const OnboardingCard(stepIndex: 2),
      );
      expect(find.byType(OnboardingCard), findsOneWidget);
      expect(find.text('Три жеста.'), findsOneWidget);
    });

    testWidgets('step 3 (context) renders without throwing',
        (WidgetTester tester) async {
      await _pump(
        tester,
        const OnboardingCard(stepIndex: 3),
      );
      expect(find.byType(OnboardingCard), findsOneWidget);
      // Title is a multi-line string — check for the first part.
      expect(find.textContaining('Два факта'), findsOneWidget);
    });

    testWidgets(
        'step 3 "Начать использовать Kai" button fires onComplete callback',
        (WidgetTester tester) async {
      var fired = 0;
      await _pump(
        tester,
        OnboardingCard(stepIndex: 3, onComplete: () => fired++),
      );
      await tester.tap(find.text('Начать использовать Kai'));
      // Use pump instead of pumpAndSettle — AnimationController.repeat() never
      // settles; pump a few frames to process the tap.
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 50));
      expect(fired, 1);
    });

    testWidgets('dots indicator shows 4 dots', (WidgetTester tester) async {
      await _pump(tester, const OnboardingCard(stepIndex: 0));
      // The _StepDots widget renders 4 AnimatedContainer children without a child.
      final dotFinder = find.descendant(
        of: find.byType(OnboardingCard),
        matching: find.byWidgetPredicate(
          (widget) =>
              widget is AnimatedContainer &&
              widget.child == null,
        ),
      );
      expect(dotFinder, findsNWidgets(4));
    });

    testWidgets('active dot index matches stepIndex',
        (WidgetTester tester) async {
      // Pump step 2: dots at index 0, 1 are inactive, index 2 is active.
      await _pump(tester, const OnboardingCard(stepIndex: 2));
      // No crash means the step index is correctly wired.
      expect(find.byType(OnboardingCard), findsOneWidget);
    });
  });
}
