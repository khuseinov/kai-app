import 'package:flutter/material.dart';

import '../../l10n/app_localizations.dart';
import '../atoms/kai_button.dart';
import '../atoms/kai_icon.dart';
import '../theme/kai_theme.dart';
import '../tokens/kai_tokens.dart';
import '../v3/organisms/nav_models.dart';

// ─── Data models — now canonical in v3/organisms/nav_models.dart ─────────────
// Re-exported here so that files importing nav_panel.dart continue to compile.
export '../v3/organisms/nav_models.dart' show TripInfo, SessionPreview;

// ─── Internal date-group model ────────────────────────────────────────────────

class _DateGroup {
  const _DateGroup({required this.label, required this.sessions});
  final String label;
  final List<SessionPreview> sessions;
}

// ─── Grouping helper ──────────────────────────────────────────────────────────

List<_DateGroup> _groupSessionsByDate(
  List<SessionPreview> sessions,
  AppLocalizations l10n,
) {
  final now = DateTime.now();
  final today = DateTime(now.year, now.month, now.day);
  final yesterday = today.subtract(const Duration(days: 1));
  final lastWeek = today.subtract(const Duration(days: 7));
  final tomorrow = today.add(const Duration(days: 1));

  final todayList = <SessionPreview>[];
  final yesterdayList = <SessionPreview>[];
  final previousList = <SessionPreview>[];
  final olderList = <SessionPreview>[];

  for (final s in sessions) {
    final d = DateTime(s.createdAt.year, s.createdAt.month, s.createdAt.day);
    if (d.isAtSameMomentAs(today) ||
        (d.isAfter(today) && d.isBefore(tomorrow.add(const Duration(days: 1))))) {
      // Future-dated (clock skew) → still treated as today.
      todayList.add(s);
    } else if (d.isAtSameMomentAs(yesterday)) {
      yesterdayList.add(s);
    } else if (!d.isBefore(lastWeek)) {
      // Inclusive of day −7: d >= lastWeek.
      previousList.add(s);
    } else {
      // Fallback bucket — sessions > 7 days old still visible.
      olderList.add(s);
    }
  }

  return [
    if (todayList.isNotEmpty)
      _DateGroup(label: l10n.dateToday, sessions: todayList),
    if (yesterdayList.isNotEmpty)
      _DateGroup(label: l10n.dateYesterday, sessions: yesterdayList),
    if (previousList.isNotEmpty)
      _DateGroup(label: l10n.datePrevious7, sessions: previousList),
    if (olderList.isNotEmpty)
      _DateGroup(label: l10n.dateOlder, sessions: olderList),
  ];
}

// ─── NavPanel ─────────────────────────────────────────────────────────────────

/// Full-screen swipe-from-left drawer.
///
/// Layout (top → bottom):
/// - Top bar: close (28×28 circle) | Kai centred 14px | 28px spacer
/// - New chat button
/// - Search box (radius 9, mono 11, ink-3)
/// - Pinned trip card (optional)
/// - Trips section: sec-label + folder-rows
/// - Date-grouped sessions: sec-label groups + chat-rows
/// - Apps section (Memory, Settings)
/// - Account anchor (tide-gradient avatar + initial + chev)
class NavPanel extends StatelessWidget {
  const NavPanel({
    this.onClose,
    this.onNewChat,
    this.pinnedTrip,
    this.trips = const [],
    this.sessions = const [],
    this.activeSessionId,
    this.onSessionTap,
    this.onTripTap,
    this.accountInitial = 'A',
    this.accountName,
    this.accountPlan,
    this.onAccountTap,
    super.key,
  });

  final VoidCallback? onClose;
  final VoidCallback? onNewChat;

  /// Optional pinned trip shown directly below the search box.
  final TripInfo? pinnedTrip;

  /// Trip folders shown in the trips section.
  final List<TripInfo> trips;

  /// Chat sessions grouped by date internally.
  final List<SessionPreview> sessions;

  /// The session id that is currently active (highlighted).
  final String? activeSessionId;

  final ValueChanged<String>? onSessionTap;
  final ValueChanged<String>? onTripTap;

  /// Single character for the account avatar (first letter of user's name).
  final String accountInitial;

  final String? accountName;
  final String? accountPlan;
  final VoidCallback? onAccountTap;

