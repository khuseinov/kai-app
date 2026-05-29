import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:kai_app/design_system/tokens/kai_tokens.dart';
import 'package:kai_app/design_system/atoms/kai_chip.dart';

import '../../test_helpers.dart';

// Helper — find a Text widget by fontSize inside the chip.
Text? _textWithFontSize(WidgetTester tester, double size) {
  final texts = tester.widgetList<Text>(find.byType(Text)).toList();
  for (final t in texts) {
    if (t.style?.fontSize == size) return t;
  }
  return null;
}

void main() {
  group('v3/KaiChip', () {
    // -------------------------------------------------------------------------
    // KaiChip.status
    // -------------------------------------------------------------------------
    group('status', () {
      testWidgets('label is uppercased', (tester) async {
        await tester.pumpWidget(
          buildTestWidget(const KaiChip.status('active')),
        );
        await tester.pump();
        // The widget uppercases the label internally.
        expect(find.text('ACTIVE'), findsOneWidget);
        expect(find.text('active'), findsNothing);
      });

      testWidgets('neutral tone — text color is ink3', (tester) async {
        await tester.pumpWidget(
          buildTestWidget(const KaiChip.status('draft')),
        );
        await tester.pump();
        final texts = tester.widgetList<Text>(find.byType(Text)).toList();
        final found = texts.any(
          (t) => t.style?.color == KaiColors.light.ink3,
        );
        expect(found, isTrue,
            reason: 'neutral chip text must use ink3');
      });

      testWidgets('neutral tone — background is transparent', (tester) async {
        await tester.pumpWidget(
          buildTestWidget(const KaiChip.status('draft')),
        );
        await tester.pump();
        final containers =
            tester.widgetList<Container>(find.byType(Container)).toList();
        // Neutral chips have null/transparent bg color.
        final found = containers.any((c) {
          final deco = c.decoration;
          return deco is BoxDecoration &&
              (deco.color == null || deco.color == Colors.transparent);
        });
        expect(found, isTrue,
            reason: 'neutral chip must have no background color');
      });

      testWidgets('neutral tone — border uses line color', (tester) async {
        await tester.pumpWidget(
          buildTestWidget(const KaiChip.status('draft')),
        );
        await tester.pump();
        final containers =
            tester.widgetList<Container>(find.byType(Container)).toList();
        final found = containers.any((c) {
          final deco = c.decoration;
          if (deco is! BoxDecoration) return false;
          final border = deco.border;
          if (border is! Border) return false;
          return border.top.color == KaiColors.light.line;
        });
        expect(found, isTrue,
            reason: 'neutral chip must have a border using line color');
      });

      testWidgets('done tone — text color is positive', (tester) async {
        await tester.pumpWidget(
          buildTestWidget(
              const KaiChip.status('done', tone: KaiChipTone.done)),
        );
        await tester.pump();
        final texts = tester.widgetList<Text>(find.byType(Text)).toList();
        final found = texts.any(
          (t) => t.style?.color == KaiColors.light.positive,
        );
        expect(found, isTrue,
            reason: 'done chip text must use positive color');
      });

      testWidgets('done tone — bg is positiveWash', (tester) async {
        await tester.pumpWidget(
          buildTestWidget(
              const KaiChip.status('done', tone: KaiChipTone.done)),
        );
        await tester.pump();
        final containers =
            tester.widgetList<Container>(find.byType(Container)).toList();
        final found = containers.any((c) {
          final deco = c.decoration;
          return deco is BoxDecoration &&
              deco.color == KaiColors.light.positiveWash;
        });
        expect(found, isTrue,
            reason: 'done chip must use positiveWash background');
      });

      testWidgets('active tone — text color is accent', (tester) async {
        await tester.pumpWidget(
          buildTestWidget(
              const KaiChip.status('live', tone: KaiChipTone.active)),
        );
        await tester.pump();
        final texts = tester.widgetList<Text>(find.byType(Text)).toList();
        final found = texts.any(
          (t) => t.style?.color == KaiColors.light.accent,
        );
        expect(found, isTrue,
            reason: 'active chip text must use accent color');
      });

      testWidgets('active tone — bg is accentWash', (tester) async {
        await tester.pumpWidget(
          buildTestWidget(
              const KaiChip.status('live', tone: KaiChipTone.active)),
        );
        await tester.pump();
        final containers =
            tester.widgetList<Container>(find.byType(Container)).toList();
        final found = containers.any((c) {
          final deco = c.decoration;
          return deco is BoxDecoration &&
              deco.color == KaiColors.light.accentWash;
        });
        expect(found, isTrue,
            reason: 'active chip must use accentWash background');
      });

      testWidgets('uses pill border radius', (tester) async {
        await tester.pumpWidget(
          buildTestWidget(const KaiChip.status('test')),
        );
        await tester.pump();
        final containers =
            tester.widgetList<Container>(find.byType(Container)).toList();
        final found = containers.any((c) {
          final deco = c.decoration;
          return deco is BoxDecoration &&
              deco.borderRadius == KaiRadius.brPill;
        });
        expect(found, isTrue,
            reason: 'status chip must use pill border radius');
      });

      testWidgets('not tappable — no GestureDetector', (tester) async {
        await tester.pumpWidget(
          buildTestWidget(const KaiChip.status('draft')),
        );
        await tester.pump();
        expect(find.byType(GestureDetector), findsNothing);
      });
    });

    // -------------------------------------------------------------------------
    // KaiChip.choice
    // -------------------------------------------------------------------------
    group('choice', () {
      testWidgets('selected — bg is surface color', (tester) async {
        await tester.pumpWidget(
          buildTestWidget(
            const KaiChip.choice('Все', selected: true),
          ),
        );
        await tester.pump();
        final containers =
            tester.widgetList<Container>(find.byType(Container)).toList();
        final found = containers.any((c) {
          final deco = c.decoration;
          return deco is BoxDecoration &&
              deco.color == KaiColors.light.surface;
        });
        expect(found, isTrue,
            reason: 'selected choice chip must use surface background');
      });

      testWidgets('selected — text color is ink1', (tester) async {
        await tester.pumpWidget(
          buildTestWidget(
            const KaiChip.choice('Все', selected: true),
          ),
        );
        await tester.pump();
        final texts = tester.widgetList<Text>(find.byType(Text)).toList();
        final found = texts.any(
          (t) => t.style?.color == KaiColors.light.ink1,
        );
        expect(found, isTrue,
            reason: 'selected choice chip text must use ink1');
      });

      testWidgets('unselected — bg is transparent', (tester) async {
        await tester.pumpWidget(
          buildTestWidget(
            const KaiChip.choice('Все', selected: false),
          ),
        );
        await tester.pump();
        final containers =
            tester.widgetList<Container>(find.byType(Container)).toList();
        // Unselected: no background fill.
        final found = containers.any((c) {
          final deco = c.decoration;
          return deco is BoxDecoration &&
              (deco.color == null || deco.color == Colors.transparent);
        });
        expect(found, isTrue,
            reason: 'unselected choice chip must have transparent background');
      });

      testWidgets('unselected — text color is ink3', (tester) async {
        await tester.pumpWidget(
          buildTestWidget(
            const KaiChip.choice('Всё', selected: false),
          ),
        );
        await tester.pump();
        final texts = tester.widgetList<Text>(find.byType(Text)).toList();
        final found = texts.any(
          (t) => t.style?.color == KaiColors.light.ink3,
        );
        expect(found, isTrue,
            reason: 'unselected choice chip text must use ink3');
      });

      testWidgets('uses pill border radius', (tester) async {
        await tester.pumpWidget(
          buildTestWidget(
            const KaiChip.choice('Test', selected: true),
          ),
        );
        await tester.pump();
        final containers =
            tester.widgetList<Container>(find.byType(Container)).toList();
        final found = containers.any((c) {
          final deco = c.decoration;
          return deco is BoxDecoration &&
              deco.borderRadius == KaiRadius.brPill;
        });
        expect(found, isTrue,
            reason: 'choice chip must use pill border radius');
      });

      testWidgets('onTap fires when tapped', (tester) async {
        var tapped = false;
        await tester.pumpWidget(
          buildTestWidget(
            KaiChip.choice('Tap', selected: false, onTap: () {
              tapped = true;
            }),
          ),
        );
        await tester.pump();
        await tester.tap(find.byType(KaiChip));
        expect(tapped, isTrue,
            reason: 'onTap must fire when choice chip is tapped');
      });

      testWidgets('onTap null — widget still renders without error', (tester) async {
        await tester.pumpWidget(
          buildTestWidget(
            const KaiChip.choice('Static', selected: false),
          ),
        );
        await tester.pump();
        expect(find.byType(KaiChip), findsOneWidget);
      });

      testWidgets('label is not uppercased for choice variant', (tester) async {
        await tester.pumpWidget(
          buildTestWidget(
            const KaiChip.choice('Все поездки', selected: false),
          ),
        );
        await tester.pump();
        // Choice chips preserve original casing.
        expect(find.text('Все поездки'), findsOneWidget);
      });
    });

    // -------------------------------------------------------------------------
    // KaiChipSize
    // -------------------------------------------------------------------------
    group('size', () {
      testWidgets('sm status chip renders 11px label', (tester) async {
        await tester.pumpWidget(
          buildTestWidget(
            const KaiChip.status('test', size: KaiChipSize.sm),
          ),
        );
        await tester.pump();
        final t = _textWithFontSize(tester, 11);
        expect(t, isNotNull, reason: 'sm status chip must use 11px fontSize');
      });

      testWidgets('md status chip renders 12px label (default)', (tester) async {
        await tester.pumpWidget(
          buildTestWidget(
            const KaiChip.status('test'),
          ),
        );
        await tester.pump();
        final t = _textWithFontSize(tester, 12);
        expect(t, isNotNull, reason: 'md status chip must use 12px fontSize');
      });

      testWidgets('sm choice chip renders 12px label', (tester) async {
        await tester.pumpWidget(
          buildTestWidget(
            const KaiChip.choice('option', selected: false, size: KaiChipSize.sm),
          ),
        );
        await tester.pump();
        final t = _textWithFontSize(tester, 12);
        expect(t, isNotNull, reason: 'sm choice chip must use 12px fontSize');
      });

      testWidgets('md choice chip renders 14px label (default)', (tester) async {
        await tester.pumpWidget(
          buildTestWidget(
            const KaiChip.choice('option', selected: false),
          ),
        );
        await tester.pump();
        final t = _textWithFontSize(tester, 14);
        expect(t, isNotNull, reason: 'md choice chip must use 14px fontSize');
      });
    });

    // -------------------------------------------------------------------------
    // Semantic tones (positive / warning / negative)
    // -------------------------------------------------------------------------
    group('semantic tones', () {
      testWidgets('positive tone — text color is positive', (tester) async {
        await tester.pumpWidget(
          buildTestWidget(
            const KaiChip.status('ok', tone: KaiChipTone.positive),
          ),
        );
        await tester.pump();
        final texts = tester.widgetList<Text>(find.byType(Text)).toList();
        final found = texts.any((t) => t.style?.color == KaiColors.light.positive);
        expect(found, isTrue, reason: 'positive chip text must use positive color');
      });

      testWidgets('positive tone — bg is positiveWash', (tester) async {
        await tester.pumpWidget(
          buildTestWidget(
            const KaiChip.status('ok', tone: KaiChipTone.positive),
          ),
        );
        await tester.pump();
        final containers =
            tester.widgetList<Container>(find.byType(Container)).toList();
        final found = containers.any((c) {
          final deco = c.decoration;
          return deco is BoxDecoration && deco.color == KaiColors.light.positiveWash;
        });
        expect(found, isTrue, reason: 'positive chip must use positiveWash bg');
      });

      testWidgets('warning tone — text color is warning', (tester) async {
        await tester.pumpWidget(
          buildTestWidget(
            const KaiChip.status('warn', tone: KaiChipTone.warning),
          ),
        );
        await tester.pump();
        final texts = tester.widgetList<Text>(find.byType(Text)).toList();
        final found = texts.any((t) => t.style?.color == KaiColors.light.warning);
        expect(found, isTrue, reason: 'warning chip text must use warning color');
      });

      testWidgets('warning tone — bg is warningWash', (tester) async {
        await tester.pumpWidget(
          buildTestWidget(
            const KaiChip.status('warn', tone: KaiChipTone.warning),
          ),
        );
        await tester.pump();
        final containers =
            tester.widgetList<Container>(find.byType(Container)).toList();
        final found = containers.any((c) {
          final deco = c.decoration;
          return deco is BoxDecoration && deco.color == KaiColors.light.warningWash;
        });
        expect(found, isTrue, reason: 'warning chip must use warningWash bg');
      });

      testWidgets('negative tone — text color is negative', (tester) async {
        await tester.pumpWidget(
          buildTestWidget(
            const KaiChip.status('err', tone: KaiChipTone.negative),
          ),
        );
        await tester.pump();
        final texts = tester.widgetList<Text>(find.byType(Text)).toList();
        final found = texts.any((t) => t.style?.color == KaiColors.light.negative);
        expect(found, isTrue, reason: 'negative chip text must use negative color');
      });

      testWidgets('negative tone — bg is negativeWash', (tester) async {
        await tester.pumpWidget(
          buildTestWidget(
            const KaiChip.status('err', tone: KaiChipTone.negative),
          ),
        );
        await tester.pump();
        final containers =
            tester.widgetList<Container>(find.byType(Container)).toList();
        final found = containers.any((c) {
          final deco = c.decoration;
          return deco is BoxDecoration && deco.color == KaiColors.light.negativeWash;
        });
        expect(found, isTrue, reason: 'negative chip must use negativeWash bg');
      });
    });
  });
}
