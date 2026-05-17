import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_markdown/flutter_markdown.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/design/components/kai_cognitive_status.dart';
import '../../../../core/design/theme/theme_extensions.dart';
import '../../../../core/design/tokens/kai_spacing.dart';
import '../../../../core/models/chat_message.dart';
import '../../logic/chat_notifier.dart';
import 'approval_actions.dart';
import 'approval_notice.dart';
import 'message_detail_sheet.dart';
import 'safety_block_banner.dart';
import 'simulation_card.dart';
import 'source_chips.dart';
import 'thinking_trace.dart';

class MessageBubble extends ConsumerWidget {
  final ChatMessage message;
  final VoidCallback? onRetry;

  const MessageBubble({
    super.key,
    required this.message,
    this.onRetry,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final colors = context.kaiColors;
    final typography = context.kaiTypography;
    final isUser = message.isUser;

    void copyToClipboard() {
      Clipboard.setData(ClipboardData(text: message.content));
      HapticFeedback.mediumImpact();
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Скопировано'),
          duration: Duration(seconds: 1),
          behavior: SnackBarBehavior.floating,
        ),
      );
    }

    void showMessageActions(Offset globalPosition) {
      HapticFeedback.mediumImpact();
      final rect = RelativeRect.fromLTRB(
        globalPosition.dx,
        globalPosition.dy,
        globalPosition.dx,
        globalPosition.dy,
      );
      showMenu<_MessageAction>(
        context: context,
        position: rect,
        color: colors.surface,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        items: [
          PopupMenuItem(
            value: _MessageAction.copy,
            child: Row(
              children: [
                Icon(Icons.copy_rounded, size: 18, color: colors.textSecondary),
                const SizedBox(width: 10),
                Text('Копировать',
                    style: typography.bodyLarge
                        .copyWith(color: colors.textPrimary)),
              ],
            ),
          ),
          if (isUser && onRetry != null)
            PopupMenuItem(
              value: _MessageAction.retry,
              child: Row(
                children: [
                  Icon(Icons.refresh_rounded,
                      size: 18, color: colors.textSecondary),
                  const SizedBox(width: 10),
                  Text('Повторить',
                      style: typography.bodyLarge
                          .copyWith(color: colors.textPrimary)),
                ],
              ),
            ),
        ],
      ).then((action) {
        if (action == _MessageAction.copy) copyToClipboard();
        if (action == _MessageAction.retry) onRetry?.call();
      });
    }

    if (isUser) {
      return Padding(
        padding:
            const EdgeInsets.only(bottom: KaiSpacing.m, left: KaiSpacing.xxl),
        child: Align(
          alignment: Alignment.centerRight,
          child: GestureDetector(
            onLongPressStart: (d) => showMessageActions(d.globalPosition),
            child: Container(
              padding: const EdgeInsets.symmetric(
                horizontal: KaiSpacing.m,
                vertical: KaiSpacing.s,
              ),
              decoration: BoxDecoration(
                color: colors.surfaceContainer,
                borderRadius: BorderRadius.circular(20).copyWith(
                  bottomRight: const Radius.circular(4),
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    message.content,
                    style: typography.bodyLarge
                        .copyWith(color: colors.textPrimary),
                  ),
                  const SizedBox(height: 2),
                  _StatusIcon(status: message.status),
                ],
              ),
            ),
          ),
        ),
      );
    } else {
      // APP-SIM-CARD-1: pre-compute S-loop split.
      final sloopIdx = message.specialMode?.toUpperCase() == 'S'
          ? message.content.indexOf('[S-LOOP')
          : -1;
      final mainContent = sloopIdx >= 0
          ? message.content.substring(0, sloopIdx).trimRight()
          : message.content;
      final sloopContent = sloopIdx >= 0
          ? message.content.substring(sloopIdx).trim()
          : null;

      return GestureDetector(
        onLongPress: () {
          HapticFeedback.mediumImpact();
          MessageDetailSheet.show(context, message);
        },
        child: Padding(
          padding:
              const EdgeInsets.only(bottom: KaiSpacing.l, right: KaiSpacing.l),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                margin: const EdgeInsets.only(right: KaiSpacing.s, top: 4),
                padding: const EdgeInsets.all(4),
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: LinearGradient(
                    colors: [
                      colors.oceanPrimary,
                      colors.stateThinking,
                    ],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                ),
                child: Icon(
                  Icons.insights,
                  size: 14,
                  color: colors.onPrimary,
                ),
              ),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Kai',
                      style: typography.labelMedium.copyWith(
                        color: colors.textSecondary,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 4),
                    // BUG-RENDER-GATE-1: indicator stays until cognitiveStatus
                    // is cleared (done event sets it to null) — see chat_repository.
                    if (message.cognitiveStatus != null &&
                        message.cognitiveStatus!.isNotEmpty &&
                        message.status != 'sent') ...[
                      KaiCognitiveStatus(
                        currentStep: message.cognitiveStatus!,
                        step: message.currentStep,
                      ),
                      const SizedBox(height: 8),
                    ],
                    if (message.pendingConfirmation == true) ...[
                      if (message.injectionFragment != null)
                        InjectionWarningCard(
                          fragment: message.injectionFragment!,
                          source: message.injectionSource,
                        )
                      else
                        ApprovalNotice(type: message.confirmationType),
                      Builder(builder: (_) {
                        final chatState = ref.watch(chatNotifierProvider);
                        final notifier =
                            ref.read(chatNotifierProvider.notifier);
                        final isLatest = chatState.messages.isNotEmpty &&
                            chatState.messages.last.id == message.id;
                        final sameSession = message.sessionId == null ||
                            message.sessionId == notifier.currentSessionId;
                        if (!isLatest || !sameSession) {
                          return const SizedBox.shrink();
                        }
                        return ApprovalActions(
                          confirmationType: message.confirmationType,
                          isBusy: chatState.isLoading,
                          advisorTriggered: message.advisorTriggered,
                          onApprove: () => _sendConfirmation(ref, true),
                          onReject: () => _sendConfirmation(ref, false),
                        );
                      }),
                      const SizedBox(height: 8),
                    ],
                    // APP-SCOPE-ESC-1: scope escalation warning.
                    if ((message.scopeEscalationDetected ?? false) &&
                        message.scopeEscalationCategories.isNotEmpty)
                      _ScopeEscalationBanner(
                        categories: message.scopeEscalationCategories,
                        inheritanceViolation:
                            message.scopeInheritanceViolation ?? false,
                      ),

                    // STREAM-THINKING-1: o1-style reasoning trace.
                    if (message.thinking != null &&
                        message.thinking!.isNotEmpty) ...[
                      ThinkingTrace(
                        text: message.thinking!,
                        streaming: message.status != 'sent',
                      ),
                      const SizedBox(height: KaiSpacing.xs),
                    ],

                    if (mainContent.isNotEmpty)
                      MarkdownBody(
                        data: mainContent,
                        selectable: !kIsWeb,
                        styleSheet: MarkdownStyleSheet(
                          p: typography.bodyLarge.copyWith(
                            color: colors.textPrimary,
                            height: 1.5,
                          ),
                          h1: typography.headlineLarge
                              .copyWith(color: colors.textPrimary),
                          h2: typography.headlineMedium
                              .copyWith(color: colors.textPrimary),
                          h3: typography.headlineSmall
                              .copyWith(color: colors.textPrimary),
                          code: typography.bodyMedium.copyWith(
                            backgroundColor: colors.surfaceContainer,
                            color: colors.oceanPrimary,
                            fontFamily: 'monospace',
                          ),
                          codeblockDecoration: BoxDecoration(
                            color: colors.surfaceContainer,
                            borderRadius: BorderRadius.circular(8),
                          ),
                        ),
                      ),
                    if (sloopContent != null) ...[
                      const SizedBox(height: KaiSpacing.xs),
                      SimulationCard(sloopText: sloopContent),
                    ],

                    if (message.sources.isNotEmpty) ...[
                      const SizedBox(height: KaiSpacing.xs),
                      SourceChips(sources: message.sources),
                    ],

                    if (message.blockReason != null ||
                        message.injectionFragment != null) ...[
                      const SizedBox(height: KaiSpacing.xs),
                      SafetyBlockBanner(latestMessage: message),
                    ],
                  ],
                ),
              ),
            ],
          ),
        ),
      );
    }
  }
}

