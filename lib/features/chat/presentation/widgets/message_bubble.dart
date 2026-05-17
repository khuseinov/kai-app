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
import 'message_detail_sheet.dart';
import 'safety_block_banner.dart';
import 'source_chips.dart';

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
                    // BUG-RENDER-GATE-1 (2026-05-17): previously gated on
                    // `message.status == 'typing'`, but the SSE `done` event
                    // flips status to `sent` before the user has had time to
                    // notice the indicator. status never transitions back,
                    // so KaiCognitiveStatus was almost never visible despite
                    // the backend actually emitting state events. Now the
                    // indicator stays as long as cognitiveStatus is set —
                    // we clear it via copyWith(cognitiveStatus: null) once
                    // the final message has rendered (status == 'sent'
                    // AND content is non-empty AND error is not set).
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
                      // APP-INJ-CONFIRM-1: show injection context when fragment present.
                      if (message.injectionFragment != null)
                        _InjectionWarningCard(
                          fragment: message.injectionFragment!,
                          source: message.injectionSource,
                        )
                      else
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
                          advisorTriggered: message.advisorTriggered,
                          onApprove: () => _sendConfirmation(ref, true),
                          onReject: () => _sendConfirmation(ref, false),
                        );
                      }),
                      const SizedBox(height: 8),
                    ],
                    // APP-SCOPE-ESC-1: scope escalation warning banner.
                    if ((message.scopeEscalationDetected ?? false) &&
                        message.scopeEscalationCategories.isNotEmpty)
                      _ScopeEscalationBanner(
                        categories: message.scopeEscalationCategories,
                        inheritanceViolation:
                            message.scopeInheritanceViolation ?? false,
                      ),

                    // STREAM-THINKING-1: o1-style reasoning trace above the
                    // answer. Streams in live as LLM emits thinking deltas.
                    if (message.thinking != null && message.thinking!.isNotEmpty) ...[
                      _ThinkingTrace(
                        text: message.thinking!,
                        streaming: message.status != 'sent',
                      ),
                      const SizedBox(height: KaiSpacing.xs),
                    ],

                    // Render main content (marker blocks stripped above).
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
                    // APP-SIM-CARD-1: S-loop structured simulation card
                    if (sloopContent != null) ...[
                      const SizedBox(height: KaiSpacing.xs),
                      _SimulationCard(sloopText: sloopContent),
                    ],

                    // APP-A1 / TOOL-PROV-1: tool source provenance chips
                    if (message.sources.isNotEmpty) ...[
                      const SizedBox(height: KaiSpacing.xs),
                      SourceChips(sources: message.sources),
                    ],

                    // APP-INJ-CONFIRM-1 / APP-A4: safety block banner
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

// APP-SCOPE-ESC-1 ─────────────────────────────────────────────────────────────

/// Warning card shown when Kai proposed an action in a category the user has
/// not explicitly consented to. Backend: alignment/scope.py (S3-SCOPE).
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

// APP-INJ-CONFIRM-1 ────────────────────────────────────────────────────────────

/// Shown instead of the generic _ApprovalNotice when pending_confirmation
/// was triggered by an injection signal (injection_fragment present).
/// Shows what was flagged and where it came from before asking to proceed.
class _InjectionWarningCard extends StatelessWidget {
  final String fragment;
  final String? source;

  const _InjectionWarningCard({required this.fragment, this.source});

  @override
  Widget build(BuildContext context) {
    final colors = context.kaiColors;
    final typography = context.kaiTypography;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
      decoration: BoxDecoration(
        color: colors.error.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: colors.error.withValues(alpha: 0.35)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.warning_amber_rounded, size: 14, color: colors.error),
              const SizedBox(width: 6),
              Flexible(
                child: Text(
                  source != null
                      ? 'Подозрительный фрагмент из $source'
                      : 'Подозрительный фрагмент',
                  style: typography.labelMedium.copyWith(
                    color: colors.error,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 4),
          Text(
            '«$fragment»',
            style: typography.bodySmall.copyWith(
              color: colors.textPrimary,
              fontStyle: FontStyle.italic,
            ),
            maxLines: 3,
            overflow: TextOverflow.ellipsis,
          ),
          const SizedBox(height: 4),
          Text(
            'Продолжить?',
            style:
                typography.labelSmall.copyWith(color: colors.textTertiary),
          ),
        ],
      ),
    );
  }
}

// APP-SIM-CARD-1 ───────────────────────────────────────────────────────────────

