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
        // Assuming we would filter by sessionId in a full implementation.
        // For now, returning all or limiting to session if message has sessionId.
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
}
