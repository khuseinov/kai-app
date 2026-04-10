import 'package:flutter/material.dart';

import '../../../../core/design/theme/theme_extensions.dart';
import '../../../../core/design/tokens/kai_spacing.dart';
import '../../../../core/models/chat_message.dart';

/// QW-3: Message metadata footer — shown under every Kai response bubble.
/// Displays: model name · latency · confidence · language badge · PII shield.
class MessageMetadataRow extends StatelessWidget {
  final ChatMessage message;

  const MessageMetadataRow({super.key, required this.message});

  @override
  Widget build(BuildContext context) {
    // Only show for Kai responses that have metadata
    if (message.isUser) return const SizedBox.shrink();

    final hasAnyMeta = message.model != null ||
        message.latencyMs != null ||
        message.confidence != null ||
        message.language != null ||
        message.piiBlocked == true;

    if (!hasAnyMeta) return const SizedBox.shrink();

    final colors = context.kaiColors;
    final typography = context.kaiTypography;
    final textStyle = typography.labelSmall.copyWith(
      color: colors.textTertiary,
      fontSize: 10,
    );

    return Padding(
      padding: const EdgeInsets.only(
        top: KaiSpacing.xxxs,
        left: KaiSpacing.screenPadding,
        right: KaiSpacing.screenPadding,
      ),
      child: Wrap(
        spacing: KaiSpacing.xs,
        runSpacing: 2,
        crossAxisAlignment: WrapCrossAlignment.center,
        children: [
          // QW-6: Language badge
          if (message.language != null && message.language!.isNotEmpty)
            _MetaChip(
              icon: Icons.language,
              label: message.language!.toUpperCase(),
              textStyle: textStyle,
              colors: colors,
            ),

          // Model name (abbreviated)
          if (message.model != null)
            _MetaChip(
              icon: Icons.memory_outlined,
              label: _shortModelName(message.model!),
              textStyle: textStyle,
              colors: colors,
            ),

          // Latency
          if (message.latencyMs != null)
            _MetaChip(
              icon: Icons.timer_outlined,
              label: _formatLatency(message.latencyMs!),
              textStyle: textStyle,
              colors: colors,
            ),

          // Confidence
          if (message.confidence != null)
            _MetaChip(
              icon: Icons.bar_chart_rounded,
              label: '${(message.confidence! * 100).toStringAsFixed(0)}%',
              textStyle: textStyle,
              colors: colors,
            ),

          // QW-2: PII blocked shield
          if (message.piiBlocked == true)
            Tooltip(
              message: 'Personal data was detected and protected',
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.shield_outlined, size: 10, color: colors.warning),
                  const SizedBox(width: 2),
                  Text('PII', style: textStyle.copyWith(color: colors.warning)),
                ],
              ),
            ),
        ],
      ),
    );
  }

  String _shortModelName(String model) {
    // kai-ft → KAI-FT, glm-4-flash → GLM-4
    if (model.contains('kai')) return 'KAI-FT';
    if (model.contains('glm')) return 'GLM';
    if (model.contains('deepseek')) return 'DSK';
    return model.split('-').take(2).join('-').toUpperCase();
  }

  String _formatLatency(int ms) {
    if (ms >= 1000) return '${(ms / 1000).toStringAsFixed(1)}s';
    return '${ms}ms';
  }
}

class _MetaChip extends StatelessWidget {
  final IconData icon;
  final String label;
  final TextStyle textStyle;
  final dynamic colors;

  const _MetaChip({
    required this.icon,
    required this.label,
    required this.textStyle,
    required this.colors,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, size: 10, color: colors.textTertiary),
        const SizedBox(width: 2),
        Text(label, style: textStyle),
      ],
    );
  }
}
