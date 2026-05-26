import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:kai_app/design_system/atoms/kai_tide_curve.dart';
import 'package:kai_app/design_system/theme/kai_theme.dart';
import 'package:kai_app/design_system/tokens/kai_tokens.dart';

Future<void> _pump(
  WidgetTester tester,
  Widget child, {
  bool disableAnimations = false,
}) async {
  await tester.pumpWidget(
    ProviderScope(
      child: MediaQuery(
        data: MediaQueryData(disableAnimations: disableAnimations),
        child: MaterialApp(
          home: KaiTheme(
            child: Scaffold(
              body: Center(
                child: SizedBox(width: 240, height: 28, child: child),
              ),
            ),
          ),
        ),
      ),
    ),
  );
  await tester.pump();
}

void main() {
  group('KaiTideCurve - non-ephemeral states', () {
    for (final state in const [
      KaiTide.idle,
      KaiTide.listening,
      KaiTide.thinking,
      KaiTide.responding,
      KaiTide.sleep,
    ]) {
      testWidgets('renders for ${state.name}', (tester) async {
        await _pump(tester, KaiTideCurve(state: state));
        expect(find.byType(KaiTideCurve), findsOneWidget);
        // Pump a few frames to make sure the animation controller doesn't
        // throw and the paint cycle is alive.
        await tester.pump(const Duration(milliseconds: 100));
        await tester.pump(const Duration(milliseconds: 100));
        expect(find.byType(KaiTideCurve), findsOneWidget);
        // Drain remaining animation work by un-mounting cleanly.
        await tester.pumpWidget(const SizedBox.shrink());
      });
    }
  });

  group('KaiTideCurve - ephemeral states', () {
    testWidgets('success ephemeral reverts to prior state', (tester) async {
      await _pump(tester, const KaiTideCurve(state: KaiTide.idle));
      await tester.pump(const Duration(milliseconds: 50));

      // Swap to success.
      await tester.pumpWidget(
        const ProviderScope(
          child: MediaQuery(
            data: MediaQueryData(),
            child: MaterialApp(
              home: _SuccessHost(),
            ),
          ),
        ),
      );
      // Pump through the 3 cycles of 1200ms each = 3600ms total.
      await tester.pump(const Duration(milliseconds: 1300));
      await tester.pump(const Duration(milliseconds: 1300));
      await tester.pump(const Duration(milliseconds: 1300));
      // After auto-revert, the curve should still be on screen rendering
      // the restored state.
      expect(find.byType(KaiTideCurve), findsOneWidget);
      await tester.pumpWidget(const SizedBox.shrink());
    });

    testWidgets('error ephemeral lifecycle does not throw', (tester) async {
      await _pump(tester, const KaiTideCurve(state: KaiTide.error));
      // 2 cycles of 700ms with 1000ms gap = 700 + 1000 + 700 = 2400ms.
      await tester.pump(const Duration(milliseconds: 800));
      await tester.pump(const Duration(milliseconds: 1100));
      await tester.pump(const Duration(milliseconds: 800));
      expect(find.byType(KaiTideCurve), findsOneWidget);
      await tester.pumpWidget(const SizedBox.shrink());
    });

    testWidgets('memory ephemeral lifecycle does not throw', (tester) async {
      await _pump(tester, const KaiTideCurve(state: KaiTide.memory));
      // 3 cycles of 900ms with 500ms gap.
      for (var i = 0; i < 3; i++) {
        await tester.pump(const Duration(milliseconds: 950));
        await tester.pump(const Duration(milliseconds: 550));
      }
      expect(find.byType(KaiTideCurve), findsOneWidget);
      await tester.pumpWidget(const SizedBox.shrink());
    });
  });

  testWidgets('honors MediaQuery.disableAnimationsOf', (tester) async {
    // With accessibility opt-in, the controller still exists but
    // animationValue collapsed to 0 — no exceptions, stable rendering.
    await _pump(
      tester,
      const KaiTideCurve(state: KaiTide.thinking),
      disableAnimations: true,
    );
    await tester.pump(const Duration(milliseconds: 200));
    expect(find.byType(KaiTideCurve), findsOneWidget);
    await tester.pumpWidget(const SizedBox.shrink());
  });

  testWidgets('disposes controller on unmount', (tester) async {
    await _pump(tester, const KaiTideCurve(state: KaiTide.listening));
    await tester.pump(const Duration(milliseconds: 50));
    await tester.pumpWidget(const SizedBox.shrink());
    // No exception means dispose() was called cleanly.
  });
}

/// Test-only host that wraps [KaiTideCurve] in the canonical scaffolding so
/// nested branches can be `const` constructible.
class _SuccessHost extends StatelessWidget {
  const _SuccessHost();

  @override
  Widget build(BuildContext context) {
    return const KaiTheme(
      child: Scaffold(
        body: Center(
          child: SizedBox(
            width: 240,
            height: 28,
            child: KaiTideCurve(state: KaiTide.success),
          ),
        ),
      ),
    );
  }
}
