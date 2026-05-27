import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:kai_app/core/providers/root.dart';
import 'package:kai_app/design_system/molecules/alert_card.dart';
import 'package:kai_app/design_system/theme/kai_theme.dart';
import 'package:kai_app/design_system/tokens/kai_tokens.dart';

Future<void> _pump(
  WidgetTester tester,
  Widget child, {
  ThemeMode mode = ThemeMode.light,
}) async {
  await tester.pumpWidget(
    ProviderScope(
      overrides: <Override>[
        themeModeProvider.overrideWith((ref) => mode),
      ],
      child: MaterialApp(
        home: KaiTheme(
          child: Scaffold(body: child),
        ),
      ),
    ),
  );
  await tester.pump();
}

/// Returns the background colour of the outermost AlertCard Container.
/// In the 2-zone layout the outer Container carries [bg] (wash colour).
Color _backgroundOf(WidgetTester tester) {
  // The outermost Container inside AlertCard carries the wash colour.
  final container = tester.widget<Container>(
    find.descendant(
      of: find.byType(AlertCard),
      matching: find.byType(Container),
    ).first,
  );
  final dec = container.decoration as BoxDecoration;
  return dec.color!;
}

void main() {
  group('AlertCard', () {
    testWidgets('urgent uses negativeWash', (WidgetTester tester) async {
      await _pump(
        tester,
        const AlertCard(type: AlertType.urgent, title: 'Срочно'),
      );
      expect(find.text('Срочно'), findsOneWidget);
      expect(_backgroundOf(tester), KaiTokens.light.colors.negativeWash);
    });

    testWidgets('warning uses warningWash', (WidgetTester tester) async {
      await _pump(
        tester,
        const AlertCard(type: AlertType.warning, title: 'Внимание'),
      );
      expect(_backgroundOf(tester), KaiTokens.light.colors.warningWash);
    });

    testWidgets('positive uses positiveWash', (WidgetTester tester) async {
      await _pump(
        tester,
        const AlertCard(type: AlertType.positive, title: 'Готово'),
      );
      expect(_backgroundOf(tester), KaiTokens.light.colors.positiveWash);
    });

    // Canon: notifications-chat.html § .alert-card.neutral → surface-2 bg + line border
    testWidgets('neutral uses surface2 (not accentWash)', (WidgetTester tester) async {
      await _pump(
        tester,
        const AlertCard(type: AlertType.neutral, title: 'Заметка'),
      );
      expect(_backgroundOf(tester), KaiTokens.light.colors.surface2);
    });

    testWidgets('neutral has line border', (WidgetTester tester) async {
      await _pump(
        tester,
        const AlertCard(type: AlertType.neutral, title: 'Заметка'),
      );
      final container = tester.widget<Container>(
        find.descendant(
          of: find.byType(AlertCard),
          matching: find.byType(Container),
        ).first,
      );
      final dec = container.decoration as BoxDecoration;
      expect(dec.border, isNotNull);
      final border = dec.border! as Border;
      expect(border.top.color, KaiTokens.light.colors.line);
    });

    testWidgets('renders title and body text',
        (WidgetTester tester) async {
      await _pump(
        tester,
        const AlertCard(
          type: AlertType.warning,
          title: 'Title',
          body: 'Some description',
        ),
      );
      expect(find.text('Title'), findsOneWidget);
      expect(find.text('Some description'), findsOneWidget);
    });

    // Legacy `action` widget param still accepted without error.
    testWidgets('renders title, body and legacy action together',
        (WidgetTester tester) async {
      await _pump(
        tester,
        const AlertCard(
          type: AlertType.warning,
          title: 'Title',
          body: 'Some description',
          action: Text('Action'),
        ),
      );
      expect(find.text('Title'), findsOneWidget);
      expect(find.text('Some description'), findsOneWidget);
      // action is accepted but not rendered (replaced by cta)
      expect(find.byType(AlertCard), findsOneWidget);
    });

    // New API: time parameter shown in header
    testWidgets('time param renders in header', (WidgetTester tester) async {
      await _pump(
        tester,
        const AlertCard(
          type: AlertType.urgent,
          title: 'Test',
          time: '9:41',
        ),
      );
      expect(find.text('9:41'), findsOneWidget);
    });

    // New API: cta pill renders
    testWidgets('cta param renders pill button', (WidgetTester tester) async {
      var taps = 0;
      await _pump(
        tester,
        AlertCard(
          type: AlertType.urgent,
          title: 'Test',
          cta: 'Подробнее',
          onCtaTap: () => taps++,
        ),
      );
      expect(find.text('Подробнее'), findsOneWidget);
      await tester.tap(find.text('Подробнее'));
      await tester.pump();
      expect(taps, 1);
    });

    // 2-zone structure: head + body columns present
    testWidgets('renders 2-zone structure (head + body)',
        (WidgetTester tester) async {
      await _pump(
        tester,
        const AlertCard(
          type: AlertType.neutral,
          title: 'Zone test',
          body: 'Body text',
          time: '10:00',
        ),
      );
      // Both the type label and title should be visible.
      expect(find.text('NOTE'), findsOneWidget);
      expect(find.text('Zone test'), findsOneWidget);
      expect(find.text('Body text'), findsOneWidget);
      expect(find.text('10:00'), findsOneWidget);
    });
  });
}
