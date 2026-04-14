import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_markdown/flutter_markdown.dart';
import '../../../../core/design/theme/theme_extensions.dart';
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

    void copyToClipboard() {
      Clipboard.setData(ClipboardData(text: message.content));
      HapticFeedback.mediumImpact();
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Скопировано'),
          duration: Duration(seconds: 1),
          behavior: SnackBarBehavior.floating,
        ),
      );
    }

    void showMessageActions(Offset globalPosition) {
      HapticFeedback.mediumImpact();
      final rect = RelativeRect.fromLTRB(
        globalPosition.dx,
        globalPosition.dy,
        globalPosition.dx,
        globalPosition.dy,
      );
      showMenu<_MessageAction>(
        context: context,
        position: rect,
        color: colors.surface,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        items: [
          PopupMenuItem(
            value: _MessageAction.copy,
            child: Row(
              children: [
                Icon(Icons.copy_rounded, size: 18, color: colors.textSecondary),
                const SizedBox(width: 10),
                Text('Копировать',
                    style: typography.bodyLarge.copyWith(color: colors.textPrimary)),
              ],
            ),
          ),
          if (isUser && onRetry != null)
            PopupMenuItem(
              value: _MessageAction.retry,
              child: Row(
                children: [
                  Icon(Icons.refresh_rounded, size: 18, color: colors.textSecondary),
                  const SizedBox(width: 10),
                  Text('Повторить',
                      style: typography.bodyLarge.copyWith(color: colors.textPrimary)),
                ],
              ),
            ),
        ],
      ).then((action) {
        if (action == _MessageAction.copy) copyToClipboard();
        if (action == _MessageAction.retry) onRetry?.call();
      });
    }

    if (isUser) {
      return Padding(
        padding: const EdgeInsets.only(bottom: KaiSpacing.m, left: KaiSpacing.xxl),
        child: Align(
          alignment: Alignment.centerRight,
          child: GestureDetector(
            onLongPressStart: (d) => showMessageActions(d.globalPosition),
            child: Container(
              padding: const EdgeInsets.symmetric(
                horizontal: KaiSpacing.m,
                vertical: KaiSpacing.s,
              ),
              decoration: BoxDecoration(
                color: colors.surfaceContainer,
                borderRadius: BorderRadius.circular(20).copyWith(
                  bottomRight: const Radius.circular(4),
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    message.content,
                    style: typography.bodyLarge.copyWith(color: colors.textPrimary),
                  ),
                  const SizedBox(height: 2),
                  _StatusIcon(status: message.status),
                ],
              ),
            ),
          ),
        ),
      );
    } else {
      return GestureDetector(
        onLongPressStart: (d) => showMessageActions(d.globalPosition),
        child: Padding(
        padding: const EdgeInsets.only(bottom: KaiSpacing.l, right: KaiSpacing.l),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Minimal AI Avatar
            Container(
              margin: const EdgeInsets.only(right: KaiSpacing.s, top: 4),
              padding: const EdgeInsets.all(4),
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: LinearGradient(
                  colors: [
                    colors.oceanPrimary,
                    colors.stateThinking,
                  ],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
              ),
              child: Icon(
                Icons.insights,
                size: 14,
                color: colors.onPrimary,
              ),
            ),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Kai',
                    style: typography.labelMedium.copyWith(
                      color: colors.textSecondary,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 4),
                  MarkdownBody(
                    data: message.content,
                    selectable: !kIsWeb,
                    styleSheet: MarkdownStyleSheet(
                      p: typography.bodyLarge.copyWith(
                        color: colors.textPrimary,
                        height: 1.5,
                      ),
                      h1: typography.headlineLarge.copyWith(color: colors.textPrimary),
                      h2: typography.headlineMedium.copyWith(color: colors.textPrimary),
                      h3: typography.headlineSmall.copyWith(color: colors.textPrimary),
                      code: typography.bodyMedium.copyWith(
                        backgroundColor: colors.surfaceContainer,
                        color: colors.oceanPrimary,
                        fontFamily: 'monospace',
                      ),
                      codeblockDecoration: BoxDecoration(
                        color: colors.surfaceContainer,
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
      );
    }
  }
}

enum _MessageAction { copy, retry }

class _StatusIcon extends StatelessWidget {
  final String status;
  const _StatusIcon({required this.status});

  @override
  Widget build(BuildContext context) {
    final colors = context.kaiColors;

    final (icon, color) = switch (status) {
      'queued'  => (Icons.schedule_rounded,       colors.textTertiary),
      'sending' => (Icons.radio_button_unchecked, colors.textTertiary),
      'failed'  => (Icons.error_outline_rounded,  colors.error),
      _         => (Icons.done_rounded,           colors.textTertiary),
    };

    return Icon(icon, size: 12, color: color);
  }
}
