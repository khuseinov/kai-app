import 'package:flutter_test/flutter_test.dart';
import 'package:hive/hive.dart';
import 'package:hive_test/hive_test.dart';
import 'package:kai_app/core/api/api_client.dart';
import 'package:kai_app/core/api/api_exceptions.dart';
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

  FakeRemoteSource() : super(_FakeApiClient());

  void setResponse(ChatResponseDto response) => _response = response;
  void setError(Object error) => _error = error;
  void setStreamEvents(List<ChatStreamEvent> events) => _streamEvents = events;

  @override
  Future<ChatResponseDto> sendMessage(ChatRequestDto request) async {
    if (_error != null) throw _error!;
    return _response!;
  }

  @override
  Stream<ChatStreamEvent> streamMessage(ChatRequestDto request) async* {
    for (final event in _streamEvents) {
      yield event;
    }
  }
}

class _FakeApiClient extends Fake implements ApiClient {
  // Placeholder — FakeRemoteSource overrides sendMessage
}

class FakeLocalSource extends ChatLocalSource {
  final List<ChatMessage> savedMessages = [];

  FakeLocalSource(Box chatBox, Box sessionBox)
      : super(chatBox: chatBox, sessionBox: sessionBox);

  @override
  Future<void> saveMessage(ChatMessage message) async {
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

  const testResponse = ChatResponseDto(
    response: 'Tokyo is beautiful in spring!',
    language: 'en',
    model: 'gpt-4',
    provider: 'openai',
    requestType: 'travel',
    confidence: 0.95,
    latencyMs: 1200,
    tokensUsed: 150,
    piiBlocked: false,
    correlationId: 'corr-123',
  );

  test('sendMessage saves user message locally first', () async {
    remoteSource.setResponse(testResponse);

    await repository.sendMessage(
      text: 'Tell me about Tokyo',
      sessionId: 'sess-1',
    );

    expect(localSource.savedMessages.length, greaterThanOrEqualTo(2));
    final userMsg = localSource.savedMessages.first;
    expect(userMsg.isUser, isTrue);
    expect(userMsg.content, 'Tell me about Tokyo');
    expect(userMsg.sessionId, 'sess-1');
    expect(userMsg.status, 'sending');
  });

  test('sendMessage calls onMessageSavedLocally with user message', () async {
    remoteSource.setResponse(testResponse);
    ChatMessage? savedLocally;

    await repository.sendMessage(
      text: 'Hello',
      sessionId: 'sess-1',
      onMessageSavedLocally: (msg) => savedLocally = msg,
    );

    expect(savedLocally, isNotNull);
    expect(savedLocally!.isUser, isTrue);
    expect(savedLocally!.content, 'Hello');
  });

  test('sendMessage saves KAI response locally', () async {
    remoteSource.setResponse(testResponse);

    await repository.sendMessage(
      text: 'Hello',
      sessionId: 'sess-1',
    );

    expect(localSource.savedMessages.length, 3); // user+sending, kai, user+sent
    final kaiMsg = localSource.savedMessages[1];
    expect(kaiMsg.isUser, isFalse);
    expect(kaiMsg.content, 'Tokyo is beautiful in spring!');
    expect(kaiMsg.model, 'gpt-4');
    expect(kaiMsg.provider, 'openai');
  });

  test('sendMessage returns KAI message with metadata', () async {
    remoteSource.setResponse(testResponse);

    final result = await repository.sendMessage(
      text: 'Hello',
      sessionId: 'sess-1',
    );

    expect(result.isUser, isFalse);
    expect(result.content, 'Tokyo is beautiful in spring!');
    expect(result.language, 'en');
    expect(result.model, 'gpt-4');
    expect(result.provider, 'openai');
    expect(result.confidence, 0.95);
    expect(result.latencyMs, 1200);
    expect(result.tokensUsed, 150);
    expect(result.correlationId, 'corr-123');
  });

  test('sendMessage updates user message status to sent', () async {
    remoteSource.setResponse(testResponse);

    await repository.sendMessage(
      text: 'Hello',
      sessionId: 'sess-1',
    );

    // Last saved message should be the user message with status 'sent'
    final lastMsg = localSource.savedMessages.last;
    expect(lastMsg.isUser, isTrue);
    expect(lastMsg.status, 'sent');
  });

  test('sendMessage rethrows when remote source fails', () async {
    remoteSource.setError(Exception('Network error'));

    expect(
      () => repository.sendMessage(
        text: 'Hello',
        sessionId: 'sess-1',
      ),
      throwsA(isA<Exception>()),
    );
  });

  test('sendMessage rethrows when circuit breaker is open', () async {
    // Trip the circuit breaker
    final cb = CircuitBreaker(failureThreshold: 1);
    try {
      await cb.execute(() => Future.error(Exception('fail')));
    } catch (_) {}

    repository = ChatRepository(
      remoteSource,
      localSource,
      localStorage,
      cb,
    );

    expect(
      () => repository.sendMessage(
        text: 'Hello',
        sessionId: 'sess-1',
      ),
      throwsA(isA<CircuitBreakerException>()),
    );
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
    expect(latestKaiMessage!.currentStep, 'E');
    expect(latestKaiMessage!.cognitiveStatus, 'enacting');
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
}
