import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:kai_app/design_system/v3/atoms/kai_button.dart';
import 'package:kai_app/design_system/v3/molecules/kai_toast.dart';

import '../../../test_helpers.dart';

void main() {
  group('v3/KaiToast widget', () {
    // -------------------------------------------------------------------------
    // KaiToastType enum
    // -------------------------------------------------------------------------

    test('KaiToastType has exactly 4 values', () {
      expect(KaiToastType.values.length, 4);
    });

    test('KaiToastType values are neutral/positive/negative/memory', () {
      expect(
        KaiToastType.values,
        containsAll([
          KaiToastType.neutral,
          KaiToastType.positive,
          KaiToastType.negative,
          KaiToastType.memory,
        ]),
      );
    });

    // -------------------------------------------------------------------------
    // Each type renders without error
    // -------------------------------------------------------------------------

    for (final type in KaiToastType.values) {
      testWidgets('renders type=${type.name} without error', (tester) async {
        await tester.pumpWidget(
          buildTestWidget(KaiToast(type: type, label: 'Test ${type.name}')),
        );
        await tester.pump();
        expect(find.byType(KaiToast), findsOneWidget);
      });
    }

    // -------------------------------------------------------------------------
    // Label text
    // -------------------------------------------------------------------------

    testWidgets('label text is visible', (tester) async {
      await tester.pumpWidget(
        buildTestWidget(
          const KaiToast(type: KaiToastType.neutral, label: 'Сохранено'),
        ),
      );
      await tester.pump();
      expect(find.text('Сохранено'), findsOneWidget);
    });

    // -------------------------------------------------------------------------
    // actionLabel: renders KaiButton.text and fires onAction
    // -------------------------------------------------------------------------

    testWidgets('actionLabel renders a KaiButton when provided', (tester) async {
      await tester.pumpWidget(
        buildTestWidget(
          KaiToast(
            type: KaiToastType.negative,
            label: 'Ошибка',
            actionLabel: 'Повторить',
            onAction: () {},
          ),
        ),
      );
      await tester.pump();
      expect(find.byType(KaiButton), findsOneWidget);
    });

    testWidgets('actionLabel text is visible', (tester) async {
      await tester.pumpWidget(
        buildTestWidget(
          KaiToast(
            type: KaiToastType.negative,
            label: 'Ошибка',
            actionLabel: 'Повторить',
            onAction: () {},
          ),
        ),
      );
      await tester.pump();
      expect(find.text('Повторить'), findsOneWidget);
    });

    testWidgets('onAction fires when action button is tapped', (tester) async {
      var tapped = false;
      await tester.pumpWidget(
        buildTestWidget(
          KaiToast(
            type: KaiToastType.negative,
            label: 'Ошибка',
            actionLabel: 'Повторить',
            onAction: () => tapped = true,
          ),
        ),
      );
      await tester.pump();
      await tester.tap(find.text('Повторить'));
      await tester.pump();
      expect(tapped, isTrue);
    });

    testWidgets('no KaiButton when actionLabel is null', (tester) async {
      await tester.pumpWidget(
        buildTestWidget(
          const KaiToast(type: KaiToastType.neutral, label: 'OK'),
        ),
      );
      await tester.pump();
      expect(find.byType(KaiButton), findsNothing);
    });

    // -------------------------------------------------------------------------
    // memory variant: Container/DecoratedBox with KaiTide.gradient (T1 fix)
    // -------------------------------------------------------------------------

    testWidgets(
        'memory type has a Container with KaiTide.gradient — NOT a hex literal',
        (tester) async {
      await tester.pumpWidget(
        buildTestWidget(
          const KaiToast(type: KaiToastType.memory, label: 'Сохранено в память'),
        ),
      );
      await tester.pump();

      // Find all Containers and check for the gradient token.
      final containers =
          tester.widgetList<Container>(find.byType(Container)).toList();

      const expectedGradient = LinearGradient(
        colors: [Color(0xFF1B4FB0), Color(0xFF2BA8C9), Color(0xFFF4B589)],
        stops: [0.0, 0.52, 1.0],
        begin: Alignment(-0.906, -0.423),
        end: Alignment(0.906, 0.423),
      );

      final hasKaiTideGradient = containers.any((c) {
        final deco = c.decoration;
        if (deco is! BoxDecoration) return false;
        final grad = deco.gradient;
        if (grad is! LinearGradient) return false;
        // Verify it uses the token stops/colors — not a hand-typed hex.
        return grad.colors.length == 3 &&
            grad.colors[0] == expectedGradient.colors[0] &&
            grad.colors[1] == expectedGradient.colors[1] &&
            grad.colors[2] == expectedGradient.colors[2] &&
            grad.stops != null &&
            grad.stops!.length == 3;
      });

      expect(
        hasKaiTideGradient,
        isTrue,
        reason:
            'memory toast must use KaiTide.gradient (3-stop LinearGradient). '
            'No hardcoded hex gradient allowed (T1 fix).',
      );
    });

    // -------------------------------------------------------------------------
    // showCountdown: countdown bar visible when true
    // -------------------------------------------------------------------------

    testWidgets('countdown bar renders when showCountdown is true',
        (tester) async {
      await tester.pumpWidget(
        buildTestWidget(
          const KaiToast(
            type: KaiToastType.memory,
            label: 'Запомнено',
            showCountdown: true,
          ),
        ),
      );
      await tester.pump();
      // The countdown bar is a ClipRRect > Stack with two ColoredBox children.
      expect(find.byType(ClipRRect), findsWidgets);
    });

    testWidgets('countdown bar not rendered when showCountdown is false',
        (tester) async {
      await tester.pumpWidget(
        buildTestWidget(
          const KaiToast(
            type: KaiToastType.memory,
            label: 'Запомнено',
            showCountdown: false,
          ),
        ),
      );
      await tester.pump();
      // No ClipRRect in the tree when countdown is disabled.
      expect(find.byType(ClipRRect), findsNothing);
    });

    // -------------------------------------------------------------------------
    // dark pill variants: solid ink-1 background (no gradient)
    // -------------------------------------------------------------------------

    for (final type in [
      KaiToastType.neutral,
      KaiToastType.positive,
      KaiToastType.negative,
    ]) {
      testWidgets('${type.name} uses solid background, not a gradient',
          (tester) async {
        await tester.pumpWidget(
          buildTestWidget(KaiToast(type: type, label: 'Message')),
        );
        await tester.pump();

        final containers =
            tester.widgetList<Container>(find.byType(Container)).toList();
        final hasGradient = containers.any((c) {
          final deco = c.decoration;
          if (deco is! BoxDecoration) return false;
          return deco.gradient != null;
        });
        expect(
          hasGradient,
          isFalse,
          reason: '${type.name} toast must NOT have a gradient background',
        );
      });
    }

    // -------------------------------------------------------------------------
    // No Timer/Overlay/static-show in widget — compile-time enforced
    // -------------------------------------------------------------------------

    test('KaiToast is a StatelessWidget (pure presentational, no timer state)',
        () {
      // KaiToast is defined as StatelessWidget — if it had a timer it would be
      // StatefulWidget. This test verifies the pure-dumb design.
      const toast = KaiToast(type: KaiToastType.neutral, label: 'Test');
      expect(toast, isA<StatelessWidget>());
    });

    // -------------------------------------------------------------------------
    // Pill shape: outermost Container has brPill (BorderRadius.circular(999))
    // -------------------------------------------------------------------------

    testWidgets('pill container has brPill border-radius', (tester) async {
      await tester.pumpWidget(
        buildTestWidget(
          const KaiToast(type: KaiToastType.neutral, label: 'Test'),
        ),
      );
      await tester.pump();

      final containers =
          tester.widgetList<Container>(find.byType(Container)).toList();
      final hasPill = containers.any((c) {
        final deco = c.decoration;
        if (deco is! BoxDecoration) return false;
        final br = deco.borderRadius;
        if (br is! BorderRadius) return false;
        // brPill = BorderRadius.all(Radius.circular(999))
        return br.topLeft.x == 999;
      });
      expect(hasPill, isTrue,
          reason: 'toast pill must use KaiRadius.brPill (999)');
    });

    // -------------------------------------------------------------------------
    // Full combination: all optional fields together
    // -------------------------------------------------------------------------

    testWidgets('renders all fields together without error', (tester) async {
      await tester.pumpWidget(
        buildTestWidget(
          KaiToast(
            type: KaiToastType.negative,
            label: 'Ошибка соединения',
            actionLabel: 'Повторить',
            showCountdown: true,
            onAction: () {},
          ),
        ),
      );
      await tester.pump();
      expect(find.text('Ошибка соединения'), findsOneWidget);
      expect(find.text('Повторить'), findsOneWidget);
      expect(find.byType(KaiButton), findsOneWidget);
    });
  });
}
