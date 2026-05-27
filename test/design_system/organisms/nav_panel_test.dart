import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:kai_app/core/providers/root.dart';
import 'package:kai_app/design_system/organisms/nav_panel.dart';
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
          child: Scaffold(body: child),
        ),
      ),
    ),
  );
  await tester.pump();
}

void main() {
  group('NavPanel', () {
    testWidgets('renders without error', (WidgetTester tester) async {
      await _pump(tester, const NavPanel());
      expect(find.byType(NavPanel), findsOneWidget);
    });

    testWidgets('shows "Kai" title', (WidgetTester tester) async {
      await _pump(tester, const NavPanel());
      expect(find.text('Kai'), findsOneWidget);
    });

    testWidgets('close button tap fires onClose', (WidgetTester tester) async {
      var closes = 0;
      await _pump(tester, NavPanel(onClose: () => closes++));
      // The close button is a 28×28 circle GestureDetector containing a
      // close icon. Find it by locating GestureDetectors with a small size
      // (the outer panel GestureDetector has a much larger hit area).
      // Strategy: find the close button by locating a Container with a 28×28
      // circular shape that contains the close KaiIcon.
      final closeIconFinder = find.descendant(
        of: find.byType(NavPanel),
        matching: find.byWidgetPredicate(
          (widget) =>
              widget is Container &&
              widget.constraints != null &&
              widget.constraints!.maxWidth == 28,
        ),
      );
      if (closeIconFinder.evaluate().isNotEmpty) {
        await tester.tap(closeIconFinder.first);
      } else {
        // Fallback: tap the second GestureDetector (first is the outer swipe handler)
        await tester.tap(find.byType(GestureDetector).at(1));
      }
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 50));
      expect(closes, 1);
    });

    testWidgets('new chat button fires onNewChat', (WidgetTester tester) async {
      var taps = 0;
      await _pump(
        tester,
        NavPanel(onNewChat: () => taps++),
      );
      await tester.tap(find.text('Новый чат'));
      await tester.pumpAndSettle();
      expect(taps, 1);
    });

    testWidgets('empty sessions shows "Нет чатов"',
        (WidgetTester tester) async {
      await _pump(tester, const NavPanel());
      expect(find.text('Нет чатов'), findsOneWidget);
    });

    testWidgets('session tap fires onSessionTap with correct id',
        (WidgetTester tester) async {
      String? tappedId;
      final sessions = [
        {'id': 'abc123', 'title': 'Планы на отпуск', 'date': '2026-01-01'},
        {'id': 'def456', 'title': 'Вопросы по визе', 'date': '2026-01-02'},
      ];
      await _pump(
        tester,
        NavPanel(
          sessions: sessions,
          onSessionTap: (id) => tappedId = id,
        ),
      );
      await tester.tap(find.text('Планы на отпуск'));
      await tester.pumpAndSettle();
      expect(tappedId, 'abc123');
    });

    testWidgets('second session tap fires correct id',
        (WidgetTester tester) async {
      String? tappedId;
      final sessions = [
        {'id': 'abc123', 'title': 'Сессия 1', 'date': '2026-01-01'},
        {'id': 'def456', 'title': 'Сессия 2', 'date': '2026-01-02'},
      ];
      await _pump(
        tester,
        NavPanel(
          sessions: sessions,
          onSessionTap: (id) => tappedId = id,
        ),
      );
      await tester.tap(find.text('Сессия 2'));
      await tester.pumpAndSettle();
      expect(tappedId, 'def456');
    });

    testWidgets('swipe-left gesture fires onClose',
        (WidgetTester tester) async {
      var closes = 0;
      await _pump(tester, NavPanel(onClose: () => closes++));

      // Simulate a right-to-left drag with sufficient velocity.
      await tester.fling(
        find.byType(NavPanel),
        const Offset(-300, 0),
        600, // pixels/second — exceeds 200 threshold
      );
      await tester.pumpAndSettle();
      expect(closes, 1);
    });

    testWidgets('shows apps section labels', (WidgetTester tester) async {
      await _pump(tester, const NavPanel());
      expect(find.text('Память'), findsOneWidget);
      expect(find.text('Настройки'), findsOneWidget);
    });

    testWidgets('shows account anchor with Anonymous label',
        (WidgetTester tester) async {
      await _pump(tester, const NavPanel());
      expect(find.text('Anonymous'), findsOneWidget);
      expect(find.text('Free'), findsOneWidget);
    });
  });
}
