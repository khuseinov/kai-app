import 'package:flutter/material.dart';
import 'kai_label.dart';

/// STREAM-STEPS-1 (2026-05-17, revised): per KAI_VOICE.md the indicator
/// must sound like Kai THINKING ALOUD — a well-travelled human jotting
/// quick notes — not a system reporting machine states. PEOVUCARG step
/// letters get short conversational phrases (lowercase, ellipsis, no
/// padding) that map to actual user-meaningful work:
///
///   P  слушаю            → just got your question, settling in
///   E  ищу источники     → pulling KG + tools (the long visible phase)
///   O  смотрю что есть   → reading what came back
///   V  взвешиваю         → confidence + freshness check
///   C  перепроверяю      → critique, looking for mistakes
///   A  обдумываю         → considering the next move
///   R  собираю мысли     → consolidating reasoning
///   G  почти готов       → final policy check
///   U  запоминаю         → persisting learnings
///
/// Falls back to the raw label if the backend ever sends a step we don't
/// recognise (forward-compat).
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
    if (step != null) {
      final ru = _STEP_RU[step!];
      if (ru != null) return ru;
    }
    // Fallback: maybe `currentStep` itself is the step letter.
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
