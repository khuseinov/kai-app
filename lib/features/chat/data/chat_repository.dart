import 'package:uuid/uuid.dart';
import '../../../core/api/api_exceptions.dart';
import '../../../core/api/circuit_breaker.dart';
import '../../../core/models/chat_message.dart';
import '../../../core/network/offline_queue.dart';
import '../../../core/storage/local_storage.dart';
import 'chat_local_source.dart';
import 'chat_remote_source.dart';
import 'dto/chat_request_dto.dart';

class ChatRepository {
  final ChatRemoteSource _remoteSource;
  final ChatLocalSource _localSource;
  final LocalStorage _localStorage;
  final CircuitBreaker _circuitBreaker;
  final OfflineQueue? _offlineQueue;
  final Uuid _uuid = const Uuid();

  ChatRepository(
    this._remoteSource,
    this._localSource,
    this._localStorage,
    this._circuitBreaker, [
    this._offlineQueue,
  ]);

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
      sessionId: sessionId,
      status: 'sending',
    );
    await _localSource.saveMessage(userMessage);
    onMessageSavedLocally?.call(userMessage);

    // 2. Check if offline — enqueue
    if (_offlineQueue != null && !_offlineQueue!.isOnline) {
      await _offlineQueue!.enqueue(PendingMessage(
        id: userMessage.id,
        text: text,
        sessionId: sessionId,
        queuedAt: DateTime.now(),
      ));
      throw const OfflineException();
    }

    // 3. Prepare request
    final request = ChatRequestDto(
      message: text,
      userId: _localStorage.userId,
      sessionId: sessionId,
    );

    // 4. Send to backend through circuit breaker
    final responseDto = await _circuitBreaker.execute(
      () => _remoteSource.sendMessage(request),
    );

    // 5. Create and save response message
    final kaiMessage = ChatMessage(
      id: _uuid.v4(),
      content: responseDto.response,
      isUser: false,
      timestamp: DateTime.now(),
      sessionId: sessionId,
      status: 'sent',
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

    // 6. Update user message status to sent
    final updatedUserMessage = userMessage.copyWith(status: 'sent');
    await _localSource.saveMessage(updatedUserMessage);

    return kaiMessage;
  }

  List<ChatMessage> getMessagesForSession(String sessionId) {
    return _localSource.getMessagesForSession(sessionId);
  }
}
