import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:kai_app/design_system/primitives/kai_gradient_bar.dart';
import 'package:kai_app/design_system/theme/kai_theme.dart';
import 'package:kai_app/design_system/tokens/kai_tokens.dart';
import 'package:kai_app/features/voice/presentation/widgets/kai_transcript_view.dart';

Future<void> _pump(WidgetTester tester, Widget child) async {
  await tester.pumpWidget(
    ProviderScope(
      child: MaterialApp(
        themeMode: ThemeMode.dark,
        darkTheme: ThemeData.dark(),
        home: MediaQuery(
          data: const MediaQueryData(
            platformBrightness: Brightness.dark,
            size: Size(360, 640),
          ),
          child: KaiTheme(
            child: Scaffold(
              backgroundColor: const Color(0xFF08080A),
              body: SingleChildScrollView(child: child),
            ),
          ),
        ),
      ),
    ),
  );
  await tester.pump();
}

Iterable<Container> _gradientDots(WidgetTester tester) =>
    tester.widgetList<Container>(find.byType(Container)).where((c) {
      final d = c.decoration;
      return d is BoxDecoration && d.gradient == KaiTide.gradientCorner;
    });

void main() {
  const youEvent = KaiTranscriptEvent(
    who: 'you',
    text: 'Найди мне рейс в Токио',
    timestamp: '9:41',
  );
  const kaiEvent = KaiTranscriptEvent(
    who: 'kai',
    text: 'Ищу подходящие варианты…',
    timestamp: '9:42',
  );

  group('v3/KaiTranscriptView', () {
    testWidgets('renders both event texts', (tester) async {
      await _pump(tester, const KaiTranscriptView(events: [youEvent, kaiEvent]));
      expect(find.text('Найди мне рейс в Токио'), findsOneWidget);
      expect(find.text('Ищу подходящие варианты…'), findsOneWidget);
    });

    testWidgets('renders who labels uppercased', (tester) async {
      await _pump(tester, const KaiTranscriptView(events: [youEvent, kaiEvent]));
      expect(find.text('YOU'), findsOneWidget);
      expect(find.text('KAI'), findsOneWidget);
    });

    testWidgets('renders timestamps', (tester) async {
      await _pump(tester, const KaiTranscriptView(events: [youEvent, kaiEvent]));
      expect(find.text('9:41'), findsOneWidget);
      expect(find.text('9:42'), findsOneWidget);
    });

    // ── No invented gradient bar; Kai is marked by a tide-gradient rail dot ──

    testWidgets('no KaiGradientBar anywhere (canon uses rail dots)',
        (tester) async {
      await _pump(tester, const KaiTranscriptView(events: [youEvent, kaiEvent]));
      expect(find.byType(KaiGradientBar), findsNothing);
    });

    testWidgets('kai event has a tide-gradient rail dot', (tester) async {
      await _pump(tester, const KaiTranscriptView(events: [kaiEvent]));
      expect(_gradientDots(tester).length, 1);
    });

    testWidgets('you event has no tide-gradient dot', (tester) async {
      await _pump(tester, const KaiTranscriptView(events: [youEvent]));
      expect(_gradientDots(tester).length, 0);
    });

    testWidgets('mixed: one tide dot per kai event', (tester) async {
      await _pump(tester, const KaiTranscriptView(
        events: [youEvent, kaiEvent, youEvent, kaiEvent],),);
      expect(_gradientDots(tester).length, 2);
    });

    // ── Typography / colours ───────────────────────────────────────────────

    testWidgets('event padding left offset is 52px', (tester) async {
      await _pump(tester, const KaiTranscriptView(events: [youEvent]));
      final hit = tester.widgetList<Padding>(find.byType(Padding)).any(
            (p) => p.padding == const EdgeInsets.fromLTRB(52, 9, 22, 9),
          );
      expect(hit, isTrue);
    });

    testWidgets('timestamp is JetBrains Mono uppercase, white@0.4',
        (tester) async {
      await _pump(tester, const KaiTranscriptView(events: [youEvent]));
      final ts = tester.widget<Text>(find.text('9:41'));
      expect(ts.style?.fontFamily, 'JetBrainsMono');
      expect(ts.style?.fontSize, 8.5);
      expect(ts.style?.color, const Color(0x66FFFFFF));
    });

    testWidgets('you body = white@0.6, kai body = full white', (tester) async {
      await _pump(tester, const KaiTranscriptView(events: [youEvent, kaiEvent]));
      final youBody = tester.widget<Text>(find.text('Найди мне рейс в Токио'));
      final kaiBody = tester.widget<Text>(find.text('Ищу подходящие варианты…'));
      expect(youBody.style?.color, const Color(0x99FFFFFF));
      expect(kaiBody.style?.color, const Color(0xFFFFFFFF));
      expect(youBody.style?.fontSize, 12);
    });

    testWidgets('renders empty events list without error', (tester) async {
      await _pump(tester, const KaiTranscriptView(events: []));
      expect(find.byType(KaiTranscriptView), findsOneWidget);
    });
  });
}
