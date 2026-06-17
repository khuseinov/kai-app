import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:kai_app/design_system/atoms/kai_fork_chip.dart';
import 'package:kai_app/design_system/atoms/kai_fork_price_delta.dart';
import 'package:kai_app/design_system/atoms/kai_fork_score_dots.dart';
import 'package:kai_app/design_system/molecules/kai_fork_card.dart';
import 'package:kai_app/design_system/tokens/kai_tokens.dart';

import '../../test_helpers.dart';

// ---------------------------------------------------------------------------
// Sample data
// ---------------------------------------------------------------------------

const _colJapan = KaiForkColumn(
  name: 'Япония',
  glyph: 'JP',
  price: r'$2,100',
  priceDelta: r'+$500',
  priceDirection: KaiPriceDirection.up,
  rows: [
    KaiForkRow(
      label: 'виза',
      value: 'виза нужна',
      chipTone: KaiForkChipTone.bad,
      chipLabel: 'виза нужна',
    ),
    KaiForkRow(
      label: 'погода',
      value: '14°C',
      chipTone: KaiForkChipTone.neutral,
      chipLabel: '14°C',
    ),
    KaiForkRow(
      label: 'оценка',
      value: '4/5',
      score: 4,
    ),
  ],
);

const _colKorea = KaiForkColumn(
  name: 'Корея',
  glyph: 'KR',
  price: r'$1,600',
  priceDelta: r'−$500',
  priceDirection: KaiPriceDirection.down,
  rows: [
    KaiForkRow(
      label: 'виза',
      value: 'без визы',
      chipTone: KaiForkChipTone.ok,
      chipLabel: 'без визы',
    ),
    KaiForkRow(
      label: 'погода',
      value: '10°C',
      chipTone: KaiForkChipTone.neutral,
      chipLabel: '10°C',
    ),
    KaiForkRow(
      label: 'оценка',
      value: '5/5',
      score: 5,
    ),
  ],
);

// ---------------------------------------------------------------------------
// Tests
// ---------------------------------------------------------------------------

