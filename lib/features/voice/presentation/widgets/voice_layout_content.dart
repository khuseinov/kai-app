import 'package:flutter/material.dart';
import 'package:kai_app/design_system/theme/kai_theme.dart';
import 'package:kai_app/features/voice/presentation/providers/voice_state.dart';
import 'package:kai_app/features/voice/presentation/widgets/kai_karaoke_text.dart';
import 'package:kai_app/features/voice/presentation/widgets/kai_tide_large.dart';
import 'package:kai_app/features/voice/presentation/widgets/voice_close_button.dart';
import 'package:kai_app/features/voice/presentation/widgets/voice_control_hints.dart';

class VoiceLayoutContent extends StatelessWidget {
  const VoiceLayoutContent({
    required this.flowState,
    required this.karaokeWords,
    required this.karaokeIndex,
    required this.onGoToTranscript,
    super.key,
  });

  final VoiceFlowState flowState;
  final List<String> karaokeWords;
  final int karaokeIndex;
  final VoidCallback onGoToTranscript;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final c = KaiTheme.of(context).colors;

    final largeTideState = switch (flowState) {
      VoiceFlowState.idle => KaiTideLargeState.idle,
      VoiceFlowState.listening => KaiTideLargeState.listening,
      VoiceFlowState.speaking => KaiTideLargeState.speaking,
      VoiceFlowState.transcript => KaiTideLargeState.idle,
    };

    final isIdle = flowState == VoiceFlowState.idle;
    final isSpeaking = flowState == VoiceFlowState.speaking;
    final isListening = flowState == VoiceFlowState.listening;

    return Stack(
      key: const ValueKey<String>('voice_layout'),
      children: [
        const VoiceCloseButton(),
        VoiceControlHints(
          visible: isIdle,
          onTapTranscript: onGoToTranscript,
        ),
        Center(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                KaiTideLarge(state: largeTideState),
                const SizedBox(height: 28),
                Container(
                  height: 48,
                  alignment: Alignment.center,
                  child: isSpeaking
                      ? KaiKaraokeText(
                          words: karaokeWords,
                          currentIndex: karaokeIndex,
                        )
                      : Text(
                          isListening ? 'Говорите…' : 'Kai ожидает',
                          style: TextStyle(
                            fontFamily: 'Manrope',
                            fontSize: 16,
                            fontWeight: FontWeight.w500,
                            color: isDark
                                ? (isListening ? Colors.white : const Color(0x52FFFFFF))
                                : (isListening ? c.ink1 : c.ink4),
                            letterSpacing: 16 * -0.01,
                          ),
                        ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}
