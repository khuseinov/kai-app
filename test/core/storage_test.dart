import 'package:flutter_test/flutter_test.dart';
import 'package:hive/hive.dart';
import 'package:hive_test/hive_test.dart';
import 'package:kai_app/core/storage/entities/message.dart';
import 'package:kai_app/core/storage/entities/session.dart';
import 'package:kai_app/core/storage/entities/settings.dart';

void main() {
  setUp(() async {
    await setUpTestHive();
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
  });

  tearDown(() async {
    await tearDownTestHive();
  });

  group('Session box', () {
    test('writes, reads back, deletes', () async {
      final box = await Hive.openBox<Session>('chat_sessions_v1');
      final s = Session(
        id: 's1',
        title: 'Виза для Японии',
        createdAt: DateTime.utc(2026, 5, 27, 9, 30),
        tripId: 'trip-1',
      );

      await box.put(s.id, s);
      final read = box.get('s1');
      expect(read, isNotNull);
      expect(read!.id, 's1');
      expect(read.title, 'Виза для Японии');
      expect(read.createdAt, DateTime.utc(2026, 5, 27, 9, 30));
      expect(read.tripId, 'trip-1');

      await box.delete('s1');
      expect(box.get('s1'), isNull);
    });

    test('nullable tripId persists as null', () async {
      final box = await Hive.openBox<Session>('chat_sessions_v1');
      final s = Session(
        id: 's2',
        title: 'No trip',
        createdAt: DateTime.utc(2026, 5, 27),
      );
      await box.put(s.id, s);
      expect(box.get('s2')!.tripId, isNull);
    });
  });

  group('Message box', () {
    test('writes/reads with role + status enums', () async {
      final box = await Hive.openBox<Message>('messages_v1');
      final m = Message(
        id: 'm1',
        sessionId: 's1',
        role: MessageRole.kai,
        status: MessageStatus.streaming,
        content: 'Привет.',
        createdAt: DateTime.utc(2026, 5, 27, 10, 0),
      );

      await box.put(m.id, m);
      final read = box.get('m1');
      expect(read!.role, MessageRole.kai);
      expect(read.status, MessageStatus.streaming);
      expect(read.content, 'Привет.');
      expect(read.sessionId, 's1');
    });

    test('all 6 statuses survive roundtrip', () async {
      final box = await Hive.openBox<Message>('messages_v1');
      for (final status in MessageStatus.values) {
        final m = Message(
          id: 'm-${status.name}',
          sessionId: 's1',
          role: MessageRole.user,
          status: status,
          content: 'x',
          createdAt: DateTime.utc(2026, 5, 27),
        );
        await box.put(m.id, m);
      }
      for (final status in MessageStatus.values) {
        final read = box.get('m-${status.name}');
        expect(read!.status, status);
      }
    });

    test('all 3 roles survive roundtrip', () async {
      final box = await Hive.openBox<Message>('messages_v1');
      for (final role in MessageRole.values) {
        final m = Message(
          id: 'r-${role.name}',
          sessionId: 's1',
          role: role,
          status: MessageStatus.sent,
          content: 'x',
          createdAt: DateTime.utc(2026, 5, 27),
        );
        await box.put(m.id, m);
      }
      for (final role in MessageRole.values) {
        expect(box.get('r-${role.name}')!.role, role);
      }
    });
  });

  group('Settings box', () {
    test('defaults survive a roundtrip', () async {
      final box = await Hive.openBox<AppSettings>('settings_v1');
      const defaults = AppSettings();
      await box.put('app', defaults);

      final read = box.get('app');
      expect(read, isNotNull);
      expect(read!.themeMode, AppThemeMode.system);
      expect(read.locale, 'ru');
      expect(read.onboarded, isFalse);
    });

    test('mutated values persist', () async {
      final box = await Hive.openBox<AppSettings>('settings_v1');
      const mutated = AppSettings(
        themeMode: AppThemeMode.dark,
        locale: 'en',
        onboarded: true,
      );
      await box.put('app', mutated);

      final read = box.get('app');
      expect(read!.themeMode, AppThemeMode.dark);
      expect(read.locale, 'en');
      expect(read.onboarded, isTrue);
    });
  });
}
