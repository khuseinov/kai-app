import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:kai_app/design_system/tokens/kai_tokens.dart';

void main() {
  group('KaiColors', () {
    test('light palette matches design tokens', () {
      expect(KaiColors.light.bg, const Color(0xFFFAFAF9));
      expect(KaiColors.light.surface, const Color(0xFFFFFFFF));
      expect(KaiColors.light.ink1, const Color(0xFF111114));
      expect(KaiColors.light.accent, const Color(0xFF2C5BE5));
      expect(KaiColors.light.positive, const Color(0xFF1B8E4E));
    });

    test('dark palette matches design tokens', () {
      expect(KaiColors.dark.bg, const Color(0xFF0E0E11));
      expect(KaiColors.dark.surface, const Color(0xFF16161A));
      expect(KaiColors.dark.ink1, const Color(0xFFF5F5F2));
      expect(KaiColors.dark.accent, const Color(0xFF5C8EFF));
      expect(KaiColors.dark.negative, const Color(0xFFE66F60));
    });
  });

  group('KaiSpace', () {
    test('matches 4px base scale', () {
      expect(KaiSpace.s1, 4.0);
      expect(KaiSpace.s2, 8.0);
      expect(KaiSpace.s4, 16.0);
      expect(KaiSpace.s7, 32.0);
      expect(KaiSpace.s11, 120.0);
    });
  });

  group('KaiRadius', () {
    test('matches design tokens', () {
      expect(KaiRadius.r1, 6);
      expect(KaiRadius.r2, 10);
      expect(KaiRadius.r3, 14);
      expect(KaiRadius.r4, 20);
      expect(KaiRadius.r5, 28);
      expect(KaiRadius.pill, 999);
    });
  });

  group('KaiMotion', () {
    test('durations match design tokens', () {
      expect(KaiMotion.standard, const Duration(milliseconds: 240));
      expect(KaiMotion.ambient, const Duration(milliseconds: 2600));
      expect(KaiMotion.micro, const Duration(milliseconds: 120));
    });

    test('curves are constructed', () {
      expect(KaiMotion.standardCurve, isA<Cubic>());
      expect(KaiMotion.ambientCurve, isA<Cubic>());
      expect(KaiMotion.linearCurve, Curves.linear);
    });
  });

  group('KaiType', () {
    test('hero is 72/600 Manrope', () {
      final s = KaiType.hero(color: Colors.black);
      expect(s.fontSize, 72);
      expect(s.fontWeight, FontWeight.w600);
      expect(s.fontFamily, 'Manrope');
      expect(s.height, 0.96);
    });

    test('mono uses JetBrainsMono', () {
      final s = KaiType.mono(color: Colors.black);
      expect(s.fontSize, 12);
      expect(s.fontFamily, 'JetBrainsMono');
    });

    test('body is 16/400 with zero letter spacing', () {
      final s = KaiType.body(color: Colors.black);
      expect(s.fontSize, 16);
      expect(s.fontWeight, FontWeight.w400);
      expect(s.letterSpacing, 0);
    });
  });

  group('KaiTide', () {
    test('stops match design tokens', () {
      expect(KaiTide.stop1, const Color(0xFF1B4FB0));
      expect(KaiTide.stop2, const Color(0xFF2BA8C9));
      expect(KaiTide.stop3, const Color(0xFFF4B589));
    });

    test('gradient has three stops at 0/0.52/1', () {
      expect(KaiTide.gradient.colors.length, 3);
      expect(KaiTide.gradient.stops, [0.0, 0.52, 1.0]);
    });

    test('exposes 8 states', () {
      expect(KaiTide.all.length, 8);
      expect(KaiTide.idle.name, 'idle');
      expect(KaiTide.sleep.name, 'sleep');
    });

    test('idle + sleep have HTML breathe (JSON null overridden)', () {
      expect(KaiTide.idle.animation, KaiTideAnimation.breathe);
      expect(KaiTide.idle.durationMs, 5500);
      expect(KaiTide.sleep.animation, KaiTideAnimation.breathe);
      expect(KaiTide.sleep.durationMs, 7000);
    });
  });
}
