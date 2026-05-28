import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:kai_app/design_system/theme/kai_theme.dart';
import 'package:kai_app/design_system/atoms/kai_icon_button.dart';
import 'package:kai_app/design_system/primitives/kai_icon.dart';

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

// ---------------------------------------------------------------------------
// Tests
// ---------------------------------------------------------------------------

void main() {
  group('v3/KaiIconButton', () {
    // -------------------------------------------------------------------------
    // KaiIconButton.surface
    // -------------------------------------------------------------------------
    group('surface', () {
      testWidgets('renders a KaiIcon', (tester) async {
        await _pump(
          tester,
          KaiIconButton.surface(
            onPressed: () {},
            icon: KaiIconName.mic,
          ),
        );
        expect(find.byType(KaiIcon), findsOneWidget);
      });

      testWidgets('fires onPressed when tapped', (tester) async {
        var tapped = 0;
        await _pump(
          tester,
          KaiIconButton.surface(
            onPressed: () => tapped++,
            icon: KaiIconName.mic,
          ),
        );
        await tester.tap(find.byType(KaiIconButton));
        expect(tapped, 1);
      });

      testWidgets('null onPressed disables — opacity 0.5', (tester) async {
        await _pump(
          tester,
          const KaiIconButton.surface(onPressed: null, icon: KaiIconName.mic),
        );
        final opacities =
            tester.widgetList<Opacity>(find.byType(Opacity)).toList();
        final found = opacities.any((o) => o.opacity == 0.5);
        expect(found, isTrue,
            reason: 'disabled surface icon-button must have Opacity(0.5)');
      });

      testWidgets('null onPressed — tap does not fire', (tester) async {
        var tapped = 0;
        await _pump(
          tester,
          const KaiIconButton.surface(
            onPressed: null,
            icon: KaiIconName.mic,
          ),
        );
        await tester.tap(find.byType(KaiIconButton), warnIfMissed: false);
        expect(tapped, 0);
      });

      testWidgets('has surface2 background decoration', (tester) async {
        await _pump(
          tester,
          KaiIconButton.surface(
            onPressed: () {},
            icon: KaiIconName.mic,
          ),
        );
        final containers =
            tester.widgetList<Container>(find.byType(Container)).toList();
        final found = containers.any((c) {
          final deco = c.decoration;
          return deco is BoxDecoration && deco.color != null;
        });
        expect(found, isTrue, reason: 'surface variant must have a fill color');
      });

      testWidgets('has Semantics(button: true)', (tester) async {
        await _pump(
          tester,
          KaiIconButton.surface(
            onPressed: () {},
            icon: KaiIconName.mic,
          ),
        );
        final allSemantics =
            tester.widgetList<Semantics>(find.byType(Semantics)).toList();
        final found = allSemantics.any((s) => s.properties.button == true);
        expect(found, isTrue,
            reason: 'KaiIconButton must expose Semantics(button: true)');
      });

      testWidgets('AnimatedScale starts at 1.0 when not pressed', (tester) async {
        await _pump(
          tester,
          KaiIconButton.surface(
            onPressed: () {},
            icon: KaiIconName.mic,
          ),
        );
        final scale =
            tester.widget<AnimatedScale>(find.byType(AnimatedScale));
        expect(scale.scale, 1.0);
      });

      testWidgets('custom size is applied to KaiIcon', (tester) async {
        await _pump(
          tester,
          KaiIconButton.surface(
            onPressed: () {},
            icon: KaiIconName.plus,
            size: 24,
          ),
        );
        final icon = tester.widget<KaiIcon>(find.byType(KaiIcon));
        expect(icon.size, 24.0);
      });
    });

    // -------------------------------------------------------------------------
    // KaiIconButton.transparent
    // -------------------------------------------------------------------------
    group('transparent', () {
      testWidgets('renders a KaiIcon', (tester) async {
        await _pump(
          tester,
          KaiIconButton.transparent(
            onPressed: () {},
            icon: KaiIconName.mic,
          ),
        );
        expect(find.byType(KaiIcon), findsOneWidget);
      });

      testWidgets('fires onPressed when tapped', (tester) async {
        var tapped = 0;
        await _pump(
          tester,
          KaiIconButton.transparent(
            onPressed: () => tapped++,
            icon: KaiIconName.mic,
          ),
        );
        await tester.tap(find.byType(KaiIconButton));
        expect(tapped, 1);
      });

      testWidgets('null onPressed disables — opacity 0.5', (tester) async {
        await _pump(
          tester,
          const KaiIconButton.transparent(
            onPressed: null,
            icon: KaiIconName.mic,
          ),
        );
        final opacities =
            tester.widgetList<Opacity>(find.byType(Opacity)).toList();
        final found = opacities.any((o) => o.opacity == 0.5);
        expect(found, isTrue,
            reason: 'disabled transparent icon-button must have Opacity(0.5)');
      });

      testWidgets('null onPressed — tap does not fire', (tester) async {
        var tapped = 0;
        await _pump(
          tester,
          const KaiIconButton.transparent(
            onPressed: null,
            icon: KaiIconName.mic,
          ),
        );
        await tester.tap(find.byType(KaiIconButton), warnIfMissed: false);
        expect(tapped, 0);
      });

      testWidgets('has no opaque background decoration', (tester) async {
        await _pump(
          tester,
          KaiIconButton.transparent(
            onPressed: () {},
            icon: KaiIconName.mic,
          ),
        );
        // The inner container for transparent must have no fill color.
        final containers =
            tester.widgetList<Container>(find.byType(Container)).toList();
        final hasOpaqueContainer = containers.any((c) {
          final deco = c.decoration;
          if (deco is! BoxDecoration) return false;
          return deco.color != null &&
              deco.color != Colors.transparent &&
              deco.gradient == null;
        });
        // It's OK if there is no such container — transparent just means no fill.
        expect(hasOpaqueContainer, isFalse,
            reason: 'transparent variant must not have an opaque fill');
      });

      testWidgets('has Semantics(button: true)', (tester) async {
        await _pump(
          tester,
          KaiIconButton.transparent(
            onPressed: () {},
            icon: KaiIconName.mic,
          ),
        );
        final allSemantics =
            tester.widgetList<Semantics>(find.byType(Semantics)).toList();
        final found = allSemantics.any((s) => s.properties.button == true);
        expect(found, isTrue);
      });
    });

    // -------------------------------------------------------------------------
    // KaiIconButton.bare
    // -------------------------------------------------------------------------
    group('bare', () {
      testWidgets('renders a KaiIcon', (tester) async {
        await _pump(
          tester,
          KaiIconButton.bare(
            onPressed: () {},
            icon: KaiIconName.close,
          ),
        );
        expect(find.byType(KaiIcon), findsOneWidget);
      });

      testWidgets('fires onPressed when tapped', (tester) async {
        var tapped = 0;
        await _pump(
          tester,
          KaiIconButton.bare(
            onPressed: () => tapped++,
            icon: KaiIconName.close,
          ),
        );
        await tester.tap(find.byType(KaiIconButton));
        expect(tapped, 1);
      });

      testWidgets('null onPressed disables — opacity 0.5', (tester) async {
        await _pump(
          tester,
          const KaiIconButton.bare(onPressed: null, icon: KaiIconName.close),
        );
        final opacities =
            tester.widgetList<Opacity>(find.byType(Opacity)).toList();
        final found = opacities.any((o) => o.opacity == 0.5);
        expect(found, isTrue,
            reason: 'disabled bare icon-button must have Opacity(0.5)');
      });

      testWidgets('null onPressed — tap does not fire', (tester) async {
        var tapped = 0;
        await _pump(
          tester,
          const KaiIconButton.bare(
            onPressed: null,
            icon: KaiIconName.close,
          ),
        );
        await tester.tap(find.byType(KaiIconButton), warnIfMissed: false);
        expect(tapped, 0);
      });

      testWidgets('custom color is forwarded to KaiIcon', (tester) async {
        const customColor = Color(0xFFFF0000);
        await _pump(
          tester,
          KaiIconButton.bare(
            onPressed: () {},
            icon: KaiIconName.close,
            color: customColor,
          ),
        );
        final icon = tester.widget<KaiIcon>(find.byType(KaiIcon));
        expect(icon.color, customColor);
      });

      testWidgets('has Semantics(button: true)', (tester) async {
        await _pump(
          tester,
          KaiIconButton.bare(
            onPressed: () {},
            icon: KaiIconName.close,
          ),
        );
        final allSemantics =
            tester.widgetList<Semantics>(find.byType(Semantics)).toList();
        final found = allSemantics.any((s) => s.properties.button == true);
        expect(found, isTrue);
      });
    });
  });
}
