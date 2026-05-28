import 'package:flutter/material.dart';

import 'nav_models.dart';
import '../../../features/nav/session_groups.dart';
import '../theme/kai_theme.dart';
import '../tokens/kai_tokens.dart';
import '../atoms/atoms.dart';
import '../molecules/molecules.dart';
import '../primitives/kai_icon.dart';

// ─── Strings struct ───────────────────────────────────────────────────────────

/// Display strings passed to [KaiNavPanel] by the caller.
///
/// # l10n strategy
/// The organism accepts a [KaiNavStrings] struct instead of importing
/// `AppLocalizations` directly.  This keeps the organism l10n-agnostic (no
/// package dependency on the generated ARB output) and makes the API
/// unit-testable without a full localisation setup.
///
/// The W4 screen migration creates this struct from its `AppLocalizations`
/// instance — a near-zero-effort translation at the call site.
///
/// Bucket labels are provided via [bucketLabel], a function keyed on
/// [SessionBucket], so callers can supply any language or format without
/// changing the organism.
class KaiNavStrings {
  const KaiNavStrings({
    required this.title,
    required this.newChat,
    required this.search,
    required this.tripsLabel,
    required this.appsLabel,
    required this.memoryLabel,
    required this.settingsLabel,
    required this.accountAnonymous,
    required this.accountFreePlan,
    required this.noChats,
    required this.bucketLabel,
  });

  /// Panel header title — typically "Kai".
  final String title;

  /// Label for the new-chat primary button.
  final String newChat;

  /// Placeholder for the search box.
  final String search;

  /// Section header label for the trips list.
  final String tripsLabel;

  /// Section header label for the apps section.
  final String appsLabel;

  /// Row label for the Memory app.
  final String memoryLabel;

  /// Row label for the Settings app.
  final String settingsLabel;

  /// Account name shown when no real account name is available.
  final String accountAnonymous;

  /// Account plan shown when no plan is available.
  final String accountFreePlan;

  /// Shown when there are no chat sessions.
  final String noChats;

  /// Maps a [SessionBucket] to its section-header display string.
  ///
  /// The organism calls this with each non-empty bucket to get the label.
  final String Function(SessionBucket) bucketLabel;

  /// Russian-language defaults — used in tests and the dev showcase.
  static KaiNavStrings get russian => KaiNavStrings(
        title: 'Kai',
        newChat: 'Новый чат',
        search: 'Поиск',
        tripsLabel: 'ПОЕЗДКИ',
        appsLabel: 'ПРИЛОЖЕНИЯ',
        memoryLabel: 'Память',
        settingsLabel: 'Настройки',
        accountAnonymous: 'Anonymous',
        accountFreePlan: 'Free',
        noChats: 'Нет чатов',
        bucketLabel: (b) => switch (b) {
          SessionBucket.today => 'СЕГОДНЯ',
          SessionBucket.yesterday => 'ВЧЕРА',
          SessionBucket.thisWeek => 'ПОСЛЕДНИЕ 7 ДНЕЙ',
          SessionBucket.older => 'РАНЕЕ',
        },
      );
}

// ─── KaiNavPanel ──────────────────────────────────────────────────────────────

/// v3 full-screen side-panel organism.
///
/// Layout (top → bottom):
/// - Top bar: close 28×28 circle | centred title | 28px spacer
/// - New-chat button: `KaiButton.ink(fullWidth: true)` — canon ink1 br12
/// - Search box: decorative surface-2 container (r9 / mono 11)
/// - [Expanded ListView]:
///   - Pinned trip card (optional)
///   - Trips section: header + [KaiNavItem] folder rows
///   - Date-grouped sessions (from [groupSessionsByDate]): header + [KaiNavItem] rows
///   - Empty-sessions placeholder (when no sessions AND no trips)
///   - Apps section: Memory (with optional [KaiBadge.dot()]) + Settings
/// - Account anchor (tide-gradient avatar + initial + name + plan + chev)
///
/// # l10n
/// All display strings come from the [strings] parameter — see [KaiNavStrings].
///
/// # Strangler-fig note (W3)
/// This organism is NEW (v3 parallel build).  The v2 [NavPanel] is untouched.
/// W4 migrates the screen to use this organism by constructing [KaiNavStrings]
/// from `AppLocalizations`.
class KaiNavPanel extends StatelessWidget {
  const KaiNavPanel({
    required this.strings,
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
    this.onMemoryTap,
    this.onSettingsTap,
    this.hasUnseenMemory = false,
    this.now,
    super.key,
  });

