import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:kai_app/design_system/molecules/kai_segmented_control.dart';

import '../../test_helpers.dart';

void main() {
  group('v3/KaiSegmentedControl', () {
    // -------------------------------------------------------------------------
    // Basic rendering
    // -------------------------------------------------------------------------

    testWidgets('renders all option labels', (tester) async {
      await tester.pumpWidget(
        buildTestWidget(
          KaiSegmentedControl(
            options: const ['А', 'Б', 'В'],
            selectedIndex: 0,
            onSelected: (_) {},
          ),
        ),
      );
      await tester.pump();
      expect(find.text('А'), findsOneWidget);
      expect(find.text('Б'), findsOneWidget);
      expect(find.text('В'), findsOneWidget);
    });

    testWidgets('renders without error with single option', (tester) async {
      await tester.pumpWidget(
        buildTestWidget(
          KaiSegmentedControl(
            options: const ['Only'],
            selectedIndex: 0,
            onSelected: (_) {},
          ),
        ),
      );
      await tester.pump();
      expect(find.byType(KaiSegmentedControl), findsOneWidget);
    });

    // -------------------------------------------------------------------------
    // Selection index
    // -------------------------------------------------------------------------

    testWidgets('onSelected fires with correct index on first tap', (tester) async {
      int? selected;
      await tester.pumpWidget(
        buildTestWidget(
          KaiSegmentedControl(
            options: const ['Один', 'Два', 'Три'],
            selectedIndex: 0,
            onSelected: (i) => selected = i,
          ),
        ),
      );
      await tester.pump();

      await tester.tap(find.text('Два'));
      await tester.pump();

      expect(selected, 1);
    });

    testWidgets('onSelected fires with correct index on third option', (tester) async {
      int? selected;
      await tester.pumpWidget(
        buildTestWidget(
          KaiSegmentedControl(
            options: const ['RU', 'EN', 'ES'],
            selectedIndex: 1,
            onSelected: (i) => selected = i,
          ),
        ),
      );
      await tester.pump();

      await tester.tap(find.text('ES'));
      await tester.pump();

      expect(selected, 2);
    });

    testWidgets('onSelected fires with index 0 when first option is tapped', (tester) async {
      int? selected;
      await tester.pumpWidget(
        buildTestWidget(
          KaiSegmentedControl(
            options: const ['Светлая', 'Тёмная'],
            selectedIndex: 1,
            onSelected: (i) => selected = i,
          ),
        ),
      );
      await tester.pump();

      await tester.tap(find.text('Светлая'));
      await tester.pump();

      expect(selected, 0);
    });

    // -------------------------------------------------------------------------
    // Track container has rounded corners (tokenised: KaiRadius.br8 = 8px)
    // -------------------------------------------------------------------------

    testWidgets('track container uses br8 radius (8px)', (tester) async {
      await tester.pumpWidget(
        buildTestWidget(
          KaiSegmentedControl(
            options: const ['A', 'B'],
            selectedIndex: 0,
            onSelected: (_) {},
          ),
        ),
      );
      await tester.pump();

      final containers = tester
          .widgetList<Container>(find.byType(Container))
          .toList();

      const expectedRadius = BorderRadius.all(Radius.circular(8));
      final hasExpected = containers.any((c) {
        final deco = c.decoration;
        if (deco is! BoxDecoration) return false;
        return deco.borderRadius == expectedRadius;
      });

      expect(hasExpected, isTrue,
          reason: 'track must use KaiRadius.br8 (8px) borderRadius',);
    });

    // -------------------------------------------------------------------------
    // Full combination
    // -------------------------------------------------------------------------

    testWidgets('renders all options and fires callback', (tester) async {
      int? selected;
      await tester.pumpWidget(
        buildTestWidget(
          KaiSegmentedControl(
            options: const ['День', 'Ночь'],
            selectedIndex: 0,
            onSelected: (i) => selected = i,
          ),
        ),
      );
      await tester.pump();

      expect(find.text('День'), findsOneWidget);
      expect(find.text('Ночь'), findsOneWidget);

      await tester.tap(find.text('Ночь'));
      await tester.pump();

      expect(selected, 1);
    });
  });
}
