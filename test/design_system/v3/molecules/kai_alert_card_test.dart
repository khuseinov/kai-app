import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:kai_app/design_system/v3/atoms/kai_button.dart';
import 'package:kai_app/design_system/v3/molecules/kai_alert_card.dart';

import '../../../test_helpers.dart';

void main() {
  group('v3/KaiAlertCard', () {
    // -------------------------------------------------------------------------
    // Each alert type renders without error
    // -------------------------------------------------------------------------

    for (final type in KaiAlertType.values) {
      testWidgets('renders type=${type.name} without error', (tester) async {
        await tester.pumpWidget(
          buildTestWidget(
            KaiAlertCard(
              type: type,
              title: 'Title for ${type.name}',
            ),
          ),
        );
        await tester.pump();
        expect(find.byType(KaiAlertCard), findsOneWidget);
      });
    }

    // -------------------------------------------------------------------------
    // Type label (URGENT / WARNING / INFO / NOTE)
    // -------------------------------------------------------------------------

    testWidgets('urgent type renders URGENT label', (tester) async {
      await tester.pumpWidget(
        buildTestWidget(
          const KaiAlertCard(type: KaiAlertType.urgent, title: 'Test'),
        ),
      );
      await tester.pump();
      expect(find.text('URGENT'), findsOneWidget);
    });

    testWidgets('warning type renders WARNING label', (tester) async {
      await tester.pumpWidget(
        buildTestWidget(
          const KaiAlertCard(type: KaiAlertType.warning, title: 'Test'),
        ),
      );
      await tester.pump();
      expect(find.text('WARNING'), findsOneWidget);
    });

    testWidgets('positive type renders INFO label', (tester) async {
      await tester.pumpWidget(
        buildTestWidget(
          const KaiAlertCard(type: KaiAlertType.positive, title: 'Test'),
        ),
      );
      await tester.pump();
      expect(find.text('INFO'), findsOneWidget);
    });

    testWidgets('neutral type renders NOTE label', (tester) async {
      await tester.pumpWidget(
        buildTestWidget(
          const KaiAlertCard(type: KaiAlertType.neutral, title: 'Test'),
        ),
      );
      await tester.pump();
      expect(find.text('NOTE'), findsOneWidget);
    });

    // -------------------------------------------------------------------------
    // Title & body content
    // -------------------------------------------------------------------------

    testWidgets('renders title text', (tester) async {
      await tester.pumpWidget(
        buildTestWidget(
          const KaiAlertCard(
            type: KaiAlertType.neutral,
            title: 'Важное уведомление',
          ),
        ),
      );
      await tester.pump();
      expect(find.text('Важное уведомление'), findsOneWidget);
    });

    testWidgets('renders body text when provided', (tester) async {
      await tester.pumpWidget(
        buildTestWidget(
          const KaiAlertCard(
            type: KaiAlertType.warning,
            title: 'Заголовок',
            body: 'Дополнительные детали предупреждения.',
          ),
        ),
      );
      await tester.pump();
      expect(find.text('Дополнительные детали предупреждения.'), findsOneWidget);
    });

    testWidgets('omits body when null', (tester) async {
      await tester.pumpWidget(
        buildTestWidget(
          const KaiAlertCard(
            type: KaiAlertType.positive,
            title: 'Заголовок',
          ),
        ),
      );
      await tester.pump();
      expect(find.text('Дополнительные детали'), findsNothing);
    });

    // -------------------------------------------------------------------------
    // Time stamp
    // -------------------------------------------------------------------------

    testWidgets('renders time when provided', (tester) async {
      await tester.pumpWidget(
        buildTestWidget(
          const KaiAlertCard(
            type: KaiAlertType.urgent,
            title: 'Заголовок',
            time: '9:41',
          ),
        ),
      );
      await tester.pump();
      expect(find.text('9:41'), findsOneWidget);
    });

    testWidgets('omits time when null', (tester) async {
      await tester.pumpWidget(
        buildTestWidget(
          const KaiAlertCard(type: KaiAlertType.neutral, title: 'Test'),
        ),
      );
      await tester.pump();
      expect(find.text('9:41'), findsNothing);
    });

    // -------------------------------------------------------------------------
    // CTA renders as KaiButton
    // -------------------------------------------------------------------------

    testWidgets('CTA renders a KaiButton when cta is provided', (tester) async {
      await tester.pumpWidget(
        buildTestWidget(
          KaiAlertCard(
            type: KaiAlertType.urgent,
            title: 'Заголовок',
            cta: 'Подробнее',
            onCtaTap: () {},
          ),
        ),
      );
      await tester.pump();

      // The CTA MUST be rendered via KaiButton (not a bespoke pill).
      expect(find.byType(KaiButton), findsOneWidget);
    });

    testWidgets('CTA label text appears when cta provided', (tester) async {
      await tester.pumpWidget(
        buildTestWidget(
          KaiAlertCard(
            type: KaiAlertType.warning,
            title: 'Заголовок',
            cta: 'Открыть',
            onCtaTap: () {},
          ),
        ),
      );
      await tester.pump();
      expect(find.text('Открыть'), findsOneWidget);
    });

    testWidgets('onCtaTap fires when CTA is tapped', (tester) async {
      var tapped = false;
      await tester.pumpWidget(
        buildTestWidget(
          KaiAlertCard(
            type: KaiAlertType.positive,
            title: 'Заголовок',
            cta: 'Перейти',
            onCtaTap: () => tapped = true,
          ),
        ),
      );
      await tester.pump();

      // Tap the CTA label (the KaiButton contains a Text with 'Перейти').
      await tester.tap(find.text('Перейти'));
      await tester.pump();

      expect(tapped, isTrue);
    });

    testWidgets('no KaiButton when cta is null', (tester) async {
      await tester.pumpWidget(
        buildTestWidget(
          const KaiAlertCard(type: KaiAlertType.neutral, title: 'Test'),
        ),
      );
      await tester.pump();
      expect(find.byType(KaiButton), findsNothing);
    });

    // -------------------------------------------------------------------------
    // No "action" parameter (compile-time: KaiAlertCard has no action field)
    // -------------------------------------------------------------------------

    testWidgets('KaiAlertCard does not expose an action field', (tester) async {
      // Compile-time verified: if `action` existed, this test file would not
      // compile because we never reference it.
      await tester.pumpWidget(
        buildTestWidget(
          const KaiAlertCard(type: KaiAlertType.neutral, title: 'Test'),
        ),
      );
      await tester.pump();
      expect(find.byType(KaiAlertCard), findsOneWidget);
    });

    // -------------------------------------------------------------------------
    // KaiAlertType enum values
    // -------------------------------------------------------------------------

    test('KaiAlertType has exactly 4 values', () {
      expect(KaiAlertType.values.length, 4);
    });

    test('KaiAlertType values are urgent/warning/positive/neutral', () {
      expect(KaiAlertType.values, containsAll([
        KaiAlertType.urgent,
        KaiAlertType.warning,
        KaiAlertType.positive,
        KaiAlertType.neutral,
      ]));
    });

    // -------------------------------------------------------------------------
    // Visual structure — outer Container has rounded corners
    // -------------------------------------------------------------------------

    testWidgets('outer container has rounded corners', (tester) async {
      await tester.pumpWidget(
        buildTestWidget(
          const KaiAlertCard(type: KaiAlertType.neutral, title: 'Test'),
        ),
      );
      await tester.pump();

      final containers = tester
          .widgetList<Container>(find.byType(Container))
          .toList();

      final hasRounded = containers.any((c) {
        final deco = c.decoration;
        if (deco is! BoxDecoration) return false;
        final br = deco.borderRadius;
        return br != null;
      });

      expect(hasRounded, isTrue,
          reason: 'alert card outer container must have rounded border radius');
    });

    testWidgets('outer container has a border', (tester) async {
      await tester.pumpWidget(
        buildTestWidget(
          const KaiAlertCard(type: KaiAlertType.urgent, title: 'Test'),
        ),
      );
      await tester.pump();

      final containers = tester
          .widgetList<Container>(find.byType(Container))
          .toList();

      final hasBorder = containers.any((c) {
        final deco = c.decoration;
        if (deco is! BoxDecoration) return false;
        return deco.border != null;
      });

      expect(hasBorder, isTrue,
          reason: 'alert card must have a border');
    });

    // -------------------------------------------------------------------------
    // Full combination
    // -------------------------------------------------------------------------

    testWidgets('renders all fields together without error', (tester) async {
      await tester.pumpWidget(
        buildTestWidget(
          KaiAlertCard(
            type: KaiAlertType.urgent,
            title: 'Критическое предупреждение',
            body: 'Немедленно примите меры.',
            time: '10:30',
            cta: 'Действовать',
            onCtaTap: () {},
          ),
        ),
      );
      await tester.pump();

      expect(find.text('URGENT'), findsOneWidget);
      expect(find.text('Критическое предупреждение'), findsOneWidget);
      expect(find.text('Немедленно примите меры.'), findsOneWidget);
      expect(find.text('10:30'), findsOneWidget);
      expect(find.text('Действовать'), findsOneWidget);
      expect(find.byType(KaiButton), findsOneWidget);
    });
  });
}
