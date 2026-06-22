import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:kai_app/core/logger/app_logger.dart';
import 'package:kai_app/core/providers/root.dart' show EnvConfig;
import 'package:kai_app/core/storage/hive_setup.dart';

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
  } catch (e, st) {
    // No .env asset bundled — that's fine for CI / tests, but log it so
    // release builds with a missing .env are diagnosable.
    AppLogger.w('Failed to load .env asset; using defaults', e, st);
  }
  try {
    await HiveSetup.init();
  } catch (e, st) {
    AppLogger.e('HiveSetup.init failed', e, st);
    rethrow; // crash fast — corrupted persistence is unrecoverable here
  }
  return ProviderContainer();
}
