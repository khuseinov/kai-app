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
    final scopeCategories = message.scopeEscalationCategories;
    final hasScopeSignal = (message.scopeEscalationDetected ?? false) &&
        scopeCategories.isNotEmpty;

    // BUG-DUP-CHIPS-1 (2026-05-16): backend emits each tool call as a separate
    // entry in executed_tool_calls (cache hits, iteration retries), so the
    // same tool can appear 3–4× in the list. Dedupe at render time — one chip
    // per unique tool name. Order preserved via LinkedHashSet semantics.
    final uniqueTools = <String>{};
    for (final tool in message.executedToolCalls) {
      uniqueTools.add(tool);
    }

    // BUG-CHIP-NOISE-1 (2026-05-16): "knowledge graph" / world-model usage
    // chip removed — pure debug signal that confused QA testers. The fact
    // that Kai consulted the KG is already implied by source chips on the
    // bubble; redundant chip in the metadata row added noise without
    // surfacing actionable info to end users.
    final hasAnyMeta = modeChip != null ||
        uniqueTools.isNotEmpty ||
        (message.revisionCount ?? 0) > 0 ||
        hasScopeSignal ||
        (message.advisorTriggered && !(message.requiresHumanApproval ?? false));

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

          // Tool calls — which tools Kai fired (deduped, see BUG-DUP-CHIPS-1).
          for (final tool in uniqueTools)
            _ColoredMetaChip(
              icon: Icons.handyman_outlined,
              label: _toolLabel(tool),
              color: colors.oceanPrimary,
              baseStyle: textStyle,
            ),

          // BUG-CHIP-NOISE-1: knowledge-graph chip removed (debug-only signal).

          // Revision — Kai re-checked after critique failure.
          if ((message.revisionCount ?? 0) > 0)
            _MetaChip(
              icon: Icons.verified_outlined,
              label: 'перепроверено',
              textStyle: textStyle,
              colors: colors,
            ),

          // Scope escalation — soft signal: Kai proposed actions in a category
          // the user has not explicitly consented to in the recent turn.
          // Backend: alignment/scope.py check_scope_boundary (B-16/H-9).
          if (hasScopeSignal)
            _ColoredMetaChip(
              icon: (message.scopeInheritanceViolation ?? false)
                  ? Icons.swap_horiz_outlined
                  : Icons.fence_outlined,
              label: 'нужно подтверждение: ${scopeCategories.join(", ")}',
              color: colors.warning,
              baseStyle: textStyle,
            ),

          // APP-ADVISOR-1: silent revision by AdvisorStep (CC-12 low-conf path)
          if (message.advisorTriggered &&
              !(message.requiresHumanApproval ?? false))
            _MetaChip(
              icon: Icons.manage_search_outlined,
              label: 'Kai уточнил ответ ✓',
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
