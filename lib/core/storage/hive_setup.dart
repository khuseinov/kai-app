import 'package:hive_flutter/hive_flutter.dart';

import 'package:kai_app/features/memory/data/models/memory_fact.dart';
import 'package:kai_app/features/room/data/models/message.dart';
import 'package:kai_app/features/room/data/models/session.dart';
import 'package:kai_app/features/settings/data/models/settings.dart';

/// One-shot Hive bootstrap. Idempotent across hot restarts.
///
/// Box names are versioned (`_v1` suffix) so a future schema bump can land a
/// migration without touching the consumers — open `_v2` alongside `_v1`,
/// run a one-time copy, then drop `_v1`.
class HiveSetup {
  HiveSetup._();

  /// Box of [Session] keyed by session id.
  static const String sessionsBoxName = 'chat_sessions_v1';

  /// Box of [Message] keyed by message id.
  static const String messagesBoxName = 'messages_v1';

  /// Box of [AppSettings] — single value under `settingsKey`.
  static const String settingsBoxName = 'settings_v1';

  /// Box of [MemoryFact] keyed by fact id.
  static const String memoryFactsBoxName = 'memory_facts_v1';

  /// Box for the stable anonymous user id (single value).
  static const String userIdBoxName = 'user_id_v1';

  /// Stable key for the single [AppSettings] record.
  static const String settingsKey = 'app';

  /// Stable key for the single user id record.
  static const String userIdKey = 'uid';

  static bool _initialized = false;

  /// Initialize the Hive engine, register every adapter, and open the
  /// versioned boxes used by the app. Safe to call more than once.
  static Future<void> init() async {
    if (_initialized) return;
    await Hive.initFlutter();
    _registerAdapters();
    await Future.wait<void>(<Future<void>>[
      Hive.openBox<Session>(sessionsBoxName),
      Hive.openBox<Message>(messagesBoxName),
      Hive.openBox<AppSettings>(settingsBoxName),
      Hive.openBox<MemoryFact>(memoryFactsBoxName),
      Hive.openBox<String>(userIdBoxName),
    ]);
    _initialized = true;
  }

  /// Box accessor — sessions.
  static Box<Session> get sessions => Hive.box<Session>(sessionsBoxName);

  /// Box accessor — messages.
  static Box<Message> get messages => Hive.box<Message>(messagesBoxName);

  /// Box accessor — settings.
  static Box<AppSettings> get settings => Hive.box<AppSettings>(settingsBoxName);

  /// Box accessor — memory facts.
  static Box<MemoryFact> get memoryFacts => Hive.box<MemoryFact>(memoryFactsBoxName);

  /// Box accessor — stable user id.
  static Box<String> get userIds => Hive.box<String>(userIdBoxName);

  static void _registerAdapters() {
    if (!Hive.isAdapterRegistered(0)) {
      Hive.registerAdapter(SessionAdapter());
    }
    if (!Hive.isAdapterRegistered(1)) {
      Hive.registerAdapter(MessageAdapter());
    }
    if (!Hive.isAdapterRegistered(2)) {
      Hive.registerAdapter(MessageStatusAdapter());
    }
    if (!Hive.isAdapterRegistered(3)) {
      Hive.registerAdapter(MessageRoleAdapter());
    }
    if (!Hive.isAdapterRegistered(4)) {
      Hive.registerAdapter(AppThemeModeAdapter());
    }
    if (!Hive.isAdapterRegistered(5)) {
      Hive.registerAdapter(AppSettingsAdapter());
    }
    if (!Hive.isAdapterRegistered(6)) {
      Hive.registerAdapter(MemoryFactAdapter());
    }
  }
}
