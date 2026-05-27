import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:kai_app/core/providers/root.dart';
import 'package:kai_app/design_system/atoms/kai_button_send.dart';
import 'package:kai_app/design_system/molecules/compose_island.dart';
import 'package:kai_app/design_system/theme/kai_theme.dart';

Future<void> _pump(
  WidgetTester tester,
  Widget child, {
  ThemeMode mode = ThemeMode.light,
}) async {
  await tester.pumpWidget(
    ProviderScope(
      overrides: <Override>[
        themeModeProvider.overrideWith((ref) => mode),
      ],
      child: MaterialApp(
        home: KaiTheme(
          child: Scaffold(
            body: Padding(
              padding: const EdgeInsets.all(16),
              child: child,
            ),
          ),
        ),
      ),
    ),
  );
  await tester.pump();
}

void main() {
  group('ComposeIsland', () {
    testWidgets('empty controller -> send disabled (no callback)',
        (WidgetTester tester) async {
      final controller = TextEditingController();
      var sends = 0;
      await _pump(
        tester,
        ComposeIsland(
          controller: controller,
          onSend: () => sends++,
        ),
      );

      final send = tester.widget<KaiButtonSend>(find.byType(KaiButtonSend));
      expect(send.state, KaiSendState.disabled);

      await tester.tap(find.byType(KaiButtonSend));
      await tester.pumpAndSettle();
      expect(sends, 0);
    });

    testWidgets('non-empty controller -> send ready and tap fires',
        (WidgetTester tester) async {
      final controller = TextEditingController(text: 'hello');
      var sends = 0;
      await _pump(
        tester,
        ComposeIsland(
          controller: controller,
          onSend: () => sends++,
        ),
      );

      final send = tester.widget<KaiButtonSend>(find.byType(KaiButtonSend));
      expect(send.state, KaiSendState.ready);

      await tester.tap(find.byType(KaiButtonSend));
      await tester.pumpAndSettle();
      expect(sends, 1);
    });

    testWidgets('recording state renders mic with active key',
        (WidgetTester tester) async {
      final controller = TextEditingController();
      await _pump(
        tester,
        ComposeIsland(
          controller: controller,
          onSend: () {},
          onMicToggle: () {},
          state: ComposeState.recording,
        ),
      );
      expect(find.byKey(const ValueKey<String>('compose_mic_button')),
          findsOneWidget);
      // Pump the pulse animation a bit so tear-down is clean.
      await tester.pump(const Duration(milliseconds: 60));
    });

    testWidgets('showMic=false hides mic button',
        (WidgetTester tester) async {
      final controller = TextEditingController();
      await _pump(
        tester,
        ComposeIsland(
          controller: controller,
          onSend: () {},
          onMicToggle: () {},
          showMic: false,
        ),
      );
      expect(find.byKey(const ValueKey<String>('compose_mic_button')),
          findsNothing);
    });

    testWidgets('placeholder rendered when controller empty',
        (WidgetTester tester) async {
      final controller = TextEditingController();
      await _pump(
        tester,
        ComposeIsland(
          controller: controller,
          onSend: () {},
          placeholder: 'Скажи Kai…',
        ),
      );
      expect(find.text('Скажи Kai…'), findsOneWidget);
    });

    testWidgets('sending state propagates to send button',
        (WidgetTester tester) async {
      final controller = TextEditingController(text: 'hi');
      await _pump(
        tester,
        ComposeIsland(
          controller: controller,
          onSend: () {},
          state: ComposeState.sending,
        ),
      );
      final send = tester.widget<KaiButtonSend>(find.byType(KaiButtonSend));
      expect(send.state, KaiSendState.sending);
      // Drain pulse animation.
      await tester.pump(const Duration(milliseconds: 60));
      await tester.pump(const Duration(milliseconds: 60));
    });

    testWidgets('pill variant: send button size = 30', (WidgetTester tester) async {
      final controller = TextEditingController();
      await _pump(
        tester,
        ComposeIsland(
          controller: controller,
          onSend: () {},
          variant: ComposeIslandVariant.pill,
        ),
      );
      final send = tester.widget<KaiButtonSend>(find.byType(KaiButtonSend));
      expect(send.size, 30);
      expect(send.iconSize, 12);
    });

    testWidgets('sheet variant: send button size = 32', (WidgetTester tester) async {
      final controller = TextEditingController();
      await _pump(
        tester,
        ComposeIsland(
          controller: controller,
          onSend: () {},
          variant: ComposeIslandVariant.sheet,
        ),
      );
      final send = tester.widget<KaiButtonSend>(find.byType(KaiButtonSend));
      expect(send.size, 32);
      expect(send.iconSize, 16);
    });

    testWidgets('pill is the default variant (buttonSize=30)',
        (WidgetTester tester) async {
      final controller = TextEditingController();
      await _pump(
        tester,
        ComposeIsland(controller: controller, onSend: () {}),
      );
      // Default variant = pill → send.size = 30.
      final send = tester.widget<KaiButtonSend>(find.byType(KaiButtonSend));
      expect(send.size, 30);
    });
  });
}
