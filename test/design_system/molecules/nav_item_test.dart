import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:kai_app/core/providers/root.dart';
import 'package:kai_app/design_system/atoms/kai_icon.dart';
import 'package:kai_app/design_system/molecules/nav_item.dart';
import 'package:kai_app/design_system/theme/kai_theme.dart';
import 'package:kai_app/design_system/tokens/kai_tokens.dart';

Future<void> _pump(
  WidgetTester tester,
  Widget child, {
  ThemeMode mode = ThemeMode.light,
}) async {
  await tester.pumpWidget(
    ProviderScope(
      overrides: <Override>[
        themeModeProvider.overrideWith((ref) => mode),
      ],
      child: MaterialApp(
        home: KaiTheme(
          child: Scaffold(body: child),
        ),
      ),
    ),
  );
  await tester.pump();
}

void main() {
  group('NavItem', () {
    testWidgets('renders label', (WidgetTester tester) async {
      await _pump(tester, const NavItem(label: 'Inbox'));
      expect(find.text('Inbox'), findsOneWidget);
    });

    testWidgets('active state paints accent-wash background',
        (WidgetTester tester) async {
      await _pump(tester, const NavItem(label: 'Active', active: true));

      // Find the DecoratedBox produced by NavItem itself.
      final decorated = tester.widgetList<DecoratedBox>(
        find.descendant(
          of: find.byType(NavItem),
          matching: find.byType(DecoratedBox),
        ),
      );
      final hasAccentWash = decorated.any((d) {
        final dec = d.decoration;
        if (dec is! BoxDecoration) return false;
        return dec.color == KaiTokens.light.colors.accentWash;
      });
      expect(hasAccentWash, isTrue,
          reason: 'active NavItem must paint accentWash');
    });

    testWidgets('inactive state has no accent-wash',
        (WidgetTester tester) async {
      await _pump(tester, const NavItem(label: 'Idle'));
      final decorated = tester.widgetList<DecoratedBox>(
        find.descendant(
          of: find.byType(NavItem),
          matching: find.byType(DecoratedBox),
        ),
      );
      final hasAccentWash = decorated.any((d) {
        final dec = d.decoration;
        if (dec is! BoxDecoration) return false;
        return dec.color == KaiTokens.light.colors.accentWash;
      });
      expect(hasAccentWash, isFalse);
    });

    testWidgets('onTap fires', (WidgetTester tester) async {
      var taps = 0;
      await _pump(
        tester,
        NavItem(label: 'Tap me', onTap: () => taps++),
      );
      await tester.tap(find.text('Tap me'));
      await tester.pumpAndSettle();
      expect(taps, 1);
    });

    testWidgets('renders icon + trailing alongside label',
        (WidgetTester tester) async {
      await _pump(
        tester,
        const NavItem(
          label: 'Folder',
          icon: KaiIconName.search,
          trailing: Text('3'),
        ),
      );
      expect(find.text('Folder'), findsOneWidget);
      expect(find.text('3'), findsOneWidget);
      expect(find.byType(SvgPicture), findsOneWidget);
    });
  });
}
