/// Pure, testable date-bucketing presenter for the nav-panel session list.
///
/// # Why this file exists (R3 fix)
/// In v2 the grouping logic lived inline inside `_groupSessionsByDate` —
/// a private function tightly coupled to `AppLocalizations` and the widget
/// tree.  Extracting it here makes the bucketing:
///   - **pure** — no Flutter imports, no l10n, no side-effects;
///   - **deterministic** — `now` is injected, so unit tests can pin the clock;
///   - **composable** — the v3 `KaiNavPanel` organism calls this function and
///     formats the labels separately, keeping business logic out of UI.
///
/// # Bucketing thresholds (ported exactly from v2)
/// | Bucket       | Condition                                    |
/// |--------------|----------------------------------------------|
/// | today        | date == today **or** date > today (skew)     |
/// | yesterday    | date == today − 1 day                        |
/// | thisWeek     | today − 7 days <= date < yesterday           |
/// | older        | date < today − 7 days                        |
///
/// Future-dated sessions (clock skew) fall into [SessionBucket.today] —
/// matching v2 behaviour (comment: "Future-dated (clock skew) → today").
library;

import 'package:kai_app/features/nav/components/nav_models.dart'
    show SessionPreview;

// ─── Public API ───────────────────────────────────────────────────────────────

/// The four date buckets used in the nav-panel session list.
///
/// Enum order matches the top-to-bottom rendering order in the panel.
enum SessionBucket {
  /// Same calendar day as [now] (or future-dated — clock skew).
  today,

  /// One calendar day before [now].
  yesterday,

  /// Between 2 and 7 calendar days before [now] (inclusive of day −7).
  thisWeek,

  /// More than 7 calendar days before [now].
  older,
}

/// A group of sessions that share the same date bucket.
class SessionGroup {
  const SessionGroup({
    required this.bucket,
    required this.sessions,
  });

  final SessionBucket bucket;

  /// Ordered as received — [groupSessionsByDate] does not sort within groups.
  final List<SessionPreview> sessions;

  @override
  String toString() =>
      'SessionGroup(${bucket.name}, ${sessions.length} sessions)';
}

// ─── Pure grouping function ───────────────────────────────────────────────────

/// Groups [sessions] into date buckets relative to [now].
///
/// - Pass [now] to pin the clock (required for deterministic tests).
/// - Defaults to [DateTime.now()] when [now] is null.
/// - Empty [sessions] returns an empty list.
/// - Groups with zero sessions are omitted from the result.
/// - Ordering within each bucket is preserved (insertion order from [sessions]).
/// - The returned list is in [SessionBucket] enum order:
///   today → yesterday → thisWeek → older.
List<SessionGroup> groupSessionsByDate(
  List<SessionPreview> sessions, {
  DateTime? now,
}) {
  if (sessions.isEmpty) return const [];

  final reference = now ?? DateTime.now();
  // Truncate to midnight for calendar-day comparisons.
  final today = DateTime(reference.year, reference.month, reference.day);
  final yesterday = today.subtract(const Duration(days: 1));
  final lastWeek = today.subtract(const Duration(days: 7));

  final todayList = <SessionPreview>[];
  final yesterdayList = <SessionPreview>[];
  final thisWeekList = <SessionPreview>[];
  final olderList = <SessionPreview>[];

  for (final s in sessions) {
    final d = DateTime(s.createdAt.year, s.createdAt.month, s.createdAt.day);

    if (!d.isBefore(today)) {
      // today OR future (clock skew) → today bucket
      todayList.add(s);
    } else if (d.isAtSameMomentAs(yesterday)) {
      yesterdayList.add(s);
    } else if (!d.isBefore(lastWeek)) {
      // lastWeek <= d < yesterday  (i.e. days −7 through −2)
      thisWeekList.add(s);
    } else {
      olderList.add(s);
    }
  }

  return [
    if (todayList.isNotEmpty)
      SessionGroup(bucket: SessionBucket.today, sessions: todayList),
    if (yesterdayList.isNotEmpty)
      SessionGroup(bucket: SessionBucket.yesterday, sessions: yesterdayList),
    if (thisWeekList.isNotEmpty)
      SessionGroup(bucket: SessionBucket.thisWeek, sessions: thisWeekList),
    if (olderList.isNotEmpty)
      SessionGroup(bucket: SessionBucket.older, sessions: olderList),
  ];
}
