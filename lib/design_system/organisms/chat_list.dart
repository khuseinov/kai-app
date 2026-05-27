import 'package:flutter/material.dart';
import 'package:kai_app/l10n/app_localizations.dart';

import '../atoms/kai_bubble.dart';
import '../atoms/kai_icon.dart';
import '../theme/kai_theme.dart';
import '../tokens/kai_tokens.dart';

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

  /// Streaming response in progress; shows animated typing bar at top.
  streaming,

  /// Error state; shows retry prompt below existing messages.
  error,
}

/// Organism: the scrollable chat message list.
///
/// Switches rendering based on [frame]. Phase 5 will replace
/// `List<Map<String, dynamic>>` messages with typed `List<Message>` — for now,
/// each message map must contain `role` ('user'|'kai') and `content` (String).
///
/// Pass [partialContent] when [frame] == [RoomFrame.streaming] to display the
/// partial Kai response being generated. Null = empty streaming bubble.
/// TODO: wire to RoomState.streamingPartial when Phase 5/6 lands.
class ChatList extends StatefulWidget {
  const ChatList({
    required this.frame,
    this.messages = const [],
    this.onRetry,
    this.partialContent,
    super.key,
  });

  final RoomFrame frame;
  final List<Map<String, dynamic>> messages;
  final VoidCallback? onRetry;

  /// Partial Kai response text during streaming. Null when not streaming.
  final String? partialContent;

  @override
  State<ChatList> createState() => _ChatListState();
}

class _ChatListState extends State<ChatList>
    with TickerProviderStateMixin {
  late final AnimationController _tideBarController;
  late final AnimationController _cursorController;

  @override
  void initState() {
    super.initState();
    // Tide bar: 1.6s ease-in-out reverse loop (HTML canon)
    _tideBarController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1600),
    );
    // Cursor blink: 0.9s repeat (HTML canon: 0.9s steps(1))
    _cursorController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 900),
    );
    _syncStream();
  }

  void _syncStream() {
    if (widget.frame == RoomFrame.streaming) {
      if (!_tideBarController.isAnimating) {
        _tideBarController.repeat(reverse: true);
      }
      if (!_cursorController.isAnimating) {
        _cursorController.repeat();
      }
    } else {
      if (_tideBarController.isAnimating) _tideBarController.stop();
      if (_cursorController.isAnimating) _cursorController.stop();
    }
  }

  @override
  void didUpdateWidget(covariant ChatList old) {
    super.didUpdateWidget(old);
    if (old.frame != widget.frame) _syncStream();
  }

  @override
  void dispose() {
    _tideBarController.dispose();
    _cursorController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    switch (widget.frame) {
      case RoomFrame.empty:
        return _EmptyFrame(messages: widget.messages);
      case RoomFrame.live:
        return _LiveFrame(messages: widget.messages);
      case RoomFrame.panel:
        return IgnorePointer(
          child: Opacity(
            opacity: 0.25,
            child: _LiveFrame(messages: widget.messages),
          ),
        );
      case RoomFrame.compose:
        return Stack(
          children: [
            _LiveFrame(messages: widget.messages),
            Container(color: Colors.black.withValues(alpha: 0.18)),
          ],
        );
      case RoomFrame.streaming:
        return _StreamingFrame(
          messages: widget.messages,
          partialContent: widget.partialContent ?? '',
          tideBarController: _tideBarController,
          cursorController: _cursorController,
        );
      case RoomFrame.error:
        return _ErrorFrame(
          messages: widget.messages,
          onRetry: widget.onRetry,
        );
    }
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
          horizontal: 22,
          vertical: KaiSpace.s4,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
              l10n.emptyTitle,
              textAlign: TextAlign.center,
              style: TextStyle(
                fontFamily: 'Manrope',
                fontSize: 26,
                fontWeight: FontWeight.w600,
                height: 1.2,
                letterSpacing: 26 * -0.022,
                color: tokens.colors.ink1,
              ),
            ),
            const SizedBox(height: 6),
            Text(
              l10n.emptySubtitle,
              textAlign: TextAlign.center,
              style: TextStyle(
                fontFamily: 'Manrope',
                fontSize: 13.5,
                fontWeight: FontWeight.w400,
                height: 1.5,
                letterSpacing: 13.5 * -0.005,
                color: tokens.colors.ink3,
              ),
            ),
            // HTML canon: margin-top 8px
            const SizedBox(height: 8),
            // HTML canon: .suggest — column gap 8px
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

