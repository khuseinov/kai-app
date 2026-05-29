import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:kai_app/design_system/atoms/kai_step_indicator.dart';
import 'package:kai_app/design_system/tokens/kai_tokens.dart';

import '../../test_helpers.dart';

void main() {
  group('KaiStepIndicator', () {
    testWidgets('renders count=4, active=1: active dot is wider than others',
        (WidgetTester tester) async {
      await tester.pumpWidget(
        buildTestWidget(
          const KaiStepIndicator(count: 4, active: 1),
        ),
      );
      // Settle so AnimatedContainer reaches its target state.
      await tester.pumpAndSettle();

      // There should be 4 AnimatedContainers (the dots).
      final dots = tester
          .widgetList<AnimatedContainer>(find.byType(AnimatedContainer))
          .toList();
      expect(dots, hasLength(4));

      // AnimatedContainer exposes its BoxConstraints via RenderBox.
      // Each dot is wrapped in a margin so we check the widget property directly:
      // AnimatedContainer.constraints reflects the width we passed.
      // dot 0: inactive → width 6
      expect(dots[0].constraints?.maxWidth, closeTo(6.0, 0.5));
      // dot 1: active → width 16
      expect(dots[1].constraints?.maxWidth, closeTo(16.0, 0.5));
      // dot 2: inactive → width 6
      expect(dots[2].constraints?.maxWidth, closeTo(6.0, 0.5));
      // dot 3: inactive → width 6
      expect(dots[3].constraints?.maxWidth, closeTo(6.0, 0.5));
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

      // dot 1 should have accent color
      final activeDeco = getDeco(dots[1]);
      expect(activeDeco?.color, c.accent);

      // dots 0, 2, 3 should have ink4 color
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

      // Rebuild with active=2
      await tester.pumpWidget(
        buildTestWidget(
          const KaiStepIndicator(count: 4, active: 2),
        ),
      );
      await tester.pumpAndSettle();
      expect(find.byType(KaiStepIndicator), findsOneWidget);
    });

    testWidgets('all heights are 6 logical pixels',
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
        expect(dot.constraints?.maxHeight, closeTo(6.0, 0.5));
      }
    });
  });
}