void main() {
  group('v3/KaiForkCard', () {
    // -------------------------------------------------------------------------
    // Basic rendering — column names and prices
    // -------------------------------------------------------------------------

    testWidgets('renders both column names', (tester) async {
      await tester.pumpWidget(
        buildTestWidget(
          const SizedBox(
            width: 300,
            child: KaiForkCard(
              columns: [_colJapan, _colKorea],
            ),
          ),
        ),
      );
      await tester.pump();

      expect(find.text('Япония'), findsOneWidget);
      expect(find.text('Корея'), findsOneWidget);
    });

    testWidgets('renders both prices', (tester) async {
      await tester.pumpWidget(
        buildTestWidget(
          const SizedBox(
            width: 300,
            child: KaiForkCard(
              columns: [_colJapan, _colKorea],
            ),
          ),
        ),
      );
      await tester.pump();

      expect(find.text(r'$2,100'), findsOneWidget);
      expect(find.text(r'$1,600'), findsOneWidget);
    });

    testWidgets('renders both glyph labels', (tester) async {
      await tester.pumpWidget(
        buildTestWidget(
          const SizedBox(
            width: 300,
            child: KaiForkCard(
              columns: [_colJapan, _colKorea],
            ),
          ),
        ),
      );
      await tester.pump();

      expect(find.text('JP'), findsOneWidget);
      expect(find.text('KR'), findsOneWidget);
    });

    // -------------------------------------------------------------------------
    // Atoms present — KaiForkChip + KaiForkScoreDots
    // -------------------------------------------------------------------------

    testWidgets('KaiForkChip widgets appear in tree', (tester) async {
      await tester.pumpWidget(
        buildTestWidget(
          const SizedBox(
            width: 300,
            child: KaiForkCard(
              columns: [_colJapan, _colKorea],
            ),
          ),
        ),
      );
      await tester.pump();

      // At least 2 chips across both columns (visa chips)
      final chips = tester.widgetList<KaiForkChip>(find.byType(KaiForkChip));
      expect(chips.length, greaterThanOrEqualTo(2),
          reason: 'KaiForkChip atoms must be present in the card',);
    });

    testWidgets('KaiForkScoreDots widgets appear in tree', (tester) async {
      await tester.pumpWidget(
        buildTestWidget(
          const SizedBox(
            width: 300,
            child: KaiForkCard(
              columns: [_colJapan, _colKorea],
            ),
          ),
        ),
      );
      await tester.pump();

      // One score row per column = 2 total
      final scoreDots =
          tester.widgetList<KaiForkScoreDots>(find.byType(KaiForkScoreDots));
      expect(scoreDots.length, 2,
          reason: 'One KaiForkScoreDots per column must appear',);
    });

    // -------------------------------------------------------------------------
    // Chip labels are rendered
    // -------------------------------------------------------------------------

    testWidgets('chip labels are visible', (tester) async {
      await tester.pumpWidget(
        buildTestWidget(
          const SizedBox(
            width: 300,
            child: KaiForkCard(
              columns: [_colJapan, _colKorea],
            ),
          ),
        ),
      );
      await tester.pump();

      // KaiForkChip uppercases per canon (.chip text-transform).
      expect(find.text('ВИЗА НУЖНА'), findsOneWidget);
      expect(find.text('БЕЗ ВИЗЫ'), findsOneWidget);
    });

    // -------------------------------------------------------------------------
    // pickIndex — pick marker present
    // -------------------------------------------------------------------------

    group('pickIndex', () {
      testWidgets('pickIndex: 1 shows pick badge text for Korea', (tester) async {
        await tester.pumpWidget(
          buildTestWidget(
            const SizedBox(
              width: 300,
              child: KaiForkCard(
                columns: [_colJapan, _colKorea],
                pickIndex: 1,
              ),
            ),
          ),
        );
        await tester.pump();

        // The pick badge shows a bare "✓" (the "лучший" wording lives in the
        // .fc-sw winner-summary footer, not the badge).
        expect(find.text('✓'), findsOneWidget,
            reason: 'pickIndex=1 must show the pick badge on the Korea column',);
      });

      testWidgets('pickIndex: 0 shows pick badge for Japan', (tester) async {
        await tester.pumpWidget(
          buildTestWidget(
            const SizedBox(
              width: 300,
              child: KaiForkCard(
                columns: [_colJapan, _colKorea],
                pickIndex: 0,
              ),
            ),
          ),
        );
        await tester.pump();

        expect(find.text('✓'), findsOneWidget,
            reason: 'pickIndex=0 must show the pick badge on the Japan column',);
      });

      testWidgets('no pickIndex — no pick badge text', (tester) async {
        await tester.pumpWidget(
          buildTestWidget(
            const SizedBox(
              width: 300,
              child: KaiForkCard(
                columns: [_colJapan, _colKorea],
              ),
            ),
          ),
        );
        await tester.pump();

        expect(find.text('✓'), findsNothing,
            reason: 'No pick badge when pickIndex is null',);
      });

      testWidgets('winning column has a top tide gradient bar', (tester) async {
        await tester.pumpWidget(
          buildTestWidget(
            const SizedBox(
              width: 300,
              child: KaiForkCard(
                columns: [_colJapan, _colKorea],
                pickIndex: 1,
              ),
            ),
          ),
        );
        await tester.pump();

        // Positioned height=2 with tide gradient decoration exists
        final decoratedBoxes = tester
            .widgetList<DecoratedBox>(find.byType(DecoratedBox))
            .toList();
        final hasTideGradient = decoratedBoxes.any((db) {
          final deco = db.decoration;
          return deco is BoxDecoration && deco.gradient == KaiTide.gradient;
        });
        expect(hasTideGradient, isTrue,
            reason:
                'Winning column must have a 2px tide gradient top accent bar',);
      });
    });

    // -------------------------------------------------------------------------
    // Header label
    // -------------------------------------------------------------------------

    testWidgets('default header label shows "2 варианта"', (tester) async {
      await tester.pumpWidget(
        buildTestWidget(
          const SizedBox(
            width: 300,
            child: KaiForkCard(
              columns: [_colJapan, _colKorea],
            ),
          ),
        ),
      );
      await tester.pump();

      expect(find.text('2 варианта'), findsOneWidget);
    });

    testWidgets('custom headerLabel is rendered', (tester) async {
      await tester.pumpWidget(
        buildTestWidget(
          const SizedBox(
            width: 300,
            child: KaiForkCard(
              columns: [_colJapan, _colKorea],
              headerLabel: 'сравниваем · 2 варианта',
            ),
          ),
        ),
      );
      await tester.pump();

      expect(find.text('сравниваем · 2 варианта'), findsOneWidget);
    });

    // -------------------------------------------------------------------------
    // Outer container uses surface fill and br3 radius
    // -------------------------------------------------------------------------

    testWidgets('outer container uses surface fill', (tester) async {
      await tester.pumpWidget(
        buildTestWidget(
          const SizedBox(
            width: 300,
            child: KaiForkCard(
              columns: [_colJapan, _colKorea],
            ),
          ),
        ),
      );
      await tester.pump();

      final containers =
          tester.widgetList<Container>(find.byType(Container)).toList();
      final found = containers.any((c) {
        final deco = c.decoration;
        return deco is BoxDecoration && deco.color == KaiColors.light.surface;
      });
      expect(found, isTrue,
          reason: 'KaiForkCard outer container must use surface fill',);
    });

    // -------------------------------------------------------------------------
    // Dark mode — renders without error
    // -------------------------------------------------------------------------

    testWidgets('renders without error in dark mode', (tester) async {
      await tester.pumpWidget(
        buildTestWidget(
          const SizedBox(
            width: 300,
            child: KaiForkCard(
              columns: [_colJapan, _colKorea],
              pickIndex: 1,
            ),
          ),
          themeMode: ThemeMode.dark,
        ),
      );
      await tester.pump();

      expect(find.text('Япония'), findsOneWidget);
      expect(find.text('Корея'), findsOneWidget);
      expect(find.text('✓'), findsOneWidget);
    });

    // -------------------------------------------------------------------------
    // R4 fidelity additions — price delta, winner footer, fresh marker
    // -------------------------------------------------------------------------

    testWidgets('price-row renders KaiForkPriceDelta when delta provided',
        (tester) async {
      await tester.pumpWidget(
        buildTestWidget(
          const SizedBox(
            width: 300,
            child: KaiForkCard(columns: [_colJapan, _colKorea]),
          ),
        ),
      );
      await tester.pump();
      // one delta per column
      expect(find.byType(KaiForkPriceDelta), findsNWidgets(2));
      expect(find.text(r'+$500'), findsOneWidget);
      expect(find.text(r'−$500'), findsOneWidget);
    });

    testWidgets('winnerSummary renders the .fc-sw footer', (tester) async {
      await tester.pumpWidget(
        buildTestWidget(
          const SizedBox(
            width: 300,
            child: KaiForkCard(
              columns: [_colJapan, _colKorea],
              pickIndex: 1,
              winnerSummary: r'Корея — лучший выбор для $2k.',
            ),
          ),
        ),
      );
      await tester.pump();
      expect(find.text(r'Корея — лучший выбор для $2k.'), findsOneWidget);
    });

    testWidgets('no footer when winnerSummary is null', (tester) async {
      await tester.pumpWidget(
        buildTestWidget(
          const SizedBox(
            width: 300,
            child: KaiForkCard(columns: [_colJapan, _colKorea], pickIndex: 1),
          ),
        ),
      );
      await tester.pump();
      expect(find.textContaining('лучший выбор'), findsNothing);
    });

    testWidgets('freshLabel renders in the header', (tester) async {
      await tester.pumpWidget(
        buildTestWidget(
          const SizedBox(
            width: 300,
            child: KaiForkCard(
              columns: [_colJapan, _colKorea],
              freshLabel: '✓ сегодня',
            ),
          ),
        ),
      );
      await tester.pump();
      expect(find.text('✓ сегодня'), findsOneWidget);
    });

    testWidgets('score rows show dots with label, no duplicate value text',
        (tester) async {
      await tester.pumpWidget(
        buildTestWidget(
          const SizedBox(
            width: 300,
            child: KaiForkCard(columns: [_colJapan, _colKorea]),
          ),
        ),
      );
      await tester.pump();
      // score-dot label appears once per column (4/5 and 5/5), not duplicated
      expect(find.text('4/5'), findsOneWidget);
      expect(find.text('5/5'), findsOneWidget);
    });
  });
}
