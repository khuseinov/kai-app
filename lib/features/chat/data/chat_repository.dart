import 'package:uuid/uuid.dart';
import '../../../core/models/chat_message.dart';
import '../../../core/storage/local_storage.dart';
import '../domain/message_status.dart';
import 'chat_local_source.dart';
import 'chat_remote_source.dart';
import 'dto/chat_request_dto.dart';

class ChatRepository {
  final ChatRemoteSource _remoteSource;
  final ChatLocalSource _localSource;
  final LocalStorage _localStorage;
  final Uuid _uuid = const Uuid();

  ChatRepository(this._remoteSource, this._localSource, this._localStorage);

  Future<ChatMessage> sendMessage({
    required String text,
    required String sessionId,
    Function(ChatMessage)? onMessageSavedLocally,
  }) async {
    // 1. Create optimistic local message
    final userMessage = ChatMessage(
      id: _uuid.v4(),
      content: text,
      isUser: true,
      timestamp: DateTime.now(),
    );
    await _localSource.saveMessage(userMessage);
    onMessageSavedLocally?.call(userMessage);

    // 2. Prepare request
    final request = ChatRequestDto(
      message: text,
      userId: _localStorage.userId,
      sessionId: sessionId,
      client: 'mobile-kai-app',
    );

    // 3. Send to backend
    final responseDto = await _remoteSource.sendMessage(request);

    // 4. Create and save response message
    final kaiMessage = ChatMessage(
      id: _uuid.v4(),
      content: responseDto.response,
      isUser: false,
      timestamp: DateTime.now(),
      language: responseDto.language,
      model: responseDto.model,
      provider: responseDto.provider,
      requestType: responseDto.requestType,
      confidence: responseDto.confidence,
      latencyMs: responseDto.latencyMs,
      tokensUsed: responseDto.tokensUsed,
      piiBlocked: responseDto.piiBlocked,
      correlationId: responseDto.correlationId,
    );

    await _localSource.saveMessage(kaiMessage);
    
    return kaiMessage;
  }
}