/// Structured S-loop simulation preview card. Shown when special_mode="S"
/// and the response contains a `[S-LOOP` marker. Backend: SIM-AUTO-1.
///
/// Parses the backend format:
///   Simulation: {action} -> heuristic success estimate X%, heuristic
///   expected cost $Y (Z p95), risks {level}: {breakdown}.
///   Recommendation: {text}. Proceed?
class _SimulationCard extends StatelessWidget {
  final String sloopText;

  const _SimulationCard({required this.sloopText});

  // ── Parsing ────────────────────────────────────────────────────────────────

  static final _successRe = RegExp(r'success estimate\s+([\d.]+%)');
  static final _costRe = RegExp(r'expected cost\s+\$([0-9.,]+)');
  static final _p95Re = RegExp(r'\(\$([0-9.,]+)\s+p95\)');
  static final _riskLevelRe = RegExp(r'risks\s+(low|medium|high|extreme)\s*:');
  static final _risksBodyRe =
      RegExp(r'risks\s+(?:low|medium|high|extreme)\s*:\s*([^.]+)\.');
  static final _recommendationRe = RegExp(r'Recommendation:\s*([^.]+)\.');

  static ({
    bool isHeuristic,
    String? successRate,
    String? cost,
    String? costP95,
    String? riskLevel,
    String? risksBreakdown,
    String? recommendation,
  }) _parse(String text) {
    final isHeuristic = text.contains('[S-LOOP HEURISTIC');
    return (
      isHeuristic: isHeuristic,
      successRate: _successRe.firstMatch(text)?.group(1),
      cost: _costRe.firstMatch(text)?.group(1),
      costP95: _p95Re.firstMatch(text)?.group(1),
      riskLevel: _riskLevelRe.firstMatch(text)?.group(1),
      risksBreakdown: _risksBodyRe.firstMatch(text)?.group(1)?.trim(),
      recommendation: _recommendationRe.firstMatch(text)?.group(1)?.trim(),
    );
  }

  // ── Risk level color / icon ────────────────────────────────────────────────

  static (Color, IconData) _riskStyle(String? level, dynamic colors) {
    return switch (level?.toLowerCase()) {
      'low' => (colors.success as Color, Icons.check_circle_outline),
      'medium' => (colors.warning as Color, Icons.warning_amber_outlined),
      'high' => (colors.error as Color, Icons.dangerous_outlined),
      'extreme' => (colors.error as Color, Icons.emergency_outlined),
      _ => (colors.textTertiary as Color, Icons.help_outline),
    };
  }

  static String _riskLabel(String? level) => switch (level?.toLowerCase()) {
        'low' => 'низкий',
        'medium' => 'средний',
        'high' => 'высокий',
        'extreme' => 'критический',
        _ => level ?? '—',
      };

  @override
  Widget build(BuildContext context) {
    final colors = context.kaiColors;
    final typography = context.kaiTypography;
    final p = _parse(sloopText);
    final (riskColor, riskIcon) = _riskStyle(p.riskLevel, colors);

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: colors.stateThinking.withValues(alpha: 0.06),
        borderRadius: BorderRadius.circular(10),
        border:
            Border.all(color: colors.stateThinking.withValues(alpha: 0.30)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // ── Header ───────────────────────────────────────────────────────
          Row(
            children: [
              Icon(Icons.science_outlined,
                  size: 15, color: colors.stateThinking),
              const SizedBox(width: 6),
              Text(
                p.isHeuristic
                    ? 'Kai S-Loop — эвристический прогноз'
                    : 'Kai S-Loop — симуляция',
                style: typography.labelMedium.copyWith(
                  color: colors.stateThinking,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),

          if (p.isHeuristic) ...[
            const SizedBox(height: 2),
            Text(
              'Приблизительная оценка. Проверьте актуальные данные перед принятием решений.',
              style: typography.labelSmall.copyWith(
                color: colors.textTertiary,
                fontSize: 10,
                fontStyle: FontStyle.italic,
              ),
            ),
          ],

          const SizedBox(height: 10),

          // ── Stats row ────────────────────────────────────────────────────
          Wrap(
            spacing: KaiSpacing.xs,
            runSpacing: KaiSpacing.xxs,
            children: [
              if (p.successRate != null)
                _SimStat(
                  icon: Icons.trending_up_outlined,
                  label: 'Успех',
                  value: p.successRate!,
                  color: colors.success,
                  typography: typography,
                ),
              if (p.cost != null)
                _SimStat(
                  icon: Icons.attach_money_outlined,
                  label: 'Стоимость',
                  value: '\$${p.cost!}${p.costP95 != null ? " (\$${p.costP95!} p95)" : ""}',
                  color: colors.oceanPrimary,
                  typography: typography,
                ),
              if (p.riskLevel != null)
                _SimStat(
                  icon: riskIcon,
                  label: 'Риск',
                  value: _riskLabel(p.riskLevel),
                  color: riskColor,
                  typography: typography,
                ),
            ],
          ),

          // ── Risk breakdown ───────────────────────────────────────────────
          if (p.risksBreakdown != null &&
              !p.risksBreakdown!.contains('no elevated')) ...[
            const SizedBox(height: 8),
            Text(
              p.risksBreakdown!,
              style: typography.bodySmall.copyWith(
                color: colors.textSecondary,
                fontSize: 11,
              ),
            ),
          ],

          // ── Recommendation ───────────────────────────────────────────────
          if (p.recommendation != null) ...[
            const SizedBox(height: 6),
            Text(
              p.recommendation!,
              style: typography.bodySmall.copyWith(
                color: colors.textPrimary,
                fontStyle: FontStyle.italic,
                fontSize: 11,
              ),
            ),
          ],
        ],
      ),
    );
  }
}

class _SimStat extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;
  final Color color;
  final dynamic typography;

