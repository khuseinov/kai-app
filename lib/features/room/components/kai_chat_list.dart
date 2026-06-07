import 'package:flutter/material.dart';
import 'package:kai_app/l10n/app_localizations.dart';
import 'chat_bubbles/kai_user_bubble.dart';
import 'chat_bubbles/kai_kai_bubble.dart';
import 'chat_bubbles/kai_system_bubble.dart';
import 'cards/kai_alert_card.dart';
import 'cards/kai_care_block.dart';

import '../../../design_system/theme/kai_theme.dart';
import '../../../design_system/tokens/kai_tokens.dart';
import '../../../design_system/atoms/atoms.dart';
import '../../../design_system/primitives/primitives.dart';

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

class _KaiChatListState extends State<KaiChatList>
    with SingleTickerProviderStateMixin {
  // Tide bar: 1.6 s ease-in-out reverse loop (HTML canon room.html § F05).
  late final AnimationController _tideBarController;

  @override
  void initState() {
    super.initState();
    _tideBarController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1600), // canon: 1.6 s
    );
    _syncStream();
  }

  void _syncStream() {
    if (widget.frame == RoomFrame.streaming) {
      if (!_tideBarController.isAnimating) {
        _tideBarController.repeat(reverse: true);
      }
    } else {
      if (_tideBarController.isAnimating) _tideBarController.stop();
    }
  }

  @override
  void didUpdateWidget(covariant KaiChatList old) {
    super.didUpdateWidget(old);
    if (old.frame != widget.frame) _syncStream();
  }

  @override
  void dispose() {
    _tideBarController.dispose();
    super.dispose();
  }

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
        return _StreamingFrame(
          messages: widget.messages,
          partialContent: widget.partialContent ?? '',
          thinkingStep: widget.thinkingStep,
          tideBarController: _tideBarController,
          bottomPadding: widget.bottomPadding,
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
    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(
          horizontal: 22, // canon: 22px (between s5=20 and s6=24)
          vertical: KaiSpace.s4,
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
                fontSize: 26, // canon: 26px (off-scale literal)
                fontWeight: FontWeight.w600,
                height: 1.2, // canon: line-height 1.2
                letterSpacing: 26 * -0.022, // canon: -0.022em
                color: tokens.colors.ink1,
              ),
            ),
            const SizedBox(height: 6), // canon: 6px gap
            // Subtitle — Manrope 13.5/w400/h1.5/ls-0.005em ink3
            Text(
              l10n.emptySubtitle,
              textAlign: TextAlign.center,
              style: TextStyle(
                fontFamily: 'Manrope',
                fontSize: 13.5, // canon: 13.5px
                fontWeight: FontWeight.w400,
                height: 1.5,
                letterSpacing: 13.5 * -0.005,
                color: tokens.colors.ink3,
              ),
            ),
            const SizedBox(height: 8), // canon: margin-top 8px before chips
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
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: 14, // canon: 14px
        vertical: 11, // canon: 11px
      ),
      decoration: BoxDecoration(
        color: tokens.colors.surface2, // canon: surface-2
        borderRadius: KaiRadius.br12, // canon: 12px — exact
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
              fontSize: 13, // canon: 13px
              fontWeight: FontWeight.w500,
              letterSpacing: 13 * -0.005,
              color: tokens.colors.ink1,
            ),
          ),
          const SizedBox(height: 1), // canon: gap 1px between q and hint
          // .hint — JetBrainsMono 11 ink3
          Text(
            hint,
            style: TextStyle(
              fontFamily: 'JetBrainsMono',
              fontSize: 11, // canon: 11px
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
  const _LiveFrame({required this.messages, this.bottomPadding = 8.0});

  final List<Map<String, dynamic>> messages;
  final double bottomPadding;

  @override
  Widget build(BuildContext context) {
    if (messages.isEmpty) {
      return _EmptyFrame(messages: messages);
    }
    final tokens = KaiTheme.of(context);
    final l10n = AppLocalizations.of(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        // Day header — JetBrainsMono 9 ink3 uppercase ls 0.1em, margin-top 4px
        Padding(
          padding: const EdgeInsets.only(top: 4), // canon: margin-top 4px
          child: Text(
            '— ${l10n.today} —',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontFamily: 'JetBrainsMono',
              fontSize: 9, // canon: 9px
              fontWeight: FontWeight.w400,
              letterSpacing: 9 * 0.1, // canon: 0.1em
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
            itemCount: messages.length,
            itemBuilder: (context, index) {
              // Build bottom-up: index 0 = last message
              final msg = messages[messages.length - 1 - index];
              return Padding(
                padding: const EdgeInsets.symmetric(vertical: KaiSpace.s1),
                child: _buildMessageWidget(msg),
              );
            },
          ),
        ),
      ],
    );
  }
}

// ─── Streaming frame ──────────────────────────────────────────────────────────

