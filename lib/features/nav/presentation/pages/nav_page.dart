import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';

import 'package:kai_app/core/providers/session_provider.dart';
import 'package:kai_app/features/auth/domain/repositories/session_repository.dart';
import 'package:kai_app/features/nav/data/models/nav_models.dart';
import 'package:kai_app/features/nav/presentation/widgets/kai_nav_panel.dart';
import 'package:kai_app/features/nav/presentation/widgets/session_groups.dart';
import 'package:kai_app/features/room/presentation/providers/room_state.dart';
import 'package:kai_app/l10n/app_localizations.dart';

/// Full-screen nav panel as a transparent Riverpod-wired screen.
///
/// Pushed via [NavPanelRoute] — a custom slide-from-left [PageRoute].
/// W4 migration: renders [KaiNavPanel] (v3) instead of the v2 [NavPanel].
class NavScreen extends ConsumerWidget {
  const NavScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final sessionAsync = ref.watch(sessionListProvider);
    final roomNotifier = ref.read(roomNotifierProvider.notifier);
    final roomState = ref.watch(roomNotifierProvider);
    final l10n = AppLocalizations.of(context);

    final sessions = sessionAsync.when(
      data: _toSessionPreviews,
      loading: () => const <SessionPreview>[],
      error: (_, __) => const <SessionPreview>[],
    );

    final strings = KaiNavStrings(
      title: l10n.appTitle,
      newChat: l10n.newChat,
      search: l10n.search,
      tripsLabel: l10n.tripsLabel,
      appsLabel: l10n.appsLabel,
      memoryLabel: l10n.memoryAppLabel,
      settingsLabel: l10n.settingsAppLabel,
      accountAnonymous: l10n.accountAnonymous,
      accountFreePlan: l10n.accountFreePlan,
      noChats: l10n.noChats,
      bucketLabel: (bucket) => switch (bucket) {
        SessionBucket.today => l10n.dateToday,
        SessionBucket.yesterday => l10n.dateYesterday,
        SessionBucket.thisWeek => l10n.datePrevious7,
        SessionBucket.older => l10n.dateOlder,
      },
    );

    return Material(
      color: Colors.transparent,
      child: KaiNavPanel(
        strings: strings,
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
        onMemoryTap: () {
          Navigator.of(context).pop();
          context.go('/memory');
        },
        onSettingsTap: () {
          Navigator.of(context).pop();
          context.go('/settings');
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