  @override
  Widget build(BuildContext context) {
    final tokens = KaiTheme.of(context);
    final l10n = AppLocalizations.of(context);
    final dateGroups = _groupSessionsByDate(sessions, l10n);

    return GestureDetector(
      onHorizontalDragEnd: (details) {
        if ((details.primaryVelocity ?? 0) < -200) {
          onClose?.call();
        }
      },
      child: Container(
        width: double.infinity,
        height: double.infinity,
        color: tokens.colors.surface,
        child: SafeArea(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              _TopBar(onClose: onClose, tokens: tokens),
              Padding(
                padding: const EdgeInsets.fromLTRB(12, 0, 12, 10),
                child: KaiButton.ink1(
                  onPressed: onNewChat,
                  label: l10n.newChat,
                  icon: KaiIconName.plus,
                ),
              ),
              _SearchBox(tokens: tokens, l10n: l10n),
              Expanded(
                child: ListView(
                  padding: EdgeInsets.zero,
                  children: [
                    // ── Pinned trip card ──
                    if (pinnedTrip != null)
                      _PinnedTripCard(
                        title: pinnedTrip!.title,
                        subtitle: pinnedTrip!.subtitle,
                        initial: pinnedTrip!.initial,
                        onTap: onTripTap == null
                            ? null
                            : () => onTripTap!(pinnedTrip!.id),
                      ),
                    // ── Trips section ──
                    if (trips.isNotEmpty) ...[
                      _SectionLabel(
                        label: l10n.tripsLabel,
                        count: trips.length,
                      ),
                      for (final t in trips)
                        _FolderRow(
                          label: t.title,
                          count: t.chatCount,
                          onTap: onTripTap == null
                              ? null
                              : () => onTripTap!(t.id),
                        ),
                    ],
                    // ── Date-grouped sessions ──
                    if (dateGroups.isNotEmpty)
                      for (final group in dateGroups) ...[
                        _SectionLabel(
                          label: group.label,
                          count: group.sessions.length,
                        ),
                        for (final s in group.sessions)
                          _ChatRow(
                            title: s.title,
                            subtitle: s.timeLabel,
                            active: s.id == activeSessionId,
                            onTap: onSessionTap == null
                                ? null
                                : () => onSessionTap!(s.id),
                          ),
                      ]
                    else if (trips.isEmpty && pinnedTrip == null)
                      Padding(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 14,
                          vertical: 24,
                        ),
                        child: Center(
                          child: Text(
                            l10n.noChats,
                            style: TextStyle(
                              fontFamily: 'Manrope',
                              fontSize: 11,
                              color: tokens.colors.ink4,
                            ),
                          ),
                        ),
                      ),
                    // ── Apps section ──
                    _AppsSection(tokens: tokens, l10n: l10n),
                  ],
                ),
              ),
              _AccountAnchor(
                tokens: tokens,
                initial: accountInitial,
                name: accountName ?? l10n.accountAnonymous,
                plan: accountPlan ?? l10n.accountFreePlan,
                onTap: onAccountTap,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ─── Top bar ──────────────────────────────────────────────────────────────────

class _TopBar extends StatelessWidget {
  const _TopBar({required this.onClose, required this.tokens});

  final VoidCallback? onClose;
  final KaiTokens tokens;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 44,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 22),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            // Close 28×28 circle
            GestureDetector(
              onTap: onClose,
              child: Container(
                width: 28,
                height: 28,
                decoration: BoxDecoration(
                  color: tokens.colors.surface2,
                  shape: BoxShape.circle,
                ),
                child: Center(
                  child: KaiIcon(
                    KaiIconName.close,
                    size: 14,
                    color: tokens.colors.ink1,
                  ),
                ),
              ),
            ),
            // Centred title (spaceBetween + symmetric 28px edges)
            Text(
              'Kai',
              style: TextStyle(
                fontFamily: 'Manrope',
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: tokens.colors.ink1,
                letterSpacing: -0.005 * 14,
              ),
            ),
            // 28px spacer to balance close and keep title centred
            const SizedBox(width: 28),
          ],
        ),
      ),
    );
  }
}

// ─── Search box ───────────────────────────────────────────────────────────────

