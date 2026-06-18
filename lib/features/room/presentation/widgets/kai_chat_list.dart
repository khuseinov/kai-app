import 'package:flutter/material.dart';
import 'package:kai_app/design_system/atoms/atoms.dart';
import 'package:kai_app/design_system/primitives/primitives.dart';
import 'package:kai_app/design_system/theme/kai_theme.dart';
import 'package:kai_app/design_system/tokens/kai_tokens.dart';
import 'package:kai_app/features/room/presentation/widgets/cards/kai_alert_card.dart';
import 'package:kai_app/features/room/presentation/widgets/cards/kai_care_block.dart';
import 'package:kai_app/features/room/presentation/widgets/chat_bubbles/kai_kai_bubble.dart';
import 'package:kai_app/features/room/presentation/widgets/chat_bubbles/kai_system_bubble.dart';
import 'package:kai_app/features/room/presentation/widgets/chat_bubbles/kai_user_bubble.dart';
import 'package:kai_app/l10n/app_localizations.dart';

// Re-export the frame enum so screens importing this organism don't need a
// separate import.  The enum is defined here (v3-side) and is identical in
// shape to the v2 RoomFrame so the W4 screen migration is a near-drop-in.
export 'kai_chat_list.dart' show RoomFrame;

/// Room frames — describes which visual configuration of the chat surface
/// is rendered.
enum RoomFrame {
  /// No messages yet; shows Kai glyph + suggestion chips.
  empty,

  /// Live conversation; messages are shown.
  live,

  /// Nav panel is open; chat content is dimmed to 25% opacity, non-interactive.
  panel,

  /// Compose island is expanded; chat content has a dark scrim overlay.
  compose,

  /// Streaming response in progress; shows animated tide bar at top.
  streaming,

  /// Error state; shows retry prompt below existing messages.
  error,
}

/// v3 organism: the scrollable chat message list.
///
/// Composes v3 molecules/atoms instead of v2 bubbles:
///   - `role == 'user'`   → [KaiUserBubble]
///   - `role == 'kai'`    → [KaiKaiBubble] (with optional sources)
///   - `role == 'system'` → [KaiSystemBubble]
///   - `role == 'alert'`  → [KaiAlertCard]
///   - `role == 'care'`   → [KaiCareBlock]
///
/// Audit fix (R1): the v2 bespoke coral retry pill is replaced with
/// `KaiButton.ghost(tone: KaiButtonTone.negative, pill: true, ...)`.
///
/// Animation controllers:
///   - Tide bar (10→22 px, 1.6 s ease-in-out reverse) — maintained here
///     because the streaming tide-bar is part of the frame layout, distinct
///     from the caret inside [KaiKaiBubble].
///   - The streaming caret is now built into
///     `KaiKaiBubble(streaming: true)` — no separate cursor controller is
///     needed here. The v2 `_cursorController` is intentionally removed.
///
/// Public API mirrors the v2 [ChatList] so the W4 screen migration is a
/// near-drop-in:
/// ```dart
/// KaiChatList(
///   frame: RoomFrame.streaming,
///   messages: messages,
///   partialContent: partial,
///   onRetry: _retry,
/// )
/// ```
class KaiChatList extends StatefulWidget {
  const KaiChatList({
    required this.frame,
    this.messages = const [],
    this.onRetry,
    this.partialContent,
    this.thinkingStep,
    this.bottomPadding = 88.0,
    super.key,
  });

  final RoomFrame frame;

  /// Each map must contain `role` ('user'|'kai'|'system'|'alert'|'care') and
  /// `content` (String).  For 'alert' maps a `alertType` key (String matching
  /// [KaiAlertType] name) is optional — defaults to 'neutral'.
  final List<Map<String, dynamic>> messages;
  final VoidCallback? onRetry;

  /// Partial Kai response text during streaming.  Null = empty streaming
  /// bubble.
  final String? partialContent;

