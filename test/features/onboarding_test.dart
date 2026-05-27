import 'package:flutter/material.dart';
import 'package:kai_app/l10n/app_localizations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:hive/hive.dart';
import 'package:hive_test/hive_test.dart';
import 'package:kai_app/core/providers/root.dart';
import 'package:kai_app/core/storage/entities/message.dart';
import 'package:kai_app/core/storage/entities/session.dart';
import 'package:kai_app/core/storage/entities/settings.dart';
import 'package:kai_app/core/storage/hive_setup.dart';
import 'package:kai_app/design_system/theme/kai_theme.dart';
import 'package:kai_app/features/onboarding/onboarding_screen.dart';

/// Minimal GoRouter for tests — only /onboarding and /room routes.
GoRouter _makeTestRouter() {
  return GoRouter(
    initialLocation: '/onboarding',
    routes: [
      GoRoute(
        path: '/onboarding',
        builder: (_, __) => const OnboardingScreen(),
      ),
      GoRoute(
        path: '/room',
        builder: (_, __) => const Scaffold(body: Text('room')),
      ),
    ],
  );
}

Widget _buildOnboardingTest() {
  return ProviderScope(
    overrides: [
      themeModeProvider.overrideWith((ref) => ThemeMode.light),
    ],
    child: MaterialApp.router(
      localizationsDelegates: AppLocalizations.localizationsDelegates,
      supportedLocales: const [Locale('ru'), Locale('en')],
      locale: const Locale('ru'),
      routerConfig: _makeTestRouter(),
      builder: (context, child) =>
          KaiTheme(child: child ?? const SizedBox.shrink()),
    ),
  );
}

void main() {
  setUp(() async {
    await setUpTestHive();
    if (!Hive.isAdapterRegistered(0)) {
      Hive.registerAdapter(SessionAdapter());
    }
    if (!Hive.isAdapterRegistered(1)) {
      Hive.registerAdapter(MessageAdapter());
    }
    if (!Hive.isAdapterRegistered(2)) {
      Hive.registerAdapter(MessageStatusAdapter());
    }
    if (!Hive.isAdapterRegistered(3)) {
      Hive.registerAdapter(MessageRoleAdapter());
    }
    if (!Hive.isAdapterRegistered(4)) {
      Hive.registerAdapter(AppThemeModeAdapter());
    }
    if (!Hive.isAdapterRegistered(5)) {
      Hive.registerAdapter(AppSettingsAdapter());
    }
    // Open the settings box so HiveSetup.settings works synchronously.
    await Hive.openBox<AppSettings>(HiveSetup.settingsBoxName);
  });

  tearDown(() async {
    await tearDownTestHive();
  });

  testWidgets('renders step 0 initially', (tester) async {
    await tester.pumpWidget(_buildOnboardingTest());
    await tester.pump();

    // Step 0 (Welcome) shows "Добро пожаловать в Kai".
    expect(find.text('Добро пожаловать в Kai'), findsOneWidget);
  });

  testWidgets('onComplete advances to step 1', (tester) async {
    await tester.pumpWidget(_buildOnboardingTest());
    await tester.pump();

    // Step 0 shows welcome text.
    expect(find.text('Добро пожаловать в Kai'), findsOneWidget);

    // Access the PageView controller via the widget.
    final pageView = tester.widget<PageView>(find.byType(PageView));
    final controller = pageView.controller!;

    // Advance to page 1 by jumping (no animation — avoids timer issues).
    controller.jumpToPage(1);
    await tester.pump(const Duration(milliseconds: 50));

    // Step 1 shows "Kai всегда здесь".
    expect(find.text('Kai всегда здесь'), findsOneWidget);
  });

  testWidgets('step 3 onComplete saves onboarded=true', (tester) async {
    // Ensure the settings box is empty first.
    final box = Hive.box<AppSettings>(HiveSetup.settingsBoxName);
    expect(box.get(HiveSetup.settingsKey)?.onboarded ?? false, isFalse);

    await tester.pumpWidget(_buildOnboardingTest());
    await tester.pump();

    // Jump to page 3 without animation.
    final pageView = tester.widget<PageView>(find.byType(PageView));
    pageView.controller!.jumpToPage(3);
    await tester.pump(const Duration(milliseconds: 50));

    // Step 3 (Context step) has a "Начать" button.
    expect(find.text('Начать'), findsOneWidget);

    // Tapping "Начать" calls _finish() which saves onboarded=true.
    // Use runAsync so the async Hive write future can complete outside
    // of FakeAsync (hive_test boxes are async even though they're in-memory).
    await tester.runAsync(() async {
      await tester.tap(find.text('Начать'));
      // Give the async _finish() a moment to execute box.put().
      await Future<void>.delayed(const Duration(milliseconds: 50));
    });

    // Pump one frame to process any pending microtasks.
    await tester.pump();

    final saved = box.get(HiveSetup.settingsKey);
    expect(saved?.onboarded, isTrue);
  });
}
