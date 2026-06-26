import 'package:kai_app/features/voice/data/models/stt_response.dart';
import 'package:kai_app/features/voice/data/models/tts_response.dart';
import 'package:kai_app/features/voice/data/models/voice_chat_job_response.dart';
import 'package:kai_app/features/voice/data/models/voice_chat_job_status.dart';

/// Repository for voice-gateway endpoints.
abstract class VoiceRepository {
  /// Transcribes an audio file to text via `POST /voice/stt`.
  Future<SttResponse> transcribeAudio(String audioPath, String language);

  /// Synthesizes text to audio via `POST /voice/tts`.
  Future<TtsResponse> synthesizeText(String text, String language);

  /// Sends a voice message to Kai and returns a job handle
  /// via `POST /voice/chat`.
  Future<VoiceChatJobResponse> sendVoiceChat(
    String audioPath,
    String sessionId,
    String? userId,
    String language,
  );

  /// Polls the current status/result of a voice-chat job
  /// via `GET /voice/jobs/{job_id}`.
  Future<VoiceChatJobStatus> getVoiceChatJob(String jobId);
}
