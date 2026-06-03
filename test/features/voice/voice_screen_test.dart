import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:kai_app/core/providers/root.dart';
import 'package:kai_app/design_system/theme/kai_theme.dart';
import 'package:kai_app/features/voice/voice_screen.dart';
import 'package:kai_app/l10n/app_localizations.dart';

GoRouter _makeTestRouter() {
  return GoRouter(
    initialLocation: '/voice',
    routes: [
      GoRoute(
        path: '/voice',
        builder: (_, __) => const VoiceScreen(),
      ),
      GoRoute(
        path: '/room',
        builder: (_, __) => const Scaffold(body: Text('room')),
      ),
    ],
  );
}

Widget _buildVoiceTest() {
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
  testWidgets('VoiceScreen renders in idle state initially', (tester) async {
    await tester.pumpWidget(_buildVoiceTest());
    await tester.pump();

    // Check that we see the idle state texts
    expect(find.text('нажмите, чтобы говорить'), findsOneWidget);
    expect(find.text('SWIPE ↑'), findsOneWidget);
    expect(find.text('Kai ожидает'), findsOneWidget);
  });

  testWidgets('Tapping on idle transitions to listening', (tester) async {
    await tester.pumpWidget(_buildVoiceTest());
    await tester.pump();

    // Tap to talk
    await tester.tap(find.byType(VoiceScreen));
    await tester.pump(const Duration(milliseconds: 350));

    expect(find.text('слушаю…'), findsOneWidget);
    expect(find.text('Говорите…'), findsOneWidget);
  });

  testWidgets('Tapping on listening transitions to speaking and animates karaoke', (tester) async {
    await tester.pumpWidget(_buildVoiceTest());
    await tester.pump();

    // Tap once to transition to listening
    await tester.tap(find.byType(VoiceScreen));
    await tester.pump(const Duration(milliseconds: 350));

    // Tap second time to transition to speaking
    await tester.tap(find.byType(VoiceScreen));
    await tester.pump(const Duration(milliseconds: 350));

    expect(find.text('kai говорит'), findsOneWidget);
    // Karaoke widget should exist
    expect(find.text('Синкансэн'), findsOneWidget);
  });

  testWidgets('Swipe up transitions to transcript view and swipe down returns', (tester) async {
    await tester.pumpWidget(_buildVoiceTest());
    await tester.pump();

    // Swipe up
    await tester.fling(find.byType(VoiceScreen), const Offset(0, -300), 1000);
    await tester.pump(const Duration(milliseconds: 350));

    // Should render transcript view time header
    expect(find.text('сегодня · 12:34'), findsOneWidget);
    expect(find.text('НАЖМИТЕ, ЧТОБЫ ВЕРНУТЬСЯ'), findsOneWidget);

    // Tap return button to return to idle
    await tester.tap(find.text('НАЖМИТЕ, ЧТОБЫ ВЕРНУТЬСЯ'));
    await tester.pump(const Duration(milliseconds: 350));

    // Should return to voice layout
    expect(find.text('Kai ожидает'), findsOneWidget);
  });
}
