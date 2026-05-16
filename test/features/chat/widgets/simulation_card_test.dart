import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:kai_app/core/design/theme/app_theme.dart';
import 'package:kai_app/core/models/chat_message.dart';
import 'package:kai_app/features/chat/presentation/widgets/message_bubble.dart';

Widget _wrap(ChatMessage msg) => ProviderScope(
      child: MaterialApp(
        theme: AppTheme.light,
        home: Scaffold(
          body: SingleChildScrollView(child: MessageBubble(message: msg)),
        ),
      ),
    );

ChatMessage _kai({
  String content = 'Ответ Kai',
  String? specialMode,
}) =>
    ChatMessage(
      id: 'k1',
      content: content,
      isUser: false,
      timestamp: DateTime.now(),
      specialMode: specialMode,
    );

const _fullSloop = '''
[S-LOOP HEURISTIC PREVIEW]
Heuristic stub preview: not a predictive model.

Simulation: book a flight to Tokyo -> heuristic success estimate 72.0%, heuristic expected cost \$350.00 (\$520.00 p95), risks medium: weather delays possible. Recommendation: Book early for best prices. Proceed?
''';

const _extremeSloop = '''
[S-LOOP PREVIEW]
Simulation: transfer \$50000 -> heuristic success estimate 30.0%, heuristic expected cost \$500.00 (\$800.00 p95), risks extreme: fraud risk high, regulatory block possible. Recommendation: Do not proceed. Proceed?
''';

const _lowRiskSloop = '''
[S-LOOP PREVIEW]
Simulation: book taxi -> heuristic success estimate 95.0%, heuristic expected cost \$25.00 (\$35.00 p95), risks low: no elevated concerns. Recommendation: Safe to book. Proceed?
''';

const _noStatsSloop = '''
[S-LOOP PREVIEW]
Simulation: search hotels -> no predictions available. Proceed?
''';

