import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/models/chat_message.dart';
import '../../../../core/design/tokens/kai_spacing.dart';
import '../../logic/chat_notifier.dart';
import 'async_progress_card.dart';
import 'message_bubble.dart';
import 'message_metadata_row.dart';
import 'chat_loading_indicator.dart';

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

  @override
  void initState() {
    super.initState();
    ref.listenManual<String?>(chatNotifierProvider.select((s) => s.targetMessageId), (prev, next) {
      if (next != null) {
        _scrollToMessage(next);
      }
    });
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
    final itemCount = widget.messages.length + (widget.isLoading ? 1 : 0);

    return ListView.builder(
      padding: const EdgeInsets.symmetric(
        horizontal: KaiSpacing.m,
        vertical: KaiSpacing.l,
      ),
      itemCount: itemCount,
      itemBuilder: (context, index) {
        if (index == widget.messages.length && widget.isLoading) {
          return const ChatLoadingIndicator();
        }

        final message = widget.messages[index];
        final key = _messageKeys.putIfAbsent(message.id, () => GlobalKey());

        // APP-ASYNC-1: async task placeholder messages
        if (message.status == 'async_pending') {
          return AsyncProgressCard(
            key: key,
            state: AsyncTaskState.pending,
            elapsedSeconds: double.tryParse(message.content) ?? 0,
            onCancel: () =>
                ref.read(chatNotifierProvider.notifier).cancelAsyncTask(),
          );
        }
        if (message.status == 'async_failed') {
          return AsyncProgressCard(
            key: key,
            state: AsyncTaskState.failed,
            errorMessage: message.content.isEmpty ? null : message.content,
          );
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
    );
  }
}