  /// All localised/display strings. See [KaiNavStrings].
  final KaiNavStrings strings;

  /// Fires when the panel requests dismissal (close button or swipe-left).
  final VoidCallback? onClose;

  /// Fires when the user taps the "new chat" button.
  final VoidCallback? onNewChat;

  /// Optional pinned trip shown directly below the search box.
  final TripInfo? pinnedTrip;

  /// Trip folders shown in the trips section.
  final List<TripInfo> trips;

  /// Chat sessions — grouped by date internally via [groupSessionsByDate].
  final List<SessionPreview> sessions;

  /// ID of the currently active session (highlighted in the list).
  final String? activeSessionId;

  final ValueChanged<String>? onSessionTap;
  final ValueChanged<String>? onTripTap;

  /// Single character for the account avatar (first letter of user's name).
  final String accountInitial;

  final String? accountName;
  final String? accountPlan;
  final VoidCallback? onAccountTap;

  /// Fires when the user taps the Memory row.
  final VoidCallback? onMemoryTap;

  /// Fires when the user taps the Settings row.
  final VoidCallback? onSettingsTap;

  /// When true, renders a [KaiBadge.dot()] trailing on the Memory row.
  final bool hasUnseenMemory;

  /// Reference time for session date-bucketing. Defaults to [DateTime.now()]
  /// in production; tests inject a fixed value for deterministic buckets.
  final DateTime? now;

