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
  }) = _ChatResponseDto;

  factory ChatResponseDto.fromJson(Map<String, dynamic> json) =>
      _$ChatResponseDtoFromJson(json);
}
