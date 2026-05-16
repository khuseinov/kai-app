import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_markdown/flutter_markdown.dart';
import 'package:kai_app/core/design/theme/app_theme.dart';
import 'package:kai_app/core/models/tool_source.dart';
import 'package:kai_app/features/country/domain/country_tool_result.dart';
import 'package:kai_app/features/country/presentation/widgets/tool_result_card.dart';

Widget _wrap(CountryToolResult result) => MaterialApp(
      theme: AppTheme.light,
      home: Scaffold(body: ToolResultCard(result: result)),
    );

void main() {
  // ── APP-D3 (ToolResultCard) ───────────────────────────────────────────────

  testWidgets('ToolResultCard renders markdown content', (tester) async {
    const result = CountryToolResult(content: 'Виза **не требуется**.');
    await tester.pumpWidget(_wrap(result));
    await tester.pumpAndSettle();

    expect(find.byType(MarkdownBody), findsOneWidget);
    expect(find.textContaining('Виза'), findsOneWidget);
  });

  testWidgets('ToolResultCard hides source section when sources empty',
      (tester) async {
    const result = CountryToolResult(content: 'Данные.', sources: []);
    await tester.pumpWidget(_wrap(result));
    await tester.pumpAndSettle();

    expect(find.byType(Divider), findsNothing);
  });

  testWidgets('ToolResultCard shows divider when sources present',
      (tester) async {
    final result = CountryToolResult(
      content: 'Данные.',
      sources: [
        ToolSource(
          tool: 'visa_checker',
          source: 'mfa.gov.ru',
          sourceDisplayName: 'МИД России',
        ),
      ],
    );
    await tester.pumpWidget(_wrap(result));
    await tester.pumpAndSettle();

    expect(find.byType(Divider), findsOneWidget);
  });

  testWidgets('ToolResultCard renders multiple lines of markdown',
      (tester) async {
    const result = CountryToolResult(
      content: '## Виза\n\nНе требуется до 30 дней.\n\n- Паспорт\n- Обратный билет',
    );
    await tester.pumpWidget(_wrap(result));
    await tester.pumpAndSettle();

    expect(find.byType(MarkdownBody), findsOneWidget);
    expect(find.textContaining('Виза'), findsOneWidget);
  });
}
