import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:kai_app/core/providers/root.dart';
import 'package:kai_app/design_system/molecules/source_card.dart';
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
            body: SizedBox(width: 320, child: child),
          ),
        ),
      ),
    ),
  );
  await tester.pump();
}

void main() {
  group('SourceCard', () {
    testWidgets('renders url and title', (WidgetTester tester) async {
      await _pump(
        tester,
        const SourceCard(
          url: 'visa.gov',
          title: 'Visa information',
        ),
      );
      expect(find.text('visa.gov'), findsOneWidget);
      expect(find.text('Visa information'), findsOneWidget);
    });

    testWidgets('fresh flag shows ok badge', (WidgetTester tester) async {
      await _pump(
        tester,
        const SourceCard(
          url: 'visa.gov',
          title: 'Official visa page',
          fresh: true,
        ),
      );
      expect(find.text('✓ fresh'), findsOneWidget);
    });

    testWidgets('no fresh flag omits ok badge', (WidgetTester tester) async {
      await _pump(
        tester,
        const SourceCard(
          url: 'visa.gov',
          title: 'Official visa page',
        ),
      );
      expect(find.text('✓ fresh'), findsNothing);
    });

    testWidgets('renders snippet when provided', (WidgetTester tester) async {
      await _pump(
        tester,
        const SourceCard(
          url: 'visa.gov',
          title: 'Visa fee',
          snippet: 'Fee is ¥3,000 · 4 days',
        ),
      );
      expect(find.text('Fee is ¥3,000 · 4 days'), findsOneWidget);
    });

    testWidgets('omits snippet row when null', (WidgetTester tester) async {
      await _pump(
        tester,
        const SourceCard(
          url: 'visa.gov',
          title: 'Visa fee',
        ),
      );
      // No snippet text
      expect(find.text('Fee is ¥3,000 · 4 days'), findsNothing);
    });

    testWidgets('renders expand hint when provided', (WidgetTester tester) async {
      await _pump(
        tester,
        const SourceCard(
          url: 'visa.gov',
          title: 'Visa page',
          expandHint: 'tap to expand',
        ),
      );
      expect(find.text('TAP TO EXPAND'), findsOneWidget);
    });

    testWidgets('long url truncates with ellipsis', (WidgetTester tester) async {
      const longUrl = 'a-very-long-domain.example/path/to/resource/that/'
          'cannot-possibly-fit-on-one-line.html';
      await _pump(
        tester,
        const SourceCard(url: longUrl, title: 'Long url test'),
      );
      final textFinder = find.text(longUrl);
      expect(textFinder, findsOneWidget);
      final text = tester.widget<Text>(textFinder);
      expect(text.overflow, TextOverflow.ellipsis);
      expect(text.maxLines, 1);
    });
  });
}
