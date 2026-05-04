import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/design/theme/theme_extensions.dart';
import '../../logic/delete_data_notifier.dart';

/// GDPR delete-my-data section. Calls existing
/// `DELETE /user/{user_id}/trajectory` which wipes user_profiles,
/// user_episodes and legacy user_trajectory in Qdrant. Required for
/// App Store / Google Play privacy review.
class DeleteDataSection extends ConsumerWidget {
  const DeleteDataSection({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(deleteDataNotifierProvider);
    final colors = context.kaiColors;

    return ListTile(
      leading: Icon(Icons.delete_outline, color: colors.error),
      title: const Text('Удалить мои данные'),
      subtitle: Text(
        _subtitleFor(state),
        style: TextStyle(color: colors.textSecondary),
      ),
      trailing: state == DeleteDataState.deleting
          ? const SizedBox(
              width: 18,
              height: 18,
              child: CircularProgressIndicator(strokeWidth: 2),
            )
          : Icon(Icons.chevron_right, color: colors.textTertiary),
      onTap: state == DeleteDataState.deleting
          ? null
          : () => _confirm(context, ref),
    );
  }

  String _subtitleFor(DeleteDataState state) => switch (state) {
        DeleteDataState.idle =>
          'Стереть всю историю и память Kai на сервере. Действие необратимо.',
        DeleteDataState.deleting => 'Удаление…',
        DeleteDataState.success => 'Готово. Данные стёрты.',
        DeleteDataState.error => 'Ошибка. Попробуйте позже.',
      };

  Future<void> _confirm(BuildContext context, WidgetRef ref) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Удалить данные?'),
        content: const Text(
          'Все ваши сессии, эпизодическая память и предпочтения будут '
          'удалены с сервера Kai. Это действие необратимо.',
        ),
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
            child: const Text('Удалить'),
          ),
        ],
      ),
    );

    if (confirmed != true) return;
    await ref.read(deleteDataNotifierProvider.notifier).deleteAll();
  }
}