  @override
  Widget build(BuildContext context) {
    final tokens = KaiTheme.of(context);

    // Bucket the sessions with the pure presenter (R3 fix).
    final dateGroups = groupSessionsByDate(sessions, now: now);

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
              _NavTopBar(
                title: strings.title,
                onClose: onClose,
                tokens: tokens,
              ),
              Padding(
                padding: const EdgeInsets.fromLTRB(12, 0, 12, 10),
                child: KaiButton.ink(
                  onPressed: onNewChat,
                  label: strings.newChat,
                  icon: KaiIconName.plus,
                  fullWidth: true,
                ),
              ),
              _NavSearchBox(
                placeholder: strings.search,
                tokens: tokens,
              ),
              Expanded(
                child: ListView(
                  padding: EdgeInsets.zero,
                  children: [
                    // ── Pinned trip card ──
                    if (pinnedTrip != null)
                      _NavPinnedTripCard(
                        title: pinnedTrip!.title,
                        subtitle: pinnedTrip!.subtitle,
                        initial: pinnedTrip!.initial,
                        onTap: onTripTap == null
                            ? null
                            : () => onTripTap!(pinnedTrip!.id),
                        tokens: tokens,
                      ),

                    // ── Trips section ──
                    if (trips.isNotEmpty) ...[
                      _NavSectionLabel(
                        label: strings.tripsLabel,
                        count: trips.length,
                      ),
                      for (final t in trips)
                        KaiNavItem(
                          label: t.title,
                          icon: KaiIconName.folder,
                          trailing: t.chatCount > 0
                              ? _CountBadge(count: t.chatCount, tokens: tokens)
                              : null,
                          onTap: onTripTap == null
                              ? null
                              : () => onTripTap!(t.id),
                        ),
                    ],

                    // ── Date-grouped sessions ──
                    if (dateGroups.isNotEmpty)
                      for (final group in dateGroups) ...[
                        _NavSectionLabel(
                          label: strings.bucketLabel(group.bucket),
                          count: group.sessions.length,
                        ),
                        for (final s in group.sessions)
                          KaiNavItem(
                            label: s.title,
                            trailing: Text(
                              s.timeLabel,
                              style: TextStyle(
                                fontFamily: 'JetBrainsMono',
                                fontSize: 8.5, // canon: mono 8.5 ink3
                                color: tokens.colors.ink3,
                              ),
                            ),
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
                            strings.noChats,
                            style: TextStyle(
                              fontFamily: 'Manrope',
                              fontSize: 11, // canon: 11px ink4
                              color: tokens.colors.ink4,
                            ),
                          ),
                        ),
                      ),

                    // ── Apps section ──
                    _NavSectionLabel(label: strings.appsLabel),
                    KaiNavItem(
                      label: strings.memoryLabel,
                      icon: KaiIconName.memory,
                      trailing:
                          hasUnseenMemory ? const KaiBadge.dot() : null,
                      onTap: onMemoryTap,
                    ),
                    KaiNavItem(
                      label: strings.settingsLabel,
                      icon: KaiIconName.settings,
                      onTap: onSettingsTap,
                    ),
                  ],
                ),
              ),
              _NavAccountAnchor(
                tokens: tokens,
                initial: accountInitial,
                name: accountName ?? strings.accountAnonymous,
                plan: accountPlan ?? strings.accountFreePlan,
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

class _NavTopBar extends StatelessWidget {
  const _NavTopBar({
    required this.title,
    required this.onClose,
    required this.tokens,
  });

  final String title;
  final VoidCallback? onClose;
  final KaiTokens tokens;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 44, // canon: 44px top bar
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 22),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            // Close 28×28 circle button
            GestureDetector(
              onTap: onClose,
              child: Container(
                width: 28, // canon: 28×28
                height: 28,
                decoration: BoxDecoration(
                  color: tokens.colors.surface2,
                  shape: BoxShape.circle,
                ),
                child: Center(
                  child: KaiIcon(
                    KaiIconName.close,
                    size: 14, // canon: 14px icon
                    color: tokens.colors.ink1,
                  ),
                ),
              ),
            ),
            // Centred title
            Text(
              title,
              style: TextStyle(
                fontFamily: 'Manrope',
                fontSize: 14, // canon: 14px w600 ink1
                fontWeight: FontWeight.w600,
                color: tokens.colors.ink1,
                letterSpacing: -0.005 * 14,
              ),
            ),
            // 28px spacer balances the close button so the title is visually centred.
            const SizedBox(width: 28),
          ],
        ),
      ),
    );
  }
}

// ─── Search box ───────────────────────────────────────────────────────────────

/// Decorative (read-only) search box.
///
/// The search interaction is not implemented in the v2 API or the v3 orbit yet.
/// This mirrors v2's `_SearchBox` — a surface-2 container with a search icon
/// and placeholder text.  When search becomes interactive, replace this with
/// `KaiInput.line(controller: ..., placeholder: ...)`.
class _NavSearchBox extends StatelessWidget {
  const _NavSearchBox({
    required this.placeholder,
    required this.tokens,
  });

