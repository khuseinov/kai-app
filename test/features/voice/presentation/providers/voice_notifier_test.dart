import 'dart:io';
import 'dart:typed_data';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:kai_app/core/providers/root.dart';
import 'package:kai_app/features/room/presentation/providers/room_state.dart';
import 'package:kai_app/features/voice/data/models/stt_response.dart';
import 'package:kai_app/features/voice/data/models/tts_response.dart';
import 'package:kai_app/features/voice/data/models/voice_chat_job_response.dart';
import 'package:kai_app/features/voice/data/models/voice_chat_job_status.dart';
import 'package:kai_app/features/voice/domain/repositories/voice_repository.dart';
import 'package:kai_app/features/voice/domain/services/audio_player_service.dart';
import 'package:kai_app/features/voice/domain/services/audio_recorder_service.dart';
import 'package:kai_app/features/voice/presentation/providers/voice_notifier.dart';
import 'package:kai_app/features/voice/presentation/providers/voice_state.dart';

Uint8List _validM4aBytes() {
  final ftyp = Uint8List(20)
    ..buffer.asByteData().setUint32(0, 20, Endian.big);
  ftyp.setRange(4, 8, 'ftyp'.codeUnits);
  ftyp.setRange(8, 12, 'M4A '.codeUnits);
  // minor version + compatible brands left as zeros.

  final moovPayload = Uint8List(8);
  final moov = Uint8List(16 + moovPayload.length)
    ..buffer.asByteData().setUint32(0, 16 + moovPayload.length, Endian.big);
  moov.setRange(4, 8, 'moov'.codeUnits);
  moov.setRange(16, 16 + moovPayload.length, moovPayload);

  final builder = BytesBuilder()
    ..add(ftyp)
    ..add(moov);
  return builder.toBytes();
}

class _FakeAudioRecorder implements AudioRecorderService {
  String? _lastPath;
  bool _recording = false;

  @override
  Future<bool> isRecording() async => _recording;

  @override
  Future<void> start(String path) async {
    _lastPath = path;
    _recording = true;
    final file = await File(path).create(recursive: true);
    await file.writeAsBytes(_validM4aBytes());
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
  VoiceChatJobResponse _nextJobResponse = VoiceChatJobResponse(
    jobId: 'job-1',
    status: 'pending',
    createdAt: DateTime.now(),
  );
  VoiceChatJobStatus? _nextJobStatus;

  VoiceChatJobResponse get nextJobResponse => _nextJobResponse;
  set nextJobResponse(VoiceChatJobResponse value) => _nextJobResponse = value;

  VoiceChatJobStatus? get nextJobStatus => _nextJobStatus;
  set nextJobStatus(VoiceChatJobStatus? value) => _nextJobStatus = value;

  @override
  Future<VoiceChatJobResponse> sendVoiceChat(
    String audioPath,
    String sessionId,
    String? userId,
    String language,
  ) async {
    return _nextJobResponse;
  }

  @override
  Future<VoiceChatJobStatus> getVoiceChatJob(String jobId) async {
    return _nextJobStatus!;
  }

  @override
  Future<TtsResponse> synthesizeText(String text, String language) async {
    throw UnimplementedError();
  }

  @override
  Future<SttResponse> transcribeAudio(String audioPath, String language) async {
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
      envProvider.overrideWithValue(
        const EnvConfig(
          apiBaseUrl: 'http://mock-api',
          voiceGatewayBaseUrl: 'http://mock-voice-gateway',
          useRealChat: false,
        ),
      ),
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

VoiceChatJobStatus _completedStatus({
  String transcript = 'hello',
  String responseText = 'Hi there',
  Uint8List? audio,
  bool ttsFailed = false,
}) {
  final now = DateTime.now();
  return VoiceChatJobStatus(
    jobId: 'job-1',
    status: VoiceJobStatus.completed,
    sessionId: 's-1',
    transcript: transcript,
    responseText: responseText,
    audio: audio,
    ttsFailed: ttsFailed,
    ttsVoice: 'en-US-JennyNeural',
    ttsCached: false,
    language: 'en',
    correlationId: 'corr-1',
    createdAt: now,
    updatedAt: now,
  );
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
    repository.nextJobStatus = _completedStatus(
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
    repository.nextJobStatus = _completedStatus(
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

  test('failed job surfaces error message', () async {
    final recorder = _FakeAudioRecorder();
    final player = _FakeAudioPlayer();
    final repository = _FakeVoiceRepository();
    final now = DateTime.now();
    repository.nextJobStatus = VoiceChatJobStatus(
      jobId: 'job-1',
      status: VoiceJobStatus.failed,
      sessionId: 's-1',
      error: 'ASR down',
      createdAt: now,
      updatedAt: now,
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
    expect(state.flowState, VoiceFlowState.idle);
    expect(state.errorMessage, 'ASR down');

    container.dispose();
  });
}
