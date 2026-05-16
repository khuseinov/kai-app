import 'package:flutter/material.dart';
import '_country_tab_shell.dart';

/// APP-D2: Visa requirements tab.
/// Data fetched via visa_checker tool in APP-D3.
class VisaTab extends StatelessWidget {
  final String iso2;
  const VisaTab({super.key, required this.iso2});

  @override
  Widget build(BuildContext context) => CountryTabShell(
        iso2: iso2,
        tool: 'visa_checker',
        icon: Icons.badge_outlined,
        title: 'Визовые требования',
        hint: 'Нужна ли виза, тип, стоимость и срок',
      );
}
