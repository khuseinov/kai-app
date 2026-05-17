import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/design/components/kai_card.dart';
import '../../../core/design/components/kai_empty_state.dart';
import '../../../core/design/components/kai_error_view.dart';
import '../../../core/design/theme/theme_extensions.dart';
import '../../../core/design/tokens/kai_colors.dart';
import '../../../core/design/tokens/kai_spacing.dart';
import '../../../core/design/tokens/kai_typography.dart';
import '../../settings/presentation/sections/delete_data_section.dart';
import '../data/profile_remote_source.dart';
import '../logic/personal_context_notifier.dart';

class PersonalContextScreen extends ConsumerStatefulWidget {
  const PersonalContextScreen({super.key});

  @override
  ConsumerState<PersonalContextScreen> createState() =>
      _PersonalContextScreenState();
}

class _PersonalContextScreenState
    extends ConsumerState<PersonalContextScreen> {
  final _addController = TextEditingController();

  @override
  void dispose() {
    _addController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(personalContextNotifierProvider);
    final colors = context.kaiColors;
    final typography = context.kaiTypography;

    ref.listen<PersonalContextState>(personalContextNotifierProvider,
        (_, next) {
      if (next.savedSuccess) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Сохранено')),
        );
        _addController.clear();
      }
    });

    final grouped = _groupByType(state.items);

    return Scaffold(
      backgroundColor: colors.background,
      appBar: AppBar(
        title: const Text('Что Kai обо мне знает'),
        backgroundColor: colors.background,
        elevation: 0,
      ),
      body: state.isLoading
          ? const Center(child: CircularProgressIndicator())
          : ListView(
              padding: const EdgeInsets.all(KaiSpacing.m),
              children: [
                if (state.error != null) ...[
                  KaiErrorView(message: state.error!),
                  const SizedBox(height: KaiSpacing.m),
                ],

                // Grouped memory items
                if (state.items.isEmpty)
                  const Center(
                    child: KaiEmptyState(
                      icon: Icons.psychology_outlined,
                      title: 'Kai ещё ничего не знает',
                      subtitle: 'Добавьте факты или дайте Kai поработать',
                    ),
                  )
                else
                  for (final entry in grouped.entries) ...[
                    _MemorySection(
                      type: entry.key,
                      items: entry.value,
                      onDelete: (id) => ref
                          .read(personalContextNotifierProvider.notifier)
                          .deleteItem(id),
                      onEdit: (id, content) =>
                          _showEditDialog(context, id, content),
                    ),
                    const SizedBox(height: KaiSpacing.m),
                  ],

                const SizedBox(height: KaiSpacing.m),

                // Add fact
                _AddFactTile(
                  controller: _addController,
                  isSaving: state.isSaving,
                  onAdd: (text) => ref
                      .read(personalContextNotifierProvider.notifier)
                      .addInstruction(text),
                ),

                const SizedBox(height: KaiSpacing.xl),
                Divider(color: colors.textTertiary.withAlpha(40)),
                const SizedBox(height: KaiSpacing.m),

                // Memory master toggle — STUB
                _MemoryToggleTile(
                  enabled: state.memoryEnabled,
                  onChanged: (val) => ref
                      .read(personalContextNotifierProvider.notifier)
                      .setMemoryEnabled(val),
                  colors: colors,
                  typography: typography,
                ),

                const SizedBox(height: KaiSpacing.m),

                // GDPR delete — REAL
                _DeleteAllTile(colors: colors),

                const SizedBox(height: KaiSpacing.l),
              ],
            ),
    );
  }

  Map<String, List<UserProfileItem>> _groupByType(
      List<UserProfileItem> items) {
    final map = <String, List<UserProfileItem>>{};
    for (final item in items) {
      map.putIfAbsent(item.type, () => []).add(item);
    }
    return map;
  }

  void _showEditDialog(
      BuildContext context, String itemId, String currentContent) {
    final editController = TextEditingController(text: currentContent);
    showDialog<void>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Редактировать'),
        content: TextField(
          controller: editController,
          maxLines: 4,
          minLines: 2,
          autofocus: true,
          decoration: const InputDecoration(border: OutlineInputBorder()),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Отмена'),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(ctx);
              ref
                  .read(personalContextNotifierProvider.notifier)
                  .updateItem(itemId, editController.text);
            },
            child: const Text('Сохранить'),
          ),
        ],
      ),
    );
  }
}

class _MemorySection extends StatelessWidget {
  final String type;
  final List<UserProfileItem> items;
  final void Function(String id) onDelete;
  final void Function(String id, String content) onEdit;

  const _MemorySection({
    required this.type,
    required this.items,
    required this.onDelete,
    required this.onEdit,
  });

  static const _typeLabels = <String, String>{
    'preference': 'Предпочтения',
    'instruction': 'Инструкции',
    'correction': 'Исправления',
    'episode': 'Эпизоды',
    'fact': 'Факты',
  };

  @override
  Widget build(BuildContext context) {
    final colors = context.kaiColors;
    final typography = context.kaiTypography;
    final label = _typeLabels[type] ?? type;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(bottom: KaiSpacing.xs, left: 4),
          child: Text(
            label,
            style: typography.labelMedium.copyWith(
              color: colors.textTertiary,
              fontWeight: FontWeight.w600,
              letterSpacing: 0.3,
            ),
          ),
        ),
        KaiCard.flat(
          padding: EdgeInsets.zero,
          child: Column(
            children: items.asMap().entries.map((entry) {
              final i = entry.key;
              final item = entry.value;
              final isLast = i == items.length - 1;
              return Column(
                children: [
                  _MemoryItemRow(
                    item: item,
                    onDelete: () => onDelete(item.id),
                    onEdit: () => onEdit(item.id, item.content),
                  ),
                  if (!isLast)
                    Divider(
                      height: 1,
                      indent: 16,
                      endIndent: 0,
                      color: colors.textTertiary.withAlpha(30),
                    ),
                ],
              );
            }).toList(),
          ),
        ),
      ],
    );
  }
}

