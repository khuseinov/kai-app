import 'package:flutter/material.dart';
import 'kai_label.dart';

/// STREAM-STEPS-1 (2026-05-17): friendly Russian phrasing per PEOVUCARG step.
/// Backend emits English labels ("perceiving", "enacting", ...) which read
/// like jargon in a Russian UI. The widget translates by the SINGLE-LETTER
/// step id when present, falling back to the raw label otherwise.
const _STEP_RU = <String, String>{
  'P': 'читаю историю...',
  'E': 'думаю и зову инструменты...',
  'V': 'оцениваю уверенность...',
  'O': 'смотрю на контекст...',
  'C': 'проверяю ответ...',
  'A': 'продумываю следующий шаг...',
  'R': 'обобщаю...',
  'G': 'финальная проверка...',
  'U': 'сохраняю в память...',
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
