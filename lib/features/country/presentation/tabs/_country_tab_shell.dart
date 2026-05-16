import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/design/theme/theme_extensions.dart';
import '../../../../core/design/tokens/kai_spacing.dart';
import '../../data/country_tool_repository.dart';
import '../widgets/tool_result_card.dart';

/// APP-D3: wired to countryToolProvider.
/// Shows loading / error / result for a single tool tab.
class CountryTabShell extends ConsumerWidget {
  final String iso2;
  final String tool;
  final IconData icon;
  final String title;
  final String hint;

  const CountryTabShell({
    super.key,
    required this.iso2,
    required this.tool,
    required this.icon,
    required this.title,
    required this.hint,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final colors = context.kaiColors;
    final typography = context.kaiTypography;

    final async = ref.watch(countryToolProvider((iso2, tool)));

    return async.when(
      data: (result) => ToolResultCard(result: result),
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (e, _) => Center(
        child: Padding(
          padding: const EdgeInsets.all(KaiSpacing.xxl),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(Icons.cloud_off_outlined,
                  size: 40, color: colors.textTertiary),
              const SizedBox(height: KaiSpacing.m),
              Text(
                'Не удалось загрузить данные',
                style:
                    typography.bodyMedium.copyWith(color: colors.textSecondary),
              ),
              const SizedBox(height: KaiSpacing.xs),
              Text(
                e.toString(),
                textAlign: TextAlign.center,
                style:
                    typography.bodySmall.copyWith(color: colors.textTertiary),
              ),
              const SizedBox(height: KaiSpacing.l),
              OutlinedButton.icon(
                onPressed: () =>
                    ref.invalidate(countryToolProvider((iso2, tool))),
                icon: const Icon(Icons.refresh, size: 16),
                label: const Text('Повторить'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
