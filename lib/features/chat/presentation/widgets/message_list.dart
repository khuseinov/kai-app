import 'package:flutter/material.dart';
import '../../../../core/models/chat_message.dart';
import '../../../../core/design/tokens/kai_spacing.dart';
import 'message_bubble.dart';
import 'chat_loading_indicator.dart';

class MessageList extends StatelessWidget {
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
  Widget build(BuildContext context) {
    final itemCount = messages.length + (isLoading ? 1 : 0);

    return ListView.builder(
      padding: const EdgeInsets.symmetric(
        horizontal: KaiSpacing.m,
        vertical: KaiSpacing.l,
      ),
      itemCount: itemCount,
      itemBuilder: (context, index) {
        if (index == messages.length && isLoading) {
          return const ChatLoadingIndicator();
        }

        final message = messages[index];
        return MessageBubble(message: message);
      },
    );
  }
}
