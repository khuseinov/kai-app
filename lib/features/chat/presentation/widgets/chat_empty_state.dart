import 'package:flutter/material.dart';
import '../../../../core/design/theme/theme_extensions.dart';
import '../../../../core/design/tokens/kai_radii.dart';
import '../../../../core/design/tokens/kai_spacing.dart';
import '../../../../core/design/components/kai_empty_state.dart';

/// A chat-specific empty state with suggested travel prompts.
class ChatEmptyState extends StatelessWidget {
  final ValueChanged<String> onPromptTapped;

  const ChatEmptyState({
    super.key,
    required this.onPromptTapped,
  });

  static const _suggestions = [
    _Suggestion(
      text: 'Нужна ли виза в Японию?',
      icon: Icons.description,
    ),
    _Suggestion(
      text: 'Построй маршрут по Италии на 7 дней',
      icon: Icons.map,
    ),
    _Suggestion(
      text: 'Насколько безопасен Таиланд?',
      icon: Icons.shield,
    ),
  ];

  @override
  Widget build(BuildContext context) {
    final colors = context.kaiColors;

    return KaiEmptyState(
      icon: Icons.travel_explore,
      title: 'Привет! Я KAI, ваш travel-компаньон',
      subtitle: 'Задайте вопрос о путешествии или выберите тему:',
      action: Column(
        mainAxisSize: MainAxisSize.min,
        children: _suggestions.map((suggestion) {
          return Padding(
            padding: const EdgeInsets.only(bottom: KaiSpacing.xs),
            child: GestureDetector(
              onTap: () => onPromptTapped(suggestion.text),
              child: Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(
                  horizontal: KaiSpacing.m,
                  vertical: KaiSpacing.s,
                ),
                decoration: BoxDecoration(
                  color: colors.surfaceContainer,
                  borderRadius: KaiRadii.pill,
                ),
                child: Row(
                  children: [
                    Icon(
                      suggestion.icon,
                      size: 20.0,
                      color: colors.primary,
                    ),
                    const SizedBox(width: KaiSpacing.xs),
                    Expanded(
                      child: Text(
                        suggestion.text,
                        style: TextStyle(
                          fontSize: 14.0,
                          fontWeight: FontWeight.w500,
                          color: colors.primary,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          );
        }).toList(),
      ),
    );
  }
}

class _Suggestion {
  final String text;
  final IconData icon;

  const _Suggestion({
    required this.text,
    required this.icon,
  });
}
