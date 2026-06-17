import 'dart:async';

import 'package:kai_app/features/voice/presentation/providers/voice_state.dart';
import 'package:kai_app/features/voice/presentation/widgets/kai_transcript_view.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'voice_notifier.g.dart';

@riverpod
class VoiceNotifier extends _$VoiceNotifier {
  Timer? _karaokeTimer;
  Timer? _idleTransitionTimer;

  @override
  VoiceStateData build() {
    ref.onDispose(_cancelTimers);

    return const VoiceStateData(
      transcriptEvents: [
        KaiTranscriptEvent(
          who: 'you',
          text: 'Как быстрее всего добраться до Токио из Киото?',
          timestamp: '12:30',
        ),
        KaiTranscriptEvent(
          who: 'kai',
          text: 'Синкансэн — быстрее всего, займет около 2 часов 15 минут.',
          timestamp: '12:30',
        ),
        KaiTranscriptEvent(
          who: 'you',
          text: 'Сколько стоит билет?',
          timestamp: '12:33',
        ),
        KaiTranscriptEvent(
          who: 'kai',
          text: 'JR Pass на 7 дней покроет эту поездку, либо отдельный билет в одну сторону обойдется примерно в ¥14,000.',
          timestamp: '12:34',
        ),
      ],
    );
  }

  void _cancelTimers() {
    _karaokeTimer?.cancel();
    _karaokeTimer = null;
    _idleTransitionTimer?.cancel();
    _idleTransitionTimer = null;
  }

  void handleTap() {
    final currentFlow = state.flowState;
    if (currentFlow == VoiceFlowState.idle) {
      state = state.copyWith(flowState: VoiceFlowState.listening);
    } else if (currentFlow == VoiceFlowState.listening) {
      _startSpeakingSimulation();
    } else if (currentFlow == VoiceFlowState.speaking) {
      _cancelTimers();
      state = state.copyWith(flowState: VoiceFlowState.idle);
    }
  }

  void _startSpeakingSimulation() {
    _cancelTimers();
    state = state.copyWith(
      flowState: VoiceFlowState.speaking,
      karaokeIndex: 0,
    );

    _karaokeTimer = Timer.periodic(const Duration(milliseconds: 600), (timer) {
      final idx = state.karaokeIndex;
      final words = state.karaokeWords;
      if (idx < words.length - 1) {
        state = state.copyWith(karaokeIndex: idx + 1);
      } else {
        _karaokeTimer?.cancel();
        _karaokeTimer = null;

        // Auto-return to idle after speaking finishes
        _idleTransitionTimer = Timer(const Duration(milliseconds: 1500), () {
          if (state.flowState == VoiceFlowState.speaking) {
            state = state.copyWith(flowState: VoiceFlowState.idle);
          }
        });
      }
    });
  }

  void goToTranscript() {
    if (state.flowState != VoiceFlowState.transcript) {
      state = state.copyWith(
        previousState: state.flowState,
        flowState: VoiceFlowState.transcript,
      );
    }
  }

  void returnFromTranscript() {
    if (state.flowState == VoiceFlowState.transcript) {
      state = state.copyWith(flowState: state.previousState);
      if (state.flowState == VoiceFlowState.speaking) {
        _startSpeakingSimulation();
      }
    }
  }
}
