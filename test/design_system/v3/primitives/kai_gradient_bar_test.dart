import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:kai_app/design_system/theme/kai_theme.dart';
import 'package:kai_app/design_system/v3/primitives/kai_gradient_bar.dart';

Future<void> _pump(WidgetTester tester, Widget child) async {
  await tester.pumpWidget(
    ProviderScope(
      child: MaterialApp(
        home: KaiTheme(
          child: Scaffold(body: child),
        ),
      ),
    ),
  );
  await tester.pump();
}

void main() {
  group('v3/KaiGradientBar', () {
    testWidgets('renders with default size (16×4)', (tester) async {
      await _pump(tester, const KaiGradientBar());
      final box = tester.renderObject<RenderBox>(
        find.byType(KaiGradientBar),
      );
      expect(box.size.width, 16.0);
      expect(box.size.height, 4.0);
    });

    testWidgets('renders with custom width and height', (tester) async {
      await _pump(tester, const KaiGradientBar(width: 10, height: 2.5));
      final box = tester.renderObject<RenderBox>(
        find.byType(KaiGradientBar),
      );
      expect(box.size.width, 10.0);
      expect(box.size.height, 2.5);
    });

    testWidgets('pulse=false stays a simple widget without throwing',
        (tester) async {
      await _pump(tester, const KaiGradientBar(pulse: false));
      expect(tester.takeException(), isNull);
      expect(find.byType(KaiGradientBar), findsOneWidget);
    });

    testWidgets('pulse=true animates without throwing after several frames',
        (tester) async {
      await _pump(tester, const KaiGradientBar(pulse: true));
      expect(tester.takeException(), isNull);
      // Pump a handful of frames to exercise the animation loop.
      for (var i = 0; i < 5; i++) {
        await tester.pump(const Duration(milliseconds: 300));
      }
      expect(tester.takeException(), isNull);
      expect(find.byType(KaiGradientBar), findsOneWidget);
    });

    testWidgets('pulse=true widget disposes cleanly', (tester) async {
      await _pump(tester, const KaiGradientBar(pulse: true));
      // Pump a frame, then replace the widget tree — should not throw on dispose.
      await tester.pump(const Duration(milliseconds: 100));
      await tester.pumpWidget(
        const ProviderScope(
          child: MaterialApp(
            home: KaiTheme(
              child: Scaffold(body: SizedBox()),
            ),
          ),
        ),
      );
      expect(tester.takeException(), isNull);
    });

    testWidgets('contains a Container with gradient decoration', (tester) async {
      await _pump(tester, const KaiGradientBar());
      final containers =
          tester.widgetList<Container>(find.byType(Container)).toList();
      final hasGradient = containers.any((c) {
        final deco = c.decoration;
        return deco is BoxDecoration && deco.gradient != null;
      });
      expect(hasGradient, isTrue, reason: 'Should have tide gradient decoration');
    });
  });
}
