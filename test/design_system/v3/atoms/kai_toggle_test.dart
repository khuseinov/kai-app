import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:kai_app/design_system/tokens/kai_tokens.dart';
import 'package:kai_app/design_system/v3/atoms/kai_toggle.dart';

import '../../../test_helpers.dart';

void main() {
  group('v3/KaiToggle', () {
    // -------------------------------------------------------------------------
    // ON state
    // -------------------------------------------------------------------------
    group('on state', () {
      testWidgets('track uses accent color when value=true', (tester) async {
        await tester.pumpWidget(
          buildTestWidget(
            KaiToggle(value: true, onChanged: (_) {}),
          ),
        );
        await tester.pump();
        final containers =
            tester.widgetList<AnimatedContainer>(find.byType(AnimatedContainer)).toList();
        final found = containers.any((c) {
          final deco = c.decoration;
          return deco is BoxDecoration &&
              deco.color == KaiColors.light.accent;
        });
        expect(found, isTrue,
            reason: 'track must use accent color when value=true');
      });

      testWidgets('thumb aligns to centerRight when value=true', (tester) async {
        await tester.pumpWidget(
          buildTestWidget(
            KaiToggle(value: true, onChanged: (_) {}),
          ),
        );
        await tester.pump();
        final aligned =
            tester.widgetList<AnimatedAlign>(find.byType(AnimatedAlign)).toList();
        final found =
            aligned.any((a) => a.alignment == Alignment.centerRight);
        expect(found, isTrue,
            reason: 'thumb must align right when value=true');
      });
    });

    // -------------------------------------------------------------------------
    // OFF state
    // -------------------------------------------------------------------------
    group('off state', () {
      testWidgets('track uses surface3 color when value=false', (tester) async {
        await tester.pumpWidget(
          buildTestWidget(
            KaiToggle(value: false, onChanged: (_) {}),
          ),
        );
        await tester.pump();
        final containers =
            tester.widgetList<AnimatedContainer>(find.byType(AnimatedContainer)).toList();
        final found = containers.any((c) {
          final deco = c.decoration;
          return deco is BoxDecoration &&
              deco.color == KaiColors.light.surface3;
        });
        expect(found, isTrue,
            reason: 'track must use surface3 color when value=false');
      });

      testWidgets('thumb aligns to centerLeft when value=false', (tester) async {
        await tester.pumpWidget(
          buildTestWidget(
            KaiToggle(value: false, onChanged: (_) {}),
          ),
        );
        await tester.pump();
        final aligned =
            tester.widgetList<AnimatedAlign>(find.byType(AnimatedAlign)).toList();
        final found =
            aligned.any((a) => a.alignment == Alignment.centerLeft);
        expect(found, isTrue,
            reason: 'thumb must align left when value=false');
      });
    });

    // -------------------------------------------------------------------------
    // Interaction
    // -------------------------------------------------------------------------
    group('interaction', () {
      testWidgets('tapping fires onChanged with !value', (tester) async {
        final received = <bool>[];
        await tester.pumpWidget(
          buildTestWidget(
            KaiToggle(value: false, onChanged: received.add),
          ),
        );
        await tester.pump();
        await tester.tap(find.byType(KaiToggle));
        expect(received, [true],
            reason: 'onChanged must fire with !value on tap');
      });

      testWidgets('tapping when value=true fires onChanged with false', (tester) async {
        final received = <bool>[];
        await tester.pumpWidget(
          buildTestWidget(
            KaiToggle(value: true, onChanged: received.add),
          ),
        );
        await tester.pump();
        await tester.tap(find.byType(KaiToggle));
        expect(received, [false]);
      });

      testWidgets('null onChanged disables tap — no callback fired', (tester) async {
        await tester.pumpWidget(
          buildTestWidget(
            const KaiToggle(value: false, onChanged: null),
          ),
        );
        await tester.pump();
        // Tapping should not throw and callback is not called.
        await tester.tap(find.byType(KaiToggle), warnIfMissed: false);
        // No assertion on callback — just ensure no error + Opacity 0.5.
      });

      testWidgets('disabled (null onChanged) wraps in Opacity(0.5)', (tester) async {
        await tester.pumpWidget(
          buildTestWidget(
            const KaiToggle(value: false, onChanged: null),
          ),
        );
        await tester.pump();
        final opacities =
            tester.widgetList<Opacity>(find.byType(Opacity)).toList();
        final found = opacities.any((o) => o.opacity == 0.5);
        expect(found, isTrue,
            reason: 'disabled toggle must have Opacity(0.5)');
      });
    });

    // -------------------------------------------------------------------------
    // Semantics
    // -------------------------------------------------------------------------
    group('semantics', () {
      testWidgets('exposes toggled=true when value=true', (tester) async {
        await tester.pumpWidget(
          buildTestWidget(
            KaiToggle(value: true, onChanged: (_) {}),
          ),
        );
        await tester.pump();
        final all =
            tester.widgetList<Semantics>(find.byType(Semantics)).toList();
        final found = all.any((s) => s.properties.toggled == true);
        expect(found, isTrue,
            reason: 'Semantics must expose toggled=true when value=true');
      });

      testWidgets('exposes toggled=false when value=false', (tester) async {
        await tester.pumpWidget(
          buildTestWidget(
            KaiToggle(value: false, onChanged: (_) {}),
          ),
        );
        await tester.pump();
        final all =
            tester.widgetList<Semantics>(find.byType(Semantics)).toList();
        final found = all.any((s) => s.properties.toggled == false);
        expect(found, isTrue,
            reason: 'Semantics must expose toggled=false when value=false');
      });
    });

    // -------------------------------------------------------------------------
    // Thumb shadow
    // -------------------------------------------------------------------------
    group('thumb shadow', () {
      testWidgets('thumb Container carries KaiShadow.thumb', (tester) async {
        await tester.pumpWidget(
          buildTestWidget(
            KaiToggle(value: false, onChanged: (_) {}),
          ),
        );
        await tester.pump();
        final containers =
            tester.widgetList<Container>(find.byType(Container)).toList();
        final found = containers.any((c) {
          final deco = c.decoration;
          return deco is BoxDecoration &&
              deco.boxShadow != null &&
              deco.boxShadow!.isNotEmpty &&
              // Neutral black — not tide-tinted.
              deco.boxShadow!.any((s) => s.color == const Color(0x2E000000));
        });
        expect(found, isTrue,
            reason: 'thumb must carry KaiShadow.thumb (neutral black shadow)');
      });
    });
  });
}
