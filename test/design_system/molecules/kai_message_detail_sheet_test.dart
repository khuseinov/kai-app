import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:kai_app/core/providers/root.dart';
import 'package:kai_app/design_system/atoms/kai_icon.dart';
import 'package:kai_app/design_system/molecules/kai_message_detail_sheet.dart';
import 'package:kai_app/design_system/theme/kai_theme.dart';

Future<void> _pump(WidgetTester tester, Widget child) async {
  await tester.pumpWidget(
    ProviderScope(
      overrides: <Override>[
        themeModeProvider.overrideWith((ref) => ThemeMode.light),
      ],
      child: MaterialApp(
        home: KaiTheme(
          child: Scaffold(
            body: Align(alignment: Alignment.bottomCenter, child: child),
          ),
        ),
      ),
    ),
  );
  await tester.pump();
}

void main() {
  group('KaiMessageDetailSheet', () {
    testWidgets('renders sources and actions', (tester) async {
      await _pump(
        tester,
        KaiMessageDetailSheet(
          sources: const [
            MessageDetailSource(
              number: 1,
              url: 'visa.gov',
              freshness: SourceFreshness.fresh,
            ),
            MessageDetailSource(
              number: 2,
              url: 'timatic.iata.org',
              freshness: SourceFreshness.stale,
              freshnessLabel: '5d',
            ),
          ],
          actions: [
            DetailAction(
              icon: KaiIconName.send,
              label: 'Поделиться',
              style: DetailActionStyle.primary,
              onTap: () {},
            ),
            DetailAction(
              icon: KaiIconName.copy,
              label: 'Копировать',
              onTap: () {},
            ),
            DetailAction(
              icon: KaiIconName.retry,
              label: 'Переспросить',
              onTap: () {},
            ),
          ],
        ),
      );
      expect(find.text('visa.gov'), findsOneWidget);
      expect(find.text('timatic.iata.org'), findsOneWidget);
      expect(find.text('Поделиться'), findsOneWidget);
      expect(find.text('Копировать'), findsOneWidget);
      expect(find.text('Переспросить'), findsOneWidget);
      // Section labels uppercased
      expect(find.text('ИСТОЧНИКИ'), findsOneWidget);
      expect(find.text('ДЕЙСТВИЯ'), findsOneWidget);
    });

    testWidgets('source numbers render in chips', (tester) async {
      await _pump(
        tester,
        const KaiMessageDetailSheet(
          sources: [
            MessageDetailSource(number: 1, url: 'a.com'),
            MessageDetailSource(number: 2, url: 'b.com'),
            MessageDetailSource(number: 3, url: 'c.com'),
          ],
          actions: [],
        ),
      );
      expect(find.text('1'), findsOneWidget);
      expect(find.text('2'), findsOneWidget);
      expect(find.text('3'), findsOneWidget);
    });

    testWidgets('primary action uses accent colour', (tester) async {
      await _pump(
        tester,
        KaiMessageDetailSheet(
          sources: const [],
          actions: [
            DetailAction(
              icon: KaiIconName.send,
              label: 'Share',
              style: DetailActionStyle.primary,
              onTap: () {},
            ),
          ],
        ),
      );
      final text = tester.widget<Text>(find.text('Share'));
      // Canon light accent #2C5BE5
      expect(text.style?.color, const Color(0xFF2C5BE5));
    });

    testWidgets('danger action uses negative colour', (tester) async {
      await _pump(
        tester,
        KaiMessageDetailSheet(
          sources: const [],
          actions: [
            DetailAction(
              icon: KaiIconName.close,
              label: 'Delete',
              style: DetailActionStyle.danger,
              onTap: () {},
            ),
          ],
        ),
      );
      final text = tester.widget<Text>(find.text('Delete'));
      // Canon light negative #C44A3C
      expect(text.style?.color, const Color(0xFFC44A3C));
    });

    testWidgets('fresh freshness shows positive check', (tester) async {
      await _pump(
        tester,
        const KaiMessageDetailSheet(
          sources: [
            MessageDetailSource(
              number: 1,
              url: 'a.com',
              freshness: SourceFreshness.fresh,
            ),
          ],
          actions: [],
        ),
      );
      expect(find.textContaining('fresh'), findsOneWidget);
    });

    testWidgets('action tap fires onTap', (tester) async {
      var taps = 0;
      await _pump(
        tester,
        KaiMessageDetailSheet(
          sources: const [],
          actions: [
            DetailAction(
              icon: KaiIconName.copy,
              label: 'Copy',
              onTap: () => taps++,
            ),
          ],
        ),
      );
      await tester.tap(find.text('Copy'));
      await tester.pump();
      expect(taps, 1);
    });
  });
}
