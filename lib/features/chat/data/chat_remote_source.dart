import '../../../core/api/api_client.dart';
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
}
