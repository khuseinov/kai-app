import 'package:flutter/painting.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:kai_app/design_system/tokens/kai_radius.dart';

void main() {
  group('KaiRadius — new r8/r12 tokens', () {
    test('r8 == 8', () {
      expect(KaiRadius.r8, 8.0);
    });

    test('r12 == 12', () {
      expect(KaiRadius.r12, 12.0);
    });

    test('br8 is BorderRadius.all(Radius.circular(8))', () {
      expect(KaiRadius.br8, const BorderRadius.all(Radius.circular(8)));
    });

    test('br12 is BorderRadius.all(Radius.circular(12))', () {
      expect(KaiRadius.br12, const BorderRadius.all(Radius.circular(12)));
    });

    test('existing tokens are unchanged', () {
      expect(KaiRadius.r1, 6.0);
      expect(KaiRadius.r2, 10.0);
      expect(KaiRadius.r3, 14.0);
      expect(KaiRadius.r4, 20.0);
      expect(KaiRadius.r5, 28.0);
      expect(KaiRadius.pill, 999.0);
    });
  });
}
