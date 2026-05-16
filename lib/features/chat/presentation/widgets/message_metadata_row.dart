import 'package:flutter/material.dart';

import '../../../../core/design/theme/theme_extensions.dart';
import '../../../../core/design/tokens/kai_spacing.dart';
import '../../../../core/models/chat_message.dart';

/// User-facing message footer shown under Kai responses only.
///
/// Shows:
///   • source verification count (when tool sources exist)
///   • 👍 / 👎 reaction buttons  (always on Kai messages)
///
/// All dev signals (mode, tool names, provider, tokens, revision, advisor,
/// scope) are removed — available in the long-press Detail Sheet later.
class MessageMetadataRow extends StatelessWidget {
  final ChatMessage message;

  const MessageMetadataRow({super.key, required this.message});

  @override
  Widget build(BuildContext context) {
    if (message.isUser) return const SizedBox.shrink();

    final colors = context.kaiColors;
    final typography = context.kaiTypography;
    final sourceCount = message.sources.length;

    return Padding(
      padding: const EdgeInsets.only(
        top: KaiSpacing.xxxs,
        left: KaiSpacing.screenPadding,
        right: KaiSpacing.screenPadding,
        bottom: KaiSpacing.xxs,
      ),
      child: Row(
        children: [
          if (sourceCount > 0) ...[
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
          const Spacer(),
          _ReactionButton(
            icon: Icons.thumb_up_outlined,
            onPressed: () => _showThanks(context),
          ),
          const SizedBox(width: 4),
          _ReactionButton(
            icon: Icons.thumb_down_outlined,
            onPressed: () => _showThanks(context),
          ),
        ],
      ),
    );
  }

  static String _sourcesLabel(int count) {
    if (count == 1) return 'источнике';
    return 'источниках';
  }

  static void _showThanks(BuildContext context) {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Спасибо за отзыв!'),
        duration: Duration(seconds: 2),
        behavior: SnackBarBehavior.floating,
      ),
    );
  }
}

class _ReactionButton extends StatelessWidget {
  final IconData icon;
  final VoidCallback onPressed;

  const _ReactionButton({required this.icon, required this.onPressed});

  @override
  Widget build(BuildContext context) {
    final colors = context.kaiColors;
    return GestureDetector(
      onTap: onPressed,
      child: Icon(icon, size: 14, color: colors.textTertiary),
    );
  }
}
