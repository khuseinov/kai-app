import 'package:freezed_annotation/freezed_annotation.dart';

import 'tool_source.dart';

part 'chat_message.freezed.dart';
part 'chat_message.g.dart';

@freezed
class ChatMessage with _$ChatMessage {
  const factory ChatMessage({
    required String id,
    required String content,
    required bool isUser,
    required DateTime timestamp,
    String? sessionId,
    @Default('sent') String status,
    String? language,
    String? model,
    String? provider,
    String? requestType,
    double? confidence,
    int? latencyMs,
    int? tokensUsed,
    bool? piiBlocked,
    String? thinking,
    String? correlationId,
    String? currentStep,
    String? cognitiveStatus,
    bool? requiresHumanApproval,
    bool? pendingConfirmation,
    String? confirmationType,
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
  }) = _ChatMessage;

  factory ChatMessage.fromJson(Map<String, dynamic> json) =>
      _$ChatMessageFromJson(json);
}
