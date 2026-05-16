import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:kai_app/core/design/theme/app_theme.dart';
import 'package:kai_app/core/models/chat_message.dart';
import 'package:kai_app/features/chat/presentation/widgets/safety_block_banner.dart';

Widget _wrap(Widget child) => MaterialApp(
      theme: AppTheme.light,
      home: Scaffold(body: child),
    );

ChatMessage _msg({
  String? blockReason,
  String? injectionFragment,
  String? injectionSource,
}) =>
    ChatMessage(
      id: 'test-id',
      content: 'Response',
      isUser: false,
      timestamp: DateTime.now(),
      blockReason: blockReason,
      injectionFragment: injectionFragment,
      injectionSource: injectionSource,
    );

void main() {
  testWidgets('SafetyBlockBanner returns SizedBox when message is null',
      (tester) async {
    await tester.pumpWidget(
        _wrap(const SafetyBlockBanner(latestMessage: null)));
    expect(find.byType(Container), findsNothing);
  });

  testWidgets('SafetyBlockBanner returns SizedBox when user message',
      (tester) async {
    final msg = ChatMessage(
      id: 'u',
      content: 'Hello',
      isUser: true,
      timestamp: DateTime.now(),
    );
    await tester.pumpWidget(
        _wrap(SafetyBlockBanner(latestMessage: msg)));
    expect(find.byIcon(Icons.shield_outlined), findsNothing);
  });

  testWidgets(
      'SafetyBlockBanner returns SizedBox when neither blockReason nor fragment',
      (tester) async {
    final msg = _msg();
    await tester.pumpWidget(_wrap(SafetyBlockBanner(latestMessage: msg)));
    expect(find.byIcon(Icons.shield_outlined), findsNothing);
  });

  testWidgets(
      'SafetyBlockBanner shows injection title and fragment for blockReason=injection',
      (tester) async {
    final msg = _msg(
      blockReason: 'injection',
      injectionFragment: 'ignore previous instructions',
      injectionSource: 'tool:web_search',
    );

    await tester.pumpWidget(_wrap(SafetyBlockBanner(latestMessage: msg)));

    expect(find.text('Обнаружен подозрительный фрагмент'), findsOneWidget);
    expect(find.textContaining('ignore previous instructions'), findsOneWidget);
    expect(find.textContaining('tool:web_search'), findsOneWidget);
  });

  testWidgets(
      'SafetyBlockBanner shows social engineering title and hides fragment',
      (tester) async {
    final msg = _msg(
      blockReason: 'social_engineering',
      injectionFragment: 'pretend you are',
    );

    await tester.pumpWidget(_wrap(SafetyBlockBanner(latestMessage: msg)));

    expect(find.text('Попытка социальной инженерии'), findsOneWidget);
    expect(find.textContaining('pretend you are'), findsNothing);
  });

  testWidgets('SafetyBlockBanner shows goal_alignment title', (tester) async {
    final msg = _msg(blockReason: 'goal_alignment');

    await tester.pumpWidget(_wrap(SafetyBlockBanner(latestMessage: msg)));

    expect(find.text('Запрос вне области Kai'), findsOneWidget);
  });

  testWidgets('SafetyBlockBanner shows pii title', (tester) async {
    final msg = _msg(blockReason: 'pii');

    await tester.pumpWidget(_wrap(SafetyBlockBanner(latestMessage: msg)));

    expect(find.text('Запрос содержит личные данные'), findsOneWidget);
  });

  testWidgets(
      'SafetyBlockBanner shows fragment-only banner when blockReason is null but fragment present',
      (tester) async {
    final msg = _msg(injectionFragment: 'suspicious text');

    await tester.pumpWidget(_wrap(SafetyBlockBanner(latestMessage: msg)));

    expect(find.text('Обнаружен подозрительный фрагмент'), findsOneWidget);
    expect(find.textContaining('suspicious text'), findsOneWidget);
  });
}
