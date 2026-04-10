import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';

import '../../../../core/design/tokens/kai_spacing.dart';
import '../../../../core/models/chat_message.dart';
import 'message_bubble.dart';
import 'message_metadata_row.dart';
import 'typing_indicator.dart';

class MessageList extends StatefulWidget {
  final List<ChatMessage> messages;
  final bool isLoading;
  final ValueChanged<String>? onRetry;

  const MessageList({
    super.key,
    required this.messages,
    required this.isLoading,
    this.onRetry,
  });

  @override
  State<MessageList> createState() => _MessageListState();
}

class _MessageListState extends State<MessageList> {
  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    _scrollToBottom();
  }

  @override
  void didUpdateWidget(covariant MessageList oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.messages.length != widget.messages.length ||
        oldWidget.isLoading != widget.isLoading) {
      _scrollToBottom();
    }
  }

  void _scrollToBottom() {
    SchedulerBinding.instance.addPostFrameCallback((_) {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 250),
          curve: Curves.easeOut,
        );
      }
    });
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (widget.messages.isEmpty && !widget.isLoading) {
      return const SizedBox.shrink();
    }

    // Build the full list of items: messages + optional typing indicator
    final int itemCount =
        widget.messages.length + (widget.isLoading ? 1 : 0);

    return ListView.builder(
      controller: _scrollController,
      padding: EdgeInsets.symmetric(vertical: KaiSpacing.s),
      itemCount: itemCount,
      itemBuilder: (context, index) {
        // Show typing indicator as the last item while loading
        if (widget.isLoading && index == widget.messages.length) {
          return const Padding(
            padding: EdgeInsets.symmetric(
              horizontal: KaiSpacing.screenPadding,
              vertical: KaiSpacing.xxs,
            ),
            child: TypingIndicator(),
          );
        }
        final message = widget.messages[index];
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            MessageBubble(
              message: message,
              onRetry: widget.onRetry != null
                  ? () => widget.onRetry!(message.id)
                  : null,
            ),
            MessageMetadataRow(message: message),
          ],
        );
      },
    );
  }
}
