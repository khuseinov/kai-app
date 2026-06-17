import 'package:kai_app/core/storage/hive_setup.dart';
import 'package:kai_app/features/auth/domain/repositories/session_repository.dart';
import 'package:kai_app/features/room/data/models/session.dart';
import 'package:uuid/uuid.dart';

/// Hive-backed implementation of [SessionRepository].
///
/// Sessions are stored in the `chat_sessions_v1` box keyed by session id.
/// [list] returns sessions sorted most-recent-first.
class RealSessionRepository implements SessionRepository {
  static const _uuid = Uuid();

  @override
  Future<List<ChatSession>> list() async {
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
