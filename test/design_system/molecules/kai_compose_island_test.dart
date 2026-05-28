import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:kai_app/design_system/tokens/kai_tokens.dart';
import 'package:kai_app/design_system/atoms/kai_send_button.dart';
import 'package:kai_app/design_system/molecules/kai_compose_island.dart';

import '../../test_helpers.dart';

void main() {
  group('v3/KaiComposeIsland', () {
    // -----------------------------------------------------------------------
    // Renders child atoms
    // -----------------------------------------------------------------------

    testWidgets('renders a TextField', (tester) async {
      final controller = TextEditingController();
      addTearDown(controller.dispose);

      await tester.pumpWidget(
        buildTestWidget(
          KaiComposeIsland(
            controller: controller,
            onSend: () {},
          ),
        ),
      );
      await tester.pump();

      expect(find.byType(TextField), findsOneWidget);
    });

    testWidgets('renders KaiSendButton', (tester) async {
      final controller = TextEditingController();
      addTearDown(controller.dispose);

      await tester.pumpWidget(
        buildTestWidget(
          KaiComposeIsland(
            controller: controller,
            onSend: () {},
          ),
        ),
      );
      await tester.pump();

      expect(find.byType(KaiSendButton), findsOneWidget);
    });

    testWidgets('renders KaiIconButton mic when onMicTap provided',
        (tester) async {
      final controller = TextEditingController();
      addTearDown(controller.dispose);

      await tester.pumpWidget(
        buildTestWidget(
          KaiComposeIsland(
            controller: controller,
            onSend: () {},
            onMicTap: () {},
          ),
        ),
      );
      await tester.pump();

      expect(
        find.byKey(const ValueKey<String>('compose_mic_button')),
        findsOneWidget,
      );
    });

    testWidgets('omits mic button when onMicTap is null', (tester) async {
      final controller = TextEditingController();
      addTearDown(controller.dispose);

      await tester.pumpWidget(
        buildTestWidget(
          KaiComposeIsland(
            controller: controller,
            onSend: () {},
            // onMicTap intentionally not provided
          ),
        ),
      );
      await tester.pump();

      expect(
        find.byKey(const ValueKey<String>('compose_mic_button')),
        findsNothing,
      );
    });

    // -----------------------------------------------------------------------
    // Send state derivation
    // -----------------------------------------------------------------------

    testWidgets('send button is disabled when controller is empty',
        (tester) async {
      final controller = TextEditingController();
      addTearDown(controller.dispose);

      await tester.pumpWidget(
        buildTestWidget(
          KaiComposeIsland(
            controller: controller,
            onSend: () {},
          ),
        ),
      );
      await tester.pump();

      final sendBtn = tester.widget<KaiSendButton>(find.byType(KaiSendButton));
      expect(sendBtn.state, KaiSendState.disabled);
    });

    testWidgets('send button is ready when controller has text', (tester) async {
      final controller = TextEditingController(text: 'hello');
      addTearDown(controller.dispose);

      await tester.pumpWidget(
        buildTestWidget(
          KaiComposeIsland(
            controller: controller,
            onSend: () {},
          ),
        ),
      );
      await tester.pump();

      final sendBtn = tester.widget<KaiSendButton>(find.byType(KaiSendButton));
      expect(sendBtn.state, KaiSendState.ready);
    });

    testWidgets(
        'send button transitions from disabled to ready when text is entered',
        (tester) async {
      final controller = TextEditingController();
      addTearDown(controller.dispose);

      await tester.pumpWidget(
        buildTestWidget(
          KaiComposeIsland(
            controller: controller,
            onSend: () {},
          ),
        ),
      );
      await tester.pump();

      // Initially disabled.
      expect(
        tester.widget<KaiSendButton>(find.byType(KaiSendButton)).state,
        KaiSendState.disabled,
      );

      // Enter text.
      await tester.enterText(find.byType(TextField), 'Hey Kai');
      await tester.pump();

      expect(
        tester.widget<KaiSendButton>(find.byType(KaiSendButton)).state,
        KaiSendState.ready,
      );
    });

    testWidgets('explicit sending state is forwarded unchanged', (tester) async {
      final controller = TextEditingController();
      addTearDown(controller.dispose);

      await tester.pumpWidget(
        buildTestWidget(
          KaiComposeIsland(
            controller: controller,
            onSend: () {},
            sendState: KaiSendState.sending,
          ),
        ),
      );
      await tester.pump();

      final sendBtn = tester.widget<KaiSendButton>(find.byType(KaiSendButton));
      expect(sendBtn.state, KaiSendState.sending);
    });

    testWidgets('explicit streaming state is forwarded unchanged',
        (tester) async {
      final controller = TextEditingController();
      addTearDown(controller.dispose);

      await tester.pumpWidget(
        buildTestWidget(
          KaiComposeIsland(
            controller: controller,
            onSend: () {},
            sendState: KaiSendState.streaming,
          ),
        ),
      );
      await tester.pump();

      final sendBtn = tester.widget<KaiSendButton>(find.byType(KaiSendButton));
      expect(sendBtn.state, KaiSendState.streaming);
    });

    // -----------------------------------------------------------------------
    // Callbacks
    // -----------------------------------------------------------------------

    testWidgets('onSend fires when send button tapped in ready state',
        (tester) async {
      var called = false;
      final controller = TextEditingController(text: 'test');
      addTearDown(controller.dispose);

      await tester.pumpWidget(
        buildTestWidget(
          KaiComposeIsland(
            controller: controller,
            onSend: () => called = true,
          ),
        ),
      );
      await tester.pump();

      await tester.tap(find.byType(KaiSendButton));
      await tester.pump();

      expect(called, isTrue);
    });

    testWidgets('onSend does NOT fire when send button tapped in disabled state',
        (tester) async {
      var called = false;
      final controller = TextEditingController(); // empty → disabled
      addTearDown(controller.dispose);

      await tester.pumpWidget(
        buildTestWidget(
          KaiComposeIsland(
            controller: controller,
            onSend: () => called = true,
          ),
        ),
      );
      await tester.pump();

      await tester.tap(find.byType(KaiSendButton));
      await tester.pump();

      expect(called, isFalse);
    });

    testWidgets('onMicTap fires when mic button tapped', (tester) async {
      var micCalled = false;
      final controller = TextEditingController();
      addTearDown(controller.dispose);

      await tester.pumpWidget(
        buildTestWidget(
          KaiComposeIsland(
            controller: controller,
            onSend: () {},
            onMicTap: () => micCalled = true,
          ),
        ),
      );
      await tester.pump();

      await tester.tap(
        find.byKey(const ValueKey<String>('compose_mic_button')),
      );
      await tester.pump();

      expect(micCalled, isTrue);
    });

    // -----------------------------------------------------------------------
    // Visual structure
    // -----------------------------------------------------------------------

    testWidgets('outer container has pill border radius', (tester) async {
      final controller = TextEditingController();
      addTearDown(controller.dispose);

      await tester.pumpWidget(
        buildTestWidget(
          KaiComposeIsland(
            controller: controller,
            onSend: () {},
          ),
        ),
      );
      await tester.pump();

      final containers = tester
          .widgetList<Container>(find.byType(Container))
          .toList();
      final hasPill = containers.any((c) {
        final deco = c.decoration;
        if (deco is! BoxDecoration) return false;
        final br = deco.borderRadius;
        if (br is! BorderRadius) return false;
        return br.topLeft == const Radius.circular(KaiRadius.pill);
      });
      expect(hasPill, isTrue,
          reason: 'outer pill must use KaiRadius.brPill (r=999)');
    });

    testWidgets('shows placeholder text when empty', (tester) async {
      final controller = TextEditingController();
      addTearDown(controller.dispose);

      await tester.pumpWidget(
        buildTestWidget(
          KaiComposeIsland(
            controller: controller,
            onSend: () {},
            placeholder: 'Type here…',
          ),
        ),
      );
      await tester.pump();

      // The placeholder is rendered as hintText inside the TextField.
      expect(find.text('Type here…'), findsOneWidget);
    });
  });
}
