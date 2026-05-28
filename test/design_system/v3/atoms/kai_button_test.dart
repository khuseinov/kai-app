import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:kai_app/design_system/theme/kai_theme.dart';
import 'package:kai_app/design_system/tokens/kai_tokens.dart';
import 'package:kai_app/design_system/v3/atoms/kai_button.dart';
import 'package:kai_app/design_system/v3/primitives/kai_icon.dart';

// ---------------------------------------------------------------------------
// Helpers
// ---------------------------------------------------------------------------

Future<void> _pump(WidgetTester tester, Widget child) async {
  await tester.pumpWidget(
    ProviderScope(
      child: MaterialApp(
        home: KaiTheme(
          child: Scaffold(body: Center(child: child)),
        ),
      ),
    ),
  );
  await tester.pump();
}

/// Finds the [Opacity] widget that wraps the visual content and returns its
/// opacity value. KaiButton wraps content in `Opacity(opacity: enabled?1:0.5)`.
double _buttonOpacity(WidgetTester tester) {
  final opacities =
      tester.widgetList<Opacity>(find.byType(Opacity)).toList();
  // The first Opacity that is a direct descendant of AnimatedScale is ours.
  return opacities.first.opacity;
}

// ---------------------------------------------------------------------------
// Tests
// ---------------------------------------------------------------------------

