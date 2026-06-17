import 'package:flutter_test/flutter_test.dart';
import 'package:hive/hive.dart';
import 'package:hive_test/hive_test.dart';
import 'package:kai_app/core/storage/hive_setup.dart';
import 'package:kai_app/features/memory/data/models/memory_fact.dart';
import 'package:kai_app/features/memory/data/repositories/memory_repository_impl.dart';
import 'package:kai_app/features/memory/data/repositories/mock_memory_repository.dart';
import 'package:kai_app/features/settings/data/models/settings.dart';

void main() {
  group('MockMemoryRepository', () {
    late MockMemoryRepository repo;

    setUp(() {
      repo = MockMemoryRepository();
    });

    test('getMemoryFacts returns 10 seeded facts sorted by date', () async {
      final facts = await repo.getMemoryFacts();
      expect(facts, hasLength(10));
      for (var i = 0; i < facts.length - 1; i++) {
        expect(
          facts[i].createdAt.isAfter(facts[i + 1].createdAt) ||
              facts[i].createdAt.isAtSameMomentAs(facts[i + 1].createdAt),
          isTrue,
        );
      }
    });

    test('saveMemoryFact updates existing fact or adds new', () async {
      final facts = await repo.getMemoryFacts();
      final originalCount = facts.length;

      // Update existing
      final first = facts.first;
      final updated = first.copyWith(text: 'Updated Text');
      await repo.saveMemoryFact(updated);
      expect((await repo.getMemoryFacts()).first.text, 'Updated Text');
      expect((await repo.getMemoryFacts()).length, originalCount);

      // Add new
      final newFact = MemoryFact(
        id: 'fact-new',
        category: 'about',
        text: 'New Fact',
        sourceText: 'explicit',
        createdAt: DateTime.now(),
      );
      await repo.saveMemoryFact(newFact);
      final newFacts = await repo.getMemoryFacts();
      expect(newFacts, hasLength(originalCount + 1));
      expect(newFacts.first.text, 'New Fact');
    });

    test('deleteMemoryFact removes fact', () async {
      final facts = await repo.getMemoryFacts();
      final targetId = facts.first.id;

      await repo.deleteMemoryFact(targetId);
      final newFacts = await repo.getMemoryFacts();
      expect(newFacts.any((f) => f.id == targetId), isFalse);
    });

    test('clearAllMemory deletes all facts', () async {
      await repo.clearAllMemory();
      expect(await repo.getMemoryFacts(), isEmpty);
    });

    test('isMemoryEnabled and setMemoryEnabled toggles global tracking', () async {
      expect(await repo.isMemoryEnabled(), isTrue);
      await repo.setMemoryEnabled(false);
      expect(await repo.isMemoryEnabled(), isFalse);
    });
  });

  group('MemoryRepositoryImpl', () {
    late MemoryRepositoryImpl repo;

    setUp(() async {
      await setUpTestHive();
      if (!Hive.isAdapterRegistered(4)) Hive.registerAdapter(AppThemeModeAdapter());
      if (!Hive.isAdapterRegistered(5)) Hive.registerAdapter(AppSettingsAdapter());
      if (!Hive.isAdapterRegistered(6)) Hive.registerAdapter(MemoryFactAdapter());

      await Hive.openBox<AppSettings>(HiveSetup.settingsBoxName);
      await Hive.openBox<MemoryFact>(HiveSetup.memoryFactsBoxName);

      repo = MemoryRepositoryImpl();
    });

    tearDown(() async {
      await tearDownTestHive();
    });

    test('getMemoryFacts returns empty initially', () async {
      final facts = await repo.getMemoryFacts();
      expect(facts, isEmpty);
    });

    test('saveMemoryFact persists fact to Hive', () async {
      final fact = MemoryFact(
        id: 'fact-real-1',
        category: 'preferences',
        text: 'Любит горы',
        sourceText: 'установлено явно',
        createdAt: DateTime.now(),
      );

      await repo.saveMemoryFact(fact);
      final facts = await repo.getMemoryFacts();
      expect(facts, hasLength(1));
      expect(facts.first.text, 'Любит горы');
      expect(facts.first.id, 'fact-real-1');
    });

    test('deleteMemoryFact removes fact from Hive', () async {
      final fact = MemoryFact(
        id: 'fact-real-1',
        category: 'preferences',
        text: 'Любит горы',
        sourceText: 'установлено явно',
        createdAt: DateTime.now(),
      );

      await repo.saveMemoryFact(fact);
      expect(await repo.getMemoryFacts(), hasLength(1));

      await repo.deleteMemoryFact('fact-real-1');
      expect(await repo.getMemoryFacts(), isEmpty);
    });

    test('clearAllMemory clears Hive box', () async {
      final fact = MemoryFact(
        id: 'fact-real-1',
        category: 'preferences',
        text: 'Любит горы',
        sourceText: 'установлено явно',
        createdAt: DateTime.now(),
      );

      await repo.saveMemoryFact(fact);
      expect(await repo.getMemoryFacts(), hasLength(1));

      await repo.clearAllMemory();
      expect(await repo.getMemoryFacts(), isEmpty);
    });

    test('isMemoryEnabled and setMemoryEnabled toggles global tracking in settings', () async {
      expect(await repo.isMemoryEnabled(), isTrue);

      await repo.setMemoryEnabled(false);
      expect(await repo.isMemoryEnabled(), isFalse);

      final settings = HiveSetup.settings.get(HiveSetup.settingsKey);
      expect(settings?.memoryEnabled, isFalse);
    });
  });
}
