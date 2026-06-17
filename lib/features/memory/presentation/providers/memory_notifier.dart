import 'package:kai_app/core/providers/root.dart';
import 'package:kai_app/features/memory/data/models/memory_fact.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'memory_notifier.g.dart';

@Riverpod(keepAlive: true)
class MemoryFactsNotifier extends _$MemoryFactsNotifier {
  @override
  List<MemoryFact> build() {
    _load();
    return const [];
  }

  Future<void> _load() async {
    final repo = ref.read(memoryRepositoryProvider);
    state = await repo.getMemoryFacts();
  }

  Future<void> addFact(MemoryFact fact) async {
    final repo = ref.read(memoryRepositoryProvider);
    await repo.saveMemoryFact(fact);
    await _load();
  }

  Future<void> deleteFact(String id) async {
    final repo = ref.read(memoryRepositoryProvider);
    await repo.deleteMemoryFact(id);
    await _load();
  }

  Future<void> clearAll() async {
    final repo = ref.read(memoryRepositoryProvider);
    await repo.clearAllMemory();
    await _load();
  }
}

@Riverpod(keepAlive: true)
class MemoryEnabledNotifier extends _$MemoryEnabledNotifier {
  @override
  bool build() {
    _load();
    return true;
  }

  Future<void> _load() async {
    final repo = ref.read(memoryRepositoryProvider);
    state = await repo.isMemoryEnabled();
  }

  Future<void> toggle(bool enabled) async {
    final repo = ref.read(memoryRepositoryProvider);
    await repo.setMemoryEnabled(enabled);
    state = enabled;
  }
}
