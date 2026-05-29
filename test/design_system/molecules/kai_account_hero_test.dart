import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:kai_app/design_system/atoms/kai_avatar.dart';
import 'package:kai_app/design_system/molecules/kai_account_hero.dart';

import '../../test_helpers.dart';

void main() {
  group('v3/KaiAccountHero', () {
    // -------------------------------------------------------------------------
    // Variant enum
    // -------------------------------------------------------------------------

    test('KaiAccountHeroVariant has exactly 2 values', () {
      expect(KaiAccountHeroVariant.values.length, 2);
    });

    // -------------------------------------------------------------------------
    // compact variant
    // -------------------------------------------------------------------------

    testWidgets('compact: omits email', (tester) async {
      await tester.pumpWidget(
        buildTestWidget(
          const KaiAccountHero(
            name: 'Рустам',
            email: 'rustam@example.com',
            initial: 'Р',
            variant: KaiAccountHeroVariant.compact,
          ),
        ),
      );
      await tester.pump();
      expect(find.text('Рустам'), findsOneWidget);
      expect(find.text('rustam@example.com'), findsNothing);
    });

    testWidgets('compact: omits plan badge', (tester) async {
      await tester.pumpWidget(
        buildTestWidget(
          const KaiAccountHero(
            name: 'Рустам',
            email: 'rustam@example.com',
            initial: 'Р',
            planLabel: 'pro',
            variant: KaiAccountHeroVariant.compact,
          ),
        ),
      );
      await tester.pump();
      expect(find.text('PRO'), findsNothing);
    });

    testWidgets('compact: renders KaiAvatar', (tester) async {
      await tester.pumpWidget(
        buildTestWidget(
          const KaiAccountHero(
            name: 'Рустам',
            email: 'rustam@example.com',
            initial: 'Р',
            variant: KaiAccountHeroVariant.compact,
          ),
        ),
      );
      await tester.pump();
      expect(find.byType(KaiAvatar), findsOneWidget);
    });

    // -------------------------------------------------------------------------
    // full variant (default — existing tests still pass)
    // -------------------------------------------------------------------------

    testWidgets('full: shows email', (tester) async {
      await tester.pumpWidget(
        buildTestWidget(
          const KaiAccountHero(
            name: 'Рустам',
            email: 'rustam@example.com',
            initial: 'Р',
            variant: KaiAccountHeroVariant.full,
          ),
        ),
      );
      await tester.pump();
      expect(find.text('rustam@example.com'), findsOneWidget);
    });

    testWidgets('full: shows plan badge when planLabel provided', (tester) async {
      await tester.pumpWidget(
        buildTestWidget(
          const KaiAccountHero(
            name: 'Рустам',
            email: 'rustam@example.com',
            initial: 'Р',
            planLabel: 'pro',
            variant: KaiAccountHeroVariant.full,
          ),
        ),
      );
      await tester.pump();
      expect(find.text('PRO'), findsOneWidget);
    });

    // -------------------------------------------------------------------------
    // onTap
    // -------------------------------------------------------------------------

    testWidgets('onTap fires when card tapped', (tester) async {
      var tapped = false;
      await tester.pumpWidget(
        buildTestWidget(
          KaiAccountHero(
            name: 'Рустам',
            email: 'rustam@example.com',
            initial: 'Р',
            onTap: () => tapped = true,
          ),
        ),
      );
      await tester.pump();
      await tester.tap(find.text('Рустам'));
      await tester.pump();
      expect(tapped, isTrue);
    });

    testWidgets('no onTap: no InkWell wrapping', (tester) async {
      await tester.pumpWidget(
        buildTestWidget(
          const KaiAccountHero(
            name: 'Рустам',
            email: 'rustam@example.com',
            initial: 'Р',
          ),
        ),
      );
      await tester.pump();
      // Should render without error; onTap=null means no InkWell ancestor.
      expect(find.byType(KaiAccountHero), findsOneWidget);
      expect(find.byType(InkWell), findsNothing);
    });


    // -------------------------------------------------------------------------
    // Renders KaiAvatar atom (not an inline gradient circle)
    // -------------------------------------------------------------------------

    testWidgets('renders KaiAvatar atom', (tester) async {
      await tester.pumpWidget(
        buildTestWidget(
          const KaiAccountHero(
            name: 'Рустам',
            email: 'r@example.com',
            initial: 'R',
          ),
        ),
      );
      await tester.pump();
      expect(find.byType(KaiAvatar), findsOneWidget);
    });

    // -------------------------------------------------------------------------
    // Text content
    // -------------------------------------------------------------------------

    testWidgets('renders name text', (tester) async {
      await tester.pumpWidget(
        buildTestWidget(
          const KaiAccountHero(
            name: 'Рустам Хусейнов',
            email: 'rustam@example.com',
            initial: 'Р',
          ),
        ),
      );
      await tester.pump();
      expect(find.text('Рустам Хусейнов'), findsOneWidget);
    });

    testWidgets('renders email text', (tester) async {
      await tester.pumpWidget(
        buildTestWidget(
          const KaiAccountHero(
            name: 'Рустам',
            email: 'rustam@example.com',
            initial: 'Р',
          ),
        ),
      );
      await tester.pump();
      expect(find.text('rustam@example.com'), findsOneWidget);
    });

    // -------------------------------------------------------------------------
    // Plan badge
    // -------------------------------------------------------------------------

    testWidgets('renders plan label text when provided', (tester) async {
      await tester.pumpWidget(
        buildTestWidget(
          const KaiAccountHero(
            name: 'Рустам',
            email: 'r@example.com',
            initial: 'Р',
            planLabel: 'plus',
          ),
        ),
      );
      await tester.pump();
      // planLabel is uppercased inside the widget.
      expect(find.text('PLUS'), findsOneWidget);
    });

    testWidgets('omits plan badge when planLabel is null', (tester) async {
      await tester.pumpWidget(
        buildTestWidget(
          const KaiAccountHero(
            name: 'Рустам',
            email: 'r@example.com',
            initial: 'Р',
          ),
        ),
      );
      await tester.pump();
      expect(find.text('PLUS'), findsNothing);
      expect(find.text('FREE'), findsNothing);
    });

    testWidgets('renders free plan label', (tester) async {
      await tester.pumpWidget(
        buildTestWidget(
          const KaiAccountHero(
            name: 'Рустам',
            email: 'r@example.com',
            initial: 'Р',
            planLabel: 'free',
          ),
        ),
      );
      await tester.pump();
      expect(find.text('FREE'), findsOneWidget);
    });

    // -------------------------------------------------------------------------
    // Full combination
    // -------------------------------------------------------------------------

    testWidgets('renders all fields together without error', (tester) async {
      await tester.pumpWidget(
        buildTestWidget(
          const KaiAccountHero(
            name: 'Рустам Хусейнов',
            email: 'rustam.wize@gmail.com',
            initial: 'Р',
            planLabel: 'pro',
          ),
        ),
      );
      await tester.pump();

      expect(find.byType(KaiAvatar), findsOneWidget);
      expect(find.text('Рустам Хусейнов'), findsOneWidget);
      expect(find.text('rustam.wize@gmail.com'), findsOneWidget);
      expect(find.text('PRO'), findsOneWidget);
    });
  });
}
