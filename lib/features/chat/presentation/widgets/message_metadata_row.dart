import 'package:flutter/material.dart';

import '../../../../core/design/theme/theme_extensions.dart';
import '../../../../core/design/tokens/kai_spacing.dart';
import '../../../../core/models/chat_message.dart';

/// QW-3: Message metadata footer — shown under Kai responses when there is
/// something meaningful to surface to the user.
///
/// Shows only user-relevant signals:
///   • autonomous mode (когда Kai вышел за рамки стандарта)
///   • executed tool calls (что Kai вызвал)
///   • knowledge graph usage (база знаний)
///   • revision signal (Kai перепроверил ответ)
///
/// Dev-only signals (provider, model, tokens, latency, confidence, PII,
/// language) intentionally excluded — visible in server logs, not in UI.
class MessageMetadataRow extends StatelessWidget {
  final ChatMessage message;

  const MessageMetadataRow({super.key, required this.message});

  @override
  Widget build(BuildContext context) {
    if (message.isUser) return const SizedBox.shrink();

    final modeChip = _autonomousModeChip(message.requestType, context.kaiColors);

    final hasAnyMeta = modeChip != null ||
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

    return Padding(
      padding: const EdgeInsets.only(
        top: KaiSpacing.xxxs,
        left: KaiSpacing.screenPadding,
        right: KaiSpacing.screenPadding,
        bottom: KaiSpacing.xxs,
      ),
      child: Wrap(
        spacing: KaiSpacing.xs,
        runSpacing: 2,
        crossAxisAlignment: WrapCrossAlignment.center,
        children: [
          // Autonomous mode — only shown when Kai escalated past fast/standard.
          if (modeChip != null)
            _ColoredMetaChip(
              icon: modeChip.icon,
              label: modeChip.label,
              color: modeChip.color,
              baseStyle: textStyle,
            ),

          // Tool calls — which tools Kai fired.
          for (final tool in message.executedToolCalls)
            _ColoredMetaChip(
              icon: Icons.handyman_outlined,
              label: _toolLabel(tool),
              color: colors.oceanPrimary,
              baseStyle: textStyle,
            ),

          // Knowledge graph — grounded answer from world model.
          if (message.worldModelUsed == true &&
              (message.kgNodesQueried ?? 0) > 0)
            _MetaChip(
              icon: Icons.travel_explore_outlined,
              label: 'база знаний',
              textStyle: textStyle,
              colors: colors,
            ),

          // Revision — Kai re-checked after critique failure.
          if ((message.revisionCount ?? 0) > 0)
            _MetaChip(
              icon: Icons.verified_outlined,
              label: 'перепроверено',
              textStyle: textStyle,
              colors: colors,
            ),
        ],
      ),
    );
  }

  /// Maps request_type to a user-readable mode badge.
  /// Returns null for fast/standard (default path — no badge needed).
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
      default:
        return null;
    }
  }

  /// Human-readable tool name for the chip label.
  static String _toolLabel(String tool) {
    const labels = {
      'visa_checker': 'виза',
      'risk_assessment': 'риски',
      'route_planner': 'маршрут',
      'cost_estimator': 'стоимость',
      'health_requirements': 'здоровье',
      'emergency_contacts': 'экстренная связь',
      'web_search_sandboxed': 'поиск',
      'cross_source_verify': 'проверка',
      'news_search': 'новости',
    };
    return labels[tool] ?? tool.replaceAll('_', ' ');
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
