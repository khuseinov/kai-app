import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../design_system/atoms/kai_tide_curve.dart';
import '../../design_system/molecules/compose_island.dart';
import '../../design_system/organisms/chat_list.dart';
import '../nav/nav_screen.dart';
import 'room_state.dart';

/// Top-level conversation screen.
///
/// Layout (top → bottom):
///   KaiTideCurve  — brand mark
///   ChatList      — scrollable messages
///   ComposeIsland — text input
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
    Navigator.of(context).push(NavPanelRoute());
  }

  ComposeState _composeStateFrom(bool isStreaming) {
    return isStreaming ? ComposeState.streaming : ComposeState.idle;
  }

  @override
  Widget build(BuildContext context) {
    final roomState = ref.watch(roomNotifierProvider);

    return GestureDetector(
      behavior: HitTestBehavior.translucent,
      onHorizontalDragStart: _onHorizontalDragStart,
      onHorizontalDragEnd: _onHorizontalDragEnd,
      child: SafeArea(
        child: Column(
          children: [
            KaiTideCurve(state: roomState.tideState, height: 48),
            Expanded(
              child: ChatList(
                frame: roomState.currentFrame,
                messages: roomState.messages,
                onRetry: () {
                  // Find the last user message and retry.
                  final messages = roomState.messages;
                  var lastUserText = '';
                  for (var i = messages.length - 1; i >= 0; i--) {
                    if (messages[i]['role'] == 'user') {
                      lastUserText = messages[i]['content'] as String? ?? '';
                      break;
                    }
                  }
                  ref
                      .read(roomNotifierProvider.notifier)
                      .sendMessage(lastUserText);
                },
              ),
            ),
            ComposeIsland(
              controller: _composeController,
              onSend: _onSend,
              state: _composeStateFrom(roomState.isStreaming),
            ),
          ],
        ),
      ),
    );
  }
}
