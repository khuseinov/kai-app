import 'package:flutter/material.dart';
import '_country_tab_shell.dart';

/// APP-D2: Route planner tab.
/// Data fetched via route_planner tool in APP-D3.
class RoutesTab extends StatelessWidget {
  final String iso2;
  const RoutesTab({super.key, required this.iso2});

  @override
  Widget build(BuildContext context) => CountryTabShell(
        iso2: iso2,
        tool: 'route_planner',
        icon: Icons.alt_route_outlined,
        title: 'Маршруты',
        hint: 'Способы добраться, стыковки, время в пути',
      );
}
