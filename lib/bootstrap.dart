import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// One-shot init: load .env, build the root ProviderContainer.
///
/// `.env` is optional — if the asset is missing we fall back to the default
/// env values declared in [EnvConfig.fromDotenv].
Future<ProviderContainer> bootstrap() async {
  try {
    await dotenv.load();
  } catch (_) {
    // No .env asset bundled — that's fine for CI / tests.
  }
  return ProviderContainer();
}
