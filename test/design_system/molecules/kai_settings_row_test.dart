import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:kai_app/core/providers/root.dart';
import 'package:kai_app/design_system/atoms/kai_icon.dart';
import 'package:kai_app/design_system/molecules/kai_settings_row.dart';
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
  group('KaiSettingsRow', () {
    testWidgets('renders title + subtitle + trailing', (tester) async {
      await _pump(
        tester,
        const KaiSettingsRow(
          icon: KaiIconName.mic,
          title: 'Голосовой ввод',
          subtitle: 'нажмите орб для начала прослушивания',
          trailing: Text('on'),
        ),
      );
      expect(find.text('Голосовой ввод'), findsOneWidget);
      expect(
        find.text('нажмите орб для начала прослушивания'),
        findsOneWidget,
      );
      expect(find.text('on'), findsOneWidget);
    });

    testWidgets('danger flips title to negative colour', (tester) async {
      await _pump(
        tester,
        const KaiSettingsRow(
          icon: KaiIconName.trash,
          title: 'Удалить',
          danger: true,
        ),
      );
      final t = tester.widget<Text>(find.text('Удалить'));
      expect(t.style?.color, KaiTokens.light.colors.negative);
    });

    testWidgets('onTap fires when row tapped', (tester) async {
      var taps = 0;
      await _pump(
        tester,
        KaiSettingsRow(
          icon: KaiIconName.memory,
          title: 'Память',
          onTap: () => taps++,
        ),
      );
      await tester.tap(find.text('Память'));
      await tester.pump();
      expect(taps, 1);
    });
  });
}
