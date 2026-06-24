import 'package:flutter/material.dart';
import 'package:kai_app/design_system/theme/kai_theme.dart';
import 'package:kai_app/features/voice/presentation/providers/voice_state.dart';
import 'package:kai_app/features/voice/presentation/widgets/kai_karaoke_text.dart';
import 'package:kai_app/features/voice/presentation/widgets/kai_tide_large.dart';
import 'package:kai_app/features/voice/presentation/widgets/voice_close_button.dart';
import 'package:kai_app/features/voice/presentation/widgets/voice_control_hints.dart';
import 'package:kai_app/l10n/app_localizations.dart';

class VoiceLayoutContent extends StatelessWidget {
  const VoiceLayoutContent({
    required this.flowState,
    required this.karaokeWords,
    required this.karaokeIndex,
    required this.transcript,
    required this.responseText,
    required this.ttsFailed,
    required this.onGoToTranscript,
    this.errorMessage,
    super.key,
  });

  final VoiceFlowState flowState;
  final List<String> karaokeWords;
  final int karaokeIndex;
  final String transcript;
  final String responseText;
  final bool ttsFailed;
  final String? errorMessage;
  final VoidCallback onGoToTranscript;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final c = KaiTheme.of(context).colors;

    final largeTideState = switch (flowState) {
      VoiceFlowState.idle => KaiTideLargeState.idle,
      VoiceFlowState.listening => KaiTideLargeState.listening,
      VoiceFlowState.processing => KaiTideLargeState.listening,
      VoiceFlowState.speaking => KaiTideLargeState.speaking,
      VoiceFlowState.transcript => KaiTideLargeState.idle,
    };

    final isIdle = flowState == VoiceFlowState.idle;
    final isSpeaking = flowState == VoiceFlowState.speaking;
    final isListening = flowState == VoiceFlowState.listening;
    final isProcessing = flowState == VoiceFlowState.processing;
    final loc = AppLocalizations.of(context);

    String statusText() {
      if (errorMessage != null && errorMessage!.isNotEmpty) {
        return errorMessage!;
      }
      if (isProcessing) return loc.voiceStatusProcessing;
      if (isListening) return loc.voiceStatusListening;
      if (isSpeaking && ttsFailed) return loc.voiceTtsFailed;
      return loc.voiceStatusIdle;
    }

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
                          statusText(),
                          style: TextStyle(
                            fontFamily: 'Manrope',
                            fontSize: 16,
                            fontWeight: FontWeight.w500,
                            color: isDark
                                ? (isListening || isProcessing
                                    ? Colors.white
                                    : const Color(0x52FFFFFF))
                                : (isListening || isProcessing ? c.ink1 : c.ink4),
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
