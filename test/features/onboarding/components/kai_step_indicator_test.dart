import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:kai_app/design_system/tokens/kai_tokens.dart';
import 'package:kai_app/features/onboarding/presentation/widgets/kai_step_indicator.dart';

import '../../../test_helpers.dart';

void main() {
  group('KaiStepIndicator', () {
    testWidgets('renders count=4, active=1: active dot is wider than others',
        (WidgetTester tester) async {
      await tester.pumpWidget(
        buildTestWidget(
          const KaiStepIndicator(count: 4, active: 1),
        ),
      );
      await tester.pumpAndSettle();

      final dots = tester
          .widgetList<AnimatedContainer>(find.byType(AnimatedContainer))
          .toList();
      expect(dots, hasLength(4));

      // dot 0: inactive → width 8
      expect(dots[0].constraints?.maxWidth, closeTo(8.0, 0.5));
      // dot 1: active → width 20
      expect(dots[1].constraints?.maxWidth, closeTo(20.0, 0.5));
      // dot 2: inactive → width 8
      expect(dots[2].constraints?.maxWidth, closeTo(8.0, 0.5));
      // dot 3: inactive → width 8
      expect(dots[3].constraints?.maxWidth, closeTo(8.0, 0.5));
    });

    testWidgets('active dot has accent color, others have ink4',
        (WidgetTester tester) async {
      await tester.pumpWidget(
        buildTestWidget(
          const KaiStepIndicator(count: 4, active: 1),
        ),
      );
      await tester.pumpAndSettle();

      final c = KaiTokens.light.colors;

      final dots = tester
          .widgetList<AnimatedContainer>(find.byType(AnimatedContainer))
          .toList();

      BoxDecoration? getDeco(AnimatedContainer ac) {
        final deco = ac.decoration;
        return deco is BoxDecoration ? deco : null;
      }

      final activeDeco = getDeco(dots[1]);
      expect(activeDeco?.color, c.accent);

      for (final i in [0, 2, 3]) {
        final deco = getDeco(dots[i]);
        expect(deco?.color, c.ink4);
      }
    });

    testWidgets('rebuild with active=2 does not throw',
        (WidgetTester tester) async {
      await tester.pumpWidget(
        buildTestWidget(
          const KaiStepIndicator(count: 4, active: 1),
        ),
      );
      await tester.pumpAndSettle();

      await tester.pumpWidget(
        buildTestWidget(
          const KaiStepIndicator(count: 4, active: 2),
        ),
      );
      await tester.pumpAndSettle();
      expect(find.byType(KaiStepIndicator), findsOneWidget);
    });

    testWidgets('all heights are 8 logical pixels',
        (WidgetTester tester) async {
      await tester.pumpWidget(
        buildTestWidget(
          const KaiStepIndicator(count: 3, active: 0),
        ),
      );
      await tester.pumpAndSettle();

      final dots = tester
          .widgetList<AnimatedContainer>(find.byType(AnimatedContainer))
          .toList();

      for (final dot in dots) {
        expect(dot.constraints?.maxHeight, closeTo(8.0, 0.5));
      }
    });

    testWidgets('scale=1.25 multiplies dot sizes',
        (WidgetTester tester) async {
      await tester.pumpWidget(
        buildTestWidget(
          const KaiStepIndicator(count: 4, active: 1, scale: 1.25),
        ),
      );
      await tester.pumpAndSettle();

      final dots = tester
          .widgetList<AnimatedContainer>(find.byType(AnimatedContainer))
          .toList();

      expect(dots[0].constraints?.maxWidth, closeTo(10.0, 0.5));
      expect(dots[1].constraints?.maxWidth, closeTo(25.0, 0.5));
      for (final dot in dots) {
        expect(dot.constraints?.maxHeight, closeTo(10.0, 0.5));
      }
    });
  });
}
