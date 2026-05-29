import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:kai_app/design_system/molecules/kai_transcript_view.dart';
import 'package:kai_app/design_system/primitives/kai_gradient_bar.dart';
import 'package:kai_app/design_system/theme/kai_theme.dart';

Future<void> _pump(WidgetTester tester, Widget child) async {
  await tester.pumpWidget(
    ProviderScope(
      child: MaterialApp(
        home: KaiTheme(
          child: Scaffold(
            backgroundColor: const Color(0xFF08080A),
            body: SingleChildScrollView(child: child),
          ),
        ),
      ),
    ),
  );
  await tester.pump();
}

void main() {
  const youEvent = KaiTranscriptEvent(
    who: 'you',
    text: 'Найди мне рейс в Токио',
    timestamp: '9:41',
  );
  const kaiEvent = KaiTranscriptEvent(
    who: 'kai',
    text: 'Ищу подходящие варианты…',
    timestamp: '9:41',
  );

  group('v3/KaiTranscriptView', () {
    testWidgets('renders both event texts', (tester) async {
      await _pump(
        tester,
        const KaiTranscriptView(events: [youEvent, kaiEvent]),
      );
      expect(find.text('Найди мне рейс в Токио'), findsOneWidget);
      expect(find.text('Ищу подходящие варианты…'), findsOneWidget);
    });

    testWidgets('renders both timestamps', (tester) async {
      await _pump(
        tester,
        const KaiTranscriptView(events: [youEvent, kaiEvent]),
      );
      // Both events share timestamp '9:41'.
      expect(find.text('9:41'), findsNWidgets(2));
    });

    testWidgets('kai event shows KaiGradientBar (who-glyph)', (tester) async {
      await _pump(
        tester,
        const KaiTranscriptView(events: [kaiEvent]),
      );
      expect(find.byType(KaiGradientBar), findsOneWidget);
    });

    testWidgets('you event does NOT show KaiGradientBar', (tester) async {
      await _pump(
        tester,
        const KaiTranscriptView(events: [youEvent]),
      );
      expect(find.byType(KaiGradientBar), findsNothing);
    });

    testWidgets('mixed events: only kai events have KaiGradientBar',
        (tester) async {
      const events = [youEvent, kaiEvent, youEvent, kaiEvent];
      await _pump(
        tester,
        const KaiTranscriptView(events: events),
      );
      // Two kai events → two gradient bars.
      expect(find.byType(KaiGradientBar), findsNWidgets(2));
    });

    testWidgets('event padding has correct left offset (52px)', (tester) async {
      await _pump(
        tester,
        const KaiTranscriptView(events: [youEvent]),
      );
      final padding = tester
          .widgetList<Padding>(find.byType(Padding))
          .firstWhere(
            (p) => p.padding == const EdgeInsets.fromLTRB(52, 9, 22, 9),
            orElse: () => throw TestFailure(
                'Expected Padding with EdgeInsets.fromLTRB(52,9,22,9)'),
          );
      expect(padding, isNotNull);
    });

    testWidgets('renders empty events list without error', (tester) async {
      await _pump(
        tester,
        const KaiTranscriptView(events: []),
      );
      expect(find.byType(KaiTranscriptView), findsOneWidget);
    });

    testWidgets('body text uses full white Color(0xFFFFFFFF)', (tester) async {
      await _pump(
        tester,
        const KaiTranscriptView(events: [youEvent]),
      );
      final texts =
          tester.widgetList<Text>(find.byType(Text)).toList();
      final bodyText = texts.firstWhere(
        (t) => t.data == 'Найди мне рейс в Токио',
        orElse: () => throw TestFailure('body text widget not found'),
      );
      expect(bodyText.style?.color, const Color(0xFFFFFFFF));
    });

    testWidgets('timestamp uses dim white Color(0x66FFFFFF)', (tester) async {
      await _pump(
        tester,
        const KaiTranscriptView(events: [youEvent]),
      );
      final texts =
          tester.widgetList<Text>(find.byType(Text)).toList();
      final tsText = texts.firstWhere(
        (t) => t.data == '9:41',
        orElse: () => throw TestFailure('timestamp text widget not found'),
      );
      expect(tsText.style?.color, const Color(0x66FFFFFF));
    });
  });
}
