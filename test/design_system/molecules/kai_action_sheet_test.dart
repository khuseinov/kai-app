import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:kai_app/core/providers/root.dart';
import 'package:kai_app/design_system/atoms/kai_icon.dart';
import 'package:kai_app/design_system/molecules/kai_action_sheet.dart';
import 'package:kai_app/design_system/theme/kai_theme.dart';

Future<void> _pump(WidgetTester tester, Widget child) async {
  await tester.pumpWidget(
    ProviderScope(
      overrides: <Override>[
        themeModeProvider.overrideWith((ref) => ThemeMode.light),
      ],
      child: MaterialApp(
        home: KaiTheme(
          child: Scaffold(
            body: Align(alignment: Alignment.bottomCenter, child: child),
          ),
        ),
      ),
    ),
  );
  await tester.pump();
}

void main() {
  group('KaiActionSheet', () {
    testWidgets('renders one row per item', (tester) async {
      await _pump(
        tester,
        KaiActionSheet(
          items: [
            ActionSheetItem(
              icon: KaiIconName.plus,
              title: 'Новый чат',
              meta: '⌘N',
              onTap: () {},
            ),
            ActionSheetItem(
              icon: KaiIconName.settings,
              title: 'Настройки',
              onTap: () {},
            ),
            ActionSheetItem(
              icon: KaiIconName.close,
              title: 'Очистить сессию',
              danger: true,
              onTap: () {},
            ),
          ],
        ),
      );
      expect(find.text('Новый чат'), findsOneWidget);
      expect(find.text('Настройки'), findsOneWidget);
      expect(find.text('Очистить сессию'), findsOneWidget);
      expect(find.text('⌘N'), findsOneWidget);
    });

    testWidgets('tap on item fires onTap', (tester) async {
      var taps = 0;
      await _pump(
        tester,
        KaiActionSheet(
          items: [
            ActionSheetItem(
              icon: KaiIconName.plus,
              title: 'Новый чат',
              onTap: () => taps++,
            ),
          ],
        ),
      );
      await tester.tap(find.text('Новый чат'));
      await tester.pump();
      expect(taps, 1);
    });

    testWidgets('danger variant uses negative for title', (tester) async {
      await _pump(
        tester,
        KaiActionSheet(
          items: [
            ActionSheetItem(
              icon: KaiIconName.close,
              title: 'Удалить',
              danger: true,
              onTap: () {},
            ),
          ],
        ),
      );
      final text = tester.widget<Text>(find.text('Удалить'));
      // Canon: danger title = negative #C44A3C (light)
      expect(text.style?.color, const Color(0xFFC44A3C));
    });
  });
}
