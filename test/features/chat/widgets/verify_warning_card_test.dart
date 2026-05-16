import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:kai_app/core/design/theme/app_theme.dart';
import 'package:kai_app/features/chat/presentation/widgets/verify_warning_card.dart';

Widget _wrap(Widget child) => MaterialApp(
      theme: AppTheme.light,
      home: Scaffold(body: child),
    );

void main() {
  testWidgets('VerifyWarningCard renders nothing for empty warnings',
      (tester) async {
    await tester.pumpWidget(_wrap(const VerifyWarningCard(sourceWarnings: [])));
    expect(find.byType(ExpansionTile), findsNothing);
  });

  testWidgets('VerifyWarningCard renders nothing for non-VERIFY warnings',
      (tester) async {
    await tester.pumpWidget(
      _wrap(const VerifyWarningCard(
        sourceWarnings: ['conflict: mismatch between sources'],
      )),
    );
    expect(find.byType(ExpansionTile), findsNothing);
  });

  testWidgets('VerifyWarningCard shows ExpansionTile for VERIFY entries',
      (tester) async {
    const warnings = [
      '[VERIFY] visa_tool_evidence: Visa claim without executed tool',
    ];
    await tester
        .pumpWidget(_wrap(const VerifyWarningCard(sourceWarnings: warnings)));
    expect(find.byType(ExpansionTile), findsOneWidget);
    expect(find.textContaining('1 замечание'), findsOneWidget);
  });

  testWidgets('VerifyWarningCard strips [VERIFY] prefix in expanded list',
      (tester) async {
    const warnings = [
      '[VERIFY] visa_tool_evidence: Visa claim without executed tool',
    ];
    await tester
        .pumpWidget(_wrap(const VerifyWarningCard(sourceWarnings: warnings)));
    await tester.tap(find.byType(ExpansionTile));
    await tester.pumpAndSettle();
    expect(find.textContaining('visa_tool_evidence'), findsOneWidget);
    expect(find.textContaining('[VERIFY]'), findsNothing);
  });

  testWidgets('VerifyWarningCard shows plural label for multiple VERIFY entries',
      (tester) async {
    const warnings = [
      '[VERIFY] visa_tool_evidence: Claim 1',
      '[VERIFY] cost_numeric: Cost figure without tool',
    ];
    await tester
        .pumpWidget(_wrap(const VerifyWarningCard(sourceWarnings: warnings)));
    expect(find.textContaining('2 замечания'), findsOneWidget);
  });

  testWidgets(
      'VerifyWarningCard filters only VERIFY entries from mixed warnings',
      (tester) async {
    const warnings = [
      'conflict: sources disagree',
      '[VERIFY] legal_advice: Legal claim without citation',
    ];
    await tester
        .pumpWidget(_wrap(const VerifyWarningCard(sourceWarnings: warnings)));
    expect(find.textContaining('1 замечание'), findsOneWidget);
  });
}
