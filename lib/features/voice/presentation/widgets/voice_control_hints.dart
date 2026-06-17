import 'package:flutter/material.dart';

class VoiceControlHints extends StatelessWidget {
  const VoiceControlHints({
    required this.visible,
    required this.onTapTranscript,
    super.key,
  });

  final bool visible;
  final VoidCallback onTapTranscript;

  @override
  Widget build(BuildContext context) {
    if (!visible) return const SizedBox.shrink();

    return Stack(
      children: [
        const Positioned(
          top: 12,
          left: 54,
          child: Text(
            'нажмите, чтобы говорить',
            style: TextStyle(
              fontFamily: 'JetBrainsMono',
              fontSize: 9,
              color: Color(0x40FFFFFF),
              letterSpacing: 0.12,
            ),
          ),
        ),
        Positioned(
          top: 12,
          right: 18,
          child: GestureDetector(
            onTap: onTapTranscript,
            child: const Text(
              'SWIPE ↑ · ТРАНСКРИПЦИЯ',
              style: TextStyle(
                fontFamily: 'JetBrainsMono',
                fontSize: 9,
                color: Color(0x40FFFFFF),
                letterSpacing: 0.12,
              ),
            ),
          ),
        ),
      ],
    );
  }
}
