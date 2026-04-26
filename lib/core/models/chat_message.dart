import 'package:freezed_annotation/freezed_annotation.dart';

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
  }) = _ChatMessage;

  factory ChatMessage.fromJson(Map<String, dynamic> json) =>
      _$ChatMessageFromJson(json);
}
