import 'dart:async';
import 'dart:math' as math;
import 'dart:typed_data';
import 'dart:ui' as ui;

import 'package:audio_session/audio_session.dart';
import 'package:flutter/foundation.dart' show kDebugMode, visibleForTesting;
import 'package:kai_app/core/logger/app_logger.dart';
import 'package:kai_app/core/providers/root.dart';
import 'package:kai_app/features/room/presentation/providers/room_state.dart';
import 'package:kai_app/features/voice/data/services/livekit_voice_session.dart';
import 'package:kai_app/features/voice/data/services/opus_encoder_service.dart';
import 'package:kai_app/features/voice/data/services/streaming_recorder_service.dart';
import 'package:kai_app/features/voice/data/services/ws_voice_client.dart';
import 'package:kai_app/features/voice/domain/services/audio_player_service.dart';
import 'package:kai_app/features/voice/domain/services/voice_vad_service.dart';
import 'package:kai_app/features/voice/presentation/providers/voice_state.dart';
import 'package:kai_app/features/voice/presentation/widgets/kai_transcript_view.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'voice_notifier.g.dart';

@riverpod
class VoiceNotifier extends _$VoiceNotifier {
  /// Delays between automatic reconnect attempts after an unexpected
  /// disconnect. Mutable so tests can zero it out.
  @visibleForTesting
  static List<Duration> reconnectBackoff = const [
    Duration(milliseconds: 500),
    Duration(seconds: 1),
    Duration(seconds: 2),
  ];

  /// Karaoke index refresh cadence. Mutable so tests can speed it up.
  @visibleForTesting
  static Duration karaokeTickInterval = const Duration(milliseconds: 100);

  late final AudioPlayerService _player;
  late final StreamingRecorderService _recorder;
  late final VoiceVadService _vad;
  late final WsVoiceClientFactory _wsFactory;
  late final OpusEncoderFactory _opusFactory;
  late final LivekitSessionFactory _lkFactory;
  late final String _sessionId;
  late final String _userId;

  WsVoiceClient? _wsClient;
  LivekitVoiceSession? _lkSession;
  OpusEncoderService? _opusEncoder;
  bool _userStopped = false; // intentional stop — never auto-reconnect
  bool _reconnectInProgress = false;
  Timer? _karaokeTimer;
  final List<int> _karaokeStartsMs = []; // absolute word starts, turn-relative
  int _karaokeOffsetMs = 0; // cumulative duration of prior clauses
  DateTime? _turnAudioStartedAt; // wall-clock fallback when position unknown
  StreamSubscription<dynamic>? _eventSub;
  StreamSubscription<Uint8List>? _pcmSub;
  StreamSubscription<AudioInterruptionEvent>? _interruptionSub;
  StreamSubscription<AudioDevicesChangedEvent>? _devicesSub;
  StreamSubscription<void>? _vadSub;

  bool _isActive = false; // WS session open
  bool _starting = false; // guards the start window before _isActive flips
  bool _isDisposed = false; // set in onDispose; gates state writes from async cbs
  bool _resumeAfterInterruption = false; // auto-resume when interruption ends

