import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:kai_app/core/design/theme/app_theme.dart';
import 'package:kai_app/features/chat/presentation/widgets/bias_tip_card.dart';

Widget _wrap(Widget child) => MaterialApp(
      theme: AppTheme.light,
      home: Scaffold(body: child),
    );

void main() {
  testWidgets('BiasTipCard renders nothing for empty suggestions',
      (tester) async {
    await tester.pumpWidget(_wrap(const BiasTipCard(suggestions: [])));
    expect(find.byIcon(Icons.lightbulb_outline), findsNothing);
  });

  testWidgets('BiasTipCard shows both tips inline for 2 suggestions',
      (tester) async {
    const tips = ['Consider a second opinion', 'Check primary sources'];

    await tester.pumpWidget(_wrap(const BiasTipCard(suggestions: tips)));

    expect(find.text('Consider a second opinion'), findsOneWidget);
    expect(find.text('Check primary sources'), findsOneWidget);
    expect(find.text('Kai замечает:'), findsOneWidget);
    // No ExpansionTile for ≤2 items
    expect(find.byType(ExpansionTile), findsNothing);
  });

  testWidgets(
      'BiasTipCard uses ExpansionTile and collapses by default for 3+ suggestions',
      (tester) async {
    const tips = ['Tip one', 'Tip two', 'Tip three'];

    await tester.pumpWidget(_wrap(const BiasTipCard(suggestions: tips)));

    expect(find.byType(ExpansionTile), findsOneWidget);
    // Items are hidden in collapsed state
    expect(find.text('Tip one'), findsNothing);
    expect(find.text('Tip two'), findsNothing);
    expect(find.text('Tip three'), findsNothing);
  });

  testWidgets(
      'BiasTipCard ExpansionTile reveals tips after tap', (tester) async {
    const tips = ['Tip one', 'Tip two', 'Tip three'];

    await tester.pumpWidget(_wrap(const BiasTipCard(suggestions: tips)));

    await tester.tap(find.byType(ExpansionTile));
    await tester.pumpAndSettle();

    expect(find.text('Tip one'), findsOneWidget);
    expect(find.text('Tip two'), findsOneWidget);
    expect(find.text('Tip three'), findsOneWidget);
  });
}
