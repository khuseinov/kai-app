import 'package:flutter/material.dart';

import '../../../core/design/theme/theme_extensions.dart';
import '../../../core/design/tokens/kai_spacing.dart';
import '../data/country_iso_list.dart';
import 'tabs/visa_tab.dart';
import 'tabs/risk_tab.dart';
import 'tabs/routes_tab.dart';
import 'tabs/cost_tab.dart';
import 'tabs/health_tab.dart';
import 'tabs/emergency_tab.dart';

/// APP-D2: Country detail screen with 6 tabs.
/// Data is fetched per-tab in APP-D3 (CountryToolRepository).
class CountryDetailScreen extends StatefulWidget {
  final String iso2;

  const CountryDetailScreen({super.key, required this.iso2});

  @override
  State<CountryDetailScreen> createState() => _CountryDetailScreenState();
}

class _CountryDetailScreenState extends State<CountryDetailScreen>
    with SingleTickerProviderStateMixin {
  late final TabController _tabController;

  static const _tabs = [
    _TabMeta(Icons.badge_outlined, 'Виза'),
    _TabMeta(Icons.warning_amber_outlined, 'Риски'),
    _TabMeta(Icons.alt_route_outlined, 'Маршрут'),
    _TabMeta(Icons.attach_money_outlined, 'Стоимость'),
    _TabMeta(Icons.health_and_safety_outlined, 'Здоровье'),
    _TabMeta(Icons.emergency_outlined, 'Экстренно'),
  ];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: _tabs.length, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.kaiColors;
    final typography = context.kaiTypography;

    final country =
        kCountryList.where((c) => c.iso2 == widget.iso2).firstOrNull;
    final name = country?.name ?? widget.iso2;
    final flag = country?.flag ?? '';

    return Scaffold(
      backgroundColor: colors.background,
      appBar: AppBar(
        backgroundColor: colors.background,
        elevation: 0,
        title: Row(
          children: [
            Text(flag, style: const TextStyle(fontSize: 24)),
            const SizedBox(width: KaiSpacing.xs),
            Text(
              name,
              style:
                  typography.headlineSmall.copyWith(color: colors.textPrimary),
            ),
          ],
        ),
        bottom: TabBar(
          controller: _tabController,
          isScrollable: true,
          tabAlignment: TabAlignment.start,
          labelColor: colors.primary,
          unselectedLabelColor: colors.textTertiary,
          indicatorColor: colors.primary,
          labelStyle: typography.labelMedium
              .copyWith(fontWeight: FontWeight.w600, fontSize: 11),
          unselectedLabelStyle:
              typography.labelMedium.copyWith(fontSize: 11),
          tabs: _tabs
              .map((t) => Tab(
                    icon: Icon(t.icon, size: 16),
                    text: t.label,
                    iconMargin: const EdgeInsets.only(bottom: 2),
                  ))
              .toList(),
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          VisaTab(iso2: widget.iso2),
          RiskTab(iso2: widget.iso2),
          RoutesTab(iso2: widget.iso2),
          CostTab(iso2: widget.iso2),
          HealthTab(iso2: widget.iso2),
          EmergencyTab(iso2: widget.iso2),
        ],
      ),
    );
  }
}

class _TabMeta {
  final IconData icon;
  final String label;
  const _TabMeta(this.icon, this.label);
}
