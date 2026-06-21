import 'package:dio/dio.dart';
import 'package:kai_app/core/storage/hive_setup.dart';
import 'package:kai_app/features/memory/data/models/memory_fact.dart';
import 'package:kai_app/features/memory/domain/repositories/memory_repository.dart';
import 'package:kai_app/features/settings/data/models/settings.dart';

/// Dio- & Hive-backed implementation of [MemoryRepository].
class MemoryRepositoryImpl implements MemoryRepository {
  MemoryRepositoryImpl({
    required Dio dio,
    required String userId,
  })  : _dio = dio,
        _userId = userId;

  factory MemoryRepositoryImpl.withDio(Dio dio, {required String userId}) {
    return MemoryRepositoryImpl(dio: dio, userId: userId);
  }

  final Dio _dio;
  final String _userId;

  @override
  Future<List<MemoryFact>> getMemoryFacts() async {
    try {
      final response = await _dio.get<List<dynamic>>(
        '/user/$_userId/profiles',
      );
      if (response.data != null) {
        final list = <MemoryFact>[];
        for (final item in response.data!) {
          final data = item as Map<String, dynamic>;
          final id = data['id'] as String? ?? '';
          final category = data['type'] as String? ?? 'preferences';
          final text = data['content'] as String? ?? '';
          final createdAtStr = data['created_at'] as String? ?? '';
          final createdAt = DateTime.tryParse(createdAtStr) ?? DateTime.now();
          final verified = data['verified_preference'] as bool? ?? false;

          list.add(
            MemoryFact(
              id: id,
              category: category,
              text: text,
              sourceText: text,
              createdAt: createdAt,
              isCritical: verified,
            ),
          );
        }
        return List.unmodifiable(list);
      }
    } catch (_) {
      // Fallback to local Hive
    }

    final box = HiveSetup.memoryFacts;
    final all = box.values.toList()
      ..sort((a, b) => b.createdAt.compareTo(a.createdAt));
    return List.unmodifiable(all);
  }

  @override
  Future<void> saveMemoryFact(MemoryFact fact) async {
    // Optimistic local save
    await HiveSetup.memoryFacts.put(fact.id, fact);

    try {
      await _dio.post<dynamic>(
        '/user/$_userId/profiles',
        data: <String, dynamic>{
          'content': fact.text,
          'type': fact.category,
        },
      );
    } catch (_) {
      // If server save fails, we keep it locally
    }
  }

  @override
  Future<void> deleteMemoryFact(String id) async {
    await HiveSetup.memoryFacts.delete(id);
    // Note: backend has no single-fact delete API, so it's local-only.
  }

  @override
  Future<void> clearAllMemory() async {
    await HiveSetup.memoryFacts.clear();
    try {
      await _dio.delete<dynamic>(
        '/user/$_userId/trajectory',
      );
    } catch (_) {
      // Ignore network errors on deletion wipe for offline robustness
    }
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
