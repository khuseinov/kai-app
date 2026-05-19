import 'package:flutter_test/flutter_test.dart';
import 'package:kai_app/core/models/chat_message.dart';

void main() {
  test('thinking field is NOT serialized to JSON (AI-07)', () {
    final message = ChatMessage(
      id: 'test',
      content: 'hello',
      isUser: false,
      timestamp: DateTime.utc(2026, 5, 19),
      thinking: 'secret reasoning content',
    );
    final json = message.toJson();
    expect(json.containsKey('thinking'), isFalse,
        reason: 'AI-07: reasoning_content must NEVER appear in JSON');
  });

  test('thinking field IS read from JSON (round-trip read still works)', () {
    final json = {
      'id': 'test',
      'content': 'hello',
      'isUser': false,
      'timestamp': '2026-05-19T00:00:00.000Z',
      'thinking': 'some past reasoning',
    };
    final message = ChatMessage.fromJson(json);
    expect(message.thinking, 'some past reasoning');
  });
}