  @override
  VoiceStateData build() {
    _player = ref.read(audioPlayerServiceProvider);
    _recorder = ref.read(streamingRecorderServiceProvider);
    _vad = ref.read(voiceVadServiceProvider);
    _wsFactory = ref.read(wsVoiceClientFactoryProvider);
    _opusFactory = ref.read(opusEncoderFactoryProvider);
    _lkFactory = ref.read(livekitSessionFactoryProvider);
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
    _userStopped = false;
    try {
      final env = ref.read(envProvider);
      final baseUrl = env.voiceGatewayBaseUrl ?? '';
      if (baseUrl.isEmpty) {
        _setError(VoiceError.noGateway);
        return;
      }

      // LiveKit transport (VOICE_TRANSPORT=livekit): the WebRTC stack owns
      // mic/playback/AEC natively, so none of the WS pipeline below runs.
      // Any unavailability falls straight through to the WS baseline.
      if (env.voiceTransport == 'livekit' && await _startLivekitSession()) {
        return;
      }

      final apiKey = env.voiceGatewayApiKey ?? '';
      final wsUrl = '${baseUrl.replaceFirst(RegExp('^http'), 'ws')}/voice/live';
      final language = _detectLanguage();

      final hasPermission = await _recorder.hasPermission();
      if (!hasPermission) {
        _setError(VoiceError.micPermission);
        return;
      }

      // Configure the AVAudioSession before opening the mic so iOS keeps the
      // recording alive while we stream over the WebSocket. The previous manual
      // approach failed because it was called too late; audio_session handles
      // the lifecycle correctly.
      await _configureAudioSession();
      await _listenToAudioSessionEvents();

      _wsClient = _wsFactory(wsUrl: wsUrl, apiKey: apiKey, hfToken: env.hfToken);
      await _wsClient!.connect(
        userId: _userId,
        sessionId: _sessionId,
        language: language,
      );
      _isActive = true;
      // Immediate feedback: the mic is hot — show "listening" without waiting
      // for the server's speech-onset event. A fresh session always clears any
      // stale error from the previous one.
      state = state.copyWith(
        flowState: VoiceFlowState.listening,
        error: null,
      );
      _setDebug('WS connected ✓ — speak now');

      _eventSub = _wsClient!.events.listen(
        _onWsMessage,
        onError: (Object e) {
          AppLogger.e('WS error', e, StackTrace.current);
          _setError(VoiceError.connection);
        },
      );

      // Barge-in: detect real speech while Kai is talking and tell the server
      // to cancel the in-flight reply. The server already handles
      // {"event":"barge_in"} unconditionally (orchestrator.py _handle_control);
      // this only needs to fire it.
      await _vad.init();
      await _vadSub?.cancel();
      _vadSub = _vad.onRealSpeechStart.listen((_) {
        if (_isDisposed || state.flowState != VoiceFlowState.speaking) return;
        AppLogger.i('[VOICE] barge-in: real speech detected during playback');
        _wsClient?.sendEvent({'event': 'barge_in'});
        _vad.reset();
      });

      // Start streaming PCM to server, encoded as Opus (20ms frames) — the
      // server's ?codec=opus (set in ws_voice_client.dart's connect URL)
      // must match this.
      _opusEncoder = await _opusFactory();
      final pcmStream = await _recorder.startStream();
      AppLogger.i('[VOICE] Recorder stream started');
      _pcmSub = pcmStream.listen(
        (chunk) {
          if (_isDisposed) return;
          for (final packet in _opusEncoder!.encode(chunk)) {
            _wsClient?.sendAudio(packet);
          }
          // Only run barge-in detection while Kai is actually speaking — no
          // point spending CPU/battery on VAD inference the rest of the turn.
          // VAD needs raw PCM, not Opus, so it feeds off the pre-encode chunk.
          if (state.flowState == VoiceFlowState.speaking) {
            _vad.feed(chunk);
          }
          // RMS amplitude for KaiTideLarge
          final amp = _rms(chunk).clamp(0.0, 1.0);
          if ((amp - state.amplitude).abs() > 0.02) {
            state = state.copyWith(amplitude: amp);
            _setDebug('mic ▸ rms ${amp.toStringAsFixed(3)}');
          }
        },
        onError: (Object e, StackTrace st) {
          AppLogger.e('[VOICE] Recorder stream error', e, st);
          if (_isActive && !_isDisposed) {
            unawaited(_cleanup());
            _setError(VoiceError.micStream);
          }
        },
        onDone: () {
          AppLogger.i('[VOICE] Recorder stream done');
          if (_isActive && !_isDisposed) {
            unawaited(_cleanup());
            _setError(VoiceError.micStream);
          }
        },
      );
    } catch (e, st) {
      AppLogger.e('Failed to start voice session', e, st);
      _setError(VoiceError.startFailed);
      await _cleanup();
    } finally {
      _starting = false;
    }
  }

  Future<void> _stopSession() async {
    _userStopped = true;
    _wsClient?.sendEvent({'event': 'stop'});
    await _cleanup();
    state = state.copyWith(flowState: VoiceFlowState.idle, amplitude: 0);
  }

