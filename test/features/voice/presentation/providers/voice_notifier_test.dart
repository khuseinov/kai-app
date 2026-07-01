import 'dart:async';
import 'dart:typed_data';

import 'package:audio_session/audio_session.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:kai_app/core/providers/root.dart';
import 'package:kai_app/features/room/presentation/providers/room_state.dart';
import 'package:kai_app/features/voice/data/services/streaming_recorder_service.dart';
import 'package:kai_app/features/voice/domain/services/audio_player_service.dart';
import 'package:kai_app/features/voice/domain/services/voice_vad_service.dart';
import 'package:kai_app/features/voice/presentation/providers/voice_notifier.dart';
import 'package:kai_app/features/voice/presentation/providers/voice_state.dart';

// ───────────────────────────── fakes ──────────────────────────────────────────

class _FakeRecorder extends StreamingRecorderService {
  _FakeRecorder({this.permissionResult = true});

  final bool permissionResult;

  @override
  Future<bool> hasPermission() async => permissionResult;

  @override
  Future<Stream<Uint8List>> startStream() async =>
      StreamController<Uint8List>().stream; // never emits, keeps session open

  @override
  Future<void> stop() async {}
}

class _FakePlayer implements AudioPlayerService {
  @override
  Future<bool> isPlaying() async => false;
  @override
  Future<void> startStream() async {}
  @override
  void feed(Uint8List chunk) {}
  @override
  Future<void> endStream() async {}
  @override
  Future<void> stop() async {}
}

class _FakeVadService implements VoiceVadService {
  final feedCalls = <Uint8List>[];
  bool initialized = false;
  bool wasReset = false;
  final _controller = StreamController<void>.broadcast();

  @override
  Future<void> init() async => initialized = true;
  @override
  void feed(Uint8List pcm16) => feedCalls.add(pcm16);
  @override
  Stream<void> get onRealSpeechStart => _controller.stream;
  @override
  void reset() => wasReset = true;
  @override
  void dispose() => _controller.close();
}

class _MockRoomNotifier extends RoomNotifier {
  _MockRoomNotifier(this._initial);
  final RoomStateData _initial;
  @override
  RoomStateData build() => _initial;
}

// ─────────────────────────── container factory ────────────────────────────────

ProviderContainer _container({
  bool permissionResult = true,
  String voiceUrl = 'http://mock-voice',
}) {
  return ProviderContainer(
    overrides: [
      envProvider.overrideWithValue(
        EnvConfig(
          apiBaseUrl: 'http://mock-api',
          voiceGatewayBaseUrl: voiceUrl,
          useRealChat: false,
        ),
      ),
      streamingRecorderServiceProvider.overrideWithValue(
        _FakeRecorder(permissionResult: permissionResult),
      ),
      audioPlayerServiceProvider.overrideWithValue(_FakePlayer()),
      voiceVadServiceProvider.overrideWithValue(_FakeVadService()),
      roomNotifierProvider.overrideWith(
        () => _MockRoomNotifier(const RoomStateData(activeSessionId: 's-1')),
      ),
      userIdProvider.overrideWithValue('u-1'),
    ],
  );
}

// ─────────────────────────────── tests ───────────────────────────────────────

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  test('no voice gateway URL → idle + "not configured" error', () async {
    final c = _container(voiceUrl: '');
    addTearDown(c.dispose);
    c.listen(voiceNotifierProvider, (_, __) {});

    await c.read(voiceNotifierProvider.notifier).handleTapDown();

    final state = c.read(voiceNotifierProvider);
    expect(state.flowState, VoiceFlowState.idle);
    expect(state.errorMessage, contains('not configured'));
  });

  test('mic permission denied → idle + permission error', () async {
    final c = _container(permissionResult: false);
    addTearDown(c.dispose);
    c.listen(voiceNotifierProvider, (_, __) {});

    await c.read(voiceNotifierProvider.notifier).handleTapDown();

    final state = c.read(voiceNotifierProvider);
    expect(state.flowState, VoiceFlowState.idle);
    expect(state.errorMessage, contains('permission'));
  });

  test('handleTap() with no URL → same idle + error behaviour', () async {
    final c = _container(voiceUrl: '');
    addTearDown(c.dispose);
    c.listen(voiceNotifierProvider, (_, __) {});

    await c.read(voiceNotifierProvider.notifier).handleTap();

    final state = c.read(voiceNotifierProvider);
    expect(state.flowState, VoiceFlowState.idle);
    expect(state.errorMessage, isNotEmpty);
  });

  test('handleTapUp() is a no-op (legacy hold-up compat)', () async {
    final c = _container(voiceUrl: '');
    addTearDown(c.dispose);
    c.listen(voiceNotifierProvider, (_, __) {});

    // Should complete without throwing regardless of state.
    await expectLater(
      c.read(voiceNotifierProvider.notifier).handleTapUp(),
      completes,
    );
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
}
