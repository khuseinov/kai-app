import 'package:hive/hive.dart';
import '../../../core/models/chat_message.dart';
import '../domain/chat_session.dart';

/// Hive chat_box version. Increment + add migration step here whenever
/// the persisted ChatMessage schema changes.
const int kChatBoxVersion = 2;

/// Reserved key in chat_box for tracking schema version.
const String kChatBoxVersionKey = '__chat_box_version__';

class ChatLocalSource {
  final Box _chatBox;
  final Box _sessionBox;

  ChatLocalSource({required Box chatBox, required Box sessionBox})
      : _chatBox = chatBox,
        _sessionBox = sessionBox;

  /// T25 (Phase 3): one-shot migration for chat_box. Call once at app
  /// init AFTER Hive.openBox('chat_history') and BEFORE any
  /// ChatLocalSource usage.
  ///
  /// v1→v2: drop legacy `thinking` field from all entries. T31 (Phase 2
  /// Fixes) added @JsonKey(includeToJson: false) so NEW writes never
  /// include thinking, but pre-T31 entries may still contain
  /// reasoning_content in Hive — AI-07 violation for legacy data.
  ///
  /// Idempotent: marks chat_box with kChatBoxVersionKey=kChatBoxVersion
  /// after successful migration; subsequent calls are no-ops.
  static Future<void> migrateIfNeeded(Box chatBox) async {
    final currentVersion = chatBox.get(kChatBoxVersionKey) as int? ?? 1;
    if (currentVersion >= kChatBoxVersion) return;

    var migratedCount = 0;
    var skippedCount = 0;
    final keys = chatBox.keys.where((k) => k != kChatBoxVersionKey).toList();
    for (final key in keys) {
      final raw = chatBox.get(key);
      if (raw == null) continue;
      try {
        final map = Map<String, dynamic>.from(raw);
        if (map.containsKey('thinking')) {
          map.remove('thinking');
          await chatBox.put(key, map);
          migratedCount++;
        }
      } catch (e) {
        skippedCount++;
      }
    }
    await chatBox.put(kChatBoxVersionKey, kChatBoxVersion);
    // ignore: avoid_print
    print(
      '[Hive Migration v$currentVersion→$kChatBoxVersion] '
      'cleaned $migratedCount legacy thinking entries '
      '($skippedCount skipped on deserialize errors)',
    );
  }

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
    return _chatBox.keys
        .where((k) => k != kChatBoxVersionKey)
        .map((k) => _chatBox.get(k))
        .where((e) => e != null && e is! int)
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

    // T26 (Phase 3): telemetry — count orphan messages by key format
    // before deletion. Pre-existing bug: filter used snake_case
    // map['session_id'] but toJson writes camelCase 'sessionId', so
    // filter never matched and messages accumulated as orphans.
    // Telemetry logs help measure pre-fix orphan impact on devices.
    var legacyKeyCount = 0;
    var camelKeyCount = 0;
    for (final key in _chatBox.keys) {
      if (key == kChatBoxVersionKey) continue;
      final data = _chatBox.get(key);
      if (data == null || data is int) continue;
      final map = Map<String, dynamic>.from(data);
      if (map['session_id'] != null && map['sessionId'] == null) {
        legacyKeyCount++;
      } else if (map['sessionId'] != null) {
        camelKeyCount++;
      }
    }
    if (legacyKeyCount > 0) {
      // ignore: avoid_print
      print(
        '[deleteSession telemetry] orphan legacy snake_case=$legacyKeyCount camelCase=$camelKeyCount',
      );
    }

    // T26 fix: use camelCase to match chat_message.g.dart toJson output.
    final messageKeys = _chatBox.keys.where((key) {
      if (key == kChatBoxVersionKey) return false;
      final data = _chatBox.get(key);
      if (data == null || data is int) return false;
      final map = Map<String, dynamic>.from(data);
      return map['sessionId'] == sessionId;
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
