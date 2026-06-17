import 'package:kai_app/features/auth/domain/repositories/session_repository.dart';
import 'package:uuid/uuid.dart';

/// In-memory mock session repository, seeded with two sample sessions.
class MockSessionRepository implements SessionRepository {
  MockSessionRepository() : _sessions = [] {
    _sessions.addAll([
      ChatSession(
        id: 'session-seed-1',
        createdAt: DateTime.now().subtract(const Duration(hours: 2)),
        title: 'Tokyo trip planning',
      ),
      ChatSession(
        id: 'session-seed-2',
        createdAt: DateTime.now().subtract(const Duration(days: 1)),
        title: 'Visa requirements',
      ),
    ]);
  }

  final List<ChatSession> _sessions;
  static const _uuid = Uuid();

  @override
  Future<List<ChatSession>> list() async {
    final sorted = _sessions.toList()
      ..sort((a, b) => b.createdAt.compareTo(a.createdAt));
    return List.unmodifiable(sorted);
  }

  @override
  Future<ChatSession> create({String? tripId}) async {
    final session = ChatSession(
      id: _uuid.v4(),
      createdAt: DateTime.now(),
      tripId: tripId,
    );
    _sessions.add(session);
    return session;
  }

  @override
  Future<void> delete(String id) async {
    _sessions.removeWhere((s) => s.id == id);
  }
}
