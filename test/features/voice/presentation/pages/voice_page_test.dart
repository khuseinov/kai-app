import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:kai_app/core/providers/root.dart';
import 'package:kai_app/design_system/theme/kai_theme.dart';
import 'package:kai_app/features/voice/presentation/pages/voice_page.dart';
import 'package:kai_app/l10n/app_localizations.dart';

GoRouter _makeTestRouter() {
  return GoRouter(
    initialLocation: '/voice',
    routes: [
      GoRoute(
        path: '/voice',
        builder: (_, __) => const VoicePage(),
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
      themeModeProvider.overrideWith(() => _MockThemeModeNotifier(ThemeMode.light)),
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
  testWidgets('VoicePage renders in idle state initially without back arrow', (tester) async {
    await tester.pumpWidget(_buildVoiceTest());
    await tester.pump();

    // Check that we see the idle state texts
    expect(find.text('нажмите, чтобы говорить'), findsOneWidget);
    expect(find.text('SWIPE ↑ · ТРАНСКРИПЦИЯ'), findsOneWidget);
    expect(find.text('Kai ожидает'), findsOneWidget);
    
    // Back arrow icon must be removed/hidden
    expect(find.byIcon(Icons.arrow_back_ios_new), findsNothing);
  });

  testWidgets('Tapping on idle transitions to listening (and hides hints)', (tester) async {
    await tester.pumpWidget(_buildVoiceTest());
    await tester.pump();

    // Tap to talk
    await tester.tap(find.byType(VoicePage));
    await tester.pump(const Duration(milliseconds: 350));

    // Active state: hints must be hidden
    expect(find.text('нажмите, чтобы говорить'), findsNothing);
    expect(find.text('SWIPE ↑ · ТРАНСКРИПЦИЯ'), findsNothing);
    expect(find.text('слушаю…'), findsNothing);

    expect(find.text('Говорите…'), findsOneWidget);
  });

  testWidgets('Tapping on listening transitions to speaking and animates karaoke (hides hints)', (tester) async {
    await tester.pumpWidget(_buildVoiceTest());
    await tester.pump();

    // Tap once to transition to listening
    await tester.tap(find.byType(VoicePage));
    await tester.pump(const Duration(milliseconds: 350));

    // Tap second time to transition to speaking
    await tester.tap(find.byType(VoicePage));
    await tester.pump(const Duration(milliseconds: 350));

    // Active state: hints must be hidden
    expect(find.text('нажмите, чтобы говорить'), findsNothing);
    expect(find.text('SWIPE ↑ · ТРАНСКРИПЦИЯ'), findsNothing);
    expect(find.text('kai говорит'), findsNothing);

    // Karaoke widget should exist
    expect(find.text('Синкансэн'), findsOneWidget);
  });

  testWidgets('Swipe UP opens transcript view and swipe down/tap returns', (tester) async {
    await tester.pumpWidget(_buildVoiceTest());
    await tester.pump();

    // Swipe UP (negative offset) opens transcript
    await tester.fling(find.byType(VoicePage), const Offset(0, -300), 1000);
    await tester.pump();
    await tester.pump(const Duration(seconds: 1));

    // Should render transcript view time header and new return label
    expect(find.text('сегодня · 12:34'), findsOneWidget);
    expect(find.text('СВАЙП ↑ · ВЕРНУТЬСЯ К ГОЛОСУ'), findsOneWidget);

    // Swipe DOWN (positive offset) returns to voice
    await tester.fling(find.byType(VoicePage), const Offset(0, 300), 1000);
    await tester.pump();
    await tester.pump(const Duration(seconds: 1));
    expect(find.text('Kai ожидает'), findsOneWidget);

    // Swipe UP again
    await tester.fling(find.byType(VoicePage), const Offset(0, -300), 1000);
    await tester.pump();
    await tester.pump(const Duration(seconds: 1));

    // Tap return button to return to voice
    await tester.tap(find.text('СВАЙП ↑ · ВЕРНУТЬСЯ К ГОЛОСУ'));
    await tester.pump(const Duration(seconds: 1));

    // Should return to voice layout
    expect(find.text('Kai ожидает'), findsOneWidget);
  });

  testWidgets('Swipe DOWN in idle voice state exits to /room', (tester) async {
    await tester.pumpWidget(_buildVoiceTest());
    await tester.pump();

    // Swipe down (positive offset) exits
    await tester.fling(find.byType(VoicePage), const Offset(0, 300), 1000);
    await tester.pumpAndSettle();

    // Should navigate to room
    expect(find.text('room'), findsOneWidget);
    expect(find.byType(VoicePage), findsNothing);
  });

  testWidgets('Tapping SWIPE ↑ · ТРАНСКРИПЦИЯ text in idle opens transcript', (tester) async {
    await tester.pumpWidget(_buildVoiceTest());
    await tester.pump();

    // Tap SWIPE ↑ · ТРАНСКРИПЦИЯ text
    await tester.tap(find.text('SWIPE ↑ · ТРАНСКРИПЦИЯ'));
    await tester.pump(const Duration(seconds: 1));

    // Should open transcript view
    expect(find.text('сегодня · 12:34'), findsOneWidget);
    expect(find.byType(VoicePage), findsOneWidget);
  });
}

class _MockThemeModeNotifier extends ThemeModeNotifier {
  _MockThemeModeNotifier(this._initialMode);
  final ThemeMode _initialMode;
  @override
  ThemeMode build() => _initialMode;
}