/// HTML canon: room.html § F05 Streaming frame.
///
/// Shows previous messages via [_LiveFrame] (Expanded) +
/// a streaming indicator at bottom.
///
/// Three streaming states:
///   State 1 (думаю):       partialContent empty, thinkingStep null
///                          → tide bar + "KAI · думаю"
///   State 2 (ищу шаг):    partialContent empty, thinkingStep not null
///                          → tide bar + "KAI · ищу информацию о рейсах"
///   State 3 (текст идёт): partialContent not empty
///                          → tide bar + "KAI" + streamed text + blinking caret
class _StreamingFrame extends StatelessWidget {
  const _StreamingFrame({
    required this.messages,
    required this.partialContent,
    required this.tideBarController,
    required this.bottomPadding,
    this.thinkingStep,
  });

  final List<Map<String, dynamic>> messages;
  final String partialContent;
  final AnimationController tideBarController;
  final double bottomPadding;
  final String? thinkingStep;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    // Exclude the last message (the Kai response currently streaming/pending)
    // from the previous messages list so it doesn't get rendered twice.
    final previousMessages = messages.isNotEmpty
        ? messages.sublist(0, messages.length - 1)
        : messages;

    // Resolve which status suffix to show:
    //   State 3 (text arriving) → no suffix, show text inline
    //   State 2 (named step)    → thinkingStep label
    //   State 1 (waiting)       → l10n.streamingStatusThinking ("думаю")
    final statusSuffix = partialContent.isNotEmpty
        ? null
        : (thinkingStep != null && thinkingStep!.isNotEmpty)
            ? thinkingStep
            : l10n.streamingStatusThinking;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        if (previousMessages.isNotEmpty)
          Expanded(
            child: _LiveFrame(
              messages: previousMessages,
              bottomPadding: 16.0, // Small bottom padding since it is above the streaming bubble
            ),
          )
        else
          const Spacer(),
        // Single unified streaming row — no nested KaiKaiBubble to avoid
        // duplicate KAI labels.
        Padding(
          padding: EdgeInsets.only(bottom: bottomPadding),
          child: _StreamingKaiBubble(
            partialContent: partialContent,
            tideBarController: tideBarController,
            statusSuffix: statusSuffix,
          ),
        ),
      ],
    );
  }
}

/// Unified streaming Kai bubble — ONE animated tide bar row +
/// either a status suffix (States 1 & 2) or streamed text + caret (State 3).
///
/// Deliberately does NOT embed [KaiKaiBubble] to avoid double "KAI" labels.
class _StreamingKaiBubble extends StatefulWidget {
  const _StreamingKaiBubble({
    required this.partialContent,
    required this.tideBarController,
    this.statusSuffix,
  });

  final String partialContent;
  final AnimationController tideBarController;

  /// Status suffix shown next to "KAI" for States 1 & 2.
  /// Null in State 3 (text is rendered inline instead).
  final String? statusSuffix;

  @override
  State<_StreamingKaiBubble> createState() => _StreamingKaiBubbleState();
}

