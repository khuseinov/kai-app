import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:kai_app/core/providers/root.dart';
import 'package:kai_app/design_system/molecules/kai_app_bar.dart';
import 'package:kai_app/design_system/theme/kai_theme.dart';
import 'package:kai_app/l10n/app_localizations.dart';
import '../../test_helpers.dart';

// ---------------------------------------------------------------------------
// Helper — wraps KaiAppBar inside a real Navigator + KaiTheme.
// ---------------------------------------------------------------------------

const _backKey = Key('kai_app_bar_back');

Widget _withNav({
  required KaiAppBar appBar,
  Widget? pushRoute,
}) {
  return ProviderScope(
    overrides: [
      themeModeProvider.overrideWith(() => MockThemeModeNotifier(ThemeMode.light)),
    ],
    child: MaterialApp(
      localizationsDelegates: AppLocalizations.localizationsDelegates,
      supportedLocales: const [Locale('ru'), Locale('en')],
      locale: const Locale('ru'),
      home: KaiTheme(
        child: Scaffold(
          body: Builder(
            builder: (context) => Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                appBar,
                if (pushRoute != null)
                  ElevatedButton(
                    onPressed: () => Navigator.of(context).push(
                      MaterialPageRoute<void>(builder: (_) => pushRoute),
                    ),
                    child: const Text('push'),
                  ),
              ],
            ),
          ),
        ),
      ),
    ),
  );
}

void main() {
  group('v3/KaiAppBar', () {
    // -------------------------------------------------------------------------
    // Title rendering
    // -------------------------------------------------------------------------

    testWidgets('renders title text', (tester) async {
      await tester.pumpWidget(
        _withNav(appBar: const KaiAppBar(title: 'Настройки')),
      );
      await tester.pump();
      expect(find.text('Настройки'), findsOneWidget);
    });

    // -------------------------------------------------------------------------
    // Back button — ModalRoute-aware visibility (Key: 'kai_app_bar_back')
    // -------------------------------------------------------------------------

    testWidgets('no back button on root route (canPop==false, no callback)',
        (tester) async {
      await tester.pumpWidget(
        _withNav(appBar: const KaiAppBar(title: 'Root')),
      );
      await tester.pump();
      // Root route: ModalRoute.canPop==false, no callback → back button absent.
      expect(find.byKey(_backKey), findsNothing);
    });

    testWidgets('back button hidden on root, returns after push+pop cycle',
        (tester) async {
      await tester.pumpWidget(
        _withNav(
          appBar: const KaiAppBar(title: 'Root'),
          pushRoute: Scaffold(
            appBar: AppBar(title: const Text('Child')),
            body: const SizedBox.shrink(),
          ),
        ),
      );
      await tester.pump();
      // Root — no back button yet.
      expect(find.byKey(_backKey), findsNothing);

      // Push child route so canPop becomes true.
      await tester.tap(find.text('push'));
      await tester.pumpAndSettle();

      // Pop back to root.
      final nav = tester.state<NavigatorState>(find.byType(Navigator));
      nav.pop();
      await tester.pumpAndSettle();

      // Root again — canPop is false again → no back button.
      expect(find.text('Root'), findsOneWidget);
      expect(find.byKey(_backKey), findsNothing);
    });

    testWidgets('back button shown when onBackPressed is provided',
        (tester) async {
      await tester.pumpWidget(
        _withNav(
          appBar: KaiAppBar(
            title: 'Settings',
            onBackPressed: () {},
          ),
        ),
      );
      await tester.pump();
      // onBackPressed != null → hasBack==true → back button present.
      expect(find.byKey(_backKey), findsOneWidget);
    });

    testWidgets('tapping back button calls onBackPressed', (tester) async {
      var tapped = false;
      await tester.pumpWidget(
        _withNav(
          appBar: KaiAppBar(
            title: 'Назад',
            onBackPressed: () => tapped = true,
          ),
        ),
      );
      await tester.pump();
      await tester.tap(find.byKey(_backKey));
      await tester.pump();
      expect(tapped, isTrue);
    });

    // -------------------------------------------------------------------------
    // Trailing widget
    // -------------------------------------------------------------------------

    testWidgets('renders trailing widget when provided', (tester) async {
      await tester.pumpWidget(
        _withNav(
          appBar: const KaiAppBar(
            title: 'Title',
            trailing: Icon(Icons.more_vert),
          ),
        ),
      );
      await tester.pump();
      expect(find.byIcon(Icons.more_vert), findsOneWidget);
    });

    // -------------------------------------------------------------------------
    // preferredSize — used by Scaffold.appBar
    // -------------------------------------------------------------------------

    test('preferredSize height is 44', () {
      const bar = KaiAppBar(title: 'X');
      expect(bar.preferredSize.height, 44);
    });
  });
}