/// HTML canon: .f01 .sugg — surface-2 bg, 1px line border, r12, padding 11×14,
/// column direction, text-align left.
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
        horizontal: 14,
        vertical: 11,
      ),
      decoration: BoxDecoration(
        // HTML canon: surface-2 (NOT transparent)
        color: tokens.colors.surface2,
        // HTML canon: 12px radius (NOT pill)
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: tokens.colors.line, width: 1),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // .q — Manrope 13 w500 ink1 letter-spacing -0.005em
          Text(
            question,
            style: TextStyle(
              fontFamily: 'Manrope',
              fontSize: 13,
              fontWeight: FontWeight.w500,
              letterSpacing: 13 * -0.005,
              color: tokens.colors.ink1,
            ),
          ),
          // HTML canon: gap 1px between q and hint
          const SizedBox(height: 1),
          // .hint — JetBrainsMono 11 ink3
          Text(
            hint,
            style: TextStyle(
              fontFamily: 'JetBrainsMono',
              fontSize: 11,
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
  const _LiveFrame({required this.messages});

  final List<Map<String, dynamic>> messages;

  @override
  Widget build(BuildContext context) {
    if (messages.isEmpty) {
      return _EmptyFrame(messages: messages);
    }
    final tokens = KaiTheme.of(context);
    final l10n = AppLocalizations.of(context);
    return Column(
      children: [
        // Day header — HTML canon: JetBrainsMono 9px ink3 uppercase ls 0.1em
        // margin-top 4px. Format: '— today —' (em-dashes)
        Padding(
          padding: const EdgeInsets.only(top: 4),
          child: Text(
            '— ${l10n.today} —',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontFamily: 'JetBrainsMono',
              fontSize: 9,
              fontWeight: FontWeight.w400,
              letterSpacing: 9 * 0.1,
              color: tokens.colors.ink3,
            ),
          ),
        ),
        Expanded(
          child: ListView.builder(
            reverse: true,
            padding: const EdgeInsets.symmetric(
              horizontal: KaiSpace.s4,
              vertical: KaiSpace.s2,
            ),
            itemCount: messages.length,
            itemBuilder: (context, index) {
              // Build bottom-up: index 0 = last message
              final msg = messages[messages.length - 1 - index];
              final role = msg['role'] as String? ?? 'kai';
              final content = msg['content'] as String? ?? '';
              return Padding(
                padding: const EdgeInsets.symmetric(vertical: KaiSpace.s1),
                child: role == 'user'
                    ? KaiBubble.user(content)
                    : KaiBubble.kai(content),
              );
            },
          ),
        ),
      ],
    );
  }
}

// ─── Streaming frame ──────────────────────────────────────────────────────────

/// HTML canon: room.html:355-382 — F05 Streaming frame.
/// Shows previous messages via _LiveFrame (Expanded) +
/// a streaming Kai bubble at bottom with:
///   - Animated tide bar (10→22px, 1.6s ease-in-out reverse)
///   - "kai" label (mono 9 ink3 uppercase)
///   - Partial content text + blinking cursor (2×14px, 0.9s)
class _StreamingFrame extends StatelessWidget {
  const _StreamingFrame({
    required this.messages,
    required this.partialContent,
    required this.tideBarController,
    required this.cursorController,
  });

  final List<Map<String, dynamic>> messages;
  final String partialContent;
  final AnimationController tideBarController;
  final AnimationController cursorController;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        if (messages.isNotEmpty)
          Expanded(child: _LiveFrame(messages: messages))
        else
          const Spacer(),
        _StreamingKaiBubble(
          partialContent: partialContent,
          tideBarController: tideBarController,
          cursorController: cursorController,
        ),
      ],
    );
  }
}

/// Streaming Kai bubble — partial response with animated tide bar + cursor.
class _StreamingKaiBubble extends StatelessWidget {
  const _StreamingKaiBubble({
    required this.partialContent,
    required this.tideBarController,
    required this.cursorController,
  });

  final String partialContent;
  final AnimationController tideBarController;
  final AnimationController cursorController;

  @override
  Widget build(BuildContext context) {
    final tokens = KaiTheme.of(context);
    final c = tokens.colors;

    // Animated tide bar width: 10→22px
    final tideBarWidth = Tween<double>(begin: 10, end: 22).animate(
      CurvedAnimation(
        parent: tideBarController,
        curve: Curves.easeInOut,
      ),
    );

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          // .who row: animated tide bar + "kai" label
          Row(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              // Animated tide bar
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
                style: TextStyle(
                  fontFamily: 'JetBrainsMono',
                  fontSize: 9,
                  fontWeight: FontWeight.w400,
                  height: 1.4,
                  letterSpacing: 9 * 0.08,
                  color: c.ink3,
                ),
              ),
            ],
          ),
          const SizedBox(height: 5),
          // stream-txt: partial content + blinking cursor
          Row(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Flexible(
                child: Text(
                  partialContent,
                  style: TextStyle(
                    fontFamily: 'Manrope',
                    fontSize: 13.5,
                    fontWeight: FontWeight.w400,
                    height: 1.5,
                    letterSpacing: 13.5 * -0.005,
                    color: c.ink1,
                  ),
                ),
              ),
              const SizedBox(width: 2),
              // Blinking cursor: 2×14px, opacity 0/1 at 0.9s
              AnimatedBuilder(
                animation: cursorController,
                builder: (context, _) {
                  // steps(1): cursor is visible for first half, invisible second half
                  final visible = cursorController.value < 0.5;
                  return Opacity(
                    opacity: visible ? 1.0 : 0.0,
                    child: Container(
                      width: 2,
                      height: 14,
                      decoration: BoxDecoration(
                        color: c.ink1,
                        borderRadius: BorderRadius.circular(1),
                      ),
                    ),
                  );
                },
              ),
            ],
          ),
        ],
      ),
    );
  }
}

