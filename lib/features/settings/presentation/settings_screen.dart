import 'package:flutter/material.dart';

import '../../../core/design/theme/theme_extensions.dart';
import '../../../core/design/tokens/kai_spacing.dart';
import 'sections/api_url_section.dart';
import 'sections/delete_data_section.dart';
import 'sections/language_section.dart';

/// Settings screen — sectioned ListView with Data, Language, About,
/// Developer (debug-only) groups. Sections are populated incrementally
/// by APP-B2 (delete data), APP-B3 (language), APP-B4 (API URL).
class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final colors = context.kaiColors;
    final typography = context.kaiTypography;

    return Scaffold(
      backgroundColor: colors.background,
      appBar: AppBar(
        title: const Text('Настройки'),
        backgroundColor: colors.background,
        elevation: 0,
      ),
      body: ListView(
        padding: const EdgeInsets.all(KaiSpacing.l),
        children: [
          const _Section(
            title: 'Данные',
            children: [DeleteDataSection()],
          ),
          const SizedBox(height: KaiSpacing.l),
          const _Section(
            title: 'Язык',
            children: [LanguageSection()],
          ),
          const SizedBox(height: KaiSpacing.l),
          _Section(
            title: 'О приложении',
            children: [
              ListTile(
                leading: const Icon(Icons.info_outline),
                title: const Text('Версия'),
                subtitle: Text(
                  '0.1.0',
                  style: typography.bodyMedium
                      .copyWith(color: colors.textSecondary),
                ),
              ),
            ],
          ),
          const SizedBox(height: KaiSpacing.l),
          const _Section(
            title: 'Разработчик',
            // Inner section is debug-only; in release ApiUrlSection
            // returns SizedBox.shrink so the surface area is empty.
            children: [ApiUrlSection()],
          ),
        ],
      ),
    );
  }
}

class _Section extends StatelessWidget {
  final String title;
  final List<Widget> children;

  const _Section({required this.title, required this.children});

  @override
  Widget build(BuildContext context) {
    final colors = context.kaiColors;
    final typography = context.kaiTypography;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(bottom: KaiSpacing.s),
          child: Text(
            title,
            style: typography.labelMedium.copyWith(
              color: colors.textSecondary,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
        if (children.isNotEmpty)
          Container(
            decoration: BoxDecoration(
              color: colors.surface,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Column(children: children),
          ),
      ],
    );
  }
}

