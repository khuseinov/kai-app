import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:kai_app/core/design/theme/app_theme.dart';
import 'package:kai_app/features/chat/presentation/widgets/approval_actions.dart';

void main() {
  testWidgets('ApprovalActions renders both buttons and forwards taps',
      (tester) async {
    final taps = <String>[];

    await tester.pumpWidget(
      MaterialApp(
        theme: AppTheme.light,
        home: Scaffold(
          body: ApprovalActions(
            confirmationType: 'simulation',
            onApprove: () => taps.add('approve'),
            onReject: () => taps.add('reject'),
          ),
        ),
      ),
    );

    expect(find.text('Подтвердить'), findsOneWidget);
    expect(find.text('Отменить'), findsOneWidget);
    expect(find.byIcon(Icons.check_rounded), findsOneWidget);
    expect(find.byIcon(Icons.close_rounded), findsOneWidget);

    await tester.tap(find.text('Подтвердить'));
    await tester.pump();
    expect(taps, ['approve']);

    await tester.tap(find.text('Отменить'));
    await tester.pump();
    expect(taps, ['approve', 'reject']);
  });

  testWidgets('ApprovalActions ignores taps while isBusy=true', (tester) async {
    final taps = <String>[];

    await tester.pumpWidget(
      MaterialApp(
        theme: AppTheme.light,
        home: Scaffold(
          body: ApprovalActions(
            confirmationType: 'simulation',
            isBusy: true,
            onApprove: () => taps.add('approve'),
            onReject: () => taps.add('reject'),
          ),
        ),
      ),
    );

    await tester.tap(find.text('Подтвердить'));
    await tester.tap(find.text('Отменить'));
    await tester.pump();

    expect(taps, isEmpty,
        reason: 'In-flight guard must block taps while a chat request is streaming');
  });
}
