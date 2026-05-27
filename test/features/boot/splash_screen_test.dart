import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:kai_app/core/providers/root.dart';
import 'package:kai_app/design_system/theme/kai_theme.dart';
import 'package:kai_app/design_system/tokens/kai_tokens.dart';
import 'package:kai_app/features/boot/splash_screen.dart';

Future<void> _pump(
  WidgetTester tester, {
  ThemeMode mode = ThemeMode.light,
}) async {
  await tester.pumpWidget(
    ProviderScope(
      overrides: <Override>[
        themeModeProvider.overrideWith((ref) => mode),
      ],
      child: const MaterialApp(
        home: KaiTheme(child: SplashScreen()),
      ),
    ),
  );
  await tester.pump();
}

void main() {
  group('SplashScreen', () {
    testWidgets('renders wordmark + default tag', (tester) async {
      await _pump(tester);
      expect(find.text('kai'), findsOneWidget);
      expect(find.text('ваш компаньон путешественника'), findsOneWidget);
    });

    testWidgets('custom tag overrides default', (tester) async {
      await tester.pumpWidget(
        const ProviderScope(
          child: MaterialApp(
            home: KaiTheme(
              child: SplashScreen(tag: 'your travel companion'),
            ),
          ),
        ),
      );
      await tester.pump();
      expect(find.text('your travel companion'), findsOneWidget);
      expect(find.text('ваш компаньон путешественника'), findsNothing);
    });

    testWidgets('background uses bg token', (tester) async {
      await _pump(tester);
      final box = tester.widget<ColoredBox>(
        find
            .descendant(
              of: find.byType(SplashScreen),
              matching: find.byType(ColoredBox),
            )
            .first,
      );
      expect(box.color, KaiTokens.light.colors.bg);
    });

    testWidgets('glyph uses gradientCorner', (tester) async {
      await _pump(tester);
      // Find the 64×64 Container with the gradient decoration.
      final containers = tester.widgetList<Container>(
        find.descendant(
          of: find.byType(SplashScreen),
          matching: find.byType(Container),
        ),
      );
      final glyph = containers.firstWhere(
        (c) {
          final dec = c.decoration;
          return dec is BoxDecoration && dec.gradient != null;
        },
      );
      final dec = glyph.decoration! as BoxDecoration;
      expect(dec.gradient, isA<LinearGradient>());
      final gradient = dec.gradient! as LinearGradient;
      // Canon: 135° corner-to-corner, stop-2 @ 0.55
      expect(gradient.stops, [0.0, 0.55, 1.0]);
      expect(gradient.colors, [
        const Color(0xFF1B4FB0),
        const Color(0xFF2BA8C9),
        const Color(0xFFF4B589),
      ]);
      // Radius 20
      final radius = dec.borderRadius! as BorderRadius;
      expect(radius.topLeft, const Radius.circular(20));
    });

    testWidgets('glyph-pulse animation runs', (tester) async {
      await _pump(tester);
      // After 1.2s (half-period) scale should differ from initial 1.0.
      final initialScale = tester
          .widget<ScaleTransition>(find.byType(ScaleTransition))
          .scale
          .value;
      expect(initialScale, 1.0);
      await tester.pump(const Duration(milliseconds: 1200));
      final midScale = tester
          .widget<ScaleTransition>(find.byType(ScaleTransition))
          .scale
          .value;
      // Curves.easeInOut at t=0.5 returns 0.5; tween 1.0→1.06 at 0.5 = 1.03
      expect(midScale, greaterThan(1.0));
      expect(midScale, lessThanOrEqualTo(1.06));
    });

    testWidgets('wordmark uses Manrope 700/26 with -0.025em letter-spacing',
        (tester) async {
      await _pump(tester);
      final wordmark = tester.widget<Text>(find.text('kai'));
      expect(wordmark.style?.fontFamily, 'Manrope');
      expect(wordmark.style?.fontSize, 26);
      expect(wordmark.style?.fontWeight, FontWeight.w700);
      expect(wordmark.style?.letterSpacing, -0.025 * 26);
    });
  });
}
