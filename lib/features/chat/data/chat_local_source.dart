import 'package:hive/hive.dart';
import '../../../core/models/chat_message.dart';
import '../domain/chat_session.dart';

class ChatLocalSource {
  final Box _chatBox;
  final Box _sessionBox;

  ChatLocalSource({required Box chatBox, required Box sessionBox})
      : _chatBox = chatBox,
        _sessionBox = sessionBox;

  // Messages
  Future<void> saveMessage(ChatMessage message) async {
    // BUG-HIVE-TOOLSOURCE-1 (2026-05-16): json_serializable generated
    // _$ChatMessageImplToJson serializes `sources` as the raw List<ToolSource>
    // instead of List<Map>. Hive then sees `_$ToolSourceImpl` and throws
    // "Cannot write, unknown type: _$ToolSourceImpl". Until build_runner is
    // rerun with explicit_to_json enabled, force-flatten nested Freezed
    // lists here before persisting.
    final raw = Map<String, dynamic>.from(message.toJson());
    raw['sources'] = message.sources.map((s) => s.toJson()).toList();
    await _chatBox.put(message.id, raw);
  }

  List<ChatMessage> getMessagesForSession(String sessionId) {
    return _chatBox.values
        .map((e) => ChatMessage.fromJson(Map<String, dynamic>.from(e)))
        .where((m) => m.sessionId == sessionId)
        .toList();
  }

  // Sessions
  Future<void> saveSession(ChatSession session) async {
    await _sessionBox.put(session.id, session.toJson());
  }

  ChatSession? getSession(String id) {
    final data = _sessionBox.get(id);
    if (data == null) return null;
    return ChatSession.fromJson(Map<String, dynamic>.from(data));
  }

  List<ChatSession> getAllSessions() {
    return _sessionBox.values
        .map((e) => ChatSession.fromJson(Map<String, dynamic>.from(e)))
        .toList()
      ..sort((a, b) => b.updatedAt.compareTo(a.updatedAt));
  }

  Future<void> deleteSession(String sessionId) async {
    await _sessionBox.delete(sessionId);
    final messageKeys = _chatBox.keys.where((key) {
      final data = _chatBox.get(key);
      if (data == null) return false;
      final map = Map<String, dynamic>.from(data);
      return map['session_id'] == sessionId;
    }).toList();
    for (final key in messageKeys) {
      await _chatBox.delete(key);
    }
  }

  Future<void> updateSessionTitle(String sessionId, String title) async {
    final session = getSession(sessionId);
    if (session != null) {
      await saveSession(
          session.copyWith(title: title, updatedAt: DateTime.now()));
    }
  }
}
