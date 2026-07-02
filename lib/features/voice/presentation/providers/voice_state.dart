import 'package:kai_app/features/voice/presentation/widgets/kai_transcript_view.dart';

enum VoiceFlowState {
  idle,
  listening,
  thinking,
  speaking,
  transcript,
}

/// Typed voice-session errors — mapped to localized text at the widget layer
/// (the notifier has no BuildContext for AppLocalizations).
enum VoiceError {
  noGateway,
  micPermission,
  connection,
  micStream,
  startFailed,
  sttFailed,
  pipelineFailed,
  connectionLost,
  authFailed,
}

const _unsetError = Object();

class VoiceStateData {
  const VoiceStateData({
    this.flowState = VoiceFlowState.idle,
    this.previousState = VoiceFlowState.idle,
    this.karaokeIndex = 0,
    this.karaokeWords = const [],
    this.transcriptEvents = const [],
    this.lastTranscript = '',
    this.lastResponseText = '',
    this.error,
    this.reconnecting = false,
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
  final VoiceError? error;

  /// True while an unexpected disconnect is being retried automatically.
  final bool reconnecting;

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
    // Sentinel default so `error: null` actually CLEARS the error — the
    // plain `?? this.error` pattern made errors sticky forever.
    Object? error = _unsetError,
    bool? reconnecting,
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
      error: identical(error, _unsetError) ? this.error : error as VoiceError?,
      reconnecting: reconnecting ?? this.reconnecting,
      amplitude: amplitude ?? this.amplitude,
      debug: debug ?? this.debug,
    );
  }
}
