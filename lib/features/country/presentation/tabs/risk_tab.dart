import 'package:flutter/material.dart';
import '_country_tab_shell.dart';

/// APP-D2: Risk assessment tab.
/// Data fetched via risk_assessment tool in APP-D3.
class RiskTab extends StatelessWidget {
  final String iso2;
  const RiskTab({super.key, required this.iso2});

  @override
  Widget build(BuildContext context) => CountryTabShell(
        iso2: iso2,
        tool: 'risk_assessment',
        icon: Icons.warning_amber_outlined,
        title: 'Оценка рисков',
        hint: 'Уровень безопасности, актуальные предупреждения',
      );
}
