import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:kai_app/core/design/theme/app_theme.dart';
import 'package:kai_app/features/chat/presentation/widgets/approval_actions.dart';
import 'package:kai_app/features/chat/presentation/widgets/message_metadata_row.dart';
import 'package:kai_app/core/models/chat_message.dart';

Widget _wrap(Widget child) => MaterialApp(
      theme: AppTheme.light,
      home: Scaffold(body: child),
    );

ChatMessage _makeMessage({
  bool advisorTriggered = false,
  bool requiresHumanApproval = false,
}) =>
    ChatMessage(
      id: 'adv-test',
      content: 'Kai answer',
      isUser: false,
      timestamp: DateTime(2026, 5, 16),
      status: 'sent',
      advisorTriggered: advisorTriggered,
      requiresHumanApproval: requiresHumanApproval,
    );

void main() {
  // ── ApprovalActions ──────────────────────────────────────────────────────────

  testWidgets(
      'ApprovalActions shows advisor context label when advisorTriggered',
      (tester) async {
    await tester.pumpWidget(
      _wrap(
        ApprovalActions(
          confirmationType: 'simulation',
          advisorTriggered: true,
          onApprove: () {},
          onReject: () {},
        ),
      ),
    );
    expect(find.textContaining('критичный сценарий'), findsOneWidget);
  });

  testWidgets(
      'ApprovalActions hides advisor label when advisorTriggered is false',
      (tester) async {
    await tester.pumpWidget(
      _wrap(
        ApprovalActions(
          confirmationType: 'simulation',
          onApprove: () {},
          onReject: () {},
        ),
      ),
    );
    expect(find.textContaining('критичный сценарий'), findsNothing);
  });

  // ── MessageMetadataRow ───────────────────────────────────────────────────────

  testWidgets(
      'MessageMetadataRow shows advisor chip when advisorTriggered=true and no HITL',
      (tester) async {
    final msg =
        _makeMessage(advisorTriggered: true, requiresHumanApproval: false);
    await tester.pumpWidget(_wrap(MessageMetadataRow(message: msg)));
    expect(find.textContaining('уточнил'), findsOneWidget);
  });

  testWidgets(
      'MessageMetadataRow hides advisor chip when requiresHumanApproval=true',
      (tester) async {
    final msg =
        _makeMessage(advisorTriggered: true, requiresHumanApproval: true);
    await tester.pumpWidget(_wrap(MessageMetadataRow(message: msg)));
    expect(find.textContaining('уточнил'), findsNothing);
  });

  testWidgets(
      'MessageMetadataRow hides advisor chip when advisorTriggered=false',
      (tester) async {
    final msg = _makeMessage();
    await tester.pumpWidget(_wrap(MessageMetadataRow(message: msg)));
    expect(find.textContaining('уточнил'), findsNothing);
  });
}
