import 'package:flutter/material.dart';

import '../../../../core/design/theme/theme_extensions.dart';
import '../../../../core/design/tokens/kai_radii.dart';
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
    if (text.isEmpty || isLoading) return;
    onSend(text);
    controller.clear();
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.kaiColors;
    final typography = context.kaiTypography;

    return Container(
      padding: const EdgeInsets.all(KaiSpacing.s),
      decoration: BoxDecoration(
        color: colors.surfaceContainer,
        borderRadius: BorderRadius.vertical(top: Radius.circular(KaiRadii.xlRaw)),
      ),
      child: SafeArea(
        top: false,
        child: Row(
          children: [
            // Text field
            Expanded(
              child: TextField(
                controller: controller,
                maxLines: 1,
                textInputAction: TextInputAction.send,
                onSubmitted: (_) => _handleSubmit(),
                style: typography.bodyLarge.copyWith(
                  color: colors.textPrimary,
                ),
                decoration: InputDecoration(
                  hintText: '\u0421\u043F\u0440\u043E\u0441\u0438\u0442\u0435 KAI \u043E \u043F\u0443\u0442\u0435\u0448\u0435\u0441\u0442\u0432\u0438\u044F\u0445...',
                  hintStyle: typography.bodyLarge.copyWith(
                    color: colors.textTertiary,
                  ),
                  filled: true,
                  fillColor: colors.surface,
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: KaiSpacing.m,
                    vertical: KaiSpacing.s,
                  ),
                  border: OutlineInputBorder(
                    borderRadius: KaiRadii.xl,
                    borderSide: BorderSide.none,
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: KaiRadii.xl,
                    borderSide: BorderSide.none,
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: KaiRadii.xl,
                    borderSide: BorderSide(color: colors.primary, width: 1.5),
                  ),
                ),
              ),
            ),
            const SizedBox(width: KaiSpacing.xs),
            // Send button
            ValueListenableBuilder<TextEditingValue>(
              valueListenable: controller,
              builder: (context, value, child) {
                final canSend = value.text.trim().isNotEmpty && !isLoading;
                return IconButton(
                  onPressed: canSend ? _handleSubmit : null,
                  icon: Icon(
                    Icons.send,
                    color: canSend ? colors.primary : colors.textTertiary,
                  ),
                  style: IconButton.styleFrom(
                    backgroundColor: canSend
                        ? colors.surfaceContainer
                        : Colors.transparent,
                    padding: const EdgeInsets.all(KaiSpacing.s),
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
