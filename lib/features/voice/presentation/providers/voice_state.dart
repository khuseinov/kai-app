import 'package:kai_app/features/voice/presentation/widgets/kai_transcript_view.dart';

enum VoiceFlowState {
  idle,
  listening,
  processing,
  transcribing,
  thinking,
  synthesizing,
  speaking,
  transcript,
}

class VoiceStateData {
  const VoiceStateData({
    this.flowState = VoiceFlowState.idle,
    this.previousState = VoiceFlowState.idle,
    this.karaokeIndex = 0,
    this.karaokeWords = const [],
    this.transcriptEvents = const [],
    this.lastTranscript = '',
    this.lastResponseText = '',
    this.ttsFailed = false,
    this.errorMessage,
  });

  final VoiceFlowState flowState;
  final VoiceFlowState previousState;
  final int karaokeIndex;
  final List<String> karaokeWords;
  final List<KaiTranscriptEvent> transcriptEvents;
  final String lastTranscript;
  final String lastResponseText;
  final bool ttsFailed;
  final String? errorMessage;

  VoiceStateData copyWith({
    VoiceFlowState? flowState,
    VoiceFlowState? previousState,
    int? karaokeIndex,
    List<String>? karaokeWords,
    List<KaiTranscriptEvent>? transcriptEvents,
    String? lastTranscript,
    String? lastResponseText,
    bool? ttsFailed,
    String? errorMessage,
  }) {
    return VoiceStateData(
      flowState: flowState ?? this.flowState,
      previousState: previousState ?? this.previousState,
      karaokeIndex: karaokeIndex ?? this.karaokeIndex,
      karaokeWords: karaokeWords ?? this.karaokeWords,
      transcriptEvents: transcriptEvents ?? this.transcriptEvents,
      lastTranscript: lastTranscript ?? this.lastTranscript,
      lastResponseText: lastResponseText ?? this.lastResponseText,
      ttsFailed: ttsFailed ?? this.ttsFailed,
      errorMessage: errorMessage ?? this.errorMessage,
    );
  }
}
