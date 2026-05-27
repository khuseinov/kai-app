import 'package:flutter_test/flutter_test.dart';
import 'package:kai_app/core/repositories/chat_repository.dart';
import 'package:kai_app/core/repositories/mock_chat_repository.dart';

void main() {
  group('MockChatRepository', () {
    late MockChatRepository repo;

    setUp(() => repo = MockChatRepository());

    test('emits state → thinking → state → messages → correction → done',
        () async {
      final events = await repo.sendMessage('hello', 'session-1').toList();

      expect(events, [
        isA<ChatEventState>().having((e) => e.state, 'state', 'thinking'),
        isA<ChatEventThinking>(),
        isA<ChatEventState>().having((e) => e.state, 'state', 'responding'),
        isA<ChatEventMessage>().having((e) => e.content, 'content', 'Hello'),
        isA<ChatEventMessage>().having((e) => e.content, 'content', ' from'),
        isA<ChatEventMessage>().having((e) => e.content, 'content', ' Kai!'),
        isA<ChatEventCorrection>().having(
          (e) => e.content,
          'content',
          'Hello from Kai! (corrected)',
        ),
        isA<ChatEventDone>(),
      ]);
    });

    test('error path: sessionId ending with :error emits ChatEventError',
        () async {
      final events =
          await repo.sendMessage('hi', 'session:error').toList();

      expect(events.length, 1);
      expect(events.first, isA<ChatEventError>());
    });

    test('cancelStreaming closes stream mid-flight', () async {
      final stream = repo.sendMessage('hello', 'session-cancel');
      final collected = <ChatEvent>[];
      final sub = stream.listen(collected.add);

      await Future<void>.delayed(const Duration(milliseconds: 200));
      await repo.cancelStreaming('session-cancel');
      await sub.cancel();

      expect(collected, isA<List<ChatEvent>>());
    });

    test('messageId is consistent across message and correction events',
        () async {
      final events = await repo.sendMessage('hi', 'session-2').toList();

      final messages = events.whereType<ChatEventMessage>().toList();
      final corrections = events.whereType<ChatEventCorrection>().toList();

      expect(messages, isNotEmpty);
      expect(corrections, isNotEmpty);
      for (final msg in messages) {
        expect(msg.messageId, equals(corrections.first.messageId));
      }
    });

    test('multiple sessions are independent', () async {
      final f1 = repo.sendMessage('hello', 'session-a').toList();
      final f2 = repo.sendMessage('world', 'session-b').toList();
      final results = await Future.wait([f1, f2]);

      expect(results[0].whereType<ChatEventDone>(), isNotEmpty);
      expect(results[1].whereType<ChatEventDone>(), isNotEmpty);
    });
  });
}
