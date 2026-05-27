import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:kai_app/core/providers/root.dart';
import 'package:kai_app/design_system/molecules/kai_settings_group.dart';
import 'package:kai_app/design_system/theme/kai_theme.dart';
import 'package:kai_app/design_system/tokens/kai_tokens.dart';

Future<void> _pump(WidgetTester tester, Widget child) async {
  await tester.pumpWidget(
    ProviderScope(
      overrides: <Override>[
        themeModeProvider.overrideWith((ref) => ThemeMode.light),
      ],
      child: MaterialApp(
        home: KaiTheme(child: Scaffold(body: child)),
      ),
    ),
  );
  await tester.pump();
}

void main() {
  group('KaiSettingsGroup', () {
    testWidgets('renders label when provided', (tester) async {
      await _pump(
        tester,
        const KaiSettingsGroup(
          label: 'внешний вид',
          children: [Text('row1')],
        ),
      );
      expect(find.text('внешний вид'), findsOneWidget);
    });

    testWidgets('no label when null', (tester) async {
      await _pump(
        tester,
        const KaiSettingsGroup(
          children: [Text('row1')],
        ),
      );
      expect(find.text('внешний вид'), findsNothing);
      expect(find.text('row1'), findsOneWidget);
    });

    testWidgets('danger uses surface bg + negative-wash border',
        (tester) async {
      await _pump(
        tester,
        const KaiSettingsGroup(
          danger: true,
          children: [Text('row1')],
        ),
      );
      final container = tester
          .widgetList<Container>(
            find.descendant(
              of: find.byType(KaiSettingsGroup),
              matching: find.byType(Container),
            ),
          )
          .firstWhere((c) => (c.decoration! as BoxDecoration).border != null);
      final dec = container.decoration! as BoxDecoration;
      expect(dec.color, KaiTokens.light.colors.surface);
      final border = dec.border! as Border;
      expect(border.top.color, KaiTokens.light.colors.negativeWash);
    });

    testWidgets('non-danger uses surface-2 bg', (tester) async {
      await _pump(
        tester,
        const KaiSettingsGroup(
          children: [Text('row1')],
        ),
      );
      final container = tester
          .widgetList<Container>(
            find.descendant(
              of: find.byType(KaiSettingsGroup),
              matching: find.byType(Container),
            ),
          )
          .firstWhere((c) {
        final dec = c.decoration;
        return dec is BoxDecoration && dec.color == KaiTokens.light.colors.surface2;
      });
      final dec = container.decoration! as BoxDecoration;
      expect(dec.color, KaiTokens.light.colors.surface2);
    });
  });
}
