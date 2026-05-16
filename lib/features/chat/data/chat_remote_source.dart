import 'dart:convert';
import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import '../../../core/api/api_client.dart';
import '../../../core/models/tool_source.dart';
import 'dto/async_chat_dto.dart';
import 'dto/chat_stream_event.dart';
import 'dto/chat_request_dto.dart';
import 'dto/chat_response_dto.dart';

class ChatRemoteSource {
  final ApiClient _apiClient;

  ChatRemoteSource(this._apiClient);

  Future<AsyncChatResponseDto> chatAsync(ChatRequestDto request) async {
    final response = await _apiClient.chatAsync(
      message: request.message,
      userId: request.userId,
      sessionId: request.sessionId,
    );
    return AsyncChatResponseDto.fromJson(response);
  }

  Future<TaskStatusResponseDto> pollStatus(String taskId) async {
    final response = await _apiClient.chatStatus(taskId);
    return TaskStatusResponseDto.fromJson(response);
  }

  Future<ChatResponseDto> sendMessage(ChatRequestDto request) async {
    final response = await _apiClient.sendMessage(
      message: request.message,
      userId: request.userId,
      sessionId: request.sessionId,
    );

    return ChatResponseDto.fromJson(response);
  }

  Stream<ChatStreamEvent> streamMessage(
    ChatRequestDto request, {
    CancelToken? cancelToken,
  }) async* {
    final stream = _apiClient.streamMessage(
      message: request.message,
      userId: request.userId,
      sessionId: request.sessionId,
      cancelToken: cancelToken,
    );

    String? currentEvent;

    await for (final line in stream) {
      if (line.startsWith('event: ')) {
        currentEvent = line.substring(7).trim();
      } else if (line.startsWith('data: ')) {
        final data = line.substring(6).trim();

        if (data == '[DONE]' || currentEvent == 'done') {
          yield const ChatStreamEvent.done();
          continue;
        }

        if (currentEvent == 'error') {
          yield ChatStreamEvent.error(data);
          continue;
        }

        try {
          final json = jsonDecode(data);

          if (currentEvent == 'message') {
            final content =
                json['choices'][0]['delta']['content'] as String? ?? '';
            yield ChatStreamEvent.message(content);
          } else if (currentEvent == 'thinking') {
            // Raw reasoning is not user-visible in kai-app. Backend should not
            // emit it, but older streams are ignored defensively.
            continue;
          } else if (currentEvent == 'state') {
            yield ChatStreamEvent.state(
              step: json['step'] as String? ?? '',
              label: json['label'] as String? ?? '',
            );
          } else if (currentEvent == 'metadata') {
            yield ChatStreamEvent.metadata(
              correlationId: json['correlation_id'] as String? ?? '',
              language: json['language'] as String?,
              requestType: json['request_type'] as String?,
              model: json['model'] as String?,
              provider: json['provider'] as String?,
              latencyMs: (json['latency_ms'] as num?)?.toInt(),
              tokensUsed: (json['tokens_used'] as num?)?.toInt(),
              confidence: (json['confidence'] as num?)?.toDouble(),
              piiBlocked: json['pii_blocked'] as bool?,
              specialMode: json['special_mode'] as String?,
              executedToolCalls: (json['executed_tool_calls'] as List<dynamic>?)
                      ?.cast<String>() ??
                  [],
              worldModelUsed: json['world_model_used'] as bool?,
              kgNodesQueried: (json['kg_nodes_queried'] as num?)?.toInt(),
              revisionCount: (json['revision_count'] as num?)?.toInt(),
              crisisDetected: json['crisis_detected'] as bool?,
              crisisCategory: json['crisis_category'] as String?,
              scopeEscalationDetected:
                  json['scope_escalation_detected'] as bool?,
              scopeEscalationCategories:
                  (json['scope_escalation_categories'] as List<dynamic>?)
                          ?.cast<String>() ??
                      const [],
              scopeInheritanceViolation:
                  json['scope_inheritance_violation'] as bool?,
              injectionFragment: json['injection_fragment'] as String?,
              injectionSource: json['injection_source'] as String?,
              sources: (json['sources'] as List<dynamic>?)
                      ?.whereType<Map<String, dynamic>>()
                      .map(ToolSource.fromJson)
                      .toList() ??
                  const [],
              biasSuggestions: (json['bias_suggestions'] as List<dynamic>?)
                      ?.cast<String>() ??
                  const [],
              blockReason: json['block_reason'] as String?,
              sourceWarnings: (json['source_warnings'] as List<dynamic>?)
                      ?.cast<String>() ??
                  const [],
              verificationPassed: json['verification_passed'] as bool? ?? true,
              verificationFailReason:
                  json['verification_fail_reason'] as String? ?? '',
              advisorTriggered: json['advisor_triggered'] as bool? ?? false,
            );
          } else if (currentEvent == 'approval') {
            yield ChatStreamEvent.approval(
              requiresHumanApproval:
                  json['requires_human_approval'] as bool? ?? false,
              pendingConfirmation:
                  json['pending_confirmation'] as bool? ?? false,
              confirmationType: json['confirmation_type'] as String?,
            );
          } else if (currentEvent != null) {
            debugPrint('SSE: unknown event "$currentEvent" — data: $data');
          }
        } catch (e) {
          yield ChatStreamEvent.error(e.toString());
        }
      }
    }
  }
}
