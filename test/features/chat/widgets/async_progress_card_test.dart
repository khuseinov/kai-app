import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:kai_app/core/design/theme/app_theme.dart';
import 'package:kai_app/features/chat/presentation/widgets/async_progress_card.dart';

Widget _wrap(Widget child) => MaterialApp(
      theme: AppTheme.light,
      home: Scaffold(body: child),
    );

void main() {
  testWidgets('AsyncProgressCard pending state shows spinner and label',
      (tester) async {
    await tester.pumpWidget(
      _wrap(const AsyncProgressCard(
        state: AsyncTaskState.pending,
        elapsedSeconds: 0,
      )),
    );
    expect(find.byType(CircularProgressIndicator), findsOneWidget);
    expect(find.textContaining('Kai думает'), findsOneWidget);
  });

  testWidgets('AsyncProgressCard pending shows elapsed seconds when > 0',
      (tester) async {
    await tester.pumpWidget(
      _wrap(const AsyncProgressCard(
        state: AsyncTaskState.pending,
        elapsedSeconds: 17,
      )),
    );
    expect(find.textContaining('17с'), findsOneWidget);
  });

  testWidgets('AsyncProgressCard pending shows cancel button when onCancel set',
      (tester) async {
    var cancelled = false;
    await tester.pumpWidget(
      _wrap(AsyncProgressCard(
        state: AsyncTaskState.pending,
        onCancel: () => cancelled = true,
      )),
    );
    await tester.tap(find.text('Отменить'));
    expect(cancelled, isTrue);
  });

  testWidgets('AsyncProgressCard failed state shows error icon and message',
      (tester) async {
    await tester.pumpWidget(
      _wrap(const AsyncProgressCard(
        state: AsyncTaskState.failed,
        errorMessage: 'Timeout exceeded',
      )),
    );
    expect(find.byIcon(Icons.error_outline), findsOneWidget);
    expect(find.textContaining('Timeout exceeded'), findsOneWidget);
    expect(find.byType(CircularProgressIndicator), findsNothing);
  });

  testWidgets('AsyncProgressCard failed uses fallback message when null error',
      (tester) async {
    await tester.pumpWidget(
      _wrap(const AsyncProgressCard(state: AsyncTaskState.failed)),
    );
    expect(find.textContaining('не смог'), findsOneWidget);
  });
}
