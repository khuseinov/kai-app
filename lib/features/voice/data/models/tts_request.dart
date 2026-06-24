import 'package:freezed_annotation/freezed_annotation.dart';

part 'tts_request.freezed.dart';
part 'tts_request.g.dart';

/// Request body for `POST /voice/tts`.
@freezed
class TtsRequest with _$TtsRequest {
  const factory TtsRequest({
    required String text,
    @Default('en') String language,
    String? voice,
    @Default('+0%') String rate,
  }) = _TtsRequest;

  factory TtsRequest.fromJson(Map<String, Object?> json) =>
      _$TtsRequestFromJson(json);
}
