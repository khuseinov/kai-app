import 'package:flutter/material.dart';

import '../../../../core/design/theme/theme_extensions.dart';
import '../../../../core/design/tokens/kai_spacing.dart';

class ChatInputBar extends StatelessWidget {
  final TextEditingController controller;
  final bool isLoading;
  final ValueChanged<String> onSend;

  const ChatInputBar({
    super.key,
    required this.controller,
    required this.isLoading,
    required this.onSend,
  });

  void _handleSubmit() {
    final text = controller.text.trim();
    if (text.isEmpty) return; // Allow sending even if isLoading is true
    onSend(text);
    controller.clear();
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.kaiColors;
    final typography = context.kaiTypography;

    return Container(
      margin: const EdgeInsets.all(KaiSpacing.m), // Island effect
      padding: const EdgeInsets.symmetric(
          horizontal: KaiSpacing.s, vertical: KaiSpacing.xs),
      decoration: BoxDecoration(
        color: colors.surfaceContainer,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: colors.cloudLight),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: SafeArea(
        top: false,
        bottom: false,
        child: Row(
          children: [
            // Text field
            Expanded(
              child: TextField(
                controller: controller,
                maxLines: 4,
                minLines: 1,
                textInputAction: TextInputAction.send,
                onSubmitted: (_) => _handleSubmit(),
                style: typography.bodyLarge.copyWith(
                  color: colors.textPrimary,
                ),
                decoration: InputDecoration(
                  hintText: 'Спросите Kai...',
                  hintStyle: typography.bodyLarge.copyWith(
                    color: colors.textTertiary,
                  ),
                  filled: false,
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: KaiSpacing.m,
                    vertical: KaiSpacing.m,
                  ),
                  border: InputBorder.none,
                  enabledBorder: InputBorder.none,
                  focusedBorder: InputBorder.none,
                ),
              ),
            ),
            const SizedBox(width: KaiSpacing.xs),
            // Send button
            ValueListenableBuilder<TextEditingValue>(
              valueListenable: controller,
              builder: (context, value, child) {
                final canSend = value.text.trim().isNotEmpty; // Allow sending while loading
                return Container(
                  margin: const EdgeInsets.all(4),
                  decoration: BoxDecoration(
                    color: canSend ? colors.primary : colors.surface,
                    shape: BoxShape.circle,
                  ),
                  child: IconButton(
                    onPressed: canSend ? _handleSubmit : null,
                    icon: Icon(
                      Icons.arrow_upward_rounded,
                      color: canSend ? colors.onPrimary : colors.textTertiary,
                    ),
                  ),
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}
