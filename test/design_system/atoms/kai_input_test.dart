import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:kai_app/design_system/atoms/kai_input.dart';
import 'package:kai_app/design_system/tokens/kai_tokens.dart';

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
        final outline = enabledBorder! as OutlineInputBorder;
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
            reason: 'enabled=false must disable the TextField',);
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

      testWidgets('uses compact font size (13.5px)', (tester) async {
        final controller = TextEditingController();
        await tester.pumpWidget(
          buildTestWidget(
            KaiInput.line(controller: controller),
          ),
        );
        await tester.pump();
        final tf = tester.widget<TextField>(find.byType(TextField));
        expect(tf.style?.fontSize, closeTo(13.5, 0.01),
            reason: 'KaiInput.line must use canon 13.5px font size',);
      });

      testWidgets('uses compact symmetric padding (8/12)', (tester) async {
        final controller = TextEditingController();
        await tester.pumpWidget(
          buildTestWidget(
            KaiInput.line(controller: controller),
          ),
        );
        await tester.pump();
        final tf = tester.widget<TextField>(find.byType(TextField));
        final padding = tf.decoration?.contentPadding;
        expect(padding, isA<EdgeInsets>());
        final ei = padding! as EdgeInsets;
        expect(ei.top, closeTo(KaiSpace.s2, 0.01),
            reason: 'line vertical padding must be KaiSpace.s2 (8px)',);
        expect(ei.left, closeTo(KaiSpace.s3, 0.01),
            reason: 'line horizontal padding must be KaiSpace.s3 (12px)',);
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
        final outline = enabledBorder! as OutlineInputBorder;
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

      testWidgets('uses compact font size (13.5px)', (tester) async {
        final controller = TextEditingController();
        await tester.pumpWidget(
          buildTestWidget(
            KaiInput.pill(controller: controller),
          ),
        );
        await tester.pump();
        final tf = tester.widget<TextField>(find.byType(TextField));
        expect(tf.style?.fontSize, closeTo(13.5, 0.01),
            reason: 'KaiInput.pill must use canon 13.5px font size',);
      });

      testWidgets('uses canon pill padding (left:14, right:5, top:5, bottom:5)',
          (tester) async {
        final controller = TextEditingController();
        await tester.pumpWidget(
          buildTestWidget(
            KaiInput.pill(controller: controller),
          ),
        );
        await tester.pump();
        final tf = tester.widget<TextField>(find.byType(TextField));
        final padding = tf.decoration?.contentPadding;
        expect(padding, isA<EdgeInsets>());
        final ei = padding! as EdgeInsets;
        expect(ei.left, closeTo(14, 0.01),
            reason: 'pill left padding must be 14px (canon)',);
        expect(ei.right, closeTo(5, 0.01),
            reason: 'pill right padding must be 5px (canon)',);
        expect(ei.top, closeTo(5, 0.01),
            reason: 'pill top padding must be 5px (canon)',);
        expect(ei.bottom, closeTo(5, 0.01),
            reason: 'pill bottom padding must be 5px (canon)',);
      });

      testWidgets('pill and line have DIFFERENT radii', (tester) async {
        // A sanity check: br2 != brPill
        expect(KaiRadius.br2, isNot(equals(KaiRadius.brPill)));
      });
    });
  });
}
