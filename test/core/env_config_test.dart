import 'package:flutter_test/flutter_test.dart';
import 'package:kai_app/core/providers/root.dart';

void main() {
  group('EnvConfig', () {
    test('diagnosticsEnabled is true in non-release builds', () {
      // Unit tests run in debug mode, so diagnostics should always be enabled.
      expect(EnvConfig.diagnosticsEnabled, isTrue);
    });

    test('reports empty/missing HF_TOKEN as empty', () {
      const config = EnvConfig(apiBaseUrl: 'https://example.com');

      expect(config.hfTokenProvided, isFalse);
      expect(config.hfToken, isNull);
    });

    test('reports a non-empty HF_TOKEN as provided', () {
      const config = EnvConfig(
        apiBaseUrl: 'https://example.com',
        hfToken: 'hf_secret_token',
        hfTokenProvided: true,
      );

      expect(config.hfTokenProvided, isTrue);
      expect(config.hfToken, 'hf_secret_token');
    });

    test('fromDotenv does not fall back to a hardcoded HF_TOKEN', () {
      final config = EnvConfig.fromDotenv();

      expect(config.hfTokenProvided, isFalse);
      expect(config.hfToken, isNull);
    });
  });
}
