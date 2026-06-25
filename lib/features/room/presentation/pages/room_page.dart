import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:kai_app/design_system/atoms/atoms.dart';
import 'package:kai_app/design_system/primitives/primitives.dart';
import 'package:kai_app/design_system/theme/kai_theme.dart';
import 'package:kai_app/design_system/tokens/kai_tokens.dart';
import 'package:kai_app/features/nav/presentation/pages/nav_page.dart';
import 'package:kai_app/features/room/presentation/providers/room_state.dart';
import 'package:kai_app/features/room/presentation/widgets/kai_chat_list.dart';
import 'package:kai_app/features/room/presentation/widgets/kai_compose_island.dart';
import 'package:kai_app/features/room/presentation/widgets/kai_edge_state_block.dart';
import 'package:kai_app/features/room/presentation/widgets/kai_send_button.dart';
import 'package:kai_app/features/room/presentation/widgets/sheets/kai_action_sheet.dart';
import 'package:kai_app/l10n/app_localizations.dart';
import 'package:uuid/uuid.dart';

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
class RoomPage extends ConsumerStatefulWidget {
  const RoomPage({this.tripId, super.key});

  /// Optional trip id for deep-linking into a trip-specific session.
  final String? tripId;

  @override
  ConsumerState<RoomPage> createState() => _RoomPageState();
}

class _RoomPageState extends ConsumerState<RoomPage> {
  late final TextEditingController _composeController;
  double _dragStartX = 0;
  double _dragDeltaX = 0;
  bool _isDictating = false;
  Timer? _dictationTimer;
  bool _navRouteActive = false;

  @override
  void initState() {
    super.initState();
    _composeController = TextEditingController();
  }

  @override
  void dispose() {
    _composeController.dispose();
    _dictationTimer?.cancel();
    super.dispose();
  }

  void _onMicTap() {
    if (_isDictating) {
      _dictationTimer?.cancel();
      _dictationTimer = null;
      setState(() {
        _isDictating = false;
      });
    } else {
      setState(() {
        _isDictating = true;
      });
      _dictationTimer = Timer(const Duration(milliseconds: 1500), () {
        if (mounted) {
          setState(() {
            _composeController.text = 'рейс в Токио на пятницу';
            _isDictating = false;
          });
        }
      });
    }
  }

  void _onSend() {
    final text = _composeController.text.trim();
    if (text.isEmpty) return;
    _composeController.clear();
    ref.read(roomNotifierProvider.notifier).sendMessage(text);
  }

  void _onHorizontalDragStart(DragStartDetails details) {
    _dragStartX = details.localPosition.dx;
    _dragDeltaX = 0;
  }

  void _onHorizontalDragUpdate(DragUpdateDetails details) {
    _dragDeltaX += details.delta.dx;
  }

  void _onHorizontalDragEnd(DragEndDetails details) {
    final velocity = details.primaryVelocity ?? 0;
    final isDesktop = kIsWeb ||
        Theme.of(context).platform == TargetPlatform.windows ||
        Theme.of(context).platform == TargetPlatform.macOS ||
        Theme.of(context).platform == TargetPlatform.linux;
    final edgeWidth = isDesktop ? 100.0 : 60.0;
    final isLeftEdge = _dragStartX < edgeWidth;
    final isRightward = velocity > 100 || _dragDeltaX > 50;
    if (isLeftEdge && isRightward) {
      _openNav();
    }
  }

