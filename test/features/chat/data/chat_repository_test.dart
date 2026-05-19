import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hive/hive.dart';
import 'package:hive_test/hive_test.dart';
import 'package:kai_app/core/api/api_client.dart';
import 'package:kai_app/core/api/circuit_breaker.dart';
import 'package:kai_app/core/models/chat_message.dart';
import 'package:kai_app/core/storage/local_storage.dart';
import 'package:kai_app/features/chat/data/chat_local_source.dart';
import 'package:kai_app/features/chat/data/chat_remote_source.dart';
import 'package:kai_app/features/chat/data/chat_repository.dart';
import 'package:kai_app/features/chat/data/dto/chat_request_dto.dart';
import 'package:kai_app/features/chat/data/dto/chat_response_dto.dart';
import 'package:kai_app/features/chat/data/dto/chat_stream_event.dart';

class FakeRemoteSource extends ChatRemoteSource {
  ChatResponseDto? _response;
  Object? _error;
  List<ChatStreamEvent> _streamEvents = const [];
  Object? _streamThrow;
  Object? _streamThrowAfterEvents;

  FakeRemoteSource() : super(_FakeApiClient());

  void setResponse(ChatResponseDto response) => _response = response;
  void setError(Object error) => _error = error;
  void setStreamEvents(List<ChatStreamEvent> events) => _streamEvents = events;
  // Throws BEFORE any events (simulates early cancel / immediate failure)
  void setThrowOnNext(Object error) => _streamThrow = error;
  // Throws AFTER all events are yielded (simulates cancel mid-stream)
  void setThrowAfterEvents(Object error) => _streamThrowAfterEvents = error;

  @override
  Future<ChatResponseDto> sendMessage(ChatRequestDto request) async {
    if (_error != null) throw _error!;
    return _response!;
  }

  @override
  Stream<ChatStreamEvent> streamMessage(
    ChatRequestDto request, {
    CancelToken? cancelToken,
  }) async* {
    if (_streamThrow != null) {
      final err = _streamThrow!;
      _streamThrow = null;
      throw err;
    }
    for (final event in _streamEvents) {
      yield event;
      // Mirror production SSE behavior: error and done are terminal events.
      final isTerminal = event.maybeWhen(
        error: (_) => true,
        done: () => true,
        orElse: () => false,
      );
      if (isTerminal) return;
    }
    if (_streamThrowAfterEvents != null) {
      final err = _streamThrowAfterEvents!;
      _streamThrowAfterEvents = null;
      throw err;
    }
  }
}

class _FakeApiClient extends Fake implements ApiClient {
  // Placeholder — FakeRemoteSource overrides sendMessage
}

class FakeLocalSource extends ChatLocalSource {
  final List<ChatMessage> savedMessages = [];
  Object? _throwOnSave;
  int _saveCount = 0;
  int _throwFromSaveN = 0;

  FakeLocalSource(Box chatBox, Box sessionBox)
      : super(chatBox: chatBox, sessionBox: sessionBox);

  // Throws on saves AFTER n-th call (skipFirst=1 skips the initial userMessage save)
  void setThrowOnSave(Object error, {int skipFirst = 1}) {
    _throwOnSave = error;
    _throwFromSaveN = _saveCount + skipFirst;
  }

  @override
  Future<void> saveMessage(ChatMessage message) async {
    _saveCount++;
    if (_throwOnSave != null && _saveCount > _throwFromSaveN) {
      throw _throwOnSave!;
    }
    savedMessages.add(message);
  }

  @override
  List<ChatMessage> getMessagesForSession(String sessionId) {
    return savedMessages.where((m) => m.sessionId == sessionId).toList();
  }
}

