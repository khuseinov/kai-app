import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:kai_app/design_system/v3/atoms/kai_toggle.dart';
import 'package:kai_app/design_system/v3/molecules/kai_settings_row.dart';
import 'package:kai_app/design_system/v3/primitives/kai_icon.dart';

import '../../../test_helpers.dart';

void main() {
  group('v3/KaiSettingsRow', () {
    // -------------------------------------------------------------------------
    // Basic content rendering
    // -------------------------------------------------------------------------

    testWidgets('renders title text', (tester) async {
      await tester.pumpWidget(
        buildTestWidget(
          const KaiSettingsRow(
            icon: KaiIconName.settings,
            title: 'Настройки профиля',
          ),
        ),
      );
      await tester.pump();
      expect(find.text('Настройки профиля'), findsOneWidget);
    });

    testWidgets('renders subtitle when provided', (tester) async {
      await tester.pumpWidget(
        buildTestWidget(
          const KaiSettingsRow(
            icon: KaiIconName.person,
            title: 'Имя пользователя',
            subtitle: 'user@example.com',
          ),
        ),
      );
      await tester.pump();
      expect(find.text('user@example.com'), findsOneWidget);
    });

    testWidgets('omits subtitle when null', (tester) async {
      await tester.pumpWidget(
        buildTestWidget(
          const KaiSettingsRow(
            icon: KaiIconName.globe,
            title: 'Язык',
          ),
        ),
      );
      await tester.pump();
      // Subtitle not provided — no second text widget beyond the title.
      expect(find.text('Язык'), findsOneWidget);
      expect(find.text('user@example.com'), findsNothing);
    });

    // -------------------------------------------------------------------------
    // Trailing widget
    // -------------------------------------------------------------------------

    testWidgets('renders trailing widget when provided', (tester) async {
      await tester.pumpWidget(
        buildTestWidget(
          KaiSettingsRow(
            icon: KaiIconName.motion,
            title: 'Анимации',
            trailing: KaiToggle(value: true, onChanged: (_) {}),
          ),
        ),
      );
      await tester.pump();
      expect(find.byType(KaiToggle), findsOneWidget);
    });

    testWidgets('no trailing renders without error', (tester) async {
      await tester.pumpWidget(
        buildTestWidget(
          const KaiSettingsRow(
            icon: KaiIconName.palette,
            title: 'Тема',
          ),
        ),
      );
      await tester.pump();
      expect(find.byType(KaiSettingsRow), findsOneWidget);
      expect(find.byType(KaiToggle), findsNothing);
    });

    // -------------------------------------------------------------------------
    // onTap callback
    // -------------------------------------------------------------------------

    testWidgets('onTap fires when row is tapped', (tester) async {
      var tapped = false;
      await tester.pumpWidget(
        buildTestWidget(
          KaiSettingsRow(
            icon: KaiIconName.chevRight,
            title: 'Перейти',
            onTap: () => tapped = true,
          ),
        ),
      );
      await tester.pump();

      await tester.tap(find.text('Перейти'));
      await tester.pump();

      expect(tapped, isTrue);
    });

    testWidgets('no onTap does not throw on render', (tester) async {
      await tester.pumpWidget(
        buildTestWidget(
          const KaiSettingsRow(
            icon: KaiIconName.info,
            title: 'Информация',
          ),
        ),
      );
      await tester.pump();
      expect(find.byType(KaiSettingsRow), findsOneWidget);
    });

    // -------------------------------------------------------------------------
    // Danger variant
    // -------------------------------------------------------------------------

    testWidgets('danger=true renders without error', (tester) async {
      await tester.pumpWidget(
        buildTestWidget(
          const KaiSettingsRow(
            icon: KaiIconName.trash,
            title: 'Удалить мои данные',
            danger: true,
          ),
        ),
      );
      await tester.pump();
      expect(find.text('Удалить мои данные'), findsOneWidget);
    });

    testWidgets('danger row title uses negative (coral) color', (tester) async {
      await tester.pumpWidget(
        buildTestWidget(
          const KaiSettingsRow(
            icon: KaiIconName.logout,
            title: 'Выйти',
            danger: true,
          ),
        ),
      );
      await tester.pump();

      // Negative coral in light theme.
      const negativeLight = Color(0xFFC44A3C);

      final richTexts = tester.widgetList<Text>(find.byType(Text)).toList();
      final hasDangerColor = richTexts.any(
        (t) => t.style?.color == negativeLight,
      );

      expect(hasDangerColor, isTrue,
          reason: 'danger row title must use negative (coral) color');
    });

    // -------------------------------------------------------------------------
    // Full combination
    // -------------------------------------------------------------------------

    testWidgets('renders all fields together', (tester) async {
      var tapped = false;
      await tester.pumpWidget(
        buildTestWidget(
          KaiSettingsRow(
            icon: KaiIconName.settings,
            title: 'Уведомления',
            subtitle: 'Нажмите, чтобы настроить',
            trailing: KaiToggle(value: false, onChanged: (_) {}),
            onTap: () => tapped = true,
          ),
        ),
      );
      await tester.pump();

      expect(find.text('Уведомления'), findsOneWidget);
      expect(find.text('Нажмите, чтобы настроить'), findsOneWidget);
      expect(find.byType(KaiToggle), findsOneWidget);

      await tester.tap(find.text('Уведомления'));
      await tester.pump();

      expect(tapped, isTrue);
    });
  });
}
