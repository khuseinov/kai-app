import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:kai_app/design_system/atoms/kai_tide_curve.dart';
import 'package:kai_app/design_system/molecules/care_block.dart';
import 'package:kai_app/design_system/organisms/edge_state_block.dart';

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
  group('EdgeStateBlock', () {
    group('offline surface', () {
      testWidgets('renders without error', (WidgetTester tester) async {
        await _pump(
          tester,
          const EdgeStateBlock(surface: EdgeSurface.offline),
        );
        expect(find.byType(EdgeStateBlock), findsOneWidget);
        expect(find.text('Нет сети'), findsOneWidget);
      });

      // Canon: H4 — offline shows warning-wash bg + body copy
      testWidgets('shows body copy', (WidgetTester tester) async {
        await _pump(
          tester,
          const EdgeStateBlock(surface: EdgeSurface.offline),
        );
        expect(
          find.text(
            'Отправлю, когда выйдете в онлайн. Очередь сохранена.',
          ),
          findsOneWidget,
        );
      });

      testWidgets('retry button fires onRetry', (WidgetTester tester) async {
        var retries = 0;
        await _pump(
          tester,
          EdgeStateBlock(
            surface: EdgeSurface.offline,
            onRetry: () => retries++,
          ),
        );
        await tester.tap(find.text('повторить'));
        await tester.pumpAndSettle();
        expect(retries, 1);
      });
    });

    group('error surface', () {
      testWidgets('renders without error', (WidgetTester tester) async {
        await _pump(
          tester,
          const EdgeStateBlock(surface: EdgeSurface.error),
        );
        expect(find.byType(EdgeStateBlock), findsOneWidget);
        expect(find.text('Не удалось ответить'), findsOneWidget);
      });

      // Canon: H2 — _ErrorSurface must NOT render an internal KaiTideCurve.
      // Tide lives at the top of the screen only (Zero-UI rule).
      testWidgets('does not contain KaiTideCurve', (WidgetTester tester) async {
        await _pump(
          tester,
          const EdgeStateBlock(surface: EdgeSurface.error),
        );
        expect(find.byType(KaiTideCurve), findsNothing);
      });

      testWidgets('retry button fires onRetry', (WidgetTester tester) async {
        var retries = 0;
        await _pump(
          tester,
          EdgeStateBlock(
            surface: EdgeSurface.error,
            onRetry: () => retries++,
          ),
        );
        await tester.tap(find.text('повторить'));
        await tester.pump();
        expect(retries, 1);
      });
    });

    group('rateLimit surface', () {
      testWidgets('renders without error', (WidgetTester tester) async {
        await _pump(
          tester,
          const EdgeStateBlock(surface: EdgeSurface.rateLimit),
        );
        expect(find.byType(EdgeStateBlock), findsOneWidget);
        expect(find.text('Слишком много запросов'), findsOneWidget);
      });

      testWidgets('plans button fires onPlans', (WidgetTester tester) async {
        var plansTaps = 0;
        await _pump(
          tester,
          EdgeStateBlock(
            surface: EdgeSurface.rateLimit,
            onPlans: () => plansTaps++,
          ),
        );
        await tester.tap(find.text('Посмотреть планы'));
        await tester.pumpAndSettle();
        expect(plansTaps, 1);
      });

      // Canon: MEDIUM — rate-limit body with countdown uses "Сброс в X сек." prefix
      testWidgets('shows countdown when provided', (WidgetTester tester) async {
        await _pump(
          tester,
          const EdgeStateBlock(
            surface: EdgeSurface.rateLimit,
            countdown: Duration(seconds: 42),
          ),
        );
        expect(find.textContaining('42 сек'), findsOneWidget);
      });

      testWidgets('hides countdown when null', (WidgetTester tester) async {
        await _pump(
          tester,
          const EdgeStateBlock(surface: EdgeSurface.rateLimit),
        );
        expect(find.textContaining('сек'), findsNothing);
      });
    });

    group('crisis surface', () {
      testWidgets('renders without error', (WidgetTester tester) async {
        await _pump(
          tester,
          const EdgeStateBlock(surface: EdgeSurface.crisis),
        );
        expect(find.byType(EdgeStateBlock), findsOneWidget);
      });

      testWidgets('embeds CareBlock', (WidgetTester tester) async {
        await _pump(
          tester,
          const EdgeStateBlock(surface: EdgeSurface.crisis),
        );
        expect(find.byType(CareBlock), findsOneWidget);
      });

      testWidgets('CareBlock shows heading', (WidgetTester tester) async {
        await _pump(
          tester,
          const EdgeStateBlock(surface: EdgeSurface.crisis),
        );
        expect(find.text('Я слышу тебя.'), findsOneWidget);
      });

      // Canon: H3 — _CrisisSurface must NOT render an internal KaiTideCurve.
      testWidgets('does not contain KaiTideCurve', (WidgetTester tester) async {
        await _pump(
          tester,
          const EdgeStateBlock(surface: EdgeSurface.crisis),
        );
        expect(find.byType(KaiTideCurve), findsNothing);
      });

      // Canon: 4.7 — _CrisisSurface provides two CareResources.
      testWidgets('shows two CareResource numbers', (WidgetTester tester) async {
        await _pump(
          tester,
          const EdgeStateBlock(surface: EdgeSurface.crisis),
        );
        // RU locale: phone number "8 800 2000 122" and text line "Текст HOME на 741741"
        expect(find.text('8 800 2000 122'), findsOneWidget);
        expect(find.text('Текст HOME на 741741'), findsOneWidget);
      });
    });
  });
}
