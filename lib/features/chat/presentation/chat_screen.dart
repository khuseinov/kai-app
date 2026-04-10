import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/design/components/kai_hologram.dart';
import '../../../core/design/theme/theme_extensions.dart';
import '../../../core/design/tokens/kai_spacing.dart';
import '../../../core/providers/connectivity_status_provider.dart';
import '../logic/chat_notifier.dart';
import '../logic/session_notifier.dart';
import 'widgets/chat_empty_state.dart';
import 'widgets/chat_input_bar.dart';
import 'widgets/message_list.dart';
import 'widgets/offline_banner.dart';
import 'widgets/session_drawer.dart';
import '../../health/presentation/health_indicator.dart';

class ChatScreen extends ConsumerStatefulWidget {
  const ChatScreen({super.key});

  @override
  ConsumerState<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends ConsumerState<ChatScreen> {
  final _textController = TextEditingController();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _initSession();
    });
  }

  void _initSession() {
    final sessionState = ref.read(sessionNotifierProvider);
    final chatNotifier = ref.read(chatNotifierProvider.notifier);

    if (sessionState.activeSessionId != null) {
      chatNotifier.setSession(sessionState.activeSessionId!);
    } else {
      chatNotifier.initSession();
    }
  }

  @override
  void dispose() {
    _textController.dispose();
    super.dispose();
  }

  KaiHologramState _hologramStateFromChat(ChatState state) {
    if (state.isLoading) return KaiHologramState.thinking;
    if (state.messages.isNotEmpty) return KaiHologramState.speaking;
    return KaiHologramState.idle;
  }

  @override
  Widget build(BuildContext context) {
    final chatState = ref.watch(chatNotifierProvider);
    final colors = context.kaiColors;
    final isOfflineAsync = ref.watch(isOnlineProvider);
    final isOffline = !(isOfflineAsync.valueOrNull ?? true);

    return Scaffold(
      backgroundColor: colors.background,
      drawer: const SessionDrawer(),
      body: SafeArea(
        child: Column(
          children: [
            // Offline banner
            OfflineBanner(isOffline: isOffline),

            // QW-4: Typed error banner
            if (chatState.error != null)
              _ErrorBanner(
                error: chatState.error!,
                errorType: chatState.errorType,
              ),

            // App bar — menu button + QW-1: HealthIndicator (dot)
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: KaiSpacing.xs),
              child: Row(
                children: [
                  IconButton(
                    icon: Icon(Icons.menu, color: colors.textPrimary, size: 24),
                    onPressed: () => Scaffold.of(context).openDrawer(),
                  ),
                  const Spacer(),
                  // QW-1: server health dot — green/yellow/red
                  const HealthIndicator(),
                  const SizedBox(width: KaiSpacing.s),
                ],
              ),
            ),

            // Compact hologram header (120px)
            SizedBox(
              height: 120,
              child: Stack(
                children: [
                  KaiHologram(state: _hologramStateFromChat(chatState)),
                ],
              ),
            ),

            // Messages or empty state
            Expanded(
              child: chatState.messages.isEmpty && !chatState.isLoading
                  ? ChatEmptyState(
                      onPromptTapped: (text) {
                        ref.read(chatNotifierProvider.notifier).sendMessage(text);
                      },
                    )
                  : MessageList(
                      messages: chatState.messages,
                      isLoading: chatState.isLoading,
                      onRetry: (messageId) {
                        final failedMsg = chatState.messages.firstWhere(
                          (m) => m.id == messageId,
                        );
                        ref
                            .read(chatNotifierProvider.notifier)
                            .sendMessage(failedMsg.content);
                      },
                    ),
            ),

            // Input bar
            ChatInputBar(
              controller: _textController,
              isLoading: chatState.isLoading,
              onSend: (text) {
                ref.read(chatNotifierProvider.notifier).sendMessage(text);
              },
            ),
          ],
        ),
      ),
    );
  }
}

/// QW-4: Error banner with contextual icon + color per error type.
class _ErrorBanner extends StatelessWidget {
  final String error;
  final ChatErrorType? errorType;

  const _ErrorBanner({required this.error, this.errorType});

  @override
  Widget build(BuildContext context) {
    final colors = context.kaiColors;
    final typography = context.kaiTypography;

    final (icon, color) = switch (errorType) {
      ChatErrorType.rateLimited        => (Icons.hourglass_empty, colors.warning),
      ChatErrorType.serviceUnavailable => (Icons.cloud_off_outlined, colors.error),
      ChatErrorType.network            => (Icons.wifi_off_rounded, colors.warning),
      _                                => (Icons.error_outline, colors.error),
    };

    return Container(
      margin: const EdgeInsets.symmetric(
        horizontal: KaiSpacing.screenPadding,
        vertical: KaiSpacing.xxs,
      ),
      padding: const EdgeInsets.symmetric(
        horizontal: KaiSpacing.m,
        vertical: KaiSpacing.xs,
      ),
      decoration: BoxDecoration(
        color: color.withAlpha(26),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: color.withAlpha(77)),
      ),
      child: Row(
        children: [
          Icon(icon, color: color, size: 16),
          const SizedBox(width: KaiSpacing.xs),
          Expanded(
            child: Text(
              error,
              style: typography.labelMedium.copyWith(color: color),
            ),
          ),
        ],
      ),
    );
  }
}