class _SearchBox extends StatelessWidget {
  const _SearchBox({required this.tokens, required this.l10n});

  final KaiTokens tokens;
  final AppLocalizations l10n;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(12, 0, 12, 8),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 7),
        decoration: BoxDecoration(
          color: tokens.colors.surface2,
          borderRadius: BorderRadius.circular(9),
        ),
        child: Row(
          children: [
            KaiIcon(
              KaiIconName.search,
              size: 14,
              color: tokens.colors.ink3,
            ),
            const SizedBox(width: 7),
            Text(
              l10n.search,
              style: TextStyle(
                fontFamily: 'Manrope',
                fontSize: 11,
                color: tokens.colors.ink3,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ─── Section label ────────────────────────────────────────────────────────────

class _SectionLabel extends StatelessWidget {
  const _SectionLabel({required this.label, this.count});

  final String label;
  final int? count;

  @override
  Widget build(BuildContext context) {
    final tokens = KaiTheme.of(context);
    return Padding(
      padding: const EdgeInsets.fromLTRB(14, 10, 14, 4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.baseline,
        textBaseline: TextBaseline.alphabetic,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label.toUpperCase(),
            style: TextStyle(
              fontFamily: 'JetBrainsMono',
              fontSize: 8.5,
              color: tokens.colors.ink3,
              letterSpacing: 0.1 * 8.5,
            ),
          ),
          if (count != null)
            Text(
              count.toString(),
              style: TextStyle(
                fontFamily: 'JetBrainsMono',
                fontSize: 8.5,
                color: tokens.colors.ink4,
              ),
            ),
        ],
      ),
    );
  }
}

// ─── Pinned trip card ─────────────────────────────────────────────────────────

class _PinnedTripCard extends StatelessWidget {
  const _PinnedTripCard({
    required this.title,
    required this.subtitle,
    required this.initial,
    this.onTap,
  });

  final String title;
  final String subtitle;
  final String initial;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final tokens = KaiTheme.of(context);
    return Padding(
      padding: const EdgeInsets.fromLTRB(12, 0, 12, 3),
      child: GestureDetector(
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                Color.fromRGBO(43, 168, 201, 0.06),
                Color.fromRGBO(244, 181, 137, 0.04),
              ],
            ),
            border: Border.all(color: tokens.colors.accentLine, width: 1),
            borderRadius: BorderRadius.circular(10),
          ),
          child: Row(
            children: [
              // Tide-gradient glyph 24×24 r-7 with destination initial
              Container(
                width: 24,
                height: 24,
                decoration: BoxDecoration(
                  gradient: KaiTide.gradient,
                  borderRadius: BorderRadius.circular(7),
                ),
                child: Center(
                  child: Text(
                    initial.isNotEmpty ? initial[0] : 'A',
                    style: const TextStyle(
                      fontFamily: 'Manrope',
                      color: Colors.white,
                      fontSize: 9,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 9),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: TextStyle(
                        fontFamily: 'Manrope',
                        fontSize: 11,
                        fontWeight: FontWeight.w600,
                        color: tokens.colors.ink1,
                        letterSpacing: -0.005 * 11,
                      ),
                    ),
                    const SizedBox(height: 1),
                    Text(
                      subtitle,
                      style: TextStyle(
                        fontFamily: 'JetBrainsMono',
                        fontSize: 9,
                        color: tokens.colors.ink3,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ─── Folder row ───────────────────────────────────────────────────────────────

class _FolderRow extends StatelessWidget {
  const _FolderRow({
    required this.label,
    this.count,
    this.onTap,
  });

  final String label;
  final int? count;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final tokens = KaiTheme.of(context);
    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 7),
        child: Row(
          children: [
            KaiIcon(
              KaiIconName.folder,
              size: 14,
              color: tokens.colors.ink3,
            ),
            const SizedBox(width: 9),
            Expanded(
              child: Text(
                label,
                style: TextStyle(
                  fontFamily: 'Manrope',
                  fontSize: 11,
                  fontWeight: FontWeight.w500,
                  color: tokens.colors.ink1,
                  letterSpacing: -0.005 * 11,
                ),
              ),
            ),
            if (count != null)
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 5, vertical: 1),
                decoration: BoxDecoration(
                  color: tokens.colors.surface2,
                  borderRadius: BorderRadius.circular(999),
                ),
                child: Text(
                  count.toString(),
                  style: TextStyle(
                    fontFamily: 'JetBrainsMono',
                    fontSize: 8.5,
                    color: tokens.colors.ink3,
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}

// ─── Chat row ─────────────────────────────────────────────────────────────────

class _ChatRow extends StatelessWidget {
  const _ChatRow({
    required this.title,
    required this.subtitle,
    required this.active,
    this.onTap,
  });

  final String title;
  final String subtitle;
  final bool active;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final tokens = KaiTheme.of(context);
    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
        decoration: BoxDecoration(
          color: active ? tokens.colors.accentWash : Colors.transparent,
          border: Border(
            left: BorderSide(
              color: active ? tokens.colors.accent : Colors.transparent,
              width: 2,
            ),
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                fontFamily: 'Manrope',
                fontSize: 11,
                fontWeight:
                    active ? FontWeight.w600 : FontWeight.w500,
                color: active ? tokens.colors.accent : tokens.colors.ink1,
                height: 1.3,
                letterSpacing: -0.005 * 11,
              ),
            ),
            const SizedBox(height: 1),
            Text(
              subtitle,
              style: TextStyle(
                fontFamily: 'JetBrainsMono',
                fontSize: 8.5,
                color: tokens.colors.ink3,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ─── Apps section ─────────────────────────────────────────────────────────────

class _AppsSection extends StatelessWidget {
  const _AppsSection({required this.tokens, required this.l10n});

  final KaiTokens tokens;
  final AppLocalizations l10n;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _SectionLabel(label: l10n.appsLabel),
        _AppRow(
          label: l10n.memoryAppLabel,
          icon: KaiIconName.memory,
          tokens: tokens,
        ),
        _AppRow(
          label: l10n.settingsAppLabel,
          icon: KaiIconName.settings,
          tokens: tokens,
        ),
      ],
    );
  }
}

// ─── App row ──────────────────────────────────────────────────────────────────

class _AppRow extends StatelessWidget {
  const _AppRow({
    required this.label,
    required this.icon,
    required this.tokens,
  });

  final String label;
  final KaiIconName icon;
  final KaiTokens tokens;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 7),
      child: Row(
        children: [
          KaiIcon(icon, size: 14, color: tokens.colors.ink3),
          const SizedBox(width: 9),
          Expanded(
            child: Text(
              label,
              style: TextStyle(
                fontFamily: 'Manrope',
                fontSize: 11,
                fontWeight: FontWeight.w500,
                color: tokens.colors.ink1,
                letterSpacing: -0.005 * 11,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ─── Account anchor ───────────────────────────────────────────────────────────

class _AccountAnchor extends StatelessWidget {
  const _AccountAnchor({
    required this.tokens,
    required this.initial,
    required this.name,
    required this.plan,
    this.onTap,
  });

  final KaiTokens tokens;
  final String initial;
  final String name;
  final String plan;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          border: Border(
            top: BorderSide(color: tokens.colors.line, width: 1),
          ),
        ),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 9),
        child: Row(
          children: [
            // Tide-gradient avatar 24×24 circle with initial
            Container(
              width: 24,
              height: 24,
              decoration: const BoxDecoration(
                gradient: KaiTide.gradient,
                shape: BoxShape.circle,
              ),
              child: Center(
                child: Text(
                  initial.isNotEmpty ? initial[0] : 'A',
                  style: const TextStyle(
                    fontFamily: 'Manrope',
                    color: Colors.white,
                    fontSize: 9,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    name,
                    style: TextStyle(
                      fontFamily: 'Manrope',
                      fontSize: 11,
                      fontWeight: FontWeight.w500,
                      color: tokens.colors.ink1,
                      letterSpacing: -0.005 * 11,
                    ),
                  ),
                  Text(
                    plan.toUpperCase(),
                    style: TextStyle(
                      fontFamily: 'JetBrainsMono',
                      fontSize: 8.5,
                      color: tokens.colors.ink3,
                      letterSpacing: 0.06 * 8.5,
                    ),
                  ),
                ],
              ),
            ),
            KaiIcon(
              KaiIconName.chev,
              size: 11,
              color: tokens.colors.ink3,
            ),
          ],
        ),
      ),
    );
  }
}
