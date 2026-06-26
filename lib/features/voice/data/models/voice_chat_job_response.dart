import 'package:freezed_annotation/freezed_annotation.dart';

part 'voice_chat_job_response.freezed.dart';
part 'voice_chat_job_response.g.dart';

/// Response from `POST /voice/chat` when a job is accepted.
@freezed
class VoiceChatJobResponse with _$VoiceChatJobResponse {
  const factory VoiceChatJobResponse({
    @JsonKey(name: 'job_id') required String jobId,
    required String status,
    @JsonKey(name: 'created_at') required DateTime createdAt,
  }) = _VoiceChatJobResponse;

  factory VoiceChatJobResponse.fromJson(Map<String, Object?> json) =>
      _$VoiceChatJobResponseFromJson(json);
}
