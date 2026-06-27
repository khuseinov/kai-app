import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';

import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:http_parser/http_parser.dart';
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

      final result = await repository.transcribeAudio(audioFile.path, 'en');

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
      final audioPart = captured.files.firstWhere((f) => f.key == 'audio').value;
      expect(audioPart.filename, 'audio.m4a');
      expect(audioPart.contentType?.mimeType, 'audio/mp4');
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
    test('posts multipart audio to /voice/chat and returns job handle',
        () async {
      final audioFile = File('${Directory.systemTemp.path}/test.wav');
      await audioFile.writeAsBytes(Uint8List.fromList([7, 8, 9]));
      addTearDown(audioFile.deleteSync);

      final createdAt = DateTime(2026, 6, 26, 10, 0);
      final response = Response<Map<String, dynamic>>(
        requestOptions: RequestOptions(),
        data: <String, dynamic>{
          'job_id': 'job-123',
          'status': 'pending',
          'created_at': createdAt.toIso8601String(),
        },
      );

      when(
        dio.post<Map<String, dynamic>>(
          'http://localhost:8002/voice/chat',
          data: anyNamed('data'),
        ),
      ).thenAnswer((_) async => response);

      final result = await repository.sendVoiceChat(
        audioFile.path,
        'session-123',
        'user-456',
        'en',
      );

      expect(result.jobId, 'job-123');
      expect(result.status, 'pending');
      expect(result.createdAt, createdAt);

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
      final audioPart = captured.files.firstWhere((f) => f.key == 'audio').value;
      expect(audioPart.filename, 'audio.m4a');
      expect(audioPart.contentType?.mimeType, 'audio/mp4');
    });
  });

  group('getVoiceChatJob', () {
    test('fetches and decodes job status from /voice/jobs/{job_id}',
        () async {
      final audioBytes = Uint8List.fromList([10, 11, 12]);
      final updatedAt = DateTime(2026, 6, 26, 10, 1);
      final response = Response<Map<String, dynamic>>(
        requestOptions: RequestOptions(),
        data: <String, dynamic>{
          'job_id': 'job-123',
          'status': 'completed',
          'session_id': 'session-123',
          'transcript': 'book a flight',
          'response_text': 'I can help with that.',
          'audio': base64Encode(audioBytes),
          'tts_failed': true,
          'tts_voice': 'en-US-JennyNeural',
          'tts_cached': false,
          'language': 'en',
          'correlation_id': 'corr-123',
          'created_at': DateTime(2026, 6, 26, 10, 0).toIso8601String(),
          'updated_at': updatedAt.toIso8601String(),
        },
      );

      when(
        dio.get<Map<String, dynamic>>(
          'http://localhost:8002/voice/jobs/job-123',
        ),
      ).thenAnswer((_) async => response);

      final result = await repository.getVoiceChatJob('job-123');

      expect(result.jobId, 'job-123');
      expect(result.status.name, 'completed');
      expect(result.transcript, 'book a flight');
      expect(result.responseText, 'I can help with that.');
      expect(result.audio, audioBytes);
      expect(result.ttsFailed, isTrue);
      expect(result.ttsVoice, 'en-US-JennyNeural');
      expect(result.correlationId, 'corr-123');
      expect(result.updatedAt, updatedAt);
    });
  });
}
