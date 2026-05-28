import 'package:flutter_test/flutter_test.dart';
import 'package:kai_app/design_system/v3/atoms/kai_avatar.dart';
import 'package:kai_app/design_system/v3/molecules/kai_account_hero.dart';

import '../../../test_helpers.dart';

void main() {
  group('v3/KaiAccountHero', () {
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
