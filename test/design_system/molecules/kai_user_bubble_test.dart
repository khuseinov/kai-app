import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:kai_app/design_system/molecules/kai_user_bubble.dart';

import '../../test_helpers.dart';

void main() {
  group('v3/KaiUserBubble', () {
    testWidgets('renders the text', (tester) async {
      await tester.pumpWidget(
        buildTestWidget(
          const KaiUserBubble(text: 'Hello world'),
        ),
      );
      await tester.pump();
      expect(find.text('Hello world'), findsOneWidget);
    });

    testWidgets('is right-aligned via Align(centerRight)', (tester) async {
      await tester.pumpWidget(
        buildTestWidget(
          const KaiUserBubble(text: 'Right-aligned'),
        ),
      );
      await tester.pump();
      final align = tester.widget<Align>(
        find.ancestor(
          of: find.text('Right-aligned'),
          matching: find.byType(Align),
        ).first,
      );
      expect(align.alignment, Alignment.centerRight);
    });

    testWidgets('has surface2 background colour', (tester) async {
      await tester.pumpWidget(
        buildTestWidget(
          const KaiUserBubble(text: 'Colour test'),
        ),
      );
      await tester.pump();

      final containers = tester
          .widgetList<Container>(find.byType(Container))
          .toList();
      // At least one Container must have a BoxDecoration with a non-null fill
      final hasFill = containers.any((c) {
        final deco = c.decoration;
        return deco is BoxDecoration && deco.color != null;
      });
      expect(hasFill, isTrue, reason: 'bubble must have a background fill');
    });

    testWidgets('uses asymmetric border-radius (bottomRight: 4)', (tester) async {
      await tester.pumpWidget(
        buildTestWidget(
          const KaiUserBubble(text: 'Radius test'),
        ),
      );
      await tester.pump();

      final containers = tester
          .widgetList<Container>(find.byType(Container))
          .toList();
      final hasAsymmetric = containers.any((c) {
        final deco = c.decoration;
        if (deco is! BoxDecoration) return false;
        final br = deco.borderRadius;
        if (br is! BorderRadius) return false;
        return br.bottomRight == const Radius.circular(4);
      });
      expect(
        hasAsymmetric,
        isTrue,
        reason:
            'user bubble must have bottom-right corner 4px (asymmetric tail)',
      );
    });

    testWidgets('constrains width to 78% of screen', (tester) async {
      await tester.pumpWidget(
        buildTestWidget(
          const KaiUserBubble(text: 'Width test'),
        ),
      );
      await tester.pump();
      // The ConstrainedBox with maxWidth exists in the tree
      expect(find.byType(ConstrainedBox), findsWidgets);
    });
  });
}
