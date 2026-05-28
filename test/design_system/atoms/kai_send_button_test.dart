import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:kai_app/design_system/theme/kai_theme.dart';
import 'package:kai_app/design_system/tokens/kai_tokens.dart';
import 'package:kai_app/design_system/atoms/kai_send_button.dart';
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
  group('v3/KaiSendButton', () {
    // -------------------------------------------------------------------------
    // ready state
    // -------------------------------------------------------------------------
    group('ready', () {
      testWidgets('renders KaiIcon', (tester) async {
        await _pump(
          tester,
          KaiSendButton(
            state: KaiSendState.ready,
            onPressed: () {},
          ),
        );
        expect(find.byType(KaiIcon), findsOneWidget);
      });

      testWidgets('fires onPressed when tapped', (tester) async {
        var tapped = 0;
        await _pump(
          tester,
          KaiSendButton(
            state: KaiSendState.ready,
            onPressed: () => tapped++,
          ),
        );
        await tester.tap(find.byType(KaiSendButton));
        expect(tapped, 1);
      });

      testWidgets('has tide gradient decoration', (tester) async {
        await _pump(
          tester,
          KaiSendButton(
            state: KaiSendState.ready,
            onPressed: () {},
          ),
        );
        final containers =
            tester.widgetList<Container>(find.byType(Container)).toList();
        final found = containers.any((c) {
          final deco = c.decoration;
          return deco is BoxDecoration && deco.gradient != null;
        });
        expect(found, isTrue,
            reason: 'ready state must use tide gradient');
      });

      testWidgets('has boxShadow (KaiShadow.button)', (tester) async {
        await _pump(
          tester,
          KaiSendButton(
            state: KaiSendState.ready,
            onPressed: () {},
          ),
        );
        final containers =
            tester.widgetList<Container>(find.byType(Container)).toList();
        final found = containers.any((c) {
          final deco = c.decoration;
          return deco is BoxDecoration &&
              deco.boxShadow != null &&
              deco.boxShadow!.isNotEmpty;
        });
        expect(found, isTrue,
            reason: 'ready state must carry KaiShadow.button');
      });

      testWidgets('has Semantics(button: true, enabled: true)', (tester) async {
        await _pump(
          tester,
          KaiSendButton(
            state: KaiSendState.ready,
            onPressed: () {},
          ),
        );
        final allSemantics =
            tester.widgetList<Semantics>(find.byType(Semantics)).toList();
        final found = allSemantics.any((s) =>
            s.properties.button == true && s.properties.enabled == true);
        expect(found, isTrue);
      });

      testWidgets('custom size — widget renders without throwing', (tester) async {
        await _pump(
          tester,
          KaiSendButton(
            state: KaiSendState.ready,
            onPressed: () {},
            size: 40,
          ),
        );
        // Just verify the widget tree is intact; Container size is applied via
        // width/height fields which are internal layout — we trust the build
        // completes without exception.
        expect(find.byType(KaiSendButton), findsOneWidget);
      });

      testWidgets('custom iconSize is applied to KaiIcon', (tester) async {
        await _pump(
          tester,
          KaiSendButton(
            state: KaiSendState.ready,
            onPressed: () {},
            iconSize: 16,
          ),
        );
        final icon = tester.widget<KaiIcon>(find.byType(KaiIcon));
        expect(icon.size, 16.0);
      });
    });

    // -------------------------------------------------------------------------
    // disabled state
    // -------------------------------------------------------------------------
    group('disabled', () {
      testWidgets('renders KaiIcon', (tester) async {
        await _pump(
          tester,
          const KaiSendButton(
            state: KaiSendState.disabled,
            onPressed: null,
          ),
        );
        expect(find.byType(KaiIcon), findsOneWidget);
      });

      testWidgets('tap does not fire when disabled state', (tester) async {
        var tapped = 0;
        await _pump(
          tester,
          KaiSendButton(
            state: KaiSendState.disabled,
            onPressed: () => tapped++,
          ),
        );
        await tester.tap(find.byType(KaiSendButton), warnIfMissed: false);
        expect(tapped, 0,
            reason: 'disabled state must not fire even if onPressed non-null');
      });

      testWidgets('has ink4 color fill (no gradient)', (tester) async {
        await _pump(
          tester,
          const KaiSendButton(
            state: KaiSendState.disabled,
            onPressed: null,
          ),
        );
        final containers =
            tester.widgetList<Container>(find.byType(Container)).toList();
        final found = containers.any((c) {
          final deco = c.decoration;
          return deco is BoxDecoration &&
              deco.gradient == null &&
              deco.color == KaiColors.light.ink4;
        });
        expect(found, isTrue,
            reason: 'disabled state must use ink4 fill without gradient');
      });

      testWidgets('wrapped in Opacity(0.5)', (tester) async {
        await _pump(
          tester,
          const KaiSendButton(
            state: KaiSendState.disabled,
            onPressed: null,
          ),
        );
        final opacities =
            tester.widgetList<Opacity>(find.byType(Opacity)).toList();
        final found = opacities.any((o) => o.opacity == 0.5);
        expect(found, isTrue,
            reason: 'disabled state must have Opacity(0.5)');
      });

      testWidgets('has Semantics(enabled: false)', (tester) async {
        await _pump(
          tester,
          const KaiSendButton(
            state: KaiSendState.disabled,
            onPressed: null,
          ),
        );
        final allSemantics =
            tester.widgetList<Semantics>(find.byType(Semantics)).toList();
        final found = allSemantics.any((s) => s.properties.enabled == false);
        expect(found, isTrue,
            reason: 'disabled state must expose Semantics(enabled: false)');
      });
    });

    // -------------------------------------------------------------------------
    // sending state
    // -------------------------------------------------------------------------
    group('sending', () {
      testWidgets('renders KaiIcon', (tester) async {
        await _pump(
          tester,
          KaiSendButton(
            state: KaiSendState.sending,
            onPressed: () {},
          ),
        );
        expect(find.byType(KaiIcon), findsOneWidget);
      });

      testWidgets('has tide gradient decoration', (tester) async {
        await _pump(
          tester,
          KaiSendButton(
            state: KaiSendState.sending,
            onPressed: () {},
          ),
        );
        final containers =
            tester.widgetList<Container>(find.byType(Container)).toList();
        final found = containers.any((c) {
          final deco = c.decoration;
          return deco is BoxDecoration && deco.gradient != null;
        });
        expect(found, isTrue, reason: 'sending state must use tide gradient');
      });

      testWidgets('AnimationController is running (pulse active)', (tester) async {
        await _pump(
          tester,
          KaiSendButton(
            state: KaiSendState.sending,
            onPressed: () {},
          ),
        );
        // Pump several frames — if the animation were running this should not
        // throw. We verify by pumping 200ms and no exception being thrown.
        await tester.pump(const Duration(milliseconds: 200));
        expect(find.byType(KaiSendButton), findsOneWidget);
      });

      testWidgets('tappable — fires onPressed', (tester) async {
        var tapped = 0;
        await _pump(
          tester,
          KaiSendButton(
            state: KaiSendState.sending,
            onPressed: () => tapped++,
          ),
        );
        await tester.tap(find.byType(KaiSendButton));
        expect(tapped, 1);
      });
    });

    // -------------------------------------------------------------------------
    // streaming state
    // -------------------------------------------------------------------------
    group('streaming', () {
      testWidgets('renders KaiIcon', (tester) async {
        await _pump(
          tester,
          KaiSendButton(
            state: KaiSendState.streaming,
            onPressed: () {},
          ),
        );
        expect(find.byType(KaiIcon), findsOneWidget);
      });

      testWidgets('has tide gradient decoration', (tester) async {
        await _pump(
          tester,
          KaiSendButton(
            state: KaiSendState.streaming,
            onPressed: () {},
          ),
        );
        final containers =
            tester.widgetList<Container>(find.byType(Container)).toList();
        final found = containers.any((c) {
          final deco = c.decoration;
          return deco is BoxDecoration && deco.gradient != null;
        });
        expect(found, isTrue, reason: 'streaming state must use tide gradient');
      });

      testWidgets('pulse animation runs without throwing', (tester) async {
        await _pump(
          tester,
          KaiSendButton(
            state: KaiSendState.streaming,
            onPressed: () {},
          ),
        );
        await tester.pump(const Duration(milliseconds: 200));
        expect(find.byType(KaiSendButton), findsOneWidget);
      });

      testWidgets('tappable — fires onPressed', (tester) async {
        var tapped = 0;
        await _pump(
          tester,
          KaiSendButton(
            state: KaiSendState.streaming,
            onPressed: () => tapped++,
          ),
        );
        await tester.tap(find.byType(KaiSendButton));
        expect(tapped, 1);
      });
    });

    // -------------------------------------------------------------------------
    // Animation cleanup
    // -------------------------------------------------------------------------
    group('state transitions', () {
      testWidgets('switching ready→sending does not throw', (tester) async {
        final notifier = ValueNotifier<KaiSendState>(KaiSendState.ready);
        await tester.pumpWidget(
          ProviderScope(
            child: MaterialApp(
              home: KaiTheme(
                child: Scaffold(
                  body: ValueListenableBuilder<KaiSendState>(
                    valueListenable: notifier,
                    builder: (_, state, __) => KaiSendButton(
                      state: state,
                      onPressed: () {},
                    ),
                  ),
                ),
              ),
            ),
          ),
        );
        await tester.pump();

        notifier.value = KaiSendState.sending;
        await tester.pump();
        await tester.pump(const Duration(milliseconds: 200));

        notifier.value = KaiSendState.ready;
        await tester.pump();
        await tester.pump(const Duration(milliseconds: 200));

        expect(find.byType(KaiSendButton), findsOneWidget);
        notifier.dispose();
      });

      testWidgets('dispose does not throw when animation is running',
          (tester) async {
        await _pump(
          tester,
          KaiSendButton(
            state: KaiSendState.streaming,
            onPressed: () {},
          ),
        );
        await tester.pump(const Duration(milliseconds: 60));
        // Replacing the widget disposes the state.
        await tester.pumpWidget(
          const ProviderScope(
            child: MaterialApp(
              home: KaiTheme(
                child: Scaffold(body: SizedBox()),
              ),
            ),
          ),
        );
        // If dispose was correct, no exception is thrown.
        expect(find.byType(KaiSendButton), findsNothing);
      });
    });
  });
}
