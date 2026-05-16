import 'package:freezed_annotation/freezed_annotation.dart';
import 'chat_response_dto.dart';

part 'async_chat_dto.freezed.dart';
part 'async_chat_dto.g.dart';

/// 202 response from POST /chat/async (CC-8).
@freezed
class AsyncChatResponseDto with _$AsyncChatResponseDto {
  const factory AsyncChatResponseDto({
    @JsonKey(name: 'task_id') required String taskId,
    @Default('PENDING') String status,
    @JsonKey(name: 'correlation_id') required String correlationId,
    @JsonKey(name: 'created_at') required String createdAt,
    @JsonKey(name: 'estimated_wait_seconds') @Default(30) int estimatedWaitSeconds,
    @JsonKey(name: 'result_endpoint') @Default('') String resultEndpoint,
  }) = _AsyncChatResponseDto;

  factory AsyncChatResponseDto.fromJson(Map<String, dynamic> json) =>
      _$AsyncChatResponseDtoFromJson(json);
}

/// Polling response from GET /chat/status/{task_id} (CC-8).
@freezed
class TaskStatusResponseDto with _$TaskStatusResponseDto {
  const factory TaskStatusResponseDto({
    @JsonKey(name: 'task_id') required String taskId,
    required String status, // PENDING | DONE | FAILED
    @JsonKey(name: 'created_at') required String createdAt,
    @JsonKey(name: 'elapsed_seconds') @Default(0.0) double elapsedSeconds,
    @JsonKey(name: 'completed_at') String? completedAt,
    ChatResponseDto? result,
    String? error,
  }) = _TaskStatusResponseDto;

  factory TaskStatusResponseDto.fromJson(Map<String, dynamic> json) =>
      _$TaskStatusResponseDtoFromJson(json);
}
