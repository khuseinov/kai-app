import 'dart:io';
import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:kai_app/core/providers/root.dart';
import 'package:kai_app/design_system/theme/kai_theme.dart';
import 'package:kai_app/features/room/presentation/providers/room_state.dart';
import 'package:kai_app/features/voice/data/models/stt_response.dart';
import 'package:kai_app/features/voice/data/models/tts_response.dart';
import 'package:kai_app/features/voice/data/models/voice_chat_job_response.dart';
import 'package:kai_app/features/voice/data/models/voice_chat_job_status.dart';
import 'package:kai_app/features/voice/domain/repositories/voice_repository.dart';
import 'package:kai_app/features/voice/domain/services/audio_player_service.dart';
import 'package:kai_app/features/voice/domain/services/audio_recorder_service.dart';
import 'package:kai_app/features/voice/presentation/pages/voice_page.dart';
import 'package:kai_app/l10n/app_localizations.dart';

GoRouter _makeTestRouter() {
  return GoRouter(
    initialLocation: '/voice',
    routes: [
      GoRoute(
        path: '/voice',
        builder: (_, __) => const VoicePage(),
      ),
      GoRoute(
        path: '/room',
        builder: (_, __) => const Scaffold(body: Text('room')),
      ),
    ],
  );
}

class _MockAudioRecorder implements AudioRecorderService {
  String? _path;

  @override
  Future<bool> isRecording() async => _path != null;

  @override
  Future<void> start(String path) async {
    _path = path;
    await File(path).create(recursive: true);
  }

  @override
  Future<String?> stop() async {
    final p = _path;
    _path = null;
    return p;
  }
}

class _MockAudioPlayer implements AudioPlayerService {
  @override
  Future<bool> isPlaying() async => false;

  @override
  Future<void> playBytes(Uint8List bytes) async {}

  @override
  Future<void> stop() async {}
}

class _MockVoiceRepository implements VoiceRepository {
  @override
  Future<TtsResponse> synthesizeText(String text, String language) async {
    throw UnimplementedError();
  }

  @override
  Future<SttResponse> transcribeAudio(String audioPath, String language) async {
    throw UnimplementedError();
  }

  @override
  Future<VoiceChatJobResponse> sendVoiceChat(
    String audioPath,
    String sessionId,
    String? userId,
    String language,
  ) async {
    return VoiceChatJobResponse(
      jobId: 'job-1',
      status: 'pending',
      createdAt: DateTime.now(),
    );
  }

  @override
  Future<VoiceChatJobStatus> getVoiceChatJob(String jobId) async {
    return VoiceChatJobStatus(
      jobId: jobId,
      status: VoiceJobStatus.completed,
      sessionId: 's-1',
      transcript: 'hello',
      responseText: 'Hi there',
      audio: Uint8List.fromList([1, 2, 3]),
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
    );
  }
}

class _MockRoomNotifier extends RoomNotifier {
  @override
  RoomStateData build() => const RoomStateData(activeSessionId: 's-1');
}

Widget _buildVoiceTest() {
  return ProviderScope(
    overrides: [
      envProvider.overrideWithValue(
        const EnvConfig(
          apiBaseUrl: 'http://mock-api',
          voiceGatewayBaseUrl: 'http://mock-voice-gateway',
          useRealChat: false,
        ),
      ),
      themeModeProvider.overrideWith(() => _MockThemeModeNotifier(ThemeMode.light)),
      audioRecorderServiceProvider.overrideWithValue(_MockAudioRecorder()),
      audioPlayerServiceProvider.overrideWithValue(_MockAudioPlayer()),
      voiceRepositoryProvider.overrideWithValue(_MockVoiceRepository()),
      roomNotifierProvider.overrideWith(_MockRoomNotifier.new),
      userIdProvider.overrideWithValue('u-1'),
    ],
    child: MaterialApp.router(
      localizationsDelegates: AppLocalizations.localizationsDelegates,
      supportedLocales: const [Locale('ru'), Locale('en')],
      locale: const Locale('ru'),
      routerConfig: _makeTestRouter(),
      builder: (context, child) =>
          KaiTheme(child: child ?? const SizedBox.shrink()),
    ),
  );
}

void main() {
  testWidgets('VoicePage renders in idle state initially without back arrow',
      (tester) async {
    await tester.pumpWidget(_buildVoiceTest());
    await tester.pump();

    expect(find.text('нажмите и удерживайте, чтобы говорить'), findsOneWidget);
    expect(find.text('SWIPE ↑ · ТРАНСКРИПЦИЯ'), findsOneWidget);
    expect(find.text('Kai ожидает'), findsOneWidget);
    expect(find.byIcon(Icons.arrow_back_ios_new), findsNothing);
  });

  testWidgets('Swipe UP opens transcript view and swipe down returns',
      (tester) async {
    await tester.pumpWidget(_buildVoiceTest());
    await tester.pump();

    await tester.fling(find.byType(VoicePage), const Offset(0, -300), 1000);
    await tester.pump();
    await tester.pump(const Duration(seconds: 1));

    expect(find.text('СВАЙП ↑ · ВЕРНУТЬСЯ К ГОЛОСУ'), findsOneWidget);

    await tester.fling(find.byType(VoicePage), const Offset(0, 300), 1000);
    await tester.pump();
    await tester.pump(const Duration(seconds: 1));
    expect(find.text('Kai ожидает'), findsOneWidget);
  });

  testWidgets('Swipe DOWN in idle voice state exits to /room', (tester) async {
    await tester.pumpWidget(_buildVoiceTest());
    await tester.pump();

    await tester.fling(find.byType(VoicePage), const Offset(0, 300), 1000);
    await tester.pumpAndSettle();

    expect(find.text('room'), findsOneWidget);
    expect(find.byType(VoicePage), findsNothing);
  });
}

class _MockThemeModeNotifier extends ThemeModeNotifier {
  _MockThemeModeNotifier(this._initialMode);
  final ThemeMode _initialMode;
  @override
  ThemeMode build() => _initialMode;
}
