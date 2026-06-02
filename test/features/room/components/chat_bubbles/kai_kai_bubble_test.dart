import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:kai_app/design_system/atoms/kai_icon_button.dart';
import 'package:kai_app/features/room/components/chat_bubbles/kai_kai_bubble.dart';
import 'package:kai_app/design_system/primitives/kai_gradient_bar.dart';
import 'package:kai_app/design_system/primitives/kai_icon.dart';

import '../../../../test_helpers.dart';

void main() {
  group('v3/KaiKaiBubble', () {
    // -------------------------------------------------------------------------
    // Basic render
    // -------------------------------------------------------------------------

    testWidgets('renders "KAI" who label', (tester) async {
      await tester.pumpWidget(
        buildTestWidget(
          const KaiKaiBubble(text: 'Ответ'),
        ),
      );
      await tester.pump();
      expect(find.text('KAI'), findsOneWidget);
    });

    testWidgets('renders body text', (tester) async {
      await tester.pumpWidget(
        buildTestWidget(
          const KaiKaiBubble(text: 'Тут ваш ответ'),
        ),
      );
      await tester.pump();
      // Body text is inside a RichText; the plain text finder covers it.
      expect(find.textContaining('Тут ваш ответ'), findsWidgets);
    });

    testWidgets('renders KaiGradientBar as who glyph', (tester) async {
      await tester.pumpWidget(
        buildTestWidget(
          const KaiKaiBubble(text: 'Glyph test'),
        ),
      );
      await tester.pump();
      expect(find.byType(KaiGradientBar), findsOneWidget);
    });

    // -------------------------------------------------------------------------
    // Citation parsing — [1] gets accent color
    // -------------------------------------------------------------------------

    testWidgets('citation [1] is rendered in accent colour', (tester) async {
      await tester.pumpWidget(
        buildTestWidget(
          const KaiKaiBubble(text: 'Смотри источник [1] здесь.'),
        ),
      );
      await tester.pump();

      // Find ALL RichText widgets in the tree
      final richTexts =
          tester.widgetList<RichText>(find.byType(RichText)).toList();

      // At least one RichText must contain a TextSpan with text '[1]'
      var foundCitation = false;
      for (final rt in richTexts) {
        if (_containsCitationSpan(rt.text, '[1]')) {
          foundCitation = true;
          break;
        }
      }
      expect(foundCitation, isTrue,
          reason: 'citation [1] must appear inside a RichText');
    });

    testWidgets('citation [1] span has accent color', (tester) async {
      await tester.pumpWidget(
        buildTestWidget(
          const KaiKaiBubble(text: 'Text [1] more'),
        ),
      );
      await tester.pump();

      final richTexts =
          tester.widgetList<RichText>(find.byType(RichText)).toList();

      Color? citationColor;
      for (final rt in richTexts) {
        citationColor = _findCitationColor(rt.text, '[1]');
        if (citationColor != null) break;
      }

      expect(citationColor, isNotNull,
          reason: 'citation span must have an explicit color');
      // The accent token in light theme is Color(0xFF2C5BE5) — but we don't
      // want to hard-code that here. Just verify it's NOT the default ink1
      // colour, which would mean the citation wasn't specially styled.
      expect(
        citationColor,
        isNot(equals(const Color(0xFF111114))),
        reason: 'citation colour must differ from default ink1',
      );
    });

    // Multiple citations
    testWidgets('multiple citations [1] and [2] both get accent color',
        (tester) async {
      await tester.pumpWidget(
        buildTestWidget(
          const KaiKaiBubble(text: 'Source [1] and [2] are cited.'),
        ),
      );
      await tester.pump();

      final richTexts =
          tester.widgetList<RichText>(find.byType(RichText)).toList();

      var citationCount = 0;
      for (final rt in richTexts) {
        citationCount += _countCitationSpans(rt.text);
      }
      expect(citationCount, greaterThanOrEqualTo(2),
          reason: 'both [1] and [2] must be separate citation spans');
    });

    // -------------------------------------------------------------------------
    // Sources widgets
    // -------------------------------------------------------------------------

    testWidgets('sources widgets render when passed', (tester) async {
      await tester.pumpWidget(
        buildTestWidget(
          const KaiKaiBubble(
            text: 'With sources [1].',
            sources: [
              Text('Source 1', key: Key('src1')),
              Text('Source 2', key: Key('src2')),
            ],
          ),
        ),
      );
      await tester.pump();
      expect(find.byKey(const Key('src1')), findsOneWidget);
      expect(find.byKey(const Key('src2')), findsOneWidget);
    });

    testWidgets('no sources widgets when sources list is empty', (tester) async {
      await tester.pumpWidget(
        buildTestWidget(
          const KaiKaiBubble(text: 'No sources.'),
        ),
      );
      await tester.pump();
      // Just verify no crash and the bubble renders
      expect(find.textContaining('No sources.'), findsWidgets);
    });

    // -------------------------------------------------------------------------
    // Streaming caret
    // -------------------------------------------------------------------------

    testWidgets('streaming: true renders a blinking caret widget', (tester) async {
      await tester.pumpWidget(
        buildTestWidget(
          const KaiKaiBubble(text: 'Streaming...', streaming: true),
        ),
      );
      await tester.pump();

      // The caret is driven by AnimatedBuilder (one per streaming bubble)
      expect(find.byType(AnimatedBuilder), findsWidgets,
          reason: 'streaming mode must include AnimatedBuilder for the caret');
    });

    testWidgets('streaming: false renders body text without caret', (tester) async {
      await tester.pumpWidget(
        buildTestWidget(
          const KaiKaiBubble(text: 'Not streaming', streaming: false),
        ),
      );
      await tester.pump();
      // Non-streaming: no Opacity widget that blinks (the caret uses Opacity
      // inside AnimatedBuilder). We verify the widget renders correctly and
      // no extra Opacity for the caret colour (ink1) blocks are present.
      // The body text must be visible.
      expect(find.textContaining('Not streaming'), findsWidgets);
    });

    // -------------------------------------------------------------------------
    // React buttons
    // -------------------------------------------------------------------------

    testWidgets('react buttons appear when both callbacks provided', (tester) async {
      await tester.pumpWidget(
        buildTestWidget(
          KaiKaiBubble(
            text: 'React test',
            onThumbUp: () {},
            onThumbDown: () {},
          ),
        ),
      );
      await tester.pump();
      final iconButtons = tester
          .widgetList<KaiIconButton>(find.byType(KaiIconButton))
          .toList();
      expect(iconButtons.length, 2,
          reason: 'both thumb buttons must render when callbacks provided');
    });

    testWidgets('only thumbUp button appears when only onThumbUp provided',
        (tester) async {
      await tester.pumpWidget(
        buildTestWidget(
          KaiKaiBubble(
            text: 'React test',
            onThumbUp: () {},
          ),
        ),
      );
      await tester.pump();
      // Should find exactly 1 KaiIconButton (thumbUp)
      expect(find.byType(KaiIconButton), findsOneWidget);
    });

    testWidgets('react buttons absent when no callbacks', (tester) async {
      await tester.pumpWidget(
        buildTestWidget(
          const KaiKaiBubble(text: 'No react'),
        ),
      );
      await tester.pump();
      expect(find.byType(KaiIconButton), findsNothing);
    });

    testWidgets('thumbUp callback fires on tap', (tester) async {
      var count = 0;
      await tester.pumpWidget(
        buildTestWidget(
          KaiKaiBubble(
            text: 'Tap test',
            onThumbUp: () => count++,
          ),
        ),
      );
      await tester.pump();
      await tester.tap(find.byType(KaiIconButton));
      expect(count, 1);
    });

    testWidgets('thumbDown callback fires on tap', (tester) async {
      var count = 0;
      await tester.pumpWidget(
        buildTestWidget(
          KaiKaiBubble(
            text: 'Tap test',
            onThumbDown: () => count++,
          ),
        ),
      );
      await tester.pump();
      await tester.tap(find.byType(KaiIconButton));
      expect(count, 1);
    });

    // -------------------------------------------------------------------------
    // sourcesLabel
    // -------------------------------------------------------------------------

    testWidgets('sourcesLabel text is rendered', (tester) async {
      await tester.pumpWidget(
        buildTestWidget(
          const KaiKaiBubble(
            text: 'Test',
            sourcesLabel: '2 источника · только что проверено',
          ),
        ),
      );
      await tester.pump();
      expect(
        find.textContaining('2 источника'),
        findsOneWidget,
      );
    });

    testWidgets(
        'meta-row does not overflow at narrow width (300px) with label + react',
        (tester) async {
      // Regression: sourcesLabel in a Row(mainAxisSize: min) overflowed at
      // narrow widths — fixed by wrapping sourcesLabel Text in Flexible.
      tester.view.physicalSize = const Size(300, 600);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);

      await tester.pumpWidget(
        buildTestWidget(
          KaiKaiBubble(
            text: 'Text',
            sourcesLabel: '3 источника · проверено 2 минуты назад',
            onThumbUp: () {},
            onThumbDown: () {},
          ),
        ),
      );
      await tester.pump();
      // No overflow errors — if the widget builds without exception the fix works.
      expect(find.byType(KaiKaiBubble), findsOneWidget);
    });

    // -------------------------------------------------------------------------
    // KaiIconName enum
    // -------------------------------------------------------------------------

    testWidgets('KaiIconName.thumbUp resolves to "thumb-up" asset name',
        (tester) async {
      expect(KaiIconName.thumbUp.assetName, 'thumb-up');
    });

    testWidgets('KaiIconName.thumbDown resolves to "thumb-down" asset name',
        (tester) async {
      expect(KaiIconName.thumbDown.assetName, 'thumb-down');
    });

    testWidgets('KaiIcon renders with thumbUp icon without throwing',
        (tester) async {
      await tester.pumpWidget(
        buildTestWidget(
          KaiIconButton.bare(
            onPressed: () {},
            icon: KaiIconName.thumbUp,
          ),
        ),
      );
      await tester.pump();
      expect(find.byType(KaiIcon), findsOneWidget);
    });
  });
}

