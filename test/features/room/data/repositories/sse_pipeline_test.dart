import 'dart:async';
import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';
import 'package:hive/hive.dart';
import 'package:hive_test/hive_test.dart';
import 'package:kai_app/core/storage/hive_setup.dart';
import 'package:kai_app/features/room/data/models/message.dart';
import 'package:kai_app/features/room/data/models/session.dart';
import 'package:kai_app/features/room/data/repositories/chat_repository_impl.dart';
import 'package:kai_app/features/room/domain/repositories/chat_repository.dart';
import 'package:kai_app/features/settings/data/models/settings.dart';

// ---------------------------------------------------------------------------
// Helpers
// ---------------------------------------------------------------------------

/// Builds a [RealChatRepository] that serves the given raw SSE [sseData].
RealChatRepository _repoWithSse(String sseData) {
  return RealChatRepository(
    streamOpener: (_, __) => Stream.value(utf8.encode(sseData)),
  );
}

void main() {
  setUp(() async {
    await setUpTestHive();
    if (!Hive.isAdapterRegistered(0)) Hive.registerAdapter(SessionAdapter());
    if (!Hive.isAdapterRegistered(1)) Hive.registerAdapter(MessageAdapter());
    if (!Hive.isAdapterRegistered(2)) {
      Hive.registerAdapter(MessageStatusAdapter());
    }
    if (!Hive.isAdapterRegistered(3)) Hive.registerAdapter(MessageRoleAdapter());
    if (!Hive.isAdapterRegistered(4)) {
      Hive.registerAdapter(AppThemeModeAdapter());
    }
    if (!Hive.isAdapterRegistered(5)) Hive.registerAdapter(AppSettingsAdapter());
    await Hive.openBox<Message>(HiveSetup.messagesBoxName);
    await Hive.openBox<Session>(HiveSetup.sessionsBoxName);
  });

  tearDown(() async {
    await tearDownTestHive();
  });

  // -------------------------------------------------------------------------
  // T8 — optimistic persist before stream
  // -------------------------------------------------------------------------
  group('T8 — optimistic persist before stream', () {
    test('user message is in Hive before any SSE event arrives', () async {
      var userMsgInHive = false;
      final repo = RealChatRepository(
        streamOpener: (_, __) async* {
          // At this point sendMessage has already awaited _safelyPersistMessages
          userMsgInHive = HiveSetup.messages.values
              .any((m) => m.role == MessageRole.user);
          yield utf8.encode('event: done\ndata: {}\n\n');
        },
      );
      await repo.sendMessage('hi', 's1').drain<void>();
      expect(userMsgInHive, isTrue);
    });

    test('user message content matches sent text', () async {
      const sseData = 'event: done\ndata: {}\n\n';
      final repo = _repoWithSse(sseData);
      await repo.sendMessage('hello world', 's1').drain<void>();
      final userMsg = HiveSetup.messages.values
          .where((m) => m.role == MessageRole.user)
          .firstOrNull;
      expect(userMsg, isNotNull);
      expect(userMsg!.content, 'hello world');
      expect(userMsg.sessionId, 's1');
      expect(userMsg.status, MessageStatus.sent);
    });
  });

  // -------------------------------------------------------------------------
  // T21 — correction replaces, not appends
  // -------------------------------------------------------------------------
  group('T21 — correction replaces, not appends', () {
    test('correction event replaces kai message content in Hive', () async {
      const sseData =
          'event: message\ndata: {"choices":[{"delta":{"content":"hello"}}]}\n\n'
          'event: correction\ndata: {"content":"fixed","messageId":"m1"}\n\n'
          'event: done\ndata: {}\n\n';
      final repo = _repoWithSse(sseData);
      final events = await repo.sendMessage('test', 's1').toList();

      final correction = events.whereType<ChatEventCorrection>().firstOrNull;
      expect(correction, isNotNull);
      expect(correction!.content, 'fixed');

      // Verify persisted kai content is 'fixed', not 'hellofixed'
      final kaiMsg = HiveSetup.messages.values
          .where((m) => m.role == MessageRole.kai)
          .firstOrNull;
      expect(kaiMsg, isNotNull);
      expect(kaiMsg!.content, 'fixed');
    });

    test('multiple corrections: last one wins', () async {
      const sseData =
          'event: message\ndata: {"choices":[{"delta":{"content":"v1"}}]}\n\n'
          'event: correction\ndata: {"content":"v2","messageId":"m1"}\n\n'
          'event: correction\ndata: {"content":"v3","messageId":"m1"}\n\n'
          'event: done\ndata: {}\n\n';
      final repo = _repoWithSse(sseData);
      await repo.sendMessage('test', 's1').drain<void>();

      final kaiMsg = HiveSetup.messages.values
          .where((m) => m.role == MessageRole.kai)
          .firstOrNull;
      expect(kaiMsg!.content, 'v3');
    });
  });

  // -------------------------------------------------------------------------
  // T25/T27 — session-switch guard (cancel stops event processing)
  // -------------------------------------------------------------------------
  group('T25/T27 — session-switch guard', () {
    test('cancelStreaming stops processing new events', () async {
      final controller = StreamController<List<int>>();
      final repo = RealChatRepository(
        streamOpener: (_, __) => controller.stream,
      );

      var eventCount = 0;
      final sub = repo.sendMessage('hi', 's1').listen((_) => eventCount++);

      // Let the stream start, then cancel immediately
      await Future<void>.delayed(const Duration(milliseconds: 10));
      await repo.cancelStreaming('s1');

      // Push events after cancel — should not be processed
      controller.add(
        utf8.encode(
          'event: message\ndata: {"choices":[{"delta":{"content":"late"}}]}\n\n',
        ),
      );
      await Future<void>.delayed(const Duration(milliseconds: 10));
      await sub.cancel();
      await controller.close();

      // No events should have been yielded (cancelled before any SSE arrived)
      expect(eventCount, 0);
    });

    test('new sendMessage cancels previous session stream', () async {
      const sseData = 'event: done\ndata: {}\n\n';
      final repo = _repoWithSse(sseData);

      // Start first stream, immediately start second — first should be cancelled
      final f1 = repo.sendMessage('first', 's1').toList();
      final f2 = repo.sendMessage('second', 's1').toList();

      final results = await Future.wait([f1, f2]);
      // Second stream should complete with done event
      expect(results[1].whereType<ChatEventDone>(), isNotEmpty);
    });
  });

  // -------------------------------------------------------------------------
  // T30 — terminal events
  // -------------------------------------------------------------------------
  group('T30 — terminal events', () {
    test('done event terminates the stream', () async {
      const sseData = 'event: done\ndata: {}\n\n';
      final repo = _repoWithSse(sseData);
      final events = await repo.sendMessage('test', 's1').toList();
      expect(events.last, isA<ChatEventDone>());
    });

    test('error event terminates the stream', () async {
      const sseData = 'event: error\ndata: {"message":"server error"}\n\n';
      final repo = _repoWithSse(sseData);
      final events = await repo.sendMessage('test', 's1').toList();
      expect(events.any((e) => e is ChatEventError), isTrue);
    });

    test('no events emitted after done', () async {
      const sseData =
          'event: done\ndata: {}\n\n'
          'event: message\ndata: {"choices":[{"delta":{"content":"after"}}]}\n\n';
      final repo = _repoWithSse(sseData);
      final events = await repo.sendMessage('test', 's1').toList();
      // Only done, no message after it
      expect(events.whereType<ChatEventMessage>(), isEmpty);
      expect(events.whereType<ChatEventDone>(), hasLength(1));
    });
  });

  // -------------------------------------------------------------------------
  // T31 — Completer guards
  // -------------------------------------------------------------------------
  group('T31 — Completer guards', () {
    test('cancelStreaming on non-existent session does not throw', () async {
      final repo = _repoWithSse('event: done\ndata: {}\n\n');
      await expectLater(
        repo.cancelStreaming('non-existent-session'),
        completes,
      );
    });

    test('double cancelStreaming does not throw', () async {
      final repo = RealChatRepository(
        streamOpener: (_, __) => const Stream.empty(),
      );
      // Start a stream so a completer is registered
      final future = repo.sendMessage('hi', 's1').drain<void>();
      await repo.cancelStreaming('s1');
      // Second cancel on already-removed completer is safe
      await repo.cancelStreaming('s1');
      await expectLater(future, completes);
    });
  });

  // -------------------------------------------------------------------------
  // T32 — stream-started guard
  // -------------------------------------------------------------------------
  group('T32 — stream-started guard', () {
    test('done with no content: kai message NOT persisted to Hive', () async {
      const sseData = 'event: done\ndata: {}\n\n';
      final repo = _repoWithSse(sseData);
      await repo.sendMessage('test', 's1').drain<void>();
      final kaiMsgs = HiveSetup.messages.values
          .where((m) => m.role == MessageRole.kai);
      expect(kaiMsgs, isEmpty);
    });

    test('done with content: kai message IS persisted', () async {
      const sseData =
          'event: message\ndata: {"choices":[{"delta":{"content":"hello"}}]}\n\n'
          'event: done\ndata: {}\n\n';
      final repo = _repoWithSse(sseData);
      await repo.sendMessage('test', 's1').drain<void>();
      final kaiMsgs = HiveSetup.messages.values
          .where((m) => m.role == MessageRole.kai);
      expect(kaiMsgs, hasLength(1));
    });

    test('done with only thinking steps: kai message IS persisted', () async {
      const sseData =
          'event: thinking\ndata: {"choices":[{"delta":{"content":"planning"}}]}\n\n'
          'event: done\ndata: {}\n\n';
      final repo = _repoWithSse(sseData);
      await repo.sendMessage('test', 's1').drain<void>();
      final kaiMsgs = HiveSetup.messages.values
          .where((m) => m.role == MessageRole.kai);
      expect(kaiMsgs, hasLength(1));
    });
  });

  // -------------------------------------------------------------------------
  // T33 — safelyPersistMessages
  // -------------------------------------------------------------------------
  group('T33 — safelyPersistMessages', () {
    test('completes normally on happy path', () async {
      const sseData =
          'event: message\ndata: {"choices":[{"delta":{"content":"ok"}}]}\n\n'
          'event: done\ndata: {}\n\n';
      final repo = _repoWithSse(sseData);
      await expectLater(repo.sendMessage('test', 's1').drain<void>(), completes);
    });

    test('user and kai messages are both persisted correctly', () async {
      const sseData =
          'event: message\ndata: {"choices":[{"delta":{"content":"reply"}}]}\n\n'
          'event: done\ndata: {}\n\n';
      final repo = _repoWithSse(sseData);
      await repo.sendMessage('query', 's1').drain<void>();

      final all = HiveSetup.messages.values.toList();
      expect(all.where((m) => m.role == MessageRole.user), hasLength(1));
      expect(all.where((m) => m.role == MessageRole.kai), hasLength(1));
      expect(
        all.firstWhere((m) => m.role == MessageRole.user).content,
        'query',
      );
      expect(
        all.firstWhere((m) => m.role == MessageRole.kai).content,
        'reply',
      );
    });
  });

  // -------------------------------------------------------------------------
  // T35 — cancel-aware drain
  // -------------------------------------------------------------------------
  group('T35 — cancel-aware drain', () {
    test('cancelStreaming on empty stream completes the future', () async {
      final repo = RealChatRepository(
        streamOpener: (_, __) => const Stream.empty(),
      );
      final future = repo.sendMessage('hi', 's1').drain<void>();
      await repo.cancelStreaming('s1');
      await expectLater(future, completes);
    });

    test('stream completes cleanly after cancel', () async {
      final controller = StreamController<List<int>>();
      final repo = RealChatRepository(
        streamOpener: (_, __) => controller.stream,
      );
      final future = repo.sendMessage('hi', 's1').drain<void>();
      await repo.cancelStreaming('s1');
      await controller.close();
      await expectLater(future, completes);
    });
  });
}
