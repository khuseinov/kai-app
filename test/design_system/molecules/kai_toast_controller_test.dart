import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:kai_app/design_system/molecules/kai_toast.dart';
import 'package:kai_app/design_system/molecules/kai_toast_controller.dart';

import '../../test_helpers.dart';

/// Wraps [child] in a tree that has a Navigator + Overlay, which is required
/// for [KaiToastController.show] (uses [Overlay.of]).
Widget _withOverlay(Widget child) {
  return buildTestWidget(child);
}

/// A tap-target that shows a toast via [KaiToastController].
class _ToastHost extends StatelessWidget {
  const _ToastHost({
    required this.type,
    required this.label,
    this.duration = const Duration(seconds: 3),
  });

  final KaiToastType type;
  final String label;
  final Duration duration;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => KaiToastController.show(
        context,
        type: type,
        label: label,
        duration: duration,
      ),
      child: const Text('show', textDirection: TextDirection.ltr),
    );
  }
}

void main() {
  group('v3/KaiToastController', () {
    // -------------------------------------------------------------------------
    // show() inserts a KaiToast into the overlay
    // -------------------------------------------------------------------------

    testWidgets('show() inserts a KaiToast overlay entry', (tester) async {
      await tester.pumpWidget(_withOverlay(const _ToastHost(
        type: KaiToastType.neutral,
        label: 'Готово',
        duration: Duration(milliseconds: 200),
      ),),);
      await tester.pump();

      // Before tap — no toast.
      expect(find.byType(KaiToast), findsNothing);

      await tester.tap(find.text('show'));
      await tester.pump();

      // After tap — toast visible.
      expect(find.byType(KaiToast), findsOneWidget);
      expect(find.text('Готово'), findsOneWidget);

      // Advance past duration so the timer fires and no pending timer remains.
      await tester.pump(const Duration(milliseconds: 300));
    });

    // -------------------------------------------------------------------------
    // auto-dismiss after duration
    // -------------------------------------------------------------------------

    testWidgets('toast auto-dismisses after duration', (tester) async {
      const dur = Duration(milliseconds: 500);
      await tester.pumpWidget(_withOverlay(const _ToastHost(
        type: KaiToastType.neutral,
        label: 'Авто',
        duration: dur,
      ),),);
      await tester.pump();

      await tester.tap(find.text('show'));
      await tester.pump();
      expect(find.byType(KaiToast), findsOneWidget);

      // Advance past the duration.
      await tester.pump(const Duration(milliseconds: 600));

      expect(find.byType(KaiToast), findsNothing,
          reason: 'toast must auto-dismiss after duration',);
    });

    // -------------------------------------------------------------------------
    // second show() replaces the first (only one toast at a time)
    // -------------------------------------------------------------------------

    testWidgets('second show() replaces first toast', (tester) async {
      late BuildContext capturedContext;

      await tester.pumpWidget(_withOverlay(Builder(builder: (ctx) {
        capturedContext = ctx;
        return const SizedBox();
      },),),);
      await tester.pump();

      KaiToastController.show(
        capturedContext,
        type: KaiToastType.neutral,
        label: 'Первый',
        duration: const Duration(seconds: 10),
      );
      await tester.pump();
      expect(find.text('Первый'), findsOneWidget);

      KaiToastController.show(
        capturedContext,
        type: KaiToastType.positive,
        label: 'Второй',
        duration: const Duration(seconds: 10),
      );
      await tester.pump();

      // Only the second toast should exist.
      expect(find.text('Первый'), findsNothing,
          reason: 'first toast must be replaced',);
      expect(find.text('Второй'), findsOneWidget,
          reason: 'second toast must be visible',);
      expect(find.byType(KaiToast), findsOneWidget,
          reason: 'only one toast at a time',);

      // Cancel pending timer so the test framework is satisfied.
      KaiToastController.dismiss();
      await tester.pump();
    });

    // -------------------------------------------------------------------------
    // dismiss() removes the toast programmatically
    // -------------------------------------------------------------------------

    testWidgets('dismiss() removes the toast', (tester) async {
      late BuildContext capturedContext;

      await tester.pumpWidget(_withOverlay(Builder(builder: (ctx) {
        capturedContext = ctx;
        return const SizedBox();
      },),),);
      await tester.pump();

      KaiToastController.show(
        capturedContext,
        type: KaiToastType.neutral,
        label: 'Буду удалён',
        duration: const Duration(seconds: 10),
      );
      await tester.pump();
      expect(find.byType(KaiToast), findsOneWidget);

      KaiToastController.dismiss();
      await tester.pump();

      expect(find.byType(KaiToast), findsNothing,
          reason: 'dismiss() must remove the overlay entry',);
    });

    // -------------------------------------------------------------------------
    // dismiss() is safe when no toast is shown (no exception)
    // -------------------------------------------------------------------------

    testWidgets('dismiss() is safe when no toast is showing', (tester) async {
      await tester.pumpWidget(_withOverlay(const SizedBox()));
      await tester.pump();

      // Must not throw.
      expect(KaiToastController.dismiss, returnsNormally);
    });

    // -------------------------------------------------------------------------
    // show() builds the KaiToast with correct type and label
    // -------------------------------------------------------------------------

    testWidgets('show() passes type and label to KaiToast', (tester) async {
      late BuildContext capturedContext;

      await tester.pumpWidget(_withOverlay(Builder(builder: (ctx) {
        capturedContext = ctx;
        return const SizedBox();
      },),),);
      await tester.pump();

      KaiToastController.show(
        capturedContext,
        type: KaiToastType.negative,
        label: 'Ошибка',
        actionLabel: 'Повторить',
        duration: const Duration(seconds: 10),
      );
      await tester.pump();

      final toastWidget = tester.widget<KaiToast>(find.byType(KaiToast));
      expect(toastWidget.type, KaiToastType.negative);
      expect(toastWidget.label, 'Ошибка');
      expect(toastWidget.actionLabel, 'Повторить');

      // Cancel pending timer before test teardown.
      KaiToastController.dismiss();
      await tester.pump();
    });

    // -------------------------------------------------------------------------
    // duration == zero means persistent (does not auto-dismiss)
    // -------------------------------------------------------------------------

    testWidgets('duration zero keeps toast visible indefinitely', (tester) async {
      late BuildContext capturedContext;

      await tester.pumpWidget(_withOverlay(Builder(builder: (ctx) {
        capturedContext = ctx;
        return const SizedBox();
      },),),);
      await tester.pump();

      KaiToastController.show(
        capturedContext,
        type: KaiToastType.memory,
        label: 'Постоянный',
        duration: Duration.zero,
      );
      await tester.pump();
      expect(find.byType(KaiToast), findsOneWidget);

      // Pump a long time — should still be there.
      await tester.pump(const Duration(seconds: 30));
      expect(find.byType(KaiToast), findsOneWidget,
          reason: 'duration zero = persistent, no auto-dismiss',);
    });
  });
}
