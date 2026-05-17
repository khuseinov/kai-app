// lib/features/chat/presentation/widgets/message_detail_sheet.dart
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../../../core/design/components/kai_card.dart';
import '../../../../core/design/theme/theme_extensions.dart';
import '../../../../core/design/tokens/kai_spacing.dart';
import '../../../../core/models/chat_message.dart';
import '../../../../core/models/tool_source.dart';

/// Long-press detail sheet for Kai responses.
/// Shows: sources, reasoning (XAI/thinking), model details.
/// All the "dev noise" that was removed from the inline bubble lives here
/// for curious users.
class MessageDetailSheet extends StatelessWidget {
  final ChatMessage message;

  const MessageDetailSheet({super.key, required this.message});

  /// Show this sheet as a modal bottom sheet.
  static void show(BuildContext context, ChatMessage message) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => MessageDetailSheet(message: message),
    );
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.kaiColors;
    final typography = context.kaiTypography;

    // Extract XAI content if mode == 'X' (same logic as was in _XAIBlock)
    final xaiIdx = message.specialMode?.toUpperCase() == 'X'
        ? message.content.indexOf('[XAI]')
        : -1;
    final xaiContent = xaiIdx >= 0
        ? message.content.substring(xaiIdx + 5).trim()
        : null;
    final thinking = message.thinking;

    final hasSources = message.sources.isNotEmpty;
    final hasReasoning =
        xaiContent != null || (thinking != null && thinking.isNotEmpty);
    final hasDetails = message.model != null ||
        message.latencyMs != null ||
        message.tokensUsed != null;

    return DraggableScrollableSheet(
      initialChildSize: 0.55,
      minChildSize: 0.3,
      maxChildSize: 0.9,
      builder: (context, scrollController) {
        return Container(
          decoration: BoxDecoration(
            color: colors.surface,
            borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
          ),
          child: Column(
            children: [
              // Handle
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 12),
                child: Container(
                  width: 36,
                  height: 4,
                  decoration: BoxDecoration(
                    color: colors.cloudLight,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),
              // Content
              Expanded(
                child: ListView(
                  controller: scrollController,
                  padding: const EdgeInsets.fromLTRB(
                    KaiSpacing.l,
                    0,
                    KaiSpacing.l,
                    KaiSpacing.l,
                  ),
                  children: [
                    if (hasSources) ...[
                      _SectionHeader(
                          title: 'Источники',
                          colors: colors,
                          typography: typography),
                      const SizedBox(height: KaiSpacing.s),
                      ...message.sources.asMap().entries.map((e) => _SourceRow(
                          index: e.key + 1,
                          source: e.value,
                          colors: colors,
                          typography: typography)),
                      const SizedBox(height: KaiSpacing.l),
                    ],
                    if (hasReasoning) ...[
                      _SectionHeader(
                          title: 'Почему этот ответ?',
                          colors: colors,
                          typography: typography),
                      const SizedBox(height: KaiSpacing.s),
                      _ReasoningBlock(
                        xaiContent: xaiContent,
                        thinking: thinking,
                        colors: colors,
                        typography: typography,
                      ),
                      const SizedBox(height: KaiSpacing.l),
                    ],
                    if (hasDetails) ...[
                      _SectionHeader(
                          title: 'Детали',
                          colors: colors,
                          typography: typography),
                      const SizedBox(height: KaiSpacing.s),
                      if (message.model != null)
                        _DetailRow(
                            label: 'Модель',
                            value: message.model!,
                            colors: colors,
                            typography: typography),
                      if (message.provider != null)
                        _DetailRow(
                            label: 'Провайдер',
                            value: message.provider!,
                            colors: colors,
                            typography: typography),
                      if (message.latencyMs != null)
                        _DetailRow(
                          label: 'Время',
                          value:
                              '${(message.latencyMs! / 1000).toStringAsFixed(1)}с',
                          colors: colors,
                          typography: typography,
                        ),
                      if (message.tokensUsed != null)
                        _DetailRow(
                          label: 'Токены',
                          value: '${message.tokensUsed}',
                          colors: colors,
                          typography: typography,
                        ),
                      const SizedBox(height: KaiSpacing.l),
                    ],
                    if (!hasSources && !hasReasoning && !hasDetails)
                      Center(
                        child: Padding(
                          padding: const EdgeInsets.all(KaiSpacing.xl),
                          child: Text(
                            'Нет дополнительной информации',
                            style: typography.bodyMedium
                                .copyWith(color: colors.textTertiary),
                          ),
                        ),
                      ),
                    // Actions
                    const Divider(),
                    const SizedBox(height: KaiSpacing.s),
                    Row(
                      children: [
                        Expanded(
                          child: OutlinedButton.icon(
                            onPressed: () {
                              Clipboard.setData(
                                  ClipboardData(text: message.content));
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                  content: Text('Скопировано'),
                                  duration: Duration(seconds: 2),
                                  behavior: SnackBarBehavior.floating,
                                ),
                              );
                            },
                            icon:
                                const Icon(Icons.copy_rounded, size: 16),
                            label: const Text('Копировать'),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}

class _SectionHeader extends StatelessWidget {
  final String title;
  final dynamic colors;
  final dynamic typography;
  const _SectionHeader(
      {required this.title, required this.colors, required this.typography});

  @override
  Widget build(BuildContext context) {
    return Text(
      title,
      style: typography.labelLarge.copyWith(
        color: colors.textSecondary,
        fontWeight: FontWeight.w600,
      ),
    );
  }
}

class _SourceRow extends StatelessWidget {
  final int index;
  final ToolSource source;
  final dynamic colors;
  final dynamic typography;
  const _SourceRow(
      {required this.index,
      required this.source,
      required this.colors,
      required this.typography});

  @override
  Widget build(BuildContext context) {
    final displayName = source.sourceDisplayName ?? source.source;
    return Padding(
      padding: const EdgeInsets.only(bottom: KaiSpacing.xs),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            '[$index]',
            style: typography.labelSmall.copyWith(color: colors.oceanPrimary),
          ),
          const SizedBox(width: KaiSpacing.xs),
          Expanded(
            child: Text(
              displayName,
              style: typography.bodySmall.copyWith(color: colors.textPrimary),
            ),
          ),
          if (source.fetchedAt != null)
            Text(
              _shortTime(source.fetchedAt!),
              style:
                  typography.labelSmall.copyWith(color: colors.textTertiary),
            ),
        ],
      ),
    );
  }

  static String _shortTime(String iso) {
    try {
      final dt = DateTime.parse(iso).toLocal();
      return '${dt.hour.toString().padLeft(2, '0')}:${dt.minute.toString().padLeft(2, '0')}';
    } catch (_) {
      return '';
    }
  }
}

class _ReasoningBlock extends StatefulWidget {
  final String? xaiContent;
  final String? thinking;
  final dynamic colors;
  final dynamic typography;
  const _ReasoningBlock(
      {this.xaiContent,
      this.thinking,
      required this.colors,
      required this.typography});

  @override
  State<_ReasoningBlock> createState() => _ReasoningBlockState();
}

class _ReasoningBlockState extends State<_ReasoningBlock> {
  bool _expanded = false;

  @override
  Widget build(BuildContext context) {
    final text = widget.xaiContent ?? widget.thinking ?? '';
    final preview = text.length > 120 ? '${text.substring(0, 120)}…' : text;

    return GestureDetector(
      onTap: () => setState(() => _expanded = !_expanded),
      child: KaiCard.flat(
        padding: const EdgeInsets.all(KaiSpacing.m),
        backgroundColor: widget.colors.surfaceContainer,
        borderRadius: 8,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              _expanded ? text : preview,
              style: widget.typography.bodySmall.copyWith(
                color: widget.colors.textSecondary,
                height: 1.5,
              ),
            ),
            if (text.length > 120) ...[
              const SizedBox(height: KaiSpacing.xs),
              Text(
                _expanded ? 'Свернуть' : 'Показать полностью',
                style: widget.typography.labelSmall.copyWith(
                  color: widget.colors.oceanPrimary,
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

class _DetailRow extends StatelessWidget {
  final String label;
  final String value;
  final dynamic colors;
  final dynamic typography;
  const _DetailRow(
      {required this.label,
      required this.value,
      required this.colors,
      required this.typography});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: KaiSpacing.xs),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label,
              style: typography.bodySmall
                  .copyWith(color: colors.textTertiary)),
          Text(value,
              style: typography.bodySmall
                  .copyWith(color: colors.textPrimary)),
        ],
      ),
    );
  }
}
