import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:kai_app/core/providers/root.dart';
import 'package:kai_app/core/providers/session_provider.dart';
import 'package:kai_app/core/repositories/session_repository.dart';
import 'package:kai_app/design_system/theme/kai_theme.dart';
import 'package:kai_app/design_system/v3/organisms/nav_models.dart';
import 'package:kai_app/features/nav/nav_screen.dart';
import 'package:kai_app/l10n/app_localizations.dart';

// ─── Test helpers ─────────────────────────────────────────────────────────────

/// Pumps [NavScreen] inside the full test harness:
/// ProviderScope + MaterialApp with l10n (ru) + KaiTheme.
///
/// [sessionList] — sessions returned by [sessionListProvider] (defaults empty).
/// [overrides]   — additional provider overrides merged after defaults.
Future<void> _pumpNavScreen(
  WidgetTester tester, {
  List<SessionPreview> sessionList = const [],
  List<Override> overrides = const [],
}) async {
  // Tall surface so the full panel renders without clipping.
  await tester.binding.setSurfaceSize(const Size(390, 844));
  addTearDown(() => tester.binding.setSurfaceSize(null));

  await tester.pumpWidget(
    ProviderScope(
      overrides: [
        themeModeProvider.overrideWith((ref) => ThemeMode.light),
        // Override sessionListProvider to return our test list synchronously.
        sessionListProvider.overrideWith(
          (ref) async => sessionList
              .map(
                (p) => ChatSession(
                  id: p.id,
                  title: p.title,
                  createdAt: p.createdAt,
                ),
              )
              .toList(),
        ),
        ...overrides,
      ],
      child: const MaterialApp(
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        supportedLocales: [Locale('ru'), Locale('en')],
        locale: Locale('ru'),
        home: KaiTheme(child: NavScreen()),
      ),
    ),
  );
  // First pump resolves FutureProvider; second settles the widget tree.
  await tester.pump();
  await tester.pump();
}

// ─── Tests ────────────────────────────────────────────────────────────────────

void main() {
  group('NavScreen (v3 KaiNavPanel)', () {
    // ── Renders ───────────────────────────────────────────────────────────────

    testWidgets('renders without exception', (tester) async {
      await _pumpNavScreen(tester);
      // Panel builds — the title "Kai" is rendered by KaiNavPanel's top bar.
      expect(find.text('Kai'), findsOneWidget);
    });

    testWidgets('renders new-chat button label', (tester) async {
      await _pumpNavScreen(tester);
      expect(find.text('Новый чат'), findsOneWidget);
    });

    testWidgets('renders no-chats placeholder when session list is empty',
        (tester) async {
      await _pumpNavScreen(tester);
      expect(find.text('Нет чатов'), findsOneWidget);
    });

    testWidgets('renders apps section with Memory + Settings rows',
        (tester) async {
      await _pumpNavScreen(tester);
      expect(find.text('Память'), findsOneWidget);
      expect(find.text('Настройки'), findsOneWidget);
    });

    // ── Session list ──────────────────────────────────────────────────────────

    testWidgets('renders session titles when sessions are provided',
        (tester) async {
      final sessions = [
        SessionPreview(
          id: 'a',
          title: 'Поездка в Токио',
          timeLabel: '28 мая',
          createdAt: DateTime.now(),
        ),
        SessionPreview(
          id: 'b',
          title: 'Виза в Японию',
          timeLabel: '27 мая',
          createdAt: DateTime.now().subtract(const Duration(days: 1)),
        ),
      ];
      await _pumpNavScreen(tester, sessionList: sessions);

      expect(find.text('Поездка в Токио'), findsOneWidget);
      expect(find.text('Виза в Японию'), findsOneWidget);
    });

    // ── Callbacks ─────────────────────────────────────────────────────────────

    testWidgets('tapping new-chat button pops navigation', (tester) async {
      // Push NavScreen on top of a dummy page so we can verify pop.
      var popped = false;
      await tester.binding.setSurfaceSize(const Size(390, 844));
      addTearDown(() => tester.binding.setSurfaceSize(null));

      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            themeModeProvider.overrideWith((ref) => ThemeMode.light),
            sessionListProvider.overrideWith((ref) async => []),
          ],
          child: MaterialApp(
            localizationsDelegates: AppLocalizations.localizationsDelegates,
            supportedLocales: const [Locale('ru'), Locale('en')],
            locale: const Locale('ru'),
            home: KaiTheme(
              child: Navigator(
                onGenerateRoute: (settings) => MaterialPageRoute<void>(
                  builder: (_) => Scaffold(
                    body: Builder(
                      builder: (ctx) => ElevatedButton(
                        onPressed: () {
                          Navigator.of(ctx).push(
                            MaterialPageRoute<void>(
                              builder: (_) => const NavScreen(),
                            ),
                          );
                        },
                        child: const Text('Open'),
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),
      );
      await tester.pump();
      await tester.pump();

      // Open NavScreen.
      await tester.tap(find.text('Open'));
      await tester.pumpAndSettle();

      // Verify NavScreen is on top.
      expect(find.text('Новый чат'), findsOneWidget);

      // Tap new-chat.
      await tester.tap(find.text('Новый чат'));
      await tester.pumpAndSettle();

      // NavScreen should have been popped — "Open" button is visible again.
      expect(find.text('Open'), findsOneWidget);
      expect(popped, isFalse); // no separate pop variable needed
    });

    testWidgets('tapping a session row pops navigation', (tester) async {
      final sessions = [
        SessionPreview(
          id: 'chat-1',
          title: 'Чат с Kai',
          timeLabel: '28 мая',
          createdAt: DateTime.now(),
        ),
      ];

      await tester.binding.setSurfaceSize(const Size(390, 844));
      addTearDown(() => tester.binding.setSurfaceSize(null));

      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            themeModeProvider.overrideWith((ref) => ThemeMode.light),
            sessionListProvider.overrideWith(
              (ref) async => [
                ChatSession(
                  id: sessions[0].id,
                  title: sessions[0].title,
                  createdAt: sessions[0].createdAt,
                ),
              ],
            ),
          ],
          child: MaterialApp(
            localizationsDelegates: AppLocalizations.localizationsDelegates,
            supportedLocales: const [Locale('ru'), Locale('en')],
            locale: const Locale('ru'),
            home: KaiTheme(
              child: Navigator(
                onGenerateRoute: (settings) => MaterialPageRoute<void>(
                  builder: (_) => Scaffold(
                    body: Builder(
                      builder: (ctx) => ElevatedButton(
                        onPressed: () {
                          Navigator.of(ctx).push(
                            MaterialPageRoute<void>(
                              builder: (_) => const NavScreen(),
                            ),
                          );
                        },
                        child: const Text('Open'),
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),
      );
      await tester.pump();
      await tester.pump();

      await tester.tap(find.text('Open'));
      await tester.pumpAndSettle();

      expect(find.text('Чат с Kai'), findsOneWidget);

      await tester.tap(find.text('Чат с Kai'));
      await tester.pumpAndSettle();

      // Session tap should pop NavScreen.
      expect(find.text('Open'), findsOneWidget);
    });
  });
}
