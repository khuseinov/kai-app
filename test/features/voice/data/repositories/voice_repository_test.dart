import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';

import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:kai_app/features/voice/data/repositories/voice_repository_impl.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';

import 'voice_repository_test.mocks.dart';

@GenerateMocks([Dio])
void main() {
  late MockDio dio;
  late VoiceRepositoryImpl repository;

  setUp(() {
    dio = MockDio();
    repository = VoiceRepositoryImpl(dio: dio, baseUrl: 'http://localhost:8002');
  });

  group('transcribeAudio', () {
    test('posts multipart audio to /voice/stt and returns parsed response',
        () async {
      final audioFile = File('${Directory.systemTemp.path}/test.wav');
      await audioFile.writeAsBytes(Uint8List.fromList([1, 2, 3]));
      addTearDown(audioFile.deleteSync);

      final response = Response<Map<String, dynamic>>(
        requestOptions: RequestOptions(),
        data: <String, dynamic>{
          'text': 'hello world',
          'language': 'en',
          'duration_seconds': 1.2,
          'model': 'large-v3-turbo',
        },
      );

      when(
        dio.post<Map<String, dynamic>>(
          'http://localhost:8002/voice/stt',
          data: anyNamed('data'),
        ),
      ).thenAnswer((_) async => response);

      final result = await repository.transcribeAudio(audioFile, 'en');

      expect(result.text, 'hello world');
      expect(result.language, 'en');
      expect(result.durationSeconds, 1.2);
      expect(result.model, 'large-v3-turbo');

      final captured = verify(
        dio.post<Map<String, dynamic>>(
          'http://localhost:8002/voice/stt',
          data: captureAnyNamed('data'),
        ),
      ).captured.single as FormData;
      expect(
        captured.fields.any((f) => f.key == 'language' && f.value == 'en'),
        isTrue,
      );
      expect(captured.files.any((f) => f.key == 'audio'), isTrue);
    });
  });

  group('synthesizeText', () {
    test('posts JSON to /voice/tts and decodes binary response with headers',
        () async {
      final response = Response<List<int>>(
        requestOptions: RequestOptions(),
        data: Uint8List.fromList([4, 5, 6]),
        headers: Headers.fromMap(<String, List<String>>{
          'X-TTS-Voice': ['en-US-JennyNeural'],
          'X-TTS-Cached': ['true'],
        }),
      );

      when(
        dio.post<List<int>>(
          'http://localhost:8002/voice/tts',
          data: anyNamed('data'),
          options: anyNamed('options'),
        ),
      ).thenAnswer((_) async => response);

      final result = await repository.synthesizeText('Hello', 'en');

      expect(result.audio, Uint8List.fromList([4, 5, 6]));
      expect(result.voice, 'en-US-JennyNeural');
      expect(result.cached, isTrue);
    });
  });

  group('sendVoiceChat', () {
    test('posts multipart audio to /voice/chat and decodes base64 audio',
        () async {
      final audioFile = File('${Directory.systemTemp.path}/test.wav');
      await audioFile.writeAsBytes(Uint8List.fromList([7, 8, 9]));
      addTearDown(audioFile.deleteSync);

      final audioBytes = Uint8List.fromList([10, 11, 12]);
      final response = Response<Map<String, dynamic>>(
        requestOptions: RequestOptions(),
        data: <String, dynamic>{
          'transcript': 'book a flight',
          'response_text': 'I can help with that.',
          'audio': base64Encode(audioBytes),
          'tts_failed': true,
          'tts_voice': 'en-US-JennyNeural',
          'tts_cached': false,
          'language': 'en',
          'correlation_id': 'corr-123',
        },
      );

      when(
        dio.post<Map<String, dynamic>>(
          'http://localhost:8002/voice/chat',
          data: anyNamed('data'),
        ),
      ).thenAnswer((_) async => response);

      final result = await repository.sendVoiceChat(
        audioFile,
        'session-123',
        'user-456',
        'en',
      );

      expect(result.transcript, 'book a flight');
      expect(result.responseText, 'I can help with that.');
      expect(result.audio, audioBytes);
      expect(result.ttsFailed, isTrue);
      expect(result.ttsVoice, 'en-US-JennyNeural');
      expect(result.correlationId, 'corr-123');

      final captured = verify(
        dio.post<Map<String, dynamic>>(
          'http://localhost:8002/voice/chat',
          data: captureAnyNamed('data'),
        ),
      ).captured.single as FormData;
      expect(
        captured.fields
            .any((f) => f.key == 'session_id' && f.value == 'session-123'),
        isTrue,
      );
      expect(
        captured.fields
            .any((f) => f.key == 'user_id' && f.value == 'user-456'),
        isTrue,
      );
      expect(captured.files.any((f) => f.key == 'audio'), isTrue);
    });
  });
}
