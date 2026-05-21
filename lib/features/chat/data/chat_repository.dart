import 'package:dio/dio.dart';
import 'package:uuid/uuid.dart';
import '../../../core/api/circuit_breaker.dart';
import '../../../core/models/chat_message.dart';
import '../../../core/storage/local_storage.dart';
import 'chat_local_source.dart';
import 'chat_remote_source.dart';
import 'dto/chat_request_dto.dart';

class ChatRepository {
  final ChatRemoteSource _remoteSource;
  final ChatLocalSource _localSource;
  final LocalStorage _localStorage;
  // ignore: unused_field — reserved for streamMessage circuit breaker wrapping
  final CircuitBreaker _circuitBreaker;
  final Uuid _uuid = const Uuid();

  ChatRepository(
    this._remoteSource,
    this._localSource,
    this._localStorage,
    this._circuitBreaker,
  );

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
    // BUG-STREAM-FRAME-1 + T32: cogStepCount declared outside try so the catch
    // block can use it to determine whether the stream actually started.
    var cogStepCount = 0;
    DateTime? firstStateTime;

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
          thinking: (delta) async {
            // STREAM-THINKING-1 (2026-05-17): accumulate reasoning deltas
            // so MessageBubble can render the o1-style trace above the
            // final answer.
            responseMessage = responseMessage.copyWith(
              thinking: (responseMessage.thinking ?? '') + delta,
            );
            onUpdate(responseMessage);
          },
          state: (step, label) async {
            firstStateTime ??= DateTime.now();
            cogStepCount++;
            responseMessage = responseMessage.copyWith(
              currentStep: step,
              cognitiveStatus: label,
            );
            onUpdate(responseMessage);
            // T36 (Phase 3): yield to event loop so Riverpod schedules a
            // rebuild between state events. Without this, multiple state
            // events arriving in the same micro-task batch can collapse —
            // KaiCognitiveStatus.didUpdateWidget only fires for the last
            // value, dropping intermediate steps from the queue (e.g.
            // P → V skipping E, O). Future.microtask is 0ms wall-clock
            // (NOT Future.delayed) — preserves the T9 fix that removed
            // the 80ms artificial delay.
            await Future.microtask(() {});
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
          correction: (content) async {
            // STREAM-TOKENS-1 (2026-05-17): REPLACE (not append) — backend
            // post-generation safety mutated the streamed output (PII
            // detokenization or refusal override).
            responseMessage = responseMessage.copyWith(content: content);
            onUpdate(responseMessage);
          },
          done: () async {
            // BUG-STREAM-FRAME-1: wait for KaiCognitiveStatus to drain its
            // display queue before clearing cognitiveStatus. Each step is
            // held 1 200 ms by the widget; we compute the exact time still
            // owed so the indicator fades out naturally on the last step —
            // not abruptly when streaming ends.
            if (cogStepCount > 0 && firstStateTime != null) {
              const holdPerStep = Duration(milliseconds: 1200);
              final totalDisplay = holdPerStep * cogStepCount;
              final elapsed = DateTime.now().difference(firstStateTime!);
              final remaining = totalDisplay - elapsed;
              if (remaining > Duration.zero) {
                await Future.delayed(remaining);
              }
            }
            // BUG-RENDER-GATE-1: clear cognitive status so the indicator
            // doesn't stay frozen; message_bubble.dart hides it when
            // cognitiveStatus is null/empty OR status == 'sent'.
            responseMessage = responseMessage.copyWith(
              status: 'sent',
              cognitiveStatus: null,
              currentStep: null,
            );
            await _localSource.saveMessage(responseMessage);

            final updatedUserMessage = userMessage.copyWith(status: 'sent');
            await _localSource.saveMessage(updatedUserMessage);
            onUpdate(responseMessage);
          },
          error: (error) async {
            responseMessage = responseMessage.copyWith(
              status: 'error',
              content: 'Error: $error',
              cognitiveStatus: null,
              currentStep: null,
              thinking: null,
            );
            final failedUserMessage = userMessage.copyWith(status: 'failed');
            await _safelyPersistMessages([responseMessage, failedUserMessage]);
            onUpdate(failedUserMessage);
            onUpdate(responseMessage);
          },
        );
      }
    } catch (e) {
      if (e is DioException && e.type == DioExceptionType.cancel) {
        // Only persist failure state if the stream actually started producing
        // content — otherwise this is a context-switch cancel (newSession,
        // loadFromHistory, rapid re-send), not a real failure.
        final streamStarted = responseMessage.content.isNotEmpty || cogStepCount > 0;
        if (streamStarted) {
          responseMessage = responseMessage.copyWith(
            status: 'error',
            cognitiveStatus: null,
            currentStep: null,
            thinking: null,
          );
          final cancelledUserMessage = userMessage.copyWith(status: 'failed');
          await _safelyPersistMessages([responseMessage, cancelledUserMessage]);
          onUpdate(cancelledUserMessage);
          onUpdate(responseMessage);
        }
        return;
      }
      responseMessage = responseMessage.copyWith(
        status: 'error',
        content: 'Connection Error: $e',
        cognitiveStatus: null,
        currentStep: null,
        thinking: null,
      );
      final failedUserMessage = userMessage.copyWith(status: 'failed');
      await _safelyPersistMessages([responseMessage, failedUserMessage]);
      onUpdate(failedUserMessage);
      onUpdate(responseMessage);
    }
  }

  Future<void> _safelyPersistMessages(List<ChatMessage> messages) async {
    for (final msg in messages) {
      try {
        await _localSource.saveMessage(msg);
      } catch (_) {
        // Don't let storage failures escape error/cancel handlers.
        // In-memory state is updated via onUpdate regardless.
      }
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
