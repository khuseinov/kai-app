import 'dart:io';
import 'package:hive/hive.dart';

/// Initialize Hive with a fresh temporary directory and open the boxes
/// that LocalStorage requires. Call from `setUpAll` in widget tests that
/// touch `settingsProvider` (and therefore `localStorageProvider`).
///
/// Returns the temp directory so tests can clean it up in `tearDownAll`.
Future<Directory> initHiveForTest() async {
  final tempDir = Directory.systemTemp.createTempSync('kai_app_hive_test_');
  Hive.init(tempDir.path);
  if (!Hive.isBoxOpen('settings')) {
    await Hive.openBox('settings');
  }
  if (!Hive.isBoxOpen('chat_history')) {
    await Hive.openBox('chat_history');
  }
  return tempDir;
}

/// Tear down: close boxes and delete the temp directory.
Future<void> tearDownHiveForTest(Directory tempDir) async {
  await Hive.close();
  if (tempDir.existsSync()) tempDir.deleteSync(recursive: true);
}
