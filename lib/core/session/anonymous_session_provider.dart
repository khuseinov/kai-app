import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:uuid/uuid.dart';

/// Versioned secure-storage key for the anonymous device session id.
const String kAnonymousSessionStorageKey = 'anonymous_session_id_v1';

/// Wraps [FlutterSecureStorage] so tests can override the underlying storage
/// without poking at the platform channel.
final secureStorageProvider = Provider<FlutterSecureStorage>(
  (_) => const FlutterSecureStorage(),
);

/// One-time UUID generator. Overridable in tests for deterministic ids.
final uuidGeneratorProvider = Provider<String Function()>(
  (_) => () => const Uuid().v4(),
);

/// Device-scoped anonymous session id.
///
/// Read once, cached in [FlutterSecureStorage] under
/// [kAnonymousSessionStorageKey]. Read again on next launch yields the same
/// id. Reset only when the user wipes the device or the app data.
final anonymousSessionProvider = FutureProvider<String>((ref) async {
  final storage = ref.watch(secureStorageProvider);
  final existing = await storage.read(key: kAnonymousSessionStorageKey);
  if (existing != null && existing.isNotEmpty) return existing;
  final id = ref.read(uuidGeneratorProvider)();
  await storage.write(key: kAnonymousSessionStorageKey, value: id);
  return id;
});