// ─── Error frame ─────────────────────────────────────────────────────────────

/// HTML canon: room.html:384-403 — F06 Error frame.
/// Previous messages (Expanded) + Kai-bubble-like error container at bottom:
///   .who row: TideGlyph 12×3 + "kai" mono 9 ink3
///   .err-bub: negativeWash bg + r14 + border rgba(196,74,60,0.15)
///     .eh: 18×18 circle + KaiIcon alert size 10 negative + title
///     .eb: body text Manrope 11.5 ink2 h1.45
///     .retry-row: coral-themed retry button + hint mono 10 ink4
class _ErrorFrame extends StatelessWidget {
  const _ErrorFrame({
    required this.messages,
    this.onRetry,
  });

  final List<Map<String, dynamic>> messages;
  final VoidCallback? onRetry;

  @override
  Widget build(BuildContext context) {
    final tokens = KaiTheme.of(context);
    final c = tokens.colors;
    final l10n = AppLocalizations.of(context);

    return Column(
      children: [
        Expanded(child: _LiveFrame(messages: messages)),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 8),
          child: Align(
            alignment: Alignment.centerLeft,
            child: LayoutBuilder(
              builder: (context, constraints) {
                return ConstrainedBox(
                  constraints: BoxConstraints(
                    maxWidth: constraints.maxWidth * 0.92,
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      // .who row — TideGlyph 12×3 + "kai" mono 9 ink3
                      Row(
                        mainAxisSize: MainAxisSize.min,
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          const TideGlyph(width: 12, height: 3),
                          const SizedBox(width: 6),
                          Text(
                            'KAI',
                            style: TextStyle(
                              fontFamily: 'JetBrainsMono',
                              fontSize: 9,
                              fontWeight: FontWeight.w400,
                              height: 1.4,
                              letterSpacing: 9 * 0.08,
                              color: c.ink3,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 5),
                      // .err-bub container
                      Container(
                        decoration: BoxDecoration(
                          color: c.negativeWash,
                          borderRadius: BorderRadius.circular(14),
                          border: Border.all(
                            // HTML canon: rgba(196,74,60,0.15)
                            color: const Color.fromRGBO(196, 74, 60, 0.15),
                            width: 1,
                          ),
                        ),
                        padding: const EdgeInsets.symmetric(
                          horizontal: 13,
                          vertical: 11,
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            // .eh — icon circle + title
                            Row(
                              children: [
                                Container(
                                  width: 18,
                                  height: 18,
                                  decoration: const BoxDecoration(
                                    // HTML canon: rgba(196,74,60,0.12)
                                    color: Color.fromRGBO(196, 74, 60, 0.12),
                                    shape: BoxShape.circle,
                                  ),
                                  child: Center(
                                    child: KaiIcon(
                                      KaiIconName.alert,
                                      size: 10,
                                      // D1 fix: use token, NOT hardcoded Color
                                      color: c.negative,
                                    ),
                                  ),
                                ),
                                const SizedBox(width: 6),
                                Text(
                                  l10n.errorTitle,
                                  style: TextStyle(
                                    fontFamily: 'Manrope',
                                    fontSize: 12,
                                    fontWeight: FontWeight.w600,
                                    // HTML canon: letter-spacing -0.005em
                                    letterSpacing: 12 * -0.005,
                                    color: c.negative,
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 7),
                            // .eb — body text
                            Text(
                              l10n.errorBody,
                              style: TextStyle(
                                fontFamily: 'Manrope',
                                fontSize: 11.5,
                                fontWeight: FontWeight.w400,
                                height: 1.45,
                                color: c.ink2,
                              ),
                            ),
                            const SizedBox(height: 9),
                            // .retry-row — coral-themed button + hint
                            Row(
                              children: [
                                // Custom coral retry button (NOT KaiButton.ghost)
                                GestureDetector(
                                  onTap: onRetry,
                                  child: Container(
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 11,
                                      vertical: 5,
                                    ),
                                    decoration: BoxDecoration(
                                      color: Colors.transparent,
                                      border: Border.all(
                                        // HTML canon: rgba(196,74,60,0.25)
                                        color: const Color.fromRGBO(
                                          196,
                                          74,
                                          60,
                                          0.25,
                                        ),
                                        width: 1,
                                      ),
                                      borderRadius: KaiRadius.brPill,
                                    ),
                                    child: Row(
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        KaiIcon(
                                          KaiIconName.retry,
                                          size: 12,
                                          color: c.negative,
                                        ),
                                        const SizedBox(width: 4),
                                        Text(
                                          l10n.retry,
                                          style: TextStyle(
                                            fontFamily: 'Manrope',
                                            fontSize: 10.5,
                                            fontWeight: FontWeight.w500,
                                            color: c.negative,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                                const SizedBox(width: 8),
                                Text(
                                  l10n.errorRetryHint,
                                  style: TextStyle(
                                    fontFamily: 'JetBrainsMono',
                                    fontSize: 10,
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
      ],
    );
  }
}
