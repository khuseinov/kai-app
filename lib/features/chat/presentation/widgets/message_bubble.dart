import 'package:flutter/material.dart';
import 'package:flutter_markdown/flutter_markdown.dart';
import '../../../../core/design/theme/theme_extensions.dart';
import '../../../../core/design/tokens/kai_spacing.dart';
import '../../../../core/models/chat_message.dart';

class MessageBubble extends StatelessWidget {
  final ChatMessage message;

  const MessageBubble({
    super.key,
    required this.message,
  });

  @override
  Widget build(BuildContext context) {
    final colors = context.kaiColors;
    final typography = context.kaiTypography;
    final isUser = message.isUser;

    // Cache styles to avoid recreation during build
    final bodyStyle = typography.bodyLarge.copyWith(
      color: colors.textPrimary,
      height: 1.5,
    );
    final labelStyle = typography.labelMedium.copyWith(
      color: isUser ? colors.textTertiary : colors.primary,
      fontWeight: FontWeight.bold,
      letterSpacing: 1.2,
    );

    if (isUser) {
      return Padding(
        padding: const EdgeInsets.only(bottom: KaiSpacing.m, left: KaiSpacing.xxl),
        child: Align(
          alignment: Alignment.centerRight,
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
            child: Text(
              message.content,
              style: typography.bodyLarge.copyWith(color: colors.textPrimary),
            ),
          ),
        ),
      );
    } else {
      return Padding(
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
                    selectable: true,
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
      );
    }
  }
}
