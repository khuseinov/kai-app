import 'dart:async';
import 'dart:typed_data';

import 'package:audio_session/audio_session.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:kai_app/core/providers/root.dart';
import 'package:kai_app/features/room/presentation/providers/room_state.dart';
import 'package:kai_app/features/voice/data/services/livekit_voice_session.dart';
import 'package:kai_app/features/voice/data/services/opus_encoder_service.dart';
import 'package:kai_app/features/voice/data/services/streaming_recorder_service.dart';
import 'package:kai_app/features/voice/data/services/ws_voice_client.dart';
import 'package:kai_app/features/voice/domain/services/audio_player_service.dart';
import 'package:kai_app/features/voice/domain/services/voice_vad_service.dart';
import 'package:kai_app/features/voice/presentation/providers/voice_notifier.dart';
import 'package:kai_app/features/voice/presentation/providers/voice_state.dart';

// ───────────────────────────── fakes ──────────────────────────────────────────

class _FakeRecorder extends StreamingRecorderService {
  _FakeRecorder({this.permissionResult = true});

  final bool permissionResult;
  bool stopped = false;

  @override
  Future<bool> hasPermission() async => permissionResult;

  @override
  Future<Stream<Uint8List>> startStream() async {
    stopped = false;
    return StreamController<Uint8List>().stream; // never emits, stays open
  }

  @override
  Future<void> stop() async {
    stopped = true;
  }
}

class _FakePlayer implements AudioPlayerService {
  final calls = <String>[];
  Duration positionValue = Duration.zero;

  @override
  Duration get position => positionValue;

  @override
  Future<bool> isPlaying() async => false;
  @override
  Future<void> startStream() async => calls.add('startStream');
  @override
  void feed(Uint8List chunk) => calls.add('feed:${chunk.length}');
  @override
  Future<void> endStream() async => calls.add('endStream');
  @override
  Future<void> stop() async => calls.add('stop');
}

class _FakeVadService implements VoiceVadService {
  bool initialized = false;
  bool wasReset = false;
  final _controller = StreamController<void>.broadcast();

  @override
  Future<void> init() async => initialized = true;
  @override
  void feed(Uint8List pcm16) {}
  @override
  Stream<void> get onRealSpeechStart => _controller.stream;
  @override
  void reset() => wasReset = true;
  @override
  void dispose() => _controller.close();
}

class FakeWsVoiceClient implements WsVoiceClient {
  FakeWsVoiceClient({this.failConnect = false});

  final bool failConnect;
  final events_ = StreamController<dynamic>.broadcast();
  final sentEvents = <Map<String, dynamic>>[];
  final sentAudio = <Uint8List>[];
  bool closed = false;
  bool connected = false;
  String? lastLanguage;

  @override
  String get wsUrl => 'ws://fake/voice/live';
  @override
  String get apiKey => 'fake-key';
  @override
  String? get hfToken => null;

  @override
  bool get isConnected => connected;

  @override
  Stream<dynamic> get events => events_.stream;

  @override
  Future<void> connect({
    required String userId,
    required String sessionId,
    required String language,
  }) async {
    if (failConnect) throw Exception('connect refused');
    lastLanguage = language;
    connected = true;
  }

  @override
  void sendEvent(Map<String, dynamic> event) => sentEvents.add(event);

  @override
  void sendAudio(Uint8List packet) => sentAudio.add(packet);

  @override
  Future<void> close() async {
    closed = true;
    connected = false;
  }

  @override
  void dispose() {
    close();
    events_.close();
  }

  void emit(dynamic msg) => events_.add(msg);
}

class _FakeLivekitSession implements LivekitVoiceSession {
  final events_ = StreamController<LivekitSessionEvent>.broadcast();
  bool closed = false;

  @override
  Stream<LivekitSessionEvent> get events => events_.stream;

  @override
  Future<void> close() async {
    closed = true;
    await events_.close();
  }

  void emit(LivekitSessionEvent event) => events_.add(event);
}

