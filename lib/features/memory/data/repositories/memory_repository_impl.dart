import 'package:kai_app/core/storage/hive_setup.dart';
import 'package:kai_app/features/memory/data/models/memory_fact.dart';
import 'package:kai_app/features/memory/domain/repositories/memory_repository.dart';
import 'package:kai_app/features/settings/data/models/settings.dart';

class MemoryRepositoryImpl implements MemoryRepository {
  @override
  Future<List<MemoryFact>> getMemoryFacts() async {
    final box = HiveSetup.memoryFacts;
    final all = box.values.toList()
      ..sort((a, b) => b.createdAt.compareTo(a.createdAt));
    return List.unmodifiable(all);
  }

  @override
  Future<void> saveMemoryFact(MemoryFact fact) async {
    await HiveSetup.memoryFacts.put(fact.id, fact);
  }

  @override
  Future<void> deleteMemoryFact(String id) async {
    await HiveSetup.memoryFacts.delete(id);
  }

  @override
  Future<void> clearAllMemory() async {
    await HiveSetup.memoryFacts.clear();
  }

  @override
  Future<bool> isMemoryEnabled() async {
    final settings = HiveSetup.settings.get(HiveSetup.settingsKey);
    return settings?.memoryEnabled ?? true;
  }

  @override
  Future<void> setMemoryEnabled(bool enabled) async {
    final settings = HiveSetup.settings.get(HiveSetup.settingsKey) ?? const AppSettings();
    await HiveSetup.settings.put(
      HiveSetup.settingsKey,
      settings.copyWith(memoryEnabled: enabled),
    );
  }
}
