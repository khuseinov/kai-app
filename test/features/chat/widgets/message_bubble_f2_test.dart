import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:kai_app/core/design/theme/app_theme.dart';
import 'package:kai_app/core/models/chat_message.dart';
import 'package:kai_app/features/chat/presentation/widgets/message_bubble.dart';

/// ProviderScope is required because MessageBubble is a ConsumerWidget.
/// Providers are lazy — they are only initialized when accessed, so tests
/// that do NOT trigger the pendingConfirmation branch never touch Hive.
Widget _wrap(ChatMessage msg) => ProviderScope(
      child: MaterialApp(
        theme: AppTheme.light,
        home: Scaffold(
          body: SingleChildScrollView(
            child: MessageBubble(message: msg),
          ),
        ),
      ),
    );

ChatMessage _kai({
  String content = 'Ответ Kai',
  String? specialMode,
  List<String> scopeEscalationCategories = const [],
  bool? scopeEscalationDetected,
  bool? scopeInheritanceViolation,
}) =>
    ChatMessage(
      id: 'k1',
      content: content,
      isUser: false,
      timestamp: DateTime.now(),
      specialMode: specialMode,
      scopeEscalationDetected: scopeEscalationDetected,
      scopeEscalationCategories: scopeEscalationCategories,
      scopeInheritanceViolation: scopeInheritanceViolation,
    );

void main() {
  // ── APP-SCOPE-ESC-1 ────────────────────────────────────────────────────────

  testWidgets(
      'ScopeEscalationBanner hidden when scopeEscalationDetected is false/null',
      (tester) async {
    await tester.pumpWidget(_wrap(_kai()));
    expect(find.text('Kai вышел за рамки'), findsNothing);
  });

  testWidgets('ScopeEscalationBanner shows with translated categories',
      (tester) async {
    await tester.pumpWidget(_wrap(_kai(
      scopeEscalationDetected: true,
      scopeEscalationCategories: ['booking', 'financial_transfer'],
    )));
    expect(find.text('Kai вышел за рамки'), findsOneWidget);
    expect(find.text('бронирование'), findsOneWidget);
    expect(find.text('финансовый перевод'), findsOneWidget);
  });

  testWidgets(
      'ScopeEscalationBanner hidden when categories list is empty despite detected=true',
      (tester) async {
    await tester.pumpWidget(_wrap(_kai(
      scopeEscalationDetected: true,
      scopeEscalationCategories: [],
    )));
    expect(find.text('Kai вышел за рамки'), findsNothing);
  });

  testWidgets(
      'ScopeEscalationBanner uses swap_horiz icon for inheritance violation',
      (tester) async {
    await tester.pumpWidget(_wrap(_kai(
      scopeEscalationDetected: true,
      scopeEscalationCategories: ['booking'],
      scopeInheritanceViolation: true,
    )));
    expect(find.byIcon(Icons.swap_horiz_outlined), findsOneWidget);
    expect(find.byIcon(Icons.fence_outlined), findsNothing);
  });

  testWidgets(
      'ScopeEscalationBanner uses fence icon when no inheritance violation',
      (tester) async {
    await tester.pumpWidget(_wrap(_kai(
      scopeEscalationDetected: true,
      scopeEscalationCategories: ['booking'],
    )));
    expect(find.byIcon(Icons.fence_outlined), findsOneWidget);
  });

  // ── APP-XAI-CARD-1 ────────────────────────────────────────────────────────

  testWidgets('XAIBlock not shown when specialMode is not X', (tester) async {
    await tester.pumpWidget(_wrap(_kai(content: 'Просто ответ')));
    expect(find.text('XAI — объяснение решения'), findsNothing);
  });

  testWidgets('XAIBlock shown collapsed when specialMode=X with [XAI] marker',
      (tester) async {
    await tester.pumpWidget(_wrap(_kai(
      specialMode: 'X',
      content:
          'Основной ответ.[XAI] Intents: travel advice | Critique: ok | Goal: aligned',
    )));
    expect(find.text('XAI — объяснение решения'), findsOneWidget);
    // Content is hidden by default (collapsed)
    expect(find.text('travel advice'), findsNothing);
    // Main text before [XAI] is rendered
    expect(find.textContaining('Основной ответ'), findsOneWidget);
  });

  testWidgets('XAIBlock expands on tap revealing parsed fields',
      (tester) async {
    await tester.pumpWidget(_wrap(_kai(
      specialMode: 'X',
      content: 'Ответ[XAI] Intents: travel | Critique: ok | Goal: aligned',
    )));
    await tester.tap(find.text('XAI — объяснение решения'));
    await tester.pumpAndSettle();
    expect(find.text('travel'), findsOneWidget);
  });

  testWidgets('Content without [XAI] marker renders normally for mode X',
      (tester) async {
    await tester.pumpWidget(_wrap(_kai(
      specialMode: 'X',
      content: 'Ответ без маркера',
    )));
    expect(find.textContaining('Ответ без маркера'), findsOneWidget);
    expect(find.text('XAI — объяснение решения'), findsNothing);
  });

  // ── APP-MEM-CHIP-1 ────────────────────────────────────────────────────────

  testWidgets('MemorizeChip not shown for non-M modes', (tester) async {
    await tester.pumpWidget(_wrap(_kai(specialMode: 'S')));
    expect(find.text('Предпочтение сохранено'), findsNothing);
  });

  testWidgets('MemorizeChip shown when specialMode=M', (tester) async {
    await tester.pumpWidget(_wrap(_kai(specialMode: 'M')));
    expect(find.text('Предпочтение сохранено'), findsOneWidget);
    expect(find.byIcon(Icons.bookmark_added_outlined), findsOneWidget);
  });

  testWidgets('MemorizeChip shown for lowercase m', (tester) async {
    await tester.pumpWidget(_wrap(_kai(specialMode: 'm')));
    expect(find.text('Предпочтение сохранено'), findsOneWidget);
  });
}
