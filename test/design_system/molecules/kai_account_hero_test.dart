import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:kai_app/core/providers/root.dart';
import 'package:kai_app/design_system/molecules/kai_account_hero.dart';
import 'package:kai_app/design_system/theme/kai_theme.dart';

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
  group('KaiAccountHero', () {
    testWidgets('renders name + email + initial + plan', (tester) async {
      await _pump(
        tester,
        const KaiAccountHero(
          name: 'Aibek',
          email: 'aibek@wize.ai',
          initial: 'A',
          planLabel: 'plus',
        ),
      );
      expect(find.text('Aibek'), findsOneWidget);
      expect(find.text('aibek@wize.ai'), findsOneWidget);
      expect(find.text('A'), findsOneWidget);
      // Plan label gets uppercased by the badge.
      expect(find.text('PLUS'), findsOneWidget);
    });

    testWidgets('no plan when planLabel is null', (tester) async {
      await _pump(
        tester,
        const KaiAccountHero(
          name: 'X',
          email: 'x@y.z',
          initial: 'X',
        ),
      );
      expect(find.text('PLUS'), findsNothing);
      expect(find.text('FREE'), findsNothing);
    });

    testWidgets('avatar uses tide gradient', (tester) async {
      await _pump(
        tester,
        const KaiAccountHero(
          name: 'X',
          email: 'x@y.z',
          initial: 'X',
        ),
      );
      // Find the avatar Container — the one whose decoration is a circle
      // with a LinearGradient (115° tide).
      final containers = tester.widgetList<Container>(
        find.descendant(
          of: find.byType(KaiAccountHero),
          matching: find.byType(Container),
        ),
      );
      final avatar = containers.firstWhere(
        (c) {
          final dec = c.decoration;
          return dec is BoxDecoration &&
              dec.gradient is LinearGradient &&
              dec.shape == BoxShape.circle;
        },
      );
      final gradient =
          ((avatar.decoration! as BoxDecoration).gradient!) as LinearGradient;
      expect(gradient.colors, [
        const Color(0xFF1B4FB0),
        const Color(0xFF2BA8C9),
        const Color(0xFFF4B589),
      ]);
    });
  });
}
