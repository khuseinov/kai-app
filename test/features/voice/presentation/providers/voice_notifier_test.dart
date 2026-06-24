import 'dart:io';
import 'dart:typed_data';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:kai_app/core/providers/root.dart';
import 'package:kai_app/features/room/presentation/providers/room_state.dart';
import 'package:kai_app/features/voice/data/models/stt_response.dart';
import 'package:kai_app/features/voice/data/models/tts_response.dart';
import 'package:kai_app/features/voice/data/models/voice_chat_response.dart';
import 'package:kai_app/features/voice/domain/repositories/voice_repository.dart';
import 'package:kai_app/features/voice/domain/services/audio_player_service.dart';
import 'package:kai_app/features/voice/domain/services/audio_recorder_service.dart';
import 'package:kai_app/features/voice/presentation/providers/voice_notifier.dart';
import 'package:kai_app/features/voice/presentation/providers/voice_state.dart';

class _FakeAudioRecorder implements AudioRecorderService {
  String? _lastPath;
  bool _recording = false;

  @override
  Future<bool> isRecording() async => _recording;

  @override
  Future<void> start(String path) async {
    _lastPath = path;
    _recording = true;
    await File(path).create(recursive: true);
  }

  @override
  Future<String?> stop() async {
    _recording = false;
    return _lastPath;
  }
}

class _FakeAudioPlayer implements AudioPlayerService {
  Uint8List? _lastAudio;
  bool _playing = false;

  @override
  Future<bool> isPlaying() async => _playing;

  @override
  Future<void> playBytes(Uint8List bytes) async {
    _lastAudio = bytes;
    _playing = true;
  }

  @override
  Future<void> stop() async {
    _playing = false;
  }
}

class _FakeVoiceRepository implements VoiceRepository {
  late VoiceChatResponse _nextResponse;

  VoiceChatResponse get nextResponse => _nextResponse;
  set nextResponse(VoiceChatResponse value) => _nextResponse = value;

  @override
  Future<VoiceChatResponse> sendVoiceChat(
    File audio,
    String sessionId,
    String? userId,
    String language,
  ) async {
    return _nextResponse;
  }

  @override
  Future<TtsResponse> synthesizeText(String text, String language) async {
    throw UnimplementedError();
  }

  @override
  Future<SttResponse> transcribeAudio(File audio, String language) async {
    throw UnimplementedError();
  }
}

ProviderContainer _createContainer({
  required _FakeAudioRecorder recorder,
  required _FakeAudioPlayer player,
  required _FakeVoiceRepository repository,
}) {
  return ProviderContainer(
    overrides: [
      audioRecorderServiceProvider.overrideWithValue(recorder),
      audioPlayerServiceProvider.overrideWithValue(player),
      voiceRepositoryProvider.overrideWithValue(repository),
      roomNotifierProvider.overrideWith(
        () => _MockRoomNotifier(const RoomStateData(activeSessionId: 's-1')),
      ),
      userIdProvider.overrideWithValue('u-1'),
    ],
  );
}

class _MockRoomNotifier extends RoomNotifier {
  _MockRoomNotifier(this._initial);
  final RoomStateData _initial;

  @override
  RoomStateData build() => _initial;
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  test('tap down starts recording and transitions to listening', () async {
    final recorder = _FakeAudioRecorder();
    final player = _FakeAudioPlayer();
    final repository = _FakeVoiceRepository();
    final container = _createContainer(
      recorder: recorder,
      player: player,
      repository: repository,
    );
    final notifier = container.read(voiceNotifierProvider.notifier);
    container.listen(voiceNotifierProvider, (_, __) {});

    await notifier.handleTapDown();

    final state = container.read(voiceNotifierProvider);
    expect(
      state.flowState,
      VoiceFlowState.listening,
      reason: 'error: ${state.errorMessage}',
    );
    expect(await recorder.isRecording(), isTrue);

    container.dispose();
  });

  test('tap up sends voice chat, plays audio and returns to idle', () async {
    final recorder = _FakeAudioRecorder();
    final player = _FakeAudioPlayer();
    final repository = _FakeVoiceRepository();
    repository.nextResponse = VoiceChatResponse(
      transcript: 'hello',
      responseText: 'Hi there',
      audio: Uint8List.fromList([1, 2, 3]),
    );

    final container = _createContainer(
      recorder: recorder,
      player: player,
      repository: repository,
    );
    final notifier = container.read(voiceNotifierProvider.notifier);
    container.listen(voiceNotifierProvider, (_, __) {});

    await notifier.handleTapDown();
    await notifier.handleTapUp();
    await pumpEventQueue();

    final state = container.read(voiceNotifierProvider);
    expect(
      state.flowState,
      VoiceFlowState.idle,
      reason: 'error: ${state.errorMessage}',
    );
    expect(state.lastTranscript, 'hello');
    expect(state.lastResponseText, 'Hi there');
    expect(state.transcriptEvents.length, 2);
    expect(player._lastAudio, Uint8List.fromList([1, 2, 3]));

    container.dispose();
  });

  test('ttsFailed flag is surfaced in state', () async {
    final recorder = _FakeAudioRecorder();
    final player = _FakeAudioPlayer();
    final repository = _FakeVoiceRepository();
    repository.nextResponse = VoiceChatResponse(
      transcript: 'hello',
      responseText: 'Hi there',
      audio: Uint8List(0),
      ttsFailed: true,
    );

    final container = _createContainer(
      recorder: recorder,
      player: player,
      repository: repository,
    );
    final notifier = container.read(voiceNotifierProvider.notifier);
    container.listen(voiceNotifierProvider, (_, __) {});

    await notifier.handleTapDown();
    await notifier.handleTapUp();
    await pumpEventQueue();

    expect(container.read(voiceNotifierProvider).ttsFailed, isTrue);

    container.dispose();
  });
}
