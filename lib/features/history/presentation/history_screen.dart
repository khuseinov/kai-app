import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/design/theme/theme_extensions.dart';
import '../../../core/design/tokens/kai_spacing.dart';
import '../../chat/logic/chat_notifier.dart';
import '../data/history_remote_source.dart';
import '../logic/history_notifier.dart';

class HistoryScreen extends ConsumerWidget {
  const HistoryScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(historyNotifierProvider);
    final colors = context.kaiColors;

    return Scaffold(
      backgroundColor: colors.background,
      appBar: AppBar(
        title: const Text('История'),
        backgroundColor: colors.background,
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh_outlined),
            onPressed: () =>
                ref.read(historyNotifierProvider.notifier).loadSessions(),
          ),
        ],
      ),
      body: state.selectedSessionId != null
          ? _MessagesView(sessionId: state.selectedSessionId!)
          : _SessionListView(state: state),
    );
  }
}

class _SessionListView extends StatelessWidget {
  final HistoryState state;

  const _SessionListView({required this.state});

  @override
  Widget build(BuildContext context) {
    final colors = context.kaiColors;
    final typography = context.kaiTypography;

    if (state.isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (state.error != null) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(KaiSpacing.m),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(Icons.cloud_off_outlined, size: 48, color: colors.textTertiary),
              const SizedBox(height: KaiSpacing.s),
              Text(
                state.error!,
                style: typography.bodyMedium.copyWith(color: colors.textSecondary),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      );
    }

    if (state.sessions.isEmpty) {
      return Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.history, size: 48, color: colors.textTertiary),
            const SizedBox(height: KaiSpacing.s),
            Text(
              'История пуста',
              style: typography.titleMedium.copyWith(color: colors.textSecondary),
            ),
            const SizedBox(height: KaiSpacing.xxs),
            Text(
              'Ваши разговоры появятся здесь',
              style: typography.bodySmall.copyWith(color: colors.textTertiary),
            ),
          ],
        ),
      );
    }

    return Consumer(
      builder: (context, ref, _) => ListView.separated(
        itemCount: state.sessions.length,
        separatorBuilder: (_, __) =>
            Divider(color: colors.glassBorder, height: 1),
        itemBuilder: (context, index) {
          final session = state.sessions[index];
          return _SessionTile(
            session: session,
            onTap: () =>
                ref.read(historyNotifierProvider.notifier).selectSession(
                      session.sessionId,
                    ),
          );
        },
      ),
    );
  }
}

class _SessionTile extends StatelessWidget {
  final SessionSummary session;
  final VoidCallback onTap;

  const _SessionTile({required this.session, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final colors = context.kaiColors;
    final typography = context.kaiTypography;

    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(
          horizontal: KaiSpacing.m,
          vertical: KaiSpacing.s,
        ),
        child: Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    session.preview.isNotEmpty
                        ? session.preview
                        : 'Разговор',
                    style: typography.bodyLarge
                        .copyWith(color: colors.textPrimary),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: KaiSpacing.xxxs),
                  Row(
                    children: [
                      Text(
                        _formatDate(session.lastMessageAt),
                        style: typography.bodySmall
                            .copyWith(color: colors.textTertiary),
                      ),
                      const SizedBox(width: KaiSpacing.xs),
                      Text(
                        '·',
                        style: typography.bodySmall
                            .copyWith(color: colors.textTertiary),
                      ),
                      const SizedBox(width: KaiSpacing.xs),
                      Text(
                        '${session.messageCount} сообщ.',
                        style: typography.bodySmall
                            .copyWith(color: colors.textTertiary),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            Icon(Icons.chevron_right,
                size: 18, color: colors.textTertiary),
          ],
        ),
      ),
    );
  }

  String _formatDate(String iso) {
    if (iso.isEmpty) return '';
    final dt = DateTime.tryParse(iso);
    if (dt == null) return iso;
    final now = DateTime.now();
    final diff = now.difference(dt);
    if (diff.inDays == 0) return 'Сегодня';
    if (diff.inDays == 1) return 'Вчера';
    if (diff.inDays < 7) return '${diff.inDays} дн. назад';
    return '${dt.day.toString().padLeft(2, '0')}.'
        '${dt.month.toString().padLeft(2, '0')}.'
        '${dt.year}';
  }
}

class _MessagesView extends ConsumerWidget {
  final String sessionId;

  const _MessagesView({required this.sessionId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(historyNotifierProvider);
    final colors = context.kaiColors;
    final typography = context.kaiTypography;

    return Column(
      children: [
        // Back + Resume bar
        Container(
          color: colors.surface,
          padding: const EdgeInsets.symmetric(
            horizontal: KaiSpacing.s,
            vertical: KaiSpacing.xxs,
          ),
          child: Row(
            children: [
              IconButton(
                icon: const Icon(Icons.arrow_back),
                onPressed: () =>
                    ref.read(historyNotifierProvider.notifier).clearSelection(),
                tooltip: 'Назад',
              ),
              Expanded(
                child: Text(
                  'Просмотр сессии',
                  style: typography.labelMedium,
                ),
              ),
              if (!state.isLoadingMessages && state.selectedMessages.isNotEmpty)
                TextButton.icon(
                  icon: const Icon(Icons.chat_outlined, size: 16),
                  label: const Text('Продолжить'),
                  style: TextButton.styleFrom(
                    foregroundColor: colors.oceanPrimary,
                  ),
                  onPressed: () => _resumeSession(context, ref),
                ),
            ],
          ),
        ),

        Expanded(
          child: state.isLoadingMessages
              ? const Center(child: CircularProgressIndicator())
              : state.selectedMessages.isEmpty
                  ? Center(
                      child: Text(
                        'Нет сообщений',
                        style: typography.bodyMedium
                            .copyWith(color: colors.textTertiary),
                      ),
                    )
                  : ListView.builder(
                      padding: const EdgeInsets.all(KaiSpacing.m),
                      itemCount: state.selectedMessages.length,
                      itemBuilder: (context, index) {
                        final msg = state.selectedMessages[index];
                        return _MessageBubbleSimple(message: msg);
                      },
                    ),
        ),
      ],
    );
  }

  void _resumeSession(BuildContext context, WidgetRef ref) {
    final notifier = ref.read(historyNotifierProvider.notifier);
    final chatMessages = notifier.buildChatMessages(sessionId);

    ref.read(chatNotifierProvider.notifier).loadFromHistory(
          sessionId,
          chatMessages,
        );

    context.go('/chat');
  }
}

class _MessageBubbleSimple extends StatelessWidget {
  final HistoryMessage message;

  const _MessageBubbleSimple({required this.message});

  @override
  Widget build(BuildContext context) {
    final colors = context.kaiColors;
    final typography = context.kaiTypography;
    final isUser = message.role == 'user';

    return Align(
      alignment: isUser ? Alignment.centerRight : Alignment.centerLeft,
      child: Container(
        constraints: BoxConstraints(
          maxWidth: MediaQuery.of(context).size.width * 0.75,
        ),
        margin: const EdgeInsets.only(bottom: KaiSpacing.s),
        padding: const EdgeInsets.symmetric(
          horizontal: KaiSpacing.s,
          vertical: KaiSpacing.xs,
        ),
        decoration: BoxDecoration(
          color: isUser
              ? colors.oceanPrimary.withValues(alpha: 0.12)
              : colors.surfaceContainer,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: colors.glassBorder),
        ),
        child: Text(
          message.content,
          style: typography.bodySmall.copyWith(color: colors.textPrimary),
        ),
      ),
    );
  }
}
