import 'package:flutter/material.dart';
import '_country_tab_shell.dart';

/// APP-D2: Health requirements tab.
/// Data fetched via health_requirements tool in APP-D3.
class HealthTab extends StatelessWidget {
  final String iso2;
  const HealthTab({super.key, required this.iso2});

  @override
  Widget build(BuildContext context) => CountryTabShell(
        iso2: iso2,
        tool: 'health_requirements',
        icon: Icons.health_and_safety_outlined,
        title: 'Здоровье',
        hint: 'Прививки, медстраховка, санитарные требования',
      );
}
