import 'package:dio/dio.dart';
import 'package:kai_app/core/storage/hive_setup.dart';
import 'package:kai_app/features/auth/domain/repositories/session_repository.dart';
import 'package:kai_app/features/room/data/models/session.dart';
import 'package:uuid/uuid.dart';

/// Hive- & Dio-backed implementation of [SessionRepository].
///
/// Sessions are stored in the `chat_sessions_v1` box keyed by session id.
/// [list] returns sessions sorted most-recent-first, fetching from remote
/// API first and falling back to Hive.
class RealSessionRepository implements SessionRepository {
  RealSessionRepository({
    required Dio dio,
    required String userId,
  })  : _dio = dio,
        _userId = userId;

  factory RealSessionRepository.withDio(Dio dio, {required String userId}) {
    return RealSessionRepository(dio: dio, userId: userId);
  }

  final Dio _dio;
  final String _userId;
  static const _uuid = Uuid();

  @override
  Future<List<ChatSession>> list() async {
    try {
      final response = await _dio.get<List<dynamic>>(
        '/sessions',
        queryParameters: {'user_id': _userId},
      );
      if (response.data != null) {
        final List<ChatSession> list = [];
        for (final item in response.data!) {
          final data = item as Map<String, dynamic>;
          final sessionId = data['session_id'] as String;
          final startedAtStr = data['started_at'] as String? ?? '';
          final createdAt = DateTime.tryParse(startedAtStr) ?? DateTime.now();
          final preview = data['preview'] as String? ?? 'Chat';
          list.add(ChatSession(
            id: sessionId,
            createdAt: createdAt,
            title: preview,
          ));
        }
        return List.unmodifiable(list);
      }
    } catch (_) {
      // Fallback to local Hive
    }

    final box = HiveSetup.sessions;
    final all = box.values.toList()
      ..sort((a, b) => b.createdAt.compareTo(a.createdAt));
    return List.unmodifiable(all.map(_toChatSession).toList());
  }

  @override
  Future<ChatSession> create({String? tripId}) async {
    final now = DateTime.now();
    final session = Session(
      id: _uuid.v4(),
      title: 'Chat',
      createdAt: now,
      tripId: tripId,
    );
    await HiveSetup.sessions.put(session.id, session);
    return _toChatSession(session);
  }

  @override
  Future<void> delete(String id) async {
    await HiveSetup.sessions.delete(id);
  }

  ChatSession _toChatSession(Session s) => ChatSession(
        id: s.id,
        createdAt: s.createdAt,
        tripId: s.tripId,
        title: s.title,
      );
}
