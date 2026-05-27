import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:kai_app/core/providers/root.dart';
import 'package:kai_app/design_system/molecules/kai_toast.dart';
import 'package:kai_app/design_system/theme/kai_theme.dart';
import 'package:kai_app/design_system/tokens/kai_tokens.dart';

Future<void> _pump(
  WidgetTester tester,
  Widget child, {
  ThemeMode mode = ThemeMode.light,
}) async {
  await tester.pumpWidget(
    ProviderScope(
      overrides: <Override>[
        themeModeProvider.overrideWith((ref) => mode),
      ],
      child: MaterialApp(
        home: KaiTheme(
          child: Scaffold(body: Center(child: child)),
        ),
      ),
    ),
  );
  // One frame for InheritedWidget + initState, one to start entrance.
  await tester.pump();
}

/// Resolve the first Container's BoxDecoration inside a KaiToast.
BoxDecoration _pillDecoration(WidgetTester tester) {
  final container = tester.widget<Container>(
    find
        .descendant(
          of: find.byType(KaiToast),
          matching: find.byType(Container),
        )
        .first,
  );
  return container.decoration! as BoxDecoration;
}

void main() {
  group('KaiToast', () {
    testWidgets('neutral renders label', (tester) async {
      await _pump(
        tester,
        const KaiToast(
          type: KaiToastType.neutral,
          label: 'Скопировано',
        ),
      );
      expect(find.text('Скопировано'), findsOneWidget);
    });

    testWidgets('neutral uses dark ink1 background', (tester) async {
      await _pump(
        tester,
        const KaiToast(
          type: KaiToastType.neutral,
          label: 'Скопировано',
        ),
      );
      final dec = _pillDecoration(tester);
      expect(dec.color, KaiTokens.dark.colors.ink1);
      expect(dec.gradient, isNull);
    });

    testWidgets('positive uses dark ink1 background', (tester) async {
      await _pump(
        tester,
        const KaiToast(
          type: KaiToastType.positive,
          label: 'Факт сохранён',
        ),
      );
      final dec = _pillDecoration(tester);
      expect(dec.color, KaiTokens.dark.colors.ink1);
      expect(dec.gradient, isNull);
      expect(find.text('Факт сохранён'), findsOneWidget);
    });

    testWidgets('negative renders action label and fires onAction',
        (tester) async {
      var taps = 0;
      await _pump(
        tester,
        KaiToast(
          type: KaiToastType.negative,
          label: 'Не отправлено',
          actionLabel: 'Повторить',
          onAction: () => taps++,
        ),
      );
      expect(find.text('Не отправлено'), findsOneWidget);
      expect(find.text('Повторить'), findsOneWidget);
      await tester.tap(find.text('Повторить'));
      await tester.pump();
      expect(taps, 1);
    });

    testWidgets('memory uses tide gradient (not solid colour)',
        (tester) async {
      await _pump(
        tester,
        const KaiToast(
          type: KaiToastType.memory,
          label: 'Kai запомнил',
        ),
      );
      final dec = _pillDecoration(tester);
      expect(dec.color, isNull);
      expect(dec.gradient, isA<LinearGradient>());
      final gradient = dec.gradient! as LinearGradient;
      expect(gradient.colors, [
        const Color(0xFF1B4FB0),
        const Color(0xFF2BA8C9),
        const Color(0xFFF4B589),
      ]);
      expect(gradient.stops, [0.0, 0.52, 1.0]);
    });

    testWidgets('memory shows countdown bar; others do not', (tester) async {
      // Memory: should find a FractionallySizedBox (countdown bar fill).
      await _pump(
        tester,
        const KaiToast(
          type: KaiToastType.memory,
          label: 'Kai запомнил',
        ),
      );
      expect(find.byType(FractionallySizedBox), findsOneWidget);

      // Neutral: no countdown bar.
      await _pump(
        tester,
        const KaiToast(
          type: KaiToastType.neutral,
          label: 'Скопировано',
        ),
      );
      expect(find.byType(FractionallySizedBox), findsNothing);
    });

    testWidgets('auto-dismiss fires for non-negative variants',
        (tester) async {
      var dismissed = false;
      await _pump(
        tester,
        KaiToast(
          type: KaiToastType.positive,
          label: 'Готово',
          duration: const Duration(milliseconds: 500),
          onDismissRequested: () => dismissed = true,
        ),
      );
      expect(dismissed, isFalse);
      // Past the duration — timer should have fired.
      await tester.pump(const Duration(milliseconds: 600));
      expect(dismissed, isTrue);
    });

    testWidgets('negative does NOT auto-dismiss', (tester) async {
      var dismissed = false;
      await _pump(
        tester,
        KaiToast(
          type: KaiToastType.negative,
          label: 'Не отправлено',
          actionLabel: 'Повторить',
          duration: const Duration(milliseconds: 200),
          onDismissRequested: () => dismissed = true,
        ),
      );
      await tester.pump(const Duration(milliseconds: 500));
      expect(
        dismissed,
        isFalse,
        reason: 'Negative pill must stick until user taps action',
      );
    });

    testWidgets('action tap on negative triggers dismiss', (tester) async {
      var dismissed = false;
      await _pump(
        tester,
        KaiToast(
          type: KaiToastType.negative,
          label: 'Не отправлено',
          actionLabel: 'Повторить',
          onAction: () {},
          onDismissRequested: () => dismissed = true,
        ),
      );
      await tester.tap(find.text('Повторить'));
      await tester.pump();
      expect(dismissed, isTrue);
    });

    testWidgets('pill has soft drop shadow', (tester) async {
      await _pump(
        tester,
        const KaiToast(
          type: KaiToastType.neutral,
          label: 'Скопировано',
        ),
      );
      final dec = _pillDecoration(tester);
      expect(dec.boxShadow, isNotNull);
      expect(dec.boxShadow!.length, 1);
      final shadow = dec.boxShadow!.first;
      // Canon: 0 2px 12px rgba(0,0,0,0.16)
      expect(shadow.offset, const Offset(0, 2));
      expect(shadow.blurRadius, 12);
    });

    testWidgets('pill uses 999 pill radius', (tester) async {
      await _pump(
        tester,
        const KaiToast(
          type: KaiToastType.neutral,
          label: 'Скопировано',
        ),
      );
      final dec = _pillDecoration(tester);
      final radius = dec.borderRadius! as BorderRadius;
      expect(radius.topLeft, const Radius.circular(999));
    });
  });
}
