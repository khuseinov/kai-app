import 'package:flutter/material.dart';

import '../../../../core/design/theme/theme_extensions.dart';
import '../../../../core/design/tokens/kai_spacing.dart';
import '../../../../core/models/chat_message.dart';

/// User-facing message footer shown under Kai responses only.
///
/// Shows source verification count when tool sources exist.
/// Reactions (👍👎) are handled by _ReactionRow inside MessageBubble.
class MessageMetadataRow extends StatelessWidget {
  final ChatMessage message;

  const MessageMetadataRow({super.key, required this.message});

  @override
  Widget build(BuildContext context) {
    if (message.isUser) return const SizedBox.shrink();

    final sourceCount = message.sources.length;
    if (sourceCount == 0) return const SizedBox.shrink();

    final colors = context.kaiColors;
    final typography = context.kaiTypography;

    return Padding(
      padding: const EdgeInsets.only(
        top: KaiSpacing.xxxs,
        left: KaiSpacing.screenPadding,
        right: KaiSpacing.screenPadding,
        bottom: KaiSpacing.xxs,
      ),
      child: Row(
        children: [
          Icon(Icons.verified_outlined, size: 12, color: colors.textTertiary),
          const SizedBox(width: 4),
          Text(
            'Проверено в $sourceCount ${_sourcesLabel(sourceCount)}',
            style: typography.labelSmall.copyWith(
              color: colors.textTertiary,
              fontSize: 10,
            ),
          ),
        ],
      ),
    );
  }

  static String _sourcesLabel(int count) {
    if (count == 1) return 'источнике';
    return 'источниках';
  }
}
