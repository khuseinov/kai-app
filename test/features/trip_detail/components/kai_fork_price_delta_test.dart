import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:kai_app/features/trip_detail/components/kai_fork_price_delta.dart';
import 'package:kai_app/design_system/theme/kai_theme.dart';
import 'package:kai_app/design_system/tokens/kai_tokens.dart';

import '../../../test_helpers.dart';

void main() {
  group('v3/KaiForkPriceDelta', () {
    testWidgets('up uses negative palette (costlier)', (tester) async {
      await tester.pumpWidget(buildTestWidget(
        const KaiForkPriceDelta('+\$500', direction: KaiPriceDirection.up)));
      final ctx = tester.element(find.byType(KaiForkPriceDelta));
      final c = KaiTheme.of(ctx).colors;
      final txt = tester.widget<Text>(find.byType(Text));
      expect(txt.style!.color, c.negative);
      expect(txt.style!.fontFamily, 'JetBrainsMono');
      expect(txt.style!.fontSize, 8.5);
      expect(txt.style!.fontWeight, FontWeight.w600);
      final box = tester.widget<Container>(find.byType(Container));
      expect((box.decoration as BoxDecoration).color, c.negativeWash);
    });

    testWidgets('down uses positive palette (cheaper)', (tester) async {
      await tester.pumpWidget(buildTestWidget(
        const KaiForkPriceDelta('−\$500', direction: KaiPriceDirection.down)));
      final ctx = tester.element(find.byType(KaiForkPriceDelta));
      final c = KaiTheme.of(ctx).colors;
      final txt = tester.widget<Text>(find.byType(Text));
      expect(txt.style!.color, c.positive);
      final box = tester.widget<Container>(find.byType(Container));
      expect((box.decoration as BoxDecoration).color, c.positiveWash);
    });

    testWidgets('uses pill radius', (tester) async {
      await tester.pumpWidget(buildTestWidget(
        const KaiForkPriceDelta('+\$10', direction: KaiPriceDirection.up)));
      final box = tester.widget<Container>(find.byType(Container));
      expect((box.decoration as BoxDecoration).borderRadius, KaiRadius.brPill);
    });
  });
}
