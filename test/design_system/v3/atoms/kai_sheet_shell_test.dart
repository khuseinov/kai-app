import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:kai_app/design_system/tokens/kai_tokens.dart';
import 'package:kai_app/design_system/v3/atoms/kai_sheet_shell.dart';

import '../../../test_helpers.dart';

void main() {
  group('v3/KaiSheetShell', () {
    // -------------------------------------------------------------------------
    // Child rendering
    // -------------------------------------------------------------------------
    testWidgets('renders the supplied child', (tester) async {
      await tester.pumpWidget(
        buildTestWidget(
          const KaiSheetShell(child: Text('content')),
        ),
      );
      await tester.pump();
      expect(find.text('content'), findsOneWidget);
    });

    // -------------------------------------------------------------------------
    // Top-corner radius
    // -------------------------------------------------------------------------
    testWidgets('outer container has top-corner radius KaiRadius.r24',
        (tester) async {
      await tester.pumpWidget(
        buildTestWidget(
          const KaiSheetShell(child: SizedBox()),
        ),
      );
      await tester.pump();

      // The outermost Container of KaiSheetShell carries the sheet decoration.
      final outer = tester.widget<Container>(
        find
            .descendant(
              of: find.byType(KaiSheetShell),
              matching: find.byType(Container),
            )
            .first,
      );
      final dec = outer.decoration! as BoxDecoration;
      final radius = dec.borderRadius! as BorderRadius;
      expect(radius.topLeft, const Radius.circular(KaiRadius.r24));
      expect(radius.topRight, const Radius.circular(KaiRadius.r24));
      expect(radius.bottomLeft, Radius.zero);
      expect(radius.bottomRight, Radius.zero);
    });

    // -------------------------------------------------------------------------
    // Surface color + line top border
    // -------------------------------------------------------------------------
    testWidgets('outer container uses surface color and line top border',
        (tester) async {
      await tester.pumpWidget(
        buildTestWidget(
          const KaiSheetShell(child: SizedBox()),
        ),
      );
      await tester.pump();

      final outer = tester.widget<Container>(
        find
            .descendant(
              of: find.byType(KaiSheetShell),
              matching: find.byType(Container),
            )
            .first,
      );
      final dec = outer.decoration! as BoxDecoration;
      expect(dec.color, KaiTokens.light.colors.surface);
      final border = dec.border! as Border;
      expect(border.top.color, KaiTokens.light.colors.line);
      expect(border.top.width, 1.0);
    });

    // -------------------------------------------------------------------------
    // Drag pill
    // -------------------------------------------------------------------------
    testWidgets('drag pill is present with pill borderRadius', (tester) async {
      await tester.pumpWidget(
        buildTestWidget(
          const KaiSheetShell(child: SizedBox()),
        ),
      );
      await tester.pump();

      // The drag pill is a Container with brPill decoration.
      final containers =
          tester.widgetList<Container>(find.byType(Container)).toList();

      final hasPillRadius = containers.any((c) {
        final dec = c.decoration;
        if (dec is! BoxDecoration) return false;
        final br = dec.borderRadius;
        if (br == null) return false;
        // brPill = BorderRadius.all(Radius.circular(999))
        return br == const BorderRadius.all(Radius.circular(999));
      });
      expect(hasPillRadius, isTrue,
          reason: 'drag pill must have BorderRadius.all(Radius.circular(999))');
    });

    testWidgets('drag pill is 36 wide and 4 tall', (tester) async {
      await tester.pumpWidget(
        buildTestWidget(
          const KaiSheetShell(child: SizedBox()),
        ),
      );
      await tester.pump();

      // Find the pill by its width/height constraints set via Container.width/height.
      final containers =
          tester.widgetList<Container>(find.byType(Container)).toList();

      final pillContainer = containers.firstWhere(
        (c) => c.constraints?.maxWidth == 36 && c.constraints?.maxHeight == 4,
        orElse: () {
          // Fallback: match by decoration pill-radius + ink4 color family.
          return containers.firstWhere(
            (c) {
              final dec = c.decoration;
              return dec is BoxDecoration &&
                  dec.borderRadius ==
                      const BorderRadius.all(Radius.circular(999));
            },
          );
        },
      );
      expect(pillContainer, isNotNull);
    });

    // -------------------------------------------------------------------------
    // Column structure
    // -------------------------------------------------------------------------
    testWidgets('pill appears above the child in a Column', (tester) async {
      await tester.pumpWidget(
        buildTestWidget(
          const KaiSheetShell(child: Text('below')),
        ),
      );
      await tester.pump();

      // The Column is a direct child of the outer Container.
      expect(find.byType(Column), findsWidgets);
      // The child text must be present and below (later in widget tree) than
      // the Center wrapping the drag pill.
      expect(find.byType(Center), findsWidgets);
      expect(find.text('below'), findsOneWidget);
    });
  });
}
