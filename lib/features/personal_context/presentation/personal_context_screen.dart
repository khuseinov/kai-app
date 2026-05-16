import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/design/theme/theme_extensions.dart';
import '../../../core/design/tokens/kai_spacing.dart';
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
  final _controller = TextEditingController();

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(personalContextNotifierProvider);
    final colors = context.kaiColors;
    final typography = context.kaiTypography;

    // Show success snackbar
    ref.listen<PersonalContextState>(personalContextNotifierProvider,
        (_, next) {
      if (next.savedSuccess) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Инструкция сохранена')),
        );
        _controller.clear();
      }
    });

    final grouped = _groupByType(state.items);

    return Scaffold(
      backgroundColor: colors.background,
      appBar: AppBar(
        title: const Text('Личный контекст'),
        backgroundColor: colors.background,
        elevation: 0,
      ),
      body: state.isLoading
          ? const Center(child: CircularProgressIndicator())
          : ListView(
              padding: const EdgeInsets.all(KaiSpacing.m),
              children: [
                // APP-C2: Add instruction section
                _AddInstructionCard(
                  controller: _controller,
                  isSaving: state.isSaving,
                  onAdd: (text) => ref
                      .read(personalContextNotifierProvider.notifier)
                      .addInstruction(text),
                ),
                const SizedBox(height: KaiSpacing.l),

                if (state.error != null) ...[
                  _ErrorChip(message: state.error!),
                  const SizedBox(height: KaiSpacing.m),
                ],

                if (state.items.isEmpty && !state.isLoading)
                  Center(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(vertical: KaiSpacing.xxl),
                      child: Column(
                        children: [
                          Icon(
                            Icons.person_outline,
                            size: 48,
                            color: colors.textTertiary,
                          ),
                          const SizedBox(height: KaiSpacing.s),
                          Text(
                            'Kai ещё не запомнил\nваши предпочтения',
                            textAlign: TextAlign.center,
                            style: typography.bodyMedium
                                .copyWith(color: colors.textTertiary),
                          ),
                        ],
                      ),
                    ),
                  )
                else
                  for (final entry in grouped.entries) ...[
                    _TypeSection(
                      type: entry.key,
                      items: entry.value,
                    ),
                    const SizedBox(height: KaiSpacing.m),
                  ],
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
}

class _AddInstructionCard extends StatelessWidget {
  final TextEditingController controller;
  final bool isSaving;
  final void Function(String) onAdd;

  const _AddInstructionCard({
    required this.controller,
    required this.isSaving,
    required this.onAdd,
  });

  @override
  Widget build(BuildContext context) {
    final colors = context.kaiColors;
    final typography = context.kaiTypography;

    return Container(
      padding: const EdgeInsets.all(KaiSpacing.m),
      decoration: BoxDecoration(
        color: colors.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: colors.glassBorder),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.edit_note_outlined,
                  size: 16, color: colors.oceanPrimary),
              const SizedBox(width: KaiSpacing.xs),
              Text(
                'Добавить инструкцию',
                style: typography.labelMedium
                    .copyWith(color: colors.textPrimary),
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
              hintText: 'Например: Отвечай мне только на русском языке',
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
                borderSide:
                    BorderSide(color: colors.oceanPrimary),
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
                    icon: const Icon(Icons.add, size: 16),
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

class _TypeSection extends StatelessWidget {
  final String type;
  final List<UserProfileItem> items;

  const _TypeSection({required this.type, required this.items});

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
          padding: const EdgeInsets.only(bottom: KaiSpacing.xs),
          child: Text(
            label,
            style: typography.labelMedium.copyWith(
              color: colors.textSecondary,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
        Wrap(
          spacing: KaiSpacing.xs,
          runSpacing: KaiSpacing.xs,
          children: items.map((item) => _ProfileChip(item: item)).toList(),
        ),
      ],
    );
  }
}

class _ProfileChip extends StatelessWidget {
  final UserProfileItem item;

  const _ProfileChip({required this.item});

  @override
  Widget build(BuildContext context) {
    final colors = context.kaiColors;
    final typography = context.kaiTypography;

    return Container(
      constraints: const BoxConstraints(maxWidth: 280),
      padding: const EdgeInsets.symmetric(
        horizontal: KaiSpacing.s,
        vertical: KaiSpacing.xxs,
      ),
      decoration: BoxDecoration(
        color: item.verifiedPreference
            ? colors.oceanPrimary.withValues(alpha: 0.08)
            : colors.surfaceContainer,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: item.verifiedPreference
              ? colors.oceanPrimary.withValues(alpha: 0.3)
              : colors.glassBorder,
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (item.verifiedPreference) ...[
            Icon(Icons.verified_outlined,
                size: 12, color: colors.oceanPrimary),
            const SizedBox(width: KaiSpacing.xxs),
          ],
          Flexible(
            child: Text(
              item.content,
              style:
                  typography.bodySmall.copyWith(color: colors.textSecondary),
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    );
  }
}

class _ErrorChip extends StatelessWidget {
  final String message;

  const _ErrorChip({required this.message});

  @override
  Widget build(BuildContext context) {
    final colors = context.kaiColors;
    final typography = context.kaiTypography;

    return Container(
      padding: const EdgeInsets.all(KaiSpacing.s),
      decoration: BoxDecoration(
        color: colors.error.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: colors.error.withValues(alpha: 0.3)),
      ),
      child: Row(
        children: [
          Icon(Icons.error_outline, size: 16, color: colors.error),
          const SizedBox(width: KaiSpacing.xs),
          Expanded(
            child: Text(
              message,
              style: typography.bodySmall.copyWith(color: colors.error),
            ),
          ),
        ],
      ),
    );
  }
}
