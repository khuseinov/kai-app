import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:kai_app/design_system/tokens/kai_tokens.dart';
import 'package:kai_app/design_system/atoms/kai_input.dart';

import '../../test_helpers.dart';

void main() {
  group('v3/KaiInput', () {
    // -------------------------------------------------------------------------
    // KaiInput.line
    // -------------------------------------------------------------------------
    group('line', () {
      testWidgets('renders placeholder text', (tester) async {
        final controller = TextEditingController();
        await tester.pumpWidget(
          buildTestWidget(
            KaiInput.line(controller: controller, placeholder: 'Поиск'),
          ),
        );
        await tester.pump();
        expect(find.text('Поиск'), findsOneWidget);
      });

      testWidgets('uses KaiRadius.br2 (r10) decoration', (tester) async {
        final controller = TextEditingController();
        await tester.pumpWidget(
          buildTestWidget(
            KaiInput.line(controller: controller),
          ),
        );
        await tester.pump();
        // OutlineInputBorder carries the border radius.
        final borders = tester
            .widgetList<TextField>(find.byType(TextField))
            .toList();
        expect(borders, isNotEmpty);
        final decoration = borders.first.decoration;
        expect(decoration, isNotNull);
        final enabledBorder = decoration!.enabledBorder;
        expect(enabledBorder, isA<OutlineInputBorder>());
        final outline = enabledBorder as OutlineInputBorder;
        expect(
          outline.borderRadius,
          KaiRadius.br2,
          reason: 'KaiInput.line must use KaiRadius.br2',
        );
      });

      testWidgets('fires onChanged when text is entered', (tester) async {
        final controller = TextEditingController();
        final values = <String>[];
        await tester.pumpWidget(
          buildTestWidget(
            KaiInput.line(
              controller: controller,
              onChanged: values.add,
            ),
          ),
        );
        await tester.pump();
        await tester.enterText(find.byType(TextField), 'hello');
        expect(values, contains('hello'));
      });

      testWidgets('enabled=false disables TextField', (tester) async {
        final controller = TextEditingController();
        await tester.pumpWidget(
          buildTestWidget(
            KaiInput.line(
              controller: controller,
              // ignore: avoid_redundant_argument_values
              enabled: false,
            ),
          ),
        );
        await tester.pump();
        final tf = tester.widget<TextField>(find.byType(TextField));
        expect(tf.enabled, isFalse,
            reason: 'enabled=false must disable the TextField');
      });

      testWidgets('enabled=true (default) keeps TextField active', (tester) async {
        final controller = TextEditingController();
        await tester.pumpWidget(
          buildTestWidget(
            KaiInput.line(controller: controller),
          ),
        );
        await tester.pump();
        final tf = tester.widget<TextField>(find.byType(TextField));
        expect(tf.enabled, isTrue);
      });
    });

    // -------------------------------------------------------------------------
    // KaiInput.pill
    // -------------------------------------------------------------------------
    group('pill', () {
      testWidgets('renders placeholder text', (tester) async {
        final controller = TextEditingController();
        await tester.pumpWidget(
          buildTestWidget(
            KaiInput.pill(controller: controller, placeholder: 'Сообщение'),
          ),
        );
        await tester.pump();
        expect(find.text('Сообщение'), findsOneWidget);
      });

      testWidgets('uses KaiRadius.brPill decoration', (tester) async {
        final controller = TextEditingController();
        await tester.pumpWidget(
          buildTestWidget(
            KaiInput.pill(controller: controller),
          ),
        );
        await tester.pump();
        final borders = tester
            .widgetList<TextField>(find.byType(TextField))
            .toList();
        expect(borders, isNotEmpty);
        final decoration = borders.first.decoration;
        expect(decoration, isNotNull);
        final enabledBorder = decoration!.enabledBorder;
        expect(enabledBorder, isA<OutlineInputBorder>());
        final outline = enabledBorder as OutlineInputBorder;
        expect(
          outline.borderRadius,
          KaiRadius.brPill,
          reason: 'KaiInput.pill must use KaiRadius.brPill',
        );
      });

      testWidgets('fires onChanged when text is entered', (tester) async {
        final controller = TextEditingController();
        final values = <String>[];
        await tester.pumpWidget(
          buildTestWidget(
            KaiInput.pill(
              controller: controller,
              onChanged: values.add,
            ),
          ),
        );
        await tester.pump();
        await tester.enterText(find.byType(TextField), 'world');
        expect(values, contains('world'));
      });

      testWidgets('enabled=false disables TextField', (tester) async {
        final controller = TextEditingController();
        await tester.pumpWidget(
          buildTestWidget(
            KaiInput.pill(
              controller: controller,
              enabled: false,
            ),
          ),
        );
        await tester.pump();
        final tf = tester.widget<TextField>(find.byType(TextField));
        expect(tf.enabled, isFalse);
      });

      testWidgets('pill and line have DIFFERENT radii', (tester) async {
        // A sanity check: br2 != brPill
        expect(KaiRadius.br2, isNot(equals(KaiRadius.brPill)));
      });
    });
  });
}
