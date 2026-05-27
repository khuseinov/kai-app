import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:kai_app/core/providers/root.dart';
import 'package:kai_app/design_system/molecules/kai_segmented_control.dart';
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

void main() {
  group('KaiSegmentedControl', () {
    testWidgets('renders all options', (tester) async {
      await _pump(
        tester,
        KaiSegmentedControl(
          options: const ['Авто', 'Светлая', 'Тёмная'],
          selectedIndex: 1,
          onSelected: (_) {},
        ),
      );
      expect(find.text('Авто'), findsOneWidget);
      expect(find.text('Светлая'), findsOneWidget);
      expect(find.text('Тёмная'), findsOneWidget);
    });

    testWidgets('tap fires onSelected with index', (tester) async {
      int? lastIndex;
      await _pump(
        tester,
        KaiSegmentedControl(
          options: const ['A', 'B', 'C'],
          selectedIndex: 0,
          onSelected: (i) => lastIndex = i,
        ),
      );
      await tester.tap(find.text('C'));
      await tester.pump();
      expect(lastIndex, 2);
    });

    testWidgets('active option uses surface bg + ink-1 text', (tester) async {
      await _pump(
        tester,
        KaiSegmentedControl(
          options: const ['A', 'B'],
          selectedIndex: 0,
          onSelected: (_) {},
        ),
      );
      // Active text should be ink-1 (light theme: #111114).
      final active = tester.widget<Text>(find.text('A'));
      expect(active.style?.color, KaiTokens.light.colors.ink1);
      final inactive = tester.widget<Text>(find.text('B'));
      expect(inactive.style?.color, KaiTokens.light.colors.ink3);
    });
  });
}
