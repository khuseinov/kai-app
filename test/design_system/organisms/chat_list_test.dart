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
      testWidgets('renders 2-line suggestion chips (question + hint)',
          (WidgetTester tester) async {
        await _pump(
          tester,
          const ChatList(frame: RoomFrame.empty),
        );
        // New API: question + hint rows
        expect(find.text('Нужна ли виза в Японию?'), findsOneWidget);
        expect(find.text('гражданство · сроки'), findsOneWidget);
        expect(find.text('Лучшие маршруты по Японии'), findsOneWidget);
        expect(find.text('10–14 дней · оптимально'), findsOneWidget);
        expect(find.text('Что посмотреть в Токио'), findsOneWidget);
        expect(find.text('must-see · off-beat'), findsOneWidget);
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

      testWidgets('shows em-dash day header', (WidgetTester tester) async {
        final messages = <Map<String, dynamic>>[
          {'role': 'user', 'content': 'Test'},
        ];
        await _pump(
          tester,
          ChatList(frame: RoomFrame.live, messages: messages),
        );
        // HTML canon: '— today —' with em-dashes
        expect(find.text('— Сегодня —'), findsOneWidget);
      });

      testWidgets('kai bubble shows .who row with KAI label',
          (WidgetTester tester) async {
        final messages = <Map<String, dynamic>>[
          {'role': 'kai', 'content': 'Hello from Kai'},
        ];
        await _pump(
          tester,
          ChatList(frame: RoomFrame.live, messages: messages),
        );
        await tester.pump();
        expect(find.text('KAI'), findsOneWidget);
      });
    });

    group('error frame', () {
      testWidgets('renders new error title (Не удалось ответить)',
          (WidgetTester tester) async {
        await _pump(
          tester,
          const ChatList(frame: RoomFrame.error),
        );
        expect(find.text('Не удалось ответить'), findsOneWidget);
      });

      testWidgets('renders error body text', (WidgetTester tester) async {
        await _pump(
          tester,
          const ChatList(frame: RoomFrame.error),
        );
        expect(
          find.textContaining('Возможно, проблема со связью'),
          findsOneWidget,
        );
      });

      testWidgets('renders retry hint', (WidgetTester tester) async {
        await _pump(
          tester,
          const ChatList(frame: RoomFrame.error),
        );
        expect(find.text('или напишите снова'), findsOneWidget);
      });

      testWidgets('renders retry button with retry label',
          (WidgetTester tester) async {
        await _pump(
          tester,
          const ChatList(frame: RoomFrame.error),
        );
        expect(find.text('повторить'), findsOneWidget);
      });

      testWidgets('shows .who row with KAI label in error frame',
          (WidgetTester tester) async {
        await _pump(
          tester,
          const ChatList(frame: RoomFrame.error),
        );
        expect(find.text('KAI'), findsOneWidget);
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
        await tester.tap(find.text('повторить'));
        // Use pump instead of pumpAndSettle: the streaming AnimationControllers
        // repeat forever and pumpAndSettle would time out.
        await tester.pump();
        await tester.pump(const Duration(milliseconds: 50));
        expect(retries, 1);
      });

      testWidgets('dark mode renders without error', (WidgetTester tester) async {
        await _pump(
          tester,
          const ChatList(frame: RoomFrame.error),
          mode: ThemeMode.dark,
        );
        expect(find.text('Не удалось ответить'), findsOneWidget);
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

      testWidgets('shows partial content when provided',
          (WidgetTester tester) async {
        await _pump(
          tester,
          const ChatList(
            frame: RoomFrame.streaming,
            partialContent: 'JR Pass стоит',
          ),
        );
        await tester.pump(const Duration(milliseconds: 100));
        expect(find.text('JR Pass стоит'), findsOneWidget);
      });

      testWidgets('shows KAI .who label during streaming',
          (WidgetTester tester) async {
        await _pump(
          tester,
          const ChatList(
            frame: RoomFrame.streaming,
            partialContent: 'Loading...',
          ),
        );
        await tester.pump(const Duration(milliseconds: 50));
        expect(find.text('KAI'), findsOneWidget);
      });

      testWidgets('with messages still renders', (WidgetTester tester) async {
        final messages = <Map<String, dynamic>>[
          {'role': 'user', 'content': 'Streaming test'},
        ];
        await _pump(
          tester,
          ChatList(
            frame: RoomFrame.streaming,
            messages: messages,
            partialContent: 'thinking...',
          ),
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

    group('partialContent parameter', () {
      testWidgets('accepted without error in non-streaming frame',
          (WidgetTester tester) async {
        await _pump(
          tester,
          const ChatList(
            frame: RoomFrame.live,
            partialContent: 'ignored in live frame',
          ),
        );
        expect(find.byType(ChatList), findsOneWidget);
      });
    });
  });
}
