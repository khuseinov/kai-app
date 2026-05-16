import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/api/api_client.dart';
import '../../../core/providers/settings_provider.dart';

class SessionSummary {
  final String sessionId;
  final String startedAt;
  final String lastMessageAt;
  final String preview;
  final int messageCount;

  const SessionSummary({
    required this.sessionId,
    required this.startedAt,
    required this.lastMessageAt,
    required this.preview,
    required this.messageCount,
  });

  factory SessionSummary.fromJson(Map<String, dynamic> json) => SessionSummary(
        sessionId: json['session_id'] as String? ?? '',
        startedAt: json['started_at'] as String? ?? '',
        lastMessageAt: json['last_message_at'] as String? ?? '',
        preview: json['preview'] as String? ?? '',
        messageCount: json['message_count'] as int? ?? 0,
      );
}

class HistoryMessage {
  final String role;
  final String content;
  final String timestamp;
  final String? model;
  final int? latencyMs;

  const HistoryMessage({
    required this.role,
    required this.content,
    required this.timestamp,
    this.model,
    this.latencyMs,
  });

  factory HistoryMessage.fromJson(Map<String, dynamic> json) => HistoryMessage(
        role: json['role'] as String? ?? 'user',
        content: json['content'] as String? ?? '',
        timestamp: json['timestamp'] as String? ?? '',
        model: json['model'] as String?,
        latencyMs: json['latency_ms'] as int?,
      );
}

abstract interface class HistoryRemoteSource {
  Future<List<SessionSummary>> listSessions(String userId, {int limit = 50});
  Future<List<HistoryMessage>> getMessages(String sessionId);
}

class DioHistoryRemoteSource implements HistoryRemoteSource {
  final Dio _dio;
  final String _internalToken;

  DioHistoryRemoteSource(this._dio, this._internalToken);

  @override
  Future<List<SessionSummary>> listSessions(String userId,
      {int limit = 50}) async {
    final response = await _dio.get<List<dynamic>>(
      '/sessions',
      queryParameters: {'user_id': userId, 'limit': limit},
      options: Options(headers: {
        if (_internalToken.isNotEmpty) 'X-Internal-Token': _internalToken,
      }),
    );
    final data = response.data ?? [];
    return data
        .whereType<Map<String, dynamic>>()
        .map(SessionSummary.fromJson)
        .toList();
  }

  @override
  Future<List<HistoryMessage>> getMessages(String sessionId) async {
    final response = await _dio.get<List<dynamic>>(
      '/sessions/$sessionId/messages',
      options: Options(headers: {
        if (_internalToken.isNotEmpty) 'X-Internal-Token': _internalToken,
      }),
    );
    final data = response.data ?? [];
    return data
        .whereType<Map<String, dynamic>>()
        .map(HistoryMessage.fromJson)
        .toList();
  }
}

final historyRemoteSourceProvider = Provider<HistoryRemoteSource>((ref) {
  final apiKey = ref.watch(settingsProvider).apiKey ?? '';
  return DioHistoryRemoteSource(ref.watch(dioProvider), apiKey);
});
