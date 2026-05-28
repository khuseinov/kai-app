import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:kai_app/design_system/theme/kai_theme.dart';
import 'package:kai_app/design_system/tokens/kai_tokens.dart';
import 'package:kai_app/design_system/primitives/kai_icon.dart';

Future<void> _pump(WidgetTester tester, Widget child) async {
  await tester.pumpWidget(
    ProviderScope(
      child: MaterialApp(
        home: KaiTheme(
          child: Scaffold(body: child),
        ),
      ),
    ),
  );
  await tester.pump();
}

void main() {
  group('v3/KaiIcon', () {
    testWidgets('renders an SvgPicture for a given KaiIconName', (tester) async {
      await _pump(tester, const KaiIcon(KaiIconName.send));
      expect(find.byType(SvgPicture), findsOneWidget);
    });

    testWidgets('default size is 18', (tester) async {
      await _pump(tester, const KaiIcon(KaiIconName.mic));
      final svg = tester.widget<SvgPicture>(find.byType(SvgPicture));
      expect(svg.width, 18.0);
      expect(svg.height, 18.0);
    });

    testWidgets('custom size is applied', (tester) async {
      await _pump(tester, const KaiIcon(KaiIconName.menu, size: 24));
      final svg = tester.widget<SvgPicture>(find.byType(SvgPicture));
      expect(svg.width, 24.0);
      expect(svg.height, 24.0);
    });

    testWidgets('defaults to ink2 theme color when no color override',
        (tester) async {
      await _pump(tester, const KaiIcon(KaiIconName.heart));
      final svg = tester.widget<SvgPicture>(find.byType(SvgPicture));
      expect(
        svg.colorFilter,
        ColorFilter.mode(KaiColors.light.ink2, BlendMode.srcIn),
      );
    });

    testWidgets('explicit color override is applied', (tester) async {
      await _pump(
        tester,
        const KaiIcon(KaiIconName.close, color: Color(0xFFFF0000)),
      );
      final svg = tester.widget<SvgPicture>(find.byType(SvgPicture));
      expect(
        svg.colorFilter,
        const ColorFilter.mode(Color(0xFFFF0000), BlendMode.srcIn),
      );
    });

    test('all KaiIconName values have a non-empty assetName', () {
      expect(KaiIconName.values.length, 32); // +2: thumbUp, thumbDown (v3 W2)
      for (final icon in KaiIconName.values) {
        expect(icon.assetName, isNotEmpty);
      }
    });

    test('assetName maps are correct for spot-check values', () {
      expect(KaiIconName.arrowUp.assetName, 'arrow-up');
      expect(KaiIconName.chevRight.assetName, 'chev-right');
      expect(KaiIconName.wifiOff.assetName, 'wifi-off');
      expect(KaiIconName.logout.assetName, 'logout');
      expect(KaiIconName.thumbUp.assetName, 'thumb-up');
      expect(KaiIconName.thumbDown.assetName, 'thumb-down');
    });
  });
}
