import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:kai_app/design_system/atoms/kai_button.dart';
import 'package:kai_app/design_system/atoms/kai_tide_curve.dart';
import 'package:kai_app/design_system/molecules/kai_care_block.dart';
import 'package:kai_app/design_system/organisms/kai_edge_state_block.dart';

import '../../test_helpers.dart';

Future<void> _pump(
  WidgetTester tester,
  Widget child, {
  ThemeMode mode = ThemeMode.light,
}) async {
  await tester.pumpWidget(
    buildTestWidget(SingleChildScrollView(child: child), themeMode: mode),
  );
  await tester.pump();
}

void main() {
  group('KaiEdgeStateBlock', () {
    // ── offline surface ──────────────────────────────────────────────────────

    group('offline surface', () {
      testWidgets('renders without error', (WidgetTester tester) async {
        await _pump(
          tester,
          const KaiEdgeStateBlock(surface: KaiEdgeSurface.offline),
        );
        expect(find.byType(KaiEdgeStateBlock), findsOneWidget);
        expect(find.text('Нет сети'), findsOneWidget);
      });

      testWidgets('shows body copy', (WidgetTester tester) async {
        await _pump(
          tester,
          const KaiEdgeStateBlock(surface: KaiEdgeSurface.offline),
        );
        expect(
          find.text(
            'Отправлю, когда выйдете в онлайн. Очередь сохранена.',
          ),
          findsOneWidget,
        );
      });

      testWidgets('retry is a KaiButton', (WidgetTester tester) async {
        await _pump(
          tester,
          KaiEdgeStateBlock(
            surface: KaiEdgeSurface.offline,
            onRetry: () {},
          ),
        );
        expect(find.byType(KaiButton), findsOneWidget);
      });

      testWidgets('retry KaiButton fires onRetry callback',
          (WidgetTester tester) async {
        var retries = 0;
        await _pump(
          tester,
          KaiEdgeStateBlock(
            surface: KaiEdgeSurface.offline,
            onRetry: () => retries++,
          ),
        );
        await tester.tap(find.text('повторить'));
        await tester.pump();
        await tester.pump(const Duration(milliseconds: 50));
        expect(retries, 1);
      });

      testWidgets('does not render KaiTideCurve (Zero-UI)',
          (WidgetTester tester) async {
        await _pump(
          tester,
          const KaiEdgeStateBlock(surface: KaiEdgeSurface.offline),
        );
        expect(find.byType(KaiTideCurve), findsNothing);
      });
    });

    // ── error surface ────────────────────────────────────────────────────────

    group('error surface', () {
      testWidgets('renders without error', (WidgetTester tester) async {
        await _pump(
          tester,
          const KaiEdgeStateBlock(surface: KaiEdgeSurface.error),
        );
        expect(find.byType(KaiEdgeStateBlock), findsOneWidget);
        expect(find.text('Не удалось ответить'), findsOneWidget);
      });

      testWidgets('does not contain KaiTideCurve', (WidgetTester tester) async {
        await _pump(
          tester,
          const KaiEdgeStateBlock(surface: KaiEdgeSurface.error),
        );
        expect(find.byType(KaiTideCurve), findsNothing);
      });

      testWidgets('retry is a KaiButton', (WidgetTester tester) async {
        await _pump(
          tester,
          KaiEdgeStateBlock(
            surface: KaiEdgeSurface.error,
            onRetry: () {},
          ),
        );
        expect(find.byType(KaiButton), findsOneWidget);
      });

      testWidgets('retry KaiButton fires onRetry callback',
          (WidgetTester tester) async {
        var retries = 0;
        await _pump(
          tester,
          KaiEdgeStateBlock(
            surface: KaiEdgeSurface.error,
            onRetry: () => retries++,
          ),
        );
        await tester.tap(find.text('повторить'));
        await tester.pump();
        await tester.pump(const Duration(milliseconds: 50));
        expect(retries, 1);
      });
    });

    // ── rateLimit surface ────────────────────────────────────────────────────

    group('rateLimit surface', () {
      testWidgets('renders without error', (WidgetTester tester) async {
        await _pump(
          tester,
          const KaiEdgeStateBlock(surface: KaiEdgeSurface.rateLimit),
        );
        expect(find.byType(KaiEdgeStateBlock), findsOneWidget);
        expect(find.text('Слишком много запросов'), findsOneWidget);
      });

      testWidgets('plans button is a KaiButton', (WidgetTester tester) async {
        await _pump(
          tester,
          KaiEdgeStateBlock(
            surface: KaiEdgeSurface.rateLimit,
            onPlans: () {},
          ),
        );
        expect(find.byType(KaiButton), findsOneWidget);
      });

      testWidgets('plans KaiButton fires onPlans callback',
          (WidgetTester tester) async {
        var plansTaps = 0;
        await _pump(
          tester,
          KaiEdgeStateBlock(
            surface: KaiEdgeSurface.rateLimit,
            onPlans: () => plansTaps++,
          ),
        );
        await tester.tap(find.text('Посмотреть планы'));
        await tester.pump();
        await tester.pump(const Duration(milliseconds: 50));
        expect(plansTaps, 1);
      });

      testWidgets('shows countdown when provided', (WidgetTester tester) async {
        await _pump(
          tester,
          const KaiEdgeStateBlock(
            surface: KaiEdgeSurface.rateLimit,
            countdown: Duration(seconds: 42),
          ),
        );
        expect(find.textContaining('42 сек'), findsOneWidget);
      });

      testWidgets('hides countdown when null', (WidgetTester tester) async {
        await _pump(
          tester,
          const KaiEdgeStateBlock(surface: KaiEdgeSurface.rateLimit),
        );
        expect(find.textContaining('сек'), findsNothing);
      });
    });

    // ── crisis surface ───────────────────────────────────────────────────────

    group('crisis surface', () {
      testWidgets('renders without error', (WidgetTester tester) async {
        await _pump(
          tester,
          const KaiEdgeStateBlock(surface: KaiEdgeSurface.crisis),
        );
        expect(find.byType(KaiEdgeStateBlock), findsOneWidget);
      });

      testWidgets('embeds KaiCareBlock', (WidgetTester tester) async {
        await _pump(
          tester,
          const KaiEdgeStateBlock(surface: KaiEdgeSurface.crisis),
        );
        expect(find.byType(KaiCareBlock), findsOneWidget);
      });

      testWidgets('KaiCareBlock shows heading', (WidgetTester tester) async {
        await _pump(
          tester,
          const KaiEdgeStateBlock(surface: KaiEdgeSurface.crisis),
        );
        expect(find.text('Я слышу тебя.'), findsOneWidget);
      });

      testWidgets('does not contain KaiTideCurve (Zero-UI)',
          (WidgetTester tester) async {
        await _pump(
          tester,
          const KaiEdgeStateBlock(surface: KaiEdgeSurface.crisis),
        );
        expect(find.byType(KaiTideCurve), findsNothing);
      });

      testWidgets('shows two KaiCareResource numbers',
          (WidgetTester tester) async {
        await _pump(
          tester,
          const KaiEdgeStateBlock(surface: KaiEdgeSurface.crisis),
        );
        expect(find.text('8 800 2000 122'), findsOneWidget);
        expect(find.text('Текст HOME на 741741'), findsOneWidget);
      });
    });

    // ── dark mode smoke ──────────────────────────────────────────────────────

    testWidgets('dark mode renders offline without error',
        (WidgetTester tester) async {
      await _pump(
        tester,
        const KaiEdgeStateBlock(surface: KaiEdgeSurface.offline),
        mode: ThemeMode.dark,
      );
      expect(find.text('Нет сети'), findsOneWidget);
    });
  });
}
