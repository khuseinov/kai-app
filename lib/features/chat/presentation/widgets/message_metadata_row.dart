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
        message.piiBlocked == true ||
        _autonomousModeChip(message.requestType, context.kaiColors) != null ||
        message.executedToolCalls.isNotEmpty ||
        (message.worldModelUsed == true && (message.kgNodesQueried ?? 0) > 0) ||
        (message.revisionCount ?? 0) > 0;

    if (!hasAnyMeta) return const SizedBox.shrink();

    final colors = context.kaiColors;
    final typography = context.kaiTypography;
    final textStyle = typography.labelSmall.copyWith(
      color: colors.textTertiary,
      fontSize: 10,
    );

    final modeChip = _autonomousModeChip(message.requestType, colors);

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
          // Autonomous depth signal: Kai itself picks request_type via
          // classify_request_type (kai-core/src/cognitive/action/classifier.py).
          // Only render when Kai escalated past the default — silent for
          // fast/standard so the metadata row stays uncluttered.
          if (modeChip != null)
            _ColoredMetaChip(
              icon: modeChip.icon,
              label: modeChip.label,
              color: modeChip.color,
              baseStyle: textStyle,
            ),

          // BE-AUT-1: Tool calls — show which tools Kai actually fired
          for (final tool in message.executedToolCalls)
            _ColoredMetaChip(
              icon: Icons.handyman_outlined,
              label: tool.replaceAll('_', ' '),
              color: colors.oceanPrimary,
              baseStyle: textStyle,
            ),

          // BE-AUT-2: World model grounding — KG nodes fetched in P-step
          if (message.worldModelUsed == true &&
              (message.kgNodesQueried ?? 0) > 0)
            _MetaChip(
              icon: Icons.travel_explore_outlined,
              label: 'база знаний (${message.kgNodesQueried})',
              textStyle: textStyle,
              colors: colors,
            ),

          // BE-AUT-3: Revision — Kai re-checked its answer after critique failure
          if ((message.revisionCount ?? 0) > 0)
            _MetaChip(
              icon: Icons.verified_outlined,
              label: 'перепроверено',
              textStyle: textStyle,
              colors: colors,
            ),

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

  /// Maps Kai's autonomous request_type pick to a small icon+label chip.
  /// Returns null for the default tiers (fast/standard) so the row stays
  /// uncluttered — Kai escalating to ORCHESTRATOR/REASONING/HEAVY/SENSITIVE
  /// is the interesting signal worth surfacing.
  static _ModeBadge? _autonomousModeChip(String? type, dynamic colors) {
    if (type == null || type.isEmpty) return null;
    switch (type.toLowerCase()) {
      case 'orchestrator':
        return _ModeBadge(
          icon: Icons.handyman_outlined,
          label: 'инструменты',
          color: colors.oceanPrimary as Color,
        );
      case 'reasoning':
      case 'heavy':
        return _ModeBadge(
          icon: Icons.psychology_alt_outlined,
          label: 'глубокий разбор',
          color: colors.stateThinking as Color,
        );
      case 'sensitive':
        return _ModeBadge(
          icon: Icons.shield_moon_outlined,
          label: 'безопасный режим',
          color: colors.warning as Color,
        );
      case 'multimodal':
        return _ModeBadge(
          icon: Icons.image_outlined,
          label: 'мультимодально',
          color: colors.oceanPrimary as Color,
        );
      // fast / standard — default path, no chip.
      default:
        return null;
    }
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

class _ModeBadge {
  final IconData icon;
  final String label;
  final Color color;

  const _ModeBadge({
    required this.icon,
    required this.label,
    required this.color,
  });
}

class _ColoredMetaChip extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color color;
  final TextStyle baseStyle;

  const _ColoredMetaChip({
    required this.icon,
    required this.label,
    required this.color,
    required this.baseStyle,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, size: 10, color: color),
        const SizedBox(width: 2),
        Text(label, style: baseStyle.copyWith(color: color)),
      ],
    );
  }
}
