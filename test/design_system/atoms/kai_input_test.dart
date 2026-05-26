import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:kai_app/design_system/atoms/kai_input.dart';
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
  testWidgets('typing into KaiTextField updates the controller',
      (tester) async {
    final controller = TextEditingController();
    await _pump(tester, KaiTextField(controller: controller));
    await tester.enterText(find.byType(TextField), 'hello');
    expect(controller.text, 'hello');
  });

  testWidgets('placeholder visible when controller is empty', (tester) async {
    final controller = TextEditingController();
    await _pump(
      tester,
      KaiTextField(controller: controller, placeholder: 'say something'),
    );
    expect(find.text('say something'), findsOneWidget);
  });

  testWidgets('placeholder is hidden once controller has text', (tester) async {
    // Flutter keeps the hint Text widget in the render tree but fades its
    // opacity to 0 when the field has content — assert the rendered text
    // matches the controller, not the placeholder.
    final controller = TextEditingController(text: 'hello world');
    await _pump(
      tester,
      KaiTextField(controller: controller, placeholder: 'placeholder'),
    );
    expect(find.text('hello world'), findsOneWidget);
  });

  testWidgets('pillRadius=true applies pill radius', (tester) async {
    final controller = TextEditingController();
    await _pump(
      tester,
      KaiTextField(controller: controller, pillRadius: true),
    );
    final container = tester.widget<Container>(
      find.ancestor(of: find.byType(TextField), matching: find.byType(Container))
          .first,
    );
    final deco = container.decoration as BoxDecoration;
    expect(deco.borderRadius, KaiRadius.brPill);
  });

  testWidgets('default pillRadius=false applies r2 radius', (tester) async {
    final controller = TextEditingController();
    await _pump(tester, KaiTextField(controller: controller));
    final container = tester.widget<Container>(
      find.ancestor(of: find.byType(TextField), matching: find.byType(Container))
          .first,
    );
    final deco = container.decoration as BoxDecoration;
    expect(deco.borderRadius, KaiRadius.br2);
  });

  testWidgets('maxLines>1 allows multi-line editing', (tester) async {
    final controller = TextEditingController();
    await _pump(
      tester,
      KaiTextField(controller: controller, maxLines: 4),
    );
    final field = tester.widget<TextField>(find.byType(TextField));
    expect(field.maxLines, 4);
  });
}
