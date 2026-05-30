import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:kai_app/design_system/theme/kai_theme.dart';
import 'package:kai_app/design_system/tokens/kai_tokens.dart';
import 'package:kai_app/design_system/atoms/kai_badge.dart';

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
  group('v3/KaiBadge', () {
    group('dot', () {
      testWidgets('renders without error', (tester) async {
        await _pump(tester, const KaiBadge.dot());
        expect(find.byType(KaiBadge), findsOneWidget);
      });

      testWidgets('outermost sizing: outer ring is 10px (6px dot + 2px ring * 2)',
          (tester) async {
        await _pump(tester, const KaiBadge.dot());
        // The outer Container (surface ring) must be 10×10.
        final containers =
            tester.widgetList<Container>(find.byType(Container)).toList();
        final ringContainer = containers.firstWhere(
          (c) =>
              c.constraints?.maxWidth == 10.0 &&
              c.constraints?.maxHeight == 10.0,
          orElse: () => throw TestFailure(
            'Expected a 10×10 container for the dot ring; found: '
            '${containers.map((c) => '${c.constraints?.maxWidth}x${c.constraints?.maxHeight}').join(', ')}',
          ),
        );
        expect(ringContainer, isNotNull);
      });

      testWidgets('inner dot is 6px and uses accent color', (tester) async {
        await _pump(tester, const KaiBadge.dot());
        final containers =
            tester.widgetList<Container>(find.byType(Container)).toList();
        final dotContainer = containers.firstWhere(
          (c) {
            if (c.constraints?.maxWidth != 6.0) return false;
            final deco = c.decoration;
            return deco is BoxDecoration &&
                deco.color == KaiColors.light.accent;
          },
          orElse: () => throw TestFailure(
            'Expected a 6×6 accent-colored dot container.',
          ),
        );
        expect(dotContainer, isNotNull);
      });

      testWidgets('outer ring uses surface color', (tester) async {
        await _pump(tester, const KaiBadge.dot());
        final containers =
            tester.widgetList<Container>(find.byType(Container)).toList();
        final ringContainer = containers.firstWhere(
          (c) {
            if (c.constraints?.maxWidth != 10.0) return false;
            final deco = c.decoration;
            return deco is BoxDecoration &&
                deco.color == KaiColors.light.surface;
          },
          orElse: () => throw TestFailure(
            'Expected a 10×10 surface-colored ring container.',
          ),
        );
        expect(ringContainer, isNotNull);
      });

      testWidgets('dot color override is applied', (tester) async {
        const testColor = Color(0xFFFF6600);
        await _pump(tester, const KaiBadge.dot(color: testColor));
        final containers =
            tester.widgetList<Container>(find.byType(Container)).toList();
        final dotContainer = containers.firstWhere(
          (c) {
            if (c.constraints?.maxWidth != 6.0) return false;
            final deco = c.decoration;
            return deco is BoxDecoration && deco.color == testColor;
          },
          orElse: () => throw TestFailure(
            'Expected custom color on dot container.',
          ),
        );
        expect(dotContainer, isNotNull);
      });

      testWidgets('positive tone maps to positive color', (tester) async {
        await _pump(tester, const KaiBadge.dot(tone: KaiBadgeTone.positive));
        final containers =
            tester.widgetList<Container>(find.byType(Container)).toList();
        final found = containers.any((c) {
          if (c.constraints?.maxWidth != 6.0) return false;
          final deco = c.decoration;
          return deco is BoxDecoration && deco.color == KaiColors.light.positive;
        });
        expect(found, isTrue, reason: 'positive tone must use positive color');
      });

      testWidgets('warning tone maps to warning color', (tester) async {
        await _pump(tester, const KaiBadge.dot(tone: KaiBadgeTone.warning));
        final containers =
            tester.widgetList<Container>(find.byType(Container)).toList();
        final found = containers.any((c) {
          if (c.constraints?.maxWidth != 6.0) return false;
          final deco = c.decoration;
          return deco is BoxDecoration && deco.color == KaiColors.light.warning;
        });
        expect(found, isTrue, reason: 'warning tone must use warning color');
      });

      testWidgets('negative tone maps to negative color', (tester) async {
        await _pump(tester, const KaiBadge.dot(tone: KaiBadgeTone.negative));
        final containers =
            tester.widgetList<Container>(find.byType(Container)).toList();
        final found = containers.any((c) {
          if (c.constraints?.maxWidth != 6.0) return false;
          final deco = c.decoration;
          return deco is BoxDecoration && deco.color == KaiColors.light.negative;
        });
        expect(found, isTrue, reason: 'negative tone must use negative color');
      });

      testWidgets('explicit color overrides tone', (tester) async {
        const customColor = Color(0xFFAB1234);
        await _pump(tester,
            const KaiBadge.dot(tone: KaiBadgeTone.warning, color: customColor));
        final containers =
            tester.widgetList<Container>(find.byType(Container)).toList();
        final found = containers.any((c) {
          if (c.constraints?.maxWidth != 6.0) return false;
          final deco = c.decoration;
          return deco is BoxDecoration && deco.color == customColor;
        });
        expect(found, isTrue, reason: 'explicit color must override tone');
      });

      testWidgets('stays 10×10 in a wide parent (no expansion)', (tester) async {
        await _pump(
          tester,
          const SizedBox(width: 400, child: Center(child: KaiBadge.dot())),
        );
        expect(tester.getSize(find.byType(KaiBadge)), const Size(10, 10));
      });
    });

    group('tide', () {
      testWidgets('renders without error', (tester) async {
        await _pump(tester, const KaiBadge.tide());
        expect(find.byType(KaiBadge), findsOneWidget);
      });

      testWidgets('inner dot has gradientCorner decoration', (tester) async {
        await _pump(tester, const KaiBadge.tide());
        final containers =
            tester.widgetList<Container>(find.byType(Container)).toList();
        final found = containers.any((c) {
          final deco = c.decoration;
          return deco is BoxDecoration &&
              deco.gradient == KaiTide.gradientCorner &&
              deco.shape == BoxShape.circle;
        });
        expect(found, isTrue,
            reason: 'tide dot must use KaiTide.gradientCorner gradient');
      });

      testWidgets('outer ring is 12px', (tester) async {
        await _pump(tester, const KaiBadge.tide());
        final containers =
            tester.widgetList<Container>(find.byType(Container)).toList();
        final found = containers.any(
          (c) =>
              c.constraints?.maxWidth == 12.0 &&
              c.constraints?.maxHeight == 12.0,
        );
        expect(found, isTrue, reason: 'tide dot outer ring must be 12x12px');
      });

      testWidgets('inner dot is 8px', (tester) async {
        await _pump(tester, const KaiBadge.tide());
        final containers =
            tester.widgetList<Container>(find.byType(Container)).toList();
        final found = containers.any(
          (c) =>
              c.constraints?.maxWidth == 8.0 &&
              c.constraints?.maxHeight == 8.0,
        );
        expect(found, isTrue, reason: 'tide dot inner circle must be 8x8px');
      });
    });

    group('count', () {
      testWidgets('renders the count number as text', (tester) async {
        await _pump(tester, const KaiBadge.count(5));
        expect(find.text('5'), findsOneWidget);
      });

      testWidgets('renders two-digit count', (tester) async {
        await _pump(tester, const KaiBadge.count(42));
        expect(find.text('42'), findsOneWidget);
      });

      testWidgets('caps display at 99+ for counts > 99', (tester) async {
        await _pump(tester, const KaiBadge.count(100));
        expect(find.text('99+'), findsOneWidget);
        expect(find.text('100'), findsNothing);
      });

      testWidgets('caps display at 99+ for count exactly 100', (tester) async {
        await _pump(tester, const KaiBadge.count(100));
        expect(find.text('99+'), findsOneWidget);
      });

      testWidgets('uses accent background color', (tester) async {
        await _pump(tester, const KaiBadge.count(3));
        final containers =
            tester.widgetList<Container>(find.byType(Container)).toList();
        final found = containers.any((c) {
          final deco = c.decoration;
          return deco is BoxDecoration &&
              deco.color == KaiColors.light.accent;
        });
        expect(found, isTrue, reason: 'count badge must use accent background');
      });

      testWidgets('minimum height is 16px', (tester) async {
        await _pump(tester, const KaiBadge.count(1));
        final containers =
            tester.widgetList<Container>(find.byType(Container)).toList();
        final found = containers.any((c) {
          final constraints = c.constraints;
          return constraints != null && constraints.minHeight >= 16.0;
        });
        expect(found, isTrue, reason: 'count badge must have minHeight >= 16');
      });

      // R1: the count badge used a min-only BoxConstraints + alignment:center,
      // which made the Container greedy and balloon to the parent width in the
      // Storybook. It must hug its content instead.
      testWidgets('hugs content — does NOT expand to fill parent width',
          (tester) async {
        await _pump(
          tester,
          const SizedBox(width: 400, child: Center(child: KaiBadge.count(5))),
        );
        final w = tester.getSize(find.byType(KaiBadge)).width;
        expect(w, lessThan(40),
            reason: 'count badge must hug (~16px), not fill parent width');
        expect(w, greaterThanOrEqualTo(16));
      });
    });
  });
}
