import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:kai_app/core/api/api_client.dart';
import 'package:kai_app/features/chat/data/chat_remote_source.dart';
import 'package:kai_app/features/chat/data/dto/chat_request_dto.dart';
import 'package:kai_app/features/chat/data/dto/chat_stream_event.dart';

class FakeApiClient extends ApiClient {
  Map<String, dynamic>? _sendMessageResponse;
  Object? _sendMessageError;
  List<String> _streamLines = const [];

  FakeApiClient() : super(Dio());

  void setSendMessageResponse(Map<String, dynamic> data) {
    _sendMessageResponse = data;
  }

  void setSendMessageError(Object error) {
    _sendMessageError = error;
  }

  void setStreamLines(List<String> lines) {
    _streamLines = lines;
  }

  @override
  Future<Map<String, dynamic>> sendMessage({
    required String message,
    required String userId,
    required String sessionId,
  }) async {
    if (_sendMessageError != null) throw _sendMessageError!;
    return _sendMessageResponse!;
  }

  @override
  Stream<String> streamMessage({
    required String message,
    required String userId,
    required String sessionId,
    CancelToken? cancelToken,
  }) async* {
    for (final line in _streamLines) {
      yield line;
    }
  }
}

void main() {
  late FakeApiClient apiClient;
  late ChatRemoteSource remoteSource;

  setUp(() {
    apiClient = FakeApiClient();
    remoteSource = ChatRemoteSource(apiClient);
  });

  test('sendMessage returns parsed ChatResponseDto', () async {
    apiClient.setSendMessageResponse({
      'response': 'Paris is lovely in autumn!',
      'language': 'en',
      'model': 'gpt-4',
      'provider': 'openai',
    });

    const request = ChatRequestDto(
      message: 'Tell me about Paris',
      userId: 'user-1',
      sessionId: 'sess-1',
    );

    final result = await remoteSource.sendMessage(request);

    expect(result.response, 'Paris is lovely in autumn!');
    expect(result.language, 'en');
    expect(result.model, 'gpt-4');
    expect(result.provider, 'openai');
  });

  test('sendMessage returns dto with optional fields null', () async {
    apiClient.setSendMessageResponse({
      'response': 'Simple answer',
    });

    const request = ChatRequestDto(
      message: 'Hi',
      userId: 'user-1',
      sessionId: 'sess-1',
    );

    final result = await remoteSource.sendMessage(request);

    expect(result.response, 'Simple answer');
    expect(result.language, isNull);
    expect(result.model, isNull);
    expect(result.provider, isNull);
  });

  test('sendMessage throws when apiClient throws', () async {
    apiClient.setSendMessageError(Exception('Connection refused'));

    const request = ChatRequestDto(
      message: 'Hi',
      userId: 'user-1',
      sessionId: 'sess-1',
    );

    expect(
      () => remoteSource.sendMessage(request),
      throwsA(isA<Exception>()),
    );
  });

  test('streamMessage parses agent contract events and suppresses raw thinking',
      () async {
    apiClient.setStreamLines([
      'event: state',
      'data: {"step":"E","label":"enacting"}',
      'event: thinking',
      'data: {"choices":[{"delta":{"content":"hidden chain"}}]}',
      'event: message',
      'data: {"choices":[{"delta":{"content":"visible answer"}}]}',
      'event: metadata',
      'data: {"correlation_id":"corr-1","language":"en","request_type":"fast","model":"qwen3.5-9b","provider":"kai_ft","latency_ms":120,"tokens_used":9,"confidence":0.82,"pii_blocked":false}',
      'event: approval',
      'data: {"requires_human_approval":true,"pending_confirmation":true,"confirmation_type":"simulation"}',
      'event: done',
      'data: [DONE]',
    ]);

    const request = ChatRequestDto(
      message: '/s risk Japan',
      userId: 'user-1',
      sessionId: 'sess-1',
    );

    final events = await remoteSource.streamMessage(request).toList();

    expect(events,
        contains(const ChatStreamEvent.state(step: 'E', label: 'enacting')));
    expect(events, contains(const ChatStreamEvent.message('visible answer')));
    expect(
      events,
      contains(
        const ChatStreamEvent.metadata(
          correlationId: 'corr-1',
          language: 'en',
          requestType: 'fast',
          model: 'qwen3.5-9b',
          provider: 'kai_ft',
          latencyMs: 120,
          tokensUsed: 9,
          confidence: 0.82,
          piiBlocked: false,
        ),
      ),
    );
    expect(
      events,
      contains(
        const ChatStreamEvent.approval(
          requiresHumanApproval: true,
          pendingConfirmation: true,
          confirmationType: 'simulation',
        ),
      ),
    );
    expect(events, contains(const ChatStreamEvent.done()));
    expect(
      events.where((event) =>
          event.maybeWhen(thinking: (_) => true, orElse: () => false)),
      isEmpty,
    );
  });

  test('streamMessage returns plain SSE error data', () async {
    apiClient.setStreamLines([
      'event: error',
      'data: backend unavailable',
    ]);

    const request = ChatRequestDto(
      message: 'Hi',
      userId: 'user-1',
      sessionId: 'sess-1',
    );

    final events = await remoteSource.streamMessage(request).toList();

    expect(events, [const ChatStreamEvent.error('backend unavailable')]);
  });
}
