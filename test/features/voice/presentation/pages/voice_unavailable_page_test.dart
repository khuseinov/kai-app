import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:kai_app/design_system/theme/kai_theme.dart';
import 'package:kai_app/features/voice/presentation/pages/voice_unavailable_page.dart';
import 'package:kai_app/l10n/app_localizations.dart';

Widget _build() {
  final router = GoRouter(
    initialLocation: '/voice',
    routes: [
      GoRoute(path: '/voice', builder: (_, __) => const VoiceUnavailablePage()),
      GoRoute(path: '/room', builder: (_, __) => const Scaffold(body: Text('room'))),
    ],
  );
  return ProviderScope(
    child: MaterialApp.router(
      localizationsDelegates: AppLocalizations.localizationsDelegates,
      supportedLocales: const [Locale('ru'), Locale('en')],
      locale: const Locale('ru'),
      routerConfig: router,
      builder: (context, child) =>
          KaiTheme(child: child ?? const SizedBox.shrink()),
    ),
  );
}

void main() {
  testWidgets('shows localized web-unsupported message', (tester) async {
    await tester.pumpWidget(_build());
    await tester.pump();

    expect(find.text('Голос недоступен в веб-версии'), findsOneWidget);
  });

  testWidgets('back button navigates to /room', (tester) async {
    await tester.pumpWidget(_build());
    await tester.pump();

    await tester.tap(find.text('Назад'));
    await tester.pumpAndSettle();

    expect(find.text('room'), findsOneWidget);
  });

  test('voiceSupported is true off-web (test env is the VM)', () {
    expect(VoiceUnavailablePage.voiceSupported, isTrue);
  });
}
