import 'package:flutter/material.dart';
import 'kai_label.dart';

class KaiCognitiveStatus extends StatelessWidget {
  final String currentStep;
  final double progress; // 0.0 to 1.0

  const KaiCognitiveStatus({
    super.key,
    required this.currentStep,
    this.progress = 0.0,
  });

  @override
  Widget build(BuildContext context) {
    return KaiLabel(
      currentStep,
      variant: KaiLabelVariant.primary,
      icon: const SizedBox(
        width: 10,
        height: 10,
        child: CircularProgressIndicator(strokeWidth: 2),
      ),
    );
  }
}