  /// Active thinking step label (State 2). Null when not in a named step.
  final String? thinkingStep;

  /// Bottom padding to reserve space for compose island.
  final double bottomPadding;

  @override
  State<KaiChatList> createState() => _KaiChatListState();
}

class _KaiChatListState extends State<KaiChatList> {

  @override
  Widget build(BuildContext context) {
    switch (widget.frame) {
      case RoomFrame.empty:
        return _EmptyFrame(messages: widget.messages);
      case RoomFrame.live:
        return _LiveFrame(messages: widget.messages, bottomPadding: widget.bottomPadding);
      case RoomFrame.panel:
        return IgnorePointer(
          child: Opacity(
            opacity: 0.25, // canon: panel dims chat to 25 %
            child: _LiveFrame(messages: widget.messages, bottomPadding: widget.bottomPadding),
          ),
        );
      case RoomFrame.compose:
        return Stack(
          children: [
            _LiveFrame(messages: widget.messages, bottomPadding: widget.bottomPadding),
            // canon: compose scrim rgba(0,0,0,0.18)
            Container(color: Colors.black.withValues(alpha: 0.18)),
          ],
        );
      case RoomFrame.streaming:
        return _LiveFrame(
          messages: widget.messages,
          bottomPadding: widget.bottomPadding,
          isStreaming: true,
          thinkingStep: widget.thinkingStep,
          partialContent: widget.partialContent,
        );
      case RoomFrame.error:
        return _ErrorFrame(
          messages: widget.messages,
          bottomPadding: widget.bottomPadding,
          onRetry: widget.onRetry,
        );
    }
  }
}

// ─── Helpers ─────────────────────────────────────────────────────────────────

/// Maps a single message map to the appropriate v3 molecule widget.
///
/// Mapping:
/// - `role == 'user'`   → [KaiUserBubble]
/// - `role == 'kai'`    → [KaiKaiBubble] (no sources; streaming: false)
/// - `role == 'system'` → [KaiSystemBubble]
/// - `role == 'alert'`  → [KaiAlertCard]
/// - `role == 'care'`   → [KaiCareBlock]
/// - fallback           → [KaiKaiBubble]
Widget _buildMessageWidget(Map<String, dynamic> msg) {
  final role = msg['role'] as String? ?? 'kai';
  final content = msg['content'] as String? ?? '';

  switch (role) {
    case 'user':
      return KaiUserBubble(text: content);
    case 'system':
      return KaiSystemBubble(content);
    case 'alert':
      final typeStr = msg['alertType'] as String? ?? 'neutral';
      final alertType = KaiAlertType.values.firstWhere(
        (e) => e.name == typeStr,
        orElse: () => KaiAlertType.neutral,
      );
      return KaiAlertCard(
        type: alertType,
        title: content,
        body: msg['body'] as String?,
        time: msg['time'] as String?,
        cta: msg['cta'] as String?,
        onCtaTap: msg['onCtaTap'] as VoidCallback?,
      );
    case 'care':
      return KaiCareBlock(
        heading: content,
        body: msg['body'] as String? ?? '',
      );
    case 'kai':
    default:
      return KaiKaiBubble(
        text: content,
        sourcesLabel: msg['sourcesLabel'] as String?,
      );
  }
}

// ─── Empty frame ─────────────────────────────────────────────────────────────

class _EmptyFrame extends StatelessWidget {
  const _EmptyFrame({required this.messages});

  final List<Map<String, dynamic>> messages;

