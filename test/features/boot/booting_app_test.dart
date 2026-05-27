import 'package:flutter_test/flutter_test.dart';
import 'package:kai_app/features/boot/booting_app.dart';
import 'package:kai_app/features/boot/splash_screen.dart';

void main() {
  group('BootingApp', () {
    testWidgets('shows SplashScreen on the very first frame', (tester) async {
      await tester.pumpWidget(const BootingApp());
      // First frame — bootstrap() not yet returned (it's an async gap).
      expect(find.byType(SplashScreen), findsOneWidget);
      // Drive a bounded pump — pumpAndSettle would hang on the glyph-pulse
      // animation (repeat reverse). 2s is plenty for bootstrap microtasks.
      await tester.pump(const Duration(seconds: 2));
    });
  });
}
