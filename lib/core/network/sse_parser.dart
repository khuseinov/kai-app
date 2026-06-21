import 'dart:async';
import 'dart:convert';

import 'package:kai_app/features/room/domain/repositories/chat_repository.dart';

/// Parses a raw SSE byte stream into typed [ChatEvent]s.
///
/// Complies with the EventSource spec: events are separated by blank lines.
/// Each event has an optional `event:` field and a `data:` field.
class SseParser {
  SseParser._();

  /// Transforms a raw byte [Stream] (e.g. from Dio) into a [Stream] of [ChatEvent].
  static Stream<ChatEvent> parse(Stream<List<int>> bytes) async* {
    var eventType = '';
    final dataBuffer = StringBuffer();

    final lines = bytes
        .transform(utf8.decoder)
        .transform(const LineSplitter());

    await for (final line in lines) {
      if (line.startsWith('event:')) {
        eventType = line.substring(6).trim();
      } else if (line.startsWith('data:')) {
        dataBuffer.write(line.substring(5).trim());
      } else if (line.isEmpty) {
        final data = dataBuffer.toString();
        dataBuffer.clear();
        final event = _toEvent(eventType, data);
        eventType = '';
        if (event != null) yield event;
      }
    }
  }

  static ChatEvent? _toEvent(String type, String data) {
    var json = const <String, dynamic>{};
    if (data.isNotEmpty) {
      try {
        json = jsonDecode(data) as Map<String, dynamic>;
      } catch (_) {
        return null;
      }
    }
    return switch (type) {
      'message' => ChatEventMessage(
          content: _deltaContent(json) ?? json['content'] as String? ?? '',
          messageId: json['messageId'] as String? ?? '',
        ),
      'thinking' => ChatEventThinking(
          step: _deltaContent(json) ?? json['step'] as String? ?? '',
        ),
      'state' => ChatEventState(
          state: json['state'] as String? ??
              json['label'] as String? ??
              json['step'] as String? ??
              '',
        ),
      'metadata' => ChatEventMetadata(data: json),
      'approval' => ChatEventApproval(
          prompt: json['prompt'] as String? ?? '',
          requestId: json['requestId'] as String? ?? '',
        ),
      'correction' => ChatEventCorrection(
          content: json['content'] as String? ?? '',
          messageId: json['messageId'] as String? ?? '',
        ),
      'done' => const ChatEventDone(),
      'error' => ChatEventError(
          message: json['message'] as String? ?? 'stream error',
        ),
      _ => null,
    };
  }

  /// Backend emits OpenAI-style deltas: `choices[0].delta.content`.
  /// Fall back to flat fields for backward compatibility with mock fixtures.
  static String? _deltaContent(Map<String, dynamic> json) {
    final choices = json['choices'] as List<dynamic>?;
    if (choices != null && choices.isNotEmpty) {
      final first = choices.first as Map<String, dynamic>?;
      final delta = first?['delta'] as Map<String, dynamic>?;
      final content = delta?['content'] as String?;
      if (content != null && content.isNotEmpty) return content;
    }
    return null;
  }
}
