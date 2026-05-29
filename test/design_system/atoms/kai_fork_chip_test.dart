import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:kai_app/design_system/atoms/kai_fork_chip.dart';
import 'package:kai_app/design_system/tokens/kai_tokens.dart';

import '../../test_helpers.dart';

void main() {
  group('v3/KaiForkChip', () {
    // -------------------------------------------------------------------------
    // Label rendering
    // -------------------------------------------------------------------------

    testWidgets('label is visible', (tester) async {
      await tester.pumpWidget(
        buildTestWidget(const KaiForkChip('без визы')),
      );
      await tester.pump();
      expect(find.text('без визы'), findsOneWidget);
    });

    testWidgets('label is not uppercased', (tester) async {
      await tester.pumpWidget(
        buildTestWidget(const KaiForkChip('без визы')),
      );
      await tester.pump();
      // No uppercase transform applied.
      expect(find.text('без визы'), findsOneWidget);
      expect(find.text('БЕЗ ВИЗЫ'), findsNothing);
    });

    // -------------------------------------------------------------------------
    // Tone: bad — negativeWash bg + negative text
    // -------------------------------------------------------------------------

    group('tone bad', () {
      testWidgets('text color is negative (light)', (tester) async {
        await tester.pumpWidget(
          buildTestWidget(
            const KaiForkChip('виза нужна', tone: KaiForkChipTone.bad),
          ),
        );
        await tester.pump();
        final texts = tester.widgetList<Text>(find.byType(Text)).toList();
        final found = texts.any(
          (t) => t.style?.color == KaiColors.light.negative,
        );
        expect(found, isTrue, reason: 'bad chip text must use negative color');
      });

      testWidgets('bg is negativeWash (light)', (tester) async {
        await tester.pumpWidget(
          buildTestWidget(
            const KaiForkChip('виза нужна', tone: KaiForkChipTone.bad),
          ),
        );
        await tester.pump();
        final containers =
            tester.widgetList<Container>(find.byType(Container)).toList();
        final found = containers.any((c) {
          final deco = c.decoration;
          return deco is BoxDecoration &&
              deco.color == KaiColors.light.negativeWash;
        });
        expect(found, isTrue, reason: 'bad chip must use negativeWash bg');
      });

      testWidgets('text color is negative (dark)', (tester) async {
        await tester.pumpWidget(
          buildTestWidget(
            const KaiForkChip('виза нужна', tone: KaiForkChipTone.bad),
            themeMode: ThemeMode.dark,
          ),
        );
        await tester.pump();
        final texts = tester.widgetList<Text>(find.byType(Text)).toList();
        final found = texts.any(
          (t) => t.style?.color == KaiColors.dark.negative,
        );
        expect(found, isTrue,
            reason: 'bad chip text must use negative color in dark mode');
      });

      testWidgets('bg is negativeWash (dark)', (tester) async {
        await tester.pumpWidget(
          buildTestWidget(
            const KaiForkChip('виза нужна', tone: KaiForkChipTone.bad),
            themeMode: ThemeMode.dark,
          ),
        );
        await tester.pump();
        final containers =
            tester.widgetList<Container>(find.byType(Container)).toList();
        final found = containers.any((c) {
          final deco = c.decoration;
          return deco is BoxDecoration &&
              deco.color == KaiColors.dark.negativeWash;
        });
        expect(found, isTrue,
            reason: 'bad chip must use negativeWash bg in dark mode');
      });
    });

    // -------------------------------------------------------------------------
    // Tone: neutral — surface3 bg + ink3 text + line border
    // -------------------------------------------------------------------------

    group('tone neutral (default)', () {
      testWidgets('text color is ink3 (light)', (tester) async {
        await tester.pumpWidget(
          buildTestWidget(const KaiForkChip('14°C')),
        );
        await tester.pump();
        final texts = tester.widgetList<Text>(find.byType(Text)).toList();
        final found = texts.any(
          (t) => t.style?.color == KaiColors.light.ink3,
        );
        expect(found, isTrue, reason: 'neutral chip text must use ink3');
      });

      testWidgets('bg is surface3 (light)', (tester) async {
        await tester.pumpWidget(
          buildTestWidget(const KaiForkChip('14°C')),
        );
        await tester.pump();
        final containers =
            tester.widgetList<Container>(find.byType(Container)).toList();
        final found = containers.any((c) {
          final deco = c.decoration;
          return deco is BoxDecoration &&
              deco.color == KaiColors.light.surface3;
        });
        expect(found, isTrue, reason: 'neutral chip must use surface3 bg');
      });

      testWidgets('has a border using line color (light)', (tester) async {
        await tester.pumpWidget(
          buildTestWidget(const KaiForkChip('14°C')),
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
        expect(found, isTrue, reason: 'neutral chip must have a line border');
      });

      testWidgets('text color is ink3 (dark)', (tester) async {
        await tester.pumpWidget(
          buildTestWidget(
            const KaiForkChip('14°C'),
            themeMode: ThemeMode.dark,
          ),
        );
        await tester.pump();
        final texts = tester.widgetList<Text>(find.byType(Text)).toList();
        final found = texts.any(
          (t) => t.style?.color == KaiColors.dark.ink3,
        );
        expect(found, isTrue,
            reason: 'neutral chip text must use ink3 in dark mode');
      });

      testWidgets('bg is surface3 (dark)', (tester) async {
        await tester.pumpWidget(
          buildTestWidget(
            const KaiForkChip('14°C'),
            themeMode: ThemeMode.dark,
          ),
        );
        await tester.pump();
        final containers =
            tester.widgetList<Container>(find.byType(Container)).toList();
        final found = containers.any((c) {
          final deco = c.decoration;
          return deco is BoxDecoration &&
              deco.color == KaiColors.dark.surface3;
        });
        expect(found, isTrue,
            reason: 'neutral chip must use surface3 bg in dark mode');
      });
    });

    // -------------------------------------------------------------------------
    // Tone: ok — positiveWash bg + positive text
    // -------------------------------------------------------------------------

    group('tone ok', () {
      testWidgets('text color is positive (light)', (tester) async {
        await tester.pumpWidget(
          buildTestWidget(
            const KaiForkChip('без визы', tone: KaiForkChipTone.ok),
          ),
        );
        await tester.pump();
        final texts = tester.widgetList<Text>(find.byType(Text)).toList();
        final found = texts.any(
          (t) => t.style?.color == KaiColors.light.positive,
        );
        expect(found, isTrue, reason: 'ok chip text must use positive color');
      });

      testWidgets('bg is positiveWash (light)', (tester) async {
        await tester.pumpWidget(
          buildTestWidget(
            const KaiForkChip('без визы', tone: KaiForkChipTone.ok),
          ),
        );
        await tester.pump();
        final containers =
            tester.widgetList<Container>(find.byType(Container)).toList();
        final found = containers.any((c) {
          final deco = c.decoration;
          return deco is BoxDecoration &&
              deco.color == KaiColors.light.positiveWash;
        });
        expect(found, isTrue, reason: 'ok chip must use positiveWash bg');
      });

      testWidgets('text color is positive (dark)', (tester) async {
        await tester.pumpWidget(
          buildTestWidget(
            const KaiForkChip('без визы', tone: KaiForkChipTone.ok),
            themeMode: ThemeMode.dark,
          ),
        );
        await tester.pump();
        final texts = tester.widgetList<Text>(find.byType(Text)).toList();
        final found = texts.any(
          (t) => t.style?.color == KaiColors.dark.positive,
        );
        expect(found, isTrue,
            reason: 'ok chip text must use positive color in dark mode');
      });

      testWidgets('bg is positiveWash (dark)', (tester) async {
        await tester.pumpWidget(
          buildTestWidget(
            const KaiForkChip('без визы', tone: KaiForkChipTone.ok),
            themeMode: ThemeMode.dark,
          ),
        );
        await tester.pump();
        final containers =
            tester.widgetList<Container>(find.byType(Container)).toList();
        final found = containers.any((c) {
          final deco = c.decoration;
          return deco is BoxDecoration &&
              deco.color == KaiColors.dark.positiveWash;
        });
        expect(found, isTrue,
            reason: 'ok chip must use positiveWash bg in dark mode');
      });
    });

    // -------------------------------------------------------------------------
    // Pill radius
    // -------------------------------------------------------------------------

    testWidgets('uses pill border radius', (tester) async {
      await tester.pumpWidget(
        buildTestWidget(const KaiForkChip('виза')),
      );
      await tester.pump();
      final containers =
          tester.widgetList<Container>(find.byType(Container)).toList();
      final found = containers.any((c) {
        final deco = c.decoration;
        return deco is BoxDecoration &&
            deco.borderRadius == KaiRadius.brPill;
      });
      expect(found, isTrue, reason: 'KaiForkChip must use pill border radius');
    });

    // -------------------------------------------------------------------------
    // Font size
    // -------------------------------------------------------------------------

    testWidgets('uses 8px font size', (tester) async {
      await tester.pumpWidget(
        buildTestWidget(const KaiForkChip('виза')),
      );
      await tester.pump();
      final texts = tester.widgetList<Text>(find.byType(Text)).toList();
      final found = texts.any((t) => t.style?.fontSize == 8.0);
      expect(found, isTrue,
          reason: 'KaiForkChip must use 8px font size (canon fork.html)');
    });
  });
}
