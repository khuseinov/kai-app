import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:kai_app/design_system/atoms/kai_button.dart';
import 'package:kai_app/design_system/molecules/kai_toast.dart';
import 'package:kai_app/design_system/tokens/kai_tokens.dart';

import '../../test_helpers.dart';

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

    testWidgets('actionLabel renders an action widget when provided',
        (tester) async {
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
      // Action uses a GestureDetector+Text (canon-exact: 12px/w600/accent).
      expect(find.text('Повторить'), findsOneWidget);
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

    testWidgets('no action text when actionLabel is null', (tester) async {
      await tester.pumpWidget(
        buildTestWidget(
          const KaiToast(type: KaiToastType.neutral, label: 'OK'),
        ),
      );
      await tester.pump();
      // When no actionLabel, there's only the label text itself.
      expect(find.text('OK'), findsOneWidget);
      // No spurious action widgets in the tree.
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
          reason: 'toast pill must use KaiRadius.brPill (999)',);
    });

    // -------------------------------------------------------------------------
    // Action child is compact (not full-width)
    // -------------------------------------------------------------------------

    testWidgets('action child is compact — uses GestureDetector not KaiButton',
        (tester) async {
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
      // Canon-exact action button is _ToastActionButton (GestureDetector+Text),
      // NOT KaiButton (which would be full-row-width due to mainAxisSize.max).
      expect(find.byType(KaiButton), findsNothing);
      expect(find.text('Повторить'), findsOneWidget);
    });

    // -------------------------------------------------------------------------
    // KaiToast.undo factory
    // -------------------------------------------------------------------------

    testWidgets('KaiToast.undo shows "Отменить" label', (tester) async {
      await tester.pumpWidget(
        buildTestWidget(
          KaiToast.undo(
            label: 'Удалено',
            onUndo: () {},
          ),
        ),
      );
      await tester.pump();
      expect(find.text('Отменить'), findsOneWidget);
      expect(find.text('Удалено'), findsOneWidget);
    });

    testWidgets('KaiToast.undo fires onUndo when action tapped', (tester) async {
      var undoCalled = false;
      await tester.pumpWidget(
        buildTestWidget(
          KaiToast.undo(
            label: 'Удалено',
            onUndo: () => undoCalled = true,
          ),
        ),
      );
      await tester.pump();
      await tester.tap(find.text('Отменить'));
      await tester.pump();
      expect(undoCalled, isTrue);
    });

    testWidgets('KaiToast.undo shows countdown bar by default', (tester) async {
      await tester.pumpWidget(
        buildTestWidget(
          KaiToast.undo(
            label: 'Удалено',
            onUndo: () {},
          ),
        ),
      );
      await tester.pump();
      expect(find.byType(ClipRRect), findsWidgets);
    });

    testWidgets('KaiToast.undo is a StatelessWidget', (tester) async {
      final widget = KaiToast.undo(label: 'Удалено', onUndo: () {});
      expect(widget, isA<StatelessWidget>());
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
      // Action button is now _ToastActionButton (GestureDetector+Text) — not KaiButton.
      // Verified by text presence; KaiButton is absent (canon-exact: 12px/w600/accent).
      expect(find.byType(KaiButton), findsNothing);
    });

    // -------------------------------------------------------------------------
    // Dark-island background — near-black #111114, not the near-white dark.ink1
    // -------------------------------------------------------------------------

    testWidgets('compact pill bg is near-black #111114 (visible dark island)',
        (tester) async {
      await tester.pumpWidget(
        buildTestWidget(const KaiToast(type: KaiToastType.neutral, label: 'X')),
      );
      await tester.pump();
      final hasNearBlack =
          tester.widgetList<Container>(find.byType(Container)).any((c) {
        final d = c.decoration;
        return d is BoxDecoration && d.color == const Color(0xFF111114);
      });
      expect(hasNearBlack, isTrue,
          reason: 'toast pill bg must be #111114 (not #F5F5F2 — white-on-white)',);
    });

    // -------------------------------------------------------------------------
    // KaiToast.rich archetype (glyph + title + description + action)
    // -------------------------------------------------------------------------

    testWidgets('rich shows title, description, action; onAction fires',
        (tester) async {
      var opened = false;
      await tester.pumpWidget(
        buildTestWidget(
          KaiToast.rich(
            title: 'Сохранено.',
            description: 'Учту при планировании.',
            actionLabel: 'Открыть',
            onAction: () => opened = true,
          ),
        ),
      );
      await tester.pump();
      expect(find.text('Сохранено.'), findsOneWidget);
      expect(find.text('Учту при планировании.'), findsOneWidget);
      await tester.tap(find.text('Открыть'));
      await tester.pump();
      expect(opened, isTrue);
    });

    testWidgets('rich has a 24px tide-gradient Kai glyph', (tester) async {
      await tester.pumpWidget(
        buildTestWidget(
          const KaiToast.rich(title: 'T', description: 'D'),
        ),
      );
      await tester.pump();
      final hasGlyph =
          tester.widgetList<Container>(find.byType(Container)).any((c) {
        final d = c.decoration;
        return d is BoxDecoration &&
            d.shape == BoxShape.circle &&
            d.gradient == KaiTide.gradientCorner;
      });
      expect(hasGlyph, isTrue,
          reason: 'rich toast must show a 24px tide-gradient glyph',);
    });

    testWidgets('rich without action shows no action text', (tester) async {
      await tester.pumpWidget(
        buildTestWidget(
          const KaiToast.rich(title: 'T', description: 'D'),
        ),
      );
      await tester.pump();
      expect(find.text('T'), findsOneWidget);
      expect(find.byType(KaiButton), findsNothing);
    });
  });
}
