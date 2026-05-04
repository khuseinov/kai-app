import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/config/env_config.dart';
import '../../../../core/providers/settings_provider.dart';

/// Debug-only API base URL override. Hidden in release builds via
/// kDebugMode. Persists through SettingsNotifier.setApiBaseUrl which
/// writes to LocalStorage; null/empty value resets to EnvConfig default.
class ApiUrlSection extends ConsumerStatefulWidget {
  const ApiUrlSection({super.key});

  @override
  ConsumerState<ApiUrlSection> createState() => _ApiUrlSectionState();
}

class _ApiUrlSectionState extends ConsumerState<ApiUrlSection> {
  late final TextEditingController _controller;

  @override
  void initState() {
    super.initState();
    final current = ref.read(settingsProvider).apiBaseUrl;
    _controller = TextEditingController(text: current);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (!kDebugMode) return const SizedBox.shrink();

    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('API base URL'),
          const SizedBox(height: 8),
          TextField(
            controller: _controller,
            decoration: InputDecoration(
              hintText: EnvConfig.apiBaseUrl,
              border: const OutlineInputBorder(),
            ),
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              TextButton(
                onPressed: () {
                  ref
                      .read(settingsProvider.notifier)
                      .setApiBaseUrl(_controller.text);
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Сохранено. Перезапустите чат.'),
                    ),
                  );
                },
                child: const Text('Сохранить'),
              ),
              TextButton(
                onPressed: () {
                  ref.read(settingsProvider.notifier).setApiBaseUrl(null);
                  _controller.text = EnvConfig.apiBaseUrl;
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Сброшено к умолчанию.')),
                  );
                },
                child: const Text('Сбросить'),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
