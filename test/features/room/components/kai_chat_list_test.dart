import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:kai_app/design_system/atoms/kai_button.dart';
import 'package:kai_app/features/room/components/chat_bubbles/kai_kai_bubble.dart';
import 'package:kai_app/features/room/components/chat_bubbles/kai_user_bubble.dart';
import 'package:kai_app/features/room/components/kai_chat_list.dart';

import '../../../test_helpers.dart';

Future<void> _pump(
  WidgetTester tester,
  Widget child, {
  ThemeMode mode = ThemeMode.light,
}) async {
  await tester.pumpWidget(buildTestWidget(child, themeMode: mode));
  await tester.pump();
}

void main() {
  group('KaiChatList', () {
    // ── Empty frame ────────────────────────────────────────────────────────

    group('empty frame', () {
      testWidgets('renders suggestion chips (question + hint)',
          (WidgetTester tester) async {
        await _pump(tester, const KaiChatList(frame: RoomFrame.empty));
        expect(find.text('Нужна ли виза в Японию?'), findsOneWidget);
        expect(find.text('гражданство · сроки'), findsOneWidget);
        expect(find.text('Лучшие маршруты по Японии'), findsOneWidget);
        expect(find.text('10–14 дней · оптимально'), findsOneWidget);
        expect(find.text('Что посмотреть в Токио'), findsOneWidget);
        expect(find.text('must-see · off-beat'), findsOneWidget);
      });

      testWidgets('renders invitation title', (WidgetTester tester) async {
        await _pump(tester, const KaiChatList(frame: RoomFrame.empty));
        expect(find.text('Куда едем сегодня?'), findsOneWidget);
      });
    });

    // ── Live frame ─────────────────────────────────────────────────────────

    group('live frame', () {
      testWidgets('with no messages shows empty fallback',
          (WidgetTester tester) async {
        await _pump(tester, const KaiChatList(frame: RoomFrame.live));
        expect(find.text('Куда едем сегодня?'), findsOneWidget);
      });

      testWidgets('with messages renders KaiUserBubble + KaiKaiBubble',
          (WidgetTester tester) async {
        final messages = <Map<String, dynamic>>[
          {'role': 'user', 'content': 'Привет!'},
          {'role': 'kai', 'content': 'Привет! Чем могу помочь?'},
        ];
        await _pump(
          tester,
          KaiChatList(frame: RoomFrame.live, messages: messages),
        );
        await tester.pump();
        expect(find.byType(KaiUserBubble), findsOneWidget);
        expect(find.byType(KaiKaiBubble), findsOneWidget);
      });

      testWidgets('user bubble renders user content',
          (WidgetTester tester) async {
        final messages = <Map<String, dynamic>>[
          {'role': 'user', 'content': 'Hello user'},
        ];
        await _pump(
          tester,
          KaiChatList(frame: RoomFrame.live, messages: messages),
        );
        await tester.pump();
        expect(find.text('Hello user'), findsOneWidget);
      });

      testWidgets('kai bubble renders kai content',
          (WidgetTester tester) async {
        final messages = <Map<String, dynamic>>[
          {'role': 'kai', 'content': 'Hello from Kai'},
        ];
        await _pump(
          tester,
          KaiChatList(frame: RoomFrame.live, messages: messages),
        );
        await tester.pump();
        expect(find.text('Hello from Kai'), findsOneWidget);
      });

      testWidgets('shows em-dash day header', (WidgetTester tester) async {
        final messages = <Map<String, dynamic>>[
          {'role': 'user', 'content': 'Test'},
        ];
        await _pump(
          tester,
          KaiChatList(frame: RoomFrame.live, messages: messages),
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
          KaiChatList(frame: RoomFrame.live, messages: messages),
        );
        await tester.pump();
        expect(find.text('KAI'), findsOneWidget);
      });
    });

    // ── Panel frame ────────────────────────────────────────────────────────

    group('panel frame', () {
      testWidgets('wraps content in Opacity(0.25)',
          (WidgetTester tester) async {
        await _pump(tester, const KaiChatList(frame: RoomFrame.panel));
        final opacityWidgets =
            tester.widgetList<Opacity>(find.byType(Opacity)).toList();
        final hasDimOpacity = opacityWidgets.any((o) => o.opacity == 0.25);
        expect(hasDimOpacity, isTrue,
            reason: 'panel frame must have Opacity(0.25)');
      });

      testWidgets('wraps content in IgnorePointer',
          (WidgetTester tester) async {
        await _pump(tester, const KaiChatList(frame: RoomFrame.panel));
        expect(find.byType(IgnorePointer), findsWidgets);
      });
    });

    // ── Compose frame ──────────────────────────────────────────────────────

    group('compose frame', () {
      testWidgets('renders without error', (WidgetTester tester) async {
        await _pump(tester, const KaiChatList(frame: RoomFrame.compose));
        expect(find.byType(KaiChatList), findsOneWidget);
      });
    });

    // ── Streaming frame ────────────────────────────────────────────────────

    group('streaming frame', () {
      testWidgets('renders without error', (WidgetTester tester) async {
        await _pump(tester, const KaiChatList(frame: RoomFrame.streaming));
        await tester.pump(const Duration(milliseconds: 100));
        expect(find.byType(KaiChatList), findsOneWidget);
      });

      testWidgets('shows a streaming KaiKaiBubble',
          (WidgetTester tester) async {
        await _pump(
          tester,
          const KaiChatList(
            frame: RoomFrame.streaming,
            partialContent: 'JR Pass стоит',
          ),
        );
        await tester.pump(const Duration(milliseconds: 100));
        // KaiKaiBubble uses Text.rich — textContaining works across spans.
        expect(find.textContaining('JR Pass стоит'), findsOneWidget);
        // A KaiKaiBubble with streaming:true is present
        final bubbles = tester
            .widgetList<KaiKaiBubble>(find.byType(KaiKaiBubble))
            .toList();
        expect(bubbles.any((b) => b.streaming), isTrue,
            reason: 'streaming frame must show a KaiKaiBubble(streaming:true)');
      });

      testWidgets('shows KAI .who label during streaming',
          (WidgetTester tester) async {
        await _pump(
          tester,
          const KaiChatList(
            frame: RoomFrame.streaming,
            partialContent: 'Loading...',
          ),
        );
        await tester.pump(const Duration(milliseconds: 50));
        // KaiKaiBubble renders one "KAI" label in its .who row.
        expect(find.text('KAI'), findsWidgets);
      });

      testWidgets('with existing messages still renders',
          (WidgetTester tester) async {
        final messages = <Map<String, dynamic>>[
          {'role': 'user', 'content': 'Streaming test'},
        ];
        await _pump(
          tester,
          KaiChatList(
            frame: RoomFrame.streaming,
            messages: messages,
            partialContent: 'думаю...',
          ),
        );
        await tester.pump(const Duration(milliseconds: 100));
        expect(find.byType(KaiChatList), findsOneWidget);
      });
    });

    // ── Error frame ────────────────────────────────────────────────────────

    group('error frame', () {
      testWidgets('renders error title (Не удалось ответить)',
          (WidgetTester tester) async {
        await _pump(tester, const KaiChatList(frame: RoomFrame.error));
        expect(find.text('Не удалось ответить'), findsOneWidget);
      });

      testWidgets('renders error body text', (WidgetTester tester) async {
        await _pump(tester, const KaiChatList(frame: RoomFrame.error));
        expect(find.textContaining('Возможно, проблема со связью'),
            findsOneWidget);
      });

      testWidgets('renders retry hint', (WidgetTester tester) async {
        await _pump(tester, const KaiChatList(frame: RoomFrame.error));
        expect(find.text('или напишите снова'), findsOneWidget);
      });

      testWidgets('error frame shows KaiButton.ghost retry (not bespoke pill)',
          (WidgetTester tester) async {
        await _pump(tester, const KaiChatList(frame: RoomFrame.error));
        // Must find a KaiButton (v3 atom) — not a raw GestureDetector Container
        expect(find.byType(KaiButton), findsOneWidget);
        expect(find.text('повторить'), findsOneWidget);
      });

      testWidgets('retry KaiButton fires onRetry callback',
          (WidgetTester tester) async {
        var retries = 0;
        await _pump(
          tester,
          KaiChatList(
            frame: RoomFrame.error,
            onRetry: () => retries++,
          ),
        );
        await tester.tap(find.text('повторить'));
        // pump — not pumpAndSettle; animation controllers would time out.
        await tester.pump();
        await tester.pump(const Duration(milliseconds: 50));
        expect(retries, 1);
      });

      testWidgets('shows .who row with KAI label in error frame',
          (WidgetTester tester) async {
        await _pump(tester, const KaiChatList(frame: RoomFrame.error));
        expect(find.text('KAI'), findsOneWidget);
      });

      testWidgets('dark mode renders without error',
          (WidgetTester tester) async {
        await _pump(
          tester,
          const KaiChatList(frame: RoomFrame.error),
          mode: ThemeMode.dark,
        );
        expect(find.text('Не удалось ответить'), findsOneWidget);
      });
    });

    // ── partialContent param ───────────────────────────────────────────────

    group('partialContent parameter', () {
      testWidgets('accepted without error in non-streaming frame',
          (WidgetTester tester) async {
        await _pump(
          tester,
          const KaiChatList(
            frame: RoomFrame.live,
            partialContent: 'ignored in live frame',
          ),
        );
        expect(find.byType(KaiChatList), findsOneWidget);
      });
    });
  });
}
