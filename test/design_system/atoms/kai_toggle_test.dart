import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:kai_app/core/providers/root.dart';
import 'package:kai_app/design_system/atoms/kai_toggle.dart';
import 'package:kai_app/design_system/theme/kai_theme.dart';
import 'package:kai_app/design_system/tokens/kai_tokens.dart';

Future<void> _pump(WidgetTester tester, Widget child) async {
  await tester.pumpWidget(
    ProviderScope(
      overrides: <Override>[
        themeModeProvider.overrideWith((ref) => ThemeMode.light),
      ],
      child: MaterialApp(
        home: KaiTheme(child: Scaffold(body: Center(child: child))),
      ),
    ),
  );
  await tester.pump();
}

BoxDecoration _trackDeco(WidgetTester tester) {
  final ac = tester.widget<AnimatedContainer>(
    find.descendant(
      of: find.byType(KaiToggle),
      matching: find.byType(AnimatedContainer),
    ),
  );
  return ac.decoration! as BoxDecoration;
}

void main() {
  group('KaiToggle', () {
    testWidgets('off uses surface-3 track colour', (tester) async {
      await _pump(
        tester,
        KaiToggle(value: false, onChanged: (_) {}),
      );
      expect(_trackDeco(tester).color, KaiTokens.light.colors.surface3);
    });

    testWidgets('on uses accent track colour', (tester) async {
      await _pump(
        tester,
        KaiToggle(value: true, onChanged: (_) {}),
      );
      expect(_trackDeco(tester).color, KaiTokens.light.colors.accent);
    });

    testWidgets('tap fires onChanged with negation', (tester) async {
      bool? lastReceived;
      await _pump(
        tester,
        KaiToggle(value: false, onChanged: (v) => lastReceived = v),
      );
      await tester.tap(find.byType(KaiToggle));
      await tester.pump();
      expect(lastReceived, isTrue);
    });

    testWidgets('null onChanged disables taps', (tester) async {
      await _pump(
        tester,
        const KaiToggle(value: false, onChanged: null),
      );
      // Tapping shouldn't crash; we just verify state didn't bubble.
      await tester.tap(find.byType(KaiToggle));
      await tester.pump();
      // Track colour stayed off-state — confirms no internal flip happened.
      expect(_trackDeco(tester).color, KaiTokens.light.colors.surface3);
    });

    testWidgets('canonical pill geometry: 34 x 20, radius 999', (tester) async {
      await _pump(
        tester,
        KaiToggle(value: false, onChanged: (_) {}),
      );
      final ac = tester.widget<AnimatedContainer>(
        find.descendant(
          of: find.byType(KaiToggle),
          matching: find.byType(AnimatedContainer),
        ),
      );
      expect(ac.constraints?.maxWidth, 34);
      expect(ac.constraints?.maxHeight, 20);
      final radius = (ac.decoration! as BoxDecoration).borderRadius!
          as BorderRadius;
      expect(radius.topLeft, const Radius.circular(999));
    });
  });
}
