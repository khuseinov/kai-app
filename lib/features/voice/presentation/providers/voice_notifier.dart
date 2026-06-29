import 'dart:async';
import 'dart:typed_data';

import 'package:kai_app/core/logger/app_logger.dart';
import 'package:kai_app/core/providers/root.dart';
import 'package:kai_app/features/room/presentation/providers/room_state.dart';
import 'package:kai_app/features/voice/data/services/streaming_recorder_service.dart';
import 'package:kai_app/features/voice/data/services/ws_voice_client.dart';
import 'package:kai_app/features/voice/domain/services/audio_player_service.dart';
import 'package:kai_app/features/voice/presentation/providers/voice_state.dart';
import 'package:kai_app/features/voice/presentation/widgets/kai_transcript_view.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'voice_notifier.g.dart';

@riverpod
class VoiceNotifier extends _$VoiceNotifier {
  late final AudioPlayerService _player;
  late final StreamingRecorderService _recorder;
  late final String _sessionId;
  late final String _userId;

  WsVoiceClient? _wsClient;
  StreamSubscription<dynamic>? _eventSub;
  StreamSubscription<Uint8List>? _pcmSub;

  // Collect MP3 chunks during a turn; play on audio_end.
  final _audioBuf = BytesBuilder(copy: false);
  bool _collecting = false;
  bool _isActive = false; // WS session open

  @override
  VoiceStateData build() {
    _player = ref.read(audioPlayerServiceProvider);
    _recorder = ref.read(streamingRecorderServiceProvider);
    _userId = ref.read(userIdProvider);
    _sessionId = ref.read(roomNotifierProvider).activeSessionId ?? 'voice-$_userId';

    ref.onDispose(_cleanup);
    return const VoiceStateData();
  }

  // ───────────────────────────── tap-toggle API ──────────────────────────────

  /// Tap once to start; tap again to stop.
  Future<void> handleTap() async {
    if (_isActive) {
      await _stopSession();
    } else {
      await _startSession();
    }
  }

  /// Legacy hold-down (kept for backward compat with VoicePage).
  Future<void> handleTapDown() => _startSession();

  /// Legacy hold-up.
  Future<void> handleTapUp([String language = 'ru']) => Future.value();

  void stopSpeaking() {
    if (state.flowState == VoiceFlowState.speaking) {
      _player.stop();
      state = state.copyWith(flowState: VoiceFlowState.idle, amplitude: 0);
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

  // ────────────────────────────── internals ──────────────────────────────────

  Future<void> _startSession() async {
    if (_isActive) return;

    final env = ref.read(envProvider);
    final baseUrl = env.voiceGatewayBaseUrl ?? '';
    if (baseUrl.isEmpty) {
      _setError('Voice gateway URL not configured');
      return;
    }

    final apiKey = env.voiceGatewayApiKey ?? '';
    final wsUrl = '${baseUrl.replaceFirst(RegExp('^http'), 'ws')}/voice/live';
    final language = _detectLanguage();

    try {
      final hasPermission = await _recorder.hasPermission();
      if (!hasPermission) {
        _setError('Microphone permission denied');
        return;
      }

      _wsClient = WsVoiceClient(wsUrl: wsUrl, apiKey: apiKey);
      await _wsClient!.connect(
        userId: _userId,
        sessionId: _sessionId,
        language: language,
      );
      _isActive = true;

      _eventSub = _wsClient!.events.listen(
        _onWsMessage,
        onError: (Object e) {
          AppLogger.e('WS error', e, StackTrace.current);
          _setError('Connection error');
        },
      );

      // Start streaming PCM to server
      final pcmStream = await _recorder.startStream();
      _pcmSub = pcmStream.listen((chunk) {
        _wsClient?.sendPcm(chunk);
        // RMS amplitude for KaiTideLarge
        final amp = _rms(chunk).clamp(0.0, 1.0);
        if ((amp - state.amplitude).abs() > 0.02) {
          state = state.copyWith(amplitude: amp);
        }
      });
    } catch (e, st) {
      AppLogger.e('Failed to start voice session', e, st);
      _setError('Failed to start: $e');
      await _cleanup();
    }
  }

  Future<void> _stopSession() async {
    _wsClient?.sendEvent({'event': 'stop'});
    await _cleanup();
    state = state.copyWith(flowState: VoiceFlowState.idle, amplitude: 0);
  }

  void _onWsMessage(dynamic msg) {
    if (msg is Uint8List) {
      if (_collecting) _audioBuf.add(msg);
      return;
    }
    if (msg is! Map<String, dynamic>) return;

    final event = msg['event'] as String? ?? '';
    switch (event) {
      case 'state':
        _applyServerState(msg['state'] as String? ?? 'idle');
      case 'transcript':
        final text = msg['text'] as String? ?? '';
        if (text.isNotEmpty) {
          state = state.copyWith(lastTranscript: text);
        }
      case 'audio_begin':
        _collecting = true;
        _audioBuf.clear();
      case 'audio_end':
        _collecting = false;
        final bytes = _audioBuf.takeBytes();
        if (bytes.isNotEmpty) {
          _playResponseAudio(bytes);
        }
      case 'clear':
        _collecting = false;
        _audioBuf.clear();
        _player.stop();
      case 'error':
        _setError(msg['code'] as String? ?? 'error');
      case 'disconnected':
        _isActive = false;
        state = state.copyWith(flowState: VoiceFlowState.idle, amplitude: 0);
    }
  }

  void _applyServerState(String serverState) {
    final flowState = switch (serverState) {
      'listening' => VoiceFlowState.listening,
      'thinking' => VoiceFlowState.thinking,
      'speaking' => VoiceFlowState.speaking,
      _ => VoiceFlowState.idle,
    };
    state = state.copyWith(flowState: flowState);
  }

  Future<void> _playResponseAudio(Uint8List bytes) async {
    try {
      await _player.playBytes(bytes);
      // Update transcript after playback
      final now = _formatTime(DateTime.now());
      final updatedEvents = [
        ...state.transcriptEvents,
        if (state.lastTranscript.isNotEmpty)
          KaiTranscriptEvent(who: 'you', text: state.lastTranscript, timestamp: now),
      ];
      state = state.copyWith(transcriptEvents: updatedEvents, amplitude: 0);
    } catch (e, st) {
      AppLogger.e('Audio playback failed', e, st);
    }
  }

  Future<void> _cleanup() async {
    _isActive = false;
    await _pcmSub?.cancel();
    _pcmSub = null;
    await _recorder.stop();
    await _eventSub?.cancel();
    _eventSub = null;
    await _wsClient?.close();
    _wsClient = null;
    _collecting = false;
    _audioBuf.clear();
  }

  void _setError(String message) {
    state = state.copyWith(
      flowState: VoiceFlowState.idle,
      errorMessage: message,
      amplitude: 0,
    );
  }

  static double _rms(Uint8List pcm16) {
    if (pcm16.length < 2) return 0;
    var sum = 0.0;
    final samples = pcm16.length ~/ 2;
    final bd = pcm16.buffer.asByteData();
    for (var i = 0; i < samples; i++) {
      final s = bd.getInt16(i * 2, Endian.little) / 32768.0;
      sum += s * s;
    }
    return (sum / samples == 0) ? 0 : (sum / samples);
  }

  static String _detectLanguage() {
    // ponytail: hardcoded ru for v1; read from locale in Phase 2
    return 'ru';
  }

  static String _formatTime(DateTime dt) {
    final h = dt.hour.toString().padLeft(2, '0');
    final m = dt.minute.toString().padLeft(2, '0');
    return '$h:$m';
  }
}
