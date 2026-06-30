import 'package:kai_app/features/voice/presentation/widgets/kai_transcript_view.dart';

enum VoiceFlowState {
  idle,
  listening,
  processing, // kept for legacy layout_content compat
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
    this.amplitude = 0.0,
    this.debug = '',
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

  /// Normalised mic/playback amplitude 0..1 for KaiTideLarge animation.
  final double amplitude;

  /// On-screen debug line (chunks sent, last WS event, audio bytes) — visible
  /// without Xcode so voice can be diagnosed on a sideloaded build.
  final String debug;

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
    double? amplitude,
    String? debug,
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
      amplitude: amplitude ?? this.amplitude,
      debug: debug ?? this.debug,
    );
  }
}