class _StreamingKaiBubbleState extends State<_StreamingKaiBubble>
    with SingleTickerProviderStateMixin {
  AnimationController? _caretController;

  @override
  void initState() {
    super.initState();
    if (widget.partialContent.isNotEmpty) {
      _startCaret();
    }
  }

  @override
  void didUpdateWidget(covariant _StreamingKaiBubble old) {
    super.didUpdateWidget(old);
    final hasText = widget.partialContent.isNotEmpty;
    if (hasText && _caretController == null) {
      _startCaret();
    } else if (!hasText && _caretController != null) {
      _caretController!.dispose();
      _caretController = null;
    }
  }

  void _startCaret() {
    _caretController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 500),
    )..repeat(reverse: true);
  }

  @override
  void dispose() {
    _caretController?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final c = KaiTheme.of(context).colors;

    // Tide bar width: 10→22 px (HTML canon: .f05 tide-bar animation)
    final tideBarWidth = Tween<double>(begin: 10, end: 22).animate(
      CurvedAnimation(
        parent: widget.tideBarController,
        curve: Curves.easeInOut,
      ),
    );

    final isState3 = widget.partialContent.isNotEmpty;

    return Align(
      alignment: Alignment.centerLeft,
      child: Padding(
        padding: const EdgeInsets.symmetric(
          horizontal: 18,
          vertical: KaiSpace.s2,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            // ── Single "who" row: tide bar + "KAI" + optional suffix ──────────
            Row(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                AnimatedBuilder(
                  animation: tideBarWidth,
                  builder: (context, _) {
                    return Container(
                      width: tideBarWidth.value,
                      height: 3,
                      decoration: const BoxDecoration(
                        gradient: KaiTide.gradient,
                        borderRadius: KaiRadius.brPill,
                      ),
                    );
                  },
                ),
                const SizedBox(width: 6),
                Text(
                  'KAI',
                  style: KaiType.mono(color: c.ink3).copyWith(
                    fontSize: 9,
                    letterSpacing: 9 * 0.08,
                  ),
                ),
                // States 1 & 2: show suffix text
                if (widget.statusSuffix != null) ...[
                  const SizedBox(width: 6),
                  Text(
                    '· ${widget.statusSuffix}',
                    style: TextStyle(
                      fontFamily: 'Manrope',
                      fontSize: 9,
                      fontWeight: FontWeight.w400,
                      fontStyle: FontStyle.italic,
                      color: c.ink4,
                    ),
                  ),
                ],
              ],
            ),
            // State 3: streamed text content + blinking caret
            if (isState3) ...[
              const SizedBox(height: 5),
              _buildTextWithCaret(c),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildTextWithCaret(KaiColorTokens c) {
    final baseStyle = TextStyle(
      fontFamily: 'Manrope',
      fontSize: 13.5,
      fontWeight: FontWeight.w400,
      height: 1.55,
      letterSpacing: 13.5 * -0.005,
      color: c.ink1,
    );

    final spans = <InlineSpan>[
      TextSpan(text: widget.partialContent, style: baseStyle),
    ];

    if (_caretController != null) {
      spans.add(
        WidgetSpan(
          alignment: PlaceholderAlignment.bottom,
          child: AnimatedBuilder(
            animation: _caretController!,
            builder: (context, _) {
              final visible = _caretController!.value < 0.5;
              return Opacity(
                opacity: visible ? 1.0 : 0.0,
                child: Container(
                  width: 7,
                  height: 14,
                  margin: const EdgeInsets.only(left: 2),
                  color: c.ink1,
                ),
              );
            },
          ),
        ),
      );
    }

    return Text.rich(TextSpan(children: spans, style: baseStyle));
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

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Expanded(
          child: _LiveFrame(
            messages: messages,
            bottomPadding: 16.0, // Small bottom padding since it is above the error container
          ),
        ),
        Padding(
          padding: EdgeInsets.only(bottom: bottomPadding),
          child: Padding(
            padding: const EdgeInsets.fromLTRB(18, 8, 18, 0),
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
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          const KaiGradientBar(
                            width: 12, // canon: 12px for error who-glyph
                            height: 3, // canon: 3px
                          ),
                          const SizedBox(width: 6), // canon: 6px gap
                          Text(
                            'KAI',
                            style: TextStyle(
                              fontFamily: 'JetBrainsMono',
                              fontSize: 9, // canon: 9px
                              fontWeight: FontWeight.w400,
                              height: 1.4,
                              letterSpacing: 9 * 0.08, // canon: 0.08em
                              color: c.ink3,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 5), // canon: 5px
                      // .err-bub container
                      Container(
                        decoration: BoxDecoration(
                          color: c.negativeWash,
                          borderRadius: BorderRadius.circular(14), // canon: 14px
                          border: Border.all(
                            // canon: rgba(196,74,60,0.15)
                            color: const Color.fromRGBO(196, 74, 60, 0.15),
                          ),
                        ),
                        padding: const EdgeInsets.symmetric(
                          horizontal: 13, // canon: 13px
                          vertical: 11, // canon: 11px
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            // .eh — icon circle + title
                            Row(
                              children: [
                                Container(
                                  width: 18, // canon: 18×18 circle
                                  height: 18,
                                  decoration: const BoxDecoration(
                                    // canon: rgba(196,74,60,0.12)
                                    color: Color.fromRGBO(196, 74, 60, 0.12),
                                    shape: BoxShape.circle,
                                  ),
                                  child: Center(
                                    child: KaiIcon(
                                      KaiIconName.alert,
                                      size: 10, // canon: 10px icon
                                      color: c.negative,
                                    ),
                                  ),
                                ),
                                const SizedBox(width: 6), // canon: 6px
                                Text(
                                  l10n.errorTitle,
                                  style: TextStyle(
                                    fontFamily: 'Manrope',
                                    fontSize: 12, // canon: 12px
                                    fontWeight: FontWeight.w600,
                                    letterSpacing: 12 * -0.005,
                                    color: c.negative,
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 7), // canon: 7px
                            // .eb — body text Manrope 11.5 ink2 h1.45
                            Text(
                              l10n.errorBody,
                              style: TextStyle(
                                fontFamily: 'Manrope',
                                fontSize: 11.5, // canon: 11.5px
                                fontWeight: FontWeight.w400,
                                height: 1.45, // canon: line-height 1.45
                                color: c.ink2,
                              ),
                            ),
                            const SizedBox(height: 9), // canon: 9px
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
                                const SizedBox(width: 8), // canon: 8px gap
                                Text(
                                  l10n.errorRetryHint,
                                  style: TextStyle(
                                    fontFamily: 'JetBrainsMono',
                                    fontSize: 10, // canon: 10px
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
