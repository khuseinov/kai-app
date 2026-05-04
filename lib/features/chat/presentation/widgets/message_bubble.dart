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
      return GestureDetector(
        onLongPressStart: (d) => showMessageActions(d.globalPosition),
        child: Padding(
          padding:
              const EdgeInsets.only(bottom: KaiSpacing.l, right: KaiSpacing.l),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Minimal AI Avatar
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
                    if (message.cognitiveStatus != null &&
                        message.cognitiveStatus!.isNotEmpty &&
                        message.status == 'typing') ...[
                      KaiCognitiveStatus(
                        currentStep: message.cognitiveStatus!,
                      ),
                      const SizedBox(height: 8),
                    ],
                    if (message.pendingConfirmation == true) ...[
                      _ApprovalNotice(type: message.confirmationType),
                      Builder(builder: (_) {
                        // Stale-button guard: hide actions unless this Kai
                        // message is the latest in the current session AND
                        // the message's session matches the active one.
                        // This prevents users from re-firing approve/reject
                        // on historical bubbles after navigation or restart.
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
                          onApprove: () => _sendConfirmation(ref, true),
                          onReject: () => _sendConfirmation(ref, false),
                        );
                      }),
                      const SizedBox(height: 8),
                    ],
                    // BE-AUT-4: Crisis banner — P0 SAFETY.
                    // Rendered before the response text so users see the
                    // helpline notice even before they read the answer.
                    if (message.crisisDetected == true)
                      _CrisisBanner(category: message.crisisCategory),

                    // BE-AUT-5: Special mode pill — Kai autonomously entered
                    // a special cognitive mode (S/M/D/X).
                    if (message.specialMode != null &&
                        message.specialMode!.isNotEmpty) ...[
                      _SpecialModePill(mode: message.specialMode!),
                      const SizedBox(height: 6),
                    ],

                    if (message.content.isNotEmpty)
                      MarkdownBody(
                        data: message.content,
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

class _ApprovalNotice extends StatelessWidget {
  final String? type;

  const _ApprovalNotice({this.type});

  @override
  Widget build(BuildContext context) {
    final colors = context.kaiColors;
    final typography = context.kaiTypography;
    final label = type == 'simulation'
        ? 'Требуется подтверждение симуляции'
        : 'Требуется подтверждение';

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
      decoration: BoxDecoration(
        color: colors.warning.withValues(alpha: 0.10),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: colors.warning.withValues(alpha: 0.35)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.verified_user_outlined, size: 14, color: colors.warning),
          const SizedBox(width: 6),
          Flexible(
            child: Text(
              label,
              style: typography.labelMedium.copyWith(color: colors.warning),
            ),
          ),
        ],
      ),
    );
  }
}

void _sendConfirmation(WidgetRef ref, bool approve) {
  final notifier = ref.read(chatNotifierProvider.notifier);
  // Backend `_CONFIRM_YES_RE` (services/kai-core/src/api/security_scan.py)
  // matches `\b(yes|allow|ok|proceed|legitimate|да|разреши|продолжи|легитимно)\b`.
  // "да" matches → simulation/injection_pending_confirmation is consumed as approval.
  // "отмена" deliberately does NOT match → backend falls through to denial branch.
  final text = approve ? 'да' : 'отмена';
  notifier.sendMessage(text);
}

// BE-AUT-4 ────────────────────────────────────────────────────────────────────

/// Full-width crisis banner. Shown when Kai's crisis-detection protocol
/// (B-14, Constitution §12) fires — before the response text, always visible.
class _CrisisBanner extends StatelessWidget {
  final String? category;

  const _CrisisBanner({this.category});

  @override
  Widget build(BuildContext context) {
    final colors = context.kaiColors;
    final typography = context.kaiTypography;

    return Container(
      width: double.infinity,
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: BoxDecoration(
        color: colors.error.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: colors.error.withValues(alpha: 0.4)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.emergency_outlined, size: 16, color: colors.error),
              const SizedBox(width: 6),
              Text(
                'Экстренная поддержка',
                style: typography.labelMedium
                    .copyWith(color: colors.error, fontWeight: FontWeight.bold),
              ),
            ],
          ),
          const SizedBox(height: 6),
          Text(
            'Телефон доверия: 8-800-2000-122 (бесплатно)\n'
            'Международная линия: +7 495 988-44-34',
            style: typography.bodySmall.copyWith(color: colors.error),
          ),
        ],
      ),
    );
  }
}

// BE-AUT-5 ────────────────────────────────────────────────────────────────────

/// Small pill shown when Kai autonomously entered a special cognitive mode.
/// Rendered above the answer text so the user understands WHY the response
/// looks different (preview-only, memory saved, explanation mode, etc.).
class _SpecialModePill extends StatelessWidget {
  final String mode;

  const _SpecialModePill({required this.mode});

  static const _labels = {
    'S': ('Симуляция', Icons.science_outlined),
    's': ('Симуляция', Icons.science_outlined),
    'M': ('Запомнил', Icons.bookmark_outlined),
    'm': ('Запомнил', Icons.bookmark_outlined),
    'D': ('Делегирую', Icons.fork_right_outlined),
    'd': ('Делегирую', Icons.fork_right_outlined),
    'X': ('Объясняю', Icons.auto_stories_outlined),
    'x': ('Объясняю', Icons.auto_stories_outlined),
  };

  @override
  Widget build(BuildContext context) {
    final colors = context.kaiColors;
    final typography = context.kaiTypography;
    final entry = _labels[mode];
    if (entry == null) return const SizedBox.shrink();
    final (label, icon) = entry;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: colors.stateThinking.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: colors.stateThinking.withValues(alpha: 0.35)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 12, color: colors.stateThinking),
          const SizedBox(width: 4),
          Text(
            label,
            style: typography.labelSmall
                .copyWith(color: colors.stateThinking, fontSize: 11),
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
