import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:kai_app/core/design/theme/app_theme.dart';
import 'package:kai_app/core/models/tool_source.dart';
import 'package:kai_app/features/country/data/country_tool_repository.dart';
import 'package:kai_app/features/country/domain/country_tool_result.dart';
import 'package:kai_app/features/country/logic/favourites_notifier.dart';
import 'package:kai_app/features/country/presentation/country_detail_screen.dart';

// Override countryToolProvider so tabs resolve immediately with fake data.
final _fakeCountryToolProvider = countryToolProvider.overrideWith(
  (ref, params) async {
    final (_, tool) = params;
    return CountryToolResult(
      content: '## $tool\n\nФейковые данные для теста.',
      sources: [
        ToolSource(
          tool: tool,
          source: 'test.example.com',
          sourceDisplayName: 'Test Source',
        ),
      ],
    );
  },
);

Widget _wrap(String iso2) {
  final router = GoRouter(
    initialLocation: '/country/$iso2',
    routes: [
      GoRoute(
        path: '/country/:iso2',
        builder: (_, state) => CountryDetailScreen(
          iso2: state.pathParameters['iso2']!.toUpperCase(),
        ),
      ),
    ],
  );

  return ProviderScope(
    overrides: [
      favouritesProvider.overrideWith((_) => FavouritesNotifier.inMemory()),
      _fakeCountryToolProvider,
    ],
    child: MaterialApp.router(
      theme: AppTheme.light,
      routerConfig: router,
    ),
  );
}

void main() {
  // ── APP-D2 ────────────────────────────────────────────────────────────────

  testWidgets('CountryDetailScreen shows country name in AppBar',
      (tester) async {
    await tester.pumpWidget(_wrap('TH'));
    await tester.pumpAndSettle();
    expect(find.text('Таиланд'), findsAtLeast(1));
  });

  testWidgets('CountryDetailScreen shows flag emoji', (tester) async {
    await tester.pumpWidget(_wrap('JP'));
    await tester.pumpAndSettle();
    expect(find.text('🇯🇵'), findsAtLeast(1));
  });

  testWidgets('CountryDetailScreen renders 6 tabs', (tester) async {
    await tester.pumpWidget(_wrap('TH'));
    await tester.pumpAndSettle();
    expect(find.byType(Tab), findsNWidgets(6));
  });

  testWidgets('CountryDetailScreen shows Виза tab label', (tester) async {
    await tester.pumpWidget(_wrap('TH'));
    await tester.pumpAndSettle();
    expect(find.text('Виза'), findsOneWidget);
  });

  testWidgets('CountryDetailScreen shows all tab labels', (tester) async {
    await tester.pumpWidget(_wrap('TH'));
    await tester.pumpAndSettle();
    expect(find.text('Риски'), findsOneWidget);
    expect(find.text('Маршрут'), findsOneWidget);
    expect(find.text('Стоимость'), findsOneWidget);
    expect(find.text('Здоровье'), findsOneWidget);
    expect(find.text('Экстренно'), findsOneWidget);
  });

  testWidgets('CountryDetailScreen Visa tab loads and renders content',
      (tester) async {
    await tester.pumpWidget(_wrap('TH'));
    await tester.pumpAndSettle();
    // First tab (Виза) resolves via fake provider — content contains tool key
    expect(find.textContaining('visa_checker'), findsAtLeast(1));
  });

  testWidgets('CountryDetailScreen tapping Risk tab loads content',
      (tester) async {
    await tester.pumpWidget(_wrap('TH'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Риски'));
    await tester.pumpAndSettle();
    expect(find.textContaining('risk_assessment'), findsAtLeast(1));
  });

  testWidgets('CountryDetailScreen tapping Emergency tab loads content',
      (tester) async {
    await tester.pumpWidget(_wrap('TH'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Экстренно'));
    await tester.pumpAndSettle();
    expect(find.textContaining('emergency_contacts'), findsAtLeast(1));
  });

  testWidgets('CountryDetailScreen handles unknown iso2 gracefully',
      (tester) async {
    await tester.pumpWidget(_wrap('XX'));
    await tester.pumpAndSettle();
    // Unknown code displayed as-is
    expect(find.text('XX'), findsAtLeast(1));
  });
}
