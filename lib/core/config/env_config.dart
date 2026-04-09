enum Environment { dev, staging, prod }

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

  static String get apiBaseUrl => switch (current) {
    Environment.dev => 'http://10.0.2.2:8000',
    Environment.staging => 'http://10.0.2.2:8000',
    Environment.prod => 'https://api.wize.travel',
  };

  static Duration get connectTimeout => switch (current) {
    Environment.dev => const Duration(seconds: 60),
    _ => const Duration(seconds: 30),
  };

  static Duration get receiveTimeout => switch (current) {
    Environment.dev => const Duration(seconds: 130),
    _ => const Duration(seconds: 90),
  };

  static bool get enableLogging => current != Environment.prod;
}
