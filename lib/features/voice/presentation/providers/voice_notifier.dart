import 'dart:async';
import 'dart:io';
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
  StreamSubscription<AudioInterruptionEvent>? _interruptionSub;
  StreamSubscription<AudioDevicesChangedEvent>? _devicesSub;

  // Progressive playback: each server binary frame is a complete clause MP3.
  // Queue them and play sequentially so long replies stream sentence-by-sentence.
  final _playQueue = <Uint8List>[];
  bool _draining = false;
  bool _isActive = false; // WS session open
  bool _starting = false; // guards the start window before _isActive flips
  bool _isDisposed = false; // set in onDispose; gates state writes from async cbs
  bool _resumeAfterInterruption = false; // auto-resume when interruption ends
  int _pcmChunkCount = 0; // DEBUG: count PCM chunks sent to server
  int _pcmProducedCount = 0; // DEBUG: count PCM chunks produced by recorder

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

      // Configure the AVAudioSession before opening the mic so iOS keeps the
      // recording alive while we stream over the WebSocket. The previous manual
      // approach failed because it was called too late; audio_session handles
      // the lifecycle correctly.
      await _configureAudioSession();
      await _listenToAudioSessionEvents();

      _wsClient = WsVoiceClient(wsUrl: wsUrl, apiKey: apiKey, hfToken: env.hfToken);
      await _wsClient!.connect(
        userId: _userId,
        sessionId: _sessionId,
        language: language,
      );
      _isActive = true;
      // Immediate feedback: the mic is hot — show "listening" without waiting for
      // the server's speech-onset event so the user knows to start talking.
      state = state.copyWith(
        flowState: VoiceFlowState.listening,
        debug: 'WS connected ✓ — speak now',
      );

      _eventSub = _wsClient!.events.listen(
        _onWsMessage,
        onError: (Object e) {
          AppLogger.e('WS error', e, StackTrace.current);
          _setError('Connection error');
        },
      );

      // Start streaming PCM to server
      _pcmChunkCount = 0;
      _pcmProducedCount = 0; // DEBUG: chunks produced by the recorder plugin
      final pcmStream = await _recorder.startStream();
      AppLogger.i('[VOICE] Recorder stream started');
      _pcmSub = pcmStream.listen(
        (chunk) {
          if (_isDisposed) return;
          _pcmProducedCount++;
          _wsClient?.sendPcm(chunk);
          _pcmChunkCount++;
          // RMS amplitude for KaiTideLarge
          final amp = _rms(chunk).clamp(0.0, 1.0);
          // DEBUG: log first chunk and every 50th so we can verify the mic is
          // actually producing data and it is being forwarded to the backend.
          final ampChanged = (amp - state.amplitude).abs() > 0.02;
          if (_pcmChunkCount <= 5 ||
              _pcmChunkCount % 50 == 0 ||
              ampChanged ||
              _pcmProducedCount != _pcmChunkCount) {
            AppLogger.i(
              '[VOICE] pcm produced=$_pcmProducedCount sent=$_pcmChunkCount '
              'bytes=${chunk.length} rms=${amp.toStringAsFixed(3)}',
            );
            state = state.copyWith(
              amplitude: ampChanged ? amp : null,
              debug: 'mic ▸ produced $_pcmProducedCount · sent $_pcmChunkCount · rms ${amp.toStringAsFixed(3)}',
            );
          }
        },
        onError: (Object e, StackTrace st) {
          AppLogger.e('[VOICE] Recorder stream error', e, st);
          if (_isActive && !_isDisposed) {
            unawaited(_cleanup());
            _setError('Microphone stream error');
          }
        },
        onDone: () {
          AppLogger.i('[VOICE] Recorder stream done (produced=$_pcmProducedCount sent=$_pcmChunkCount)');
          if (_isActive && !_isDisposed) {
            unawaited(_cleanup());
            _setError('Microphone stopped unexpectedly');
          }
        },
      );
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

  /// Configure AVAudioSession for duplex voice.
  ///
  /// On iOS the `record` plugin manages AVAudioSession itself
  /// (IosRecordConfig.manageAudioSession defaults to true). Our previous
  /// attempts to layer audio_session on top caused very low RMS, so we let
  /// the recorder drive the session on iOS and only configure audio_session
  /// on Android.
  Future<void> _configureAudioSession() async {
    if (Platform.isIOS) {
      AppLogger.i('[VOICE] iOS: letting record plugin manage AVAudioSession');
      return;
    }
    try {
      final session = await AudioSession.instance;
      await session.configure(
        const AudioSessionConfiguration(
          avAudioSessionCategory: AVAudioSessionCategory.playAndRecord,
          avAudioSessionMode: AVAudioSessionMode.voiceChat,
          avAudioSessionRouteSharingPolicy:
              AVAudioSessionRouteSharingPolicy.defaultPolicy,
          avAudioSessionSetActiveOptions: AVAudioSessionSetActiveOptions.none,
          androidAudioAttributes: AndroidAudioAttributes(
            contentType: AndroidAudioContentType.speech,
            usage: AndroidAudioUsage.voiceCommunication,
          ),
          androidWillPauseWhenDucked: true,
        ),
      );
      final activated = await session.setActive(true);
      AppLogger.i('[VOICE] AudioSession setActive(true) -> $activated');
    } catch (e, st) {
      AppLogger.e('[VOICE] AudioSession configuration failed', e, st);
      // Don't fail the whole session if AudioSession is unavailable on a platform.
    }
  }

  Future<void> _deactivateAudioSession() async {
    if (Platform.isIOS) {
      // record plugin owns AVAudioSession lifecycle on iOS.
      return;
    }
    try {
      final session = await AudioSession.instance;
      final deactivated = await session.setActive(false);
      AppLogger.i('[VOICE] AudioSession setActive(false) -> $deactivated');
    } catch (e, st) {
      AppLogger.e('[VOICE] AudioSession deactivation failed', e, st);
    }
  }

  /// Subscribe to audio focus and route changes so we can recover from phone
  /// calls, Siri, headphones unplugging, etc. Subscriptions are cancelled in
  /// [_cleanup] to avoid leaking listeners across sessions.
  ///
  /// Currently only active on Android; on iOS the record plugin manages the
  /// AVAudioSession and we avoid layering a second controller on top.
  Future<void> _listenToAudioSessionEvents() async {
    if (Platform.isIOS) return;
    try {
      final session = await AudioSession.instance;
      await _interruptionSub?.cancel();
      _interruptionSub = session.interruptionEventStream.listen(
        _onInterruption,
        onError: (Object e, StackTrace st) {
          AppLogger.e('[VOICE] interruption stream error', e, st);
        },
      );
      await _devicesSub?.cancel();
      _devicesSub = session.devicesChangedEventStream.listen(
        _onDevicesChanged,
        onError: (Object e, StackTrace st) {
          AppLogger.e('[VOICE] devices-changed stream error', e, st);
        },
      );
    } catch (e, st) {
      AppLogger.e('[VOICE] Failed to listen to audio session events', e, st);
    }
  }

  /// React to audio interruptions (phone call, Siri, alarm, etc.).
  /// On iOS this corresponds to AVAudioSessionInterruptionNotification.
  void _onInterruption(AudioInterruptionEvent event) {
    AppLogger.i(
      '[VOICE] Interruption begin=${event.begin} type=${event.type}',
    );
    if (event.begin) {
      // Another app took audio focus. Remember whether we were live so we can
      // auto-resume when the interruption ends.
      if (_isActive) {
        _resumeAfterInterruption = true;
        _cleanup();
        state = state.copyWith(
          flowState: VoiceFlowState.idle,
          debug: 'Audio interrupted — paused',
        );
      }
    } else {
      // Interruption ended. For pause-type interruptions the OS tells us if we
      // should resume. Unknown-type interruptions are handled conservatively:
      // we do not auto-resume because the user may no longer be in the voice UI.
      final shouldResume = event.type == AudioInterruptionType.pause;
      if (_resumeAfterInterruption && shouldResume) {
        _resumeAfterInterruption = false;
        AppLogger.i('[VOICE] Auto-resuming after interruption');
        unawaited(_startSession());
      } else {
        _resumeAfterInterruption = false;
      }
    }
  }

  /// Log audio route/device changes (headphones, bluetooth, receiver, etc.).
  /// On iOS this mirrors AVAudioSessionRouteChangeNotification.
  void _onDevicesChanged(AudioDevicesChangedEvent event) {
    AppLogger.i(
      '[VOICE] Audio devices added=${event.devicesAdded} '
      'removed=${event.devicesRemoved}',
    );
    state = state.copyWith(
      debug: 'audio route changed ▸ +${event.devicesAdded.length} '
          '-${event.devicesRemoved.length}',
    );
  }

  void _onWsMessage(dynamic msg) {
    if (_isDisposed) return;
    if (msg is Uint8List) {
      AppLogger.i('[VOICE] WS binary rx ${msg.length}b');
      state = state.copyWith(debug: 'rx ◂ audio ${msg.length}b');
      _enqueueClause(msg); // one frame == one complete clause MP3
      return;
    }
    if (msg is! Map<String, dynamic>) {
      AppLogger.i('[VOICE] WS unknown msg type: ${msg.runtimeType}');
      return;
    }

    final event = msg['event'] as String? ?? '';
    AppLogger.i('[VOICE] WS event: $event payload=$msg');
    switch (event) {
      case 'state':
        state = state.copyWith(debug: 'rx ◂ state:${msg['state']}');
        _applyServerState(msg['state'] as String? ?? 'idle');
      case 'transcript':
        final text = msg['text'] as String? ?? '';
        if (text.isNotEmpty) {
          state = state.copyWith(
            lastTranscript: text,
            debug: 'rx ◂ you: $text',
          );
        }
      case 'audio_begin':
        // New turn: log the user's line and reset the play queue.
        _appendUserTranscript(state.lastTranscript);
        _playQueue.clear();
      case 'response_text':
        // Assistant reply text: show on screen AND append to the conversation
        // transcript (so the transcript sheet shows both 'you' and 'kai' lines).
        final text = msg['text'] as String? ?? '';
        if (text.isNotEmpty) {
          state = state.copyWith(
            lastResponseText: text,
            debug: 'rx ◂ kai: $text',
            transcriptEvents: [
              ...state.transcriptEvents,
              KaiTranscriptEvent(
                who: 'kai',
                text: text,
                timestamp: _formatTime(DateTime.now()),
              ),
            ],
          );
        }
      case 'clear': // barge-in: drop queued clauses and stop current playback
        _playQueue.clear();
        _player.stop();
      case 'error':
        _setError(msg['code'] as String? ?? 'error');
      case 'ping':
        // Server keepalive; WsVoiceClient replies with pong automatically.
        break;
      case 'pong':
        // Client should never receive its own pong; ignore.
        break;
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
    _resumeAfterInterruption = false;
    _pcmChunkCount = 0;
    _pcmProducedCount = 0;
    await _deactivateAudioSession();
    // Each step guarded so a failure (e.g. recorder.stop PlatformException)
    // doesn't leak the WS socket / subscriptions left after it.
    try {
      await _interruptionSub?.cancel();
    } catch (e, st) {
      AppLogger.e('interruptionSub cancel failed', e, st);
    }
    _interruptionSub = null;
    try {
      await _devicesSub?.cancel();
    } catch (e, st) {
      AppLogger.e('devicesSub cancel failed', e, st);
    }
    _devicesSub = null;
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