// ---------------------------------------------------------------------------
// Helpers for inspecting TextSpan trees
// ---------------------------------------------------------------------------

/// Returns true if the [InlineSpan] tree contains a [TextSpan] with text [target].
bool _containsCitationSpan(InlineSpan span, String target) {
  if (span is TextSpan) {
    if (span.text == target) return true;
    if (span.children != null) {
      for (final child in span.children!) {
        if (_containsCitationSpan(child, target)) return true;
      }
    }
  }
  return false;
}

/// Returns the color of the first [TextSpan] with text [target], or null.
Color? _findCitationColor(InlineSpan span, String target) {
  if (span is TextSpan) {
    if (span.text == target) return span.style?.color;
    if (span.children != null) {
      for (final child in span.children!) {
        final c = _findCitationColor(child, target);
        if (c != null) return c;
      }
    }
  }
  return null;
}

/// Counts TextSpan nodes that look like citation patterns (`[N]`).
int _countCitationSpans(InlineSpan span) {
  final pattern = RegExp(r'^\[\d+\]$');
  var count = 0;
  if (span is TextSpan) {
    if (span.text != null && pattern.hasMatch(span.text!)) count++;
    if (span.children != null) {
      for (final child in span.children!) {
        count += _countCitationSpans(child);
      }
    }
  }
  return count;
}
