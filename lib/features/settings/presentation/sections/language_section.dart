import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/providers/settings_provider.dart';

/// Language preference section. Backend lingua detector silently falls back
/// to `en` for short / ambiguous inputs, which can land Russian queries on
/// the English path. This UI lets the user pin a preference (Авто / ru /
/// en) that persists in LocalStorage. Note: backend ChatRequest schema
/// currently has no `language` field — preference is local-only until the
/// schema is extended (see APP-A-BE-1 / APP-B3-FOLLOWUP).
class LanguageSection extends ConsumerWidget {
  const LanguageSection({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final selected = ref.watch(settingsProvider.select((s) => s.language));
    final notifier = ref.read(settingsProvider.notifier);

    return RadioGroup<String?>(
      groupValue: selected,
      onChanged: notifier.setLanguage,
      child: const Column(
        children: [
          _LangTile(label: 'Авто', value: null),
          _LangTile(label: 'Русский', value: 'ru'),
          _LangTile(label: 'English', value: 'en'),
        ],
      ),
    );
  }
}

class _LangTile extends StatelessWidget {
  final String label;
  final String? value;

  const _LangTile({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return RadioListTile<String?>(
      title: Text(label),
      value: value,
    );
  }
}
