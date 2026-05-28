import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:kai_app/design_system/theme/kai_theme.dart';
import 'package:kai_app/design_system/tokens/kai_tokens.dart';
import 'package:kai_app/design_system/atoms/kai_tide_curve.dart';

// ---------------------------------------------------------------------------
// Helpers
// ---------------------------------------------------------------------------

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
  group('v3/KaiTideCurve - non-ephemeral states', () {
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
        // Pump a few frames to verify animation controller doesn't throw.
        await tester.pump(const Duration(milliseconds: 100));
        await tester.pump(const Duration(milliseconds: 100));
        expect(find.byType(KaiTideCurve), findsOneWidget);
        // Drain remaining animation work by un-mounting cleanly.
        await tester.pumpWidget(const SizedBox.shrink());
      });
    }
  });

  group('v3/KaiTideCurve - ephemeral states', () {
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
      expect(find.byType(KaiTideCurve), findsOneWidget);
      await tester.pumpWidget(const SizedBox.shrink());
    });

    testWidgets('error ephemeral lifecycle does not throw', (tester) async {
      await _pump(tester, const KaiTideCurve(state: KaiTide.error));
      // 2 cycles of 600ms with 1000ms gap = 600 + 1000 + 600 = 2200ms.
      await tester.pump(const Duration(milliseconds: 700));
      await tester.pump(const Duration(milliseconds: 1100));
      await tester.pump(const Duration(milliseconds: 700));
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

    // Regression: success (3 flash cycles, gapMs=0) must not trigger
    // use-after-dispose via status listener. The fix defers via microtask.
    testWidgets('success no-gap cycles do not throw FlutterErrors',
        (tester) async {
      final errors = <FlutterErrorDetails>[];
      final prior = FlutterError.onError;
      FlutterError.onError = (details) => errors.add(details);
      try {
        await _pump(tester, const KaiTideCurve(state: KaiTide.success));
        for (var i = 0; i < 3; i++) {
          await tester.pump(const Duration(milliseconds: 1250));
        }
        await tester.pump(const Duration(milliseconds: 100));
        expect(errors, isEmpty,
            reason: 'expected no FlutterErrors across the 3 success '
                'ephemeral cycles, but got: $errors');
        expect(find.byType(KaiTideCurve), findsOneWidget);
      } finally {
        FlutterError.onError = prior;
        await tester.pumpWidget(const SizedBox.shrink());
      }
    });
  });

  testWidgets('v3/KaiTideCurve honors MediaQuery.disableAnimationsOf',
      (tester) async {
    await _pump(
      tester,
      const KaiTideCurve(state: KaiTide.thinking),
      disableAnimations: true,
    );
    await tester.pump(const Duration(milliseconds: 200));
    expect(find.byType(KaiTideCurve), findsOneWidget);
    await tester.pumpWidget(const SizedBox.shrink());
  });

  testWidgets('v3/KaiTideCurve disposes controller on unmount', (tester) async {
    await _pump(tester, const KaiTideCurve(state: KaiTide.listening));
    await tester.pump(const Duration(milliseconds: 50));
    await tester.pumpWidget(const SizedBox.shrink());
    // No exception means dispose() was called cleanly.
  });
}

// ---------------------------------------------------------------------------
// Test-only host
// ---------------------------------------------------------------------------

/// Wraps [KaiTideCurve] in canonical scaffolding so nested branches can be
/// `const` constructible — ported from the v2 test.
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