  final String placeholder;
  final KaiTokens tokens;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(12, 0, 12, 8),
      child: Container(
        padding: const EdgeInsets.symmetric(
          horizontal: 10, // canon: 10px
          vertical: 7, // canon: 7px
        ),
        decoration: BoxDecoration(
          color: tokens.colors.surface2,
          borderRadius: BorderRadius.circular(9), // canon: r9
        ),
        child: Row(
          children: [
            KaiIcon(
              KaiIconName.search,
              size: 14, // canon: 14px
              color: tokens.colors.ink3,
            ),
            const SizedBox(width: 7), // canon: 7px gap
            Text(
              placeholder,
              style: TextStyle(
                fontFamily: 'Manrope',
                fontSize: 11, // canon: 11px ink3
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

class _NavSectionLabel extends StatelessWidget {
  const _NavSectionLabel({required this.label, this.count});

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
              fontSize: 8.5, // canon: 8.5px ls 0.1em ink3
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

class _NavPinnedTripCard extends StatelessWidget {
  const _NavPinnedTripCard({
    required this.title,
    required this.subtitle,
    required this.initial,
    required this.tokens,
    this.onTap,
  });

  final String title;
  final String subtitle;
  final String initial;
  final KaiTokens tokens;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(12, 0, 12, 3),
      child: GestureDetector(
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.symmetric(
            horizontal: 10, // canon: 10px
            vertical: 8, // canon: 8px
          ),
          decoration: BoxDecoration(
            // canon: subtle tide tint — rgba(43,168,201,0.06) → rgba(244,181,137,0.04)
            gradient: const LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                Color.fromRGBO(43, 168, 201, 0.06),
                Color.fromRGBO(244, 181, 137, 0.04),
              ],
            ),
            border: Border.all(color: tokens.colors.accentLine),
            borderRadius: BorderRadius.circular(10), // canon: r10
          ),
          child: Row(
            children: [
              // Tide-gradient glyph 24×24 r7 with destination initial
              Container(
                width: 24, // canon: 24×24
                height: 24,
                decoration: BoxDecoration(
                  gradient: KaiTide.gradient,
                  borderRadius: BorderRadius.circular(7), // canon: r7
                ),
                child: Center(
                  child: Text(
                    initial.isNotEmpty ? initial[0] : 'A',
                    style: const TextStyle(
                      fontFamily: 'Manrope',
                      color: Colors.white,
                      fontSize: 9, // canon: 9px w700
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 9), // canon: 9px gap
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: TextStyle(
                        fontFamily: 'Manrope',
                        fontSize: 11, // canon: 11px w600 ink1
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
                        fontSize: 9, // canon: 9px ink3
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

// ─── Count badge ──────────────────────────────────────────────────────────────

/// Compact trip-chat-count badge — surface-2 pill with mono 8.5 ink3 text.
///
/// This is intentionally NOT [KaiBadge.count] (which uses the accent color and
/// is sized for notification counts).  The trip folder count uses a neutral
/// surface-2 pill — identical to v2's `_FolderRow` count badge.
class _CountBadge extends StatelessWidget {
  const _CountBadge({required this.count, required this.tokens});

  final int count;
  final KaiTokens tokens;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: 5, // canon: 5px
        vertical: 1, // canon: 1px
      ),
      decoration: BoxDecoration(
        color: tokens.colors.surface2,
        borderRadius: BorderRadius.circular(999), // pill
      ),
      child: Text(
        count.toString(),
        style: TextStyle(
          fontFamily: 'JetBrainsMono',
          fontSize: 8.5,
          color: tokens.colors.ink3,
        ),
      ),
    );
  }
}

// ─── Account anchor ───────────────────────────────────────────────────────────

class _NavAccountAnchor extends StatelessWidget {
  const _NavAccountAnchor({
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
            top: BorderSide(color: tokens.colors.line), // canon: 1px line
          ),
        ),
        padding: const EdgeInsets.symmetric(
          horizontal: 12, // canon: 12px
          vertical: 9, // canon: 9px
        ),
        child: Row(
          children: [
            // Tide-gradient avatar circle 24×24 with initial
            Container(
              width: 24, // canon: 24×24
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
                    fontSize: 9, // canon: 9px w700
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
            ),
            const SizedBox(width: 8), // canon: 8px
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    name,
                    style: TextStyle(
                      fontFamily: 'Manrope',
                      fontSize: 11, // canon: 11px w500 ink1
                      fontWeight: FontWeight.w500,
                      color: tokens.colors.ink1,
                      letterSpacing: -0.005 * 11,
                    ),
                  ),
                  Text(
                    plan.toUpperCase(),
                    style: TextStyle(
                      fontFamily: 'JetBrainsMono',
                      fontSize: 8.5, // canon: 8.5px ink3 ls 0.06em
                      color: tokens.colors.ink3,
                      letterSpacing: 0.06 * 8.5,
                    ),
                  ),
                ],
              ),
            ),
            KaiIcon(
              KaiIconName.chev,
              size: 11, // canon: 11px ink3
              color: tokens.colors.ink3,
            ),
          ],
        ),
      ),
    );
  }
}
