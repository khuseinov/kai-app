import 'package:flutter_test/flutter_test.dart';
import 'package:kai_app/core/repositories/mock_session_repository.dart';
import 'package:kai_app/core/repositories/session_repository.dart';

void main() {
  group('MockSessionRepository', () {
    late MockSessionRepository repo;

    setUp(() => repo = MockSessionRepository());

    test('list() returns seeded sessions most-recent first', () async {
      final sessions = await repo.list();
      expect(sessions.length, 2);
      expect(
        sessions.first.createdAt.isAfter(sessions.last.createdAt),
        isTrue,
      );
    });

    test('create() adds session and returns it', () async {
      final created = await repo.create();
      expect(created.id, isNotEmpty);
      expect(created.tripId, isNull);

      final all = await repo.list();
      expect(all.any((s) => s.id == created.id), isTrue);
    });

    test('create() with tripId stores tripId', () async {
      final created = await repo.create(tripId: 'trip-42');
      expect(created.tripId, 'trip-42');
    });

    test('delete() removes session by id', () async {
      final before = await repo.list();
      final targetId = before.last.id;

      await repo.delete(targetId);

      final after = await repo.list();
      expect(after.any((s) => s.id == targetId), isFalse);
      expect(after.length, before.length - 1);
    });

    test('delete() is a no-op for unknown id', () async {
      final before = await repo.list();
      await repo.delete('nonexistent-id');
      final after = await repo.list();
      expect(after.length, before.length);
    });

    test('list() returns unmodifiable view', () async {
      final sessions = await repo.list();
      expect(() => (sessions as dynamic).add(null), throwsA(anything));
    });

    test('implements SessionRepository', () {
      expect(repo, isA<SessionRepository>());
    });
  });
}
