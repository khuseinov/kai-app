import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../../../core/design/theme/theme_extensions.dart';
import '../../../../core/design/tokens/kai_spacing.dart';
import '../../../../core/models/tool_source.dart';

/// Tap-to-expand source preview invoked when the user taps an inline
/// citation marker [1] [2] in a Kai message.
class CitationSheet extends StatelessWidget {
  final int number;
  final ToolSource source;

  const CitationSheet({super.key, required this.number, required this.source});

  static void show(BuildContext context, int number, ToolSource source) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (_) => CitationSheet(number: number, source: source),
    );
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.kaiColors;
    final typography = context.kaiTypography;
    final name = source.sourceDisplayName ?? source.source;

    String? _freshnessLabel() {
      if (source.expiresAt == null) return null;
      try {
        final exp = DateTime.parse(source.expiresAt!);
        final diff = exp.difference(DateTime.now());
        if (diff.isNegative) return 'Источник устарел';
        if (diff.inDays <= 7) return 'Истекает через ${diff.inDays} дн.';
        return null;
      } catch (_) {
        return null;
      }
    }

    final freshness = _freshnessLabel();

    return Container(
      decoration: BoxDecoration(
        color: colors.surface,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
      ),
      padding: const EdgeInsets.fromLTRB(
        KaiSpacing.l,
        KaiSpacing.s,
        KaiSpacing.l,
        KaiSpacing.xl,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Center(
            child: Container(
              width: 36,
              height: 4,
              margin: const EdgeInsets.only(bottom: KaiSpacing.m),
              decoration: BoxDecoration(
                color: colors.cloudLight,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          ),
          Row(
            children: [
              Container(
                width: 28,
                height: 28,
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  color: colors.oceanPrimary.withValues(alpha: 0.1),
                  shape: BoxShape.circle,
                ),
                child: Text(
                  '$number',
                  style: typography.labelMedium.copyWith(
                    color: colors.oceanPrimary,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              const SizedBox(width: KaiSpacing.s),
              Expanded(
                child: Text(
                  name,
                  style: typography.headlineSmall.copyWith(
                    color: colors.textPrimary,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: KaiSpacing.s),
          GestureDetector(
            onTap: () {
              Clipboard.setData(ClipboardData(text: source.source));
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Ссылка скопирована'),
                  duration: Duration(seconds: 1),
                  behavior: SnackBarBehavior.floating,
                ),
              );
            },
            child: Text(
              source.source,
              style: typography.bodyMedium.copyWith(
                color: colors.oceanPrimary,
                decoration: TextDecoration.underline,
                decorationColor: colors.oceanPrimary,
              ),
            ),
          ),
          if (source.fetchedAt != null) ...[
            const SizedBox(height: KaiSpacing.xs),
            _InfoRow(
              icon: Icons.access_time_rounded,
              text: 'Получено: ${_formatDate(source.fetchedAt!)}',
              colors: colors,
              typography: typography,
            ),
          ],
          if (freshness != null) ...[
            const SizedBox(height: KaiSpacing.xxs),
            _InfoRow(
              icon: Icons.warning_amber_rounded,
              text: freshness,
              colors: colors,
              typography: typography,
              color: colors.warning,
            ),
          ],
          if (source.stalenessNote != null) ...[
            const SizedBox(height: KaiSpacing.xs),
            Text(
              source.stalenessNote!,
              style: typography.bodySmall.copyWith(
                color: colors.textTertiary,
                fontStyle: FontStyle.italic,
              ),
            ),
          ],
        ],
      ),
    );
  }

  static String _formatDate(String iso) {
    try {
      final dt = DateTime.parse(iso).toLocal();
      return '${dt.day}.${dt.month.toString().padLeft(2, '0')}.${dt.year} '
          '${dt.hour.toString().padLeft(2, '0')}:${dt.minute.toString().padLeft(2, '0')}';
    } catch (_) {
      return iso;
    }
  }
}

class _InfoRow extends StatelessWidget {
  final IconData icon;
  final String text;
  final dynamic colors;
  final dynamic typography;
  final Color? color;

  const _InfoRow({
    required this.icon,
    required this.text,
    required this.colors,
    required this.typography,
    this.color,
  });

  @override
  Widget build(BuildContext context) {
    final c = color ?? (colors.textTertiary as Color);
    return Row(
      children: [
        Icon(icon, size: 13, color: c),
        const SizedBox(width: 4),
        Text(
          text,
          style: (typography.labelSmall as TextStyle).copyWith(color: c),
        ),
      ],
    );
  }
}