  @override
  Widget build(BuildContext context) {
    final tokens = KaiTheme.of(context);
    final l10n = AppLocalizations.of(context);
    final scale = context.scale;
    final textScale = context.textScale;
    return Center(
      child: Padding(
        padding: EdgeInsets.symmetric(
          horizontal: 22 * scale, // canon: 22px (between s5=20 and s6=24)
          vertical: KaiSpace.s4 * scale,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Title — Manrope 26/w600/h1.2/ls-0.022em ink1
            Text(
              l10n.emptyTitle,
              textAlign: TextAlign.center,
              style: TextStyle(
                fontFamily: 'Manrope',
                fontSize: 28.5 * textScale, // canon: 28.5px
                fontWeight: FontWeight.w600,
                height: 1.2, // canon: line-height 1.2
                letterSpacing: 28.5 * -0.022 * textScale,
                color: tokens.colors.ink1,
              ),
            ),
            SizedBox(height: 6 * scale), // canon: 6px gap
            // Subtitle — Manrope 13.5/w400/h1.5/ls-0.005em ink3
            Text(
              l10n.emptySubtitle,
              textAlign: TextAlign.center,
              style: TextStyle(
                fontFamily: 'Manrope',
                fontSize: 15.0 * textScale, // canon: 15.0px
                fontWeight: FontWeight.w400,
                height: 1.5,
                letterSpacing: 15.0 * -0.005 * textScale,
                color: tokens.colors.ink3,
              ),
            ),
            SizedBox(height: 8 * scale), // canon: margin-top 8px before chips
            // Suggestion chips — column gap 8px (canon: .suggest)
            _SuggestionChip(
              question: l10n.suggestionVisaQuestion,
              hint: l10n.suggestionVisaHint,
            ),
            const SizedBox(height: 8),
            _SuggestionChip(
              question: l10n.suggestionTripQuestion,
              hint: l10n.suggestionTripHint,
            ),
            const SizedBox(height: 8),
            _SuggestionChip(
              question: l10n.suggestionRecommendationsQuestion,
              hint: l10n.suggestionRecommendationsHint,
            ),
          ],
        ),
      ),
    );
  }
}

/// HTML canon: .f01 .sugg — surface-2 bg, 1 px line border, r12, padding 11×14.
/// Two rows: .q (Manrope 13 w500 ink1 ls -0.005em) + .hint (JetBrainsMono 11 ink3).
class _SuggestionChip extends StatelessWidget {
  const _SuggestionChip({required this.question, required this.hint});

  final String question;
  final String hint;

  @override
  Widget build(BuildContext context) {
    final tokens = KaiTheme.of(context);
    final scale = context.scale;
    final textScale = context.textScale;
    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: 14 * scale, // canon: 14px
        vertical: 11 * scale, // canon: 11px
      ),
      decoration: BoxDecoration(
        color: tokens.colors.surface2, // canon: surface-2
        borderRadius: KaiRadius.br12 * scale, // canon: 12px — exact
        border: Border.all(color: tokens.colors.line),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // .q — Manrope 13 w500 ink1 ls -0.005em
          Text(
            question,
            style: TextStyle(
              fontFamily: 'Manrope',
              fontSize: 14.5 * textScale, // canon: 14.5px
              fontWeight: FontWeight.w500,
              letterSpacing: 14.5 * -0.005 * textScale,
              color: tokens.colors.ink1,
            ),
          ),
          SizedBox(height: 1 * scale), // canon: gap 1px between q and hint
          // .hint — JetBrainsMono 11 ink3
          Text(
            hint,
            style: TextStyle(
              fontFamily: 'JetBrainsMono',
              fontSize: 12 * textScale, // canon: 12px
              fontWeight: FontWeight.w400,
              color: tokens.colors.ink3,
            ),
          ),
        ],
      ),
    );
  }
}

// ─── Live frame ───────────────────────────────────────────────────────────────

class _LiveFrame extends StatelessWidget {
  const _LiveFrame({
    required this.messages,
    this.bottomPadding = 8.0,
    this.isStreaming = false,
    this.thinkingStep,
    this.partialContent,
  });

  final List<Map<String, dynamic>> messages;
  final double bottomPadding;
  final bool isStreaming;
  final String? thinkingStep;
  final String? partialContent;

