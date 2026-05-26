import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:kai_app/core/providers/root.dart';
import 'package:kai_app/design_system/atoms/kai_button.dart';
import 'package:kai_app/design_system/atoms/kai_button_send.dart';
import 'package:kai_app/design_system/atoms/kai_icon.dart';
import 'package:kai_app/design_system/theme/kai_theme.dart';

Future<void> _pump(
  WidgetTester tester,
  Widget child, {
  ThemeMode mode = ThemeMode.light,
}) async {
  await tester.pumpWidget(
    ProviderScope(
      overrides: [themeModeProvider.overrideWith((ref) => mode)],
      child: MaterialApp(
        home: KaiTheme(
          child: Scaffold(
            body: Center(child: child),
          ),
        ),
      ),
    ),
  );
  await tester.pump();
}

void main() {
  group('KaiButton variants', () {
    testWidgets('tide: renders label + tap fires callback', (tester) async {
      var taps = 0;
      await _pump(
        tester,
        KaiButton.tide(onPressed: () => taps++, label: 'Go'),
      );
      expect(find.text('Go'), findsOneWidget);
      await tester.tap(find.text('Go'));
      await tester.pumpAndSettle();
      expect(taps, 1);
    });

    testWidgets('ink1: renders label + tap fires callback', (tester) async {
      var taps = 0;
      await _pump(
        tester,
        KaiButton.ink1(onPressed: () => taps++, label: 'Save'),
      );
      expect(find.text('Save'), findsOneWidget);
      await tester.tap(find.text('Save'));
      await tester.pumpAndSettle();
      expect(taps, 1);
    });

    testWidgets('ghost: renders label + tap fires callback', (tester) async {
      var taps = 0;
      await _pump(
        tester,
        KaiButton.ghost(onPressed: () => taps++, label: 'Cancel'),
      );
      expect(find.text('Cancel'), findsOneWidget);
      await tester.tap(find.text('Cancel'));
      await tester.pumpAndSettle();
      expect(taps, 1);
    });

    testWidgets('icon: renders svg + tap fires callback', (tester) async {
      var taps = 0;
      await _pump(
        tester,
        KaiButton.icon(onPressed: () => taps++, icon: KaiIconName.mic),
      );
      expect(find.byType(SvgPicture), findsOneWidget);
      await tester.tap(find.byType(SvgPicture));
      await tester.pumpAndSettle();
      expect(taps, 1);
    });

    testWidgets('disabled (onPressed null) ignores taps', (tester) async {
      await _pump(
        tester,
        const KaiButton.tide(onPressed: null, label: 'Off'),
      );
      // Just make sure no exception even though there's no callback.
      await tester.tap(find.text('Off'));
      await tester.pumpAndSettle();
      // No expectations on counters — just that this didn't throw.
    });

    testWidgets('icon variant supports optional size', (tester) async {
      await _pump(
        tester,
        KaiButton.icon(
          onPressed: () {},
          icon: KaiIconName.plus,
          size: 32,
        ),
      );
      final svg = tester.widget<SvgPicture>(find.byType(SvgPicture));
      expect(svg.width, 32);
      expect(svg.height, 32);
    });

    testWidgets('tide button renders optional icon + label together',
        (tester) async {
      await _pump(
        tester,
        KaiButton.tide(
          onPressed: () {},
          label: 'Send',
          icon: KaiIconName.send,
        ),
      );
      expect(find.text('Send'), findsOneWidget);
      expect(find.byType(SvgPicture), findsOneWidget);
    });
  });

  group('KaiButtonSend', () {
    testWidgets('ready: tap fires callback', (tester) async {
      var taps = 0;
      await _pump(
        tester,
        KaiButtonSend(
          state: KaiSendState.ready,
          onPressed: () => taps++,
        ),
      );
      await tester.tap(find.byType(KaiButtonSend));
      await tester.pumpAndSettle();
      expect(taps, 1);
    });

    testWidgets('disabled: tap ignored', (tester) async {
      var taps = 0;
      await _pump(
        tester,
        KaiButtonSend(
          state: KaiSendState.disabled,
          onPressed: () => taps++,
        ),
      );
      await tester.tap(find.byType(KaiButtonSend));
      await tester.pumpAndSettle();
      expect(taps, 0);
    });

    testWidgets('sending: pulse animation runs', (tester) async {
      await _pump(
        tester,
        KaiButtonSend(
          state: KaiSendState.sending,
          onPressed: () {},
        ),
      );
      // Pulse loops. Confirm by pumping ahead and seeing the build keeps
      // producing frames (animation alive). We sanity check by pumping the
      // 120ms cycle and observing no exception/throw.
      await tester.pump(const Duration(milliseconds: 60));
      await tester.pump(const Duration(milliseconds: 60));
      expect(find.byType(KaiButtonSend), findsOneWidget);
    });

    testWidgets('streaming: tap ignored (only ready taps)', (tester) async {
      var taps = 0;
      await _pump(
        tester,
        KaiButtonSend(
          state: KaiSendState.streaming,
          onPressed: () => taps++,
        ),
      );
      await tester.tap(find.byType(KaiButtonSend));
      await tester.pump(const Duration(milliseconds: 50));
      expect(taps, 0);
      // Pump to drain the running animation so the test tear-down is clean.
      await tester.pump(const Duration(milliseconds: 60));
    });
  });
}
