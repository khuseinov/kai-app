import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:kai_app/core/design/components/kai_connectivity_pill.dart';
import 'package:kai_app/core/design/theme/app_theme.dart';

Widget _wrap(ConnectivityPillState state) {
  return MaterialApp(
    theme: AppTheme.light,
    home: Scaffold(body: KaiConnectivityPill(state: state)),
  );
}

void main() {
  testWidgets('pill renders online state with green dot', (tester) async {
    await tester.pumpWidget(_wrap(ConnectivityPillState.online));
    expect(find.byKey(const Key('connectivity_pill_online')), findsOneWidget);
    expect(find.text('online'), findsOneWidget);
  });

  testWidgets('pill renders degraded state with warning dot', (tester) async {
    await tester.pumpWidget(_wrap(ConnectivityPillState.degraded));
    expect(find.byKey(const Key('connectivity_pill_degraded')), findsOneWidget);
    expect(find.text('degraded'), findsOneWidget);
  });

  testWidgets('pill renders offline state with red dot', (tester) async {
    await tester.pumpWidget(_wrap(ConnectivityPillState.offline));
    expect(find.byKey(const Key('connectivity_pill_offline')), findsOneWidget);
    expect(find.text('offline'), findsOneWidget);
  });
}
