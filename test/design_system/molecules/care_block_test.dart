import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:kai_app/core/providers/root.dart';
import 'package:kai_app/design_system/molecules/care_block.dart';
import 'package:kai_app/design_system/theme/kai_theme.dart';
import 'package:kai_app/design_system/tokens/kai_tokens.dart';

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
          child: Scaffold(body: child),
        ),
      ),
    ),
  );
  await tester.pump();
}

void main() {
  group('CareBlock', () {
    testWidgets('renders heading, heart icon and body',
        (WidgetTester tester) async {
      await _pump(
        tester,
        const CareBlock(
          heading: 'Я слышу тебя.',
          body: 'Звучит тяжело. Я рядом.',
        ),
      );
      expect(find.text('Я слышу тебя.'), findsOneWidget);
      expect(find.text('Звучит тяжело. Я рядом.'), findsOneWidget);
      // Heart icon SVG is rendered.
      expect(find.byType(SvgPicture), findsOneWidget);
    });

    testWidgets('renders all resources in mono', (WidgetTester tester) async {
      await _pump(
        tester,
        const CareBlock(
          heading: 'Здесь поможем',
          body: 'Линии помощи доступны круглосуточно.',
          resources: [
            CareResource(label: 'Lifeline', number: '988'),
            CareResource(label: 'Crisis Text Line', number: '741741'),
          ],
        ),
      );
      expect(find.text('988'), findsOneWidget);
      expect(find.text('741741'), findsOneWidget);
      expect(find.text('· Lifeline'), findsOneWidget);
      expect(find.text('· Crisis Text Line'), findsOneWidget);

      // Each number is rendered in JetBrainsMono.
      final mono = tester.widget<Text>(find.text('988'));
      expect(mono.style?.fontFamily, 'JetBrainsMono');
    });

    testWidgets('border colour is the negative token (coral, not red)',
        (WidgetTester tester) async {
      await _pump(
        tester,
        const CareBlock(
          heading: 'Поддержка рядом',
          body: 'Body',
        ),
      );

      final decorated = tester.widgetList<DecoratedBox>(
        find.descendant(
          of: find.byType(CareBlock),
          matching: find.byType(DecoratedBox),
        ),
      );

      final matched = decorated.any((d) {
        final dec = d.decoration;
        if (dec is! BoxDecoration) return false;
        final border = dec.border;
        if (border is! Border) return false;
        return border.left.color == KaiTokens.light.colors.negative &&
            border.left.width == 2;
      });
      expect(matched, isTrue,
          reason: 'CareBlock must have a 2px left border in the negative '
              '(coral) token, never bright red.');
    });

    testWidgets('closing italic line renders when provided',
        (WidgetTester tester) async {
      await _pump(
        tester,
        const CareBlock(
          heading: 'h',
          body: 'b',
          closing: 'Без давления.',
        ),
      );
      final closing = tester.widget<Text>(find.text('Без давления.'));
      expect(closing.style?.fontStyle, FontStyle.italic);
    });
  });
}
