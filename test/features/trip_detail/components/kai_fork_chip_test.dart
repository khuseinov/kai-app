import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:kai_app/features/trip_detail/components/kai_fork_chip.dart';
import 'package:kai_app/design_system/tokens/kai_tokens.dart';

import '../../../test_helpers.dart';

Text _chipText(WidgetTester t) =>
    t.widget<Text>(find.byType(Text));

bool _anyContainer(WidgetTester t, bool Function(BoxDecoration) test) =>
    t.widgetList<Container>(find.byType(Container)).any((c) {
      final d = c.decoration;
      return d is BoxDecoration && test(d);
    });

void main() {
  group('v3/KaiForkChip', () {
    // ── Canon typography: JetBrains Mono, 8px/600, UPPERCASE, ls 0.04em ──────

    testWidgets('label is uppercased (canon text-transform)', (tester) async {
      await tester.pumpWidget(buildTestWidget(
        const KaiForkChip('без визы', tone: KaiForkChipTone.ok)));
      expect(find.text('БЕЗ ВИЗЫ'), findsOneWidget);
      expect(find.text('без визы'), findsNothing);
    });

    testWidgets('font is JetBrains Mono 8px/600 with 0.04em tracking',
        (tester) async {
      await tester.pumpWidget(buildTestWidget(const KaiForkChip('виза')));
      final style = _chipText(tester).style!;
      expect(style.fontFamily, 'JetBrainsMono');
      expect(style.fontSize, 8.0);
      expect(style.fontWeight, FontWeight.w600);
      expect(style.letterSpacing, closeTo(8 * 0.04, 0.001));
    });

    // ── Tone: bad — negative / negativeWash, no border ───────────────────────

    group('tone bad', () {
      testWidgets('negative text + negativeWash bg (light)', (tester) async {
        await tester.pumpWidget(buildTestWidget(
          const KaiForkChip('виза нужна', tone: KaiForkChipTone.bad)));
        expect(_chipText(tester).style!.color, KaiColors.light.negative);
        expect(_anyContainer(tester, (d) => d.color == KaiColors.light.negativeWash),
            isTrue);
      });

      testWidgets('negative text + negativeWash bg (dark)', (tester) async {
        await tester.pumpWidget(buildTestWidget(
          const KaiForkChip('виза нужна', tone: KaiForkChipTone.bad),
          themeMode: ThemeMode.dark));
        expect(_chipText(tester).style!.color, KaiColors.dark.negative);
        expect(_anyContainer(tester, (d) => d.color == KaiColors.dark.negativeWash),
            isTrue);
      });
    });

    // ── Tone: neutral — ink3 / surface2 + 0.8px line border ──────────────────

    group('tone neutral (default)', () {
      testWidgets('ink3 text + surface2 bg (light)', (tester) async {
        await tester.pumpWidget(buildTestWidget(const KaiForkChip('14°C')));
        expect(_chipText(tester).style!.color, KaiColors.light.ink3);
        expect(_anyContainer(tester, (d) => d.color == KaiColors.light.surface2),
            isTrue);
      });

      testWidgets('has a 0.8px line border (light)', (tester) async {
        await tester.pumpWidget(buildTestWidget(const KaiForkChip('14°C')));
        final found = _anyContainer(tester, (d) {
          final b = d.border;
          return b is Border &&
              b.top.color == KaiColors.light.line &&
              b.top.width == 0.8;
        });
        expect(found, isTrue);
      });

      testWidgets('ink3 text + surface2 bg (dark)', (tester) async {
        await tester.pumpWidget(buildTestWidget(
          const KaiForkChip('14°C'), themeMode: ThemeMode.dark));
        expect(_chipText(tester).style!.color, KaiColors.dark.ink3);
        expect(_anyContainer(tester, (d) => d.color == KaiColors.dark.surface2),
            isTrue);
      });
    });

    // ── Tone: ok — positive / positiveWash ───────────────────────────────────

    group('tone ok', () {
      testWidgets('positive text + positiveWash bg (light)', (tester) async {
        await tester.pumpWidget(buildTestWidget(
          const KaiForkChip('без визы', tone: KaiForkChipTone.ok)));
        expect(_chipText(tester).style!.color, KaiColors.light.positive);
        expect(_anyContainer(tester, (d) => d.color == KaiColors.light.positiveWash),
            isTrue);
      });
    });

    // ── Tone: warn — warning / warningWash (added R4) ────────────────────────

    group('tone warn', () {
      testWidgets('warning text + warningWash bg (light)', (tester) async {
        await tester.pumpWidget(buildTestWidget(
          const KaiForkChip('толпы', tone: KaiForkChipTone.warn)));
        expect(find.text('ТОЛПЫ'), findsOneWidget);
        expect(_chipText(tester).style!.color, KaiColors.light.warning);
        expect(_anyContainer(tester, (d) => d.color == KaiColors.light.warningWash),
            isTrue);
      });

      testWidgets('warning text + warningWash bg (dark)', (tester) async {
        await tester.pumpWidget(buildTestWidget(
          const KaiForkChip('толпы', tone: KaiForkChipTone.warn),
          themeMode: ThemeMode.dark));
        expect(_chipText(tester).style!.color, KaiColors.dark.warning);
        expect(_anyContainer(tester, (d) => d.color == KaiColors.dark.warningWash),
            isTrue);
      });
    });

    // ── Pill radius ──────────────────────────────────────────────────────────

    testWidgets('uses pill border radius', (tester) async {
      await tester.pumpWidget(buildTestWidget(const KaiForkChip('виза')));
      expect(_anyContainer(tester, (d) => d.borderRadius == KaiRadius.brPill),
          isTrue);
    });
  });
}
