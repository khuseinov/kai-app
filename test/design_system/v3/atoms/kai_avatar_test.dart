import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:kai_app/design_system/tokens/kai_tokens.dart';
import 'package:kai_app/design_system/v3/atoms/kai_avatar.dart';

import '../../../test_helpers.dart';

void main() {
  group('v3/KaiAvatar', () {
    // -------------------------------------------------------------------------
    // Shape + gradient
    // -------------------------------------------------------------------------
    group('shape and gradient', () {
      testWidgets('renders a circular BoxDecoration with gradientCorner',
          (tester) async {
        await tester.pumpWidget(
          buildTestWidget(const KaiAvatar()),
        );
        await tester.pump();

        final containers =
            tester.widgetList<Container>(find.byType(Container)).toList();
        final found = containers.any((c) {
          final deco = c.decoration;
          return deco is BoxDecoration &&
              deco.shape == BoxShape.circle &&
              deco.gradient == KaiTide.gradientCorner;
        });
        expect(found, isTrue,
            reason:
                'KaiAvatar must render a circle filled with KaiTide.gradientCorner');
      });

      testWidgets('default size is 40px', (tester) async {
        await tester.pumpWidget(
          buildTestWidget(const KaiAvatar()),
        );
        await tester.pump();

        final containers =
            tester.widgetList<Container>(find.byType(Container)).toList();
        final found = containers.any((c) {
          final deco = c.decoration;
          return deco is BoxDecoration &&
              deco.shape == BoxShape.circle &&
              c.constraints?.maxWidth == 40.0 &&
              c.constraints?.maxHeight == 40.0;
        });
        expect(found, isTrue,
            reason: 'default KaiAvatar must be 40x40px');
      });

      testWidgets('custom size is applied', (tester) async {
        await tester.pumpWidget(
          buildTestWidget(const KaiAvatar(size: 64)),
        );
        await tester.pump();

        final containers =
            tester.widgetList<Container>(find.byType(Container)).toList();
        final found = containers.any((c) {
          final deco = c.decoration;
          return deco is BoxDecoration &&
              deco.shape == BoxShape.circle &&
              c.constraints?.maxWidth == 64.0 &&
              c.constraints?.maxHeight == 64.0;
        });
        expect(found, isTrue,
            reason: 'KaiAvatar must respect the size parameter');
      });
    });

    // -------------------------------------------------------------------------
    // Initial letter
    // -------------------------------------------------------------------------
    group('initial letter', () {
      testWidgets('initial letter is shown when initial is provided',
          (tester) async {
        await tester.pumpWidget(
          buildTestWidget(const KaiAvatar(initial: 'R')),
        );
        await tester.pump();

        expect(find.text('R'), findsOneWidget);
      });

      testWidgets('initial is uppercased', (tester) async {
        await tester.pumpWidget(
          buildTestWidget(const KaiAvatar(initial: 'r')),
        );
        await tester.pump();

        expect(find.text('R'), findsOneWidget);
        expect(find.text('r'), findsNothing);
      });

      testWidgets('initial text color is white', (tester) async {
        await tester.pumpWidget(
          buildTestWidget(const KaiAvatar(initial: 'K')),
        );
        await tester.pump();

        final texts = tester.widgetList<Text>(find.byType(Text)).toList();
        final found = texts.any(
          (t) => t.style?.color == const Color(0xFFFFFFFF),
        );
        expect(found, isTrue,
            reason: 'initial letter must be white on gradient fill');
      });

      testWidgets('no Text widget when initial is null', (tester) async {
        await tester.pumpWidget(
          buildTestWidget(const KaiAvatar()),
        );
        await tester.pump();

        expect(find.byType(Text), findsNothing);
      });

      testWidgets('no Text widget when initial is empty string', (tester) async {
        await tester.pumpWidget(
          buildTestWidget(const KaiAvatar(initial: '')),
        );
        await tester.pump();

        expect(find.byType(Text), findsNothing);
      });
    });
  });
}
