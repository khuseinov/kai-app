import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';
import 'package:kai_app/core/network/sse_parser.dart';
import 'package:kai_app/core/repositories/chat_repository.dart';

Stream<List<int>> _toStream(String raw) => Stream.value(utf8.encode(raw));

void main() {
  group('SseParser', () {
    test('parses message event', () async {
      const raw =
          'event: message\ndata: {"content":"hi","messageId":"m1"}\n\n';
      final events = await SseParser.parse(_toStream(raw)).toList();
      expect(events, hasLength(1));
      expect(events.first, isA<ChatEventMessage>());
      final msg = events.first as ChatEventMessage;
      expect(msg.content, 'hi');
      expect(msg.messageId, 'm1');
    });

    test('parses state event', () async {
      const raw = 'event: state\ndata: {"state":"thinking"}\n\n';
      final events = await SseParser.parse(_toStream(raw)).toList();
      expect(events, hasLength(1));
      expect(events.first, isA<ChatEventState>());
      final s = events.first as ChatEventState;
      expect(s.state, 'thinking');
    });

    test('parses correction event', () async {
      const raw =
          'event: correction\ndata: {"content":"fixed","messageId":"m2"}\n\n';
      final events = await SseParser.parse(_toStream(raw)).toList();
      expect(events, hasLength(1));
      expect(events.first, isA<ChatEventCorrection>());
      final c = events.first as ChatEventCorrection;
      expect(c.content, 'fixed');
      expect(c.messageId, 'm2');
    });

    test('parses done event', () async {
      const raw = 'event: done\ndata: {}\n\n';
      final events = await SseParser.parse(_toStream(raw)).toList();
      expect(events, hasLength(1));
      expect(events.first, isA<ChatEventDone>());
    });

    test('parses error event', () async {
      const raw = 'event: error\ndata: {"message":"oops"}\n\n';
      final events = await SseParser.parse(_toStream(raw)).toList();
      expect(events, hasLength(1));
      expect(events.first, isA<ChatEventError>());
      final e = events.first as ChatEventError;
      expect(e.message, 'oops');
    });

    test('skips unknown event types', () async {
      const raw = 'event: unknown_type\ndata: {"foo":"bar"}\n\n';
      final events = await SseParser.parse(_toStream(raw)).toList();
      expect(events, isEmpty);
    });

    test('handles multi-event stream', () async {
      const raw = 'event: state\ndata: {"state":"thinking"}\n\n'
          'event: message\ndata: {"content":"Hello","messageId":"m3"}\n\n'
          'event: done\ndata: {}\n\n';
      final events = await SseParser.parse(_toStream(raw)).toList();
      expect(events, hasLength(3));
      expect(events[0], isA<ChatEventState>());
      expect(events[1], isA<ChatEventMessage>());
      expect(events[2], isA<ChatEventDone>());
      // Verify order / content.
      expect((events[0] as ChatEventState).state, 'thinking');
      expect((events[1] as ChatEventMessage).content, 'Hello');
    });
  });
}
