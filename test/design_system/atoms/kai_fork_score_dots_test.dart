import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:kai_app/design_system/atoms/kai_fork_score_dots.dart';
import 'package:kai_app/design_system/tokens/kai_tokens.dart';

import '../../test_helpers.dart';

// ---------------------------------------------------------------------------
// Helpers
// ---------------------------------------------------------------------------

/// Returns all Container widgets in the tree that have a circular BoxDecoration.
List<Container> _circleDots(WidgetTester tester) {
  return tester
      .widgetList<Container>(find.byType(Container))
      .where((c) {
        final deco = c.decoration;
        return deco is BoxDecoration && deco.shape == BoxShape.circle;
      })
      .toList();
}

int _dotsWithColor(WidgetTester tester, Color color) {
  return _circleDots(tester)
      .where((c) {
        final deco = c.decoration as BoxDecoration;
        return deco.color == color;
      })
      .length;
}

void main() {
  group('v3/KaiForkScoreDots', () {
    // -------------------------------------------------------------------------
    // Core rendering — score=3, max=5 (default)
    // -------------------------------------------------------------------------

    group('score=3, max=5 (default)', () {
      testWidgets('renders exactly 5 dots', (tester) async {
        await tester.pumpWidget(
          buildTestWidget(const KaiForkScoreDots(score: 3)),
        );
        await tester.pump();
        expect(_circleDots(tester).length, 5,
            reason: '5 dots must be rendered for default max');
      });

      testWidgets('3 dots use positive fill color (light)', (tester) async {
        await tester.pumpWidget(
          buildTestWidget(const KaiForkScoreDots(score: 3)),
        );
        await tester.pump();
        expect(
          _dotsWithColor(tester, KaiColors.light.positive),
          3,
          reason: '3 filled dots must use positive color',
        );
      });

      testWidgets('2 dots use surface3 empty color (light)', (tester) async {
        await tester.pumpWidget(
          buildTestWidget(const KaiForkScoreDots(score: 3)),
        );
        await tester.pump();
        expect(
          _dotsWithColor(tester, KaiColors.light.surface3),
          2,
          reason: '2 empty dots must use surface3 color',
        );
      });
    });

    // -------------------------------------------------------------------------
    // Edge cases
    // -------------------------------------------------------------------------

    group('score=0', () {
      testWidgets('all 5 dots are surface3 (empty)', (tester) async {
        await tester.pumpWidget(
          buildTestWidget(const KaiForkScoreDots(score: 0)),
        );
        await tester.pump();
        expect(_circleDots(tester).length, 5);
        expect(
          _dotsWithColor(tester, KaiColors.light.surface3),
          5,
          reason: 'score=0 must show all empty dots',
        );
      });

      testWidgets('no positive dots when score is 0', (tester) async {
        await tester.pumpWidget(
          buildTestWidget(const KaiForkScoreDots(score: 0)),
        );
        await tester.pump();
        expect(
          _dotsWithColor(tester, KaiColors.light.positive),
          0,
          reason: 'score=0 must show 0 filled dots',
        );
      });
    });

    group('score >= max (all filled)', () {
      testWidgets('score=5 — all 5 dots use positive fill', (tester) async {
        await tester.pumpWidget(
          buildTestWidget(const KaiForkScoreDots(score: 5)),
        );
        await tester.pump();
        expect(
          _dotsWithColor(tester, KaiColors.light.positive),
          5,
          reason: 'score=5 must fill all 5 dots',
        );
        expect(
          _dotsWithColor(tester, KaiColors.light.surface3),
          0,
          reason: 'score=5 must leave no empty dots',
        );
      });

      testWidgets('score > max clamps to max (all filled)', (tester) async {
        await tester.pumpWidget(
          // score=10 with max=5 must clamp to 5 filled
          buildTestWidget(const KaiForkScoreDots(score: 10)),
        );
        await tester.pump();
        expect(_circleDots(tester).length, 5,
            reason: 'still 5 dots rendered');
        expect(
          _dotsWithColor(tester, KaiColors.light.positive),
          5,
          reason: 'score>max clamps to max filled dots',
        );
      });
    });

    // -------------------------------------------------------------------------
    // Custom max
    // -------------------------------------------------------------------------

    testWidgets('max=3, score=2 — 3 dots total, 2 filled', (tester) async {
      await tester.pumpWidget(
        buildTestWidget(const KaiForkScoreDots(score: 2, max: 3)),
      );
      await tester.pump();
      expect(_circleDots(tester).length, 3,
          reason: 'custom max=3 must render 3 dots');
      expect(
        _dotsWithColor(tester, KaiColors.light.positive),
        2,
        reason: '2 filled dots',
      );
      expect(
        _dotsWithColor(tester, KaiColors.light.surface3),
        1,
        reason: '1 empty dot',
      );
    });

    // -------------------------------------------------------------------------
    // Custom fillColor override
    // -------------------------------------------------------------------------

    testWidgets('custom fillColor is applied to filled dots', (tester) async {
      const customColor = Color(0xFF2BA8C9); // tide-2
      await tester.pumpWidget(
        buildTestWidget(
          const KaiForkScoreDots(score: 4, fillColor: customColor),
        ),
      );
      await tester.pump();
      expect(
        _dotsWithColor(tester, customColor),
        4,
        reason: 'custom fillColor must be used for filled dots',
      );
    });

    // -------------------------------------------------------------------------
    // Dark mode
    // -------------------------------------------------------------------------

    testWidgets('score=3 — 3 positive + 2 surface3 in dark mode', (tester) async {
      await tester.pumpWidget(
        buildTestWidget(
          const KaiForkScoreDots(score: 3),
          themeMode: ThemeMode.dark,
        ),
      );
      await tester.pump();
      expect(
        _dotsWithColor(tester, KaiColors.dark.positive),
        3,
        reason: '3 filled dots must use dark.positive',
      );
      expect(
        _dotsWithColor(tester, KaiColors.dark.surface3),
        2,
        reason: '2 empty dots must use dark.surface3',
      );
    });

    // -------------------------------------------------------------------------
    // Layout — Row with min size
    // -------------------------------------------------------------------------

    testWidgets('widget uses Row with mainAxisSize.min', (tester) async {
      await tester.pumpWidget(
        buildTestWidget(const KaiForkScoreDots(score: 3)),
      );
      await tester.pump();
      final rows = tester.widgetList<Row>(find.byType(Row)).toList();
      final found = rows.any((r) => r.mainAxisSize == MainAxisSize.min);
      expect(found, isTrue,
          reason: 'Row must use MainAxisSize.min to hug content');
    });
  });
}
