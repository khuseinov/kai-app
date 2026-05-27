import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:kai_app/core/providers/root.dart';
import 'package:kai_app/design_system/molecules/kai_system_note.dart';
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

BoxDecoration _outerDecoration(WidgetTester tester) {
  final container = tester.widget<Container>(
    find
        .descendant(
          of: find.byType(KaiSystemNote),
          matching: find.byType(Container),
        )
        .first,
  );
  return container.decoration! as BoxDecoration;
}

void main() {
  group('KaiSystemNote', () {
    testWidgets('neutral uses surface-2 bg and ink-2 text', (tester) async {
      await _pump(
        tester,
        const KaiSystemNote(message: 'Источники обновлены.'),
      );
      final dec = _outerDecoration(tester);
      expect(dec.color, KaiTokens.light.colors.surface2);
      expect(find.text('Источники обновлены.'), findsOneWidget);
    });

    testWidgets('warning uses warningWash bg', (tester) async {
      await _pump(
        tester,
        const KaiSystemNote(
          type: SystemNoteType.warning,
          message: 'Сайт устарел.',
        ),
      );
      final dec = _outerDecoration(tester);
      expect(dec.color, KaiTokens.light.colors.warningWash);
    });

    testWidgets('negative uses negativeWash bg', (tester) async {
      await _pump(
        tester,
        const KaiSystemNote(
          type: SystemNoteType.negative,
          message: 'Не отправлено.',
        ),
      );
      final dec = _outerDecoration(tester);
      expect(dec.color, KaiTokens.light.colors.negativeWash);
    });

    testWidgets('bold prefix renders alongside regular body', (tester) async {
      await _pump(
        tester,
        const KaiSystemNote(
          type: SystemNoteType.warning,
          bold: 'Внимание —',
          message: ' сайт посольства не обновлялся 6 месяцев.',
        ),
      );

      // Find the RichText whose combined text covers both segments — this
      // confirms the two spans render together inline.
      final richTexts = tester
          .widgetList<RichText>(find.byType(RichText))
          .where(
            (r) {
              final plain = r.text.toPlainText();
              return plain.contains('Внимание —') &&
                  plain.contains('посольства');
            },
          );
      expect(richTexts, hasLength(1));

      // Walk all descendant TextSpans and assert the bold prefix carries w600.
      final root = richTexts.first.text;
      var boldFound = false;
      root.visitChildren((span) {
        if (span is TextSpan && span.text == 'Внимание —') {
          expect(span.style?.fontWeight, FontWeight.w600);
          boldFound = true;
        }
        return true;
      });
      expect(boldFound, isTrue, reason: 'bold prefix TextSpan must exist');
    });

    testWidgets('stretches to full width (no constraints)', (tester) async {
      await _pump(
        tester,
        const SizedBox(
          width: 400,
          child: KaiSystemNote(message: 'A note.'),
        ),
      );
      final container = tester.widget<Container>(
        find
            .descendant(
              of: find.byType(KaiSystemNote),
              matching: find.byType(Container),
            )
            .first,
      );
      expect(container.constraints?.maxWidth, double.infinity);
    });

    testWidgets('uses 12px radius', (tester) async {
      await _pump(
        tester,
        const KaiSystemNote(message: 'x'),
      );
      final dec = _outerDecoration(tester);
      final radius = dec.borderRadius! as BorderRadius;
      expect(radius.topLeft, const Radius.circular(12));
    });

    testWidgets('dark theme uses dark surface2', (tester) async {
      await _pump(
        tester,
        const KaiSystemNote(message: 'x'),
        mode: ThemeMode.dark,
      );
      final dec = _outerDecoration(tester);
      expect(dec.color, KaiTokens.dark.colors.surface2);
    });
  });
}
