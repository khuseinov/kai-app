import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:kai_app/core/providers/root.dart';
import 'package:kai_app/core/repositories/mock_memory_repository.dart';
import 'package:kai_app/design_system/atoms/kai_toggle.dart';
import 'package:kai_app/design_system/theme/kai_theme.dart';
import 'package:kai_app/features/memory/memory_screen.dart';
import 'package:kai_app/l10n/app_localizations.dart';

void main() {
  late MockMemoryRepository mockRepo;

  setUp(() {
    mockRepo = MockMemoryRepository();
  });

  Widget pumpMemoryScreen({
    required MockMemoryRepository repository,
    GoRouter? router,
  }) {
    final defaultRouter = router ??
        GoRouter(
          initialLocation: '/memory',
          routes: [
            GoRoute(
              path: '/memory',
              builder: (context, state) => const MemoryScreen(),
            ),
            GoRoute(
              path: '/room',
              builder: (context, state) => const Scaffold(body: Text('Room Screen')),
            ),
          ],
        );

    return ProviderScope(
      overrides: [
        memoryRepositoryProvider.overrideWithValue(repository),
      ],
      child: KaiTheme(
        child: MediaQuery(
          data: const MediaQueryData(disableAnimations: true),
          child: MaterialApp.router(
            localizationsDelegates: AppLocalizations.localizationsDelegates,
            supportedLocales: AppLocalizations.supportedLocales,
            locale: const Locale('ru'),
            routerConfig: defaultRouter,
          ),
        ),
      ),
    );
  }

  group('MemoryScreen Widget Tests', () {
    testWidgets('renders all canonical mockup sections and details', (tester) async {
      // Force screen height to render all sections (avoid lazy ListView skipping)
      await tester.binding.setSurfaceSize(const Size(390, 1400));
      addTearDown(() async => await tester.binding.setSurfaceSize(null));

      await tester.pumpWidget(pumpMemoryScreen(repository: mockRepo));
      await tester.pumpAndSettle();

      final l10n = AppLocalizations.of(tester.element(find.byType(MemoryScreen)));

      // Assert AppBar Title
      expect(find.text(l10n.memoryAppLabel), findsOneWidget);

      // Assert Hero Card contents
      expect(find.text('10 фактов о вас'), findsOneWidget); // 10 seeded facts
      expect(find.text(l10n.memoryLastSaved('12 мин')), findsOneWidget);
      expect(find.byType(KaiToggle), findsOneWidget);

      // Assert Search field
      expect(find.text(l10n.memorySearchPlaceholder), findsOneWidget);

      // Assert Categories and Fact rows exist
      expect(find.text('о вас'), findsOneWidget);
      expect(find.text('предпочтения'), findsOneWidget);
      expect(find.text('ограничения'), findsOneWidget);
      expect(find.text('поездки'), findsOneWidget);

      // Assert specific facts render
      expect(find.text('Гражданин России'), findsOneWidget);
      expect(find.text('Живёт в Алматы'), findsOneWidget);
      expect(find.text('Поезда вместо самолётов при возможности'), findsOneWidget);

      // Assert TTL Badges
      expect(find.text('expires 23h'), findsNWidgets(2));
      expect(find.text('expires 3h'), findsOneWidget);

      // Assert Danger Zone
      expect(find.text(l10n.memoryDangerWipeAll), findsOneWidget);
    });

    testWidgets('toggling memoryEnabled calls repository update', (tester) async {
      await tester.pumpWidget(pumpMemoryScreen(repository: mockRepo));
      await tester.pumpAndSettle();

      final toggleFinder = find.byType(KaiToggle);
      expect(toggleFinder, findsOneWidget);

      // Initially enabled
      expect(await mockRepo.isMemoryEnabled(), isTrue);

      // Tap toggle
      await tester.tap(toggleFinder);
      await tester.pumpAndSettle();

      expect(await mockRepo.isMemoryEnabled(), isFalse);

      // Tap toggle again
      await tester.tap(toggleFinder);
      await tester.pumpAndSettle();

      expect(await mockRepo.isMemoryEnabled(), isTrue);
    });

    testWidgets('filters facts when typing in search bar', (tester) async {
      await tester.binding.setSurfaceSize(const Size(390, 1400));
      addTearDown(() async => await tester.binding.setSurfaceSize(null));

      await tester.pumpWidget(pumpMemoryScreen(repository: mockRepo));
      await tester.pumpAndSettle();

      // Enter search query
      final searchFinder = find.byType(TextField);
      expect(searchFinder, findsOneWidget);

      await tester.enterText(searchFinder, 'Алматы');
      await tester.pump(); // trigger filter, no settle needed since no routing/long animations

      // Verify only matching facts remain
      expect(find.text('Живёт в Алматы'), findsOneWidget);
      expect(find.text('Гражданин России'), findsNothing);
      expect(find.text('Поезда вместо самолётов при возможности'), findsNothing);

      // Clear search
      await tester.enterText(searchFinder, '');
      await tester.pump();

      // Verify all reappear
      expect(find.text('Гражданин России'), findsOneWidget);
      expect(find.text('Живёт в Алматы'), findsOneWidget);
    });

    testWidgets('fact row context menu allows delete and edit', (tester) async {
      await tester.pumpWidget(pumpMemoryScreen(repository: mockRepo));
      await tester.pumpAndSettle();

      final l10n = AppLocalizations.of(tester.element(find.byType(MemoryScreen)));

      // Find the menu dots of the first fact (e.g. Russia citizenship)
      final dotsFinder = find.descendant(
        of: find.widgetWithText(Container, 'Гражданин России'),
        matching: find.byType(GestureDetector),
      );

      // Tap context dots
      await tester.tap(dotsFinder.first);
      await tester.pumpAndSettle();

      // Bottom sheet open - verify items
      expect(find.text(l10n.memoryEditFactAction), findsOneWidget);
      expect(find.text(l10n.memoryDeleteFactAction), findsOneWidget);

      // Tap delete
      await tester.tap(find.text(l10n.memoryDeleteFactAction));
      await tester.pumpAndSettle();

      // Verify deleted from UI and repo
      expect(find.text('Гражданин России'), findsNothing);
      final repoFacts = await mockRepo.getMemoryFacts();
      expect(repoFacts.any((f) => f.text == 'Гражданин России'), isFalse);
    });

    testWidgets('GDPR wipe all clears all facts after confirmation', (tester) async {
      await tester.binding.setSurfaceSize(const Size(390, 1400));
      addTearDown(() async => await tester.binding.setSurfaceSize(null));

      await tester.pumpWidget(pumpMemoryScreen(repository: mockRepo));
      await tester.pumpAndSettle();

      final l10n = AppLocalizations.of(tester.element(find.byType(MemoryScreen)));

      // Verify facts are present initially
      expect(find.text('Гражданин России'), findsOneWidget);

      // Tap GDPR delete row
      await tester.tap(find.text(l10n.memoryDangerWipeAll));
      await tester.pumpAndSettle();

      // Verify confirmation action sheet is visible
      expect(find.text(l10n.memoryWipeConfirmation), findsOneWidget);
      expect(find.text(l10n.memoryWipeConfirmAction), findsOneWidget);

      // Tap confirm "Забыть"
      await tester.tap(find.text(l10n.memoryWipeConfirmAction));
      await tester.pumpAndSettle();

      // Verify facts wiped in UI and mock repo
      expect(find.text('Гражданин России'), findsNothing);
      expect(await mockRepo.getMemoryFacts(), isEmpty);
    });
  });
}