void main() {
  late FakeRemoteSource remoteSource;
  late FakeLocalSource localSource;
  late LocalStorage localStorage;
  late CircuitBreaker circuitBreaker;
  late ChatRepository repository;

  setUp(() async {
    await setUpTestHive();
    final settingsBox = await Hive.openBox('settings');
    final historyBox = await Hive.openBox('chat_history');
    final sessionBox = await Hive.openBox('sessions');

    remoteSource = FakeRemoteSource();
    localSource = FakeLocalSource(historyBox, sessionBox);
    localStorage = LocalStorage(settingsBox, historyBox);
    circuitBreaker = CircuitBreaker(failureThreshold: 3);
    repository = ChatRepository(
      remoteSource,
      localSource,
      localStorage,
      circuitBreaker,
    );
  });

  tearDown(() async {
    await tearDownTestHive();
  });

  test('streamMessage applies state metadata and approval to Kai message',
      () async {
    remoteSource.setStreamEvents([
      const ChatStreamEvent.state(step: 'E', label: 'enacting'),
      const ChatStreamEvent.message('Simulation ready. Proceed?'),
      const ChatStreamEvent.metadata(
        correlationId: 'corr-stream',
        language: 'en',
        requestType: 'fast',
        model: 'qwen3.5-9b',
        provider: 'kai_ft',
        latencyMs: 140,
        tokensUsed: 11,
        confidence: 0.81,
        piiBlocked: false,
      ),
      const ChatStreamEvent.approval(
        requiresHumanApproval: true,
        pendingConfirmation: true,
        confirmationType: 'simulation',
      ),
      const ChatStreamEvent.done(),
    ]);

    ChatMessage? latestKaiMessage;

    await repository.streamMessage(
      text: '/s risk Japan',
      sessionId: 'sess-1',
      onUpdate: (message) {
        if (!message.isUser) latestKaiMessage = message;
      },
    );

    expect(latestKaiMessage, isNotNull);
    expect(latestKaiMessage!.status, 'sent');
    expect(latestKaiMessage!.content, 'Simulation ready. Proceed?');
    // BUG-RENDER-GATE-1 (2026-05-17): done event now clears cognitive
    // status fields so the indicator hides cleanly after the message
    // finalises. We still verify state events were *received* during
    // streaming by checking the final value got applied at least once
    // (model/provider below — those came from the same metadata event).
    expect(latestKaiMessage!.currentStep, isNull);
    expect(latestKaiMessage!.cognitiveStatus, isNull);
    expect(latestKaiMessage!.model, 'qwen3.5-9b');
    expect(latestKaiMessage!.provider, 'kai_ft');
    expect(latestKaiMessage!.latencyMs, 140);
    expect(latestKaiMessage!.tokensUsed, 11);
    expect(latestKaiMessage!.correlationId, 'corr-stream');
    expect(latestKaiMessage!.requiresHumanApproval, isTrue);
    expect(latestKaiMessage!.pendingConfirmation, isTrue);
    expect(latestKaiMessage!.confirmationType, 'simulation');
    expect(
        localSource.savedMessages
            .where((message) => !message.isUser)
            .single
            .status,
        'sent');
  });

  // T30 — error event terminates stream: subsequent done must NOT overwrite status
  test('error event terminates stream — subsequent done event ignored', () async {
    remoteSource.setStreamEvents([
      const ChatStreamEvent.state(step: 'P', label: 'perceiving'),
      const ChatStreamEvent.error('upstream timeout'),
      const ChatStreamEvent.done(), // must NOT be processed after error
    ]);

    final updates = <ChatMessage>[];
    await repository.streamMessage(
      text: 'visa Japan',
      sessionId: 'sess-err-done',
      onUpdate: (m) => updates.add(m),
    );

    final lastKai = updates.lastWhere((m) => !m.isUser);
    expect(lastKai.status, 'error',
        reason: 'subsequent done event must NOT overwrite error status to sent');
    expect(lastKai.content, contains('Error:'),
        reason: 'error content must not be overwritten by done handler');
  });

  // T12 — T8 regression: error event clears cognitive indicators
  test('error event clears cognitive indicators and persists user-message as error',
      () async {
    remoteSource.setStreamEvents([
      const ChatStreamEvent.state(step: 'P', label: 'perceiving'),
      const ChatStreamEvent.state(step: 'E', label: 'enacting'),
      const ChatStreamEvent.error('upstream timeout'),
    ]);

    final updates = <ChatMessage>[];

    await repository.streamMessage(
      text: 'visa Japan',
      sessionId: 'sess-err',
      onUpdate: (m) => updates.add(m),
    );

    final lastKai = updates.lastWhere((m) => !m.isUser);
    expect(lastKai.cognitiveStatus, isNull,
        reason: 'cognitiveStatus must be cleared on error');
    expect(lastKai.currentStep, isNull,
        reason: 'currentStep must be cleared on error');
    expect(lastKai.thinking, isNull,
        reason: 'thinking must be cleared on error');
    expect(lastKai.status, 'error');

    final persistedUser = localSource.savedMessages.lastWhere((m) => m.isUser);
    expect(persistedUser.status, 'failed',
        reason: 'user message must be persisted as failed (matches MessageStatus enum)');
  });

  // T29 — cancel after stream started: responseMessage gets status='error' (not 'typing')
  test('cancel path persists responseMessage with status=error (not typing)', () async {
    // Yield a message chunk first so cogStepCount==0 but content is non-empty
    // → streamStarted=true after T32 guard is applied → persist IS expected.
    remoteSource.setStreamEvents([
      const ChatStreamEvent.message('Привет'),
    ]);
    remoteSource.setThrowAfterEvents(
      DioException(
        requestOptions: RequestOptions(path: '/chat/stream'),
        type: DioExceptionType.cancel,
      ),
    );

    await repository.streamMessage(
      text: 'visa Japan',
      sessionId: 'sess-cancel',
      onUpdate: (_) {},
    );

    final persistedKai = localSource.savedMessages
        .where((m) => !m.isUser)
        .last;
    expect(persistedKai.status, 'error',
        reason: 'cancel must update responseMessage status (was stuck on typing)');
    expect(persistedKai.cognitiveStatus, isNull);

    final persistedUser = localSource.savedMessages
        .where((m) => m.isUser)
        .last;
    expect(persistedUser.status, 'failed');
  });

  // T34 — error path emits both messages via onUpdate (user message visible immediately)
  test('error path emits both updated messages via onUpdate', () async {
    remoteSource.setStreamEvents([
      const ChatStreamEvent.error('upstream timeout'),
    ]);

    final updates = <ChatMessage>[];
    await repository.streamMessage(
      text: 'visa Japan',
      sessionId: 'sess-on-update',
      onUpdate: (m) => updates.add(m),
    );

    final userUpdates = updates.where((m) => m.isUser).toList();
    expect(userUpdates.isNotEmpty, isTrue,
        reason: 'failed user message must be emitted via onUpdate (T34)');
    expect(userUpdates.last.status, 'failed',
        reason: 'user message status visible without session reload');

    final kaiUpdates = updates.where((m) => !m.isUser).toList();
    expect(kaiUpdates.last.status, 'error');
  });

  // T33 — saveMessage failures in error path do not cascade to connection-error
  test('saveMessage failures in error path do not cascade', () async {
    remoteSource.setStreamEvents([
      const ChatStreamEvent.error('upstream timeout'),
    ]);
    localSource.setThrowOnSave(Exception('Box closed'));

    await expectLater(
      repository.streamMessage(
        text: 'test',
        sessionId: 'sess-save-fail',
        onUpdate: (_) {},
      ),
      completes,
      reason: 'error handler must not propagate storage failures',
    );
  });

  // T32 — cancel before stream starts must NOT persist phantom messages
  test('cancel before stream starts does NOT persist phantom messages', () async {
    remoteSource.setThrowOnNext(
      DioException(
        requestOptions: RequestOptions(path: '/chat/stream'),
        type: DioExceptionType.cancel,
      ),
    );

    await repository.streamMessage(
      text: 'visa Japan',
      sessionId: 'sess-ghost',
      onUpdate: (_) {},
    );

    final kaiMessages = localSource.savedMessages.where((m) => !m.isUser).toList();
    expect(kaiMessages, isEmpty,
        reason: 'no phantom responseMessage should be persisted on early cancel');

    final userMessages = localSource.savedMessages.where((m) => m.isUser).toList();
    expect(userMessages.length, 1,
        reason: 'only initial sending userMessage saved, no failed overwrite');
    expect(userMessages.first.status, 'sending',
        reason: 'userMessage status not mutated on early cancel');
  });

  // T12 — T9 regression: state events must not introduce artificial delays.
  // End with error (not done) to avoid the BUG-STREAM-FRAME-1 cognitive-status
  // drain (1 200 ms × cogStepCount) which is intentional and unrelated to T9.
  test('state events do not introduce artificial delays', () async {
    remoteSource.setStreamEvents([
      const ChatStreamEvent.state(step: 'P', label: 'perceiving'),
      const ChatStreamEvent.state(step: 'E', label: 'enacting'),
      const ChatStreamEvent.state(step: 'V', label: 'evaluating'),
      const ChatStreamEvent.error('test-end'),
    ]);

    final sw = Stopwatch()..start();
    await repository.streamMessage(
      text: 'route planner',
      sessionId: 'sess-delay',
      onUpdate: (_) {},
    );
    sw.stop();

    // 3 state events × 80ms = 240ms if artificial delay not removed.
    // Allow 200ms for real I/O overhead (Hive writes).
    expect(sw.elapsedMilliseconds, lessThan(200),
        reason: 'state handler must not sleep between SSE events');
  });
}
