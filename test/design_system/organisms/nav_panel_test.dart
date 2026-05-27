import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:kai_app/design_system/atoms/kai_icon.dart';
import 'package:kai_app/design_system/organisms/nav_panel.dart';

import '../../test_helpers.dart';

Future<void> _pump(
  WidgetTester tester,
  Widget child, {
  ThemeMode mode = ThemeMode.light,
}) async {
  await tester.pumpWidget(buildTestWidget(child, themeMode: mode));
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
      // Find the close button via the KaiIcon with KaiIconName.close — reliable
      // regardless of container size/constraints.
      final closeButton = find.ancestor(
        of: find.byWidgetPredicate(
          (w) => w is KaiIcon && w.name == KaiIconName.close,
        ),
        matching: find.byType(GestureDetector),
      ).first;
      await tester.tap(closeButton);
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
      final now = DateTime.now();
      final sessions = [
        SessionPreview(
          id: 'abc123',
          title: 'Планы на отпуск',
          timeLabel: '9:41',
          createdAt: now,
        ),
        SessionPreview(
          id: 'def456',
          title: 'Вопросы по визе',
          timeLabel: '10:00',
          createdAt: now,
        ),
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
      final now = DateTime.now();
      final sessions = [
        SessionPreview(
          id: 'abc123',
          title: 'Сессия 1',
          timeLabel: '9:41',
          createdAt: now,
        ),
        SessionPreview(
          id: 'def456',
          title: 'Сессия 2',
          timeLabel: '10:00',
          createdAt: now,
        ),
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
      // plan is rendered as .toUpperCase() → "FREE"
      expect(find.text('FREE'), findsOneWidget);
    });

    // H1: sessions > 7 days old must appear in "РАНЕЕ" bucket (not silently dropped)
    testWidgets('sessions older than 7 days appear in РАНЕЕ bucket',
        (WidgetTester tester) async {
      final old = DateTime.now().subtract(const Duration(days: 30));
      final sessions = [
        SessionPreview(
          id: 'old1',
          title: 'Старый чат',
          timeLabel: '3 апр',
          createdAt: old,
        ),
      ];
      await _pump(tester, NavPanel(sessions: sessions));
      // The session row should be visible.
      expect(find.text('Старый чат'), findsOneWidget);
      // Section label "РАНЕЕ" should be shown.
      expect(find.text('РАНЕЕ'), findsOneWidget);
    });

    // M3: future-dated sessions (clock skew) go into today bucket
    testWidgets('future-dated sessions (clock skew) appear in СЕГОДНЯ bucket',
        (WidgetTester tester) async {
      final future = DateTime.now().add(const Duration(hours: 2));
      final sessions = [
        SessionPreview(
          id: 'future1',
          title: 'Будущий чат',
          timeLabel: '23:59',
          createdAt: future,
        ),
      ];
      await _pump(tester, NavPanel(sessions: sessions));
      expect(find.text('Будущий чат'), findsOneWidget);
      expect(find.text('СЕГОДНЯ'), findsOneWidget);
    });

    // L2: TripInfo.initial truncated to first char — multi-char initial renders
    testWidgets('pinned trip shows only first char of initial',
        (WidgetTester tester) async {
      const trip = TripInfo(
        id: 't1',
        title: 'Токио',
        subtitle: '3 чата',
        initial: 'ТО', // Multi-char — should render only 'Т'
      );
      await _pump(tester, NavPanel(pinnedTrip: trip));
      expect(find.text('Т'), findsOneWidget);
      expect(find.text('ТО'), findsNothing);
    });
  });
}
