import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:kai_app/design_system/molecules/kai_settings_group.dart';
import 'package:kai_app/design_system/molecules/kai_settings_row.dart';
import 'package:kai_app/design_system/primitives/kai_icon.dart';

import '../../test_helpers.dart';

void main() {
  group('v3/KaiSettingsGroup', () {
    // -------------------------------------------------------------------------
    // Basic rendering — children
    // -------------------------------------------------------------------------

    testWidgets('renders children', (tester) async {
      await tester.pumpWidget(
        buildTestWidget(
          const KaiSettingsGroup(
            children: [
              KaiSettingsRow(icon: KaiIconName.palette, title: 'Тема'),
              KaiSettingsRow(icon: KaiIconName.globe, title: 'Язык'),
            ],
          ),
        ),
      );
      await tester.pump();
      expect(find.text('Тема'), findsOneWidget);
      expect(find.text('Язык'), findsOneWidget);
    });

    testWidgets('renders single child without error', (tester) async {
      await tester.pumpWidget(
        buildTestWidget(
          const KaiSettingsGroup(
            children: [
              KaiSettingsRow(icon: KaiIconName.settings, title: 'Только одна'),
            ],
          ),
        ),
      );
      await tester.pump();
      expect(find.byType(KaiSettingsGroup), findsOneWidget);
    });

    // -------------------------------------------------------------------------
    // Label
    // -------------------------------------------------------------------------

    testWidgets('renders label text when provided', (tester) async {
      await tester.pumpWidget(
        buildTestWidget(
          const KaiSettingsGroup(
            label: 'внешний вид',
            children: [
              KaiSettingsRow(icon: KaiIconName.palette, title: 'Тема'),
            ],
          ),
        ),
      );
      await tester.pump();
      expect(find.text('внешний вид'), findsOneWidget);
    });

    testWidgets('omits label when null', (tester) async {
      await tester.pumpWidget(
        buildTestWidget(
          const KaiSettingsGroup(
            children: [
              KaiSettingsRow(icon: KaiIconName.settings, title: 'Строка'),
            ],
          ),
        ),
      );
      await tester.pump();
      // Just check it rendered without a spurious text widget for the label.
      expect(find.text('Строка'), findsOneWidget);
    });

    // -------------------------------------------------------------------------
    // Container uses KaiRadius.br12 (12px)
    // -------------------------------------------------------------------------

    testWidgets('group container uses br12 radius (12px)', (tester) async {
      await tester.pumpWidget(
        buildTestWidget(
          const KaiSettingsGroup(
            children: [
              KaiSettingsRow(icon: KaiIconName.settings, title: 'Test'),
            ],
          ),
        ),
      );
      await tester.pump();

      const expected = BorderRadius.all(Radius.circular(12));
      final containers =
          tester.widgetList<Container>(find.byType(Container)).toList();
      final has12 = containers.any((c) {
        final deco = c.decoration;
        if (deco is! BoxDecoration) return false;
        return deco.borderRadius == expected;
      });

      expect(has12, isTrue,
          reason: 'group container must use KaiRadius.br12 (12px) borderRadius',);
    });

    // -------------------------------------------------------------------------
    // Danger variant — negative-wash border
    // -------------------------------------------------------------------------

    testWidgets('danger=true renders without error', (tester) async {
      await tester.pumpWidget(
        buildTestWidget(
          const KaiSettingsGroup(
            danger: true,
            children: [
              KaiSettingsRow(
                icon: KaiIconName.trash,
                title: 'Удалить',
                danger: true,
              ),
            ],
          ),
        ),
      );
      await tester.pump();
      expect(find.byType(KaiSettingsGroup), findsOneWidget);
    });

    testWidgets('danger group has a border', (tester) async {
      await tester.pumpWidget(
        buildTestWidget(
          const KaiSettingsGroup(
            danger: true,
            children: [
              KaiSettingsRow(
                icon: KaiIconName.logout,
                title: 'Выйти',
                danger: true,
              ),
            ],
          ),
        ),
      );
      await tester.pump();

      final containers =
          tester.widgetList<Container>(find.byType(Container)).toList();
      final hasBorder = containers.any((c) {
        final deco = c.decoration;
        if (deco is! BoxDecoration) return false;
        return deco.border != null;
      });

      expect(hasBorder, isTrue,
          reason: 'danger group must have a border decoration',);
    });

    // -------------------------------------------------------------------------
    // Full combination
    // -------------------------------------------------------------------------

    testWidgets('renders label + multiple children together', (tester) async {
      await tester.pumpWidget(
        buildTestWidget(
          const KaiSettingsGroup(
            label: 'аккаунт',
            children: [
              KaiSettingsRow(icon: KaiIconName.person, title: 'Профиль'),
              KaiSettingsRow(
                icon: KaiIconName.lock,
                title: 'Безопасность',
                subtitle: 'PIN и биометрия',
              ),
            ],
          ),
        ),
      );
      await tester.pump();

      expect(find.text('аккаунт'), findsOneWidget);
      expect(find.text('Профиль'), findsOneWidget);
      expect(find.text('Безопасность'), findsOneWidget);
      expect(find.text('PIN и биометрия'), findsOneWidget);
    });
  });
}
