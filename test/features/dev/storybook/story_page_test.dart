import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:kai_app/features/dev/storybook/story_page.dart';
import '../../../test_helpers.dart';

void main() {
  testWidgets('StoryPage renders title, blurb, a labelled cell, a prop row',
      (t) async {
    await t.pumpWidget(buildTestWidget(const StoryPage(
      title: 'KaiButton',
      layer: 'ATOM',
      blurb: 'Primary action button.',
      sections: [
        StorySection('Variants', [StoryCell('tide', Text('btn'))])
      ],
      usage: 'KaiButton.tide(label: ..., onPressed: ...)',
      props: [PropDoc('label', 'String', 'required', 'Button text')],
    )));
    expect(find.text('KaiButton'), findsOneWidget);
    expect(find.text('Primary action button.'), findsOneWidget);
    expect(find.text('tide'), findsOneWidget); // cell caption
    expect(find.text('btn'), findsOneWidget); // cell child
    expect(find.text('Variants'), findsOneWidget); // section header
    expect(find.text('label'), findsOneWidget); // prop row
  });
}
