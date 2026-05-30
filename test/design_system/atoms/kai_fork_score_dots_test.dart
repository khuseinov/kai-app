import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:kai_app/design_system/atoms/kai_fork_score_dots.dart';
import 'package:kai_app/design_system/tokens/kai_tokens.dart';

import '../../test_helpers.dart';

// Canon: filled dots use tide-2 (#2BA8C9 = KaiTide.stop2), not positive green.
const _fill = KaiTide.stop2;

List<Container> _circleDots(WidgetTester tester) => tester
    .widgetList<Container>(find.byType(Container))
    .where((c) {
      final deco = c.decoration;
      return deco is BoxDecoration && deco.shape == BoxShape.circle;
    })
    .toList();

int _dotsWithColor(WidgetTester tester, Color color) => _circleDots(tester)
    .where((c) => (c.decoration as BoxDecoration).color == color)
    .length;

void main() {
  group('v3/KaiForkScoreDots', () {
    group('score=3, max=5 (default)', () {
      testWidgets('renders exactly 5 dots', (tester) async {
        await tester.pumpWidget(buildTestWidget(const KaiForkScoreDots(score: 3)));
        expect(_circleDots(tester).length, 5);
      });

      testWidgets('3 filled dots use tide-2 (canon, not positive)', (tester) async {
        await tester.pumpWidget(buildTestWidget(const KaiForkScoreDots(score: 3)));
        expect(_dotsWithColor(tester, _fill), 3);
        // explicitly NOT positive green
        expect(_dotsWithColor(tester, KaiColors.light.positive), 0);
      });

      testWidgets('2 empty dots use surface3 (light)', (tester) async {
        await tester.pumpWidget(buildTestWidget(const KaiForkScoreDots(score: 3)));
        expect(_dotsWithColor(tester, KaiColors.light.surface3), 2);
      });
    });

    group('edge cases', () {
      testWidgets('score=0 — all 5 empty (surface3), 0 filled', (tester) async {
        await tester.pumpWidget(buildTestWidget(const KaiForkScoreDots(score: 0)));
        expect(_dotsWithColor(tester, KaiColors.light.surface3), 5);
        expect(_dotsWithColor(tester, _fill), 0);
      });

      testWidgets('score=5 — all 5 filled, 0 empty', (tester) async {
        await tester.pumpWidget(buildTestWidget(const KaiForkScoreDots(score: 5)));
        expect(_dotsWithColor(tester, _fill), 5);
        expect(_dotsWithColor(tester, KaiColors.light.surface3), 0);
      });

      testWidgets('score>max clamps to max filled', (tester) async {
        await tester.pumpWidget(buildTestWidget(const KaiForkScoreDots(score: 10)));
        expect(_circleDots(tester).length, 5);
        expect(_dotsWithColor(tester, _fill), 5);
      });

      testWidgets('max=3, score=2 — 2 filled, 1 empty', (tester) async {
        await tester.pumpWidget(
          buildTestWidget(const KaiForkScoreDots(score: 2, max: 3)));
        expect(_circleDots(tester).length, 3);
        expect(_dotsWithColor(tester, _fill), 2);
        expect(_dotsWithColor(tester, KaiColors.light.surface3), 1);
      });
    });

    testWidgets('custom fillColor overrides tide-2 default', (tester) async {
      const custom = Color(0xFF2C5BE5); // accent — distinct from tide-2
      await tester.pumpWidget(
        buildTestWidget(const KaiForkScoreDots(score: 4, fillColor: custom)));
      expect(_dotsWithColor(tester, custom), 4);
      expect(_dotsWithColor(tester, _fill), 0);
    });

    testWidgets('dark mode — 3 tide-2 filled + 2 dark.surface3 empty',
        (tester) async {
      await tester.pumpWidget(buildTestWidget(
        const KaiForkScoreDots(score: 3), themeMode: ThemeMode.dark));
      expect(_dotsWithColor(tester, _fill), 3);
      expect(_dotsWithColor(tester, KaiColors.dark.surface3), 2);
    });

    testWidgets('showLabel renders the "n/max" score label', (tester) async {
      await tester.pumpWidget(
        buildTestWidget(const KaiForkScoreDots(score: 4, showLabel: true)));
      expect(find.text('4/5'), findsOneWidget);
    });

    testWidgets('no label by default', (tester) async {
      await tester.pumpWidget(buildTestWidget(const KaiForkScoreDots(score: 4)));
      expect(find.text('4/5'), findsNothing);
    });

    testWidgets('Row uses mainAxisSize.min', (tester) async {
      await tester.pumpWidget(buildTestWidget(const KaiForkScoreDots(score: 3)));
      expect(
        tester.widgetList<Row>(find.byType(Row)).any((r) => r.mainAxisSize == MainAxisSize.min),
        isTrue,
      );
    });
  });
}
