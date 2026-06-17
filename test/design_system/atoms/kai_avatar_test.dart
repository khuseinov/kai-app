import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:kai_app/design_system/atoms/kai_avatar.dart';
import 'package:kai_app/design_system/primitives/kai_gradient_bar.dart';
import 'package:kai_app/design_system/tokens/kai_tokens.dart';

import '../../test_helpers.dart';

// Helper: find a Container that is a circle with the gradientCorner gradient.
bool _hasGradientCircle(WidgetTester tester, double? diameter) {
  final containers =
      tester.widgetList<Container>(find.byType(Container)).toList();
  return containers.any((c) {
    final deco = c.decoration;
    if (deco is! BoxDecoration) return false;
    if (deco.shape != BoxShape.circle) return false;
    if (deco.gradient != KaiTide.gradientCorner) return false;
    if (diameter != null) {
      if (c.constraints?.maxWidth != diameter) return false;
      if (c.constraints?.maxHeight != diameter) return false;
    }
    return true;
  });
}

void main() {
  group('v3/KaiAvatar', () {
    // -------------------------------------------------------------------------
    // Shape + gradient (legacy constructor)
    // -------------------------------------------------------------------------
    group('shape and gradient', () {
      testWidgets('renders a circular BoxDecoration with gradientCorner',
          (tester) async {
        await tester.pumpWidget(
          buildTestWidget(const KaiAvatar()),
        );
        await tester.pump();
        expect(_hasGradientCircle(tester, null), isTrue,
            reason:
                'KaiAvatar must render a circle filled with KaiTide.gradientCorner',);
      });

      testWidgets('default size is 40px', (tester) async {
        await tester.pumpWidget(
          buildTestWidget(const KaiAvatar()),
        );
        await tester.pump();
        expect(_hasGradientCircle(tester, 40), isTrue,
            reason: 'default KaiAvatar must be 40x40px',);
      });

      testWidgets('custom size is applied', (tester) async {
        await tester.pumpWidget(
          buildTestWidget(const KaiAvatar(size: 64)),
        );
        await tester.pump();
        expect(_hasGradientCircle(tester, 64), isTrue,
            reason: 'KaiAvatar must respect the size parameter',);
      });
    });

    // -------------------------------------------------------------------------
    // Initial letter (legacy constructor)
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
            reason: 'initial letter must be white on gradient fill',);
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

    // -------------------------------------------------------------------------
    // KaiAvatarSize enum diameters
    // -------------------------------------------------------------------------
    group('named ctor sizes', () {
      testWidgets('sm is 28px', (tester) async {
        await tester.pumpWidget(
          buildTestWidget(const KaiAvatar.user('A', avatarSize: KaiAvatarSize.sm)),
        );
        await tester.pump();
        expect(_hasGradientCircle(tester, 28), isTrue,
            reason: 'KaiAvatarSize.sm must produce a 28px circle',);
      });

      testWidgets('md is 40px (default)', (tester) async {
        await tester.pumpWidget(
          buildTestWidget(const KaiAvatar.user('A')),
        );
        await tester.pump();
        expect(_hasGradientCircle(tester, 40), isTrue,
            reason: 'KaiAvatarSize.md must produce a 40px circle',);
      });

      testWidgets('lg is 56px', (tester) async {
        await tester.pumpWidget(
          buildTestWidget(const KaiAvatar.user('A', avatarSize: KaiAvatarSize.lg)),
        );
        await tester.pump();
        expect(_hasGradientCircle(tester, 56), isTrue,
            reason: 'KaiAvatarSize.lg must produce a 56px circle',);
      });
    });

    // -------------------------------------------------------------------------
    // KaiAvatar.user
    // -------------------------------------------------------------------------
    group('user ctor', () {
      testWidgets('shows the initial letter', (tester) async {
        await tester.pumpWidget(
          buildTestWidget(const KaiAvatar.user('A')),
        );
        await tester.pump();
        expect(find.text('A'), findsOneWidget);
      });

      testWidgets('uppercases the initial', (tester) async {
        await tester.pumpWidget(
          buildTestWidget(const KaiAvatar.user('z')),
        );
        await tester.pump();
        expect(find.text('Z'), findsOneWidget);
        expect(find.text('z'), findsNothing);
      });
    });

    // -------------------------------------------------------------------------
    // KaiAvatar.kai
    // -------------------------------------------------------------------------
    group('kai ctor', () {
      testWidgets('renders no initial text', (tester) async {
        await tester.pumpWidget(
          buildTestWidget(const KaiAvatar.kai()),
        );
        await tester.pump();
        expect(find.byType(Text), findsNothing);
      });

      testWidgets('renders gradientCorner circle', (tester) async {
        await tester.pumpWidget(
          buildTestWidget(const KaiAvatar.kai()),
        );
        await tester.pump();
        expect(_hasGradientCircle(tester, null), isTrue,
            reason: 'KaiAvatar.kai must render a gradientCorner circle',);
      });

      testWidgets('renders KaiGradientBar mark', (tester) async {
        await tester.pumpWidget(
          buildTestWidget(const KaiAvatar.kai()),
        );
        await tester.pump();
        expect(find.byType(KaiGradientBar), findsOneWidget,
            reason: 'KaiAvatar.kai must include the gradient bar mark',);
      });
    });

    // -------------------------------------------------------------------------
    // Breathing animation
    // -------------------------------------------------------------------------
    group('breathing', () {
      testWidgets('breathing:true builds and pumps frames without throw',
          (tester) async {
        await tester.pumpWidget(
          buildTestWidget(const KaiAvatar.user('K', breathing: true)),
        );
        // Advance several frames to exercise the animation tick path.
        await tester.pump(const Duration(milliseconds: 50));
        await tester.pump(const Duration(milliseconds: 500));
        await tester.pump(const Duration(milliseconds: 1300));
        expect(find.text('K'), findsOneWidget);
      });

      testWidgets('KaiAvatar.kai breathing:true builds without throw',
          (tester) async {
        await tester.pumpWidget(
          buildTestWidget(const KaiAvatar.kai(breathing: true)),
        );
        await tester.pump(const Duration(milliseconds: 500));
        expect(find.byType(KaiGradientBar), findsOneWidget);
      });

      testWidgets('breathing:false renders initial correctly', (tester) async {
        await tester.pumpWidget(
          buildTestWidget(const KaiAvatar.user('B')),
        );
        await tester.pump();
        expect(find.text('B'), findsOneWidget);
        // Static path — no _BreathingWrapper in the subtree.
        expect(find.byWidgetPredicate(
          (w) => w.runtimeType.toString() == '_BreathingWrapper',
        ), findsNothing,);
      });
    });
  });
}
