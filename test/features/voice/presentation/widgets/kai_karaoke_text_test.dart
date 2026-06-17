import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:kai_app/design_system/theme/kai_theme.dart';
import 'package:kai_app/features/voice/presentation/widgets/kai_karaoke_text.dart';

Future<void> _pump(WidgetTester tester, Widget child) async {
  await tester.pumpWidget(
    ProviderScope(
      child: MaterialApp(
        home: KaiTheme(
          child: Scaffold(
            // Voice field background — always dark.
            backgroundColor: const Color(0xFF08080A),
            body: child,
          ),
        ),
      ),
    ),
  );
  await tester.pump();
}

void main() {
  group('v3/KaiKaraokeText', () {
    const words = ['Привет', 'Kai', 'как'];
    // index 0 = spoken, index 1 = now, index 2 = next.
    const currentIndex = 1;

    testWidgets('renders all words as text', (tester) async {
      await _pump(
        tester,
        const KaiKaraokeText(words: words, currentIndex: currentIndex),
      );
      expect(find.text('Привет'), findsOneWidget);
      expect(find.text('Kai'), findsOneWidget);
      expect(find.text('как'), findsOneWidget);
    });

    testWidgets('now-word (currentIndex) has tide-3 highlight background',
        (tester) async {
      await _pump(
        tester,
        const KaiKaraokeText(words: words, currentIndex: currentIndex),
      );
      // The "now" word 'Kai' (index 1) is wrapped in a Container with the
      // amber tide-3 highlight bg Color(0x47F4B589).
      final containers =
          tester.widgetList<Container>(find.byType(Container)).toList();
      final nowContainer = containers.any((c) {
        final deco = c.decoration;
        return deco is BoxDecoration && deco.color == const Color(0x47F4B589);
      });
      expect(
        nowContainer,
        isTrue,
        reason:
            'now-word must have tide-3 highlight bg Color(0x47F4B589)',
      );
    });

    testWidgets('now-word container has 4px corner radius (canon .now)',
        (tester) async {
      await _pump(
        tester,
        const KaiKaraokeText(words: words, currentIndex: currentIndex),
      );
      final containers =
          tester.widgetList<Container>(find.byType(Container)).toList();
      const expectedBr = BorderRadius.all(Radius.circular(4));
      final hasCorrectRadius = containers.any((c) {
        final deco = c.decoration;
        return deco is BoxDecoration &&
            deco.color == const Color(0x47F4B589) &&
            deco.borderRadius == expectedBr;
      });
      expect(hasCorrectRadius, isTrue,
          reason: 'now-word container must use 4px radius (canon .now)',);
    });

    testWidgets('words use canon letter-spacing (-0.01em) and line-height 1.5',
        (tester) async {
      await _pump(
        tester,
        const KaiKaraokeText(words: words, currentIndex: currentIndex),
      );
      for (final t in tester.widgetList<Text>(find.byType(Text))) {
        expect(t.style?.letterSpacing, closeTo(16 * -0.01, 0.001));
        expect(t.style?.height, 1.5);
      }
    });

    testWidgets('next word uses dim white Color(0x52FFFFFF)', (tester) async {
      await _pump(
        tester,
        const KaiKaraokeText(words: words, currentIndex: currentIndex),
      );
      // 'как' is index 2, which is > currentIndex(1) → next → dim white.
      final textWidgets =
          tester.widgetList<Text>(find.byType(Text)).toList();
      final nextText = textWidgets.firstWhere(
        (t) => t.data == 'как',
        orElse: () => throw TestFailure('Expected text "как" not found'),
      );
      expect(
        nextText.style?.color,
        const Color(0x52FFFFFF),
        reason: 'next word must use Color(0x52FFFFFF)',
      );
    });

    testWidgets('spoken word uses full white Color(0xFFFFFFFF)', (tester) async {
      await _pump(
        tester,
        const KaiKaraokeText(words: words, currentIndex: currentIndex),
      );
      // 'Привет' is index 0, which is < currentIndex(1) → spoken → full white.
      final textWidgets =
          tester.widgetList<Text>(find.byType(Text)).toList();
      final spokenText = textWidgets.firstWhere(
        (t) => t.data == 'Привет',
        orElse: () => throw TestFailure('Expected text "Привет" not found'),
      );
      expect(
        spokenText.style?.color,
        const Color(0xFFFFFFFF),
        reason: 'spoken word must use full white Color(0xFFFFFFFF)',
      );
    });

    testWidgets('renders with empty words list without error', (tester) async {
      await _pump(
        tester,
        const KaiKaraokeText(words: [], currentIndex: 0),
      );
      expect(find.byType(KaiKaraokeText), findsOneWidget);
    });

    testWidgets('all words spoken (currentIndex = words.length) — all full white',
        (tester) async {
      await _pump(
        tester,
        const KaiKaraokeText(
          words: ['один', 'два'],
          currentIndex: 2, // past the end
        ),
      );
      final textWidgets =
          tester.widgetList<Text>(find.byType(Text)).toList();
      for (final t in textWidgets) {
        if (t.data == 'один' || t.data == 'два') {
          expect(
            t.style?.color,
            const Color(0xFFFFFFFF),
            reason: 'all spoken words must be full white',
          );
        }
      }
    });
  });
}
