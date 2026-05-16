import '../../../core/models/tool_source.dart';

/// Result from a single tool call for a country tab.
/// Populated by CountryToolRepository (APP-D3).
class CountryToolResult {
  final String content;
  final List<ToolSource> sources;

  const CountryToolResult({
    required this.content,
    this.sources = const [],
  });
}
