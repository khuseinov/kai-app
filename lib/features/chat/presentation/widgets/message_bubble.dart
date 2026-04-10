import 'package:flutter/material.dart';
import 'package:flutter_markdown/flutter_markdown.dart';

import '../../../../core/design/theme/theme_extensions.dart';
import '../../../../core/design/tokens/kai_colors.dart';
import '../../../../core/design/tokens/kai_radii.dart';
import '../../../../core/design/tokens/kai_spacing.dart';
import '../../../../core/models/chat_message.dart';

class MessageBubble extends StatelessWidget {
  final ChatMessage message;
  final VoidCallback? onRetry;

  const MessageBubble({
    super.key,
    required this.message,
    this.onRetry,
  });

  @override
  Widget build(BuildContext context) {
    final colors = context.kaiColors;
    final typography = context.kaiTypography;

    final isUser = message.isUser;

    return Align(
      alignment: isUser ? Alignment.centerRight : Alignment.centerLeft,
      child: Padding(
        padding: EdgeInsets.symmetric(
          horizontal: KaiSpacing.screenPadding,
          vertical: KaiSpacing.xxs,
        ),
        child: Column(
          crossAxisAlignment:
              isUser ? CrossAxisAlignment.end : CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            // Bubble
            GestureDetector(
              onTap: onRetry,
              child: ConstrainedBox(
                constraints: BoxConstraints(
                  maxWidth: MediaQuery.of(context).size.width * 0.75,
                ),
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: KaiSpacing.m,
                    vertical: KaiSpacing.s,
                  ),
                  decoration: BoxDecoration(
                    color: isUser ? colors.primary : colors.surfaceContainer,
                    borderRadius: _borderRadius(isUser),
                  ),
                  child: isUser
                      ? Text(
                          message.content,
                          style: typography.bodyLarge.copyWith(
                            color: colors.onPrimary,
                          ),
                        )
                      : MarkdownBody(
                          data: message.content,
                          styleSheet: MarkdownStyleSheet.fromTheme(
                            ThemeData(
                              textTheme: TextTheme(
                                bodyLarge: typography.bodyLarge.copyWith(
                                  color: colors.textPrimary,
                                ),
                                bodyMedium: typography.bodyMedium.copyWith(
                                  color: colors.textPrimary,
                                ),
                              ),
                            ),
                          ).copyWith(
                            p: typography.bodyLarge.copyWith(
                              color: colors.textPrimary,
                            ),
                          ),
                        ),
                ),
              ),
            ),
            // Timestamp row
            const SizedBox(height: KaiSpacing.xxxs),
            Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  _formatTime(message.timestamp),
                  style: typography.labelSmall.copyWith(
                    color: colors.textTertiary,
                  ),
                ),
                if (isUser) ...[
                  const SizedBox(width: KaiSpacing.xxxs),
                  _StatusIcon(
                    status: _inferStatus(message),
                    colors: colors,
                    onRetry: onRetry,
                  ),
                ],
              ],
            ),
          ],
        ),
      ),
    );
  }

  MessageBubbleStatus _inferStatus(ChatMessage msg) {
    switch (msg.status) {
      case 'sending':
        return MessageBubbleStatus.sending;
      case 'failed':
        return MessageBubbleStatus.failed;
      default:
        return MessageBubbleStatus.sent;
    }
  }

  BorderRadius _borderRadius(bool isUser) {
    if (isUser) {
      return const BorderRadius.only(
        topLeft: Radius.circular(KaiRadii.lRaw),
        topRight: Radius.circular(KaiRadii.lRaw),
        bottomLeft: Radius.circular(KaiRadii.lRaw),
        bottomRight: Radius.circular(KaiSpacing.xxs),
      );
    }
    return const BorderRadius.only(
      topLeft: Radius.circular(KaiRadii.lRaw),
      topRight: Radius.circular(KaiRadii.lRaw),
      bottomLeft: Radius.circular(KaiSpacing.xxs),
      bottomRight: Radius.circular(KaiRadii.lRaw),
    );
  }

  String _formatTime(DateTime dt) {
    final h = dt.hour.toString().padLeft(2, '0');
    final m = dt.minute.toString().padLeft(2, '0');
    return '$h:$m';
  }
}

enum MessageBubbleStatus { sending, sent, failed }

class _StatusIcon extends StatelessWidget {
  final MessageBubbleStatus status;
  final KaiColors colors;
  final VoidCallback? onRetry;

  const _StatusIcon({
    required this.status,
    required this.colors,
    this.onRetry,
  });

  @override
  Widget build(BuildContext context) {
    switch (status) {
      case MessageBubbleStatus.sending:
        return SizedBox(
          width: 12,
          height: 12,
          child: CircularProgressIndicator(
            strokeWidth: 1.5,
            color: colors.stateThinking,
          ),
        );
      case MessageBubbleStatus.sent:
        return Icon(Icons.check, size: 12, color: colors.success);
      case MessageBubbleStatus.failed:
        return GestureDetector(
          onTap: onRetry,
          child: Icon(Icons.error_outline, size: 12, color: colors.error),
        );
    }
  }
}
