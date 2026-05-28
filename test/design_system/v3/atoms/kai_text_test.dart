import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:kai_app/design_system/theme/kai_theme.dart';
import 'package:kai_app/design_system/v3/atoms/kai_text.dart';

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
  group('v3/KaiText', () {
    testWidgets('hero renders a Text widget', (tester) async {
      await _pump(tester, const KaiText.hero('Hello'));
      expect(find.text('Hello'), findsOneWidget);
    });

    testWidgets('display renders a Text widget', (tester) async {
      await _pump(tester, const KaiText.display('Display'));
      expect(find.text('Display'), findsOneWidget);
    });

    testWidgets('h1 renders a Text widget', (tester) async {
      await _pump(tester, const KaiText.h1('H1'));
      expect(find.text('H1'), findsOneWidget);
    });

    testWidgets('h2 renders a Text widget', (tester) async {
      await _pump(tester, const KaiText.h2('H2'));
      expect(find.text('H2'), findsOneWidget);
    });

    testWidgets('h3 renders a Text widget', (tester) async {
      await _pump(tester, const KaiText.h3('H3'));
      expect(find.text('H3'), findsOneWidget);
    });

    testWidgets('lead renders a Text widget', (tester) async {
      await _pump(tester, const KaiText.lead('Lead'));
      expect(find.text('Lead'), findsOneWidget);
    });

    testWidgets('body renders a Text widget', (tester) async {
      await _pump(tester, const KaiText.body('Body'));
      expect(find.text('Body'), findsOneWidget);
    });

    testWidgets('small renders a Text widget', (tester) async {
      await _pump(tester, const KaiText.small('Small'));
      expect(find.text('Small'), findsOneWidget);
    });

    testWidgets('micro renders a Text widget', (tester) async {
      await _pump(tester, const KaiText.micro('Micro'));
      expect(find.text('Micro'), findsOneWidget);
    });

    testWidgets('mono renders a Text widget', (tester) async {
      await _pump(tester, const KaiText.mono('Mono'));
      expect(find.text('Mono'), findsOneWidget);
    });

    testWidgets('hero without gradient renders plain Text (no ShaderMask)',
        (tester) async {
      await _pump(tester, const KaiText.hero('Plain'));
      expect(find.byType(ShaderMask), findsNothing);
    });

    testWidgets('hero with gradient:true wraps in ShaderMask', (tester) async {
      await _pump(tester, const KaiText.hero('Grad', gradient: true));
      expect(find.byType(ShaderMask), findsOneWidget);
      expect(find.text('Grad'), findsOneWidget);
    });

    testWidgets('display with gradient:true wraps in ShaderMask', (tester) async {
      await _pump(tester, const KaiText.display('Grad', gradient: true));
      expect(find.byType(ShaderMask), findsOneWidget);
    });

    testWidgets('h1 with gradient:true wraps in ShaderMask', (tester) async {
      await _pump(tester, const KaiText.h1('Grad', gradient: true));
      expect(find.byType(ShaderMask), findsOneWidget);
    });

    testWidgets('h2 with gradient:true wraps in ShaderMask', (tester) async {
      await _pump(tester, const KaiText.h2('Grad', gradient: true));
      expect(find.byType(ShaderMask), findsOneWidget);
    });

    testWidgets('h3 with gradient:true wraps in ShaderMask', (tester) async {
      await _pump(tester, const KaiText.h3('Grad', gradient: true));
      expect(find.byType(ShaderMask), findsOneWidget);
    });

    testWidgets('body does not support gradient param (plain Text)',
        (tester) async {
      // body/small/micro/mono do not have the gradient parameter — they always
      // render as plain Text.
      await _pump(tester, const KaiText.body('BodyText'));
      expect(find.byType(ShaderMask), findsNothing);
      expect(find.text('BodyText'), findsOneWidget);
    });

    testWidgets('explicit color override is forwarded to text style',
        (tester) async {
      const testColor = Color(0xFFFF4500);
      await _pump(
        tester,
        const KaiText.body('Colored', color: testColor),
      );
      final textWidget = tester.widget<Text>(find.text('Colored'));
      expect(textWidget.style?.color, testColor);
    });

    testWidgets('textAlign is forwarded to Text widget', (tester) async {
      await _pump(
        tester,
        const KaiText.body('Aligned', textAlign: TextAlign.center),
      );
      final textWidget = tester.widget<Text>(find.text('Aligned'));
      expect(textWidget.textAlign, TextAlign.center);
    });
  });
}