  /// Try to start a LiveKit session. Returns false when the transport is
  /// unavailable (token 503, config missing, connect failure) — the caller
  /// then runs the WS pipeline instead. Never surfaces an error itself.
  Future<bool> _startLivekitSession() async {
    try {
      final session = await _lkFactory(userId: _userId, sessionId: _sessionId);
      _lkSession = session;
      _isActive = true;
      state = state.copyWith(flowState: VoiceFlowState.listening, error: null);
      _setDebug('LiveKit connected ✓ — speak now');
      _eventSub = session.events.listen(
        _onLivekitEvent,
        onError: (Object e) {
          AppLogger.e('[VOICE] LiveKit session error', e, StackTrace.current);
          _setError(VoiceError.connection);
        },
      );
      return true;
    } on LivekitUnavailableException catch (e) {
      AppLogger.i('[VOICE] LiveKit unavailable (${e.reason}) — WS fallback');
      return false;
    } catch (e, st) {
      AppLogger.e('[VOICE] LiveKit start failed — WS fallback', e, st);
      await _lkSession?.close();
      _lkSession = null;
      _isActive = false;
      return false;
    }
  }

  void _onLivekitEvent(LivekitSessionEvent event) {
    if (_isDisposed) return;
    switch (event) {
      case LkAgentState(:final state):
        // initializing → default branch → idle → shown as listening while
        // the session is active (same rule as the WS server states).
        _applyServerState(state);
      case LkUserTranscript(:final text, :final isFinal):
        state = state.copyWith(lastTranscript: text);
        if (isFinal) _appendUserTranscript(text);
      case LkAgentTranscript(:final text, :final isFinal):
        state = state.copyWith(lastResponseText: text);
        if (isFinal) {
          state = state.copyWith(
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
      case LkDisconnected():
        unawaited(_onDisconnected(null));
    }
  }

  /// Shared AVAudioSession config for duplex voice, applied on every platform.
  ///
  /// Previously iOS left this entirely to the `record` plugin (which manages
  /// AVAudioSession by default) while `just_audio` (TTS playback) separately
  /// touched the session — two uncoordinated owners caused session thrash and
  /// the mic going silent after a few frames. `audio_session` is now the
  /// single owner everywhere; `StreamingRecorderService.buildRecordConfig()`
  /// sets `iosConfig.manageAudioSession: false` to match.
  @visibleForTesting
  static final kaiVoiceSessionConfig = AudioSessionConfiguration(
    avAudioSessionCategory: AVAudioSessionCategory.playAndRecord,
    avAudioSessionMode: AVAudioSessionMode.voiceChat,
    avAudioSessionCategoryOptions: AVAudioSessionCategoryOptions.defaultToSpeaker |
        AVAudioSessionCategoryOptions.allowBluetooth,
    avAudioSessionRouteSharingPolicy: AVAudioSessionRouteSharingPolicy.defaultPolicy,
    avAudioSessionSetActiveOptions: AVAudioSessionSetActiveOptions.none,
    androidAudioAttributes: const AndroidAudioAttributes(
      contentType: AndroidAudioContentType.speech,
      usage: AndroidAudioUsage.voiceCommunication,
    ),
    androidWillPauseWhenDucked: true,
  );

  /// Configure AVAudioSession for duplex voice, before the mic opens.
  Future<void> _configureAudioSession() async {
    try {
      final session = await AudioSession.instance;
      await session.configure(kaiVoiceSessionConfig);
      final activated = await session.setActive(true);
      AppLogger.i('[VOICE] AudioSession setActive(true) -> $activated');
    } catch (e, st) {
      AppLogger.e('[VOICE] AudioSession configuration failed', e, st);
      // Don't fail the whole session if AudioSession is unavailable on a platform.
    }
  }

  Future<void> _deactivateAudioSession() async {
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
  Future<void> _listenToAudioSessionEvents() async {
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
        state = state.copyWith(flowState: VoiceFlowState.idle);
        _setDebug('Audio interrupted — paused');
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
    _setDebug(
      'audio route changed ▸ +${event.devicesAdded.length} '
      '-${event.devicesRemoved.length}',
    );
  }

  void _onWsMessage(dynamic msg) {
    if (_isDisposed) return;
    if (msg is Uint8List) {
      _setDebug('rx ◂ audio ${msg.length}b');
      _player.feed(msg);
      return;
    }
    if (msg is! Map<String, dynamic>) {
      AppLogger.d('[VOICE] WS unknown msg type: ${msg.runtimeType}');
      return;
    }

    final event = msg['event'] as String? ?? '';
    AppLogger.d('[VOICE] WS event: $event');
    switch (event) {
      case 'state':
        _setDebug('rx ◂ state:${msg['state']}');
        _applyServerState(msg['state'] as String? ?? 'idle');
      case 'transcript':
        final text = msg['text'] as String? ?? '';
        if (text.isNotEmpty) {
          state = state.copyWith(lastTranscript: text);
          _setDebug('rx ◂ you: $text');
        }
      case 'audio_begin':
        // New turn: log the user's line, start a fresh playback stream, and
        // reset VAD + karaoke state (a new reply shouldn't inherit leftover
        // detector counters or word timings from the previous turn).
        _appendUserTranscript(state.lastTranscript);
        _resetKaraoke();
        unawaited(_player.startStream());
        _vad.reset();
      case 'clause_words':
        _appendKaraokeClause(msg);
      case 'response_text':
        // Assistant reply text: show on screen AND append to the conversation
        // transcript (so the transcript sheet shows both 'you' and 'kai' lines).
        final text = msg['text'] as String? ?? '';
        if (text.isNotEmpty) {
          _setDebug('rx ◂ kai: $text');
          state = state.copyWith(
            lastResponseText: text,
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
      case 'audio_end':
        // No more clauses coming for this turn; let buffered audio drain.
        unawaited(_player.endStream());
      case 'clear': // barge-in: stop current playback immediately
        _resetKaraoke();
        unawaited(_player.stop());
      case 'error':
        _setError(switch (msg['code'] as String?) {
          'stt_failed' => VoiceError.sttFailed,
          _ => VoiceError.pipelineFailed,
        });
      case 'ping':
        // Server keepalive; WsVoiceClient replies with pong automatically.
        break;
      case 'pong':
        // Client should never receive its own pong; ignore.
        break;
      case 'disconnected':
        unawaited(_onDisconnected(msg['code'] as int?));
    }
  }

  /// Handles a socket drop: full resource cleanup, then bounded auto-reconnect
  /// for unexpected disconnects (never for user stops or auth failures).
  ///
  /// Without the cleanup the recorder/encoder/VAD kept running into a closed
  /// sink after any server-side drop, leaking a hot mic until the provider
  /// was disposed.
  Future<void> _onDisconnected(int? closeCode) async {
    if (_isDisposed || _reconnectInProgress) return;
    final wasActive = _isActive;
    _isActive = false;
    await _cleanup();
    if (_isDisposed) return;

    if (!wasActive || _userStopped) {
      state = state.copyWith(flowState: VoiceFlowState.idle, amplitude: 0);
      return;
    }
    if (closeCode == 4401) {
      _setError(VoiceError.authFailed);
      return;
    }

    _reconnectInProgress = true;
    try {
      for (final delay in reconnectBackoff) {
        state = state.copyWith(
          flowState: VoiceFlowState.idle,
          reconnecting: true,
          amplitude: 0,
        );
        await Future<void>.delayed(delay);
        if (_isDisposed || _userStopped) return;
        await _startSession();
        if (_isActive) {
          state = state.copyWith(reconnecting: false);
          return;
        }
      }
      _setError(VoiceError.connectionLost);
    } finally {
      _reconnectInProgress = false;
      if (!_isDisposed && state.reconnecting) {
        state = state.copyWith(reconnecting: false);
      }
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

  /// Ingest one clause's word timings ("clause_words" protocol event —
  /// always arrives right before that clause's MP3 binary frame). When the
  /// server has no per-word stamps (Piper fallback), words are paced
  /// uniformly across the clause duration.
  void _appendKaraokeClause(Map<String, dynamic> msg) {
    final text = msg['text'] as String? ?? '';
    final durationMs = (msg['duration_ms'] as num?)?.toInt() ?? 0;
    final stamps = (msg['words'] as List<dynamic>?) ?? const [];

    final words = <String>[];
    final starts = <int>[];
    if (stamps.isNotEmpty) {
      for (final raw in stamps) {
        final stamp = raw as Map<String, dynamic>;
        words.add(stamp['w'] as String? ?? '');
        starts.add(_karaokeOffsetMs + ((stamp['t_ms'] as num?)?.toInt() ?? 0));
      }
    } else {
      final split =
          text.split(RegExp(r'\s+')).where((w) => w.isNotEmpty).toList();
      if (split.isEmpty) {
        _karaokeOffsetMs += durationMs;
        return;
      }
      // ponytail: 350ms/word estimate when duration is unknown too; real
      // per-word boundaries come from edge-tts on the primary path anyway.
      final perWordMs = durationMs > 0 ? durationMs ~/ split.length : 350;
      for (var i = 0; i < split.length; i++) {
        words.add(split[i]);
        starts.add(_karaokeOffsetMs + i * perWordMs);
      }
    }
    _karaokeOffsetMs += durationMs > 0 ? durationMs : words.length * 350;
    _karaokeStartsMs.addAll(starts);
    _turnAudioStartedAt ??= DateTime.now();
    state = state.copyWith(karaokeWords: [...state.karaokeWords, ...words]);
    _karaokeTimer ??= Timer.periodic(karaokeTickInterval, (_) => _tickKaraoke());
  }

  void _tickKaraoke() {
    if (_isDisposed) {
      _karaokeTimer?.cancel();
      _karaokeTimer = null;
      return;
    }
    final startedAt = _turnAudioStartedAt;
    if (startedAt == null || _karaokeStartsMs.isEmpty) return;
    final playerMs = _player.position.inMilliseconds;
    final posMs = playerMs > 0
        ? playerMs
        : DateTime.now().difference(startedAt).inMilliseconds;
    var passed = 0;
    while (passed < _karaokeStartsMs.length && _karaokeStartsMs[passed] <= posMs) {
      passed++;
    }
    final index = passed > 0 ? passed - 1 : 0;
    if (index != state.karaokeIndex) {
      state = state.copyWith(karaokeIndex: index);
    }
  }

  void _resetKaraoke() {
    _karaokeTimer?.cancel();
    _karaokeTimer = null;
    _karaokeStartsMs.clear();
    _karaokeOffsetMs = 0;
    _turnAudioStartedAt = null;
    if (!_isDisposed &&
        (state.karaokeWords.isNotEmpty || state.karaokeIndex != 0)) {
      state = state.copyWith(karaokeWords: const [], karaokeIndex: 0);
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
      await _vadSub?.cancel();
    } catch (e, st) {
      AppLogger.e('vadSub cancel failed', e, st);
    }
    _vadSub = null;
    _vad.reset();
    _karaokeTimer?.cancel();
    _karaokeTimer = null;
    try {
      await _pcmSub?.cancel();
    } catch (e, st) {
      AppLogger.e('pcmSub cancel failed', e, st);
    }
    _pcmSub = null;
    try {
      _opusEncoder?.dispose();
    } catch (e, st) {
      AppLogger.e('opusEncoder dispose failed', e, st);
    }
    _opusEncoder = null;
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
    try {
      await _lkSession?.close();
    } catch (e, st) {
      AppLogger.e('livekit session close failed', e, st);
    }
    _lkSession = null;
    try {
      await _player.stop();
    } catch (e, st) {
      AppLogger.e('player stop failed', e, st);
    }
  }

  /// On-screen debug line — debug builds only; release keeps state clean.
  void _setDebug(String message) {
    if (!kDebugMode || _isDisposed) return;
    state = state.copyWith(debug: message);
  }

  void _setError(VoiceError error) {
    state = state.copyWith(
      flowState: VoiceFlowState.idle,
      error: error,
      reconnecting: false,
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

  /// Returns the current platform locale's language code. Injectable so
  /// tests can pin the locale.
  @visibleForTesting
  static String Function() localeCodeGetter =
      () => ui.PlatformDispatcher.instance.locale.languageCode;

  /// Voice language follows the app locale — EN-first global default, Russian
  /// only for ru locales.
  static String _detectLanguage() => localeCodeGetter() == 'ru' ? 'ru' : 'en';

  static String _formatTime(DateTime dt) {
    final h = dt.hour.toString().padLeft(2, '0');
    final m = dt.minute.toString().padLeft(2, '0');
    return '$h:$m';
  }
}
