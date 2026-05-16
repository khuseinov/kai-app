import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:kai_app/core/design/theme/app_theme.dart';
import 'package:kai_app/core/models/tool_source.dart';
import 'package:kai_app/features/chat/presentation/widgets/source_chips.dart';

Widget _wrap(Widget child) => MaterialApp(
      theme: AppTheme.light,
      home: Scaffold(body: child),
    );

void main() {
  testWidgets('SourceChips renders nothing for empty sources', (tester) async {
    await tester.pumpWidget(_wrap(const SourceChips(sources: [])));
    expect(find.byIcon(Icons.schedule_outlined), findsNothing);
  });

  testWidgets('SourceChips renders one chip for a source with future expiry',
      (tester) async {
    final future = DateTime.now().add(const Duration(days: 7));
    final sources = [
      ToolSource(
        tool: 'visa_checker',
        source: 'govuk.com',
        sourceDisplayName: 'GOV.UK',
        fetchedAt: DateTime.now().toIso8601String(),
        expiresAt: future.toIso8601String(),
      ),
    ];

    await tester.pumpWidget(_wrap(SourceChips(sources: sources)));
    expect(find.text('GOV.UK'), findsOneWidget);
    expect(find.byIcon(Icons.schedule_outlined), findsOneWidget);
  });

  testWidgets(
      'SourceChips dedupes identical (tool, source) pairs (BUG-DUP-CHIPS-1)',
      (tester) async {
    // Backend reports the same tool firing 4 times (cache hits + retries).
    // The mobile UI must show ONE chip per unique (tool, source) pair.
    const sources = [
      ToolSource(tool: 'visa_checker', source: 'kg_visa_rules'),
      ToolSource(tool: 'visa_checker', source: 'kg_visa_rules'),
      ToolSource(tool: 'visa_checker', source: 'kg_visa_rules'),
      ToolSource(tool: 'visa_checker', source: 'kg_visa_rules'),
    ];
    await tester.pumpWidget(_wrap(const SourceChips(sources: sources)));
    expect(find.text('kg_visa_rules'), findsOneWidget);
  });

  testWidgets('SourceChips keeps distinct (tool, source) pairs',
      (tester) async {
    const sources = [
      ToolSource(tool: 'visa_checker', source: 'kg_visa_rules'),
      ToolSource(tool: 'health_requirements', source: 'kg_health'),
      ToolSource(tool: 'visa_checker', source: 'kg_visa_rules'),
    ];
    await tester.pumpWidget(_wrap(const SourceChips(sources: sources)));
    expect(find.text('kg_visa_rules'), findsOneWidget);
    expect(find.text('kg_health'), findsOneWidget);
  });

  testWidgets('SourceChips falls back to source when sourceDisplayName is null',
      (tester) async {
    final sources = [
      const ToolSource(
        tool: 'risk_assessment',
        source: 'travel.state.gov',
      ),
    ];

    await tester.pumpWidget(_wrap(SourceChips(sources: sources)));
    expect(find.text('travel.state.gov'), findsOneWidget);
  });

  testWidgets('SourceChips renders two chips for two sources', (tester) async {
    final sources = [
      const ToolSource(tool: 'visa_checker', source: 'govuk.com'),
      const ToolSource(tool: 'risk_assessment', source: 'state.gov'),
    ];

    await tester.pumpWidget(_wrap(SourceChips(sources: sources)));
    expect(find.byIcon(Icons.schedule_outlined), findsNWidgets(2));
  });

  testWidgets('SourceChips uses error color for expired source',
      (tester) async {
    final past = DateTime.now().subtract(const Duration(hours: 1));
    final sources = [
      ToolSource(
        tool: 'visa_checker',
        source: 'govuk.com',
        sourceDisplayName: 'GOV.UK',
        expiresAt: past.toIso8601String(),
      ),
    ];

    await tester.pumpWidget(_wrap(SourceChips(sources: sources)));
    expect(find.text('GOV.UK'), findsOneWidget);
  });

  // ── APP-FRESHNESS-1 ────────────────────────────────────────────────────────

  testWidgets('SourceChip renders warning for source expiring within 7 days',
      (tester) async {
    final soonExpiry = DateTime.now().add(const Duration(days: 3));
    final sources = [
      ToolSource(
        tool: 'cost_estimator',
        source: 'numbeo.com',
        sourceDisplayName: 'Numbeo',
        expiresAt: soonExpiry.toIso8601String(),
      ),
    ];

    await tester.pumpWidget(_wrap(SourceChips(sources: sources)));
    expect(find.text('Numbeo'), findsOneWidget);
  });

  testWidgets('SourceChip renders warning for fetched_at older than 30 days',
      (tester) async {
    final oldFetch = DateTime.now().subtract(const Duration(days: 45));
    final sources = [
      ToolSource(
        tool: 'cost_estimator',
        source: 'numbeo.com',
        sourceDisplayName: 'Numbeo',
        fetchedAt: oldFetch.toIso8601String(),
        // no expiresAt — falls back to fetched_at age check
      ),
    ];

    await tester.pumpWidget(_wrap(SourceChips(sources: sources)));
    expect(find.text('Numbeo'), findsOneWidget);
  });

  testWidgets('SourceChip shows staleness note in tooltip when present',
      (tester) async {
    const sources = [
      ToolSource(
        tool: 'cost_estimator',
        source: 'numbeo.com',
        sourceDisplayName: 'Numbeo',
        stalenessNote: 'Данные за 2025 год. Уточняйте на numbeo.com.',
      ),
    ];

    await tester.pumpWidget(_wrap(const SourceChips(sources: sources)));
    expect(find.text('Numbeo'), findsOneWidget);
  });

  // ── APP-STALENESS-1 ────────────────────────────────────────────────────────

  testWidgets('long-press chip opens detail bottom sheet', (tester) async {
    final sources = [
      ToolSource(
        tool: 'cost_estimator',
        source: 'numbeo.com',
        sourceDisplayName: 'Numbeo',
        fetchedAt: '2026-05-16T10:00:00Z',
        expiresAt: '2026-06-16T10:00:00Z',
        stalenessNote: 'Данные за 2025 год.',
      ),
    ];

    await tester.pumpWidget(_wrap(SourceChips(sources: sources)));
    await tester.longPress(find.text('Numbeo'));
    await tester.pumpAndSettle();

    // Bottom sheet appears with source detail
    expect(find.text('Инструмент:'), findsOneWidget);
    expect(find.text('Источник:'), findsOneWidget);
    expect(find.text('Получено:'), findsOneWidget);
    expect(find.text('Действует до:'), findsOneWidget);
    expect(find.text('Данные за 2025 год.'), findsOneWidget);
    expect(find.text('Копировать источник'), findsOneWidget);
  });
}