  @override
  Widget build(BuildContext context) {
    if (messages.isEmpty && !isStreaming) {
      return _EmptyFrame(messages: messages);
    }
    final tokens = KaiTheme.of(context);
    final l10n = AppLocalizations.of(context);
    final scale = context.scale;
    final textScale = context.textScale;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        // Day header — JetBrainsMono 9 ink3 uppercase ls 0.1em, margin-top 4px
        Padding(
          padding: EdgeInsets.only(top: 4 * scale), // canon: margin-top 4px
          child: Text(
            '— ${l10n.today} —',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontFamily: 'JetBrainsMono',
              fontSize: 10 * textScale, // canon: 10px
              fontWeight: FontWeight.w400,
              letterSpacing: 10 * 0.1 * textScale, // canon: 0.1em
              color: tokens.colors.ink3,
            ),
          ),
        ),
        Expanded(
          child: ListView.builder(
            reverse: true,
            padding: EdgeInsets.only(
              left: KaiSpace.s4,
              right: KaiSpace.s4,
              top: KaiSpace.s2,
              bottom: bottomPadding,
            ),
            itemCount: messages.isEmpty ? (isStreaming ? 1 : 0) : messages.length,
            itemBuilder: (context, index) {
              // Build bottom-up: index 0 = last message (pending/streaming response when isStreaming is true)
              final isLast = index == 0;
              final msg = messages.isEmpty ? null : messages[messages.length - 1 - index];

              if (isStreaming && isLast) {
                // ponytail: render the streaming bubble inline inside the list to prevent layout resizing/flickering
                final content = partialContent ?? (msg != null ? msg['content'] as String? : null) ?? '';
                final statusSuffix = content.isNotEmpty
                    ? null
                    : (thinkingStep != null && thinkingStep!.isNotEmpty)
                        ? thinkingStep
                        : l10n.streamingStatusThinking;

                return Padding(
                  padding: const EdgeInsets.symmetric(vertical: KaiSpace.s1),
                  // ponytail: use unified KaiKaiBubble directly instead of separate custom widgets to avoid font/padding mismatch
                  child: KaiKaiBubble(
                    text: content,
                    streaming: true,
                    statusSuffix: statusSuffix,
                  ),
                );
              }

              return Padding(
                padding: const EdgeInsets.symmetric(vertical: KaiSpace.s1),
                child: _buildMessageWidget(msg!),
              );
            },
          ),
        ),
      ],
    );
  }
}



// ─── Error frame ─────────────────────────────────────────────────────────────

/// HTML canon: room.html § F06 Error frame.
///
/// Previous messages (Expanded) + Kai-bubble-like error container at bottom.
///
/// Audit fix (R1): the bespoke coral GestureDetector+Container retry pill from
/// v2 is replaced with [KaiButton.ghost] (`tone: KaiButtonTone.negative,
/// pill: true`) — the closest v3 token-correct equivalent.
class _ErrorFrame extends StatelessWidget {
  const _ErrorFrame({
    required this.messages,
    required this.bottomPadding,
    this.onRetry,
  });

  final List<Map<String, dynamic>> messages;
  final double bottomPadding;
  final VoidCallback? onRetry;

