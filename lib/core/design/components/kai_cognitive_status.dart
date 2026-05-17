import 'package:flutter/material.dart';
import 'kai_label.dart';

/// STREAM-STEPS-1 (2026-05-17, revised): per KAI_VOICE.md the indicator
/// must sound like Kai THINKING ALOUD — a well-travelled human jotting
/// quick notes — not a system reporting machine states. PEOVUCARG step
/// letters get short conversational phrases (lowercase, ellipsis, no
/// padding) that map to actual user-meaningful work.
const _STEP_RU = <String, String>{
  'P': 'слушаю...',
  'E': 'ищу источники...',
  'O': 'смотрю что есть...',
  'V': 'взвешиваю...',
  'C': 'перепроверяю...',
  'A': 'обдумываю...',
  'R': 'собираю мысли...',
  'G': 'почти готов...',
  'U': 'запоминаю...',
};

/// STREAM-TOOL-DETAIL-1 (2026-05-17): when EnactStep dispatches a specific
/// tool, the backend stream emits the tool name as the state-event label.
/// We map it to a meaningful action so the user sees "сверяю визы..." for
/// 5–7 seconds (while visa_checker runs) instead of the generic "ищу
/// источники...". Unknown tools fall through to the step-letter lookup.
const _TOOL_RU = <String, String>{
  'visa_checker': 'сверяю визы...',
  'health_requirements': 'смотрю про прививки...',
  'risk_assessment': 'оцениваю риски...',
  'route_planner': 'планирую маршрут...',
  'cost_estimator': 'считаю стоимость...',
  'emergency_contacts': 'ищу экстренные контакты...',
  'web_search_sandboxed': 'ищу в интернете...',
  'cross_source_verify': 'сверяю источники...',
  'news_search': 'проверяю новости...',
};

class KaiCognitiveStatus extends StatelessWidget {
  /// User-visible label. Pass `step` to get Russian translation; if absent,
  /// `currentStep` (free text) is rendered as-is.
  final String currentStep;
  final String? step;
  final double progress; // 0.0 to 1.0 (reserved for future progress bar)

  const KaiCognitiveStatus({
    super.key,
    required this.currentStep,
    this.step,
    this.progress = 0.0,
  });

  String get _displayText {
    // STREAM-TOOL-DETAIL-1: if backend pushed a tool-specific label
    // (e.g. "visa_checker") the friendlier tool phrase wins.
    final toolRu = _TOOL_RU[currentStep];
    if (toolRu != null) return toolRu;

    // Otherwise translate by step letter ("E" → "ищу источники...").
    if (step != null) {
      final ru = _STEP_RU[step!];
      if (ru != null) return ru;
    }
    final ru = _STEP_RU[currentStep];
    if (ru != null) return ru;
    return currentStep;
  }

  @override
  Widget build(BuildContext context) {
    return KaiLabel(
      _displayText,
      variant: KaiLabelVariant.primary,
      icon: const SizedBox(
        width: 10,
        height: 10,
        child: CircularProgressIndicator(strokeWidth: 2),
      ),
    );
  }
}
