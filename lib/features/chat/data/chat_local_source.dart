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
    await _chatBox.put(message.id, message.toJson());
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
      await saveSession(session.copyWith(title: title, updatedAt: DateTime.now()));
    }
  }
}
