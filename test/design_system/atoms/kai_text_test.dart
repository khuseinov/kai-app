import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:kai_app/design_system/atoms/kai_text.dart';
import 'package:kai_app/design_system/theme/kai_theme.dart';

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
  testWidgets('KaiText.body renders Text with 16/400', (tester) async {
    await _pump(tester, const KaiText.body('hello'));
    final text = tester.widget<Text>(find.text('hello'));
    expect(text.style?.fontSize, 16);
    expect(text.style?.fontWeight, FontWeight.w400);
    expect(text.style?.fontFamily, 'Manrope');
  });

  testWidgets('KaiText.hero renders Text with 72/600', (tester) async {
    await _pump(tester, const KaiText.hero('big'));
    final text = tester.widget<Text>(find.text('big'));
    expect(text.style?.fontSize, 72);
    expect(text.style?.fontWeight, FontWeight.w600);
  });

  testWidgets('KaiText.mono uses JetBrainsMono', (tester) async {
    await _pump(tester, const KaiText.mono('code()'));
    final text = tester.widget<Text>(find.text('code()'));
    expect(text.style?.fontFamily, 'JetBrainsMono');
    expect(text.style?.fontSize, 12);
  });

  testWidgets('KaiText respects explicit color override', (tester) async {
    await _pump(
      tester,
      const KaiText.body('colored', color: Color(0xFFFF0000)),
    );
    final text = tester.widget<Text>(find.text('colored'));
    expect(text.style?.color, const Color(0xFFFF0000));
  });
}