void main() {
  // ── APP-SIM-CARD-1 ────────────────────────────────────────────────────────

  testWidgets('SimulationCard not shown when specialMode is not S',
      (tester) async {
    await tester.pumpWidget(_wrap(_kai(content: 'Просто ответ')));
    expect(find.text('Kai S-Loop — эвристический прогноз'), findsNothing);
    expect(find.text('Kai S-Loop — симуляция'), findsNothing);
  });

  testWidgets(
      'SimulationCard not shown when specialMode=S but no [S-LOOP] marker',
      (tester) async {
    await tester.pumpWidget(_wrap(_kai(
      specialMode: 'S',
      content: 'Ответ без маркера симуляции',
    )));
    expect(find.text('Kai S-Loop — эвристический прогноз'), findsNothing);
    expect(find.text('Kai S-Loop — симуляция'), findsNothing);
  });

  testWidgets(
      'SimulationCard shows heuristic header and disclaimer for HEURISTIC tag',
      (tester) async {
    await tester.pumpWidget(_wrap(_kai(
      specialMode: 'S',
      content: 'Основной ответ.\n$_fullSloop',
    )));
    await tester.pumpAndSettle();
    expect(find.text('Kai S-Loop — эвристический прогноз'), findsOneWidget);
    expect(
      find.textContaining('Приблизительная оценка'),
      findsOneWidget,
    );
  });

  testWidgets('SimulationCard shows non-heuristic header for plain [S-LOOP]',
      (tester) async {
    await tester.pumpWidget(_wrap(_kai(
      specialMode: 'S',
      content: 'Основной ответ.\n$_extremeSloop',
    )));
    await tester.pumpAndSettle();
    expect(find.text('Kai S-Loop — симуляция'), findsOneWidget);
    expect(find.textContaining('Приблизительная оценка'), findsNothing);
  });

  testWidgets('SimulationCard parses and displays success rate and cost',
      (tester) async {
    await tester.pumpWidget(_wrap(_kai(
      specialMode: 'S',
      content: _fullSloop,
    )));
    await tester.pumpAndSettle();
    expect(find.textContaining('Успех: 72.0%'), findsOneWidget);
    expect(find.textContaining('Стоимость:'), findsOneWidget);
    expect(find.textContaining('\$350.00'), findsOneWidget);
  });

  testWidgets('SimulationCard shows p95 cost in stat chip', (tester) async {
    await tester.pumpWidget(_wrap(_kai(
      specialMode: 'S',
      content: _fullSloop,
    )));
    await tester.pumpAndSettle();
    expect(find.textContaining('p95'), findsOneWidget);
  });

  testWidgets('SimulationCard shows medium risk label', (tester) async {
    await tester.pumpWidget(_wrap(_kai(
      specialMode: 'S',
      content: _fullSloop,
    )));
    await tester.pumpAndSettle();
    expect(find.textContaining('Риск: средний'), findsOneWidget);
  });

  testWidgets('SimulationCard shows extreme risk label for extreme level',
      (tester) async {
    await tester.pumpWidget(_wrap(_kai(
      specialMode: 'S',
      content: _extremeSloop,
    )));
    await tester.pumpAndSettle();
    expect(find.textContaining('Риск: критический'), findsOneWidget);
  });

  testWidgets('SimulationCard shows low risk label for low level',
      (tester) async {
    await tester.pumpWidget(_wrap(_kai(
      specialMode: 'S',
      content: _lowRiskSloop,
    )));
    await tester.pumpAndSettle();
    expect(find.textContaining('Риск: низкий'), findsOneWidget);
  });

  testWidgets(
      'SimulationCard hides risksBreakdown when it contains "no elevated"',
      (tester) async {
    await tester.pumpWidget(_wrap(_kai(
      specialMode: 'S',
      content: _lowRiskSloop,
    )));
    await tester.pumpAndSettle();
    expect(find.textContaining('no elevated'), findsNothing);
    expect(find.textContaining('concerns'), findsNothing);
  });

  testWidgets('SimulationCard shows non-trivial risksBreakdown text',
      (tester) async {
    await tester.pumpWidget(_wrap(_kai(
      specialMode: 'S',
      content: _extremeSloop,
    )));
    await tester.pumpAndSettle();
    expect(find.textContaining('fraud risk high'), findsOneWidget);
  });

  testWidgets('SimulationCard shows recommendation', (tester) async {
    await tester.pumpWidget(_wrap(_kai(
      specialMode: 'S',
      content: _fullSloop,
    )));
    await tester.pumpAndSettle();
    expect(find.textContaining('Book early for best prices'), findsOneWidget);
  });

  testWidgets('SimulationCard renders gracefully when no stats parseable',
      (tester) async {
    await tester.pumpWidget(_wrap(_kai(
      specialMode: 'S',
      content: _noStatsSloop,
    )));
    await tester.pumpAndSettle();
    // Card still shows, just no stat chips
    expect(find.text('Kai S-Loop — симуляция'), findsOneWidget);
    expect(find.textContaining('Успех:'), findsNothing);
    expect(find.textContaining('Стоимость:'), findsNothing);
    expect(find.textContaining('Риск:'), findsNothing);
  });

  testWidgets('SimulationCard lowercase s mode also triggers card',
      (tester) async {
    await tester.pumpWidget(_wrap(_kai(
      specialMode: 's',
      content: _fullSloop,
    )));
    await tester.pumpAndSettle();
    expect(find.text('Kai S-Loop — эвристический прогноз'), findsOneWidget);
  });

  testWidgets('Main content before [S-LOOP] marker is rendered',
      (tester) async {
    await tester.pumpWidget(_wrap(_kai(
      specialMode: 'S',
      content: 'Основной ответ про Токио.\n$_fullSloop',
    )));
    await tester.pumpAndSettle();
    expect(find.textContaining('Основной ответ про Токио'), findsOneWidget);
  });
}
