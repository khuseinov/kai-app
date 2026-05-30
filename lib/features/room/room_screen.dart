import 'package:flutter/material.dart';
import 'package:kai_app/l10n/app_localizations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../design_system/theme/kai_theme.dart';
import '../../design_system/tokens/kai_tokens.dart';
import '../../design_system/atoms/atoms.dart';
import '../../design_system/molecules/molecules.dart';
import '../../design_system/organisms/organisms.dart';
import '../nav/nav_screen.dart';
import 'room_state.dart';

/// Top-level conversation screen.
///
/// Layout (top → bottom):
///   KaiTideCurve      — brand mark
///   KaiChatList       — scrollable messages
///   KaiEdgeStateBlock — shown inline when offline / rate-limited / crisis
///   KaiComposeIsland  — text input
///
/// Left-edge swipe (drag start x < 24, velocity > 200 rightward) opens
/// the nav panel as a slide-in modal route.
class RoomScreen extends ConsumerStatefulWidget {
  const RoomScreen({this.tripId, super.key});

  /// Optional trip id for deep-linking into a trip-specific session.
  final String? tripId;

  @override
  ConsumerState<RoomScreen> createState() => _RoomScreenState();
}

class _RoomScreenState extends ConsumerState<RoomScreen> {
  late final TextEditingController _composeController;
  double _dragStartX = 0;

  @override
  void initState() {
    super.initState();
    _composeController = TextEditingController();
  }

  @override
  void dispose() {
    _composeController.dispose();
    super.dispose();
  }

  void _onSend() {
    final text = _composeController.text.trim();
    if (text.isEmpty) return;
    _composeController.clear();
    ref.read(roomNotifierProvider.notifier).sendMessage(text);
  }

  void _onHorizontalDragStart(DragStartDetails details) {
    _dragStartX = details.localPosition.dx;
  }

  void _onHorizontalDragEnd(DragEndDetails details) {
    final velocity = details.primaryVelocity ?? 0;
    final isLeftEdge = _dragStartX < 24;
    final isRightward = velocity > 200;
    if (isLeftEdge && isRightward) {
      _openNav();
    }
  }

  void _openNav() {
    ref.read(roomNotifierProvider.notifier).openNavPanel();
    Navigator.of(context).push(NavPanelRoute()).then((_) {
      ref.read(roomNotifierProvider.notifier).closeNavPanel();
    });
  }

  /// Maps v2-style compose state from [RoomStateData] → v3 [KaiSendState].
  ///
  /// - offline / rateLimited → disabled
  /// - streaming             → streaming
  /// - otherwise             → ready (KaiComposeIsland derives disabled from
  ///   empty text automatically, so `ready` here just lifts the lock)
  KaiSendState _sendStateFrom(RoomStateData s) {
    if (s.isOffline || s.isRateLimited) return KaiSendState.disabled;
    if (s.isStreaming) return KaiSendState.streaming;
    return KaiSendState.ready;
  }

  @override
  Widget build(BuildContext context) {
    final roomState = ref.watch(roomNotifierProvider);
    final colors = KaiTheme.of(context).colors;
    final topInset = MediaQuery.of(context).padding.top;

    return Scaffold(
      backgroundColor: colors.bg,
      body: GestureDetector(
        behavior: HitTestBehavior.translucent,
        onHorizontalDragStart: _onHorizontalDragStart,
        onHorizontalDragEnd: _onHorizontalDragEnd,
        child: SafeArea(
          top: false,
          child: Stack(
            children: [
              Column(
                children: [
                  SizedBox(height: topInset + 4),
                  SizedBox(
                    height: 16,
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 18),
                      child: KaiTideCurve(state: roomState.tideState, height: 16),
                    ),
                  ),
                  Expanded(
                    child: KaiChatList(
                      frame: roomState.currentFrame,
                      messages: roomState.messages,
                      // M1: wire accumulated partial text from streaming message
                      partialContent: roomState.streamingPartial,
                      onRetry: () {
                        final messages = roomState.messages;
                        var lastUserText = '';
                        for (var i = messages.length - 1; i >= 0; i--) {
                          if (messages[i]['role'] == 'user') {
                            lastUserText =
                                messages[i]['content'] as String? ?? '';
                            break;
                          }
                        }
                        if (lastUserText.isNotEmpty) {
                          ref
                              .read(roomNotifierProvider.notifier)
                              .sendMessage(lastUserText);
                        }
                      },
                    ),
                  ),
                  if (roomState.isOffline)
                    const Padding(
                      padding: EdgeInsets.symmetric(
                        horizontal: KaiSpace.s4,
                        vertical: KaiSpace.s2,
                      ),
                      child: KaiEdgeStateBlock(surface: KaiEdgeSurface.offline),
                    ),
                  if (roomState.isRateLimited)
                    Padding(
                      padding: const EdgeInsets.symmetric(
                        horizontal: KaiSpace.s4,
                        vertical: KaiSpace.s2,
                      ),
                      child: KaiEdgeStateBlock(
                        surface: KaiEdgeSurface.rateLimit,
                        countdown: roomState.rateLimitRetryAfter,
                      ),
                    ),
                  if (roomState.isCrisis)
                    const Padding(
                      padding: EdgeInsets.symmetric(
                        horizontal: KaiSpace.s4,
                        vertical: KaiSpace.s2,
                      ),
                      child: KaiEdgeStateBlock(surface: KaiEdgeSurface.crisis),
                    ),
                  // Reserve space so chat content doesn't hide behind compose island.
                  // 26 (bottom) + 44 (island height) + 18 (top margin) = 88
                  const SizedBox(height: 88),
                ],
              ),
              Positioned(
                left: 18,
                right: 18,
                bottom: 26,
                child: KaiComposeIsland(
                  controller: _composeController,
                  onSend: _onSend,
                  // TODO(R2 follow-up): wire onMicTap (dictation), onVoiceTap
                  // (voice-mode route) and onAddTap (attach/travel sheet) once
                  // those features exist. Null keeps the buttons hidden today.
                  onStop: () => ref
                      .read(roomNotifierProvider.notifier)
                      .cancelStreaming(),
                  sendState: _sendStateFrom(roomState),
                  offline: roomState.isOffline,
                  placeholder: AppLocalizations.of(context).composePlaceholder,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
