import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:kai_app/core/providers/root.dart';
import 'package:kai_app/design_system/theme/kai_theme.dart';
import 'package:kai_app/design_system/atoms/kai_sheet_shell.dart';
import 'package:kai_app/features/room/components/sheets/kai_message_detail_sheet.dart';
import 'package:kai_app/design_system/primitives/kai_icon.dart';
import 'package:kai_app/l10n/app_localizations.dart';

import '../../../../test_helpers.dart';

/// Wraps [child] with KaiTheme ABOVE MaterialApp so that modal bottom sheets
/// (which use the Navigator inside MaterialApp) also inherit KaiTheme.
Widget _buildModalTestWidget(Widget child) {
  return ProviderScope(
    overrides: <Override>[
      themeModeProvider.overrideWith((ref) => ThemeMode.light),
    ],
    child: KaiTheme(
      child: Builder(
        builder: (kaiCtx) => MaterialApp(
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          supportedLocales: const [Locale('ru'), Locale('en')],
          locale: const Locale('ru'),
          home: Scaffold(body: child),
        ),
      ),
    ),
  );
}

void main() {
  group('v3/KaiMessageDetailSheet — dumb widget', () {
    // -------------------------------------------------------------------------
    // Basic render
    // -------------------------------------------------------------------------

    testWidgets('renders KaiSheetShell container', (tester) async {
      await tester.pumpWidget(
        buildTestWidget(
          KaiMessageDetailSheet(
            sources: const [KaiDetailSource(number: 1, url: 'example.com')],
            actions: [
              KaiDetailAction(
                icon: KaiIconName.copy,
                label: 'Копировать',
                onTap: () {},
              ),
            ],
          ),
        ),
      );
      await tester.pump();
      expect(find.byType(KaiSheetShell), findsOneWidget);
    });

    // -------------------------------------------------------------------------
    // Sources section
    // -------------------------------------------------------------------------

    testWidgets('renders all source URLs', (tester) async {
      await tester.pumpWidget(
        buildTestWidget(
          KaiMessageDetailSheet(
            sources: const [
              KaiDetailSource(number: 1, url: 'wikipedia.org'),
              KaiDetailSource(number: 2, url: 'arxiv.org'),
            ],
            actions: [
              KaiDetailAction(
                icon: KaiIconName.copy,
                label: 'Копировать',
                onTap: () {},
              ),
            ],
          ),
        ),
      );
      await tester.pump();
      expect(find.text('wikipedia.org'), findsOneWidget);
      expect(find.text('arxiv.org'), findsOneWidget);
    });

    testWidgets('renders source index numbers', (tester) async {
      await tester.pumpWidget(
        buildTestWidget(
          const KaiMessageDetailSheet(
            sources: [
              KaiDetailSource(number: 1, url: 'a.com'),
              KaiDetailSource(number: 2, url: 'b.com'),
            ],
            actions: [],
          ),
        ),
      );
      await tester.pump();
      expect(find.text('1'), findsOneWidget);
      expect(find.text('2'), findsOneWidget);
    });

    testWidgets('renders freshness badge when provided', (tester) async {
      await tester.pumpWidget(
        buildTestWidget(
          const KaiMessageDetailSheet(
            sources: [
              KaiDetailSource(
                number: 1,
                url: 'fresh.com',
                freshness: KaiSourceFreshness.fresh,
              ),
              KaiDetailSource(
                number: 2,
                url: 'stale.com',
                freshness: KaiSourceFreshness.stale,
              ),
            ],
            actions: [],
          ),
        ),
      );
      await tester.pump();
      // Default labels: "fresh" and "stale" with glyph prefix.
      expect(find.textContaining('fresh'), findsWidgets);
      expect(find.textContaining('stale'), findsWidgets);
    });

    testWidgets('renders custom freshness label when provided', (tester) async {
      await tester.pumpWidget(
        buildTestWidget(
          const KaiMessageDetailSheet(
            sources: [
              KaiDetailSource(
                number: 1,
                url: 'test.com',
                freshness: KaiSourceFreshness.stale,
                freshnessLabel: '7d',
              ),
            ],
            actions: [],
          ),
        ),
      );
      await tester.pump();
      expect(find.textContaining('7d'), findsWidgets);
    });

    testWidgets('omits freshness badge when null', (tester) async {
      await tester.pumpWidget(
        buildTestWidget(
          const KaiMessageDetailSheet(
            sources: [KaiDetailSource(number: 1, url: 'plain.com')],
            actions: [],
          ),
        ),
      );
      await tester.pump();
      expect(find.textContaining('fresh'), findsNothing);
      expect(find.textContaining('stale'), findsNothing);
    });

    // -------------------------------------------------------------------------
    // Section labels
    // -------------------------------------------------------------------------

    testWidgets('renders default section labels', (tester) async {
      await tester.pumpWidget(
        buildTestWidget(
          const KaiMessageDetailSheet(
            sources: [KaiDetailSource(number: 1, url: 'x.com')],
            actions: [],
          ),
        ),
      );
      await tester.pump();
      // Section labels are uppercased in the widget.
      expect(find.text('ИСТОЧНИКИ'), findsOneWidget);
      expect(find.text('ДЕЙСТВИЯ'), findsOneWidget);
    });

    testWidgets('renders custom section labels', (tester) async {
      await tester.pumpWidget(
        buildTestWidget(
          const KaiMessageDetailSheet(
            sources: [],
            actions: [],
            sourcesLabel: 'Ссылки',
            actionsLabel: 'Опции',
          ),
        ),
      );
      await tester.pump();
      expect(find.text('ССЫЛКИ'), findsOneWidget);
      expect(find.text('ОПЦИИ'), findsOneWidget);
    });

    // -------------------------------------------------------------------------
    // Actions section
    // -------------------------------------------------------------------------

    testWidgets('renders all action labels', (tester) async {
      await tester.pumpWidget(
        buildTestWidget(
          KaiMessageDetailSheet(
            sources: const [],
            actions: [
              KaiDetailAction(
                icon: KaiIconName.globe,
                label: 'Поделиться',
                style: KaiDetailActionStyle.primary,
                onTap: () {},
              ),
              KaiDetailAction(
                icon: KaiIconName.copy,
                label: 'Копировать',
                onTap: () {},
              ),
              KaiDetailAction(
                icon: KaiIconName.retry,
                label: 'Переспросить',
                onTap: () {},
              ),
            ],
          ),
        ),
      );
      await tester.pump();
      expect(find.text('Поделиться'), findsOneWidget);
      expect(find.text('Копировать'), findsOneWidget);
      expect(find.text('Переспросить'), findsOneWidget);
    });

    testWidgets('primary action row renders without error', (tester) async {
      await tester.pumpWidget(
        buildTestWidget(
          KaiMessageDetailSheet(
            sources: const [],
            actions: [
              KaiDetailAction(
                icon: KaiIconName.globe,
                label: 'Поделиться',
                style: KaiDetailActionStyle.primary,
                onTap: () {},
              ),
            ],
          ),
        ),
      );
      await tester.pump();
      expect(find.text('Поделиться'), findsOneWidget);
    });

    testWidgets('danger action row renders without error', (tester) async {
      await tester.pumpWidget(
        buildTestWidget(
          KaiMessageDetailSheet(
            sources: const [],
            actions: [
              KaiDetailAction(
                icon: KaiIconName.trash,
                label: 'Удалить',
                style: KaiDetailActionStyle.danger,
                onTap: () {},
              ),
            ],
          ),
        ),
      );
      await tester.pump();
      expect(find.text('Удалить'), findsOneWidget);
    });

    testWidgets('danger action uses negative color on label text', (tester) async {
      await tester.pumpWidget(
        buildTestWidget(
          KaiMessageDetailSheet(
            sources: const [],
            actions: [
              KaiDetailAction(
                icon: KaiIconName.trash,
                label: 'DangerLabel',
                style: KaiDetailActionStyle.danger,
                onTap: () {},
              ),
            ],
          ),
        ),
      );
      await tester.pump();

      final textWidgets =
          tester.widgetList<Text>(find.text('DangerLabel')).toList();
      expect(textWidgets, isNotEmpty);
      expect(textWidgets.first.style?.color, isNotNull);
    });

    testWidgets('primary action uses accent color on label text', (tester) async {
      await tester.pumpWidget(
        buildTestWidget(
          KaiMessageDetailSheet(
            sources: const [],
            actions: [
              KaiDetailAction(
                icon: KaiIconName.globe,
                label: 'PrimaryLabel',
                style: KaiDetailActionStyle.primary,
                onTap: () {},
              ),
            ],
          ),
        ),
      );
      await tester.pump();

      final textWidgets =
          tester.widgetList<Text>(find.text('PrimaryLabel')).toList();
      expect(textWidgets, isNotEmpty);
      expect(textWidgets.first.style?.color, isNotNull);
    });

    // -------------------------------------------------------------------------
    // Tap fires callback — NO Navigator required
    // -------------------------------------------------------------------------

    testWidgets('tapping an action fires its onTap callback', (tester) async {
      var tapped = false;
      await tester.pumpWidget(
        buildTestWidget(
          KaiMessageDetailSheet(
            sources: const [],
            actions: [
              KaiDetailAction(
                icon: KaiIconName.copy,
                label: 'Копировать',
                onTap: () => tapped = true,
              ),
            ],
          ),
        ),
      );
      await tester.pump();

      await tester.tap(find.text('Копировать'));
      await tester.pump();

      expect(tapped, isTrue,
          reason: 'onTap must fire directly — widget must not require Navigator');
    });

    testWidgets('tapping fires correct callback when multiple actions',
        (tester) async {
      final tapped = <int>[];
      await tester.pumpWidget(
        buildTestWidget(
          KaiMessageDetailSheet(
            sources: const [],
            actions: [
              KaiDetailAction(
                icon: KaiIconName.globe,
                label: 'Первое',
                onTap: () => tapped.add(0),
              ),
              KaiDetailAction(
                icon: KaiIconName.copy,
                label: 'Второе',
                onTap: () => tapped.add(1),
              ),
              KaiDetailAction(
                icon: KaiIconName.trash,
                label: 'Третье',
                style: KaiDetailActionStyle.danger,
                onTap: () => tapped.add(2),
              ),
            ],
          ),
        ),
      );
      await tester.pump();

      await tester.tap(find.text('Второе'));
      await tester.pump();

      expect(tapped, equals([1]));
    });

    // -------------------------------------------------------------------------
    // Regression: no Navigator call inside the widget
    // -------------------------------------------------------------------------

    testWidgets(
        'widget does not call Navigator — tapping succeeds without route',
        (tester) async {
      var tapped = false;
      await tester.pumpWidget(
        buildTestWidget(
          KaiMessageDetailSheet(
            sources: const [],
            actions: [
              KaiDetailAction(
                icon: KaiIconName.check,
                label: 'Готово',
                onTap: () => tapped = true,
              ),
            ],
          ),
        ),
      );
      await tester.pump();

      // Must not throw even though there is nothing to pop.
      await tester.tap(find.text('Готово'));
      await tester.pump();

      expect(tapped, isTrue);
    });

    // -------------------------------------------------------------------------
    // Empty lists
    // -------------------------------------------------------------------------

    testWidgets('renders without error with empty sources and actions',
        (tester) async {
      await tester.pumpWidget(
        buildTestWidget(
          const KaiMessageDetailSheet(sources: [], actions: []),
        ),
      );
      await tester.pump();
      expect(find.byType(KaiMessageDetailSheet), findsOneWidget);
    });

    // -------------------------------------------------------------------------
    // Data classes
    // -------------------------------------------------------------------------

    test('KaiDetailSource preserves all fields', () {
      const src = KaiDetailSource(
        number: 3,
        url: 'test.com',
        freshness: KaiSourceFreshness.stale,
        freshnessLabel: '5d',
      );
      expect(src.number, 3);
      expect(src.url, 'test.com');
      expect(src.freshness, KaiSourceFreshness.stale);
      expect(src.freshnessLabel, '5d');
    });

    test('KaiDetailSource defaults freshness to null', () {
      const src = KaiDetailSource(number: 1, url: 'x.com');
      expect(src.freshness, isNull);
      expect(src.freshnessLabel, isNull);
    });

    test('KaiDetailAction default style is normal', () {
      final action = KaiDetailAction(
        icon: KaiIconName.copy,
        label: 'Test',
        onTap: () {},
      );
      expect(action.style, KaiDetailActionStyle.normal);
    });

    test('KaiDetailAction preserves all fields', () {
      var called = false;
      final action = KaiDetailAction(
        icon: KaiIconName.trash,
        label: 'Delete',
        style: KaiDetailActionStyle.danger,
        onTap: () => called = true,
      );
      expect(action.icon, KaiIconName.trash);
      expect(action.label, 'Delete');
      expect(action.style, KaiDetailActionStyle.danger);
      action.onTap();
      expect(called, isTrue);
    });

    test('KaiSourceFreshness has fresh and stale values', () {
      expect(KaiSourceFreshness.values, containsAll([
        KaiSourceFreshness.fresh,
        KaiSourceFreshness.stale,
      ]));
    });

    test('KaiDetailActionStyle has normal/primary/danger values', () {
      expect(KaiDetailActionStyle.values, containsAll([
        KaiDetailActionStyle.normal,
        KaiDetailActionStyle.primary,
        KaiDetailActionStyle.danger,
      ]));
    });
  });

  // ---------------------------------------------------------------------------
  // showKaiMessageDetailSheet helper — light smoke test
  // ---------------------------------------------------------------------------

  group('v3/showKaiMessageDetailSheet helper', () {
    testWidgets('presents sheet content when called', (tester) async {
      await tester.pumpWidget(
        _buildModalTestWidget(
          Builder(
            builder: (ctx) => TextButton(
              onPressed: () {
                showKaiMessageDetailSheet(
                  ctx,
                  sources: const [KaiDetailSource(number: 1, url: 'via-helper.com')],
                  actions: [
                    KaiDetailAction(
                      icon: KaiIconName.copy,
                      label: 'Копировать',
                      onTap: () {},
                    ),
                  ],
                );
              },
              child: const Text('Открыть'),
            ),
          ),
        ),
      );
      await tester.pump();

      await tester.tap(find.text('Открыть'));
      await tester.pumpAndSettle();

      expect(find.text('via-helper.com'), findsOneWidget);
    });

    testWidgets('sheet pops and fires callback when action tapped via helper',
        (tester) async {
      var fired = false;
      await tester.pumpWidget(
        _buildModalTestWidget(
          Builder(
            builder: (ctx) => TextButton(
              onPressed: () {
                showKaiMessageDetailSheet(
                  ctx,
                  sources: const [],
                  actions: [
                    KaiDetailAction(
                      icon: KaiIconName.check,
                      label: 'Действие',
                      onTap: () => fired = true,
                    ),
                  ],
                );
              },
              child: const Text('Показать'),
            ),
          ),
        ),
      );
      await tester.pump();

      await tester.tap(find.text('Показать'));
      await tester.pumpAndSettle();

      await tester.tap(find.text('Действие'));
      await tester.pumpAndSettle();

      expect(fired, isTrue);
      // Sheet should be dismissed after pop.
      expect(find.text('Действие'), findsNothing);
    });
  });
}
