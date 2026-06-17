import 'package:kai_app/features/voice/presentation/widgets/kai_transcript_view.dart';

enum VoiceFlowState {
  idle,
  listening,
  speaking,
  transcript,
}

class VoiceStateData {
  const VoiceStateData({
    this.flowState = VoiceFlowState.idle,
    this.previousState = VoiceFlowState.idle,
    this.karaokeIndex = 0,
    this.karaokeWords = const [
      'Синкансэн',
      '—',
      'быстрее',
      'всего',
      'добраться',
      'за',
      '¥14,000.',
    ],
    this.transcriptEvents = const [],
  });

  final VoiceFlowState flowState;
  final VoiceFlowState previousState;
  final int karaokeIndex;
  final List<String> karaokeWords;
  final List<KaiTranscriptEvent> transcriptEvents;

  VoiceStateData copyWith({
    VoiceFlowState? flowState,
    VoiceFlowState? previousState,
    int? karaokeIndex,
    List<String>? karaokeWords,
    List<KaiTranscriptEvent>? transcriptEvents,
  }) {
    return VoiceStateData(
      flowState: flowState ?? this.flowState,
      previousState: previousState ?? this.previousState,
      karaokeIndex: karaokeIndex ?? this.karaokeIndex,
      karaokeWords: karaokeWords ?? this.karaokeWords,
      transcriptEvents: transcriptEvents ?? this.transcriptEvents,
    );
  }
}
