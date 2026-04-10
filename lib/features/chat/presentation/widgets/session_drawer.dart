import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/design/components/kai_button.dart';
import '../../../../core/design/theme/theme_extensions.dart';
import '../../../../core/design/tokens/kai_spacing.dart';
import '../../../../core/design/tokens/kai_radii.dart';
import '../../domain/chat_session.dart';
import '../../logic/session_notifier.dart';
import '../../logic/chat_notifier.dart';

class SessionDrawer extends ConsumerWidget {
  const SessionDrawer({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final sessionState = ref.watch(sessionNotifierProvider);
    final colors = context.kaiColors;
    final typography = context.kaiTypography;

    return Drawer(
      backgroundColor: colors.background,
      child: SafeArea(
        child: Column(
          children: [
            // Header — New session button
            Padding(
              padding: const EdgeInsets.all(KaiSpacing.m),
              child: SizedBox(
                width: double.infinity,
                child: KaiButton(
                  label: 'Новый разговор',
                  icon: Icons.add,
                  onPressed: () {
                    final sessionNotifier =
                        ref.read(sessionNotifierProvider.notifier);
                    final chatNotifier =
                        ref.read(chatNotifierProvider.notifier);
                    final newId = sessionNotifier.createSession();
                    chatNotifier.newSession();
                    chatNotifier.setSession(newId);
                    Navigator.pop(context);
                  },
                  type: KaiButtonType.primary,
                ),
              ),
            ),
            Divider(color: colors.textTertiary.withValues(alpha: 0.2)),

            // Session list
            Expanded(
              child: sessionState.isLoading
                  ? const Center(child: CircularProgressIndicator())
                  : sessionState.sessions.isEmpty
                      ? _DrawerEmptyState(colors: colors, typography: typography)
                      : ListView.builder(
                          itemCount: sessionState.sessions.length,
                          padding: const EdgeInsets.symmetric(
                            vertical: KaiSpacing.xs,
                          ),
                          itemBuilder: (context, index) {
                            final session = sessionState.sessions[index];
                            final isActive =
                                session.id == sessionState.activeSessionId;
                            return _SessionTile(
                              session: session,
                              isActive: isActive,
                              onTap: () {
                                ref
                                    .read(sessionNotifierProvider.notifier)
                                    .switchSession(session.id);
                                ref
                                    .read(chatNotifierProvider.notifier)
                                    .setSession(session.id);
                                Navigator.pop(context);
                              },
                              onDelete: () {
                                ref
                                    .read(sessionNotifierProvider.notifier)
                                    .deleteSession(session.id);
                              },
                            );
                          },
                        ),
            ),

            // Footer
            const SizedBox(height: KaiSpacing.xs),
            Padding(
              padding: const EdgeInsets.only(
                left: KaiSpacing.m,
                right: KaiSpacing.m,
                bottom: KaiSpacing.s,
              ),
              child: Text(
                'Kai v0.1.0 · staging',
                style: typography.labelSmall.copyWith(
                  color: colors.textTertiary,
                  fontSize: 10,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _DrawerEmptyState extends StatelessWidget {
  const _DrawerEmptyState({
    required this.colors,
    required this.typography,
  });

  final dynamic colors;
  final dynamic typography;

  @override
  Widget build(BuildContext context) {
    final kaiColors = context.kaiColors;
    final kaiTypography = context.kaiTypography;

    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            Icons.chat_bubble_outline,
            size: 48,
            color: kaiColors.textTertiary,
          ),
          const SizedBox(height: KaiSpacing.s),
          Text(
            'Нет разговоров',
            style: kaiTypography.titleMedium.copyWith(
              color: kaiColors.textSecondary,
            ),
          ),
          const SizedBox(height: KaiSpacing.xxs),
          Text(
            'Начните новый разговор',
            style: kaiTypography.bodySmall.copyWith(
              color: kaiColors.textTertiary,
            ),
          ),
        ],
      ),
    );
  }
}

class _SessionTile extends StatelessWidget {
  final ChatSession session;
  final bool isActive;
  final VoidCallback onTap;
  final VoidCallback onDelete;

  const _SessionTile({
    required this.session,
    required this.isActive,
    required this.onTap,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    final colors = context.kaiColors;
    final typography = context.kaiTypography;

    return Dismissible(
      key: ValueKey(session.id),
      direction: DismissDirection.endToStart,
      onDismissed: (_) => onDelete(),
      background: Container(
        alignment: Alignment.centerRight,
        padding: const EdgeInsets.only(right: KaiSpacing.m),
        color: colors.error,
        child: Icon(Icons.delete_outline, color: colors.onPrimary),
      ),
      child: Material(
        color: isActive
            ? colors.primary.withValues(alpha: 0.08)
            : Colors.transparent,
        child: InkWell(
          onTap: onTap,
          child: Container(
            padding: const EdgeInsets.symmetric(
              horizontal: KaiSpacing.m,
              vertical: KaiSpacing.s,
            ),
            decoration: BoxDecoration(
              border: isActive
                  ? Border(
                      left: BorderSide(
                        color: colors.primary,
                        width: 3,
                      ),
                    )
                  : null,
            ),
            child: Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        session.title ?? 'Новый разговор',
                        style: typography.bodyLarge.copyWith(
                          color: isActive
                              ? colors.textPrimary
                              : colors.textSecondary,
                          fontWeight: isActive
                              ? FontWeight.w600
                              : FontWeight.w400,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: KaiSpacing.xxxs),
                      Text(
                        _formatDate(session.updatedAt),
                        style: typography.bodySmall.copyWith(
                          color: colors.textTertiary,
                        ),
                      ),
                    ],
                  ),
                ),
                IconButton(
                  icon: Icon(
                    Icons.delete_outline,
                    size: 20,
                    color: colors.textTertiary,
                  ),
                  onPressed: onDelete,
                  tooltip: 'Удалить',
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  String _formatDate(DateTime date) {
    final now = DateTime.now();
    final diff = now.difference(date);

    if (diff.inMinutes < 1) return 'Только что';
    if (diff.inHours < 1) return '${diff.inMinutes} мин. назад';
    if (diff.inDays < 1) return '${diff.inHours} ч. назад';
    if (diff.inDays < 7) return '${diff.inDays} дн. назад';

    return '${date.day.toString().padLeft(2, '0')}.'
        '${date.month.toString().padLeft(2, '0')}.'
        '${date.year}';
  }
}
