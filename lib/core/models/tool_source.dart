import 'package:freezed_annotation/freezed_annotation.dart';

part 'tool_source.freezed.dart';
part 'tool_source.g.dart';

/// Tool source provenance record — returned in ChatResponse.sources (TOOL-PROV-1).
///
/// Carries the data source, display name, and freshness timestamps for each
/// tool result so the UI can show provenance chips (APP-A1 / APP-TOOL-PROV-1).
@freezed
class ToolSource with _$ToolSource {
  const factory ToolSource({
    required String tool,
    required String source,
    @JsonKey(name: 'source_display_name') String? sourceDisplayName,
    @JsonKey(name: 'fetched_at') String? fetchedAt,
    @JsonKey(name: 'expires_at') String? expiresAt,
    @JsonKey(name: 'staleness_note') String? stalenessNote,
  }) = _ToolSource;

  factory ToolSource.fromJson(Map<String, dynamic> json) =>
      _$ToolSourceFromJson(json);
}
