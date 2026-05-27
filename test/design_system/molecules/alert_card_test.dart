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

Color _backgroundOf(WidgetTester tester) {
  // The AlertCard root is a Container with BoxDecoration carrying our wash.
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

    testWidgets('neutral uses accentWash', (WidgetTester tester) async {
      await _pump(
        tester,
        const AlertCard(type: AlertType.neutral, title: 'Заметка'),
      );
      expect(_backgroundOf(tester), KaiTokens.light.colors.accentWash);
    });

    testWidgets('renders title, body and action together',
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
      expect(find.text('Action'), findsOneWidget);
    });
  });
}
