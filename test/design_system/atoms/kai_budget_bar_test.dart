import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:kai_app/design_system/atoms/kai_budget_bar.dart';
import 'package:kai_app/design_system/tokens/kai_tokens.dart';

import '../../test_helpers.dart';

// ---------------------------------------------------------------------------
// Segment fixtures
// ---------------------------------------------------------------------------

const _segFlights = KaiBudgetSegment(
  fraction: 0.40,
  color: Color(0xFF2BA8C9), // tide-2 blue
  label: 'Авиа',
);

const _segStays = KaiBudgetSegment(
  fraction: 0.30,
  color: Color(0xFFF4B589), // tide-3 warm
  label: 'Отели',
);

const _segFood = KaiBudgetSegment(
  fraction: 0.20,
  color: Color(0xFF5B9BD5), // mid-blue
  label: 'Еда',
);

const _segLocal = KaiBudgetSegment(
  fraction: 0.10,
  color: Color(0xFFB5CBE3),
  label: 'Транспорт',
);

// ---------------------------------------------------------------------------
// Helpers
// ---------------------------------------------------------------------------

/// Returns all [Expanded] widgets in the tree.
List<Expanded> _expandedWidgets(WidgetTester tester) =>
    tester.widgetList<Expanded>(find.byType(Expanded)).toList();

/// Returns all [ColoredBox] widgets in the tree.
List<ColoredBox> _coloredBoxes(WidgetTester tester) =>
    tester.widgetList<ColoredBox>(find.byType(ColoredBox)).toList();

