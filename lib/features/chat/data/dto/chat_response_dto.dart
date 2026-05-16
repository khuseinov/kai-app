import 'package:freezed_annotation/freezed_annotation.dart';

import '../../../../core/models/tool_source.dart';

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
    // Scope escalation signals (API-SCOPE-ESC-1; backend: alignment/scope.py)
    @JsonKey(name: 'scope_escalation_detected') bool? scopeEscalationDetected,
    @JsonKey(name: 'scope_escalation_categories')
    @Default([])
    List<String> scopeEscalationCategories,
    @JsonKey(name: 'scope_inheritance_violation')
    bool? scopeInheritanceViolation,
    // Injection transparency (API-INJ-SIGNALS-1; backend: cognitive/critique/critique.py B-12)
    @JsonKey(name: 'injection_fragment') String? injectionFragment,
    @JsonKey(name: 'injection_source') String? injectionSource,
    // Tool source provenance (APP-A1 / TOOL-PROV-1)
    @Default([]) List<ToolSource> sources,
    // Bias detector suggestions (APP-A3)
    @JsonKey(name: 'bias_suggestions') @Default([]) List<String> biasSuggestions,
    // Block reason for distinct safety banners (APP-A4)
    @JsonKey(name: 'block_reason') String? blockReason,
    // VerifyStep (APP-SPRINT-C-BE-1)
    @JsonKey(name: 'source_warnings') @Default([]) List<String> sourceWarnings,
    @JsonKey(name: 'verification_passed') @Default(true) bool verificationPassed,
    @JsonKey(name: 'verification_fail_reason') @Default('') String verificationFailReason,
    // AdvisorStep (APP-SPRINT-C-BE-2)
    @JsonKey(name: 'advisor_triggered') @Default(false) bool advisorTriggered,
  }) = _ChatResponseDto;

  factory ChatResponseDto.fromJson(Map<String, dynamic> json) =>
      _$ChatResponseDtoFromJson(json);
}