  const _SimStat({
    required this.icon,
    required this.label,
    required this.value,
    required this.color,
    required this.typography,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: color.withValues(alpha: 0.30)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 11, color: color),
          const SizedBox(width: 4),
          Text(
            '$label: $value',
            style: (typography.labelSmall as TextStyle).copyWith(
              color: color,
              fontSize: 11,
            ),
          ),
        ],
      ),
    );
  }
}

enum _MessageAction { copy, retry }

/// STREAM-THINKING-1 (2026-05-17): inline reasoning trace shown above the
/// final answer when the backend streams `event: thinking` chunks.
///
/// Behaviour:
/// - While streaming (`streaming == true`): expanded by default with a
///   subtle pulsing dot so the user sees Kai's reasoning in real time.
/// - When done: auto-collapses to a single line; tap to re-expand.
/// - Italic, low-contrast (textTertiary) — never competes with the answer.
class _ThinkingTrace extends StatefulWidget {
  final String text;
  final bool streaming;

  const _ThinkingTrace({required this.text, required this.streaming});

  @override
  State<_ThinkingTrace> createState() => _ThinkingTraceState();
}

class _ThinkingTraceState extends State<_ThinkingTrace>
    with SingleTickerProviderStateMixin {
  bool _userCollapsed = false;
  late final AnimationController _pulse;

  @override
  void initState() {
    super.initState();
    _pulse = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    )..repeat(reverse: true);
  }

  @override
  void dispose() {
    _pulse.dispose();
    super.dispose();
  }

  bool get _expanded => widget.streaming && !_userCollapsed;

  @override
  Widget build(BuildContext context) {
    final colors = context.kaiColors;
    final typography = context.kaiTypography;

    return GestureDetector(
      onTap: () => setState(() => _userCollapsed = !_userCollapsed),
      child: Container(
        padding: const EdgeInsets.symmetric(
          horizontal: KaiSpacing.s,
          vertical: KaiSpacing.xs,
        ),
        decoration: BoxDecoration(
          border: Border(
            left: BorderSide(
              color: colors.cloudLight,
              width: 2,
            ),
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                if (widget.streaming) ...[
                  FadeTransition(
                    opacity: Tween<double>(begin: 0.3, end: 0.9).animate(_pulse),
                    child: Icon(
                      Icons.psychology_outlined,
                      size: 11,
                      color: colors.textTertiary,
                    ),
                  ),
                  const SizedBox(width: 6),
                ] else ...[
                  Icon(
                    Icons.psychology_outlined,
                    size: 11,
                    color: colors.textTertiary,
                  ),
                  const SizedBox(width: 6),
                ],
                Text(
                  widget.streaming
                      ? 'Kai размышляет...'
                      : (_userCollapsed ? 'Развернуть рассуждения' : 'Свернуть'),
                  style: typography.labelSmall.copyWith(
                    color: colors.textTertiary,
                    fontSize: 10,
                    letterSpacing: 0.3,
                  ),
                ),
                const Spacer(),
                if (!widget.streaming)
                  Icon(
                    _userCollapsed ? Icons.expand_more : Icons.expand_less,
                    size: 14,
                    color: colors.textTertiary,
                  ),
              ],
            ),
            if (_expanded || !_userCollapsed && !widget.streaming) ...[
              const SizedBox(height: KaiSpacing.xxs),
              AnimatedSize(
                duration: const Duration(milliseconds: 200),
                alignment: Alignment.topLeft,
                child: Text(
                  widget.text,
                  style: typography.bodySmall.copyWith(
                    color: colors.textSecondary,
                    fontStyle: FontStyle.italic,
                    fontSize: 12,
                    height: 1.45,
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

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
