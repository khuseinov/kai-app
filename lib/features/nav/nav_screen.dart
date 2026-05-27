import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

import '../../core/providers/session_provider.dart';
import '../../core/repositories/session_repository.dart';
import '../../design_system/organisms/nav_panel.dart';
import '../room/room_state.dart';

/// Full-screen nav panel as a transparent Riverpod-wired screen.
///
/// Pushed via [NavPanelRoute] — a custom slide-from-left [PageRoute].
class NavScreen extends ConsumerWidget {
  const NavScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final sessionAsync = ref.watch(sessionListProvider);
    final roomNotifier = ref.read(roomNotifierProvider.notifier);
    final roomState = ref.watch(roomNotifierProvider);

    final sessions = sessionAsync.when(
      data: (list) => _toSessionPreviews(list),
      loading: () => const <SessionPreview>[],
      error: (_, __) => const <SessionPreview>[],
    );

    return Material(
      color: Colors.transparent,
      child: NavPanel(
        onClose: () => Navigator.of(context).pop(),
        onNewChat: () {
          roomNotifier.switchSession(
            'session-${DateTime.now().millisecondsSinceEpoch}',
          );
          Navigator.of(context).pop();
        },
        sessions: sessions,
        activeSessionId: roomState.activeSessionId,
        onSessionTap: (id) {
          roomNotifier.switchSession(id);
          Navigator.of(context).pop();
        },
      ),
    );
  }

  List<SessionPreview> _toSessionPreviews(List<ChatSession> sessions) {
    return sessions
        .map(
          (s) => SessionPreview(
            id: s.id,
            title: s.title ?? 'Чат',
            timeLabel: _formatDate(s.createdAt),
            createdAt: s.createdAt,
          ),
        )
        .toList();
  }

  String _formatDate(DateTime dt) {
    return DateFormat('d MMM', 'ru').format(dt);
  }
}

/// Custom [PageRoute] that slides [NavScreen] in from the left.
class NavPanelRoute extends PageRoute<void> {
  NavPanelRoute();

  @override
  Color? get barrierColor => Colors.black38;

  @override
  bool get barrierDismissible => true;

  @override
  String? get barrierLabel => 'Nav panel';

  @override
  bool get maintainState => true;

  @override
  Duration get transitionDuration => const Duration(milliseconds: 250);

  @override
  Widget buildPage(
    BuildContext context,
    Animation<double> animation,
    Animation<double> secondaryAnimation,
  ) {
    return const NavScreen();
  }

  @override
  Widget buildTransitions(
    BuildContext context,
    Animation<double> animation,
    Animation<double> secondaryAnimation,
    Widget child,
  ) {
    return SlideTransition(
      position: Tween<Offset>(
        begin: const Offset(-1, 0),
        end: Offset.zero,
      ).animate(
        CurvedAnimation(parent: animation, curve: Curves.easeOutCubic),
      ),
      child: child,
    );
  }
}
