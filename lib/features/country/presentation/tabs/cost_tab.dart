import 'package:flutter/material.dart';
import '_country_tab_shell.dart';

/// APP-D2: Cost estimator tab.
/// Data fetched via cost_estimator tool in APP-D3.
class CostTab extends StatelessWidget {
  final String iso2;
  const CostTab({super.key, required this.iso2});

  @override
  Widget build(BuildContext context) => CountryTabShell(
        iso2: iso2,
        tool: 'cost_estimator',
        icon: Icons.attach_money_outlined,
        title: 'Стоимость',
        hint: 'Средние расходы на жильё, еду, транспорт',
      );
}
