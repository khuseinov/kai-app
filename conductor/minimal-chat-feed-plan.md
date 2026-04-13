# Minimal Chat Feed Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Replace the WhatsApp-style chat bubbles with a clean, document-like "Typographic Accent" interface inspired by Notion and Claude. User prompts and AI responses will be plain text blocks separated by spacing, with AI responses accentuated by a subtle left border.

**Architecture:** 
1. Delete the old `MessageBubble` and `MessageMetadata` widgets.
2. Create a new `MinimalMessageBlock` widget that renders raw text. For AI responses, it will add a 2px left border (`oceanPrimary`) and a specific padding.
3. Create a `SkeletonLoader` (or use a blinking cursor) to replace the `CircularProgressIndicator` inside the chat feed when `isLoading` is true. The main loading indicator is our Gemini wave, so the feed only needs a subtle text-placeholder animation to show where the text will appear.

**Tech Stack:** Flutter, Riverpod

---

### Task 1: Create MinimalMessageBlock

**Files:**
- Create: `lib/features/chat/presentation/widgets/minimal_message_block.dart`
- Delete: `lib/features/chat/presentation/widgets/message_bubble.dart`
- Delete: `lib/features/chat/presentation/widgets/message_metadata.dart`

- [ ] **Step 1: Delete old bubble widgets**
Remove the files `message_bubble.dart` and `message_metadata.dart`.

- [ ] **Step 2: Implement MinimalMessageBlock**
Create `minimal_message_block.dart`. It should take a `Message` object. If `isUser` is true, show "Вы" in bold grey and the text. If `isUser` is false, show "KAI" in bold `oceanPrimary` and the text with a 2px left border of `oceanPrimary` (with some alpha) and 12px left padding.

```dart
// lib/features/chat/presentation/widgets/minimal_message_block.dart
import 'package:flutter/material.dart';
import '../../../../core/design/theme/theme_extensions.dart';
import '../../../../core/design/tokens/kai_spacing.dart';
import '../../domain/models/message.dart';

class MinimalMessageBlock extends StatelessWidget {
  final Message message;

  const MinimalMessageBlock({
    super.key,
    required this.message,
  });

  @override
  Widget build(BuildContext context) {
    final colors = context.kaiColors;
    final typography = context.kaiTypography;
    final isUser = message.role == MessageRole.user;

    final nameText = isUser ? 'Вы' : 'KAI';
    final nameColor = isUser ? colors.textTertiary : colors.primary;

    return Padding(
      padding: const EdgeInsets.only(bottom: KaiSpacing.l),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            nameText,
            style: typography.labelMedium.copyWith(
              color: nameColor,
              fontWeight: FontWeight.bold,
              letterSpacing: 1.2,
            ),
          ),
          const SizedBox(height: KaiSpacing.xs),
          if (isUser)
            Text(
              message.content,
              style: typography.bodyLarge.copyWith(color: colors.textPrimary),
            )
          else
            Container(
              decoration: BoxDecoration(
                border: Border(
                  left: BorderSide(
                    color: colors.primary.withValues(alpha: 0.5),
                    width: 2.0,
                  ),
                ),
              ),
              padding: const EdgeInsets.only(left: KaiSpacing.m),
              child: Text(
                message.content,
                style: typography.bodyLarge.copyWith(
                  color: colors.textPrimary,
                  height: 1.6, // Good line height for readability
                ),
              ),
            ),
        ],
      ),
    );
  }
}
```

- [ ] **Step 3: Commit**
```bash
git rm lib/features/chat/presentation/widgets/message_bubble.dart lib/features/chat/presentation/widgets/message_metadata.dart
git add lib/features/chat/presentation/widgets/minimal_message_block.dart
git commit -m "feat: replace chat bubbles with minimal typography blocks"
```

### Task 2: Create Text Skeleton Loader

**Files:**
- Create: `lib/features/chat/presentation/widgets/text_skeleton_loader.dart`

- [ ] **Step 1: Implement TextSkeletonLoader**
Create a widget that pulses opacity on a grey rounded rectangle to simulate text loading.

```dart
// lib/features/chat/presentation/widgets/text_skeleton_loader.dart
import 'package:flutter/material.dart';
import '../../../../core/design/theme/theme_extensions.dart';
import '../../../../core/design/tokens/kai_spacing.dart';

class TextSkeletonLoader extends StatefulWidget {
  const TextSkeletonLoader({super.key});

  @override
  State<TextSkeletonLoader> createState() => _TextSkeletonLoaderState();
}

class _TextSkeletonLoaderState extends State<TextSkeletonLoader>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    )..repeat(reverse: true);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.kaiColors;
    final typography = context.kaiTypography;

    return Padding(
      padding: const EdgeInsets.only(bottom: KaiSpacing.l),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'KAI',
            style: typography.labelMedium.copyWith(
              color: colors.primary,
              fontWeight: FontWeight.bold,
              letterSpacing: 1.2,
            ),
          ),
          const SizedBox(height: KaiSpacing.xs),
          Container(
            decoration: BoxDecoration(
              border: Border(
                left: BorderSide(
                  color: colors.primary.withValues(alpha: 0.5),
                  width: 2.0,
                ),
              ),
            ),
            padding: const EdgeInsets.only(left: KaiSpacing.m),
            child: FadeTransition(
              opacity: Tween<double>(begin: 0.3, end: 0.8).animate(_controller),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    height: 16,
                    width: 200,
                    decoration: BoxDecoration(
                      color: colors.cloudLight.withValues(alpha: 0.3),
                      borderRadius: BorderRadius.circular(4),
                    ),
                  ),
                  const SizedBox(height: 8),
                  Container(
                    height: 16,
                    width: 150,
                    decoration: BoxDecoration(
                      color: colors.cloudLight.withValues(alpha: 0.3),
                      borderRadius: BorderRadius.circular(4),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
```

- [ ] **Step 2: Commit**
```bash
git add lib/features/chat/presentation/widgets/text_skeleton_loader.dart
git commit -m "feat: add text skeleton loader for minimal chat feed"
```

### Task 3: Update MessageList

**Files:**
- Modify: `lib/features/chat/presentation/widgets/message_list.dart`

- [ ] **Step 1: Refactor MessageList**
Update the ListView to use `MinimalMessageBlock` instead of `MessageBubble`. If `isLoading` is true, append `TextSkeletonLoader()` at the end of the list instead of a `CircularProgressIndicator`.

```dart
// lib/features/chat/presentation/widgets/message_list.dart
import 'package:flutter/material.dart';
import '../../domain/models/message.dart';
import '../../../../core/design/tokens/kai_spacing.dart';
import 'minimal_message_block.dart';
import 'text_skeleton_loader.dart';

class MessageList extends StatelessWidget {
  final List<Message> messages;
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
          return const TextSkeletonLoader();
        }

        final message = messages[index];
        return MinimalMessageBlock(message: message);
      },
    );
  }
}
```

- [ ] **Step 2: Commit**
```bash
git add lib/features/chat/presentation/widgets/message_list.dart
git commit -m "refactor: update message list to use minimal blocks and skeleton loader"
```