import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:kai_app/core/models/chat_message.dart';
import 'package:kai_app/core/models/tool_source.dart';
import 'package:kai_app/features/chat/presentation/widgets/message_metadata_row.dart';

import '../../../helpers/test_helpers.dart';

void main() {
  group('MessageMetadataRow', () {
    testWidgets('returns SizedBox for user messages', (tester) async {
      final msg = _userMessage();
      await tester.pumpWidget(buildTestWidget(MessageMetadataRow(message: msg)));
      expect(find.byIcon(Icons.verified_outlined), findsNothing);
    });

    testWidgets('returns SizedBox for Kai message with no sources', (tester) async {
      final msg = _kaiMessage();
      await tester.pumpWidget(buildTestWidget(MessageMetadataRow(message: msg)));
      // Reactions moved to _ReactionRow inside MessageBubble — not shown here
      expect(find.byIcon(Icons.thumb_up_outlined), findsNothing);
      expect(find.byIcon(Icons.thumb_down_outlined), findsNothing);
      expect(find.byIcon(Icons.verified_outlined), findsNothing);
    });

    testWidgets('shows source count badge when sources present', (tester) async {
      final msg = _kaiMessage(sourceCount: 2);
      await tester.pumpWidget(buildTestWidget(MessageMetadataRow(message: msg)));
      expect(find.textContaining('Проверено в 2'), findsOneWidget);
      expect(find.byIcon(Icons.verified_outlined), findsOneWidget);
    });

    testWidgets('does NOT show mode chip or tool chip', (tester) async {
      final msg = _kaiMessage(requestType: 'orchestrator', toolCalls: ['visa_checker']);
      await tester.pumpWidget(buildTestWidget(MessageMetadataRow(message: msg)));
      expect(find.text('инструменты'), findsNothing);
      expect(find.text('виза'), findsNothing);
    });

    testWidgets('does NOT show revision or advisor chip', (tester) async {
      final msg = _kaiMessage(revisionCount: 2, advisorTriggered: true);
      await tester.pumpWidget(buildTestWidget(MessageMetadataRow(message: msg)));
      expect(find.text('перепроверено'), findsNothing);
      expect(find.textContaining('уточнил'), findsNothing);
    });

    testWidgets('singular label for 1 source', (tester) async {
      final msg = _kaiMessage(sourceCount: 1);
      await tester.pumpWidget(buildTestWidget(MessageMetadataRow(message: msg)));
      expect(find.text('Проверено в 1 источнике'), findsOneWidget);
    });
  });
}

ChatMessage _userMessage() => ChatMessage(
      id: '1',
      content: 'Привет',
      isUser: true,
      timestamp: DateTime.now(),
    );

ChatMessage _kaiMessage({
  int sourceCount = 0,
  String? requestType,
  List<String> toolCalls = const [],
  int? revisionCount,
  bool advisorTriggered = false,
}) =>
    ChatMessage(
      id: '2',
      content: 'Ответ Kai',
      isUser: false,
      timestamp: DateTime.now(),
      sources: List.generate(sourceCount, (_) => _makeSource()),
      requestType: requestType,
      executedToolCalls: toolCalls,
      revisionCount: revisionCount,
      advisorTriggered: advisorTriggered,
    );

ToolSource _makeSource() => const ToolSource(
      tool: 'web_search_sandboxed',
      source: 'https://example.com',
    );
