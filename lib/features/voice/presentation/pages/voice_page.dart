import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:go_router/go_router.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

import 'package:kai_app/features/voice/presentation/providers/voice_notifier.dart';
import 'package:kai_app/features/voice/presentation/providers/voice_state.dart';
import 'package:kai_app/features/voice/presentation/widgets/voice_home_indicator.dart';
import 'package:kai_app/features/voice/presentation/widgets/voice_layout_content.dart';
import 'package:kai_app/features/voice/presentation/widgets/voice_transcript_sheet.dart';

class VoicePage extends HookConsumerWidget {
  const VoicePage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final voiceBg = isDark ? const Color(0xFF08080A) : const Color(0xFFFAFAF9);
    final state = ref.watch(voiceNotifierProvider);
    final notifier = ref.read(voiceNotifierProvider.notifier);

    // Animation Controller Hook (handled automatically)
    final transcriptController = useAnimationController(
      duration: const Duration(milliseconds: 350),
    );

    final transcriptOffset = useMemoized(() {
      return Tween<Offset>(
        begin: const Offset(0, -1),
        end: Offset.zero,
      ).animate(CurvedAnimation(
        parent: transcriptController,
        curve: Curves.easeOutCubic,
        reverseCurve: Curves.easeInCubic,
      ),);
    }, [transcriptController],);

    final dragDeltaY = useRef<double>(0);

    // Sync state changes with the animation controller
    ref.listen<VoiceFlowState>(
      voiceNotifierProvider.select((s) => s.flowState),
      (prev, next) {
        if (next == VoiceFlowState.transcript) {
          transcriptController.forward();
        } else if (prev == VoiceFlowState.transcript) {
          transcriptController.reverse();
        }
      },
    );

    void handleVerticalDrag(DragEndDetails details) {
      final velocity = details.primaryVelocity ?? 0;
      if (velocity < -200 || dragDeltaY.value < -100) {
        if (state.flowState != VoiceFlowState.transcript) {
          notifier.goToTranscript();
        }
      } else if (velocity > 200 || dragDeltaY.value > 100) {
        if (state.flowState == VoiceFlowState.transcript) {
          notifier.returnFromTranscript();
        } else {
          context.go('/room');
        }
      }
    }

    return Scaffold(
      backgroundColor: voiceBg,
      body: SafeArea(
        child: GestureDetector(
          onVerticalDragStart: (_) => dragDeltaY.value = 0,
          onVerticalDragUpdate: (details) => dragDeltaY.value += details.delta.dy,
          onVerticalDragEnd: handleVerticalDrag,
          onTapDown: state.flowState == VoiceFlowState.transcript
              ? null
              : (_) => notifier.handleTapDown(),
          onTapUp: state.flowState == VoiceFlowState.transcript
              ? null
              : (_) {
                  final lang = Localizations.localeOf(context).languageCode;
                  notifier.handleTapUp(lang);
                },
          onTapCancel: state.flowState == VoiceFlowState.transcript
              ? null
              : () {
                  final lang = Localizations.localeOf(context).languageCode;
                  notifier.handleTapUp(lang);
                },
          behavior: HitTestBehavior.opaque,
          child: Stack(
            children: [
              // Main Layout Layer
              VoiceLayoutContent(
                flowState: state.flowState,
                karaokeWords: state.karaokeWords,
                karaokeIndex: state.karaokeIndex,
                transcript: state.lastTranscript,
                responseText: state.lastResponseText,
                ttsFailed: state.ttsFailed,
                errorMessage: state.errorMessage,
                onGoToTranscript: notifier.goToTranscript,
                amplitude: state.amplitude,
              ),

              // Transcript Slide Transition Cover Layer
              Positioned.fill(
                child: SlideTransition(
                  position: transcriptOffset,
                  child: ColoredBox(
                    color: voiceBg,
                    child: VoiceTranscriptSheet(
                      events: state.transcriptEvents,
                      onReturn: notifier.returnFromTranscript,
                    ),
                  ),
                ),
              ),

              // Top and Bottom overlays
              const VoiceHomeIndicator(),
            ],
          ),
        ),
      ),
    );
  }
}
