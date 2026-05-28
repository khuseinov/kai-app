import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:kai_app/design_system/organisms/nav_models.dart'
    show SessionPreview, TripInfo;
import 'package:kai_app/design_system/atoms/kai_badge.dart';
import 'package:kai_app/design_system/atoms/kai_button.dart';
import 'package:kai_app/design_system/molecules/kai_nav_item.dart';
import 'package:kai_app/design_system/organisms/kai_nav_panel.dart';
import 'package:kai_app/features/nav/session_groups.dart';

import '../../test_helpers.dart';

// ─── Helpers ─────────────────────────────────────────────────────────────────

/// Default Russian strings for all tests.
final _strings = KaiNavStrings.russian;

Future<void> _pump(
  WidgetTester tester,
  Widget child, {
  ThemeMode mode = ThemeMode.light,
}) async {
  await tester.pumpWidget(buildTestWidget(child, themeMode: mode));
  await tester.pump();
}

/// Returns a [KaiNavPanel] with [strings] and any optional overrides.
KaiNavPanel _panel({
  VoidCallback? onClose,
  VoidCallback? onNewChat,
  TripInfo? pinnedTrip,
  List<TripInfo> trips = const [],
  List<SessionPreview> sessions = const [],
  String? activeSessionId,
  ValueChanged<String>? onSessionTap,
  ValueChanged<String>? onTripTap,
  String accountInitial = 'A',
  String? accountName,
  String? accountPlan,
  VoidCallback? onAccountTap,
  VoidCallback? onMemoryTap,
  VoidCallback? onSettingsTap,
  bool hasUnseenMemory = false,
  DateTime? now,
}) {
  return KaiNavPanel(
    strings: _strings,
    onClose: onClose,
    onNewChat: onNewChat,
    pinnedTrip: pinnedTrip,
    trips: trips,
    sessions: sessions,
    activeSessionId: activeSessionId,
    onSessionTap: onSessionTap,
    onTripTap: onTripTap,
    accountInitial: accountInitial,
    accountName: accountName,
    accountPlan: accountPlan,
    onAccountTap: onAccountTap,
    onMemoryTap: onMemoryTap,
    onSettingsTap: onSettingsTap,
    hasUnseenMemory: hasUnseenMemory,
    now: now,
  );
}

/// A minimal set of today sessions for convenience.
List<SessionPreview> _todaySessions() {
  final now = DateTime.now();
  return [
    SessionPreview(
      id: 'ses1',
      title: 'Планы на отпуск',
      timeLabel: '9:41',
      createdAt: now,
    ),
    SessionPreview(
      id: 'ses2',
      title: 'Вопросы по визе',
      timeLabel: '10:00',
      createdAt: now,
    ),
  ];
}

