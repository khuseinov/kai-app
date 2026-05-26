import 'package:flutter/material.dart';
import 'package:flutter_markdown/flutter_markdown.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:kai_app/design_system/atoms/kai_bubble.dart';
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
  testWidgets('KaiBubble.user renders the content', (tester) async {
    await _pump(tester, const KaiBubble.user('hello'));
    expect(find.text('hello'), findsOneWidget);
  });

  testWidgets('KaiBubble.system renders content centered', (tester) async {
    await _pump(tester, const KaiBubble.system('Kai is waking up'));
    expect(find.text('Kai is waking up'), findsOneWidget);
    expect(find.byType(Center), findsWidgets);
  });

  testWidgets('KaiBubble.kai renders a MarkdownBody', (tester) async {
    await _pump(
      tester,
      const KaiBubble.kai('**bold** and _italic_'),
    );
    expect(find.byType(MarkdownBody), findsOneWidget);
  });

  testWidgets('KaiBubble.kai parses simple markdown text', (tester) async {
    await _pump(tester, const KaiBubble.kai('hello world'));
    // The MarkdownBody renders paragraphs through RichText — assert via
    // the MarkdownBody widget's data prop.
    final md = tester.widget<MarkdownBody>(find.byType(MarkdownBody));
    expect(md.data, 'hello world');
  });
}
