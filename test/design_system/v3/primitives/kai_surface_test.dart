import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:kai_app/design_system/theme/kai_theme.dart';
import 'package:kai_app/design_system/tokens/kai_tokens.dart';
import 'package:kai_app/design_system/v3/primitives/kai_surface.dart';

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
  group('v3/KaiSurface', () {
    testWidgets('renders its child', (tester) async {
      await _pump(
        tester,
        KaiSurface(
          color: KaiColors.light.surface,
          child: const Text('hello'),
        ),
      );
      expect(find.text('hello'), findsOneWidget);
    });

    testWidgets('uses provided background color in decoration', (tester) async {
      const testColor = Color(0xFFABCDEF);
      await _pump(
        tester,
        const KaiSurface(
          color: testColor,
          child: SizedBox(),
        ),
      );
      final containers =
          tester.widgetList<Container>(find.byType(Container)).toList();
      final found = containers.any((c) {
        final deco = c.decoration;
        return deco is BoxDecoration && deco.color == testColor;
      });
      expect(found, isTrue, reason: 'Background color should be applied');
    });

    testWidgets('border=false produces no Border in decoration', (tester) async {
      await _pump(
        tester,
        KaiSurface(
          color: KaiColors.light.surface,
          child: const SizedBox(),
        ),
      );
      final containers =
          tester.widgetList<Container>(find.byType(Container)).toList();
      final hasBorder = containers.any((c) {
        final deco = c.decoration;
        if (deco is BoxDecoration && deco.border != null) {
          final border = deco.border;
          // Border with null/transparent sides counts as no visible border.
          if (border is Border) {
            return border.top.width > 0;
          }
        }
        return false;
      });
      expect(hasBorder, isFalse, reason: 'No border should be drawn by default');
    });

    testWidgets('border=true draws a 1px border', (tester) async {
      await _pump(
        tester,
        KaiSurface(
          color: KaiColors.light.surface,
          border: true,
          child: const SizedBox(),
        ),
      );
      final containers =
          tester.widgetList<Container>(find.byType(Container)).toList();
      final hasBorder = containers.any((c) {
        final deco = c.decoration;
        if (deco is BoxDecoration && deco.border != null) {
          final border = deco.border;
          if (border is Border) {
            return border.top.width == 1.0;
          }
        }
        return false;
      });
      expect(hasBorder, isTrue, reason: 'border=true must draw a 1px border');
    });

    testWidgets('radius is applied to decoration when provided', (tester) async {
      const testRadius = BorderRadius.all(Radius.circular(20));
      await _pump(
        tester,
        KaiSurface(
          color: KaiColors.light.surface,
          radius: testRadius,
          child: const SizedBox(),
        ),
      );
      final containers =
          tester.widgetList<Container>(find.byType(Container)).toList();
      final found = containers.any((c) {
        final deco = c.decoration;
        return deco is BoxDecoration && deco.borderRadius == testRadius;
      });
      expect(found, isTrue, reason: 'Radius should be applied to decoration');
    });

    testWidgets('shadow is applied to decoration when provided', (tester) async {
      const shadow = BoxShadow(color: Color(0x2E2BA8C9), blurRadius: 8);
      await _pump(
        tester,
        KaiSurface(
          color: KaiColors.light.surface,
          shadow: const [shadow],
          child: const SizedBox(),
        ),
      );
      final containers =
          tester.widgetList<Container>(find.byType(Container)).toList();
      final found = containers.any((c) {
        final deco = c.decoration;
        return deco is BoxDecoration &&
            deco.boxShadow != null &&
            deco.boxShadow!.isNotEmpty;
      });
      expect(found, isTrue, reason: 'Shadow should be applied to decoration');
    });

    testWidgets('padding wraps child when provided', (tester) async {
      await _pump(
        tester,
        KaiSurface(
          color: KaiColors.light.surface,
          padding: const EdgeInsets.all(16),
          child: const Text('padded'),
        ),
      );
      // Padding widget should appear between Container and child.
      expect(find.byType(Padding), findsWidgets);
      expect(find.text('padded'), findsOneWidget);
    });
  });
}
