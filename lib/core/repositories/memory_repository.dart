import '../storage/entities/memory_fact.dart';

abstract class MemoryRepository {
  /// Retrieves all memory facts.
  Future<List<MemoryFact>> getMemoryFacts();

  /// Saves or updates a memory fact.
  Future<void> saveMemoryFact(MemoryFact fact);

  /// Deletes a memory fact by its ID.
  Future<void> deleteMemoryFact(String id);

  /// Wipes all memory facts (GDPR bulk wipe).
  Future<void> clearAllMemory();

  /// Gets the global memory tracking setting.
  Future<bool> isMemoryEnabled();

  /// Sets the global memory tracking setting.
  Future<void> setMemoryEnabled(bool enabled);
}
