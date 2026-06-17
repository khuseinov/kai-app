import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:kai_app/design_system/atoms/kai_divider.dart';
import 'package:kai_app/design_system/theme/kai_theme.dart';
import 'package:kai_app/design_system/tokens/kai_tokens.dart';

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
  group('v3/KaiDivider', () {
    testWidgets('horizontal: height is 1px', (tester) async {
      await _pump(
        tester,
        const KaiDivider(),
      );
      final sizeBox = tester.widgetList<SizedBox>(find.byType(SizedBox))
          .firstWhere((s) => s.height == 1.0);
      expect(sizeBox.height, 1.0);
    });

    testWidgets('horizontal: uses line color from theme', (tester) async {
      await _pump(tester, const KaiDivider());
      final coloredBox = tester.widget<ColoredBox>(
        find.descendant(
          of: find.byType(KaiDivider),
          matching: find.byType(ColoredBox),
        ),
      );
      expect(coloredBox.color, KaiColors.light.line);
    });

    testWidgets('horizontal: color override is applied', (tester) async {
      const testColor = Color(0xFFAA0000);
      await _pump(
        tester,
        const KaiDivider(color: testColor),
      );
      final coloredBox = tester.widget<ColoredBox>(
        find.descendant(
          of: find.byType(KaiDivider),
          matching: find.byType(ColoredBox),
        ),
      );
      expect(coloredBox.color, testColor);
    });

    testWidgets('vertical: width is 1px', (tester) async {
      await _pump(
        tester,
        const SizedBox(
          height: 50,
          child: KaiDivider.vertical(),
        ),
      );
      final sizeBox = tester.widgetList<SizedBox>(find.byType(SizedBox))
          .firstWhere((s) => s.width == 1.0);
      expect(sizeBox.width, 1.0);
    });

    testWidgets('vertical: uses line color from theme', (tester) async {
      await _pump(
        tester,
        const SizedBox(
          height: 50,
          child: KaiDivider.vertical(),
        ),
      );
      final coloredBox = tester.widget<ColoredBox>(
        find.descendant(
          of: find.byType(KaiDivider),
          matching: find.byType(ColoredBox),
        ),
      );
      expect(coloredBox.color, KaiColors.light.line);
    });
  });
}