void main() {
  group('v3/KaiBudgetBar', () {
    // -------------------------------------------------------------------------
    // Basic rendering
    // -------------------------------------------------------------------------

    testWidgets('renders without error with a single segment', (tester) async {
      await tester.pumpWidget(
        buildTestWidget(
          const KaiBudgetBar(
            segments: [
              KaiBudgetSegment(fraction: 0.6, color: Colors.blue, label: 'A'),
            ],
          ),
        ),
      );
      await tester.pump();
      expect(find.byType(KaiBudgetBar), findsOneWidget);
    });

    testWidgets('renders four segments without error', (tester) async {
      await tester.pumpWidget(
        buildTestWidget(
          const KaiBudgetBar(
            segments: [_segFlights, _segStays, _segFood, _segLocal],
          ),
        ),
      );
      await tester.pump();
      expect(find.byType(KaiBudgetBar), findsOneWidget);
    });

    // -------------------------------------------------------------------------
    // Proportional flex values
    // -------------------------------------------------------------------------

    testWidgets('Expanded flex values match fraction*1000 for each segment',
        (tester) async {
      await tester.pumpWidget(
        buildTestWidget(
          const KaiBudgetBar(
            segments: [_segFlights, _segStays, _segFood, _segLocal],
          ),
        ),
      );
      await tester.pump();

      final expandedList = _expandedWidgets(tester);
      // Segment flex values: 400, 300, 200, 100
      // Remainder flex: (1.0 - 1.0) * 1000 = 0  → no remainder Expanded
      final flexValues = expandedList.map((e) => e.flex).toList();

      expect(flexValues, contains(400));
      expect(flexValues, contains(300));
      expect(flexValues, contains(200));
      expect(flexValues, contains(100));
    });

    testWidgets('remainder segment has correct flex when segments sum < 1.0',
        (tester) async {
      // Two segments summing to 0.5 — remainder flex = 500
      await tester.pumpWidget(
        buildTestWidget(
          const KaiBudgetBar(
            segments: [
              KaiBudgetSegment(fraction: 0.3, color: Colors.red, label: 'X'),
              KaiBudgetSegment(fraction: 0.2, color: Colors.blue, label: 'Y'),
            ],
          ),
        ),
      );
      await tester.pump();

      final expandedList = _expandedWidgets(tester);
      final flexValues = expandedList.map((e) => e.flex).toList();

      // X: 300, Y: 200, remainder: 500
      expect(flexValues, contains(300));
      expect(flexValues, contains(200));
      expect(flexValues, contains(500));
    });

    // -------------------------------------------------------------------------
    // Track uses surface3 background color
    // -------------------------------------------------------------------------

    testWidgets('track has surface3 background color (light)', (tester) async {
      await tester.pumpWidget(
        buildTestWidget(
          const KaiBudgetBar(
            segments: [_segFlights, _segStays],
          ),
        ),
      );
      await tester.pump();

      final boxes = _coloredBoxes(tester);
      final hasSurface3 = boxes.any(
        (b) => b.color == KaiColors.light.surface3,
      );
      expect(hasSurface3, isTrue,
          reason: 'track outer ColoredBox must use surface3',);
    });

    testWidgets('track has surface3 background color (dark)', (tester) async {
      await tester.pumpWidget(
        buildTestWidget(
          const KaiBudgetBar(
            segments: [_segFlights, _segStays],
          ),
          themeMode: ThemeMode.dark,
        ),
      );
      await tester.pump();

      final boxes = _coloredBoxes(tester);
      final hasSurface3 = boxes.any(
        (b) => b.color == KaiColors.dark.surface3,
      );
      expect(hasSurface3, isTrue,
          reason: 'dark track must still use surface3',);
    });

    // -------------------------------------------------------------------------
    // Segment colors appear as ColoredBox widgets
    // -------------------------------------------------------------------------

    testWidgets('each segment color appears as a ColoredBox', (tester) async {
      await tester.pumpWidget(
        buildTestWidget(
          const KaiBudgetBar(
            segments: [_segFlights, _segStays, _segFood, _segLocal],
          ),
        ),
      );
      await tester.pump();

      final boxes = _coloredBoxes(tester);
      final colors = boxes.map((b) => b.color).toSet();

      expect(colors, contains(_segFlights.color));
      expect(colors, contains(_segStays.color));
      expect(colors, contains(_segFood.color));
      expect(colors, contains(_segLocal.color));
    });

    // -------------------------------------------------------------------------
    // Track uses pill border radius (ClipRRect)
    // -------------------------------------------------------------------------

    testWidgets('ClipRRect wraps the track with pill border radius',
        (tester) async {
      await tester.pumpWidget(
        buildTestWidget(
          const KaiBudgetBar(segments: [_segFlights]),
        ),
      );
      await tester.pump();

      final clips = tester
          .widgetList<ClipRRect>(find.byType(ClipRRect))
          .toList();
      final hasPill = clips.any(
        (c) => c.borderRadius == KaiRadius.brPill,
      );
      expect(hasPill, isTrue,
          reason: 'ClipRRect must use KaiRadius.brPill for pill ends',);
    });

    // -------------------------------------------------------------------------
    // showLegend = false (default): no label text
    // -------------------------------------------------------------------------

    testWidgets('showLegend=false — no label text rendered', (tester) async {
      await tester.pumpWidget(
        buildTestWidget(
          const KaiBudgetBar(
            segments: [_segFlights, _segStays],
          ),
        ),
      );
      await tester.pump();

      expect(find.text(_segFlights.label), findsNothing);
      expect(find.text(_segStays.label), findsNothing);
    });

    // -------------------------------------------------------------------------
    // showLegend = true: labels rendered
    // -------------------------------------------------------------------------

    testWidgets('showLegend=true — all segment labels are rendered',
        (tester) async {
      await tester.pumpWidget(
        buildTestWidget(
          const KaiBudgetBar(
            segments: [_segFlights, _segStays, _segFood, _segLocal],
            showLegend: true,
          ),
        ),
      );
      await tester.pump();

      expect(find.text(_segFlights.label), findsOneWidget);
      expect(find.text(_segStays.label), findsOneWidget);
      expect(find.text(_segFood.label), findsOneWidget);
      expect(find.text(_segLocal.label), findsOneWidget);
    });

    testWidgets('showLegend=true — legend swatch colors match segment colors',
        (tester) async {
      await tester.pumpWidget(
        buildTestWidget(
          const KaiBudgetBar(
            segments: [_segFlights, _segStays],
            showLegend: true,
          ),
        ),
      );
      await tester.pump();

      final containers =
          tester.widgetList<Container>(find.byType(Container)).toList();
      final containerColors =
          containers.map((c) => (c.decoration as BoxDecoration?)?.color).toSet();

      expect(containerColors, contains(_segFlights.color));
      expect(containerColors, contains(_segStays.color));
    });

    // -------------------------------------------------------------------------
    // Custom height
    // -------------------------------------------------------------------------

    testWidgets('custom height is applied to the SizedBox track wrapper',
        (tester) async {
      await tester.pumpWidget(
        buildTestWidget(
          const KaiBudgetBar(
            segments: [_segFlights],
            height: 16,
          ),
        ),
      );
      await tester.pump();

      final sizedBoxes =
          tester.widgetList<SizedBox>(find.byType(SizedBox)).toList();
      final found = sizedBoxes.any((s) => s.height == 16.0);
      expect(found, isTrue,
          reason: 'SizedBox with height=16 must exist for the track',);
    });

    // -------------------------------------------------------------------------
    // Empty segments list renders without error
    // -------------------------------------------------------------------------

    testWidgets('empty segments renders without error', (tester) async {
      await tester.pumpWidget(
        buildTestWidget(
          const KaiBudgetBar(segments: []),
        ),
      );
      await tester.pump();
      expect(find.byType(KaiBudgetBar), findsOneWidget);
    });
  });
}