class _MockRoomNotifier extends RoomNotifier {
  _MockRoomNotifier(this._initial);
  final RoomStateData _initial;
  @override
  RoomStateData build() => _initial;
}

// ─────────────────────────── container factory ────────────────────────────────

typedef _Made = ({ProviderContainer container, List<FakeWsVoiceClient> clients, List<_FakeLivekitSession> lkSessions, _FakeRecorder recorder, _FakePlayer player});

_Made _make({
  bool permissionResult = true,
  String voiceUrl = 'http://mock-voice',
  String transport = 'ws',
  bool livekitUnavailable = false,
  bool Function(int attempt)? connectFails,
}) {
  final clients = <FakeWsVoiceClient>[];
  final lkSessions = <_FakeLivekitSession>[];
  final recorder = _FakeRecorder(permissionResult: permissionResult);
  final player = _FakePlayer();
  final container = ProviderContainer(
    overrides: [
      envProvider.overrideWithValue(
        EnvConfig(
          apiBaseUrl: 'http://mock-api',
          voiceGatewayBaseUrl: voiceUrl,
          useRealChat: false,
          voiceTransport: transport,
        ),
      ),
      livekitSessionFactoryProvider.overrideWithValue(
        ({required String userId, required String sessionId}) async {
          if (livekitUnavailable) {
            throw LivekitUnavailableException('test: 503');
          }
          final session = _FakeLivekitSession();
          lkSessions.add(session);
          return session;
        },
      ),
      streamingRecorderServiceProvider.overrideWithValue(recorder),
      audioPlayerServiceProvider.overrideWithValue(player),
      voiceVadServiceProvider.overrideWithValue(_FakeVadService()),
      opusEncoderFactoryProvider.overrideWithValue(
        // Pure-Dart fake: no native libopus/path_provider in flutter_test.
        () async => OpusEncoderService(frameEncoder: (window) => Uint8List(1)),
      ),
      wsVoiceClientFactoryProvider.overrideWithValue(
        ({required String wsUrl, required String apiKey, String? hfToken}) {
          final fail = connectFails?.call(clients.length + 1) ?? false;
          final client = FakeWsVoiceClient(failConnect: fail);
          clients.add(client);
          return client;
        },
      ),
      roomNotifierProvider.overrideWith(
        () => _MockRoomNotifier(const RoomStateData(activeSessionId: 's-1')),
      ),
      userIdProvider.overrideWithValue('u-1'),
    ],
  );
  return (container: container, clients: clients, lkSessions: lkSessions, recorder: recorder, player: player);
}

Future<void> _pump() => Future<void>.delayed(Duration.zero);

