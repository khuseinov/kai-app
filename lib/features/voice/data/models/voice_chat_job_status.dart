import 'dart:typed_data';

import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:kai_app/features/voice/data/models/base64_audio_converter.dart';

part 'voice_chat_job_status.freezed.dart';
part 'voice_chat_job_status.g.dart';

/// Possible states of a voice-chat job.
@JsonEnum(alwaysCreate: true)
enum VoiceJobStatus {
  pending,
  transcribing,
  thinking,
  synthesizing,
  completed,
  failed,
}

/// Status/result of `GET /voice/jobs/{job_id}`.
@freezed
class VoiceChatJobStatus with _$VoiceChatJobStatus {
  const factory VoiceChatJobStatus({
    @JsonKey(name: 'job_id') required String jobId,
    required VoiceJobStatus status,
    @JsonKey(name: 'session_id') required String sessionId,
    @JsonKey(name: 'user_id') String? userId,
    String? transcript,
    @JsonKey(name: 'response_text') String? responseText,
    @JsonKey(name: 'audio') @Base64AudioConverter() Uint8List? audio,
    @JsonKey(name: 'audio_url') String? audioUrl,
    @JsonKey(name: 'tts_failed') bool? ttsFailed,
    @JsonKey(name: 'tts_voice') String? ttsVoice,
    @JsonKey(name: 'tts_cached') bool? ttsCached,
    String? language,
    @JsonKey(name: 'correlation_id') String? correlationId,
    String? error,
    @JsonKey(name: 'created_at') required DateTime createdAt,
    @JsonKey(name: 'updated_at') required DateTime updatedAt,
  }) = _VoiceChatJobStatus;

  factory VoiceChatJobStatus.fromJson(Map<String, Object?> json) =>
      _$VoiceChatJobStatusFromJson(json);
}
