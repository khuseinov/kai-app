import 'package:flutter/material.dart';
import 'package:flutter_markdown/flutter_markdown.dart';

import '../../../../core/design/theme/theme_extensions.dart';
import '../../../../core/design/tokens/kai_spacing.dart';
import '../../../chat/presentation/widgets/source_chips.dart';
import '../../domain/country_tool_result.dart';

/// Renders a CountryToolResult: markdown content + source provenance chips.
/// Reuses the source_chips.dart widget from APP-A1.
class ToolResultCard extends StatelessWidget {
  final CountryToolResult result;

  const ToolResultCard({super.key, required this.result});

  @override
  Widget build(BuildContext context) {
    final colors = context.kaiColors;

    return SingleChildScrollView(
      padding: const EdgeInsets.all(KaiSpacing.m),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          MarkdownBody(
            data: result.content,
            styleSheet: MarkdownStyleSheet.fromTheme(Theme.of(context)),
          ),
          if (result.sources.isNotEmpty) ...[
            const SizedBox(height: KaiSpacing.m),
            Divider(color: colors.textTertiary.withValues(alpha: 0.2)),
            const SizedBox(height: KaiSpacing.xs),
            SourceChips(sources: result.sources),
          ],
        ],
      ),
    );
  }
}
