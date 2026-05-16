import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/design/theme/theme_extensions.dart';
import '../../../core/design/tokens/kai_spacing.dart';
import '../data/country_iso_list.dart';
import '../logic/favourites_notifier.dart';

class CountryPickerScreen extends ConsumerStatefulWidget {
  const CountryPickerScreen({super.key});

  @override
  ConsumerState<CountryPickerScreen> createState() =>
      _CountryPickerScreenState();
}

class _CountryPickerScreenState extends ConsumerState<CountryPickerScreen> {
  final _searchController = TextEditingController();
  String _query = '';

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  List<IsoCountry> get _filtered {
    if (_query.isEmpty) return kCountryList;
    final q = _query.toLowerCase();
    return kCountryList
        .where((c) =>
            c.name.toLowerCase().contains(q) ||
            c.iso2.toLowerCase().contains(q))
        .toList();
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.kaiColors;
    final typography = context.kaiTypography;
    final favourites = ref.watch(favouritesProvider);

    final filtered = _filtered;
    final favCountries = favourites.isEmpty
        ? <IsoCountry>[]
        : filtered
            .where((c) => favourites.contains(c.iso2))
            .toList();
    final restCountries =
        filtered.where((c) => !favourites.contains(c.iso2)).toList();

    return Scaffold(
      backgroundColor: colors.background,
      appBar: AppBar(
        backgroundColor: colors.background,
        elevation: 0,
        title: Text(
          'Выберите страну',
          style: typography.headlineSmall.copyWith(color: colors.textPrimary),
        ),
      ),
      body: Column(
        children: [
          // ── Search field ──────────────────────────────────────────────────
          Padding(
            padding: const EdgeInsets.symmetric(
              horizontal: KaiSpacing.screenPadding,
              vertical: KaiSpacing.xs,
            ),
            child: TextField(
              controller: _searchController,
              autofocus: false,
              decoration: InputDecoration(
                hintText: 'Поиск страны…',
                hintStyle:
                    typography.bodyMedium.copyWith(color: colors.textTertiary),
                prefixIcon:
                    Icon(Icons.search, color: colors.textTertiary, size: 20),
                suffixIcon: _query.isNotEmpty
                    ? IconButton(
                        icon: Icon(Icons.clear,
                            size: 18, color: colors.textTertiary),
                        onPressed: () {
                          _searchController.clear();
                          setState(() => _query = '');
                        },
                      )
                    : null,
                filled: true,
                fillColor: colors.surfaceContainer,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide.none,
                ),
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: KaiSpacing.m,
                  vertical: KaiSpacing.s,
                ),
              ),
              onChanged: (v) => setState(() => _query = v.trim()),
            ),
          ),

          // ── Country list ──────────────────────────────────────────────────
          Expanded(
            child: ListView(
              padding: const EdgeInsets.only(bottom: KaiSpacing.xxl),
              children: [
                if (favCountries.isNotEmpty) ...[
                  _SectionHeader(
                      label: 'Избранное', colors: colors, typography: typography),
                  ...favCountries.map(
                    (c) => _CountryTile(
                      country: c,
                      isFavourite: true,
                      onTap: () => context.push('/country/${c.iso2}'),
                      onFavouriteTap: () =>
                          ref.read(favouritesProvider.notifier).toggle(c.iso2),
                    ),
                  ),
                  const Divider(height: 1),
                ],
                if (restCountries.isNotEmpty) ...[
                  if (favCountries.isNotEmpty)
                    _SectionHeader(
                        label: 'Все страны',
                        colors: colors,
                        typography: typography),
                  ...restCountries.map(
                    (c) => _CountryTile(
                      country: c,
                      isFavourite: false,
                      onTap: () => context.push('/country/${c.iso2}'),
                      onFavouriteTap: () =>
                          ref.read(favouritesProvider.notifier).toggle(c.iso2),
                    ),
                  ),
                ],
                if (filtered.isEmpty)
                  Padding(
                    padding: const EdgeInsets.all(KaiSpacing.xxl),
                    child: Center(
                      child: Text(
                        'Страна не найдена',
                        style: typography.bodyMedium
                            .copyWith(color: colors.textTertiary),
                      ),
                    ),
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _SectionHeader extends StatelessWidget {
  final String label;
  final dynamic colors;
  final dynamic typography;

  const _SectionHeader({
    required this.label,
    required this.colors,
    required this.typography,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(
        KaiSpacing.screenPadding,
        KaiSpacing.m,
        KaiSpacing.screenPadding,
        KaiSpacing.xs,
      ),
      child: Text(
        label,
        style: (typography.labelMedium as TextStyle).copyWith(
          color: colors.textTertiary,
          fontWeight: FontWeight.w600,
          letterSpacing: 0.5,
        ),
      ),
    );
  }
}

class _CountryTile extends StatelessWidget {
  final IsoCountry country;
  final bool isFavourite;
  final VoidCallback onTap;
  final VoidCallback onFavouriteTap;

  const _CountryTile({
    required this.country,
    required this.isFavourite,
    required this.onTap,
    required this.onFavouriteTap,
  });

  @override
  Widget build(BuildContext context) {
    final colors = context.kaiColors;
    final typography = context.kaiTypography;

    return ListTile(
      contentPadding: const EdgeInsets.symmetric(
        horizontal: KaiSpacing.screenPadding,
        vertical: KaiSpacing.xxxs,
      ),
      leading: Text(
        country.flag,
        style: const TextStyle(fontSize: 28),
      ),
      title: Text(
        country.name,
        style: typography.bodyMedium.copyWith(color: colors.textPrimary),
      ),
      subtitle: Text(
        country.iso2,
        style: typography.labelSmall.copyWith(
          color: colors.textTertiary,
          fontSize: 10,
        ),
      ),
      trailing: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: onFavouriteTap,
        child: Padding(
          padding: const EdgeInsets.all(KaiSpacing.xs),
          child: Icon(
            isFavourite ? Icons.star_rounded : Icons.star_outline_rounded,
            size: 20,
            color: isFavourite ? colors.warning : colors.textTertiary,
          ),
        ),
      ),
      onTap: onTap,
    );
  }
}
