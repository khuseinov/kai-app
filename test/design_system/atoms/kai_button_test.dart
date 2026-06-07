import 'package:flutter/material.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:kai_app/core/providers/root.dart';
import 'package:kai_app/design_system/theme/kai_theme.dart';
import 'package:kai_app/design_system/tokens/kai_tokens.dart';
import 'package:kai_app/design_system/atoms/kai_button.dart';
import 'package:kai_app/design_system/primitives/kai_icon.dart';

// ---------------------------------------------------------------------------
// Helpers
// ---------------------------------------------------------------------------

Future<void> _pump(
  WidgetTester tester,
  Widget child, {
  ThemeMode themeMode = ThemeMode.light,
}) async {
  await tester.pumpWidget(
    ProviderScope(
      overrides: [
        themeModeProvider.overrideWith((ref) => themeMode),
      ],
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

      // -- Foreground colour legibility tests --

      testWidgets('light mode: label colour is surface (white #FFFFFF)',
          (tester) async {
        await _pump(
          tester,
          KaiButton.ink(onPressed: () {}, label: 'X'),
          themeMode: ThemeMode.light,
        );
        final labelColor =
            tester.widget<Text>(find.text('X')).style?.color;
        // Light surface = #FFFFFF
        expect(
          labelColor,
          const Color(0xFFFFFFFF),
          reason:
              'ink light-mode label must be surface (#FFFFFF) — legible on dark ink1 fill',
        );
      });

      testWidgets('dark mode: label colour is surface (dark #16161A)',
          (tester) async {
        await _pump(
          tester,
          KaiButton.ink(onPressed: () {}, label: 'X'),
          themeMode: ThemeMode.dark,
        );
        final labelColor =
            tester.widget<Text>(find.text('X')).style?.color;
        // Dark surface = #16161A — must NOT be white on near-white ink1 fill
        expect(
          labelColor,
          isNot(const Color(0xFFFFFFFF)),
          reason:
              'ink dark-mode label must NOT be white — white on #F5F5F2 ink1 fill is invisible',
        );
        expect(
          labelColor,
          const Color(0xFF16161A),
          reason:
              'ink dark-mode label must be surface (#16161A) — legible on light ink1 fill',
        );
      });

      testWidgets('tide: label colour is always white regardless of theme',
          (tester) async {
        for (final mode in [ThemeMode.light, ThemeMode.dark]) {
          await _pump(
            tester,
            KaiButton.tide(onPressed: () {}, label: 'T'),
            themeMode: mode,
          );
          final labelColor =
              tester.widget<Text>(find.text('T')).style?.color;
          expect(
            labelColor,
            const Color(0xFFFFFFFF),
            reason:
                'tide label must always be white — gradient is theme-independent; mode=$mode',
          );
        }
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

    // -----------------------------------------------------------------------
    // Size tiers
    // -----------------------------------------------------------------------
    group('sizes', () {
      testWidgets('sm renders label without overflow', (tester) async {
        await _pump(
          tester,
          KaiButton.tide(
            onPressed: () {},
            label: 'Открыть',
            size: KaiButtonSize.sm,
          ),
        );
        expect(find.text('Открыть'), findsOneWidget);
      });

      testWidgets('md renders label without overflow (default)', (tester) async {
        await _pump(
          tester,
          KaiButton.tide(
            onPressed: () {},
            label: 'Продолжить',
            // ignore: avoid_redundant_argument_values
            size: KaiButtonSize.md,
          ),
        );
        expect(find.text('Продолжить'), findsOneWidget);
      });

      testWidgets('lg renders label without overflow', (tester) async {
        await _pump(
          tester,
          KaiButton.tide(
            onPressed: () {},
            label: 'Начать',
            size: KaiButtonSize.lg,
          ),
        );
        expect(find.text('Начать'), findsOneWidget);
      });

      testWidgets('sm uses 12.5px font size', (tester) async {
        await _pump(
          tester,
          KaiButton.tide(
            onPressed: () {},
            label: 'Sm',
            size: KaiButtonSize.sm,
          ),
        );
        final texts = tester.widgetList<Text>(find.byType(Text)).toList();
        final found =
            texts.any((t) => (t.style?.fontSize ?? 0) - 12.5 < 0.01);
        expect(found, isTrue, reason: 'sm must use 12.5px font size');
      });

      testWidgets('md uses 13.5px font size (canon default)', (tester) async {
        await _pump(
          tester,
          KaiButton.tide(
            onPressed: () {},
            label: 'Md',
            // ignore: avoid_redundant_argument_values
            size: KaiButtonSize.md,
          ),
        );
        final texts = tester.widgetList<Text>(find.byType(Text)).toList();
        final found =
            texts.any((t) => (t.style?.fontSize ?? 0) - 13.5 < 0.01);
        expect(found, isTrue, reason: 'md must use 13.5px font size');
      });

      testWidgets('lg uses 15px font size', (tester) async {
        await _pump(
          tester,
          KaiButton.tide(
            onPressed: () {},
            label: 'Lg',
            size: KaiButtonSize.lg,
          ),
        );
        final texts = tester.widgetList<Text>(find.byType(Text)).toList();
        final found =
            texts.any((t) => (t.style?.fontSize ?? 0) - 15.0 < 0.01);
        expect(found, isTrue, reason: 'lg must use 15px font size');
      });

      testWidgets('size works on ink variant', (tester) async {
        await _pump(
          tester,
          KaiButton.ink(
            onPressed: () {},
            label: 'Small ink',
            size: KaiButtonSize.sm,
          ),
        );
        expect(find.text('Small ink'), findsOneWidget);
      });

      testWidgets('size works on ghost variant', (tester) async {
        await _pump(
          tester,
          KaiButton.ghost(
            onPressed: () {},
            label: 'Large ghost',
            size: KaiButtonSize.lg,
          ),
        );
        expect(find.text('Large ghost'), findsOneWidget);
      });

      testWidgets('size works on text variant', (tester) async {
        await _pump(
          tester,
          KaiButton.text(
            onPressed: () {},
            label: 'Sm text',
            size: KaiButtonSize.sm,
          ),
        );
        expect(find.text('Sm text'), findsOneWidget);
      });
    });

    // -----------------------------------------------------------------------
    // Tide gradient animation
    // -----------------------------------------------------------------------
    group('tide gradient animation', () {
      testWidgets('tide pumps frames without throwing', (tester) async {
        await _pump(
          tester,
          KaiButton.tide(onPressed: () {}, label: 'Animate'),
        );
        // Run several frames — button is static at rest (onInteraction default),
        // so no AnimatedBuilder runs; just verify no throw.
        await tester.pump(const Duration(milliseconds: 500));
        await tester.pump(const Duration(milliseconds: 1300));
        await tester.pump(const Duration(milliseconds: 2600));
        expect(find.text('Animate'), findsOneWidget);
      });

      testWidgets(
          'tide with disableAnimations=true renders static gradient (no AnimatedBuilder)',
          (tester) async {
        // Override MediaQuery to signal reduce-motion preference.
        await tester.pumpWidget(
          ProviderScope(
            child: MaterialApp(
              home: KaiTheme(
                child: MediaQuery(
                  data: const MediaQueryData(disableAnimations: true),
                  child: Scaffold(
                    body: Center(
                      child: KaiButton.tide(
                        onPressed: () {},
                        label: 'Static',
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),
        );
        await tester.pump();

        // With disableAnimations=true the gradient-flow controller must NOT
        // be created, so no AnimatedBuilder should be present for the gradient.
        // We verify by checking that advancing frames doesn't throw and that
        // the gradient is still painted (Container with gradient exists).
        await tester.pump(const Duration(milliseconds: 2600));
        expect(find.text('Static'), findsOneWidget);

        // The static path uses a Container with BoxDecoration gradient.
        final containers =
            tester.widgetList<Container>(find.byType(Container)).toList();
        final hasGradient = containers.any((c) {
          final deco = c.decoration;
          return deco is BoxDecoration && deco.gradient != null;
        });
        expect(hasGradient, isTrue,
            reason:
                'tide static path must still have a gradient container');
      });

      testWidgets('non-tide variants do not run gradient animation',
          (tester) async {
        // ink, ghost, text should not create the animated builder path.
        for (final button in [
          KaiButton.ink(onPressed: () {}, label: 'Ink'),
          KaiButton.ghost(onPressed: () {}, label: 'Ghost'),
          KaiButton.text(onPressed: () {}, label: 'Text'),
        ]) {
          await _pump(tester, button);
          await tester.pump(const Duration(milliseconds: 2600));
          // Should render and pump without throwing.
        }
        expect(true, isTrue); // reached without throwing
      });
    });

    // -----------------------------------------------------------------------
    // KaiTideAnim modes
    // -----------------------------------------------------------------------
    group('KaiTideAnim modes', () {
      // Helper: read isFlowing from the live state object.
      bool readIsFlowing(WidgetTester tester) {
        // ignore: avoid_dynamic_calls
        return (tester.state(find.byType(KaiButton)) as dynamic).isFlowing
            as bool;
      }

      testWidgets('onInteraction at rest → isFlowing == false', (tester) async {
        await _pump(
          tester,
          KaiButton.tide(
            onPressed: () {},
            label: 'Flow',
            tideAnim: KaiTideAnim.onInteraction,
          ),
        );
        await tester.pump();
        expect(readIsFlowing(tester), isFalse,
            reason: 'onInteraction: flow must be off at rest (no hover/press)');
      });

      testWidgets('onState + busy:true → isFlowing == true', (tester) async {
        await _pump(
          tester,
          KaiButton.tide(
            onPressed: () {},
            label: 'Busy',
            tideAnim: KaiTideAnim.onState,
            busy: true,
          ),
        );
        await tester.pump();
        expect(readIsFlowing(tester), isTrue,
            reason: 'onState: flow must be on when busy=true');
      });

      testWidgets('onState + busy:false → isFlowing == false', (tester) async {
        await _pump(
          tester,
          KaiButton.tide(
            onPressed: () {},
            label: 'Idle',
            tideAnim: KaiTideAnim.onState,
            // ignore: avoid_redundant_argument_values
            busy: false,
          ),
        );
        await tester.pump();
        expect(readIsFlowing(tester), isFalse,
            reason: 'onState: flow must be off when busy=false');
      });

      testWidgets('none + busy:true → isFlowing == false', (tester) async {
        await _pump(
          tester,
          KaiButton.tide(
            onPressed: () {},
            label: 'None',
            tideAnim: KaiTideAnim.none,
            busy: true,
          ),
        );
        await tester.pump();
        expect(readIsFlowing(tester), isFalse,
            reason: 'none: flow must always be off regardless of busy');
      });

      testWidgets('tide renders correctly with all tideAnim modes',
          (tester) async {
        for (final mode in KaiTideAnim.values) {
          await _pump(
            tester,
            KaiButton.tide(
              onPressed: () {},
              label: 'Mode',
              tideAnim: mode,
            ),
          );
          await tester.pump();
          expect(find.byType(KaiButton), findsOneWidget,
              reason: 'KaiButton.tide must render for tideAnim=$mode');
        }
      });

      // -----------------------------------------------------------------------
      // neutralAtRest
      // -----------------------------------------------------------------------
      group('neutralAtRest', () {
        testWidgets(
            'at rest (not hovered/pressed/busy) -> solid ink1 color, no gradient or shadow',
            (tester) async {
          await _pump(
            tester,
            KaiButton.tide(
              onPressed: () {},
              label: 'Neutral',
              neutralAtRest: true,
            ),
          );

          final containers =
              tester.widgetList<Container>(find.byType(Container)).toList();
          final found = containers.any((c) {
            final deco = c.decoration;
            return deco is BoxDecoration &&
                deco.color == KaiColors.light.ink1 &&
                deco.borderRadius == KaiRadius.br3 &&
                deco.gradient == null &&
                deco.boxShadow == null;
          });
          expect(found, isTrue,
              reason: 'Must render solid ink1 background with no gradient/shadow');
        });

        testWidgets(
            'glow emphasis at rest -> solid ink1 color, br2 radius, no gradient or shadow',
            (tester) async {
          await _pump(
            tester,
            KaiButton.tide(
              onPressed: () {},
              label: 'Glow Neutral',
              neutralAtRest: true,
              emphasis: KaiButtonEmphasis.glow,
            ),
          );

          final containers =
              tester.widgetList<Container>(find.byType(Container)).toList();
          final found = containers.any((c) {
            final deco = c.decoration;
            return deco is BoxDecoration &&
                deco.color == KaiColors.light.ink1 &&
                deco.borderRadius == KaiRadius.br2 &&
                deco.gradient == null &&
                deco.boxShadow == null;
          });
          expect(found, isTrue,
              reason: 'Glow neutral button must use br2 radius and no gradient/shadow');
        });

        testWidgets('when pressed -> switches to tide gradient and shadow',
            (tester) async {
          await _pump(
            tester,
            KaiButton.tide(
              onPressed: () {},
              label: 'Press me',
              neutralAtRest: true,
            ),
          );

          // Initially at rest: solid color
          var containers =
              tester.widgetList<Container>(find.byType(Container)).toList();
          expect(
            containers.any((c) =>
                c.decoration is BoxDecoration &&
                (c.decoration as BoxDecoration).color == KaiColors.light.ink1),
            isTrue,
          );

          // Start press gesture
          final gesture =
              await tester.startGesture(tester.getCenter(find.byType(KaiButton)));
          await tester.pump();

          // When pressed, it switches to the tide gradient (animated or static).
          // Since tideAnim defaults to onInteraction, when pressed it should flow (animated gradient).
          containers =
              tester.widgetList<Container>(find.byType(Container)).toList();
          final hasGradient = containers.any((c) {
            final deco = c.decoration;
            return deco is BoxDecoration && deco.gradient != null;
          });
          expect(hasGradient, isTrue,
              reason: 'Must switch to gradient when pressed');

          // Finish gesture
          await gesture.up();
          await tester.pump();
        });

        testWidgets('when busy -> switches to tide gradient and shadow',
            (tester) async {
          await _pump(
            tester,
            KaiButton.tide(
              onPressed: () {},
              label: 'Busy button',
              neutralAtRest: true,
              busy: true,
              tideAnim: KaiTideAnim.none, // Static gradient for easy verification
            ),
          );

          final containers =
              tester.widgetList<Container>(find.byType(Container)).toList();
          final hasGradient = containers.any((c) {
            final deco = c.decoration;
            return deco is BoxDecoration &&
                deco.gradient != null &&
                deco.boxShadow != null &&
                deco.boxShadow!.isNotEmpty;
          });
          expect(hasGradient, isTrue,
              reason: 'Must show static tide gradient and shadow when busy');
        });

        testWidgets('when hovered -> switches to tide gradient',
            (tester) async {
          await _pump(
            tester,
            KaiButton.tide(
              onPressed: () {},
              label: 'Hover me',
              neutralAtRest: true,
            ),
          );

          // Simulate hover using a mouse gesture
          final gesture =
              await tester.createGesture(kind: PointerDeviceKind.mouse);
          await gesture.addPointer(location: Offset.zero);
          await gesture.moveTo(tester.getCenter(find.byType(KaiButton)));
          await tester.pump();

          final containers =
              tester.widgetList<Container>(find.byType(Container)).toList();
          final hasGradient = containers.any((c) {
            final deco = c.decoration;
            return deco is BoxDecoration && deco.gradient != null;
          });
          expect(hasGradient, isTrue,
              reason: 'Must switch to gradient when hovered');

          await gesture.removePointer();
        });
      });
    });
  });
}
