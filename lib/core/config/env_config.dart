import 'package:flutter/foundation.dart' show kIsWeb;

enum Environment { dev, staging, prod }

/// VPS IP address — no domain yet.
/// Phase 3: replace with wize.travel when domain purchased.
const String _vpsIp = '100.127.146.71';

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

  /// Platform-aware local host.
  /// - Web: localhost (browser same-machine)
  /// - Android emulator: 10.0.2.2 (loopback through AVD NAT)
  /// - iOS simulator: 127.0.0.1
  /// - Physical device: use VPS IP directly (_vpsIp)
  static String get _localHost => kIsWeb ? 'localhost' : '10.0.2.2';

  /// Base URL routing:
  ///   dev     → local machine Nginx (port 80)
  ///   staging → VPS Nginx (port 80) — IP only, no domain
  ///   prod    → wize.travel (Phase 3, domain not yet purchased)
  ///
  /// IMPORTANT: always point to Nginx (port 80), never direct to kai-core:8000.
  /// Nginx provides: rate limiting, security headers, CORS.
  static String get apiBaseUrl => switch (current) {
    Environment.dev     => 'http://$_localHost:80',
    Environment.staging => 'http://$_vpsIp:80',
    // Phase 3: uncomment when wize.travel is purchased + TLS configured
    // Environment.prod    => 'https://wize.travel',
    Environment.prod    => 'http://$_vpsIp:80',
  };

  static Duration get connectTimeout => switch (current) {
    Environment.dev => const Duration(seconds: 60),
    _               => const Duration(seconds: 30),
  };

  static Duration get receiveTimeout => switch (current) {
    Environment.dev => const Duration(seconds: 130),
    _               => const Duration(seconds: 90),
  };

  static bool get enableLogging => current != Environment.prod;

  /// VPS base URL for manual override in Settings screen.
  /// User can change this via Settings → API URL field.
  static String get vpsBaseUrl => 'http://$_vpsIp:80';
}