  void _openNav() {
    ref.read(roomNotifierProvider.notifier).openNavPanel();
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

    if (roomState.currentFrame == RoomFrame.panel && !_navRouteActive) {
      _navRouteActive = true;
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) {
          Navigator.of(context).push(NavPanelRoute()).then((_) {
            _navRouteActive = false;
            ref.read(roomNotifierProvider.notifier).closeNavPanel();
          });
        }
      });
    }

    final colors = KaiTheme.of(context).colors;
    final topInset = MediaQuery.of(context).padding.top;
    final scale = context.scale;

    return Scaffold(
      backgroundColor: colors.bg,
      body: Stack(
        children: [
          // ── Main content ──────────────────────────────────────────────
          SafeArea(
            top: false,
            child: Stack(
              children: [
                Column(
                  children: [
                    SizedBox(height: topInset + 4 * scale),
                  RepaintBoundary(
                    child: SizedBox(
                      height: 16 * scale,
                      child: Padding(
                        padding: EdgeInsets.symmetric(horizontal: 18 * scale),
                        child: KaiTideCurve(state: roomState.tideState, height: 16 * scale),
                      ),
                    ),
                  ),
                  Expanded(
                    child: KaiChatList(
                      frame: roomState.currentFrame,
                      messages: roomState.messages,
                      partialContent: roomState.streamingPartial,
                      thinkingStep: roomState.thinkingStep,
                      bottomPadding: (roomState.isOffline || roomState.isRateLimited || roomState.isCrisis)
                          ? 16.0 * scale // Small padding if offline block is present, since the column itself has the 88px spacer
                          : 88.0 * scale, // Full 88px padding to avoid compose island
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
                  // Reserve space so edge state blocks don't hide behind compose island.
                  // Only active when edge blocks are present; otherwise padding is inside ListView.
                  if (roomState.isOffline || roomState.isRateLimited || roomState.isCrisis)
                    SizedBox(height: 88 * scale)
                  else
                    const SizedBox(height: 0),
                ],
              ),
              Positioned(
                left: 18 * scale,
                right: 18 * scale,
                bottom: 26 * scale,
                child: KaiComposeIsland(
                  controller: _composeController,
                  onSend: _onSend,
                  onAddTap: () {
                    showKaiActionSheet(
                      context,
                      title: 'Добавить в поездку',
                      items: [
                        KaiActionItem(
                          icon: KaiIconName.folder,
                          title: 'Прикрепить файл (Билет)',
                          meta: 'PDF',
                          onTap: () {
                            ref
                                .read(roomNotifierProvider.notifier)
                                .addMockAttachment('Авиабилет.pdf');
                          },
                        ),
                        KaiActionItem(
                          icon: KaiIconName.folder,
                          title: 'Прикрепить бронь отеля',
                          meta: 'DOCX',
                          onTap: () {
                            ref
                                .read(roomNotifierProvider.notifier)
                                .addMockAttachment('Бронь_отеля.docx');
                          },
                        ),
                        KaiActionItem(
                          icon: KaiIconName.plus,
                          title: 'Новое путешествие',
                          onTap: () {
                            ref
                                .read(roomNotifierProvider.notifier)
                                .switchSession(const Uuid().v4());
                          },
                        ),
                        KaiActionItem(
                          icon: KaiIconName.settings,
                          title: 'Настройки',
                          onTap: () => context.go('/settings'),
                        ),
                      ],
                    );
                  },
                  onMicTap: _onMicTap,
                  onVoiceTap: null,
                  onStop: () => ref
                      .read(roomNotifierProvider.notifier)
                      .cancelStreaming(),
                  sendState: _sendStateFrom(roomState),
                  offline: roomState.isOffline,
                  dictating: _isDictating,
                  onQueue: _onSend,
                  placeholder: AppLocalizations.of(context).composePlaceholder,
                ),
              ),
            ],
          ),
        ),
        // ── Left-edge swipe catcher ────────────────────────────────────
        Positioned(
          left: 0,
          top: 0,
          bottom: 100, // Reserve bottom 100px for compose island inputs to prevent touch interception
          width: 60,
          child: GestureDetector(
            behavior: HitTestBehavior.translucent,
            onHorizontalDragStart: _onHorizontalDragStart,
            onHorizontalDragUpdate: _onHorizontalDragUpdate,
            onHorizontalDragEnd: _onHorizontalDragEnd,
            child: const SizedBox.expand(),
          ),
        ),
      ],
      ),
    );
  }
}
