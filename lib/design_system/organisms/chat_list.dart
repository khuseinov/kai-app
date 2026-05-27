import 'package:flutter/material.dart';

import '../atoms/kai_bubble.dart';
import '../atoms/kai_button.dart';
import '../atoms/kai_icon.dart';
import '../atoms/kai_text.dart';
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
/// Switches rendering based on [frame]. Phase 5 will replace `List<Object>`
/// messages with typed `List<Message>` — for now, each message is treated as
/// `Map<String, dynamic>` with `role` ('user'|'kai') and `content` (String).
class ChatList extends StatefulWidget {
  const ChatList({
    required this.frame,
    this.messages = const [],
    this.onRetry,
    super.key,
  });

  final RoomFrame frame;
  final List<Object> messages;
  final VoidCallback? onRetry;

  @override
  State<ChatList> createState() => _ChatListState();
}

class _ChatListState extends State<ChatList>
    with SingleTickerProviderStateMixin {
  late final AnimationController _streamController;

  @override
  void initState() {
    super.initState();
    _streamController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 500),
    )..repeat(reverse: true);
  }

  @override
  void dispose() {
    _streamController.dispose();
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
          controller: _streamController,
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

  final List<Object> messages;

  @override
  Widget build(BuildContext context) {
    final tokens = KaiTheme.of(context);
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(KaiSpace.s6),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // 48px Kai glyph
            Container(
              width: 48,
              height: 48,
              decoration: const BoxDecoration(
                gradient: KaiTide.gradient,
                shape: BoxShape.circle,
              ),
            ),
            const SizedBox(height: KaiSpace.s4),
            KaiText.body(
              'Начните разговор с Kai',
              color: tokens.colors.ink2,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: KaiSpace.s5),
            // Suggestion chips
            const Wrap(
              spacing: KaiSpace.s2,
              runSpacing: KaiSpace.s2,
              alignment: WrapAlignment.center,
              children: [
                _SuggestionChip(label: 'Планы на поездку'),
                _SuggestionChip(label: 'Вопрос о визе'),
                _SuggestionChip(label: 'Рекомендации'),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _SuggestionChip extends StatelessWidget {
  const _SuggestionChip({required this.label});

  final String label;

  @override
  Widget build(BuildContext context) {
    final tokens = KaiTheme.of(context);
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: KaiSpace.s4,
        vertical: KaiSpace.s2,
      ),
      decoration: BoxDecoration(
        color: Colors.transparent,
        borderRadius: KaiRadius.brPill,
        border: Border.all(color: tokens.colors.line, width: 1),
      ),
      child: Text(
        label,
        style: KaiType.small(color: tokens.colors.ink1),
      ),
    );
  }
}

// ─── Live frame ───────────────────────────────────────────────────────────────

class _LiveFrame extends StatelessWidget {
  const _LiveFrame({required this.messages});

  final List<Object> messages;

  @override
  Widget build(BuildContext context) {
    if (messages.isEmpty) {
      return _EmptyFrame(messages: messages);
    }
    final tokens = KaiTheme.of(context);
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(vertical: KaiSpace.s2),
          child: KaiText.micro(
            'Сегодня',
            color: tokens.colors.ink4,
            textAlign: TextAlign.center,
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
              final msg =
                  messages[messages.length - 1 - index] as Map<String, dynamic>;
              final role = msg['role'] as String? ?? 'kai';
              final content = msg['content'] as String? ?? '';
              return Padding(
                padding:
                    const EdgeInsets.symmetric(vertical: KaiSpace.s1),
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

class _StreamingFrame extends StatelessWidget {
  const _StreamingFrame({
    required this.messages,
    required this.controller,
  });

  final List<Object> messages;
  final AnimationController controller;

  @override
  Widget build(BuildContext context) {
    final tokens = KaiTheme.of(context);
    return Column(
      children: [
        // Animated typing bar
        SizedBox(
          height: KaiSpace.s10, // 80px
          child: Center(
            child: AnimatedBuilder(
              animation: controller,
              builder: (context, _) {
                final width = 32.0 + 32.0 * controller.value; // 32..64
                return AnimatedContainer(
                  duration: const Duration(milliseconds: 100),
                  height: 10.0 + 12.0 * controller.value, // 10..22
                  width: width,
                  decoration: BoxDecoration(
                    color: tokens.colors.accent,
                    borderRadius: KaiRadius.br2,
                  ),
                );
              },
            ),
          ),
        ),
        Expanded(child: _LiveFrame(messages: messages)),
      ],
    );
  }
}

// ─── Error frame ─────────────────────────────────────────────────────────────

class _ErrorFrame extends StatelessWidget {
  const _ErrorFrame({
    required this.messages,
    this.onRetry,
  });

  final List<Object> messages;
  final VoidCallback? onRetry;

  @override
  Widget build(BuildContext context) {
    final tokens = KaiTheme.of(context);
    return Column(
      children: [
        Expanded(child: _LiveFrame(messages: messages)),
        Padding(
          padding: const EdgeInsets.all(KaiSpace.s4),
          child: Container(
            width: double.infinity,
            padding: const EdgeInsets.all(KaiSpace.s4),
            decoration: BoxDecoration(
              color: tokens.colors.negativeWash,
              borderRadius: KaiRadius.br3,
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    const KaiIcon(
                      KaiIconName.alert,
                      size: 18,
                      color: Color(0xFFC44A3C),
                    ),
                    const SizedBox(width: KaiSpace.s2),
                    KaiText.body(
                      'Что-то пошло не так',
                      color: tokens.colors.ink1,
                    ),
                  ],
                ),
                const SizedBox(height: KaiSpace.s3),
                KaiButton.ghost(
                  onPressed: onRetry,
                  label: 'Повторить',
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}
