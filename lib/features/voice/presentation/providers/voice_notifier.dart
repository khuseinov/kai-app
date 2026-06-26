import 'dart:async';
import 'dart:io';
import 'dart:typed_data';

import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:kai_app/core/logger/app_logger.dart';
import 'package:kai_app/core/network/interceptors/error_interceptor.dart';
import 'package:kai_app/core/providers/root.dart';
import 'package:kai_app/features/room/presentation/providers/room_state.dart';
import 'package:kai_app/features/voice/data/models/voice_chat_job_status.dart';
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
    if (kIsWeb) {
      return '';
    }
    try {
      final tempDir = await getTemporaryDirectory();
      return '${tempDir.path}/kai_voice_recording.wav';
    } catch (_) {
      // Fallback for environments where path_provider is unavailable (e.g. unit tests).
      try {
        return '${Directory.systemTemp.path}/kai_voice_recording.wav';
      } catch (_) {
        return '';
      }
    }
  }

  Future<void> handleTapDown() async {
    if (state.flowState != VoiceFlowState.idle) return;
    state = state.copyWith(flowState: VoiceFlowState.listening);

    try {
      final path = await _ensureRecordingPath();
      _recordingPath = path;
      await _recorder.start(path);
    } catch (e, st) {
      AppLogger.e('Failed to start recording', e, st);
      _setError('Failed to start recording: $e');
    }
  }

  Future<void> handleTapUp([String language = 'en']) async {
    if (state.flowState != VoiceFlowState.listening) return;
    state = state.copyWith(flowState: VoiceFlowState.processing);

    try {
      final path = await _recorder.stop();
      final recordingPath = path ?? _recordingPath;
      _recordingPath = null;

      if (recordingPath == null || recordingPath.isEmpty) {
        _setError('No recording captured');
        return;
      }

      if (!kIsWeb && !File(recordingPath).existsSync()) {
        _setError('No recording captured');
        return;
      }

      await _sendVoiceChat(recordingPath, language);
    } catch (e, st) {
      AppLogger.e('Failed to process recording', e, st);
      _setError('Failed to process recording: $e');
    }
  }

  Future<void> _sendVoiceChat(String audioPath, String language) async {
    final env = ref.read(envProvider);
    if ((env.voiceGatewayBaseUrl == null || env.voiceGatewayBaseUrl!.isEmpty) &&
        env.apiBaseUrl.isEmpty) {
      _setError(
        'Voice gateway URL is not configured. Please check your .env file.',
      );
      return;
    }

    try {
      final job = await _voiceRepository.sendVoiceChat(
        audioPath,
        _sessionId,
        _userId,
        language,
      );

      if (_isDisposed) return;

      state = state.copyWith(flowState: VoiceFlowState.transcribing);
      final result = await _pollVoiceChatJob(job.jobId);
      if (_isDisposed || result == null) return;

      await _handleJobResult(result);
    } on DioException catch (e, st) {
      AppLogger.e('Voice chat failed', e, st);
      final message = _humanReadableError(e);
      _setError(message);
    } catch (e, st) {
      AppLogger.e('Voice chat failed', e, st);
      _setError('Voice chat failed: $e');
    }
  }

  Future<VoiceChatJobStatus?> _pollVoiceChatJob(String jobId) async {
    const maxAttempts = 90;
    const interval = Duration(seconds: 2);

    for (var attempt = 0; attempt < maxAttempts; attempt++) {
      if (_isDisposed) return null;

      try {
        final job = await _voiceRepository.getVoiceChatJob(jobId);
        _applyJobStatus(job.status);

        if (job.status == VoiceJobStatus.completed ||
            job.status == VoiceJobStatus.failed) {
          return job;
        }
      } on DioException catch (e, st) {
        AppLogger.e('Voice job poll failed', e, st);
        // Retry on transient errors; if the failure persists we will time out.
      }

      await Future.delayed(interval);
      if (_isDisposed) return null;
    }

    _setError('Голосовой чат занял слишком много времени');
    return null;
  }

  void _applyJobStatus(VoiceJobStatus status) {
    if (_isDisposed) return;
    final flowState = switch (status) {
      VoiceJobStatus.pending => VoiceFlowState.processing,
      VoiceJobStatus.transcribing => VoiceFlowState.transcribing,
      VoiceJobStatus.thinking => VoiceFlowState.thinking,
      VoiceJobStatus.synthesizing => VoiceFlowState.synthesizing,
      VoiceJobStatus.completed || VoiceJobStatus.failed => state.flowState,
    };
    state = state.copyWith(flowState: flowState);
  }

  Future<void> _handleJobResult(VoiceChatJobStatus job) async {
    if (job.status == VoiceJobStatus.failed) {
      _setError(job.error ?? 'Голосовой чат завершился с ошибкой');
      return;
    }

    if (_isDisposed) return;

    final now = _formatTime(DateTime.now());
    final updatedEvents = [
      ...state.transcriptEvents,
      KaiTranscriptEvent(
        who: 'you',
        text: job.transcript ?? '',
        timestamp: now,
      ),
      KaiTranscriptEvent(
        who: 'kai',
        text: job.responseText ?? '',
        timestamp: now,
      ),
    ];

    final responseText = job.responseText ?? '';
    final words = responseText.trim().isEmpty
        ? <String>[]
        : responseText.trim().split(RegExp(r'\s+'));

    state = state.copyWith(
      flowState: VoiceFlowState.speaking,
      transcriptEvents: updatedEvents,
      lastTranscript: job.transcript ?? '',
      lastResponseText: responseText,
      ttsFailed: job.ttsFailed ?? false,
      karaokeWords: words,
      karaokeIndex: 0,
    );

    final audio = job.audio;
    if ((job.ttsFailed ?? false) || audio == null || audio.isEmpty) {
      await Future<void>.delayed(const Duration(seconds: 2));
      if (!_isDisposed && state.flowState == VoiceFlowState.speaking) {
        state = state.copyWith(flowState: VoiceFlowState.idle);
      }
    } else {
      unawaited(_playAudio(audio));
    }
  }

  Future<void> _playAudio(Uint8List audio) async {
    try {
      await _player.playBytes(audio);
      if (!_isDisposed) {
        state = state.copyWith(flowState: VoiceFlowState.idle);
      }
    } catch (e, st) {
      AppLogger.e('Audio playback failed', e, st);
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

  String _humanReadableError(DioException e) {
    final wrapped = e.error;
    if (wrapped is NetworkException) {
      final status = wrapped.statusCode;
      switch (wrapped.failure) {
        case NetworkFailure.offline:
          return 'No internet connection';
        case NetworkFailure.timeout:
          return 'Request timed out. The server is taking too long to respond.';
        case NetworkFailure.clientError when status == 401 || status == 403:
          return 'Authorization failed. Check your HF_TOKEN in .env.';
        case NetworkFailure.clientError when status == 404:
          return 'Backend is unreachable. The Space may be private, stopped, or the URL is wrong.';
        case NetworkFailure.serverError:
          return 'Server error. Please try again later.';
        case NetworkFailure.cancelled:
          return 'Request was cancelled.';
        case _:
          break;
      }
    }
    return 'Connection error';
  }

  String _formatTime(DateTime dt) {
    final hour = dt.hour.toString().padLeft(2, '0');
    final minute = dt.minute.toString().padLeft(2, '0');
    return '$hour:$minute';
  }
}
