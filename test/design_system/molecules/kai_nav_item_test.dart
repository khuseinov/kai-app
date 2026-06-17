import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:kai_app/design_system/atoms/kai_badge.dart';
import 'package:kai_app/design_system/primitives/kai_icon.dart';
import 'package:kai_app/features/nav/presentation/widgets/kai_nav_item.dart';

import '../../test_helpers.dart';

void main() {
  group('v3/KaiNavItem', () {
    // -------------------------------------------------------------------------
    // Basic rendering
    // -------------------------------------------------------------------------

    testWidgets('renders label text', (tester) async {
      await tester.pumpWidget(
        buildTestWidget(
          const KaiNavItem(label: 'Память'),
        ),
      );
      await tester.pump();
      expect(find.text('Память'), findsOneWidget);
    });

    testWidgets('renders with icon without error', (tester) async {
      await tester.pumpWidget(
        buildTestWidget(
          const KaiNavItem(label: 'Память', icon: KaiIconName.memory),
        ),
      );
      await tester.pump();
      expect(find.byType(KaiNavItem), findsOneWidget);
    });

    testWidgets('renders without icon without error', (tester) async {
      await tester.pumpWidget(
        buildTestWidget(
          const KaiNavItem(label: 'Чат'),
        ),
      );
      await tester.pump();
      expect(find.text('Чат'), findsOneWidget);
    });

    // -------------------------------------------------------------------------
    // Active state
    // -------------------------------------------------------------------------

    testWidgets('active=false renders without error', (tester) async {
      await tester.pumpWidget(
        buildTestWidget(
          const KaiNavItem(label: 'Настройки', active: false),
        ),
      );
      await tester.pump();
      expect(find.byType(KaiNavItem), findsOneWidget);
    });

    testWidgets('active=true renders without error', (tester) async {
      await tester.pumpWidget(
        buildTestWidget(
          const KaiNavItem(label: 'Настройки', active: true),
        ),
      );
      await tester.pump();
      expect(find.byType(KaiNavItem), findsOneWidget);
    });

    testWidgets('active item has accent-wash background (DecoratedBox)', (tester) async {
      await tester.pumpWidget(
        buildTestWidget(
          const KaiNavItem(label: 'Память', active: true),
        ),
      );
      await tester.pump();

      // accent-wash in light theme = Color(0xFFEEF2FD)
      const accentWashLight = Color(0xFFEEF2FD);

      final decoratedBoxes =
          tester.widgetList<DecoratedBox>(find.byType(DecoratedBox)).toList();

      final hasAccentWash = decoratedBoxes.any((db) {
        final deco = db.decoration;
        if (deco is! BoxDecoration) return false;
        return deco.color == accentWashLight;
      });

      expect(hasAccentWash, isTrue,
          reason: 'active nav item must have accent-wash background',);
    });

    // -------------------------------------------------------------------------
    // Trailing widget (badge dot)
    // -------------------------------------------------------------------------

    testWidgets('renders trailing KaiBadge.dot() when provided', (tester) async {
      await tester.pumpWidget(
        buildTestWidget(
          const KaiNavItem(
            label: 'Память',
            icon: KaiIconName.memory,
            trailing: KaiBadge.dot(),
          ),
        ),
      );
      await tester.pump();
      expect(find.byType(KaiBadge), findsOneWidget);
    });

    testWidgets('no trailing widget renders without error', (tester) async {
      await tester.pumpWidget(
        buildTestWidget(
          const KaiNavItem(label: 'Чат'),
        ),
      );
      await tester.pump();
      expect(find.byType(KaiBadge), findsNothing);
    });

    // -------------------------------------------------------------------------
    // onTap callback
    // -------------------------------------------------------------------------

    testWidgets('onTap fires when row is tapped', (tester) async {
      var tapped = false;
      await tester.pumpWidget(
        buildTestWidget(
          KaiNavItem(
            label: 'Новый чат',
            onTap: () => tapped = true,
          ),
        ),
      );
      await tester.pump();

      await tester.tap(find.text('Новый чат'));
      await tester.pump();

      expect(tapped, isTrue);
    });

    testWidgets('no onTap does not throw on render', (tester) async {
      await tester.pumpWidget(
        buildTestWidget(
          const KaiNavItem(label: 'Только просмотр'),
        ),
      );
      await tester.pump();
      expect(find.byType(KaiNavItem), findsOneWidget);
    });

    // -------------------------------------------------------------------------
    // Full combination
    // -------------------------------------------------------------------------

    testWidgets('renders all fields together without error', (tester) async {
      var tapped = false;
      await tester.pumpWidget(
        buildTestWidget(
          KaiNavItem(
            label: 'Память',
            icon: KaiIconName.memory,
            trailing: const KaiBadge.dot(),
            active: true,
            onTap: () => tapped = true,
          ),
        ),
      );
      await tester.pump();

      expect(find.text('Память'), findsOneWidget);
      expect(find.byType(KaiBadge), findsOneWidget);

      await tester.tap(find.text('Память'));
      await tester.pump();

      expect(tapped, isTrue);
    });
  });
}