  @override
  Widget build(BuildContext context) {
    final c = KaiTheme.of(context).colors;
    final l10n = AppLocalizations.of(context);
    final scale = context.scale;
    final textScale = context.textScale;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Expanded(
          child: _LiveFrame(
            messages: messages,
            bottomPadding: 16 * scale, // Small bottom padding since it is above the error container
          ),
        ),
        Padding(
          padding: EdgeInsets.only(bottom: bottomPadding),
          child: Padding(
            padding: EdgeInsets.fromLTRB(18 * scale, 8 * scale, 18 * scale, 0),
            child: Align(
            alignment: Alignment.centerLeft,
            child: LayoutBuilder(
              builder: (context, constraints) {
                return ConstrainedBox(
                  constraints: BoxConstraints(
                    maxWidth: constraints.maxWidth * 0.92, // canon: 92% width
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      // .who row — TideGlyph 12×3 + "KAI" mono 9 ink3
                      Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          KaiGradientBar(
                            width: 12 * scale, // canon: 12px for error who-glyph
                            height: 3 * scale, // canon: 3px
                          ),
                          SizedBox(width: 6 * scale), // canon: 6px gap
                          Text(
                            'KAI',
                            style: TextStyle(
                              fontFamily: 'JetBrainsMono',
                              fontSize: 10 * textScale, // canon: 10px
                              fontWeight: FontWeight.w400,
                              height: 1.4,
                              letterSpacing: 10 * 0.08 * textScale, // canon: 0.08em
                              color: c.ink3,
                            ),
                          ),
                        ],
                      ),
                      SizedBox(height: 5 * scale), // canon: 5px
                      // .err-bub container
                      Container(
                        decoration: BoxDecoration(
                          color: c.negativeWash,
                          borderRadius: BorderRadius.circular(14 * scale), // canon: 14px
                          border: Border.all(
                            // canon: rgba(196,74,60,0.15)
                            color: const Color.fromRGBO(196, 74, 60, 0.15),
                          ),
                        ),
                        padding: EdgeInsets.symmetric(
                          horizontal: 13 * scale, // canon: 13px
                          vertical: 11 * scale, // canon: 11px
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            // .eh — icon circle + title
                            Row(
                              children: [
                                Container(
                                  width: 18 * scale, // canon: 18×18 circle
                                  height: 18 * scale,
                                  decoration: const BoxDecoration(
                                    // canon: rgba(196,74,60,0.12)
                                    color: Color.fromRGBO(196, 74, 60, 0.12),
                                    shape: BoxShape.circle,
                                  ),
                                  child: Center(
                                    child: KaiIcon(
                                      KaiIconName.alert,
                                      size: 10 * scale, // canon: 10px icon
                                      color: c.negative,
                                    ),
                                  ),
                                ),
                                SizedBox(width: 6 * scale), // canon: 6px
                                Text(
                                  l10n.errorTitle,
                                  style: TextStyle(
                                    fontFamily: 'Manrope',
                                    fontSize: 13 * textScale, // canon: 13px
                                    fontWeight: FontWeight.w600,
                                    letterSpacing: 13 * -0.005 * textScale,
                                    color: c.negative,
                                  ),
                                ),
                              ],
                            ),
                            SizedBox(height: 7 * scale), // canon: 7px
                            // .eb — body text Manrope 11.5 ink2 h1.45
                            Text(
                              l10n.errorBody,
                              style: TextStyle(
                                fontFamily: 'Manrope',
                                fontSize: 12.5 * textScale, // canon: 12.5px
                                fontWeight: FontWeight.w400,
                                height: 1.45, // canon: line-height 1.45
                                color: c.ink2,
                              ),
                            ),
                            SizedBox(height: 9 * scale), // canon: 9px
                            // .retry-row — KaiButton.ghost (R1 audit fix) + hint
                            Row(
                              children: [
                                // R1 fix: KaiButton.ghost replaces the bespoke
                                // coral GestureDetector+Container pill from v2.
                                // tone: negative → coral border + text.
                                // pill: true    → brPill corners.
                                KaiButton.ghost(
                                  label: l10n.retry,
                                  onPressed: onRetry,
                                  tone: KaiButtonTone.negative,
                                  pill: true,
                                ),
                                SizedBox(width: 8 * scale), // canon: 8px gap
                                Text(
                                  l10n.errorRetryHint,
                                  style: TextStyle(
                                    fontFamily: 'JetBrainsMono',
                                    fontSize: 11 * textScale, // canon: 11px
                                    fontWeight: FontWeight.w400,
                                    color: c.ink4,
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
            ),
          ),
        ),
        ),
      ],
    );
  }
}
