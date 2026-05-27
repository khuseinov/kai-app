import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:kai_app/design_system/atoms/kai_bubble.dart';
import 'package:kai_app/design_system/organisms/chat_list.dart';

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
  group('ChatList', () {
    group('empty frame', () {
      testWidgets('renders suggestion chips', (WidgetTester tester) async {
        await _pump(
          tester,
          const ChatList(frame: RoomFrame.empty),
        );
        expect(find.text('Планы на поездку'), findsOneWidget);
        expect(find.text('Вопрос о визе'), findsOneWidget);
        expect(find.text('Рекомендации'), findsOneWidget);
      });

      testWidgets('renders invitation title', (WidgetTester tester) async {
        await _pump(
          tester,
          const ChatList(frame: RoomFrame.empty),
        );
        expect(find.text('Куда едем сегодня?'), findsOneWidget);
      });
    });

    group('live frame', () {
      testWidgets('with no messages shows empty fallback',
          (WidgetTester tester) async {
        await _pump(
          tester,
          const ChatList(frame: RoomFrame.live),
        );
        expect(find.text('Куда едем сегодня?'), findsOneWidget);
      });

      testWidgets('with messages renders KaiBubble widgets',
          (WidgetTester tester) async {
        final messages = <Map<String, dynamic>>[
          {'role': 'user', 'content': 'Привет!'},
          {'role': 'kai', 'content': 'Привет! Чем могу помочь?'},
        ];
        await _pump(
          tester,
          ChatList(frame: RoomFrame.live, messages: messages),
        );
        await tester.pump();
        expect(find.byType(KaiBubble), findsNWidgets(2));
      });

      testWidgets('user bubble renders user content',
          (WidgetTester tester) async {
        final messages = <Map<String, dynamic>>[
          {'role': 'user', 'content': 'Hello user'},
        ];
        await _pump(
          tester,
          ChatList(frame: RoomFrame.live, messages: messages),
        );
        await tester.pump();
        expect(find.text('Hello user'), findsOneWidget);
      });
    });

    group('error frame', () {
      testWidgets('renders retry button', (WidgetTester tester) async {
        await _pump(
          tester,
          const ChatList(frame: RoomFrame.error),
        );
        expect(find.text('Повторить'), findsOneWidget);
        expect(find.text('Ошибка — попробуйте ещё раз'), findsOneWidget);
      });

      testWidgets('tap retry fires onRetry callback',
          (WidgetTester tester) async {
        var retries = 0;
        await _pump(
          tester,
          ChatList(
            frame: RoomFrame.error,
            onRetry: () => retries++,
          ),
        );
        await tester.tap(find.text('Повторить'));
        // Use pump instead of pumpAndSettle: the streaming AnimationController
        // repeats forever and pumpAndSettle would time out.
        await tester.pump();
        await tester.pump(const Duration(milliseconds: 50));
        expect(retries, 1);
      });
    });

    group('streaming frame', () {
      testWidgets('renders without error', (WidgetTester tester) async {
        await _pump(
          tester,
          const ChatList(frame: RoomFrame.streaming),
        );
        await tester.pump(const Duration(milliseconds: 100));
        expect(find.byType(ChatList), findsOneWidget);
      });

      testWidgets('with messages still renders', (WidgetTester tester) async {
        final messages = <Map<String, dynamic>>[
          {'role': 'user', 'content': 'Streaming test'},
        ];
        await _pump(
          tester,
          ChatList(frame: RoomFrame.streaming, messages: messages),
        );
        await tester.pump(const Duration(milliseconds: 100));
        expect(find.byType(ChatList), findsOneWidget);
      });
    });

    group('panel frame', () {
      testWidgets('wraps content in Opacity(0.25)', (WidgetTester tester) async {
        await _pump(
          tester,
          const ChatList(frame: RoomFrame.panel),
        );
        final opacityWidgets = tester
            .widgetList<Opacity>(find.byType(Opacity))
            .toList();
        final hasDimOpacity = opacityWidgets.any((o) => o.opacity == 0.25);
        expect(hasDimOpacity, isTrue,
            reason: 'panel frame must have Opacity(0.25)');
      });

      testWidgets('wraps content in IgnorePointer', (WidgetTester tester) async {
        await _pump(
          tester,
          const ChatList(frame: RoomFrame.panel),
        );
        expect(find.byType(IgnorePointer), findsWidgets);
      });
    });

    group('compose frame', () {
      testWidgets('renders without error', (WidgetTester tester) async {
        await _pump(
          tester,
          const ChatList(frame: RoomFrame.compose),
        );
        expect(find.byType(ChatList), findsOneWidget);
      });
    });
  });
}
