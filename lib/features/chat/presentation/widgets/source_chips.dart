import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../../../core/design/theme/theme_extensions.dart';
import '../../../../core/design/tokens/kai_spacing.dart';
import '../../../../core/models/tool_source.dart';

/// APP-A1 / APP-TOOL-PROV-1: Tool source provenance chips.
///
/// Shown below the Kai response when the backend returns sources[].
/// Each chip displays the tool name, source URL/key, and fetched timestamp.
/// Color-codes freshness: neutral → stale (within 24h) → expired.
class SourceChips extends StatelessWidget {
  final List<ToolSource> sources;

  const SourceChips({super.key, required this.sources});

  @override
  Widget build(BuildContext context) {
    if (sources.isEmpty) return const SizedBox.shrink();

    // BUG-DUP-CHIPS-1 (2026-05-16): backend reports one source per tool fire,
    // and Kai often fires the same tool multiple times (cache hits / retry
    // loops), so a single Kai response can list visa_checker 3-4 times. Show
    // each unique (tool, source) pair once. Order preserved (first occurrence).
    final seenKeys = <String>{};
    final unique = <ToolSource>[];
    for (final s in sources) {
      final key = '${s.tool}|${s.source}';
      if (seenKeys.add(key)) {
        unique.add(s);
      }
    }

    return Wrap(
      spacing: KaiSpacing.xxs,
      runSpacing: KaiSpacing.xxs,
      children: unique.map((s) => _SourceChip(source: s)).toList(),
    );
  }
}

class _SourceChip extends StatelessWidget {
  final ToolSource source;

  const _SourceChip({required this.source});

  Color _freshnessColor(BuildContext context) {
    final colors = context.kaiColors;
    final now = DateTime.now();

    // expires_at takes precedence when present
    final expiresAt = source.expiresAt;
    if (expiresAt != null) {
      final expiry = DateTime.tryParse(expiresAt);
      if (expiry != null) {
        if (expiry.isBefore(now)) return colors.error;
        if (expiry.difference(now).inDays < 7) return colors.warning;
        return colors.textTertiary;
      }
    }

    // Fall back to fetched_at age when expires_at is absent
    final fetchedAt = source.fetchedAt;
    if (fetchedAt != null) {
      final fetched = DateTime.tryParse(fetchedAt);
      if (fetched != null && now.difference(fetched).inDays > 30) {
        return colors.warning;
      }
    }

    return colors.textTertiary;
  }

  String _fetchedLabel() {
    final fetchedAt = source.fetchedAt;
    if (fetchedAt == null) return '';
    final dt = DateTime.tryParse(fetchedAt);
    if (dt == null) return '';
    final local = dt.toLocal();
    return '${local.hour.toString().padLeft(2, '0')}:${local.minute.toString().padLeft(2, '0')}';
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.kaiColors;
    final typography = context.kaiTypography;
    final chipColor = _freshnessColor(context);
    final label = source.sourceDisplayName ?? source.source;
    final timeLabel = _fetchedLabel();

    return GestureDetector(
      onLongPress: () => _showDetailSheet(context),
      child: Tooltip(
        triggerMode: TooltipTriggerMode.tap,
        message: '${source.tool} · ${source.source}'
            '${source.fetchedAt != null ? "\nПолучено: ${source.fetchedAt}" : ""}'
            '${source.stalenessNote != null ? "\n${source.stalenessNote}" : ""}',
        child: Container(
        padding: const EdgeInsets.symmetric(
          horizontal: KaiSpacing.xs,
          vertical: KaiSpacing.xxxs,
        ),
        decoration: BoxDecoration(
          color: chipColor.withValues(alpha: 0.08),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: chipColor.withValues(alpha: 0.35)),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.schedule_outlined, size: 11, color: chipColor),
            const SizedBox(width: 4),
            Text(
              label,
              style: typography.labelSmall.copyWith(
                color: chipColor,
                fontSize: 11,
              ),
            ),
            if (timeLabel.isNotEmpty) ...[
              const SizedBox(width: 3),
              Text(
                timeLabel,
                style: typography.labelSmall.copyWith(
                  color: colors.textTertiary,
                  fontSize: 10,
                ),
              ),
            ],
          ],
        ),
      ),
    ),
    );
  }

  void _showDetailSheet(BuildContext context) {
    showModalBottomSheet<void>(
      context: context,
      builder: (_) => _StalenessDetailSheet(source: source),
    );
  }
}

class _StalenessDetailSheet extends StatelessWidget {
  final ToolSource source;

  const _StalenessDetailSheet({required this.source});

  static String _formatDate(String? isoString) {
    if (isoString == null) return '—';
    final dt = DateTime.tryParse(isoString);
    if (dt == null) return isoString;
    final local = dt.toLocal();
    return '${local.day.toString().padLeft(2, '0')}.${local.month.toString().padLeft(2, '0')}.${local.year}'
        ' ${local.hour.toString().padLeft(2, '0')}:${local.minute.toString().padLeft(2, '0')}';
  }

  @override
  Widget build(BuildContext context) {
    final typography = context.kaiTypography;
    final colors = context.kaiColors;

    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.all(KaiSpacing.l),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              source.sourceDisplayName ?? source.source,
              style: typography.titleMedium,
            ),
            const SizedBox(height: KaiSpacing.xs),
            _Row('Инструмент:', source.tool, typography, colors),
            _Row('Источник:', source.source, typography, colors),
            _Row('Получено:', _formatDate(source.fetchedAt), typography, colors),
            _Row('Действует до:', _formatDate(source.expiresAt), typography, colors),
            if (source.stalenessNote != null) ...[
              const SizedBox(height: KaiSpacing.xs),
              Text(
                source.stalenessNote!,
                style: typography.bodySmall.copyWith(
                  color: colors.warning,
                  fontStyle: FontStyle.italic,
                ),
              ),
            ],
            const SizedBox(height: KaiSpacing.m),
            OutlinedButton.icon(
              onPressed: () {
                // Copy source URL to clipboard
                // ignore: deprecated_member_use
                final data = ClipboardData(text: source.source);
                Clipboard.setData(data);
                Navigator.of(context).pop();
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Скопировано'),
                    duration: Duration(seconds: 2),
                    behavior: SnackBarBehavior.floating,
                  ),
                );
              },
              icon: const Icon(Icons.copy_outlined, size: 16),
              label: const Text('Копировать источник'),
            ),
          ],
        ),
      ),
    );
  }
}

class _Row extends StatelessWidget {
  final String label;
  final String value;
  final dynamic typography;
  final dynamic colors;

  const _Row(this.label, this.value, this.typography, this.colors);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 2),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 110,
            child: Text(
              label,
              style: typography.bodySmall.copyWith(color: colors.textTertiary),
            ),
          ),
          Expanded(
            child: Text(value, style: typography.bodySmall),
          ),
        ],
      ),
    );
  }
}
