import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:kai_app/design_system/atoms/kai_icon.dart';
import 'package:kai_app/design_system/theme/kai_theme.dart';
import 'package:kai_app/design_system/tokens/kai_tokens.dart';

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
  testWidgets('KaiIcon renders SvgPicture with default 18 size', (tester) async {
    await _pump(tester, const KaiIcon(KaiIconName.send));
    final svg = tester.widget<SvgPicture>(find.byType(SvgPicture));
    expect(svg.width, 18);
    expect(svg.height, 18);
  });

  testWidgets('KaiIcon applies custom size', (tester) async {
    await _pump(tester, const KaiIcon(KaiIconName.mic, size: 32));
    final svg = tester.widget<SvgPicture>(find.byType(SvgPicture));
    expect(svg.width, 32);
    expect(svg.height, 32);
  });

  testWidgets('KaiIcon defaults to ink2 from theme when no color override',
      (tester) async {
    await _pump(tester, const KaiIcon(KaiIconName.heart));
    final svg = tester.widget<SvgPicture>(find.byType(SvgPicture));
    expect(svg.colorFilter,
        ColorFilter.mode(KaiColors.light.ink2, BlendMode.srcIn));
  });

  testWidgets('KaiIcon honors explicit color override', (tester) async {
    await _pump(
      tester,
      const KaiIcon(KaiIconName.plus, color: Color(0xFFFF0000)),
    );
    final svg = tester.widget<SvgPicture>(find.byType(SvgPicture));
    expect(svg.colorFilter,
        const ColorFilter.mode(Color(0xFFFF0000), BlendMode.srcIn));
  });

  testWidgets('all KaiIconName values have a defined assetName',
      (tester) async {
    expect(KaiIconName.values.length, 22);
    for (final n in KaiIconName.values) {
      expect(n.assetName, isNotEmpty);
    }
  });
}
