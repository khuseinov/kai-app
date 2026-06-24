import 'dart:async';
import 'dart:io';
import 'dart:typed_data';

import 'package:kai_app/core/providers/root.dart';
import 'package:kai_app/features/room/presentation/providers/room_state.dart';
import 'package:kai_app/features/voice/domain/repositories/voice_repository.dart';
import 'package:kai_app/features/voice/domain/services/audio_player_service.dart';
import 'package:kai_app/features/voice/domain/services/audio_recorder_service.dart';
import 'package:kai_app/features/voice/presentation/providers/voice_state.dart';
import 'package:kai_app/features/voice/presentation/widgets/kai_transcript_view.dart';
import 'package:path_provider/path_provider.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'voice_notifier.g.dart';

@riverpod
class VoiceNotifier extends _$VoiceNotifier {
  late final AudioRecorderService _recorder;
  late final AudioPlayerService _player;
  late final VoiceRepository _voiceRepository;
  late final String _sessionId;
  late final String _userId;

  String? _recordingPath;
  bool _isDisposed = false;

  @override
  VoiceStateData build() {
    _recorder = ref.read(audioRecorderServiceProvider);
    _player = ref.read(audioPlayerServiceProvider);
    _voiceRepository = ref.read(voiceRepositoryProvider);
    _sessionId =
        ref.read(roomNotifierProvider).activeSessionId ?? 'default-session';
    _userId = ref.read(userIdProvider);

    ref.onDispose(() {
      _isDisposed = true;
      _player.stop();
    });
    return const VoiceStateData();
  }

  Future<String> _ensureRecordingPath() async {
    try {
      final tempDir = await getTemporaryDirectory();
      return '${tempDir.path}/kai_voice_recording.wav';
    } on Exception {
      // Fallback for environments where path_provider is unavailable (e.g. unit tests).
      return '${Directory.systemTemp.path}/kai_voice_recording.wav';
    }
  }

  Future<void> handleTapDown() async {
    if (state.flowState != VoiceFlowState.idle) return;
    state = state.copyWith(flowState: VoiceFlowState.listening);

    try {
      final path = await _ensureRecordingPath();
      _recordingPath = path;
      await _recorder.start(path);
    } on Exception catch (e) {
      _setError('Failed to start recording: $e');
    }
  }

  Future<void> handleTapUp() async {
    if (state.flowState != VoiceFlowState.listening) return;
    state = state.copyWith(flowState: VoiceFlowState.processing);

    try {
      final path = await _recorder.stop();
      final recordingPath = path ?? _recordingPath;
      _recordingPath = null;

      if (recordingPath == null || !File(recordingPath).existsSync()) {
        _setError('No recording captured');
        return;
      }

      await _sendVoiceChat(File(recordingPath));
    } on Exception catch (e) {
      _setError('Failed to process recording: $e');
    }
  }

  Future<void> _sendVoiceChat(File audio) async {
    try {
      final response = await _voiceRepository.sendVoiceChat(
        audio,
        _sessionId,
        _userId,
        'en',
      );

      if (_isDisposed) return;

      final now = _formatTime(DateTime.now());
      final updatedEvents = [
        ...state.transcriptEvents,
        KaiTranscriptEvent(
          who: 'you',
          text: response.transcript,
          timestamp: now,
        ),
        KaiTranscriptEvent(
          who: 'kai',
          text: response.responseText,
          timestamp: now,
        ),
      ];

      final words = response.responseText.trim().isEmpty
          ? <String>[]
          : response.responseText.trim().split(RegExp(r'\s+'));

      state = state.copyWith(
        flowState: VoiceFlowState.speaking,
        transcriptEvents: updatedEvents,
        lastTranscript: response.transcript,
        lastResponseText: response.responseText,
        ttsFailed: response.ttsFailed,
        karaokeWords: words,
        karaokeIndex: 0,
      );

      if (!response.ttsFailed && response.audio.isNotEmpty) {
        unawaited(_playAudio(response.audio));
      } else {
        await Future<void>.delayed(const Duration(seconds: 2));
        if (!_isDisposed && state.flowState == VoiceFlowState.speaking) {
          state = state.copyWith(flowState: VoiceFlowState.idle);
        }
      }
    } on Exception catch (e) {
      _setError('Voice chat failed: $e');
    }
  }

  Future<void> _playAudio(Uint8List audio) async {
    try {
      await _player.playBytes(audio);
      if (!_isDisposed) {
        state = state.copyWith(flowState: VoiceFlowState.idle);
      }
    } on Exception catch (e) {
      _setError('Audio playback failed: $e');
    }
  }

  void stopSpeaking() {
    if (state.flowState == VoiceFlowState.speaking) {
      unawaited(_player.stop());
      state = state.copyWith(flowState: VoiceFlowState.idle);
    }
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
    }
  }

  void _setError(String message) {
    state = state.copyWith(
      flowState: VoiceFlowState.idle,
      errorMessage: message,
    );
  }

  String _formatTime(DateTime dt) {
    final hour = dt.hour.toString().padLeft(2, '0');
    final minute = dt.minute.toString().padLeft(2, '0');
    return '$hour:$minute';
  }
}
