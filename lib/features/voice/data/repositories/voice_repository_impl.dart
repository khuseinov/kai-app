import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:kai_app/features/voice/data/models/stt_response.dart';
import 'package:kai_app/features/voice/data/models/tts_request.dart';
import 'package:kai_app/features/voice/data/models/tts_response.dart';
import 'package:kai_app/features/voice/data/models/voice_chat_job_response.dart';
import 'package:kai_app/features/voice/data/models/voice_chat_job_status.dart';
import 'package:kai_app/features/voice/domain/repositories/voice_repository.dart';

/// Dio-backed implementation of [VoiceRepository].
class VoiceRepositoryImpl implements VoiceRepository {
  VoiceRepositoryImpl({
    required Dio dio,
    required String baseUrl,
  })  : _dio = dio,
        _baseUrl = baseUrl;

  final Dio _dio;
  final String _baseUrl;

  @override
  Future<SttResponse> transcribeAudio(String audioPath, String language) async {
    final MultipartFile multipartFile;
    if (kIsWeb) {
      // ponytail: use a fresh, unconfigured Dio instance to avoid custom headers/interceptors failing on browser blob requests
      final response = await Dio().get<List<int>>(
        audioPath,
        options: Options(responseType: ResponseType.bytes),
      );
      multipartFile = MultipartFile.fromBytes(
        response.data!,
        filename: 'audio.webm',
      );
    } else {
      multipartFile = await MultipartFile.fromFile(
        audioPath,
        filename: 'audio.m4a',
      );
    }

    final response = await _dio.post<Map<String, dynamic>>(
      '$_baseUrl/voice/stt',
      data: FormData.fromMap(<String, dynamic>{
        'language': language,
        'audio': multipartFile,
      }),
    );
    return SttResponse.fromJson(response.data!);
  }

  @override
  Future<TtsResponse> synthesizeText(String text, String language) async {
    final response = await _dio.post<List<int>>(
      '$_baseUrl/voice/tts',
      data: TtsRequest(text: text, language: language).toJson(),
      options: Options(
        responseType: ResponseType.bytes,
        contentType: 'application/json',
      ),
    );
    final audio = Uint8List.fromList(response.data!);
    final voice = response.headers.value('X-TTS-Voice') ?? '';
    final cached = (response.headers.value('X-TTS-Cached') ?? 'false') == 'true';
    return TtsResponse(audio: audio, voice: voice, cached: cached);
  }

  @override
  Future<VoiceChatJobResponse> sendVoiceChat(
    String audioPath,
    String sessionId,
    String? userId,
    String language,
  ) async {
    final MultipartFile multipartFile;
    if (kIsWeb) {
      // ponytail: use a fresh, unconfigured Dio instance to avoid custom headers/interceptors failing on browser blob requests
      final response = await Dio().get<List<int>>(
        audioPath,
        options: Options(responseType: ResponseType.bytes),
      );
      multipartFile = MultipartFile.fromBytes(
        response.data!,
        filename: 'audio.webm',
      );
    } else {
      multipartFile = await MultipartFile.fromFile(
        audioPath,
        filename: 'audio.m4a',
      );
    }

    final formMap = <String, dynamic>{
      'session_id': sessionId,
      'language': language,
      'audio': multipartFile,
    };
    if (userId != null && userId.isNotEmpty) {
      formMap['user_id'] = userId;
    }

    final response = await _dio.post<Map<String, dynamic>>(
      '$_baseUrl/voice/chat',
      data: FormData.fromMap(formMap),
    );
    return VoiceChatJobResponse.fromJson(response.data!);
  }

  @override
  Future<VoiceChatJobStatus> getVoiceChatJob(String jobId) async {
    final response = await _dio.get<Map<String, dynamic>>(
      '$_baseUrl/voice/jobs/$jobId',
    );
    return VoiceChatJobStatus.fromJson(response.data!);
  }
}
