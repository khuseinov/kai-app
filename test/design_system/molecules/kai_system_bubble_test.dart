import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:kai_app/design_system/tokens/kai_colors.dart';
import 'package:kai_app/design_system/molecules/kai_system_bubble.dart';
import 'package:kai_app/design_system/primitives/kai_icon.dart';

import '../../test_helpers.dart';

void main() {
  group('v3/KaiSystemBubble', () {
    // -------------------------------------------------------------------------
    // Renders message
    // -------------------------------------------------------------------------

    testWidgets('renders message text', (tester) async {
      await tester.pumpWidget(
        buildTestWidget(
          const KaiSystemBubble('System note'),
        ),
      );
      await tester.pump();
      expect(find.textContaining('System note'), findsWidgets);
    });

    testWidgets('renders KaiIcon', (tester) async {
      await tester.pumpWidget(
        buildTestWidget(
          const KaiSystemBubble('Icon test'),
        ),
      );
      await tester.pump();
      expect(find.byType(KaiIcon), findsOneWidget);
    });

    testWidgets('is full-width — at least one Container exists in tree',
        (tester) async {
      await tester.pumpWidget(
        buildTestWidget(
          const KaiSystemBubble('Width test'),
        ),
      );
      await tester.pump();
      // Verify the widget renders without overflow and has at least one
      // Container (the outer shell with width: double.infinity).
      expect(find.byType(Container), findsWidgets);
    });

    // -------------------------------------------------------------------------
    // Tone: neutral
    // -------------------------------------------------------------------------

    testWidgets('neutral tone — background is surface2', (tester) async {
      await tester.pumpWidget(
        buildTestWidget(
          const KaiSystemBubble(
            'Neutral',
            tone: KaiSystemTone.neutral,
          ),
        ),
      );
      await tester.pump();

      _expectContainerWithColor(tester, KaiColors.light.surface2);
    });

    testWidgets('neutral tone — foreground text is ink2', (tester) async {
      await tester.pumpWidget(
        buildTestWidget(
          const KaiSystemBubble(
            'Neutral text',
            tone: KaiSystemTone.neutral,
          ),
        ),
      );
      await tester.pump();
      _expectRichTextWithColor(tester, KaiColors.light.ink2);
    });

    // -------------------------------------------------------------------------
    // Tone: warning
    // -------------------------------------------------------------------------

    testWidgets('warning tone — background is warningWash', (tester) async {
      await tester.pumpWidget(
        buildTestWidget(
          const KaiSystemBubble(
            'Warning',
            tone: KaiSystemTone.warning,
          ),
        ),
      );
      await tester.pump();

      _expectContainerWithColor(tester, KaiColors.light.warningWash);
    });

    testWidgets('warning tone — foreground is warning color', (tester) async {
      await tester.pumpWidget(
        buildTestWidget(
          const KaiSystemBubble(
            'Warning text',
            tone: KaiSystemTone.warning,
          ),
        ),
      );
      await tester.pump();
      _expectRichTextWithColor(tester, KaiColors.light.warning);
    });

    // -------------------------------------------------------------------------
    // Tone: negative
    // -------------------------------------------------------------------------

    testWidgets('negative tone — background is negativeWash', (tester) async {
      await tester.pumpWidget(
        buildTestWidget(
          const KaiSystemBubble(
            'Negative',
            tone: KaiSystemTone.negative,
          ),
        ),
      );
      await tester.pump();

      _expectContainerWithColor(tester, KaiColors.light.negativeWash);
    });

    testWidgets('negative tone — foreground is negative color', (tester) async {
      await tester.pumpWidget(
        buildTestWidget(
          const KaiSystemBubble(
            'Negative text',
            tone: KaiSystemTone.negative,
          ),
        ),
      );
      await tester.pump();
      _expectRichTextWithColor(tester, KaiColors.light.negative);
    });

    // -------------------------------------------------------------------------
    // Bold lead-in
    // -------------------------------------------------------------------------

    testWidgets('bold text and message both appear', (tester) async {
      await tester.pumpWidget(
        buildTestWidget(
          const KaiSystemBubble(
            ' сайт не обновлялся.',
            bold: 'Внимание —',
          ),
        ),
      );
      await tester.pump();
      // Both spans appear inside the same RichText
      final richTexts =
          tester.widgetList<RichText>(find.byType(RichText)).toList();
      var hasBold = false;
      var hasMessage = false;
      for (final rt in richTexts) {
        if (_spanContainsText(rt.text, 'Внимание —')) hasBold = true;
        if (_spanContainsText(rt.text, ' сайт не обновлялся.')) hasMessage = true;
      }
      expect(hasBold, isTrue, reason: 'bold prefix must appear in RichText');
      expect(hasMessage, isTrue, reason: 'message must appear in RichText');
    });

    // -------------------------------------------------------------------------
    // Border radius
    // -------------------------------------------------------------------------

    testWidgets('uses KaiRadius.r12 (12px) border radius', (tester) async {
      await tester.pumpWidget(
        buildTestWidget(
          const KaiSystemBubble('Radius test'),
        ),
      );
      await tester.pump();
      final containers = tester
          .widgetList<Container>(find.byType(Container))
          .toList();
      final has12 = containers.any((c) {
        final deco = c.decoration;
        if (deco is! BoxDecoration) return false;
        final br = deco.borderRadius;
        return br == BorderRadius.circular(12);
      });
      expect(has12, isTrue,
          reason: 'system bubble border-radius must be 12px (KaiRadius.r12)');
    });

    // -------------------------------------------------------------------------
    // Custom icon
    // -------------------------------------------------------------------------

    testWidgets('custom icon is forwarded to KaiIcon', (tester) async {
      await tester.pumpWidget(
        buildTestWidget(
          const KaiSystemBubble(
            'Custom icon',
            icon: KaiIconName.info,
          ),
        ),
      );
      await tester.pump();
      final icon = tester.widget<KaiIcon>(find.byType(KaiIcon));
      expect(icon.name, KaiIconName.info);
    });
  });
}

// ---------------------------------------------------------------------------
// Helpers
// ---------------------------------------------------------------------------

void _expectContainerWithColor(WidgetTester tester, Color expected) {
  final containers =
      tester.widgetList<Container>(find.byType(Container)).toList();
  final found = containers.any((c) {
    final deco = c.decoration;
    return deco is BoxDecoration && deco.color == expected;
  });
  expect(found, isTrue,
      reason: 'expected a Container with color $expected');
}

void _expectRichTextWithColor(WidgetTester tester, Color expected) {
  final richTexts =
      tester.widgetList<RichText>(find.byType(RichText)).toList();
  final found = richTexts.any((rt) => _spanHasColor(rt.text, expected));
  expect(found, isTrue,
      reason: 'expected a RichText span with color $expected');
}

bool _spanHasColor(InlineSpan span, Color color) {
  if (span is TextSpan) {
    if (span.style?.color == color) return true;
    if (span.children != null) {
      for (final child in span.children!) {
        if (_spanHasColor(child, color)) return true;
      }
    }
  }
  return false;
}

bool _spanContainsText(InlineSpan span, String text) {
  if (span is TextSpan) {
    if (span.text?.contains(text) == true) return true;
    if (span.children != null) {
      for (final child in span.children!) {
        if (_spanContainsText(child, text)) return true;
      }
    }
  }
  return false;
}
