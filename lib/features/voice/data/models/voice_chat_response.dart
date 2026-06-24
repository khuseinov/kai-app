import 'dart:typed_data';

import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:kai_app/features/voice/data/models/base64_audio_converter.dart';

part 'voice_chat_response.freezed.dart';
part 'voice_chat_response.g.dart';

/// Response from `POST /voice/chat`.
///
/// The `audio` field is base64-encoded on the wire and decoded into
/// [Uint8List] during deserialization.
@freezed
class VoiceChatResponse with _$VoiceChatResponse {
  const factory VoiceChatResponse({
    required String transcript,
    @JsonKey(name: 'response_text') required String responseText,
    @JsonKey(name: 'audio') @Base64AudioConverter() required Uint8List audio,
    @JsonKey(name: 'audio_url') String? audioUrl,
    @JsonKey(name: 'tts_failed') @Default(false) bool ttsFailed,
    @JsonKey(name: 'tts_voice') @Default('') String ttsVoice,
    @JsonKey(name: 'tts_cached') @Default(false) bool ttsCached,
    @Default('en') String language,
    @JsonKey(name: 'correlation_id') @Default('') String correlationId,
  }) = _VoiceChatResponse;

  factory VoiceChatResponse.fromJson(Map<String, Object?> json) =>
      _$VoiceChatResponseFromJson(json);
}
