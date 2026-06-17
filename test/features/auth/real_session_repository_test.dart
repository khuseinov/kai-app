import 'package:flutter_test/flutter_test.dart';
import 'package:hive/hive.dart';
import 'package:hive_test/hive_test.dart';
import 'package:kai_app/core/storage/hive_setup.dart';
import 'package:kai_app/features/auth/data/repositories/session_repository_impl.dart';
import 'package:kai_app/features/room/data/models/message.dart';
import 'package:kai_app/features/room/data/models/session.dart';
import 'package:kai_app/features/settings/data/models/settings.dart';

void main() {
  late RealSessionRepository repo;

  setUp(() async {
    await setUpTestHive();
    if (!Hive.isAdapterRegistered(0)) Hive.registerAdapter(SessionAdapter());
    if (!Hive.isAdapterRegistered(1)) Hive.registerAdapter(MessageAdapter());
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
    await Hive.openBox<Session>(HiveSetup.sessionsBoxName);
    repo = RealSessionRepository();
  });

  tearDown(() async {
    await tearDownTestHive();
  });

  test('list returns empty initially', () async {
    final sessions = await repo.list();
    expect(sessions, isEmpty);
  });

  test('create adds session to box', () async {
    final session = await repo.create();
    expect(session.id, isNotEmpty);
    expect(session.title, 'Chat');
    expect(session.tripId, isNull);

    final sessions = await repo.list();
    expect(sessions, hasLength(1));
    expect(sessions.first.id, session.id);
  });

  test('list returns most recent first', () async {
    final s1 = await repo.create();
    // Small delay to ensure distinct createdAt timestamps
    await Future<void>.delayed(const Duration(milliseconds: 5));
    final s2 = await repo.create();

    final sessions = await repo.list();
    expect(sessions, hasLength(2));
    // s2 was created more recently — should be first
    expect(sessions.first.id, s2.id);
    expect(sessions.last.id, s1.id);
  });

  test('delete removes session', () async {
    final session = await repo.create();
    expect(await repo.list(), hasLength(1));

    await repo.delete(session.id);
    expect(await repo.list(), isEmpty);
  });

  test('list returns unmodifiable list', () async {
    final s = await repo.create();
    final sessions = await repo.list();
    expect(
      () => sessions.add(s),
      throwsUnsupportedError,
    );
  });

  test('create with tripId persists tripId', () async {
    final session = await repo.create(tripId: 'trip-42');
    expect(session.tripId, 'trip-42');

    final sessions = await repo.list();
    expect(sessions.first.tripId, 'trip-42');
  });

  test('delete non-existent id does not throw', () async {
    await expectLater(repo.delete('ghost-id'), completes);
  });
}
