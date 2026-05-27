/// Abstract session repository.
abstract class SessionRepository {
  /// Returns all sessions, most recent first.
  Future<List<ChatSession>> list();

  /// Creates a new session, optionally associated with a [tripId].
  Future<ChatSession> create({String? tripId});

  /// Deletes the session identified by [id].
  Future<void> delete(String id);
}

/// Lightweight session model used by repositories.
///
/// Phase 5 will replace this with the Hive-backed entity from core/storage/.
final class ChatSession {
  const ChatSession({
    required this.id,
    required this.createdAt,
    this.tripId,
    this.title,
  });

  final String id;
  final DateTime createdAt;
  final String? tripId;
  final String? title;
}
