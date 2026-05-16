import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:kai_app/core/design/theme/app_theme.dart';
import 'package:kai_app/core/models/chat_message.dart';
import 'package:kai_app/features/chat/presentation/widgets/message_metadata_row.dart';

ChatMessage _kaiMessage({String? requestType}) {
  return ChatMessage(
    id: 'm1',
    content: 'Hi',
    isUser: false,
    timestamp: DateTime(2026, 5, 4),
    requestType: requestType,
  );
}

Widget _wrap(ChatMessage msg) {
  return MaterialApp(
    theme: AppTheme.light,
    home: Scaffold(body: MessageMetadataRow(message: msg)),
  );
}

void main() {
  group('autonomous depth chip', () {
    testWidgets('hides for fast (default tier)', (tester) async {
      await tester.pumpWidget(_wrap(_kaiMessage(requestType: 'fast')));
      expect(find.text('инструменты'), findsNothing);
      expect(find.text('глубокий разбор'), findsNothing);
    });

    testWidgets('hides for standard (default tier)', (tester) async {
      await tester.pumpWidget(_wrap(_kaiMessage(requestType: 'standard')));
      expect(find.text('инструменты'), findsNothing);
    });

    testWidgets('shows "инструменты" when Kai escalates to orchestrator',
        (tester) async {
      await tester.pumpWidget(_wrap(_kaiMessage(requestType: 'orchestrator')));
      expect(find.text('инструменты'), findsOneWidget);
    });

    testWidgets('shows "глубокий разбор" for reasoning tier', (tester) async {
      await tester.pumpWidget(_wrap(_kaiMessage(requestType: 'reasoning')));
      expect(find.text('глубокий разбор'), findsOneWidget);
    });

    testWidgets('shows "глубокий разбор" for heavy tier', (tester) async {
      await tester.pumpWidget(_wrap(_kaiMessage(requestType: 'heavy')));
      expect(find.text('глубокий разбор'), findsOneWidget);
    });

    testWidgets('shows "безопасный режим" for sensitive tier', (tester) async {
      await tester.pumpWidget(_wrap(_kaiMessage(requestType: 'sensitive')));
      expect(find.text('безопасный режим'), findsOneWidget);
    });

    testWidgets('shows "мультимодально" for multimodal tier', (tester) async {
      await tester.pumpWidget(_wrap(_kaiMessage(requestType: 'multimodal')));
      expect(find.text('мультимодально'), findsOneWidget);
    });

    testWidgets('hides for unknown / null request type', (tester) async {
      await tester.pumpWidget(_wrap(_kaiMessage()));
      // No metadata at all → row collapses to SizedBox.shrink.
      expect(find.byType(Padding), findsNothing);
    });
  });

  testWidgets('user messages render nothing', (tester) async {
    final userMsg = ChatMessage(
      id: 'u1',
      content: 'привет',
      isUser: true,
      timestamp: DateTime(2026, 5, 4),
      requestType: 'reasoning',
    );
    await tester.pumpWidget(_wrap(userMsg));
    expect(find.text('глубокий разбор'), findsNothing);
  });

  testWidgets(
      'tool chips dedupe duplicate executed_tool_calls (BUG-DUP-CHIPS-1)',
      (tester) async {
    // Backend often reports the same tool 3-4 times because of cache hits
    // and iteration retries. The metadata row must render ONE chip per
    // unique tool name, not one per occurrence.
    final msg = ChatMessage(
      id: 'm1',
      content: 'hi',
      isUser: false,
      timestamp: DateTime(2026, 5, 16),
      requestType: 'fast',
      executedToolCalls: const [
        'health_requirements',
        'health_requirements',
        'health_requirements',
        'health_requirements',
      ],
    );
    await tester.pumpWidget(_wrap(msg));
    expect(find.text('здоровье'), findsOneWidget);
  });

  testWidgets('tool chips keep distinct tools', (tester) async {
    final msg = ChatMessage(
      id: 'm1',
      content: 'hi',
      isUser: false,
      timestamp: DateTime(2026, 5, 16),
      requestType: 'fast',
      executedToolCalls: const [
        'visa_checker',
        'health_requirements',
        'visa_checker',
      ],
    );
    await tester.pumpWidget(_wrap(msg));
    expect(find.text('виза'), findsOneWidget);
    expect(find.text('здоровье'), findsOneWidget);
  });
}
