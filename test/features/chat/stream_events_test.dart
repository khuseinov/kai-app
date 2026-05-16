import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:kai_app/core/api/api_client.dart';
import 'package:kai_app/features/chat/data/chat_remote_source.dart';
import 'package:kai_app/features/chat/data/dto/chat_request_dto.dart';
import 'package:kai_app/features/chat/data/dto/chat_stream_event.dart';

class _FakeApiClient extends ApiClient {
  List<String> lines = const [];

  _FakeApiClient() : super(Dio());

  @override
  Future<Map<String, dynamic>> sendMessage({
    required String message,
    required String userId,
    required String sessionId,
  }) async =>
      {};

  @override
  Stream<String> streamMessage({
    required String message,
    required String userId,
    required String sessionId,
    CancelToken? cancelToken,
  }) async* {
    for (final line in lines) {
      yield line;
    }
  }
}

const _request = ChatRequestDto(
  message: 'test',
  userId: 'u-1',
  sessionId: 's-1',
);

void main() {
  late _FakeApiClient api;
  late ChatRemoteSource source;

  setUp(() {
    api = _FakeApiClient();
    source = ChatRemoteSource(api);
  });

  test('message event accumulates text chunks', () async {
    api.lines = [
      'event: message',
      'data: {"choices":[{"delta":{"content":"Hello"}}]}',
      'event: message',
      'data: {"choices":[{"delta":{"content":", world"}}]}',
      'event: done',
      'data: [DONE]',
    ];

    final events = await source.streamMessage(_request).toList();
    final messages = events
        .map((e) => e.maybeWhen(message: (c) => c, orElse: () => null))
        .whereType<String>()
        .toList();

    expect(messages, ['Hello', ', world']);
    expect(events.last, const ChatStreamEvent.done());
  });

  test('state event updates cognitive step and label', () async {
    api.lines = [
      'event: state',
      'data: {"step":"P","label":"perceiving"}',
      'event: state',
      'data: {"step":"E","label":"enacting"}',
    ];

    final events = await source.streamMessage(_request).toList();

    expect(
      events,
      containsAllInOrder([
        const ChatStreamEvent.state(step: 'P', label: 'perceiving'),
        const ChatStreamEvent.state(step: 'E', label: 'enacting'),
      ]),
    );
  });

  test('metadata event populates all 25 fields', () async {
    api.lines = [
      'event: metadata',
      'data: {'
          '"correlation_id":"corr-42",'
          '"language":"ru",'
          '"request_type":"standard",'
          '"model":"qwen3.5-9b",'
          '"provider":"kai_ft",'
          '"latency_ms":350,'
          '"tokens_used":512,'
          '"confidence":0.91,'
          '"pii_blocked":false,'
          '"special_mode":"memorize",'
          '"executed_tool_calls":["visa_checker"],'
          '"world_model_used":true,'
          '"kg_nodes_queried":5,'
          '"revision_count":1,'
          '"crisis_detected":false,'
          '"crisis_category":null,'
          '"scope_escalation_detected":false,'
          '"scope_escalation_categories":[],'
          '"scope_inheritance_violation":false,'
          '"injection_fragment":null,'
          '"injection_source":null,'
          '"sources":[],'
          '"bias_suggestions":["consider alt view"],'
          '"block_reason":null'
          '}',
    ];

    final events = await source.streamMessage(_request).toList();

    events.first.when(
      message: (_) => fail('expected metadata'),
      thinking: (_) => fail('expected metadata'),
      state: (_, __) => fail('expected metadata'),
      approval: (_, __, ___) => fail('expected metadata'),
      correction: (_) => fail('expected metadata'),
      done: () => fail('expected metadata'),
      error: (_) => fail('expected metadata'),
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
      ) {
        expect(correlationId, 'corr-42');
        expect(language, 'ru');
        expect(requestType, 'standard');
        expect(model, 'qwen3.5-9b');
        expect(provider, 'kai_ft');
        expect(latencyMs, 350);
        expect(tokensUsed, 512);
        expect(confidence, closeTo(0.91, 0.001));
        expect(piiBlocked, false);
        expect(specialMode, 'memorize');
        expect(executedToolCalls, ['visa_checker']);
        expect(worldModelUsed, true);
        expect(kgNodesQueried, 5);
        expect(revisionCount, 1);
        expect(crisisDetected, false);
        expect(crisisCategory, isNull);
        expect(scopeEscalationDetected, false);
        expect(scopeEscalationCategories, isEmpty);
        expect(scopeInheritanceViolation, false);
        expect(injectionFragment, isNull);
        expect(injectionSource, isNull);
        expect(sources, isEmpty);
        expect(biasSuggestions, ['consider alt view']);
        expect(blockReason, isNull);
      },
    );
  });

  test('approval event carries HITL fields', () async {
    api.lines = [
      'event: approval',
      'data: {"requires_human_approval":true,"pending_confirmation":true,"confirmation_type":"simulation"}',
    ];

    final events = await source.streamMessage(_request).toList();

    expect(
      events.first,
      const ChatStreamEvent.approval(
        requiresHumanApproval: true,
        pendingConfirmation: true,
        confirmationType: 'simulation',
      ),
    );
  });

  test('done event finalizes stream', () async {
    api.lines = [
      'event: done',
      'data: [DONE]',
    ];

    final events = await source.streamMessage(_request).toList();

    expect(events, [const ChatStreamEvent.done()]);
  });

  test('error event propagates error string', () async {
    api.lines = [
      'event: error',
      'data: upstream timeout',
    ];

    final events = await source.streamMessage(_request).toList();

    expect(events, [const ChatStreamEvent.error('upstream timeout')]);
  });

  test('unknown event type is silently skipped', () async {
    api.lines = [
      'event: future_event',
      'data: {"some":"payload"}',
      'event: done',
      'data: [DONE]',
    ];

    final events = await source.streamMessage(_request).toList();

    // Only the done event — unknown future_event is discarded
    expect(events, [const ChatStreamEvent.done()]);
  });
}
