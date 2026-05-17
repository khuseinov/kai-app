enum Environment { dev, staging, prod }

const String _vpsIp = '78.17.13.214';

class EnvConfig {
  static const _env = String.fromEnvironment(
    'ENV',
    defaultValue: 'dev',
  );

  static Environment get current {
    return switch (_env) {
      'prod' => Environment.prod,
      'staging' => Environment.staging,
      _ => Environment.dev,
    };
  }

  /// Base URL routing:
  ///   dev     → local machine Nginx (port 80)
  ///   staging → VPS Nginx (port 80) — IP only, no domain
  ///   prod    → wize.travel (Phase 3, domain not yet purchased)
  ///
  /// IMPORTANT: always point to Nginx (port 80), never direct to kai-core:8000.
  /// Nginx provides: rate limiting, security headers, CORS.
  static String get apiBaseUrl => switch (current) {
        // Since backend is running on VPS, pointing dev to VPS as well.
        Environment.dev => 'http://$_vpsIp:80',
        Environment.staging => 'http://$_vpsIp:80',
        // Phase 3: uncomment when wize.travel is purchased + TLS configured
        // Environment.prod    => 'https://wize.travel',
        Environment.prod => 'http://$_vpsIp:80',
      };

  static Duration get connectTimeout => switch (current) {
        Environment.dev => const Duration(seconds: 60),
        _ => const Duration(seconds: 30),
      };

  static Duration get receiveTimeout => switch (current) {
        Environment.dev => const Duration(seconds: 1800), // KAI-FT CPU timeout
        _ => const Duration(seconds: 300),
      };

  static bool get enableLogging => current != Environment.prod;
}
