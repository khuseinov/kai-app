import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:kai_app/core/providers/root.dart';
import 'package:kai_app/design_system/molecules/care_block.dart';
import 'package:kai_app/design_system/organisms/edge_state_block.dart';
import 'package:kai_app/design_system/theme/kai_theme.dart';

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
          child: Scaffold(body: SingleChildScrollView(child: child)),
        ),
      ),
    ),
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

      testWidgets('retry button fires onRetry', (WidgetTester tester) async {
        var retries = 0;
        await _pump(
          tester,
          EdgeStateBlock(
            surface: EdgeSurface.offline,
            onRetry: () => retries++,
          ),
        );
        await tester.tap(find.text('Повторить'));
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
        expect(find.text('Ошибка — попробуйте ещё раз'), findsOneWidget);
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
        // KaiTide.error is ephemeral and uses Future.delayed — avoid
        // pumpAndSettle which would time out waiting for the timer.
        // Pump a few frames to let the initial animation run, then tap.
        await tester.pump(const Duration(milliseconds: 100));
        await tester.tap(find.text('Продолжить'));
        await tester.pump();
        await tester.pump(const Duration(milliseconds: 50));
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

      testWidgets('shows countdown when provided', (WidgetTester tester) async {
        await _pump(
          tester,
          const EdgeStateBlock(
            surface: EdgeSurface.rateLimit,
            countdown: Duration(seconds: 42),
          ),
        );
        expect(find.text('42 сек'), findsOneWidget);
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
    });
  });
}
