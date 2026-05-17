import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/models/chat_message.dart';
import '../../../../core/design/tokens/kai_spacing.dart';
import '../../logic/chat_notifier.dart';
import 'crisis_card.dart';
import 'message_bubble.dart';
import 'message_metadata_row.dart';
import 'scroll_to_latest_button.dart';

class MessageList extends ConsumerStatefulWidget {
  final List<ChatMessage> messages;
  final bool isLoading;
  final Function(String) onRetry;

  const MessageList({
    super.key,
    required this.messages,
    required this.isLoading,
    required this.onRetry,
  });

  @override
  ConsumerState<MessageList> createState() => _MessageListState();
}

class _MessageListState extends ConsumerState<MessageList> {
  final Map<String, GlobalKey> _messageKeys = {};
  final ScrollController _scrollController = ScrollController();
  bool _showJumpToBottom = false;

  @override
  void initState() {
    super.initState();
    ref.listenManual<String?>(chatNotifierProvider.select((s) => s.targetMessageId), (prev, next) {
      if (next != null) {
        _scrollToMessage(next);
      }
    });
    _scrollController.addListener(_onScroll);
  }

  @override
  void dispose() {
    _scrollController.removeListener(_onScroll);
    _scrollController.dispose();
    super.dispose();
  }

  void _onScroll() {
    if (!_scrollController.hasClients) return;
    final pos = _scrollController.position;
    // Bottom of list is `maxScrollExtent`. Show fab when more than 120 px above.
    final atBottom = pos.pixels >= pos.maxScrollExtent - 120;
    if (atBottom == _showJumpToBottom) return;
    setState(() => _showJumpToBottom = !atBottom);
  }

  void _jumpToLatest() {
    if (!_scrollController.hasClients) return;
    _scrollController.animateTo(
      _scrollController.position.maxScrollExtent,
      duration: const Duration(milliseconds: 250),
      curve: Curves.easeOutCubic,
    );
  }

  void _scrollToMessage(String id) {
    final key = _messageKeys[id];
    if (key?.currentContext != null) {
      Scrollable.ensureVisible(
        key!.currentContext!,
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final itemCount = widget.messages.length;

    return Stack(
      children: [
        ListView.builder(
          controller: _scrollController,
          padding: const EdgeInsets.symmetric(
            horizontal: KaiSpacing.m,
            vertical: KaiSpacing.l,
          ),
          itemCount: itemCount,
          itemBuilder: (context, index) {
            final message = widget.messages[index];
            final key = _messageKeys.putIfAbsent(message.id, () => GlobalKey());

            // D4: Crisis messages get full-bleed CrisisCard instead of normal bubble.
            if (message.crisisDetected == true) {
              return CrisisCard(key: key, category: message.crisisCategory);
            }

            return Column(
              key: key,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                MessageBubble(message: message),
                MessageMetadataRow(message: message),
              ],
            );
          },
        ),
        Positioned(
          right: KaiSpacing.m,
          bottom: KaiSpacing.m,
          child: ScrollToLatestButton(
            visible: _showJumpToBottom,
            onTap: _jumpToLatest,
          ),
        ),
      ],
    );
  }
}