class _MemoryItemRow extends StatelessWidget {
  final UserProfileItem item;
  final VoidCallback onDelete;
  final VoidCallback onEdit;

  const _MemoryItemRow({
    required this.item,
    required this.onDelete,
    required this.onEdit,
  });

  @override
  Widget build(BuildContext context) {
    final colors = context.kaiColors;
    final typography = context.kaiTypography;

    return Padding(
      padding: const EdgeInsets.symmetric(
        horizontal: KaiSpacing.m,
        vertical: KaiSpacing.s,
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (item.verifiedPreference) ...[
            Icon(Icons.verified_outlined, size: 14, color: colors.oceanPrimary),
            const SizedBox(width: 6),
          ],
          Expanded(
            child: Text(
              item.content,
              style: typography.bodyMedium.copyWith(color: colors.textPrimary),
            ),
          ),
          const SizedBox(width: KaiSpacing.xs),
          GestureDetector(
            onTap: onEdit,
            child:
                Icon(Icons.edit_outlined, size: 16, color: colors.textTertiary),
          ),
          const SizedBox(width: KaiSpacing.s),
          GestureDetector(
            onTap: onDelete,
            child: Icon(Icons.delete_outline,
                size: 16, color: colors.textTertiary),
          ),
        ],
      ),
    );
  }
}

class _AddFactTile extends StatelessWidget {
  final TextEditingController controller;
  final bool isSaving;
  final void Function(String) onAdd;

  const _AddFactTile({
    required this.controller,
    required this.isSaving,
    required this.onAdd,
  });

  @override
  Widget build(BuildContext context) {
    final colors = context.kaiColors;
    final typography = context.kaiTypography;

    return KaiCard(
      padding: const EdgeInsets.all(KaiSpacing.m),
      border: Border.all(color: colors.glassBorder),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.add_circle_outline,
                  size: 16, color: colors.oceanPrimary),
              const SizedBox(width: KaiSpacing.xs),
              Text(
                'Добавить факт',
                style:
                    typography.labelMedium.copyWith(color: colors.textPrimary),
              ),
            ],
          ),
          const SizedBox(height: KaiSpacing.s),
          TextField(
            controller: controller,
            maxLines: 3,
            minLines: 2,
            style: typography.bodyMedium.copyWith(color: colors.textPrimary),
            decoration: InputDecoration(
              hintText: 'Например: Предпочитаю краткие ответы',
              hintStyle:
                  typography.bodySmall.copyWith(color: colors.textTertiary),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
                borderSide: BorderSide(color: colors.glassBorder),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
                borderSide: BorderSide(color: colors.glassBorder),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
                borderSide: BorderSide(color: colors.oceanPrimary),
              ),
              contentPadding: const EdgeInsets.all(KaiSpacing.s),
            ),
          ),
          const SizedBox(height: KaiSpacing.s),
          Align(
            alignment: Alignment.centerRight,
            child: isSaving
                ? const SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  )
                : TextButton.icon(
                    onPressed: () => onAdd(controller.text),
                    icon: const Icon(Icons.save_outlined, size: 16),
                    label: const Text('Сохранить'),
                    style: TextButton.styleFrom(
                      foregroundColor: colors.oceanPrimary,
                    ),
                  ),
          ),
        ],
      ),
    );
  }
}

class _MemoryToggleTile extends StatelessWidget {
  final bool enabled;
  final void Function(bool) onChanged;
  final KaiColors colors;
  final KaiTypography typography;

  const _MemoryToggleTile({
    required this.enabled,
    required this.onChanged,
    required this.colors,
    required this.typography,
  });

  @override
  Widget build(BuildContext context) {
    return KaiCard.flat(
      padding: const EdgeInsets.symmetric(
        horizontal: KaiSpacing.m,
        vertical: KaiSpacing.s,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Память Kai',
                      style: typography.labelMedium.copyWith(
                        color: colors.textPrimary,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      // STUB: toggle not yet wired to backend
                      'Kai запоминает факты о вас между сессиями',
                      style: typography.bodySmall.copyWith(
                        color: colors.textTertiary,
                      ),
                    ),
                  ],
                ),
              ),
              Switch(
                value: enabled,
                onChanged: onChanged,
                activeThumbColor: colors.oceanPrimary,
              ),
            ],
          ),
          if (!enabled)
            Padding(
              padding: const EdgeInsets.only(top: KaiSpacing.xs),
              child: Text(
                'Kai будет забывать всё после каждой сессии.',
                style: typography.bodySmall.copyWith(
                  color: colors.warning,
                  fontStyle: FontStyle.italic,
                ),
              ),
            ),
        ],
      ),
    );
  }
}

class _DeleteAllTile extends StatelessWidget {
  // ignore: unused_element_parameter — kept for caller symmetry with _MemoryToggleTile
  final KaiColors? colors;

  const _DeleteAllTile({this.colors});

  @override
  Widget build(BuildContext context) {
    return const KaiCard.flat(
      padding: EdgeInsets.zero,
      child: DeleteDataSection(),
    );
  }
}
