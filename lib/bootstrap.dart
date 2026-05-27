import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'core/storage/hive_setup.dart';

/// One-shot init: load .env, prepare Hive, build the root ProviderContainer.
///
/// `.env` is optional — if the asset is missing we fall back to the default
/// env values declared in [EnvConfig.fromDotenv].
///
/// Hive is initialized before the container so any provider that reads from
/// storage during construction sees an open box.
Future<ProviderContainer> bootstrap() async {
  try {
    await dotenv.load();
  } catch (_) {
    // No .env asset bundled — that's fine for CI / tests.
  }
  await HiveSetup.init();
  return ProviderContainer();
}
