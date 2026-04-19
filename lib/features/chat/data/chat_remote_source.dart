import 'dart:convert';
import '../../../core/api/api_client.dart';
import 'dto/chat_stream_event.dart';
import 'dto/chat_request_dto.dart';
import 'dto/chat_response_dto.dart';

class ChatRemoteSource {
  final ApiClient _apiClient;

  ChatRemoteSource(this._apiClient);

  Future<ChatResponseDto> sendMessage(ChatRequestDto request) async {
    final response = await _apiClient.sendMessage(
      message: request.message,
      userId: request.userId,
      sessionId: request.sessionId,
    );

    return ChatResponseDto.fromJson(response);
  }

  Stream<ChatStreamEvent> streamMessage(ChatRequestDto request) async* {
    final stream = _apiClient.streamMessage(
      message: request.message,
      userId: request.userId,
      sessionId: request.sessionId,
    );

    String? currentEvent;

    await for (final line in stream) {
      if (line.startsWith('event: ')) {
        currentEvent = line.substring(7).trim();
      } else if (line.startsWith('data: ')) {
        final data = line.substring(6).trim();

        if (data == '[DONE]') {
          yield const ChatStreamEvent.done();
          continue;
        }

        try {
          final json = jsonDecode(data);
          final content = json['choices'][0]['delta']['content'] as String? ?? '';

          if (currentEvent == 'thinking') {
            yield ChatStreamEvent.thinking(content);
          } else if (currentEvent == 'message') {
            yield ChatStreamEvent.message(content);
          }
        } catch (e) {
          yield ChatStreamEvent.error(e.toString());
        }
      }
    }
  }
}
