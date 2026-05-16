import 'package:freezed_annotation/freezed_annotation.dart';

import '../../../../core/models/tool_source.dart';

part 'chat_stream_event.freezed.dart';

@freezed
class ChatStreamEvent with _$ChatStreamEvent {
  const factory ChatStreamEvent.message(String content) = _EventMessage;
  const factory ChatStreamEvent.thinking(String content) = _EventThinking;
  const factory ChatStreamEvent.state({
    required String step,
    required String label,
  }) = _EventState;
  const factory ChatStreamEvent.metadata({
    required String correlationId,
    String? language,
    String? requestType,
    String? model,
    String? provider,
    int? latencyMs,
    int? tokensUsed,
    double? confidence,
    bool? piiBlocked,
    // Autonomous decision signals (APP-A-BE-2)
    String? specialMode,
    @Default([]) List<String> executedToolCalls,
    bool? worldModelUsed,
    int? kgNodesQueried,
    int? revisionCount,
    bool? crisisDetected,
    String? crisisCategory,
    // Scope escalation signals (API-SCOPE-ESC-1)
    bool? scopeEscalationDetected,
    @Default([]) List<String> scopeEscalationCategories,
    bool? scopeInheritanceViolation,
    // Injection transparency (API-INJ-SIGNALS-1)
    String? injectionFragment,
    String? injectionSource,
    // Tool source provenance (APP-A1 / TOOL-PROV-1)
    @Default([]) List<ToolSource> sources,
    // Bias detector suggestions (APP-A3)
    @Default([]) List<String> biasSuggestions,
    // Block reason for distinct safety banners (APP-A4)
    String? blockReason,
  }) = _EventMetadata;
  const factory ChatStreamEvent.approval({
    required bool requiresHumanApproval,
    required bool pendingConfirmation,
    String? confirmationType,
  }) = _EventApproval;
  const factory ChatStreamEvent.done() = _EventDone;
  const factory ChatStreamEvent.error(String error) = _EventError;
}
