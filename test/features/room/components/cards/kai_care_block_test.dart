import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:kai_app/features/room/presentation/widgets/cards/kai_care_block.dart';

import '../../../../test_helpers.dart';

void main() {
  group('v3/KaiCareBlock', () {
    // -------------------------------------------------------------------------
    // Basic content rendering
    // -------------------------------------------------------------------------

    testWidgets('renders heading text', (tester) async {
      await tester.pumpWidget(
        buildTestWidget(
          const KaiCareBlock(
            heading: 'Я слышу тебя.',
            body: 'Ты не один в этом.',
          ),
        ),
      );
      await tester.pump();
      expect(find.text('Я слышу тебя.'), findsOneWidget);
    });

    testWidgets('renders body text', (tester) async {
      await tester.pumpWidget(
        buildTestWidget(
          const KaiCareBlock(
            heading: 'Заголовок',
            body: 'Текст поддержки для пользователя.',
          ),
        ),
      );
      await tester.pump();
      expect(find.text('Текст поддержки для пользователя.'), findsOneWidget);
    });

    testWidgets('renders resource label and number', (tester) async {
      await tester.pumpWidget(
        buildTestWidget(
          const KaiCareBlock(
            heading: 'Помощь рядом',
            body: 'Обратись за помощью.',
            resources: [
              KaiCareResource(label: 'Телефон доверия', number: '8-800-2000-122'),
            ],
          ),
        ),
      );
      await tester.pump();
      expect(find.text('8-800-2000-122'), findsOneWidget);
      expect(find.textContaining('Телефон доверия'), findsOneWidget);
    });

    testWidgets('renders multiple resources', (tester) async {
      await tester.pumpWidget(
        buildTestWidget(
          const KaiCareBlock(
            heading: 'Ресурсы',
            body: 'Ты не один.',
            resources: [
              KaiCareResource(label: 'Lifeline', number: '988'),
              KaiCareResource(label: 'Crisis Text Line', number: '741741'),
            ],
          ),
        ),
      );
      await tester.pump();
      expect(find.text('988'), findsOneWidget);
      expect(find.text('741741'), findsOneWidget);
    });

    testWidgets('renders closing italic line when provided', (tester) async {
      await tester.pumpWidget(
        buildTestWidget(
          const KaiCareBlock(
            heading: 'Заголовок',
            body: 'Тело.',
            closing: 'Всё будет хорошо.',
          ),
        ),
      );
      await tester.pump();
      expect(find.text('Всё будет хорошо.'), findsOneWidget);
    });

    testWidgets('omits closing when null', (tester) async {
      await tester.pumpWidget(
        buildTestWidget(
          const KaiCareBlock(
            heading: 'Заголовок',
            body: 'Тело.',
          ),
        ),
      );
      await tester.pump();
      expect(find.text('Всё будет хорошо.'), findsNothing);
    });

    testWidgets('omits resources section when resources is null', (tester) async {
      await tester.pumpWidget(
        buildTestWidget(
          const KaiCareBlock(
            heading: 'Заголовок',
            body: 'Тело без ресурсов.',
          ),
        ),
      );
      await tester.pump();
      // No resource numbers or bullet chars visible.
      expect(find.text('988'), findsNothing);
    });

    testWidgets('omits resources section when resources is empty', (tester) async {
      await tester.pumpWidget(
        buildTestWidget(
          const KaiCareBlock(
            heading: 'Заголовок',
            body: 'Тело без ресурсов.',
            resources: [],
          ),
        ),
      );
      await tester.pump();
      expect(find.text('988'), findsNothing);
    });

    // -------------------------------------------------------------------------
    // Resource tap callback
    // -------------------------------------------------------------------------

    testWidgets('onResourceTap fires when resource row is tapped', (tester) async {
      KaiCareResource? tapped;
      const resource = KaiCareResource(label: 'Lifeline', number: '988');

      await tester.pumpWidget(
        buildTestWidget(
          KaiCareBlock(
            heading: 'Заголовок',
            body: 'Тело.',
            resources: const [resource],
            onResourceTap: (r) => tapped = r,
          ),
        ),
      );
      await tester.pump();

      await tester.tap(find.text('988'));
      await tester.pump();

      expect(tapped, isNotNull);
      expect(tapped!.number, '988');
    });

    testWidgets('onResourceTap fires with correct resource when multiple exist',
        (tester) async {
      KaiCareResource? tapped;
      const res1 = KaiCareResource(label: 'Lifeline', number: '988');
      const res2 = KaiCareResource(label: 'Crisis Text', number: '741741');

      await tester.pumpWidget(
        buildTestWidget(
          KaiCareBlock(
            heading: 'Заголовок',
            body: 'Тело.',
            resources: const [res1, res2],
            onResourceTap: (r) => tapped = r,
          ),
        ),
      );
      await tester.pump();

      await tester.tap(find.text('741741'));
      await tester.pump();

      expect(tapped?.number, '741741');
    });

    testWidgets('resources render without crash when onResourceTap is null',
        (tester) async {
      await tester.pumpWidget(
        buildTestWidget(
          const KaiCareBlock(
            heading: 'Заголовок',
            body: 'Тело.',
            resources: [KaiCareResource(label: 'Lifeline', number: '988')],
          ),
        ),
      );
      await tester.pump();
      expect(find.text('988'), findsOneWidget);
    });

    // -------------------------------------------------------------------------
    // Visual structure — left border coral color
    // -------------------------------------------------------------------------

    testWidgets('DecoratedBox has left border in negative (coral) color', (tester) async {
      await tester.pumpWidget(
        buildTestWidget(
          const KaiCareBlock(
            heading: 'Заголовок',
            body: 'Тело.',
          ),
        ),
      );
      await tester.pump();

      // The negative (coral) token in light theme is Color(0xFFC44A3C).
      const negativeLight = Color(0xFFC44A3C);

      final decoratedBoxes = tester
          .widgetList<DecoratedBox>(find.byType(DecoratedBox))
          .toList();

      final hasNegativeBorder = decoratedBoxes.any((db) {
        final deco = db.decoration;
        if (deco is! BoxDecoration) return false;
        final border = deco.border;
        if (border is! Border) return false;
        return border.left.color == negativeLight;
      });

      expect(hasNegativeBorder, isTrue,
          reason: 'CareBlock must have a left BorderSide in negative (coral) color',);
    });

    testWidgets('left border is flush (r0/10/10/0 corners)', (tester) async {
      await tester.pumpWidget(
        buildTestWidget(
          const KaiCareBlock(
            heading: 'Заголовок',
            body: 'Тело.',
          ),
        ),
      );
      await tester.pump();

      final decoratedBoxes = tester
          .widgetList<DecoratedBox>(find.byType(DecoratedBox))
          .toList();

      final hasFlushCorners = decoratedBoxes.any((db) {
        final deco = db.decoration;
        if (deco is! BoxDecoration) return false;
        final br = deco.borderRadius;
        if (br is! BorderRadius) return false;
        // Left corners are 0 (flush), right corners are non-zero.
        return br.topLeft == Radius.zero &&
            br.bottomLeft == Radius.zero &&
            br.topRight != Radius.zero &&
            br.bottomRight != Radius.zero;
      });

      expect(hasFlushCorners, isTrue,
          reason: 'CareBlock must have flush left corners (r0) and rounded right corners',);
    });

    // -------------------------------------------------------------------------
    // Full combination
    // -------------------------------------------------------------------------

    testWidgets('renders all fields together without error', (tester) async {
      await tester.pumpWidget(
        buildTestWidget(
          KaiCareBlock(
            heading: 'Я слышу тебя.',
            body: 'Ты не один. Обратись за помощью.',
            resources: const [
              KaiCareResource(label: 'Телефон доверия', number: '8-800-2000-122'),
              KaiCareResource(label: 'Lifeline', number: '988'),
            ],
            closing: 'Я здесь.',
            onResourceTap: (_) {},
          ),
        ),
      );
      await tester.pump();

      expect(find.text('Я слышу тебя.'), findsOneWidget);
      expect(find.text('Ты не один. Обратись за помощью.'), findsOneWidget);
      expect(find.text('8-800-2000-122'), findsOneWidget);
      expect(find.text('988'), findsOneWidget);
      expect(find.text('Я здесь.'), findsOneWidget);
    });

    // -------------------------------------------------------------------------
    // Narrow-width overflow regression — _ResourceRow label in Flexible
    // -------------------------------------------------------------------------

    testWidgets(
        'resource row does not overflow at narrow width (322px)',
        (tester) async {
      // Regression: label Text in _ResourceRow overflowed at ≤322px — fixed by
      // wrapping label in Flexible with TextOverflow.ellipsis.
      tester.view.physicalSize = const Size(322, 600);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);

      await tester.pumpWidget(
        buildTestWidget(
          const KaiCareBlock(
            heading: 'Помощь рядом',
            body: 'Обратись.',
            resources: [
              KaiCareResource(
                label: 'Телефон доверия кризисной помощи',
                number: '8-800-2000-122',
              ),
            ],
          ),
        ),
      );
      await tester.pump();
      // No overflow exception thrown — fix confirmed.
      expect(find.byType(KaiCareBlock), findsOneWidget);
    });

    // -------------------------------------------------------------------------
    // No "action" param (compile-time: type has no such field)
    // -------------------------------------------------------------------------

    testWidgets('KaiCareBlock does not expose an action field', (tester) async {
      // This test is compile-time-verified: KaiCareBlock has no `action` param.
      // Just render a minimal instance to confirm the widget works.
      await tester.pumpWidget(
        buildTestWidget(
          const KaiCareBlock(heading: 'H', body: 'B'),
        ),
      );
      await tester.pump();
      expect(find.byType(KaiCareBlock), findsOneWidget);
    });
  });
}
