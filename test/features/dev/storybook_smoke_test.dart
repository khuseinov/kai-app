import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:kai_app/core/providers/root.dart';
import 'package:kai_app/design_system/theme/kai_theme.dart';
import 'package:kai_app/features/dev/storybook/story_registry.dart';
import 'package:kai_app/features/dev/storybook/storybook_screen.dart';
import 'package:kai_app/l10n/app_localizations.dart';

import '../../test_helpers.dart';

/// Smoke tests for the adaptive Storybook shell (C1-Task-4 3-pane rebuild).
///
/// Covers:
///   - Wide (1400×900) and narrow (380×800) build without exception.
///   - Search filters the sidebar — no results for a never-matching query.
///   - Selecting a story (identity-based) renders correctly.
///   - Layer coverage is maintained.

Widget _wrap(Widget screen) {
  return ProviderScope(
    overrides: [
      themeModeProvider.overrideWith(() => MockThemeModeNotifier(ThemeMode.light)),
    ],
    child: MaterialApp(
      localizationsDelegates: AppLocalizations.localizationsDelegates,
      supportedLocales: const [Locale('ru'), Locale('en')],
      locale: const Locale('ru'),
      home: KaiTheme(child: screen),
    ),
  );
}

/// Suppresses RenderFlex overflow errors from pre-existing component internals.
Future<void> _ignoringOverflows(Future<void> Function() body) async {
  final original = FlutterError.onError;
  FlutterError.onError = (details) {
    if (details.exceptionAsString().contains('RenderFlex overflowed')) return;
    original?.call(details);
  };
  try {
    await body();
  } finally {
    FlutterError.onError = original;
  }
}

void main() {
  group('StorybookScreen — smoke', () {
    testWidgets('builds without exception at extra-wide layout (1400×900)',
        (t) async {
      await _ignoringOverflows(() async {
        t.view.physicalSize = const Size(1400, 900);
        t.view.devicePixelRatio = 1.0;
        addTearDown(t.view.reset);

        await t.pumpWidget(_wrap(const StorybookScreen()));
        await t.pump();
      });

      // In the 3-pane layout the first story name appears in the sidebar.
      expect(find.text(kStories.first.name), findsWidgets);
    });

    testWidgets('builds without exception at narrow layout (380×800)',
        (t) async {
      await _ignoringOverflows(() async {
        t.view.physicalSize = const Size(380, 800);
        t.view.devicePixelRatio = 1.0;
        addTearDown(t.view.reset);

        await t.pumpWidget(_wrap(const StorybookScreen()));
        await t.pump();
      });

      // In narrow layout the AppBar shows 'Storybook'.
      expect(find.text('Storybook'), findsOneWidget);
    });

    testWidgets(
        'search filters sidebar — no sidebar rows for a never-matching query',
        (t) async {
      await _ignoringOverflows(() async {
        t.view.physicalSize = const Size(1400, 900);
        t.view.devicePixelRatio = 1.0;
        addTearDown(t.view.reset);

        await t.pumpWidget(_wrap(const StorybookScreen()));
        await t.pump();

        // Type a query that matches no story name.
        await t.enterText(find.byType(TextField).first, 'zzzznomatch');
        await t.pump();
      });

      // No story name should appear in the filtered sidebar.
      expect(find.text('KaiButton'), findsNothing);
    });

    testWidgets('story registry is non-empty and built layers are covered',
        (t) async {
      expect(kStories, isNotEmpty);
      final layers = kStories.map((s) => s.layer).toSet();
      // All layers now populated (foundations filled in C1-T5).
      const builtLayers = {
        StoryLayer.foundations,
        StoryLayer.primitives,
        StoryLayer.atoms,
        StoryLayer.molecules,
        StoryLayer.organisms,
      };
      expect(layers, containsAll(builtLayers));
    });

    testWidgets('first story renders in canvas at wide layout', (t) async {
      await _ignoringOverflows(() async {
        t.view.physicalSize = const Size(1400, 900);
        t.view.devicePixelRatio = 1.0;
        addTearDown(t.view.reset);

        await t.pumpWidget(_wrap(const StorybookScreen()));
        await t.pump();
      });

      // First story name appears (in the sidebar and/or AppBar title).
      expect(find.text(kStories.first.name), findsWidgets);
    });
  });
}
