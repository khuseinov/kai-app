import 'package:flutter/services.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:kai_app/core/storage/secure_storage.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUp(() {
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(
      const MethodChannel('plugins.it_nomads.com/flutter_secure_storage'),
      (MethodCall methodCall) async {
        return null;
      },
    );
  });

  group('SecureStorage', () {
    test('writeApiKey does not throw', () async {
      final storage = SecureStorage(FlutterSecureStorage());
      expect(() => storage.writeApiKey('test-key'), returnsNormally);
    });

    test('deleteApiKey does not throw', () async {
      final storage = SecureStorage(FlutterSecureStorage());
      expect(() => storage.deleteApiKey(), returnsNormally);
    });

    test('readApiKey returns null when nothing stored', () async {
      final storage = SecureStorage(FlutterSecureStorage());
      final result = await storage.readApiKey();
      expect(result, isNull);
    });
  });
}
