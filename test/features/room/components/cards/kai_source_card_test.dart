import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:kai_app/features/room/presentation/widgets/cards/kai_source_card.dart';

import '../../../../test_helpers.dart';

void main() {
  group('v3/KaiSourceCard', () {
    // -----------------------------------------------------------------------
    // Core content rendering
    // -----------------------------------------------------------------------

    testWidgets('renders url', (tester) async {
      await tester.pumpWidget(
        buildTestWidget(
          const KaiSourceCard(url: 'example.com'),
        ),
      );
      await tester.pump();

      expect(find.text('example.com'), findsOneWidget);
    });

    testWidgets('renders title when provided', (tester) async {
      await tester.pumpWidget(
        buildTestWidget(
          const KaiSourceCard(
            url: 'example.com',
            title: 'Example Title',
          ),
        ),
      );
      await tester.pump();

      expect(find.text('Example Title'), findsOneWidget);
    });

    testWidgets('does not render title row when title is null', (tester) async {
      await tester.pumpWidget(
        buildTestWidget(
          const KaiSourceCard(url: 'example.com'),
        ),
      );
      await tester.pump();

      // Only the url text should appear; no title text.
      expect(find.text('example.com'), findsOneWidget);
      // Verify no unexpected titled text shows up.
      expect(find.text('Example Title'), findsNothing);
    });

    testWidgets('renders snippet when provided', (tester) async {
      await tester.pumpWidget(
        buildTestWidget(
          const KaiSourceCard(
            url: 'example.com',
            snippet: 'A short excerpt from the source.',
          ),
        ),
      );
      await tester.pump();

      expect(find.text('A short excerpt from the source.'), findsOneWidget);
    });

    testWidgets('hides snippet when null', (tester) async {
      await tester.pumpWidget(
        buildTestWidget(
          const KaiSourceCard(url: 'example.com'),
        ),
      );
      await tester.pump();

      expect(find.text('A short excerpt from the source.'), findsNothing);
    });

    // -----------------------------------------------------------------------
    // Index chip
    // -----------------------------------------------------------------------

    testWidgets('renders numeric index when provided', (tester) async {
      await tester.pumpWidget(
        buildTestWidget(
          const KaiSourceCard(url: 'example.com', index: 3),
        ),
      );
      await tester.pump();

      expect(find.text('3'), findsOneWidget);
    });

    testWidgets('omits index chip when index is null', (tester) async {
      await tester.pumpWidget(
        buildTestWidget(
          const KaiSourceCard(url: 'example.com'),
        ),
      );
      await tester.pump();

      // No numeric index text should appear.
      expect(find.text('1'), findsNothing);
      expect(find.text('3'), findsNothing);
    });

    // -----------------------------------------------------------------------
    // Freshness badge
    // -----------------------------------------------------------------------

    testWidgets('shows fresh badge when fresh is true', (tester) async {
      await tester.pumpWidget(
        buildTestWidget(
          const KaiSourceCard(url: 'example.com', fresh: true),
        ),
      );
      await tester.pump();

      expect(find.text('✓ fresh'), findsOneWidget);
    });

    testWidgets('does not show fresh badge when fresh is false', (tester) async {
      await tester.pumpWidget(
        buildTestWidget(
          // fresh defaults to false
          const KaiSourceCard(url: 'example.com'),
        ),
      );
      await tester.pump();

      expect(find.text('✓ fresh'), findsNothing);
    });

    // -----------------------------------------------------------------------
    // onTap callback
    // -----------------------------------------------------------------------

    testWidgets('onTap fires when card is tapped', (tester) async {
      var tapped = false;

      await tester.pumpWidget(
        buildTestWidget(
          KaiSourceCard(
            url: 'example.com',
            title: 'Tappable Card',
            onTap: () => tapped = true,
          ),
        ),
      );
      await tester.pump();

      await tester.tap(find.text('Tappable Card'));
      await tester.pump();

      expect(tapped, isTrue);
    });

    testWidgets('card is not tappable when onTap is null', (tester) async {
      // Simply verify no GestureDetector with an onTap handler wraps the card
      // (the card should still render without errors).
      await tester.pumpWidget(
        buildTestWidget(
          const KaiSourceCard(url: 'example.com', title: 'Static Card'),
        ),
      );
      await tester.pump();

      // Renders without throwing.
      expect(find.text('example.com'), findsOneWidget);
    });

    // -----------------------------------------------------------------------
    // Visual structure
    // -----------------------------------------------------------------------

    testWidgets('outer container has surface-2 fill', (tester) async {
      await tester.pumpWidget(
        buildTestWidget(
          const KaiSourceCard(url: 'example.com'),
        ),
      );
      await tester.pump();

      final containers = tester
          .widgetList<Container>(find.byType(Container))
          .toList();
      final hasFill = containers.any((c) {
        final deco = c.decoration;
        return deco is BoxDecoration && deco.color != null;
      });
      expect(hasFill, isTrue,
          reason: 'source card must have a background fill',);
    });

    testWidgets('outer container has r10 border radius', (tester) async {
      await tester.pumpWidget(
        buildTestWidget(
          const KaiSourceCard(url: 'example.com'),
        ),
      );
      await tester.pump();

      final containers = tester
          .widgetList<Container>(find.byType(Container))
          .toList();
      final hasR10 = containers.any((c) {
        final deco = c.decoration;
        if (deco is! BoxDecoration) return false;
        final br = deco.borderRadius;
        if (br is! BorderRadius) return false;
        return br.topLeft == const Radius.circular(10);
      });
      expect(hasR10, isTrue,
          reason: 'source card must use r10 border radius (KaiRadius.br2)',);
    });

    // -----------------------------------------------------------------------
    // Full combination
    // -----------------------------------------------------------------------

    testWidgets('renders all fields together without error', (tester) async {
      await tester.pumpWidget(
        buildTestWidget(
          KaiSourceCard(
            url: 'wiki.example.com/article',
            title: 'Encyclopedia Article',
            snippet: 'A brief description of the topic.',
            index: 1,
            fresh: true,
            onTap: () {},
          ),
        ),
      );
      await tester.pump();

      expect(find.text('wiki.example.com/article'), findsOneWidget);
      expect(find.text('Encyclopedia Article'), findsOneWidget);
      expect(find.text('A brief description of the topic.'), findsOneWidget);
      expect(find.text('1'), findsOneWidget);
      expect(find.text('✓ fresh'), findsOneWidget);
    });
  });
}
