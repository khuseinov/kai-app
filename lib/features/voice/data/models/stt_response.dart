import 'package:freezed_annotation/freezed_annotation.dart';

part 'stt_response.freezed.dart';
part 'stt_response.g.dart';

/// Response from `POST /voice/stt`.
@freezed
class SttResponse with _$SttResponse {
  const factory SttResponse({
    required String text,
    required String language,
    @JsonKey(name: 'language_probability') double? languageProbability,
    @JsonKey(name: 'duration_seconds') double? durationSeconds,
    String? model,
  }) = _SttResponse;

  factory SttResponse.fromJson(Map<String, Object?> json) =>
      _$SttResponseFromJson(json);
}