void main() {
  group('v3/KaiButton', () {
    // -----------------------------------------------------------------------
    // KaiButton.tide
    // -----------------------------------------------------------------------
    group('tide.normal', () {
      testWidgets('renders label', (tester) async {
        await _pump(
          tester,
          KaiButton.tide(onPressed: () {}, label: 'Продолжить'),
        );
        expect(find.text('Продолжить'), findsOneWidget);
      });

      testWidgets('fires onPressed when tapped', (tester) async {
        var tapped = 0;
        await _pump(
          tester,
          KaiButton.tide(onPressed: () => tapped++, label: 'Tap'),
        );
        await tester.tap(find.byType(KaiButton));
        expect(tapped, 1);
      });

      testWidgets('disabled when onPressed is null — opacity 0.5', (tester) async {
        await _pump(
          tester,
          const KaiButton.tide(onPressed: null, label: 'Disabled'),
        );
        expect(_buttonOpacity(tester), 0.5);
      });

      testWidgets('disabled — tap does not fire', (tester) async {
        var tapped = 0;
        await _pump(
          tester,
          const KaiButton.tide(onPressed: null, label: 'Nope'),
        );
        await tester.tap(find.byType(KaiButton), warnIfMissed: false);
        expect(tapped, 0);
      });

      testWidgets('uses KaiRadius.br3 decoration', (tester) async {
        await _pump(
          tester,
          KaiButton.tide(onPressed: () {}, label: 'R'),
        );
        final containers =
            tester.widgetList<Container>(find.byType(Container)).toList();
        final found = containers.any((c) {
          final deco = c.decoration;
          return deco is BoxDecoration &&
              deco.borderRadius == KaiRadius.br3 &&
              deco.gradient != null;
        });
        expect(found, isTrue, reason: 'tide.normal must use br3 + gradient');
      });

      testWidgets('has boxShadow (KaiShadow.button)', (tester) async {
        await _pump(
          tester,
          KaiButton.tide(onPressed: () {}, label: 'S'),
        );
        final containers =
            tester.widgetList<Container>(find.byType(Container)).toList();
        final found = containers.any((c) {
          final deco = c.decoration;
          return deco is BoxDecoration &&
              deco.boxShadow != null &&
              deco.boxShadow!.isNotEmpty;
        });
        expect(found, isTrue, reason: 'tide.normal must carry KaiShadow.button');
      });

      testWidgets('renders KaiIcon when icon provided', (tester) async {
        await _pump(
          tester,
          KaiButton.tide(
            onPressed: () {},
            label: 'Go',
            icon: KaiIconName.arrowUp,
          ),
        );
        expect(find.byType(KaiIcon), findsOneWidget);
      });
    });

    group('tide.glow', () {
      testWidgets('renders label', (tester) async {
        await _pump(
          tester,
          KaiButton.tide(
            onPressed: () {},
            label: 'Premium',
            emphasis: KaiButtonEmphasis.glow,
          ),
        );
        expect(find.text('Premium'), findsOneWidget);
      });

      testWidgets('uses KaiRadius.br2 (r10) — differs from normal', (tester) async {
        await _pump(
          tester,
          KaiButton.tide(
            onPressed: () {},
            label: 'G',
            emphasis: KaiButtonEmphasis.glow,
          ),
        );
        final containers =
            tester.widgetList<Container>(find.byType(Container)).toList();
        final found = containers.any((c) {
          final deco = c.decoration;
          return deco is BoxDecoration &&
              deco.borderRadius == KaiRadius.br2;
        });
        expect(found, isTrue, reason: 'tide.glow must use br2 (r10)');
      });

      testWidgets('glow shadow differs from normal (larger blurRadius)', (tester) async {
        // Build glow variant and inspect shadow blur.
        await _pump(
          tester,
          KaiButton.tide(
            onPressed: () {},
            label: 'G',
            emphasis: KaiButtonEmphasis.glow,
          ),
        );
        final containers =
            tester.widgetList<Container>(find.byType(Container)).toList();
        final glowShadow = containers
            .map((c) => c.decoration)
            .whereType<BoxDecoration>()
            .where((d) => d.boxShadow != null && d.boxShadow!.isNotEmpty)
            .expand((d) => d.boxShadow!)
            .toList();
        expect(
          glowShadow.any((s) => s.blurRadius >= 16),
          isTrue,
          reason: 'tide.glow must use glow shadow (blurRadius >= 16)',
        );
      });
    });

    // -----------------------------------------------------------------------
    // KaiButton.ink
    // -----------------------------------------------------------------------
    group('ink', () {
      testWidgets('renders label', (tester) async {
        await _pump(
          tester,
          KaiButton.ink(onPressed: () {}, label: 'Новый чат'),
        );
        expect(find.text('Новый чат'), findsOneWidget);
      });

      testWidgets('fires onPressed when tapped', (tester) async {
        var tapped = 0;
        await _pump(
          tester,
          KaiButton.ink(onPressed: () => tapped++, label: 'Tap'),
        );
        await tester.tap(find.byType(KaiButton));
        expect(tapped, 1);
      });

      testWidgets('disabled when onPressed is null — opacity 0.5', (tester) async {
        await _pump(
          tester,
          const KaiButton.ink(onPressed: null, label: 'Off'),
        );
        expect(_buttonOpacity(tester), 0.5);
      });

      testWidgets('uses ink1 color fill + br3 radius by default', (tester) async {
        await _pump(
          tester,
          KaiButton.ink(onPressed: () {}, label: 'I'),
        );
        final containers =
            tester.widgetList<Container>(find.byType(Container)).toList();
        final found = containers.any((c) {
          final deco = c.decoration;
          return deco is BoxDecoration &&
              deco.color == KaiColors.light.ink1 &&
              deco.borderRadius == KaiRadius.br3;
        });
        expect(found, isTrue, reason: 'ink default must use ink1 + br3');
      });

      testWidgets('fullWidth: true uses br12 radius', (tester) async {
        await _pump(
          tester,
          KaiButton.ink(
            onPressed: () {},
            label: 'Full',
            fullWidth: true,
          ),
        );
        final containers =
            tester.widgetList<Container>(find.byType(Container)).toList();
        final found = containers.any((c) {
          final deco = c.decoration;
          return deco is BoxDecoration &&
              deco.borderRadius == KaiRadius.br12;
        });
        expect(found, isTrue, reason: 'ink fullWidth must use br12');
      });

      testWidgets('fullWidth: true stretches container to double.infinity', (tester) async {
        await _pump(
          tester,
          KaiButton.ink(
            onPressed: () {},
            label: 'Full',
            fullWidth: true,
          ),
        );
        // Full-width is expressed via Row(mainAxisSize.max) + width:infinity.
        final rows = tester.widgetList<Row>(find.byType(Row)).toList();
        final hasMaxRow =
            rows.any((r) => r.mainAxisSize == MainAxisSize.max);
        expect(hasMaxRow, isTrue,
            reason: 'fullWidth must use Row with mainAxisSize.max');
      });

      testWidgets('renders KaiIcon when icon provided', (tester) async {
        await _pump(
          tester,
          KaiButton.ink(
            onPressed: () {},
            label: 'Plus',
            icon: KaiIconName.plus,
          ),
        );
        expect(find.byType(KaiIcon), findsOneWidget);
      });
    });

    // -----------------------------------------------------------------------
    // KaiButton.ghost
    // -----------------------------------------------------------------------
    group('ghost', () {
      testWidgets('renders label', (tester) async {
        await _pump(
          tester,
          KaiButton.ghost(onPressed: () {}, label: 'Повторить'),
        );
        expect(find.text('Повторить'), findsOneWidget);
      });

      testWidgets('fires onPressed when tapped', (tester) async {
        var tapped = 0;
        await _pump(
          tester,
          KaiButton.ghost(onPressed: () => tapped++, label: 'Tap'),
        );
        await tester.tap(find.byType(KaiButton));
        expect(tapped, 1);
      });

      testWidgets('disabled when onPressed is null — opacity 0.5', (tester) async {
        await _pump(
          tester,
          const KaiButton.ghost(onPressed: null, label: 'Off'),
        );
        expect(_buttonOpacity(tester), 0.5);
      });

      testWidgets('tone.neutral uses line border + br3', (tester) async {
        await _pump(
          tester,
          KaiButton.ghost(
            onPressed: () {},
            label: 'N',
            tone: KaiButtonTone.neutral,
          ),
        );
        final containers =
            tester.widgetList<Container>(find.byType(Container)).toList();
        final found = containers.any((c) {
          final deco = c.decoration;
          if (deco is! BoxDecoration) return false;
          final border = deco.border;
          return border is Border &&
              deco.borderRadius == KaiRadius.br3;
        });
        expect(found, isTrue, reason: 'ghost.neutral must use br3 + border');
      });

      testWidgets('tone.warning uses warning-colored border', (tester) async {
        await _pump(
          tester,
          KaiButton.ghost(
            onPressed: () {},
            label: 'W',
            tone: KaiButtonTone.warning,
          ),
        );
        final containers =
            tester.widgetList<Container>(find.byType(Container)).toList();
        final found = containers.any((c) {
          final deco = c.decoration;
          if (deco is! BoxDecoration) return false;
          final border = deco.border;
          if (border is! Border) return false;
          return border.top.color == KaiColors.light.warning;
        });
        expect(found, isTrue,
            reason: 'ghost.warning must use warning color on border');
      });

      testWidgets('tone.negative uses negative-colored border', (tester) async {
        await _pump(
          tester,
          KaiButton.ghost(
            onPressed: () {},
            label: 'X',
            tone: KaiButtonTone.negative,
          ),
        );
        final containers =
            tester.widgetList<Container>(find.byType(Container)).toList();
        final found = containers.any((c) {
          final deco = c.decoration;
          if (deco is! BoxDecoration) return false;
          final border = deco.border;
          if (border is! Border) return false;
          return border.top.color == KaiColors.light.negative;
        });
        expect(found, isTrue,
            reason: 'ghost.negative must use negative color on border');
      });

      testWidgets('pill: true uses brPill radius', (tester) async {
        await _pump(
          tester,
          KaiButton.ghost(
            onPressed: () {},
            label: 'Retry',
            pill: true,
          ),
        );
        final containers =
            tester.widgetList<Container>(find.byType(Container)).toList();
        final found = containers.any((c) {
          final deco = c.decoration;
          return deco is BoxDecoration &&
              deco.borderRadius == KaiRadius.brPill;
        });
        expect(found, isTrue, reason: 'ghost pill must use brPill radius');
      });

      testWidgets('pill: false uses br3 radius (default)', (tester) async {
        await _pump(
          tester,
          KaiButton.ghost(
            onPressed: () {},
            label: 'Default',
          ),
        );
        final containers =
            tester.widgetList<Container>(find.byType(Container)).toList();
        final found = containers.any((c) {
          final deco = c.decoration;
          return deco is BoxDecoration &&
              deco.borderRadius == KaiRadius.br3;
        });
        expect(found, isTrue, reason: 'ghost default must use br3 radius');
      });

      testWidgets('renders KaiIcon when icon provided', (tester) async {
        await _pump(
          tester,
          KaiButton.ghost(
            onPressed: () {},
            label: 'Retry',
            icon: KaiIconName.retry,
          ),
        );
        expect(find.byType(KaiIcon), findsOneWidget);
      });
    });

    // -----------------------------------------------------------------------
    // KaiButton.text
    // -----------------------------------------------------------------------
    group('text', () {
      testWidgets('renders label', (tester) async {
        await _pump(
          tester,
          KaiButton.text(onPressed: () {}, label: 'Открыть'),
        );
        expect(find.text('Открыть'), findsOneWidget);
      });

      testWidgets('fires onPressed when tapped', (tester) async {
        var tapped = 0;
        await _pump(
          tester,
          KaiButton.text(onPressed: () => tapped++, label: 'Tap'),
        );
        await tester.tap(find.byType(KaiButton));
        expect(tapped, 1);
      });

      testWidgets('disabled when onPressed is null — opacity 0.5', (tester) async {
        await _pump(
          tester,
          const KaiButton.text(onPressed: null, label: 'Off'),
        );
        expect(_buttonOpacity(tester), 0.5);
      });

      testWidgets('has no border / no fill (transparent background)', (tester) async {
        await _pump(
          tester,
          KaiButton.text(onPressed: () {}, label: 'T'),
        );
        final containers =
            tester.widgetList<Container>(find.byType(Container)).toList();
        // No container should have a non-transparent color or a gradient.
        final hasOpaqueContainer = containers.any((c) {
          final deco = c.decoration;
          if (deco is! BoxDecoration) return false;
          final hasColor =
              deco.color != null && deco.color != Colors.transparent;
          final hasGradient = deco.gradient != null;
          final hasBorder = deco.border != null;
          return hasColor || hasGradient || hasBorder;
        });
        expect(hasOpaqueContainer, isFalse,
            reason: 'text button must have no fill, no border, no gradient');
      });

      testWidgets('tone.neutral text uses ink1 color', (tester) async {
        await _pump(
          tester,
          KaiButton.text(
            onPressed: () {},
            label: 'Neutral',
            tone: KaiButtonTone.neutral,
          ),
        );
        // Check that a Text widget with ink1 color is present.
        final texts = tester.widgetList<Text>(find.byType(Text)).toList();
        final found = texts.any((t) =>
            t.style?.color == KaiColors.light.ink1);
        expect(found, isTrue,
            reason: 'text.neutral must use ink1 color');
      });

      testWidgets('tone.accent text uses accent color', (tester) async {
        await _pump(
          tester,
          KaiButton.text(
            onPressed: () {},
            label: 'Accent',
            tone: KaiButtonTone.accent,
          ),
        );
        final texts = tester.widgetList<Text>(find.byType(Text)).toList();
        final found = texts.any((t) =>
            t.style?.color == KaiColors.light.accent);
        expect(found, isTrue,
            reason: 'text.accent must use accent color');
      });

      testWidgets('tone.negative text uses negative color', (tester) async {
        await _pump(
          tester,
          KaiButton.text(
            onPressed: () {},
            label: 'Delete',
            tone: KaiButtonTone.negative,
          ),
        );
        final texts = tester.widgetList<Text>(find.byType(Text)).toList();
        final found = texts.any((t) =>
            t.style?.color == KaiColors.light.negative);
        expect(found, isTrue,
            reason: 'text.negative must use negative color');
      });

      testWidgets('renders KaiIcon when icon provided', (tester) async {
        await _pump(
          tester,
          KaiButton.text(
            onPressed: () {},
            label: 'Open',
            icon: KaiIconName.chevRight,
          ),
        );
        expect(find.byType(KaiIcon), findsOneWidget);
      });
    });

    // -----------------------------------------------------------------------
    // Semantics
    // -----------------------------------------------------------------------
    group('semantics', () {
      testWidgets('has Semantics widget with button=true, enabled when active',
          (tester) async {
        await _pump(
          tester,
          KaiButton.tide(onPressed: () {}, label: 'Go'),
        );
        // Find our KaiButton's direct Semantics widget (button: true, enabled: true).
        final allSemantics =
            tester.widgetList<Semantics>(find.byType(Semantics)).toList();
        final found = allSemantics.any((s) =>
            s.properties.button == true && s.properties.enabled == true);
        expect(found, isTrue,
            reason: 'KaiButton must expose Semantics(button:true, enabled:true)');
      });

      testWidgets('has Semantics widget with enabled=false when disabled',
          (tester) async {
        await _pump(
          tester,
          const KaiButton.tide(onPressed: null, label: 'Go'),
        );
        final allSemantics =
            tester.widgetList<Semantics>(find.byType(Semantics)).toList();
        final found = allSemantics.any((s) => s.properties.enabled == false);
        expect(found, isTrue,
            reason:
                'KaiButton must expose Semantics(enabled:false) when onPressed is null');
      });
    });

    // -----------------------------------------------------------------------
    // AnimatedScale press behavior
    // -----------------------------------------------------------------------
    group('press animation', () {
      testWidgets('AnimatedScale starts at 1.0 before press', (tester) async {
        await _pump(
          tester,
          KaiButton.tide(onPressed: () {}, label: 'Press'),
        );
        final scale = tester.widget<AnimatedScale>(find.byType(AnimatedScale));
        expect(scale.scale, 1.0);
      });
    });
  });
}
