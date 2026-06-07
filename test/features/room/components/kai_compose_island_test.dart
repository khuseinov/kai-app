import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:kai_app/features/room/components/kai_send_button.dart';
import 'package:kai_app/features/room/components/kai_compose_island.dart';
import 'package:kai_app/design_system/primitives/primitives.dart';
import 'package:kai_app/design_system/theme/kai_theme.dart';
import 'package:kai_app/design_system/tokens/kai_tokens.dart';

import '../../../test_helpers.dart';

const _micKey = ValueKey<String>('compose_mic_button');
const _addKey = ValueKey<String>('compose_add_button');
const _voiceKey = ValueKey<String>('compose_voice_button');
const _queueKey = ValueKey<String>('compose_queue_button');

bool _hasIcon(WidgetTester t, KaiIconName name) =>
    t.widgetList<KaiIcon>(find.byType(KaiIcon)).any((i) => i.name == name);

void main() {
  group('v3/KaiComposeIsland', () {
    // ── Variant-1 swap ──────────────────────────────────────────────────────

    testWidgets('empty field shows mic, not send', (tester) async {
      final c = TextEditingController();
      addTearDown(c.dispose);
      await tester.pumpWidget(buildTestWidget(KaiComposeIsland(
        controller: c, onSend: () {}, onMicTap: () {}, onVoiceTap: () {},
      )));
      expect(find.byKey(_micKey), findsOneWidget);
      expect(find.byType(KaiSendButton), findsNothing);
    });

    testWidgets('typing swaps mic → send', (tester) async {
      final c = TextEditingController();
      addTearDown(c.dispose);
      await tester.pumpWidget(buildTestWidget(KaiComposeIsland(
        controller: c, onSend: () {}, onMicTap: () {}, onVoiceTap: () {},
      )));
      await tester.enterText(find.byType(TextField), 'рейс в Токио');
      // Settle the mic→send AnimatedSwitcher (outgoing child removed a frame
      // after the transition completes).
      await tester.pumpAndSettle();
      expect(find.byType(KaiSendButton), findsOneWidget);
      expect(find.byKey(_micKey), findsNothing);
    });

    testWidgets('no mic callback → far-right slot is send (disabled when empty)',
        (tester) async {
      final c = TextEditingController();
      addTearDown(c.dispose);
      await tester.pumpWidget(buildTestWidget(KaiComposeIsland(
        controller: c, onSend: () {},
      )));
      expect(find.byKey(_micKey), findsNothing);
      expect(
        tester.widget<KaiSendButton>(find.byType(KaiSendButton)).state,
        KaiSendState.disabled,
      );
    });

    // ── Composable affordances ────────────────────────────────────────────────

    testWidgets('voice + add hidden when callbacks null', (tester) async {
      final c = TextEditingController();
      addTearDown(c.dispose);
      await tester.pumpWidget(buildTestWidget(KaiComposeIsland(
        controller: c, onSend: () {},
      )));
      expect(find.byKey(_voiceKey), findsNothing);
      expect(find.byKey(_addKey), findsNothing);
      expect(_hasIcon(tester, KaiIconName.waveform), isFalse);
      expect(_hasIcon(tester, KaiIconName.plus), isFalse);
    });

    testWidgets('voice + add shown when callbacks set', (tester) async {
      final c = TextEditingController();
      addTearDown(c.dispose);
      await tester.pumpWidget(buildTestWidget(KaiComposeIsland(
        controller: c, onSend: () {}, onAddTap: () {}, onVoiceTap: () {}, onMicTap: () {},
      )));
      expect(find.byKey(_voiceKey), findsOneWidget);
      expect(find.byKey(_addKey), findsOneWidget);
      expect(_hasIcon(tester, KaiIconName.waveform), isTrue);
    });

    testWidgets('onVoiceTap + onAddTap fire on tap', (tester) async {
      final c = TextEditingController();
      addTearDown(c.dispose);
      var voice = false, add = false;
      await tester.pumpWidget(buildTestWidget(KaiComposeIsland(
        controller: c, onSend: () {},
        onAddTap: () => add = true, onVoiceTap: () => voice = true, onMicTap: () {},
      )));
      await tester.tap(find.byKey(_voiceKey));
      await tester.tap(find.byKey(_addKey));
      expect(voice, isTrue);
      expect(add, isTrue);
    });

    // ── Streaming ──────────────────────────────────────────────────────────────

    testWidgets('streaming collapses to stop, hides field; onStop fires',
        (tester) async {
      final c = TextEditingController(text: 'x');
      addTearDown(c.dispose);
      var stopped = false;
      await tester.pumpWidget(buildTestWidget(KaiComposeIsland(
        controller: c, onSend: () {}, onStop: () => stopped = true,
        sendState: KaiSendState.streaming,
      )));
      expect(find.byType(TextField), findsNothing);
      expect(find.text('Kai отвечает…'), findsOneWidget);
      final stopBtn = find.byType(KaiSendButton);
      expect(stopBtn, findsOneWidget);
      expect(
        tester.widget<KaiSendButton>(stopBtn).state, KaiSendState.streaming);
      await tester.tap(stopBtn);
      expect(stopped, isTrue);
    });

    // ── Offline (O-A) ───────────────────────────────────────────────────────────

    testWidgets('offline empty shows amber hint, no negative/info', (tester) async {
      final c = TextEditingController();
      addTearDown(c.dispose);
      await tester.pumpWidget(buildTestWidget(KaiComposeIsland(
        controller: c, onSend: () {}, offline: true,
      )));
      expect(find.text('оффлайн — отправлю, когда вернётся сеть'), findsOneWidget);
      expect(_hasIcon(tester, KaiIconName.info), isFalse);
      // hint dot uses warning, never negative
      final ctx = tester.element(find.byType(KaiComposeIsland));
      final colors = KaiTheme.of(ctx).colors;
      final dot = tester.widgetList<Container>(find.byType(Container)).firstWhere(
        (w) => (w.decoration is BoxDecoration) &&
            (w.decoration as BoxDecoration).color == colors.warning,
        orElse: () => Container(),
      );
      expect((dot.decoration as BoxDecoration?)?.color, colors.warning);
      expect((dot.decoration as BoxDecoration?)?.color == colors.negative, isFalse);
    });

    testWidgets('offline + text shows queue affordance, fires onQueue',
        (tester) async {
      final c = TextEditingController(text: 'позже');
      addTearDown(c.dispose);
      var queued = false;
      await tester.pumpWidget(buildTestWidget(KaiComposeIsland(
        controller: c, onSend: () {}, offline: true, onQueue: () => queued = true,
      )));
      expect(find.byKey(_queueKey), findsOneWidget);
      expect(_hasIcon(tester, KaiIconName.clock), isTrue);
      await tester.tap(find.byKey(_queueKey));
      expect(queued, isTrue);
    });

    // ── Send behaviour ──────────────────────────────────────────────────────────

    testWidgets('onSend fires when send tapped with text', (tester) async {
      final c = TextEditingController(text: 'test');
      addTearDown(c.dispose);
      var sent = false;
      await tester.pumpWidget(buildTestWidget(KaiComposeIsland(
        controller: c, onSend: () => sent = true,
      )));
      await tester.tap(find.byType(KaiSendButton));
      expect(sent, isTrue);
    });

    testWidgets('onSend does NOT fire when empty (disabled)', (tester) async {
      final c = TextEditingController();
      addTearDown(c.dispose);
      var sent = false;
      await tester.pumpWidget(buildTestWidget(KaiComposeIsland(
        controller: c, onSend: () => sent = true,
      )));
      await tester.tap(find.byType(KaiSendButton), warnIfMissed: false);
      expect(sent, isFalse);
    });

    // ── Structure ────────────────────────────────────────────────────────────────

    testWidgets('outer container uses pill radius', (tester) async {
      final c = TextEditingController();
      addTearDown(c.dispose);
      await tester.pumpWidget(buildTestWidget(KaiComposeIsland(
        controller: c, onSend: () {},
      )));
      final hasPill = tester.widgetList<Container>(find.byType(Container)).any((w) {
        final d = w.decoration;
        return d is BoxDecoration &&
            d.borderRadius is BorderRadius &&
            (d.borderRadius as BorderRadius).topLeft ==
                const Radius.circular(KaiRadius.pill);
      });
      expect(hasPill, isTrue);
    });

    testWidgets('shows placeholder when empty', (tester) async {
      final c = TextEditingController();
      addTearDown(c.dispose);
      await tester.pumpWidget(buildTestWidget(KaiComposeIsland(
        controller: c, onSend: () {}, placeholder: 'Type here…',
      )));
      expect(find.text('Type here…'), findsOneWidget);
    });

    testWidgets('dictating state shows listening text and toggled mic button', (tester) async {
      final c = TextEditingController();
      addTearDown(c.dispose);
      await tester.pumpWidget(buildTestWidget(KaiComposeIsland(
        controller: c, onSend: () {}, onMicTap: () {}, dictating: true,
      )));
      expect(find.text('Слушаю вас...'), findsOneWidget);
      expect(find.byType(TextField), findsNothing);
      expect(find.byKey(_micKey), findsOneWidget);
    });
  });
}
