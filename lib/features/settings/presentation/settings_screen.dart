import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/design/components/kai_card.dart';
import '../../../core/design/theme/theme_extensions.dart';
import '../../../core/design/tokens/kai_spacing.dart';
import '../../../core/providers/settings_provider.dart';
import '../../auth/logic/auth_notifier.dart';
import '../../auth/logic/auth_state.dart';
import 'sections/delete_data_section.dart';

class SettingsScreen extends ConsumerStatefulWidget {
  const SettingsScreen({super.key});

  @override
  ConsumerState<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends ConsumerState<SettingsScreen> {
  @override
  Widget build(BuildContext context) {
    final colors = context.kaiColors;
    final typography = context.kaiTypography;
    final settings = ref.watch(settingsProvider);
    final authState = ref.watch(authNotifierProvider);

    final email = authState is Authenticated ? authState.user.email : null;

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
          // Appearance
          _Section(
            title: 'Внешний вид',
            children: [
              ListTile(
                leading: Icon(Icons.palette_outlined, color: colors.textSecondary),
                title: const Text('Тема'),
                trailing: DropdownButton<ThemeMode>(
                  value: settings.themeMode,
                  underline: const SizedBox.shrink(),
                  items: const [
                    DropdownMenuItem(value: ThemeMode.system, child: Text('Авто')),
                    DropdownMenuItem(value: ThemeMode.light, child: Text('Светлая')),
                    DropdownMenuItem(value: ThemeMode.dark, child: Text('Тёмная')),
                  ],
                  onChanged: (mode) {
                    if (mode != null) {
                      ref.read(settingsProvider.notifier).setThemeMode(mode);
                    }
                  },
                ),
              ),
              SwitchListTile(
                secondary: Icon(Icons.motion_photos_off_outlined, color: colors.textSecondary),
                title: const Text('Снизить анимацию'),
                subtitle: Text(
                  'Kai-сфера и переходы будут спокойнее',
                  style: typography.bodySmall.copyWith(color: colors.textTertiary),
                ),
                value: settings.reduceMotion,
                onChanged: (v) =>
                    ref.read(settingsProvider.notifier).setReduceMotion(v),
                activeColor: colors.oceanPrimary,
              ),
            ],
          ),
          const SizedBox(height: KaiSpacing.l),

          // Voice — STUB
          _Section(
            title: 'Голос',
            children: [
              SwitchListTile(
                secondary: Icon(Icons.mic_outlined, color: colors.textSecondary),
                title: const Text('Голос Kai'),
                subtitle: Text(
                  // STUB: voice toggle not yet implemented
                  'Голосовые ответы Kai',
                  style: typography.bodySmall.copyWith(color: colors.textTertiary),
                ),
                value: true, // STUB: always on for now
                onChanged: (_) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Голосовые настройки — скоро'),
                      duration: Duration(seconds: 2),
                      behavior: SnackBarBehavior.floating,
                    ),
                  );
                },
                activeColor: colors.oceanPrimary,
              ),
            ],
          ),
          const SizedBox(height: KaiSpacing.l),

          // Account
          _Section(
            title: 'Аккаунт',
            children: [
              if (email != null)
                ListTile(
                  leading: Icon(Icons.person_outline, color: colors.textSecondary),
                  title: Text(email),
                  subtitle: Text(
                    'Текущий аккаунт',
                    style: typography.bodySmall.copyWith(color: colors.textTertiary),
                  ),
                ),
              ListTile(
                leading: Icon(Icons.logout, color: colors.error),
                title: Text(
                  'Выйти',
                  style: typography.bodyLarge.copyWith(color: colors.error),
                ),
                onTap: () => _confirmLogout(context, ref),
              ),
            ],
          ),
          const SizedBox(height: KaiSpacing.l),

          // Data
          const _Section(
            title: 'Данные',
            children: [DeleteDataSection()],
          ),
          const SizedBox(height: KaiSpacing.l),

          // About
          _Section(
            title: 'О приложении',
            children: [
              ListTile(
                leading: Icon(Icons.info_outline, color: colors.textSecondary),
                title: const Text('Версия'),
                subtitle: Text(
                  '0.2.0',
                  style: typography.bodyMedium.copyWith(color: colors.textSecondary),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Future<void> _confirmLogout(BuildContext context, WidgetRef ref) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Выйти?'),
        content: const Text('Вы выйдете из аккаунта Kai.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('Отмена'),
          ),
          TextButton(
            style: TextButton.styleFrom(
              foregroundColor: context.kaiColors.error,
            ),
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text('Выйти'),
          ),
        ],
      ),
    );
    if (confirmed != true) return;
    await ref.read(authNotifierProvider.notifier).logout();
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
        KaiCard.flat(
          padding: EdgeInsets.zero,
          child: Column(children: children),
        ),
      ],
    );
  }
}
