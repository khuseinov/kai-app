import 'dart:async';
import 'dart:math' as math;
import 'dart:typed_data';

import 'package:audio_session/audio_session.dart';
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

  // Progressive playback: each server binary frame is a complete clause MP3.
  // Queue them and play sequentially so long replies stream sentence-by-sentence.
  final _playQueue = <Uint8List>[];
  bool _draining = false;
  bool _isActive = false; // WS session open
  bool _starting = false; // guards the start window before _isActive flips
  bool _isDisposed = false; // set in onDispose; gates state writes from async cbs
  int _pcmChunkCount = 0; // DEBUG: count PCM chunks sent to server

  @override
  VoiceStateData build() {
    _player = ref.read(audioPlayerServiceProvider);
    _recorder = ref.read(streamingRecorderServiceProvider);
    _userId = ref.read(userIdProvider);
    _sessionId = ref.read(roomNotifierProvider).activeSessionId ?? 'voice-$_userId';

    ref.onDispose(() {
      _isDisposed = true;
      _cleanup();
    });
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
    // Synchronous guard: _isActive only flips after `await connect()`, so a
    // second tap during that window would start a duplicate session.
    if (_isActive || _starting) return;
    _starting = true;
    try {
      final env = ref.read(envProvider);
      final baseUrl = env.voiceGatewayBaseUrl ?? '';
      if (baseUrl.isEmpty) {
        _setError('Voice gateway URL not configured');
        return;
      }

      final apiKey = env.voiceGatewayApiKey ?? '';
      final wsUrl = '${baseUrl.replaceFirst(RegExp('^http'), 'ws')}/voice/live';
      final language = _detectLanguage();

      final hasPermission = await _recorder.hasPermission();
      if (!hasPermission) {
        _setError('Microphone permission denied');
        return;
      }

      // iOS: route mic + playback through one playAndRecord session on the
      // speaker. Without this the record session silences just_audio playback
      // (and can leave the mic dead between turns).
      await _configureAudioSession();

      _wsClient = WsVoiceClient(wsUrl: wsUrl, apiKey: apiKey, hfToken: env.hfToken);
      await _wsClient!.connect(
        userId: _userId,
        sessionId: _sessionId,
        language: language,
      );
      _isActive = true;
      // Immediate feedback: the mic is hot — show "listening" without waiting for
      // the server's speech-onset event so the user knows to start talking.
      state = state.copyWith(flowState: VoiceFlowState.listening);

      _eventSub = _wsClient!.events.listen(
        _onWsMessage,
        onError: (Object e) {
          AppLogger.e('WS error', e, StackTrace.current);
          _setError('Connection error');
        },
      );

      // Start streaming PCM to server
      _pcmChunkCount = 0;
      final pcmStream = await _recorder.startStream();
      _pcmSub = pcmStream.listen((chunk) {
        if (_isDisposed) return;
        _wsClient?.sendPcm(chunk);
        _pcmChunkCount++;
        // RMS amplitude for KaiTideLarge
        final amp = _rms(chunk).clamp(0.0, 1.0);
        // DEBUG: log first chunk and every 50th so we can verify the mic is
        // actually producing data and it is being forwarded to the backend.
        if (_pcmChunkCount == 1 || _pcmChunkCount % 50 == 0) {
          AppLogger.i(
            '[VOICE] PCM chunk #$_pcmChunkCount sent: ${chunk.length} bytes, '
            'rms=${amp.toStringAsFixed(4)}',
          );
        }
        if ((amp - state.amplitude).abs() > 0.02) {
          state = state.copyWith(amplitude: amp);
        }
      });
    } catch (e, st) {
      AppLogger.e('Failed to start voice session', e, st);
      _setError('Failed to start: $e');
      await _cleanup();
    } finally {
      _starting = false;
    }
  }

  Future<void> _stopSession() async {
    _wsClient?.sendEvent({'event': 'stop'});
    await _cleanup();
    state = state.copyWith(flowState: VoiceFlowState.idle, amplitude: 0);
  }

  /// Configure one shared playAndRecord session so the mic and just_audio
  /// playback coexist on iOS, routed to the loudspeaker. No-op-safe on failure.
  Future<void> _configureAudioSession() async {
    try {
      final session = await AudioSession.instance;
      await session.configure(
        const AudioSessionConfiguration(
          avAudioSessionCategory: AVAudioSessionCategory.playAndRecord,
          avAudioSessionCategoryOptions:
              AVAudioSessionCategoryOptions.defaultToSpeaker,
          avAudioSessionMode: AVAudioSessionMode.spokenAudio,
          androidAudioAttributes: AndroidAudioAttributes(
            contentType: AndroidAudioContentType.speech,
            usage: AndroidAudioUsage.voiceCommunication,
          ),
        ),
      );
      await session.setActive(true);
    } catch (e, st) {
      AppLogger.e('audio session config failed', e, st);
    }
  }

  void _onWsMessage(dynamic msg) {
    if (_isDisposed) return;
    if (msg is Uint8List) {
      AppLogger.i('[VOICE] enqueue audio clause: ${msg.length} bytes');
      _enqueueClause(msg); // one frame == one complete clause MP3
      return;
    }
    if (msg is! Map<String, dynamic>) {
      AppLogger.w('[VOICE] unknown WS message type: ${msg.runtimeType}');
      return;
    }

    final event = msg['event'] as String? ?? '';
    AppLogger.i('[VOICE] WS event: $event payload=$msg');
    switch (event) {
      case 'state':
        _applyServerState(msg['state'] as String? ?? 'idle');
      case 'transcript':
        final text = msg['text'] as String? ?? '';
        if (text.isNotEmpty) {
          state = state.copyWith(lastTranscript: text);
          AppLogger.i('[VOICE] transcript updated: $text');
        }
      case 'audio_begin':
        // New turn: log the user's line and reset the play queue.
        _appendUserTranscript(state.lastTranscript);
        _playQueue.clear();
      case 'response_text':
        // Server may stream the assistant reply as text for display.
        final text = msg['text'] as String? ?? '';
        if (text.isNotEmpty) {
          state = state.copyWith(lastResponseText: text);
        }
      case 'clear': // barge-in: drop queued clauses and stop current playback
        _playQueue.clear();
        _player.stop();
      case 'error':
        _setError(msg['code'] as String? ?? 'error');
      case 'disconnected':
        _isActive = false;
        state = state.copyWith(flowState: VoiceFlowState.idle, amplitude: 0);
    }
  }

  void _applyServerState(String serverState) {
    var flowState = switch (serverState) {
      'listening' => VoiceFlowState.listening,
      'thinking' => VoiceFlowState.thinking,
      'speaking' => VoiceFlowState.speaking,
      _ => VoiceFlowState.idle,
    };
    // While the session is open the mic stays hot: server "idle" (no active turn)
    // means "armed, waiting for speech", so show listening — not a dead idle that
    // reads as "off". Real idle only after the session closes.
    if (flowState == VoiceFlowState.idle && _isActive) {
      flowState = VoiceFlowState.listening;
    }
    // Don't yank the user out of the transcript overlay on a server state push;
    // remember it so returnFromTranscript() restores the live state instead.
    if (state.flowState == VoiceFlowState.transcript) {
      state = state.copyWith(previousState: flowState);
      return;
    }
    state = state.copyWith(flowState: flowState);
  }

  void _enqueueClause(Uint8List mp3) {
    if (mp3.isEmpty) return;
    _playQueue.add(mp3);
    unawaited(_drainQueue());
  }

  /// Plays queued clauses one after another. A single drain loop runs at a time;
  /// new clauses appended mid-turn are picked up by the running loop.
  Future<void> _drainQueue() async {
    if (_draining) return;
    _draining = true;
    try {
      while (_playQueue.isNotEmpty) {
        if (_isDisposed) break;
        final clause = _playQueue.removeAt(0);
        try {
          await _player.playBytes(clause);
        } catch (e, st) {
          AppLogger.e('Clause playback failed', e, st);
        }
      }
    } finally {
      _draining = false;
      if (!_isDisposed) state = state.copyWith(amplitude: 0);
    }
  }

  void _appendUserTranscript(String text) {
    if (text.isEmpty) return;
    final now = _formatTime(DateTime.now());
    state = state.copyWith(
      transcriptEvents: [
        ...state.transcriptEvents,
        KaiTranscriptEvent(who: 'you', text: text, timestamp: now),
      ],
    );
  }

  Future<void> _cleanup() async {
    _isActive = false;
    _pcmChunkCount = 0;
    // Each step guarded so a failure (e.g. recorder.stop PlatformException)
    // doesn't leak the WS socket / subscriptions left after it.
    try {
      await _pcmSub?.cancel();
    } catch (e, st) {
      AppLogger.e('pcmSub cancel failed', e, st);
    }
    _pcmSub = null;
    try {
      await _recorder.stop();
    } catch (e, st) {
      AppLogger.e('recorder stop failed', e, st);
    }
    try {
      await _eventSub?.cancel();
    } catch (e, st) {
      AppLogger.e('eventSub cancel failed', e, st);
    }
    _eventSub = null;
    try {
      await _wsClient?.close();
    } catch (e, st) {
      AppLogger.e('wsClient close failed', e, st);
    }
    _wsClient = null;
    _playQueue.clear();
    try {
      await _player.stop();
    } catch (e, st) {
      AppLogger.e('player stop failed', e, st);
    }
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
    return math.sqrt(sum / samples); // root-mean-square (was mean-square: wave never animated)
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
