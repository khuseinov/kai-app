import 'package:flutter/material.dart';
import '../../../../core/design/theme/theme_extensions.dart';
import '../../../../core/design/components/kai_gemini_wave.dart';

class ChatEmptyState extends StatelessWidget {
  final ValueChanged<String> onPromptTapped;
  final KaiVoiceState voiceState;

  const ChatEmptyState({
    super.key,
    required this.onPromptTapped,
    required this.voiceState,
  });

  @override
  Widget build(BuildContext context) {
    final colors = context.kaiColors;
    final typography = context.kaiTypography;

    String displayText;
    switch (voiceState) {
      case KaiVoiceState.idle:
        displayText = 'Как я могу\nпомочь вам?';
        break;
      case KaiVoiceState.listening:
        displayText = 'Слушаю вас...';
        break;
      case KaiVoiceState.thinking:
        displayText = 'Анализирую...';
        break;
      case KaiVoiceState.speaking:
        displayText = '...';
        break;
    }

    return Center(
      child: AnimatedSwitcher(
        duration: const Duration(milliseconds: 300),
        child: Text(
          displayText,
          key: ValueKey<String>(displayText),
          textAlign: TextAlign.center,
          style: typography.displaySmall.copyWith(color: colors.textSecondary),
        ),
      ),
    );
  }
}