void _sendConfirmation(WidgetRef ref, bool approve) {
  final notifier = ref.read(chatNotifierProvider.notifier);
  // "да" matches backend `_CONFIRM_YES_RE`; "отмена" falls to denial branch.
  final text = approve ? 'да' : 'отмена';
  notifier.sendMessage(text);
}

// APP-SCOPE-ESC-1 ─────────────────────────────────────────────────────────────

class _ScopeEscalationBanner extends StatelessWidget {
  final List<String> categories;
  final bool inheritanceViolation;

  const _ScopeEscalationBanner({
    required this.categories,
    required this.inheritanceViolation,
  });

  static String _catLabel(String c) => switch (c.toLowerCase()) {
        'booking' => 'бронирование',
        'financial_transfer' => 'финансовый перевод',
        'personal_data_access' => 'доступ к личным данным',
        'external_api_call' => 'внешний запрос',
        _ => c.replaceAll('_', ' '),
      };

  @override
  Widget build(BuildContext context) {
    final colors = context.kaiColors;
    final typography = context.kaiTypography;

    return Container(
      width: double.infinity,
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
      decoration: BoxDecoration(
        color: colors.warning.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: colors.warning.withValues(alpha: 0.35)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                inheritanceViolation
                    ? Icons.swap_horiz_outlined
                    : Icons.fence_outlined,
                size: 14,
                color: colors.warning,
              ),
              const SizedBox(width: 6),
              Text(
                'Kai вышел за рамки',
                style: typography.labelMedium.copyWith(
                  color: colors.warning,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          const SizedBox(height: 4),
          Wrap(
            spacing: 4,
            runSpacing: 2,
            children: categories
                .map((c) => Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 6, vertical: 2),
                      decoration: BoxDecoration(
                        color: colors.warning.withValues(alpha: 0.12),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Text(
                        _catLabel(c),
                        style: typography.labelSmall.copyWith(
                          color: colors.warning,
                          fontSize: 10,
                        ),
                      ),
                    ))
                .toList(),
          ),
        ],
      ),
    );
  }
}

enum _MessageAction { copy, retry }

class _StatusIcon extends StatelessWidget {
  final String status;
  const _StatusIcon({required this.status});

  @override
  Widget build(BuildContext context) {
    final colors = context.kaiColors;

    final (icon, color) = switch (status) {
      'queued' => (Icons.schedule_rounded, colors.textTertiary),
      'sending' => (Icons.radio_button_unchecked, colors.textTertiary),
      'failed' => (Icons.error_outline_rounded, colors.error),
      _ => (Icons.done_rounded, colors.textTertiary),
    };

    return Icon(icon, size: 12, color: color);
  }
}
