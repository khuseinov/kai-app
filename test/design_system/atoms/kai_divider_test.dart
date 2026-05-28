import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:kai_app/design_system/theme/kai_theme.dart';
import 'package:kai_app/design_system/tokens/kai_tokens.dart';
import 'package:kai_app/design_system/atoms/kai_divider.dart';

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
      final container = tester.widget<Container>(
        find.byType(Container).first,
      );
      expect(container.constraints?.maxHeight, 1.0);
    });

    testWidgets('horizontal: uses line color from theme', (tester) async {
      await _pump(tester, const KaiDivider());
      final containers =
          tester.widgetList<Container>(find.byType(Container)).toList();
      final found = containers.any((c) {
        final deco = c.decoration;
        return deco is BoxDecoration && deco.color == KaiColors.light.line;
      });
      expect(found, isTrue, reason: 'Horizontal divider must use theme line color');
    });

    testWidgets('horizontal: color override is applied', (tester) async {
      const testColor = Color(0xFFAA0000);
      await _pump(
        tester,
        const KaiDivider(color: testColor),
      );
      final containers =
          tester.widgetList<Container>(find.byType(Container)).toList();
      final found = containers.any((c) {
        final deco = c.decoration;
        return deco is BoxDecoration && deco.color == testColor;
      });
      expect(found, isTrue, reason: 'Color override must be applied');
    });

    testWidgets('vertical: width is 1px', (tester) async {
      await _pump(
        tester,
        const SizedBox(
          height: 50,
          child: KaiDivider.vertical(),
        ),
      );
      final container = tester.widget<Container>(
        find.byType(Container).first,
      );
      expect(container.constraints?.maxWidth, 1.0);
    });

    testWidgets('vertical: uses line color from theme', (tester) async {
      await _pump(
        tester,
        const SizedBox(
          height: 50,
          child: KaiDivider.vertical(),
        ),
      );
      final containers =
          tester.widgetList<Container>(find.byType(Container)).toList();
      final found = containers.any((c) {
        final deco = c.decoration;
        return deco is BoxDecoration && deco.color == KaiColors.light.line;
      });
      expect(found, isTrue, reason: 'Vertical divider must use theme line color');
    });
  });
}
