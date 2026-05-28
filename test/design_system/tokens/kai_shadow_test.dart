import 'package:flutter/painting.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:kai_app/design_system/tokens/kai_shadow.dart';

void main() {
  group('KaiShadow', () {
    group('button shadow', () {
      test('is a list with one BoxShadow', () {
        expect(KaiShadow.button, isA<List<BoxShadow>>());
        expect(KaiShadow.button.length, 1);
      });

      test('color is tide-2 sea-glass at alpha 0x2E', () {
        expect(KaiShadow.button.first.color, const Color(0x2E2BA8C9));
      });

      test('blurRadius is 8', () {
        expect(KaiShadow.button.first.blurRadius, 8.0);
      });

      test('offset is Offset(0, 2)', () {
        expect(KaiShadow.button.first.offset, const Offset(0, 2));
      });
    });

    group('glow shadow', () {
      test('is a list with one BoxShadow', () {
        expect(KaiShadow.glow, isA<List<BoxShadow>>());
        expect(KaiShadow.glow.length, 1);
      });

      test('color is tide-2 sea-glass at alpha 0x62', () {
        expect(KaiShadow.glow.first.color, const Color(0x622BA8C9));
      });

      test('blurRadius is 16', () {
        expect(KaiShadow.glow.first.blurRadius, 16.0);
      });

      test('offset is Offset(0, 0)', () {
        expect(KaiShadow.glow.first.offset, const Offset(0, 0));
      });
    });

    group('thumb shadow', () {
      test('is a list with one BoxShadow', () {
        expect(KaiShadow.thumb, isA<List<BoxShadow>>());
        expect(KaiShadow.thumb.length, 1);
      });

      test('color is neutral black at alpha 0x2E (~0.18)', () {
        expect(KaiShadow.thumb.first.color, const Color(0x2E000000));
      });

      test('blurRadius is 3', () {
        expect(KaiShadow.thumb.first.blurRadius, 3.0);
      });

      test('offset is Offset(0, 1)', () {
        expect(KaiShadow.thumb.first.offset, const Offset(0, 1));
      });
    });
  });
}
