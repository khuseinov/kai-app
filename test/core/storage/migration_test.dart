import 'package:flutter_test/flutter_test.dart';

/// Placeholder test that establishes the migration testing pattern.
///
/// When the first real schema bump lands (`chat_sessions_v1` →
/// `chat_sessions_v2`, say), this file will be expanded to:
///
///   1. Open the legacy v1 box with seeded fixture data.
///   2. Run the migration routine (yet to be written, will live under
///      `lib/core/storage/migrations/`).
///   3. Open the v2 box and assert the converted shape.
///
/// Until then, we ship a trivially passing test so the file exists in CI and
/// the directory is reserved.
void main() {
  test('migration scaffold ready (no migrations yet)', () {
    expect(true, isTrue);
  });
}
