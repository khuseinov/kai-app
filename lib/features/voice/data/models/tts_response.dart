import 'dart:typed_data';

import 'package:freezed_annotation/freezed_annotation.dart';

part 'tts_response.freezed.dart';

/// Decoded audio returned by `POST /voice/tts`.
///
/// The gateway returns raw MP3 bytes with `X-TTS-Voice` and `X-TTS-Cached`
/// headers, so this model is assembled from the binary body and headers.
@freezed
class TtsResponse with _$TtsResponse {
  const factory TtsResponse({
    required Uint8List audio,
    required String voice,
    @Default(false) bool cached,
  }) = _TtsResponse;
}
