import 'package:flutter/material.dart';
import 'package:flutter_markdown/flutter_markdown.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:kai_app/design_system/atoms/kai_bubble.dart';
import 'package:kai_app/design_system/molecules/source_card.dart';
import 'package:kai_app/design_system/theme/kai_theme.dart';

Future<void> _pump(WidgetTester tester, Widget child) async {
  await tester.pumpWidget(
    ProviderScope(
      child: MaterialApp(
        home: KaiTheme(
          child: Scaffold(body: child),
        ),
      ),
    ),
  );
  await tester.pump();
}

void main() {
  group('KaiBubble.user', () {
    testWidgets('renders the content', (tester) async {
      await _pump(tester, const KaiBubble.user('hello'));
      expect(find.text('hello'), findsOneWidget);
    });

    testWidgets('is right-aligned', (tester) async {
      await _pump(tester, const KaiBubble.user('align test'));
      final align = tester.widget<Align>(find.byType(Align).first);
      expect(align.alignment, Alignment.centerRight);
    });

    testWidgets('radius is 16-16-4-16 per HTML canon', (tester) async {
      await _pump(tester, const KaiBubble.user('radius test'));
      final containers = tester.widgetList<Container>(find.byType(Container));
      var foundRadius = false;
      for (final c in containers) {
        final deco = c.decoration;
        if (deco is BoxDecoration) {
          final br = deco.borderRadius;
          if (br is BorderRadius) {
            if (br.topLeft == const Radius.circular(16) &&
                br.topRight == const Radius.circular(16) &&
                br.bottomLeft == const Radius.circular(16) &&
                br.bottomRight == const Radius.circular(4)) {
              foundRadius = true;
            }
          }
        }
      }
      expect(foundRadius, isTrue, reason: 'User bubble must have 16-16-4-16 radius');
    });
  });

  group('KaiBubble.system', () {
    testWidgets('renders content centered', (tester) async {
      await _pump(tester, const KaiBubble.system('Kai is waking up'));
      expect(find.text('Kai is waking up'), findsOneWidget);
      expect(find.byType(Center), findsWidgets);
    });
  });

  group('KaiBubble.kai', () {
    testWidgets('renders a MarkdownBody', (tester) async {
      await _pump(
        tester,
        const KaiBubble.kai('**bold** and _italic_'),
      );
      expect(find.byType(MarkdownBody), findsOneWidget);
    });

    testWidgets('parses simple markdown text', (tester) async {
      await _pump(tester, const KaiBubble.kai('hello world'));
      final md = tester.widget<MarkdownBody>(find.byType(MarkdownBody));
      expect(md.data, 'hello world');
    });

    testWidgets('shows .who row with KAI label', (tester) async {
      await _pump(tester, const KaiBubble.kai('some response'));
      expect(find.text('KAI'), findsOneWidget);
    });

    testWidgets('shows TideGlyph in .who row', (tester) async {
      await _pump(tester, const KaiBubble.kai('response'));
      expect(find.byType(TideGlyph), findsOneWidget);
    });

    testWidgets('without sources does not render SourceCard', (tester) async {
      await _pump(tester, const KaiBubble.kai('no sources'));
      expect(find.byType(SourceCard), findsNothing);
    });

    testWidgets('with sources renders SourceCard below content', (tester) async {
      await _pump(
        tester,
        const KaiBubble.kai(
          'answer with source',
          sources: [
            SourceCard(
              url: 'visa.go.jp',
              title: 'Visa fee ¥3,000',
              snippet: 'Official visa page',
              fresh: true,
            ),
          ],
        ),
      );
      expect(find.byType(SourceCard), findsOneWidget);
      expect(find.text('visa.go.jp'), findsOneWidget);
    });

    testWidgets('with multiple sources renders all SourceCards', (tester) async {
      await _pump(
        tester,
        const KaiBubble.kai(
          'answer with multiple sources',
          sources: [
            SourceCard(url: 'source1.com', title: 'Source 1'),
            SourceCard(url: 'source2.com', title: 'Source 2'),
          ],
        ),
      );
      expect(find.byType(SourceCard), findsNWidgets(2));
    });
  });
}
