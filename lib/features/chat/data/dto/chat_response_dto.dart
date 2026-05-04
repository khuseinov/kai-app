import 'package:freezed_annotation/freezed_annotation.dart';

part 'chat_response_dto.freezed.dart';
part 'chat_response_dto.g.dart';

@freezed
class ChatResponseDto with _$ChatResponseDto {
  const factory ChatResponseDto({
    required String response,
    String? language,
    String? model,
    String? provider,
    @JsonKey(name: 'request_type') String? requestType,
    double? confidence,
    @JsonKey(name: 'latency_ms') int? latencyMs,
    @JsonKey(name: 'tokens_used') int? tokensUsed,
    @JsonKey(name: 'pii_blocked') bool? piiBlocked,
    @JsonKey(name: 'correlation_id') String? correlationId,
    // Autonomous decision signals (APP-A-BE-2)
    @JsonKey(name: 'special_mode') String? specialMode,
    @JsonKey(name: 'executed_tool_calls') @Default([]) List<String> executedToolCalls,
    @JsonKey(name: 'world_model_used') bool? worldModelUsed,
    @JsonKey(name: 'kg_nodes_queried') int? kgNodesQueried,
    @JsonKey(name: 'revision_count') int? revisionCount,
    @JsonKey(name: 'crisis_detected') bool? crisisDetected,
    @JsonKey(name: 'crisis_category') String? crisisCategory,
  }) = _ChatResponseDto;

  factory ChatResponseDto.fromJson(Map<String, dynamic> json) =>
      _$ChatResponseDtoFromJson(json);
}