// ─────────────────────────────── tests ───────────────────────────────────────

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUp(() {
    VoiceNotifier.reconnectBackoff = const [Duration.zero, Duration.zero, Duration.zero];
    VoiceNotifier.localeCodeGetter = () => 'en';
    VoiceNotifier.karaokeTickInterval = const Duration(milliseconds: 1);
  });

  test('no voice gateway URL → idle + "not configured" error', () async {
    final m = _make(voiceUrl: '');
    addTearDown(m.container.dispose);
    m.container.listen(voiceNotifierProvider, (_, __) {});

    await m.container.read(voiceNotifierProvider.notifier).handleTap();

    final state = m.container.read(voiceNotifierProvider);
    expect(state.flowState, VoiceFlowState.idle);
    expect(state.error, VoiceError.noGateway);
  });

  test('mic permission denied → idle + permission error', () async {
    final m = _make(permissionResult: false);
    addTearDown(m.container.dispose);
    m.container.listen(voiceNotifierProvider, (_, __) {});

    await m.container.read(voiceNotifierProvider.notifier).handleTap();

    final state = m.container.read(voiceNotifierProvider);
    expect(state.flowState, VoiceFlowState.idle);
    expect(state.error, VoiceError.micPermission);
  });

  test('successful start → listening; server events drive the state machine',
      () async {
    final m = _make();
    addTearDown(m.container.dispose);
    m.container.listen(voiceNotifierProvider, (_, __) {});
    final notifier = m.container.read(voiceNotifierProvider.notifier);

    await notifier.handleTap();
    expect(m.container.read(voiceNotifierProvider).flowState,
        VoiceFlowState.listening);
    final ws = m.clients.single;

    ws.emit({'event': 'state', 'state': 'thinking'});
    await _pump();
    expect(m.container.read(voiceNotifierProvider).flowState,
        VoiceFlowState.thinking);

    ws.emit({'event': 'transcript', 'text': 'привет'});
    await _pump();
    expect(
        m.container.read(voiceNotifierProvider).lastTranscript, 'привет');

    ws.emit({'event': 'audio_begin', 'turn_id': 't1'});
    await _pump();
    expect(m.player.calls, contains('startStream'));

    ws.emit(Uint8List.fromList([1, 2, 3]));
    await _pump();
    expect(m.player.calls, contains('feed:3'));

    ws.emit({'event': 'audio_end', 'turn_id': 't1'});
    await _pump();
    expect(m.player.calls, contains('endStream'));

    ws.emit({'event': 'clear'});
    await _pump();
    expect(m.player.calls, contains('stop'));

    ws.emit({'event': 'error', 'code': 'stt_failed'});
    await _pump();
    expect(m.container.read(voiceNotifierProvider).error, VoiceError.sttFailed);
  });

  test('unexpected disconnect → cleanup + reconnect succeeds on retry',
      () async {
    final m = _make();
    addTearDown(m.container.dispose);
    m.container.listen(voiceNotifierProvider, (_, __) {});
    final notifier = m.container.read(voiceNotifierProvider.notifier);

    await notifier.handleTap();
    final ws = m.clients.single;
    ws.emit({'event': 'transcript', 'text': 'до обрыва'});
    await _pump();

    ws.emit({'event': 'disconnected', 'code': 1006, 'reason': 'abnormal'});
    // The cleanup→backoff→restart chain crosses many microtasks/timers.
    for (var i = 0; i < 10; i++) {
      await _pump();
    }

    // A second client was created (reconnect) and connected.
    expect(m.clients.length, 2);
    expect(m.clients.last.connected, isTrue);
    final state = m.container.read(voiceNotifierProvider);
    expect(state.flowState, VoiceFlowState.listening);
    // Transcript survives the reconnect.
    expect(state.lastTranscript, 'до обрыва');
  });

  test('reconnect exhaustion after 3 failed attempts → error + idle', () async {
    final m = _make(connectFails: (attempt) => attempt > 1); // retries all fail
    addTearDown(m.container.dispose);
    m.container.listen(voiceNotifierProvider, (_, __) {});
    final notifier = m.container.read(voiceNotifierProvider.notifier);

    await notifier.handleTap();
    m.clients.single.emit({'event': 'disconnected', 'code': 1006});
    // let the retry loop run
    for (var i = 0; i < 10; i++) {
      await _pump();
    }

    expect(m.clients.length, 4); // 1 initial + 3 retries
    final state = m.container.read(voiceNotifierProvider);
    expect(state.flowState, VoiceFlowState.idle);
    expect(state.error, VoiceError.connectionLost);
  });

  test('user stop → no reconnect', () async {
    final m = _make();
    addTearDown(m.container.dispose);
    m.container.listen(voiceNotifierProvider, (_, __) {});
    final notifier = m.container.read(voiceNotifierProvider.notifier);

    await notifier.handleTap(); // start
    await notifier.handleTap(); // stop
    for (var i = 0; i < 5; i++) {
      await _pump();
    }

    expect(m.clients.length, 1); // never reconnected
    expect(m.container.read(voiceNotifierProvider).flowState,
        VoiceFlowState.idle);
  });

  test('auth failure close code 4401 → no retry, error surfaced', () async {
    final m = _make();
    addTearDown(m.container.dispose);
    m.container.listen(voiceNotifierProvider, (_, __) {});
    final notifier = m.container.read(voiceNotifierProvider.notifier);

    await notifier.handleTap();
    m.clients.single.emit({'event': 'disconnected', 'code': 4401});
    for (var i = 0; i < 5; i++) {
      await _pump();
    }

    expect(m.clients.length, 1); // no reconnect on auth failure
    final state = m.container.read(voiceNotifierProvider);
    expect(state.flowState, VoiceFlowState.idle);
    expect(state.error, VoiceError.authFailed);
  });

  test('handleTapUp() is a no-op (legacy hold-up compat)', () async {
    final m = _make(voiceUrl: '');
    addTearDown(m.container.dispose);
    m.container.listen(voiceNotifierProvider, (_, __) {});

    await expectLater(
      m.container.read(voiceNotifierProvider.notifier).handleTapUp(),
      completes,
    );
  });

  test('error clears on next successful session start', () async {
    final m = _make();
    addTearDown(m.container.dispose);
    m.container.listen(voiceNotifierProvider, (_, __) {});
    final notifier = m.container.read(voiceNotifierProvider.notifier);

    await notifier.handleTap();
    m.clients.single.emit({'event': 'error', 'code': 'stt_failed'});
    await _pump();
    expect(m.container.read(voiceNotifierProvider).error, VoiceError.sttFailed);

    await notifier.handleTap(); // stop (error state left the session inactive? no — error keeps session)
    await notifier.handleTap(); // fresh start
    for (var i = 0; i < 5; i++) {
      await _pump();
    }

    expect(m.container.read(voiceNotifierProvider).error, isNull);
  });

  test('voice language follows app locale (EN-first, ru for ru locale)',
      () async {
    VoiceNotifier.localeCodeGetter = () => 'ru';
    final m = _make();
    addTearDown(m.container.dispose);
    m.container.listen(voiceNotifierProvider, (_, __) {});

    await m.container.read(voiceNotifierProvider.notifier).handleTap();

    expect(m.clients.single.lastLanguage, 'ru');
  });

  test('voice language defaults to en for non-ru locales', () async {
    VoiceNotifier.localeCodeGetter = () => 'de';
    final m = _make();
    addTearDown(m.container.dispose);
    m.container.listen(voiceNotifierProvider, (_, __) {});

    await m.container.read(voiceNotifierProvider.notifier).handleTap();

    expect(m.clients.single.lastLanguage, 'en');
  });

  test('clause_words accumulates karaoke words across clauses', () async {
    final m = _make();
    addTearDown(m.container.dispose);
    m.container.listen(voiceNotifierProvider, (_, __) {});
    final notifier = m.container.read(voiceNotifierProvider.notifier);

    await notifier.handleTap();
    final ws = m.clients.single;
    ws.emit({'event': 'audio_begin', 'turn_id': 't1'});
    await _pump();
    ws.emit({
      'event': 'clause_words',
      'turn_id': 't1',
      'clause_index': 0,
      'duration_ms': 1000,
      'text': 'Привет мир.',
      'words': [
        {'w': 'Привет', 't_ms': 0, 'd_ms': 300},
        {'w': 'мир.', 't_ms': 350, 'd_ms': 300},
      ],
    });
    await _pump();
    ws.emit({
      'event': 'clause_words',
      'turn_id': 't1',
      'clause_index': 1,
      'duration_ms': 800,
      'text': 'Как дела?',
      'words': [
        {'w': 'Как', 't_ms': 0, 'd_ms': 200},
        {'w': 'дела?', 't_ms': 250, 'd_ms': 300},
      ],
    });
    await _pump();

    expect(m.container.read(voiceNotifierProvider).karaokeWords,
        ['Привет', 'мир.', 'Как', 'дела?']);
  });

  test('karaokeIndex follows player position across clause offsets', () async {
    final m = _make();
    addTearDown(m.container.dispose);
    m.container.listen(voiceNotifierProvider, (_, __) {});
    final notifier = m.container.read(voiceNotifierProvider.notifier);

    await notifier.handleTap();
    final ws = m.clients.single;
    ws.emit({'event': 'audio_begin', 'turn_id': 't1'});
    await _pump();
    ws.emit({
      'event': 'clause_words',
      'turn_id': 't1',
      'clause_index': 0,
      'duration_ms': 1000,
      'text': 'a b',
      'words': [
        {'w': 'a', 't_ms': 0, 'd_ms': 300},
        {'w': 'b', 't_ms': 500, 'd_ms': 300},
      ],
    });
    ws.emit({
      'event': 'clause_words',
      'turn_id': 't1',
      'clause_index': 1,
      'duration_ms': 1000,
      'text': 'c',
      'words': [
        {'w': 'c', 't_ms': 100, 'd_ms': 300},
      ],
    });
    await _pump();

    // position 0 -> first word highlighted
    m.player.positionValue = Duration.zero;
    await Future<void>.delayed(const Duration(milliseconds: 20));
    expect(m.container.read(voiceNotifierProvider).karaokeIndex, 0);

    // 600ms -> second word of clause 0
    m.player.positionValue = const Duration(milliseconds: 600);
    await Future<void>.delayed(const Duration(milliseconds: 20));
    expect(m.container.read(voiceNotifierProvider).karaokeIndex, 1);

    // 1200ms -> clause 1 started (offset 1000) + its word at +100ms
    m.player.positionValue = const Duration(milliseconds: 1200);
    await Future<void>.delayed(const Duration(milliseconds: 20));
    expect(m.container.read(voiceNotifierProvider).karaokeIndex, 2);
  });

  test('clause_words without word stamps paces uniformly over duration',
      () async {
    final m = _make();
    addTearDown(m.container.dispose);
    m.container.listen(voiceNotifierProvider, (_, __) {});
    final notifier = m.container.read(voiceNotifierProvider.notifier);

    await notifier.handleTap();
    final ws = m.clients.single;
    ws.emit({'event': 'audio_begin', 'turn_id': 't1'});
    await _pump();
    ws.emit({
      'event': 'clause_words',
      'turn_id': 't1',
      'clause_index': 0,
      'duration_ms': 400,
      'text': 'one two three four',
      'words': <Map<String, Object>>[],
    });
    await _pump();

    expect(m.container.read(voiceNotifierProvider).karaokeWords,
        ['one', 'two', 'three', 'four']);

    m.player.positionValue = const Duration(milliseconds: 250);
    await Future<void>.delayed(const Duration(milliseconds: 20));
    // 400ms / 4 words = 100ms per word -> at 250ms word index 2 is current
    expect(m.container.read(voiceNotifierProvider).karaokeIndex, 2);
  });

  test('karaoke resets on clear (barge-in) and on a new turn', () async {
    final m = _make();
    addTearDown(m.container.dispose);
    m.container.listen(voiceNotifierProvider, (_, __) {});
    final notifier = m.container.read(voiceNotifierProvider.notifier);

    await notifier.handleTap();
    final ws = m.clients.single;
    ws.emit({'event': 'audio_begin', 'turn_id': 't1'});
    await _pump();
    ws.emit({
      'event': 'clause_words',
      'turn_id': 't1',
      'clause_index': 0,
      'duration_ms': 500,
      'text': 'x y',
      'words': [
        {'w': 'x', 't_ms': 0, 'd_ms': 100},
        {'w': 'y', 't_ms': 200, 'd_ms': 100},
      ],
    });
    await _pump();
    expect(
        m.container.read(voiceNotifierProvider).karaokeWords, isNotEmpty);

    ws.emit({'event': 'clear'});
    await _pump();
    expect(m.container.read(voiceNotifierProvider).karaokeWords, isEmpty);
    expect(m.container.read(voiceNotifierProvider).karaokeIndex, 0);

    // New turn also starts clean.
    ws.emit({'event': 'audio_begin', 'turn_id': 't2'});
    await _pump();
    expect(m.container.read(voiceNotifierProvider).karaokeWords, isEmpty);
  });

  test(
    'shared AVAudioSession config: playAndRecord + voiceChat + speaker/bluetooth '
    'on every platform (no iOS skip — audio_session is now the single owner)',
    () {
      final config = VoiceNotifier.kaiVoiceSessionConfig;
      expect(config.avAudioSessionCategory, AVAudioSessionCategory.playAndRecord);
      expect(config.avAudioSessionMode, AVAudioSessionMode.voiceChat);
      expect(
        config.avAudioSessionCategoryOptions
            ?.contains(AVAudioSessionCategoryOptions.defaultToSpeaker),
        isTrue,
      );
      expect(
        config.avAudioSessionCategoryOptions
            ?.contains(AVAudioSessionCategoryOptions.allowBluetooth),
        isTrue,
      );
      expect(
        config.androidAudioAttributes?.usage,
        AndroidAudioUsage.voiceCommunication,
      );
    },
  );

  group('LiveKit transport (VOICE_TRANSPORT=livekit)', () {
    test('start goes through LiveKit — no WS client, no local recorder', () async {
      final m = _make(transport: 'livekit');
      addTearDown(m.container.dispose);
      m.container.listen(voiceNotifierProvider, (_, __) {});

      await m.container.read(voiceNotifierProvider.notifier).handleTap();

      expect(m.lkSessions, hasLength(1));
      expect(m.clients, isEmpty);
      expect(
        m.container.read(voiceNotifierProvider).flowState,
        VoiceFlowState.listening,
      );
    });

    test('token 503 / unavailable → silent fallback to the WS pipeline', () async {
      final m = _make(transport: 'livekit', livekitUnavailable: true);
      addTearDown(m.container.dispose);
      m.container.listen(voiceNotifierProvider, (_, __) {});

      await m.container.read(voiceNotifierProvider.notifier).handleTap();

      expect(m.lkSessions, isEmpty);
      expect(m.clients, hasLength(1));
      expect(m.clients.single.connected, isTrue);
      final state = m.container.read(voiceNotifierProvider);
      expect(state.flowState, VoiceFlowState.listening);
      expect(state.error, isNull);
    });

    test('agent state + transcripts map onto the same state machine', () async {
      final m = _make(transport: 'livekit');
      addTearDown(m.container.dispose);
      m.container.listen(voiceNotifierProvider, (_, __) {});
      await m.container.read(voiceNotifierProvider.notifier).handleTap();
      final session = m.lkSessions.single;

      session.emit(const LkAgentState('thinking'));
      await _pump();
      expect(
        m.container.read(voiceNotifierProvider).flowState,
        VoiceFlowState.thinking,
      );

      session.emit(const LkAgentState('speaking'));
      await _pump();
      expect(
        m.container.read(voiceNotifierProvider).flowState,
        VoiceFlowState.speaking,
      );

      session.emit(const LkUserTranscript('привет кай', isFinal: true));
      session.emit(const LkAgentTranscript('Привет!', isFinal: true));
      await _pump();
      final state = m.container.read(voiceNotifierProvider);
      expect(state.lastTranscript, 'привет кай');
      expect(state.lastResponseText, 'Привет!');
      expect(state.transcriptEvents.map((e) => e.who), ['you', 'kai']);

      // Turn over: agent back to listening.
      session.emit(const LkAgentState('listening'));
      await _pump();
      expect(
        m.container.read(voiceNotifierProvider).flowState,
        VoiceFlowState.listening,
      );
    });

    test('user stop closes the LiveKit session and returns to idle', () async {
      final m = _make(transport: 'livekit');
      addTearDown(m.container.dispose);
      m.container.listen(voiceNotifierProvider, (_, __) {});
      final notifier = m.container.read(voiceNotifierProvider.notifier);

      await notifier.handleTap(); // start
      await notifier.handleTap(); // stop

      expect(m.lkSessions.single.closed, isTrue);
      expect(
        m.container.read(voiceNotifierProvider).flowState,
        VoiceFlowState.idle,
      );
    });

    test('ws transport (default) never touches the LiveKit factory', () async {
      final m = _make();
      addTearDown(m.container.dispose);
      m.container.listen(voiceNotifierProvider, (_, __) {});

      await m.container.read(voiceNotifierProvider.notifier).handleTap();

      expect(m.lkSessions, isEmpty);
      expect(m.clients, hasLength(1));
    });
  });
}
