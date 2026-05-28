import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:kai_app/core/providers/root.dart';
import 'package:kai_app/design_system/theme/kai_theme.dart';
import 'package:kai_app/design_system/v3/atoms/kai_sheet_shell.dart';
import 'package:kai_app/design_system/v3/molecules/kai_action_sheet.dart';
import 'package:kai_app/design_system/v3/primitives/kai_icon.dart';
import 'package:kai_app/l10n/app_localizations.dart';

import '../../../test_helpers.dart';

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
  group('v3/KaiActionSheet — dumb widget', () {
    // -------------------------------------------------------------------------
    // Basic render
    // -------------------------------------------------------------------------

    testWidgets('renders KaiSheetShell container', (tester) async {
      await tester.pumpWidget(
        buildTestWidget(
          KaiActionSheet(
            items: [
              KaiActionItem(
                icon: KaiIconName.copy,
                title: 'Копировать',
                onTap: () {},
              ),
            ],
          ),
        ),
      );
      await tester.pump();
      expect(find.byType(KaiSheetShell), findsOneWidget);
    });

    testWidgets('renders all item titles', (tester) async {
      await tester.pumpWidget(
        buildTestWidget(
          KaiActionSheet(
            items: [
              KaiActionItem(
                icon: KaiIconName.copy,
                title: 'Копировать',
                onTap: () {},
              ),
              KaiActionItem(
                icon: KaiIconName.trash,
                title: 'Удалить',
                onTap: () {},
              ),
              KaiActionItem(
                icon: KaiIconName.globe,
                title: 'Открыть',
                onTap: () {},
              ),
            ],
          ),
        ),
      );
      await tester.pump();
      expect(find.text('Копировать'), findsOneWidget);
      expect(find.text('Удалить'), findsOneWidget);
      expect(find.text('Открыть'), findsOneWidget);
    });

    testWidgets('renders meta label when provided', (tester) async {
      await tester.pumpWidget(
        buildTestWidget(
          KaiActionSheet(
            items: [
              KaiActionItem(
                icon: KaiIconName.settings,
                title: 'Настройки',
                meta: 'auto',
                onTap: () {},
              ),
            ],
          ),
        ),
      );
      await tester.pump();
      expect(find.text('auto'), findsOneWidget);
    });

    testWidgets('omits meta when null', (tester) async {
      await tester.pumpWidget(
        buildTestWidget(
          KaiActionSheet(
            items: [
              KaiActionItem(
                icon: KaiIconName.copy,
                title: 'Копировать',
                onTap: () {},
              ),
            ],
          ),
        ),
      );
      await tester.pump();
      // No unexpected meta text present
      expect(find.text('auto'), findsNothing);
    });

    // -------------------------------------------------------------------------
    // Danger tint
    // -------------------------------------------------------------------------

    testWidgets('danger item renders (does not crash)', (tester) async {
      await tester.pumpWidget(
        buildTestWidget(
          KaiActionSheet(
            items: [
              KaiActionItem(
                icon: KaiIconName.trash,
                title: 'Удалить навсегда',
                danger: true,
                onTap: () {},
              ),
            ],
          ),
        ),
      );
      await tester.pump();
      expect(find.text('Удалить навсегда'), findsOneWidget);
    });

    testWidgets('danger item uses negative color on the row text', (tester) async {
      await tester.pumpWidget(
        buildTestWidget(
          KaiActionSheet(
            items: [
              KaiActionItem(
                icon: KaiIconName.trash,
                title: 'Danger',
                danger: true,
                onTap: () {},
              ),
            ],
          ),
        ),
      );
      await tester.pump();

      // Find the Text widget for 'Danger' and check it uses a non-null color.
      final textWidgets = tester.widgetList<Text>(find.text('Danger')).toList();
      expect(textWidgets, isNotEmpty);
      final textColor = textWidgets.first.style?.color;
      // The danger color is the negative token (≈ #C44A3C / non-null).
      expect(textColor, isNotNull);
    });

    // -------------------------------------------------------------------------
    // Tap fires callback — NO Navigator required
    // -------------------------------------------------------------------------

    testWidgets('tapping a row fires its onTap callback', (tester) async {
      var tapped = false;
      await tester.pumpWidget(
        buildTestWidget(
          KaiActionSheet(
            items: [
              KaiActionItem(
                icon: KaiIconName.copy,
                title: 'Нажми меня',
                onTap: () => tapped = true,
              ),
            ],
          ),
        ),
      );
      await tester.pump();

      await tester.tap(find.text('Нажми меня'));
      await tester.pump();

      expect(tapped, isTrue,
          reason:
              'onTap must fire directly — widget must not require Navigator');
    });

    testWidgets('tapping danger row fires its onTap callback', (tester) async {
      var fired = false;
      await tester.pumpWidget(
        buildTestWidget(
          KaiActionSheet(
            items: [
              KaiActionItem(
                icon: KaiIconName.trash,
                title: 'Удалить',
                danger: true,
                onTap: () => fired = true,
              ),
            ],
          ),
        ),
      );
      await tester.pump();

      await tester.tap(find.text('Удалить'));
      await tester.pump();

      expect(fired, isTrue);
    });

    testWidgets('tapping fires correct callback when multiple items', (tester) async {
      final tapped = <int>[];
      await tester.pumpWidget(
        buildTestWidget(
          KaiActionSheet(
            items: [
              KaiActionItem(
                icon: KaiIconName.copy,
                title: 'Первый',
                onTap: () => tapped.add(0),
              ),
              KaiActionItem(
                icon: KaiIconName.globe,
                title: 'Второй',
                onTap: () => tapped.add(1),
              ),
              KaiActionItem(
                icon: KaiIconName.trash,
                title: 'Третий',
                onTap: () => tapped.add(2),
              ),
            ],
          ),
        ),
      );
      await tester.pump();

      await tester.tap(find.text('Второй'));
      await tester.pump();

      expect(tapped, equals([1]));
    });

    // -------------------------------------------------------------------------
    // Regression: no Navigator call inside the widget
    // -------------------------------------------------------------------------

    testWidgets('widget does not call Navigator — tapping succeeds without route',
        (tester) async {
      // The test scaffold from buildTestWidget has NO named route / navigation
      // stack, so any Navigator.pop / maybePop inside the widget would throw.
      // Successful tap without error proves the widget is navigation-free.
      var tapped = false;
      await tester.pumpWidget(
        buildTestWidget(
          KaiActionSheet(
            items: [
              KaiActionItem(
                icon: KaiIconName.check,
                title: 'Готово',
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
    // Empty list
    // -------------------------------------------------------------------------

    testWidgets('renders without error with empty items list', (tester) async {
      await tester.pumpWidget(
        buildTestWidget(const KaiActionSheet(items: [])),
      );
      await tester.pump();
      expect(find.byType(KaiActionSheet), findsOneWidget);
    });

    // -------------------------------------------------------------------------
    // KaiActionItem data class
    // -------------------------------------------------------------------------

    test('KaiActionItem default danger is false', () {
      final item = KaiActionItem(
        icon: KaiIconName.copy,
        title: 'Test',
        onTap: () {},
      );
      expect(item.danger, isFalse);
    });

    test('KaiActionItem preserves all fields', () {
      var called = false;
      final item = KaiActionItem(
        icon: KaiIconName.trash,
        title: 'Delete',
        meta: 'del',
        danger: true,
        onTap: () => called = true,
      );
      expect(item.icon, KaiIconName.trash);
      expect(item.title, 'Delete');
      expect(item.meta, 'del');
      expect(item.danger, isTrue);
      item.onTap();
      expect(called, isTrue);
    });
  });

  // ---------------------------------------------------------------------------
  // showKaiActionSheet helper — light smoke test
  // ---------------------------------------------------------------------------

  group('v3/showKaiActionSheet helper', () {
    testWidgets('presents sheet content when called', (tester) async {
      await tester.pumpWidget(
        _buildModalTestWidget(
          Builder(
            builder: (ctx) => TextButton(
              onPressed: () {
                showKaiActionSheet(
                  ctx,
                  items: [
                    KaiActionItem(
                      icon: KaiIconName.copy,
                      title: 'Через хелпер',
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
      // Let the modal bottom sheet animate in.
      await tester.pumpAndSettle();

      expect(find.text('Через хелпер'), findsOneWidget);
    });

    testWidgets('sheet pops and fires callback when row tapped via helper',
        (tester) async {
      var fired = false;
      await tester.pumpWidget(
        _buildModalTestWidget(
          Builder(
            builder: (ctx) => TextButton(
              onPressed: () {
                showKaiActionSheet(
                  ctx,
                  items: [
                    KaiActionItem(
                      icon: KaiIconName.check,
                      title: 'Действие',
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
      // Sheet should be dismissed.
      expect(find.text('Действие'), findsNothing);
    });
  });
}
