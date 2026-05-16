import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:kai_app/core/design/theme/app_theme.dart';
import 'package:kai_app/features/country/data/country_iso_list.dart';
import 'package:kai_app/features/country/logic/favourites_notifier.dart';
import 'package:kai_app/features/country/presentation/country_picker_screen.dart';

Widget _wrap({List<String> favs = const []}) {
  final router = GoRouter(
    initialLocation: '/country',
    routes: [
      GoRoute(
        path: '/country',
        builder: (_, __) => const CountryPickerScreen(),
      ),
      GoRoute(
        path: '/country/:iso2',
        builder: (_, state) =>
            Scaffold(body: Text('detail:${state.pathParameters['iso2']}')),
      ),
    ],
  );

  return ProviderScope(
    overrides: [
      favouritesProvider.overrideWith(
        (ref) => FavouritesNotifier.inMemory(favs),
      ),
    ],
    child: MaterialApp.router(
      theme: AppTheme.light,
      routerConfig: router,
    ),
  );
}

void main() {
  // ── APP-D1 ────────────────────────────────────────────────────────────────

  testWidgets('CountryPickerScreen shows country list', (tester) async {
    await tester.pumpWidget(_wrap());
    await tester.pumpAndSettle();
    // First 3 in kCountryList — always visible in default test viewport
    expect(find.text('Таиланд'), findsOneWidget);
    expect(find.text('Вьетнам'), findsOneWidget);
    expect(find.text('Индонезия'), findsOneWidget);
  });

  testWidgets('CountryPickerScreen filters by name', (tester) async {
    await tester.pumpWidget(_wrap());
    await tester.pumpAndSettle();
    // 'таи' matches 'Таиланд' (и = U+0438, not й = U+0439)
    await tester.enterText(find.byType(TextField), 'таи');
    await tester.pumpAndSettle();
    expect(find.text('Таиланд'), findsOneWidget);
    expect(find.text('Япония'), findsNothing);
  });

  testWidgets('CountryPickerScreen filters by ISO code', (tester) async {
    await tester.pumpWidget(_wrap());
    await tester.pumpAndSettle();
    await tester.enterText(find.byType(TextField), 'JP');
    await tester.pumpAndSettle();
    expect(find.text('Япония'), findsOneWidget);
    expect(find.text('Таиланд'), findsNothing);
  });

  testWidgets('CountryPickerScreen shows empty message for no match',
      (tester) async {
    await tester.pumpWidget(_wrap());
    await tester.pumpAndSettle();
    await tester.enterText(find.byType(TextField), 'xyzxyzxyz');
    await tester.pumpAndSettle();
    expect(find.text('Страна не найдена'), findsOneWidget);
  });

  testWidgets('CountryPickerScreen shows Избранное section when favourites set',
      (tester) async {
    await tester.pumpWidget(_wrap(favs: ['TH']));
    await tester.pumpAndSettle();
    expect(find.text('Избранное'), findsOneWidget);
  });

  testWidgets('CountryPickerScreen does not show Избранное section when empty',
      (tester) async {
    await tester.pumpWidget(_wrap());
    await tester.pumpAndSettle();
    expect(find.text('Избранное'), findsNothing);
  });

  testWidgets('flag emoji for TH is 🇹🇭', (tester) async {
    const th = IsoCountry('TH', 'Таиланд');
    expect(th.flag, '🇹🇭');
  });

  testWidgets('flag emoji for JP is 🇯🇵', (tester) async {
    const jp = IsoCountry('JP', 'Япония');
    expect(jp.flag, '🇯🇵');
  });

  testWidgets('clear button appears after typing', (tester) async {
    await tester.pumpWidget(_wrap());
    await tester.pumpAndSettle();
    expect(find.byIcon(Icons.clear), findsNothing);
    await tester.enterText(find.byType(TextField), 'фр');
    await tester.pump();
    expect(find.byIcon(Icons.clear), findsOneWidget);
  });

  testWidgets('clear button resets search', (tester) async {
    await tester.pumpWidget(_wrap());
    await tester.pumpAndSettle();
    await tester.enterText(find.byType(TextField), 'таи');
    await tester.pumpAndSettle();
    // Only Thailand visible while filtered
    expect(find.text('Япония'), findsNothing);
    await tester.tap(find.byIcon(Icons.clear));
    await tester.pumpAndSettle();
    // After clear, first country (Thailand) is visible again
    expect(find.text('Таиланд'), findsOneWidget);
  });

  testWidgets('FavouritesNotifier toggle adds and removes', (tester) async {
    final notifier = FavouritesNotifier.inMemory();
    expect(notifier.state, isEmpty);
    notifier.toggle('TH');
    expect(notifier.state, contains('TH'));
    notifier.toggle('TH');
    expect(notifier.state, isNot(contains('TH')));
  });

  testWidgets('kCountryList contains expected countries', (tester) async {
    expect(kCountryList.map((c) => c.iso2), contains('TH'));
    expect(kCountryList.map((c) => c.iso2), contains('JP'));
    expect(kCountryList.map((c) => c.iso2), contains('US'));
    expect(kCountryList.map((c) => c.iso2), contains('AU'));
    expect(kCountryList.length, greaterThan(50));
  });
}
