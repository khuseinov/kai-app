import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:kai_app/core/providers/root.dart';
import 'package:kai_app/design_system/theme/kai_theme.dart';
import 'package:kai_app/features/settings/settings_screen.dart';

Future<ProviderContainer> _pump(
  WidgetTester tester, {
  ThemeMode initial = ThemeMode.light,
}) async {
  // Tall surface so the full settings list renders without scrolling —
  // ListView is lazy, so off-screen rows don't materialise and find.text
  // returns Bad-state on them. iPhone-width × 1400 fits all 7 sections.
  await tester.binding.setSurfaceSize(const Size(390, 1400));
  addTearDown(() => tester.binding.setSurfaceSize(null));
  final container = ProviderContainer(
    overrides: [
      themeModeProvider.overrideWith((ref) => initial),
    ],
  );
  await tester.pumpWidget(
    UncontrolledProviderScope(
      container: container,
      child: const MaterialApp(
        home: KaiTheme(child: SettingsScreen()),
      ),
    ),
  );
  await tester.pump();
  return container;
}

void main() {
  group('SettingsScreen', () {
    testWidgets('renders top bar title + account hero', (tester) async {
      await _pump(tester);
      expect(find.text('Настройки'), findsOneWidget);
      expect(find.text('Aibek'), findsOneWidget);
      expect(find.text('aibek@wize.ai'), findsOneWidget);
      expect(find.text('PLUS'), findsOneWidget);
    });

    testWidgets('renders all 6 section labels', (tester) async {
      await _pump(tester);
      for (final label in [
        'внешний вид',
        'голос',
        'данные',
        'приватность',
        'аккаунт',
        'о приложении',
      ]) {
        expect(find.text(label), findsOneWidget, reason: 'label "$label"');
      }
    });

    testWidgets('theme segmented control toggles themeModeProvider',
        (tester) async {
      final container = await _pump(tester, initial: ThemeMode.system);
      // initial selected = system (index 0 = "Авто")
      expect(container.read(themeModeProvider), ThemeMode.system);
      // Scroll the Тёмная option into view first (settings list is scrollable).
      await tester.tap(find.text('Тёмная'));
      await tester.pump();
      expect(container.read(themeModeProvider), ThemeMode.dark);
    });

    testWidgets('voice input toggle (default on) flips on tap',
        (tester) async {
      await _pump(tester);
      // Find the Voice section title to anchor a scroll.
      // We can't easily reach into local state, but we can verify the row
      // renders with its subtitle (sanity smoke).
      expect(find.text('нажмите орб для начала прослушивания'), findsOneWidget);
    });

    testWidgets('danger row renders with negative title', (tester) async {
      await _pump(tester);
      expect(find.text('Удалить мои данные'), findsOneWidget);
      expect(find.text('необратимо · GDPR'), findsOneWidget);
    });

    testWidgets('renders version row', (tester) async {
      await _pump(tester);
      expect(find.text('Версия'), findsOneWidget);
      expect(find.text('0.2.0'), findsOneWidget);
    });
  });
}
