import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:logger/logger.dart';

import 'core/storage/hive_setup.dart';

final _bootstrapLogger = Logger();

/// One-shot init: load .env, prepare Hive, build the root ProviderContainer.
///
/// `.env` is optional — if the asset is missing we fall back to the default
/// env values declared in [EnvConfig.fromDotenv].
///
/// Hive is initialized before the container so any provider that reads from
/// storage during construction sees an open box. If Hive init fails (e.g.
/// corrupted box), we log full context and rethrow — corrupted persistence
/// is unrecoverable at this layer, so fail fast and surface the crash rather
/// than leave [HiveSetup]'s internal `_initialized` flag in an inconsistent
/// half-open state.
Future<ProviderContainer> bootstrap() async {
  try {
    await dotenv.load();
  } catch (_) {
    // No .env asset bundled — that's fine for CI / tests.
  }
  try {
    await HiveSetup.init();
  } catch (e, st) {
    _bootstrapLogger.e('HiveSetup.init failed', error: e, stackTrace: st);
    rethrow; // crash fast — corrupted persistence is unrecoverable here
  }
  return ProviderContainer();
}
