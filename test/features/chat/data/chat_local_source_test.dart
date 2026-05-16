import 'package:flutter_test/flutter_test.dart';
import 'package:hive/hive.dart';
import 'package:hive_test/hive_test.dart';
import 'package:kai_app/core/models/chat_message.dart';
import 'package:kai_app/core/models/tool_source.dart';
import 'package:kai_app/features/chat/data/chat_local_source.dart';
import 'package:kai_app/features/chat/domain/chat_session.dart';

void main() {
  setUp(() async {
    await setUpTestHive();
  });

  tearDown(() async {
    await tearDownTestHive();
  });

  group('ChatLocalSource', () {
    test('saveMessage and getMessagesForSession round-trip', () async {
      final chatBox = await Hive.openBox('chat_history');
      final sessionBox = await Hive.openBox('sessions');
      final source = ChatLocalSource(chatBox: chatBox, sessionBox: sessionBox);

      final message = ChatMessage(
        id: 'msg-1',
        content: 'Hello',
        isUser: true,
        timestamp: DateTime(2024, 1, 1),
        sessionId: 'sess-1',
      );

      await source.saveMessage(message);
      final messages = source.getMessagesForSession('sess-1');

      expect(messages.length, 1);
      expect(messages.first.id, 'msg-1');
      expect(messages.first.content, 'Hello');
      expect(messages.first.sessionId, 'sess-1');

      await chatBox.close();
      await sessionBox.close();
    });

    test('getMessagesForSession filters by sessionId', () async {
      final chatBox = await Hive.openBox('chat_history');
      final sessionBox = await Hive.openBox('sessions');
      final source = ChatLocalSource(chatBox: chatBox, sessionBox: sessionBox);

      await source.saveMessage(
        ChatMessage(
          id: 'msg-1',
          content: 'Session 1 message',
          isUser: true,
          timestamp: DateTime(2024, 1, 1),
          sessionId: 'sess-1',
        ),
      );
      await source.saveMessage(
        ChatMessage(
          id: 'msg-2',
          content: 'Session 2 message',
          isUser: true,
          timestamp: DateTime(2024, 1, 1),
          sessionId: 'sess-2',
        ),
      );

      final result = source.getMessagesForSession('sess-1');
      expect(result.length, 1);
      expect(result.first.content, 'Session 1 message');

      await chatBox.close();
      await sessionBox.close();
    });

    test('getMessagesForSession returns empty for unknown session', () async {
      final chatBox = await Hive.openBox('chat_history');
      final sessionBox = await Hive.openBox('sessions');
      final source = ChatLocalSource(chatBox: chatBox, sessionBox: sessionBox);

      final result = source.getMessagesForSession('nonexistent');
      expect(result, isEmpty);

      await chatBox.close();
      await sessionBox.close();
    });

    test('saveSession and getSession round-trip', () async {
      final chatBox = await Hive.openBox('chat_history');
      final sessionBox = await Hive.openBox('sessions');
      final source = ChatLocalSource(chatBox: chatBox, sessionBox: sessionBox);

      final session = ChatSession(
        id: 'sess-1',
        createdAt: DateTime(2024, 1, 1),
        updatedAt: DateTime(2024, 1, 1),
        title: 'My Chat',
      );

      await source.saveSession(session);
      final retrieved = source.getSession('sess-1');

      expect(retrieved, isNotNull);
      expect(retrieved!.id, 'sess-1');
      expect(retrieved.title, 'My Chat');

      await chatBox.close();
      await sessionBox.close();
    });

    test('getSession returns null for missing id', () async {
      final chatBox = await Hive.openBox('chat_history');
      final sessionBox = await Hive.openBox('sessions');
      final source = ChatLocalSource(chatBox: chatBox, sessionBox: sessionBox);

      final result = source.getSession('nonexistent');
      expect(result, isNull);

      await chatBox.close();
      await sessionBox.close();
    });

    test(
      'saveMessage with non-empty sources round-trips without Hive type error '
      '(BUG-HIVE-TOOLSOURCE-1)',
      () async {
        final chatBox = await Hive.openBox('chat_history');
        final sessionBox = await Hive.openBox('sessions');
        final source =
            ChatLocalSource(chatBox: chatBox, sessionBox: sessionBox);

        final message = ChatMessage(
          id: 'msg-with-sources',
          content: 'Visa info for Thailand',
          isUser: false,
          timestamp: DateTime(2026, 5, 16),
          sessionId: 'sess-1',
          sources: const [
            ToolSource(
              tool: 'visa_checker',
              source: 'knowledge_graph_visa_rules',
              sourceDisplayName: 'Knowledge Graph (visa rules)',
              fetchedAt: '2026-05-16T12:00:00Z',
              expiresAt: '2027-05-16T12:00:00Z',
            ),
            ToolSource(
              tool: 'health_requirements',
              source: 'knowledge_graph_health_requirements',
              sourceDisplayName: 'Knowledge Graph (health requirements)',
              fetchedAt: '2026-05-16T12:00:00Z',
              expiresAt: 'unknown',
            ),
          ],
        );

        // Must not throw "HiveError: Cannot write, unknown type: _\$ToolSourceImpl"
        await source.saveMessage(message);

        final retrieved = source.getMessagesForSession('sess-1');
        expect(retrieved.length, 1);
        expect(retrieved.first.sources.length, 2);
        expect(retrieved.first.sources.first.tool, 'visa_checker');
        expect(retrieved.first.sources[1].tool, 'health_requirements');

        await chatBox.close();
        await sessionBox.close();
      },
    );
  });
}
