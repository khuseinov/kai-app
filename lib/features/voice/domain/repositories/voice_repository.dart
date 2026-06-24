import 'dart:io';

import 'package:kai_app/features/voice/data/models/stt_response.dart';
import 'package:kai_app/features/voice/data/models/tts_response.dart';
import 'package:kai_app/features/voice/data/models/voice_chat_response.dart';

/// Repository for voice-gateway endpoints.
abstract class VoiceRepository {
  /// Transcribes an audio file to text via `POST /voice/stt`.
  Future<SttResponse> transcribeAudio(File audio, String language);

  /// Synthesizes text to audio via `POST /voice/tts`.
  Future<TtsResponse> synthesizeText(String text, String language);

  /// Sends a voice message to Kai and returns transcript + response audio
  /// via `POST /voice/chat`.
  Future<VoiceChatResponse> sendVoiceChat(
    File audio,
    String sessionId,
    String? userId,
    String language,
  );
}
