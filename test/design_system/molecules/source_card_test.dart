import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_svg/flutter_svg.dart';
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
    testWidgets('renders index, url and timestamp',
        (WidgetTester tester) async {
      await _pump(
        tester,
        const SourceCard(
          index: 1,
          url: 'visa.gov',
          timestamp: '12:34',
        ),
      );
      expect(find.text('[1]'), findsOneWidget);
      expect(find.text('visa.gov'), findsOneWidget);
      expect(find.text('12:34'), findsOneWidget);
    });

    testWidgets('stale freshness shows alert icon',
        (WidgetTester tester) async {
      await _pump(
        tester,
        const SourceCard(
          index: 2,
          url: 'timatic.iata.org',
          freshness: SourceFreshness.stale,
        ),
      );
      expect(find.byType(SvgPicture), findsOneWidget);
    });

    testWidgets('fresh freshness omits alert icon',
        (WidgetTester tester) async {
      await _pump(
        tester,
        const SourceCard(
          index: 3,
          url: 'embassy.jp',
        ),
      );
      expect(find.byType(SvgPicture), findsNothing);
    });

    testWidgets('long url truncates with ellipsis',
        (WidgetTester tester) async {
      const longUrl = 'a-very-long-domain.example/path/to/resource/that/'
          'cannot-possibly-fit-on-one-line.html';
      await _pump(
        tester,
        const SourceCard(index: 4, url: longUrl),
      );
      final textFinder = find.text(longUrl);
      expect(textFinder, findsOneWidget);
      final text = tester.widget<Text>(textFinder);
      expect(text.overflow, TextOverflow.ellipsis);
      expect(text.maxLines, 1);
    });
  });
}
