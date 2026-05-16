import 'package:flutter/material.dart';
import '_country_tab_shell.dart';

/// APP-D2: Emergency contacts tab.
/// Data fetched via emergency_contacts tool in APP-D3.
class EmergencyTab extends StatelessWidget {
  final String iso2;
  const EmergencyTab({super.key, required this.iso2});

  @override
  Widget build(BuildContext context) => CountryTabShell(
        iso2: iso2,
        tool: 'emergency_contacts',
        icon: Icons.emergency_outlined,
        title: 'Экстренные контакты',
        hint: 'Полиция, скорая помощь, посольство',
      );
}
