import 'package:dio/dio.dart';
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
    if (_offlineQueue != null && !_offlineQueue.isOnline) {
      await _offlineQueue.enqueue(
        PendingMessage(
          id: userMessage.id,
          text: text,
          sessionId: sessionId,
          queuedAt: DateTime.now(),
        ),
      );
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
      specialMode: responseDto.specialMode,
      executedToolCalls: responseDto.executedToolCalls,
      worldModelUsed: responseDto.worldModelUsed,
      kgNodesQueried: responseDto.kgNodesQueried,
      revisionCount: responseDto.revisionCount,
      crisisDetected: responseDto.crisisDetected,
      crisisCategory: responseDto.crisisCategory,
      scopeEscalationDetected: responseDto.scopeEscalationDetected,
      scopeEscalationCategories: responseDto.scopeEscalationCategories,
      scopeInheritanceViolation: responseDto.scopeInheritanceViolation,
      injectionFragment: responseDto.injectionFragment,
      injectionSource: responseDto.injectionSource,
      sources: responseDto.sources,
      biasSuggestions: responseDto.biasSuggestions,
      blockReason: responseDto.blockReason,
      sourceWarnings: responseDto.sourceWarnings,
      verificationPassed: responseDto.verificationPassed,
      verificationFailReason: responseDto.verificationFailReason,
      advisorTriggered: responseDto.advisorTriggered,
    );

    await _localSource.saveMessage(kaiMessage);

    // 6. Update user message status to sent
    final updatedUserMessage = userMessage.copyWith(status: 'sent');
    await _localSource.saveMessage(updatedUserMessage);

    return kaiMessage;
  }

  Future<void> streamMessage({
    required String text,
    required String sessionId,
    required Function(ChatMessage) onUpdate,
    CancelToken? cancelToken,
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
    onUpdate(userMessage);

    // 2. Prepare response message (empty initially)
    var responseMessage = ChatMessage(
      id: _uuid.v4(),
      content: '',
      isUser: false,
      timestamp: DateTime.now(),
      sessionId: sessionId,
      status: 'typing',
    );
    onUpdate(responseMessage);

    // 3. Prepare request
    final request = ChatRequestDto(
      message: text,
      userId: _localStorage.userId,
      sessionId: sessionId,
    );

    // 4. Listen to stream
    try {
      final stream = _remoteSource.streamMessage(request, cancelToken: cancelToken);

      await for (final event in stream) {
        await event.when<Future<void>>(
          message: (content) async {
            responseMessage = responseMessage.copyWith(
              content: responseMessage.content + content,
            );
            onUpdate(responseMessage);
          },
          thinking: (thinking) async {
            // Raw reasoning is intentionally not surfaced in kai-app.
          },
          state: (step, label) async {
            responseMessage = responseMessage.copyWith(
              currentStep: step,
              cognitiveStatus: label,
            );
            onUpdate(responseMessage);
          },
          metadata: (
            correlationId,
            language,
            requestType,
            model,
            provider,
            latencyMs,
            tokensUsed,
            confidence,
            piiBlocked,
            specialMode,
            executedToolCalls,
            worldModelUsed,
            kgNodesQueried,
            revisionCount,
            crisisDetected,
            crisisCategory,
            scopeEscalationDetected,
            scopeEscalationCategories,
            scopeInheritanceViolation,
            injectionFragment,
            injectionSource,
            sources,
            biasSuggestions,
            blockReason,
            sourceWarnings,
            verificationPassed,
            verificationFailReason,
            advisorTriggered,
          ) async {
            responseMessage = responseMessage.copyWith(
              correlationId: correlationId,
              language: language,
              requestType: requestType,
              model: model,
              provider: provider,
              latencyMs: latencyMs,
              tokensUsed: tokensUsed,
              confidence: confidence,
              piiBlocked: piiBlocked,
              specialMode: specialMode,
              executedToolCalls: executedToolCalls,
              worldModelUsed: worldModelUsed,
              kgNodesQueried: kgNodesQueried,
              revisionCount: revisionCount,
              crisisDetected: crisisDetected,
              crisisCategory: crisisCategory,
              scopeEscalationDetected: scopeEscalationDetected,
              scopeEscalationCategories: scopeEscalationCategories,
              scopeInheritanceViolation: scopeInheritanceViolation,
              injectionFragment: injectionFragment,
              injectionSource: injectionSource,
              sources: sources,
              biasSuggestions: biasSuggestions,
              blockReason: blockReason,
              sourceWarnings: sourceWarnings,
              verificationPassed: verificationPassed,
              verificationFailReason: verificationFailReason,
              advisorTriggered: advisorTriggered,
            );
            onUpdate(responseMessage);
          },
          approval: (
            requiresHumanApproval,
            pendingConfirmation,
            confirmationType,
          ) async {
            responseMessage = responseMessage.copyWith(
              requiresHumanApproval: requiresHumanApproval,
              pendingConfirmation: pendingConfirmation,
              confirmationType: confirmationType,
            );
            onUpdate(responseMessage);
          },
          done: () async {
            responseMessage = responseMessage.copyWith(status: 'sent');
            await _localSource.saveMessage(responseMessage);

            final updatedUserMessage = userMessage.copyWith(status: 'sent');
            await _localSource.saveMessage(updatedUserMessage);
            onUpdate(responseMessage);
          },
          error: (error) async {
            responseMessage = responseMessage.copyWith(
                status: 'error', content: 'Error: $error');
            onUpdate(responseMessage);
          },
        );
      }
    } catch (e) {
      if (e is DioException && e.type == DioExceptionType.cancel) {
        return;
      }
      responseMessage = responseMessage.copyWith(
          status: 'error', content: 'Connection Error: $e');
      onUpdate(responseMessage);
    }
  }

  List<ChatMessage> getMessagesForSession(String sessionId) {
    return _localSource.getMessagesForSession(sessionId);
  }

  /// APP-ASYNC-1: enqueue a long-running chat request.
  /// Returns the task_id from POST /chat/async.
  Future<String> enqueueAsync({
    required String text,
    required String sessionId,
  }) async {
    final userId = _localStorage.userId;
    final request = ChatRequestDto(
      message: text,
      userId: userId,
      sessionId: sessionId,
    );
    final dto = await _remoteSource.chatAsync(request);
    return dto.taskId;
  }

  /// APP-ASYNC-1: poll GET /chat/status/{taskId}.
  /// Returns ('PENDING' | 'DONE' | 'FAILED', ChatMessage? result, String? error).
  Future<({String status, ChatMessage? result, String? error})> pollAsync(
      String taskId) async {
    final dto = await _remoteSource.pollStatus(taskId);
    if (dto.status == 'DONE' && dto.result != null) {
      final r = dto.result!;
      final msg = ChatMessage(
        id: _uuid.v4(),
        content: r.response,
        isUser: false,
        timestamp: DateTime.now(),
        language: r.language,
        piiBlocked: r.piiBlocked,
        correlationId: r.correlationId,
        model: r.model,
        provider: r.provider,
        requestType: r.requestType,
        latencyMs: r.latencyMs,
        tokensUsed: r.tokensUsed,
        confidence: r.confidence,
        status: 'sent',
        sources: r.sources,
        biasSuggestions: r.biasSuggestions,
        blockReason: r.blockReason,
        sourceWarnings: r.sourceWarnings,
        verificationPassed: r.verificationPassed,
        verificationFailReason: r.verificationFailReason,
        advisorTriggered: r.advisorTriggered,
      );
      await _localSource.saveMessage(msg);
      return (status: 'DONE', result: msg, error: null);
    }
    return (status: dto.status, result: null, error: dto.error);
  }
}