void main() {
  group('KaiNavPanel', () {
    // ── Smoke ─────────────────────────────────────────────────────────────────

    testWidgets('renders without error', (WidgetTester tester) async {
      await _pump(tester, _panel());
      expect(find.byType(KaiNavPanel), findsOneWidget);
    });

    testWidgets('shows panel title from strings', (WidgetTester tester) async {
      await _pump(tester, _panel());
      expect(find.text('Kai'), findsOneWidget);
    });

    // ── New-chat button ───────────────────────────────────────────────────────

    testWidgets('renders new-chat as KaiButton (ink variant)',
        (WidgetTester tester) async {
      await _pump(tester, _panel());
      // KaiButton.ink is a KaiButton
      expect(find.byType(KaiButton), findsWidgets);
      // The label from strings is visible
      expect(find.text('Новый чат'), findsOneWidget);
    });

    testWidgets('new-chat button fires onNewChat callback',
        (WidgetTester tester) async {
      var taps = 0;
      await _pump(tester, _panel(onNewChat: () => taps++));
      await tester.tap(find.text('Новый чат'));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 50));
      expect(taps, 1);
    });

    // ── Close button ──────────────────────────────────────────────────────────

    testWidgets('close button fires onClose callback',
        (WidgetTester tester) async {
      var closes = 0;
      await _pump(tester, _panel(onClose: () => closes++));
      // Find GestureDetector containing the close icon via its position
      // (first GestureDetector wrapping the 28×28 circle).
      final closeContainers = find.ancestor(
        of: find.byWidgetPredicate(
          (w) => w is Container && w.constraints?.maxWidth == 28,
        ),
        matching: find.byType(GestureDetector),
      );
      await tester.tap(closeContainers.first);
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 50));
      expect(closes, 1);
    });

    testWidgets('swipe-left fires onClose callback',
        (WidgetTester tester) async {
      var closes = 0;
      await _pump(tester, _panel(onClose: () => closes++));
      await tester.fling(
        find.byType(KaiNavPanel),
        const Offset(-300, 0),
        600, // px/s — exceeds 200 threshold
      );
      await tester.pumpAndSettle();
      expect(closes, 1);
    });

    // ── Session rows ──────────────────────────────────────────────────────────

    testWidgets('session rows are rendered as KaiNavItem widgets',
        (WidgetTester tester) async {
      await _pump(tester, _panel(sessions: _todaySessions()));
      // Each session gets a KaiNavItem
      final items = tester.widgetList<KaiNavItem>(find.byType(KaiNavItem));
      // At least the two session rows (plus apps rows)
      expect(items.length, greaterThanOrEqualTo(2));
    });

    testWidgets('session titles are visible', (WidgetTester tester) async {
      await _pump(tester, _panel(sessions: _todaySessions()));
      expect(find.text('Планы на отпуск'), findsOneWidget);
      expect(find.text('Вопросы по визе'), findsOneWidget);
    });

    testWidgets('tapping a session row fires onSessionTap with correct id',
        (WidgetTester tester) async {
      String? tappedId;
      await _pump(
        tester,
        _panel(
          sessions: _todaySessions(),
          onSessionTap: (id) => tappedId = id,
        ),
      );
      await tester.tap(find.text('Планы на отпуск'));
      await tester.pumpAndSettle();
      expect(tappedId, 'ses1');
    });

    testWidgets('tapping second session fires correct id',
        (WidgetTester tester) async {
      String? tappedId;
      await _pump(
        tester,
        _panel(
          sessions: _todaySessions(),
          onSessionTap: (id) => tappedId = id,
        ),
      );
      await tester.tap(find.text('Вопросы по визе'));
      await tester.pumpAndSettle();
      expect(tappedId, 'ses2');
    });

    // ── Date bucket headers ───────────────────────────────────────────────────

    testWidgets('today sessions show СЕГОДНЯ section header',
        (WidgetTester tester) async {
      await _pump(tester, _panel(sessions: _todaySessions()));
      expect(find.text('СЕГОДНЯ'), findsOneWidget);
    });

    testWidgets('yesterday sessions show ВЧЕРА section header',
        (WidgetTester tester) async {
      // Pin the clock: a bare `now - 26h` is flaky — 26h before an early-morning
      // "now" lands two calendar days back, so it buckets as thisWeek not
      // yesterday. Inject a fixed `now` and build the fixture one calendar day
      // before it.
      final now = DateTime(2026, 6, 15, 12, 0);
      final yesterday = now.subtract(const Duration(days: 1));
      final sessions = [
        SessionPreview(
          id: 'y1',
          title: 'Вчерашний чат',
          timeLabel: '20:00',
          createdAt: yesterday,
        ),
      ];
      await _pump(tester, _panel(now: now, sessions: sessions));
      expect(find.text('ВЧЕРА'), findsOneWidget);
      expect(find.text('Вчерашний чат'), findsOneWidget);
    });

    testWidgets('sessions older than 7 days show РАНЕЕ section header',
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
      await _pump(tester, _panel(sessions: sessions));
      expect(find.text('РАНЕЕ'), findsOneWidget);
      expect(find.text('Старый чат'), findsOneWidget);
    });

    // ── Active session highlighting ───────────────────────────────────────────

    testWidgets('active session KaiNavItem has active=true',
        (WidgetTester tester) async {
      final sessions = _todaySessions();
      await _pump(
        tester,
        _panel(
          sessions: sessions,
          activeSessionId: 'ses1',
        ),
      );
      // Find all KaiNavItem widgets and verify one is active
      final navItems =
          tester.widgetList<KaiNavItem>(find.byType(KaiNavItem)).toList();
      final activeItem = navItems.where((item) => item.active).toList();
      expect(activeItem, hasLength(1));
      expect(activeItem.first.label, 'Планы на отпуск');
    });

    testWidgets('non-active sessions have active=false',
        (WidgetTester tester) async {
      final sessions = _todaySessions();
      await _pump(
        tester,
        _panel(
          sessions: sessions,
          activeSessionId: 'ses1',
        ),
      );
      final navItems =
          tester.widgetList<KaiNavItem>(find.byType(KaiNavItem)).toList();
      final inactiveSessionItems =
          navItems.where((item) => item.label == 'Вопросы по визе').toList();
      expect(inactiveSessionItems.single.active, isFalse);
    });

    // ── Empty state ───────────────────────────────────────────────────────────

    testWidgets('empty sessions with no trips shows "Нет чатов"',
        (WidgetTester tester) async {
      await _pump(tester, _panel());
      expect(find.text('Нет чатов'), findsOneWidget);
    });

    testWidgets('with sessions present "Нет чатов" is absent',
        (WidgetTester tester) async {
      await _pump(tester, _panel(sessions: _todaySessions()));
      expect(find.text('Нет чатов'), findsNothing);
    });

    // ── Memory notification dot ───────────────────────────────────────────────

    testWidgets('KaiBadge.dot is absent when hasUnseenMemory=false',
        (WidgetTester tester) async {
      await _pump(tester, _panel());
      expect(find.byType(KaiBadge), findsNothing);
    });

    testWidgets('KaiBadge.dot appears when hasUnseenMemory=true',
        (WidgetTester tester) async {
      await _pump(tester, _panel(hasUnseenMemory: true));
      expect(find.byType(KaiBadge), findsOneWidget);
    });

    // ── Apps section ──────────────────────────────────────────────────────────

    testWidgets('apps section shows Memory and Settings rows',
        (WidgetTester tester) async {
      await _pump(tester, _panel());
      expect(find.text('Память'), findsOneWidget);
      expect(find.text('Настройки'), findsOneWidget);
    });

    testWidgets('memory row tap fires onMemoryTap', (WidgetTester tester) async {
      var taps = 0;
      await _pump(tester, _panel(onMemoryTap: () => taps++));
      await tester.tap(find.text('Память'));
      await tester.pumpAndSettle();
      expect(taps, 1);
    });

    testWidgets('settings row tap fires onSettingsTap',
        (WidgetTester tester) async {
      var taps = 0;
      await _pump(tester, _panel(onSettingsTap: () => taps++));
      await tester.tap(find.text('Настройки'));
      await tester.pumpAndSettle();
      expect(taps, 1);
    });

    // ── Account anchor ────────────────────────────────────────────────────────

    testWidgets('account anchor shows anonymous name when no accountName',
        (WidgetTester tester) async {
      await _pump(tester, _panel());
      expect(find.text('Anonymous'), findsOneWidget);
    });

    testWidgets('account anchor shows provided name', (WidgetTester tester) async {
      await _pump(tester, _panel(accountName: 'Анна'));
      expect(find.text('Анна'), findsOneWidget);
    });

    testWidgets('account plan shown uppercased', (WidgetTester tester) async {
      await _pump(tester, _panel(accountPlan: 'free'));
      expect(find.text('FREE'), findsOneWidget);
    });

    testWidgets('account anchor tap fires onAccountTap',
        (WidgetTester tester) async {
      var taps = 0;
      await _pump(tester, _panel(onAccountTap: () => taps++));
      await tester.tap(find.text('Anonymous'));
      await tester.pumpAndSettle();
      expect(taps, 1);
    });

    // ── Trips section ─────────────────────────────────────────────────────────

    testWidgets('trips section shows trip titles', (WidgetTester tester) async {
      final trips = [
        const TripInfo(id: 't1', title: 'Токио', subtitle: '3 чата', initial: 'Т'),
        const TripInfo(id: 't2', title: 'Париж', subtitle: '1 чат', initial: 'П'),
      ];
      await _pump(tester, _panel(trips: trips));
      expect(find.text('Токио'), findsOneWidget);
      expect(find.text('Париж'), findsOneWidget);
    });

    testWidgets('trip tap fires onTripTap with correct id',
        (WidgetTester tester) async {
      String? tappedId;
      final trips = [
        const TripInfo(id: 't1', title: 'Токио', subtitle: '3 чата', initial: 'Т'),
      ];
      await _pump(
        tester,
        _panel(trips: trips, onTripTap: (id) => tappedId = id),
      );
      await tester.tap(find.text('Токио'));
      await tester.pumpAndSettle();
      expect(tappedId, 't1');
    });

    testWidgets('with trips but no sessions "Нет чатов" is absent',
        (WidgetTester tester) async {
      final trips = [
        const TripInfo(id: 't1', title: 'Токио', subtitle: '3 чата', initial: 'Т'),
      ];
      await _pump(tester, _panel(trips: trips));
      expect(find.text('Нет чатов'), findsNothing);
    });

    // ── Pinned trip card ──────────────────────────────────────────────────────

    testWidgets('pinned trip title is visible', (WidgetTester tester) async {
      const trip = TripInfo(
        id: 'p1',
        title: 'Осака 2026',
        subtitle: '2 чата',
        initial: 'О',
      );
      await _pump(tester, _panel(pinnedTrip: trip));
      expect(find.text('Осака 2026'), findsOneWidget);
    });

    testWidgets('pinned trip shows only first char of multi-char initial',
        (WidgetTester tester) async {
      const trip = TripInfo(
        id: 'p2',
        title: 'Токио',
        subtitle: '3 чата',
        initial: 'ТО',
      );
      await _pump(tester, _panel(pinnedTrip: trip));
      expect(find.text('Т'), findsOneWidget);
      expect(find.text('ТО'), findsNothing);
    });

    // ── Dark mode ─────────────────────────────────────────────────────────────

    testWidgets('dark mode renders without error', (WidgetTester tester) async {
      await _pump(
        tester,
        _panel(sessions: _todaySessions()),
        mode: ThemeMode.dark,
      );
      expect(find.text('Планы на отпуск'), findsOneWidget);
    });

    // ── KaiNavStrings.bucketLabel ─────────────────────────────────────────────

    testWidgets('custom bucketLabel is used for section headers',
        (WidgetTester tester) async {
      final customStrings = KaiNavStrings(
        title: 'Nav',
        newChat: 'New',
        search: 'Search',
        tripsLabel: 'TRIPS',
        appsLabel: 'APPS',
        memoryLabel: 'Memory',
        settingsLabel: 'Settings',
        accountAnonymous: 'Anon',
        accountFreePlan: 'Free',
        noChats: 'No chats',
        bucketLabel: (b) => switch (b) {
          SessionBucket.today => 'TODAY',
          SessionBucket.yesterday => 'YESTERDAY',
          SessionBucket.thisWeek => 'THIS WEEK',
          SessionBucket.older => 'OLDER',
        },
      );
      final sessions = [
        SessionPreview(
          id: 's1',
          title: 'Test session',
          timeLabel: '9:00',
          createdAt: DateTime.now(),
        ),
      ];
      await tester.pumpWidget(
        buildTestWidget(
          KaiNavPanel(strings: customStrings, sessions: sessions),
        ),
      );
      await tester.pump();
      expect(find.text('TODAY'), findsOneWidget);
    });
  });
}
