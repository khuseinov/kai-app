import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:kai_app/core/providers/root.dart';
import 'package:kai_app/design_system/atoms/kai_bottom_sheet_shell.dart';
import 'package:kai_app/design_system/theme/kai_theme.dart';
import 'package:kai_app/design_system/tokens/kai_tokens.dart';

Future<void> _pump(WidgetTester tester, Widget child) async {
  await tester.pumpWidget(
    ProviderScope(
      overrides: <Override>[
        themeModeProvider.overrideWith((ref) => ThemeMode.light),
      ],
      child: MaterialApp(
        home: KaiTheme(
          child: Scaffold(body: Align(alignment: Alignment.bottomCenter, child: child)),
        ),
      ),
    ),
  );
  await tester.pump();
}

void main() {
  group('KaiBottomSheetShell', () {
    testWidgets('renders drag indicator + child', (tester) async {
      await _pump(
        tester,
        const KaiBottomSheetShell(
          child: Text('inner'),
        ),
      );
      expect(find.text('inner'), findsOneWidget);
      // Drag indicator = 36×4 pill via inner Container
      final containers = tester.widgetList<Container>(find.byType(Container));
      final dragIndicator = containers.firstWhere(
        (c) => c.constraints?.maxWidth == 36 && c.constraints?.maxHeight == 4,
        orElse: () => containers.firstWhere(
          (c) {
            final dec = c.decoration;
            return dec is BoxDecoration &&
                dec.borderRadius == BorderRadius.circular(999);
          },
        ),
      );
      // Just confirm we found it via radius-pill match
      final dec = dragIndicator.decoration as BoxDecoration?;
      expect(dec?.borderRadius, BorderRadius.circular(999));
    });

    testWidgets('shell uses surface bg + line top border', (tester) async {
      await _pump(
        tester,
        const KaiBottomSheetShell(child: SizedBox()),
      );
      // Outer Container = shell
      final outer = tester.widget<Container>(
        find.descendant(
          of: find.byType(KaiBottomSheetShell),
          matching: find.byType(Container),
        ).first,
      );
      final dec = outer.decoration! as BoxDecoration;
      expect(dec.color, KaiTokens.light.colors.surface);
      final border = dec.border! as Border;
      expect(border.top.color, KaiTokens.light.colors.line);
      // Canon radius 24 24 0 0
      final radius = dec.borderRadius! as BorderRadius;
      expect(radius.topLeft, const Radius.circular(24));
      expect(radius.topRight, const Radius.circular(24));
      expect(radius.bottomLeft, Radius.zero);
    });
  });
}
