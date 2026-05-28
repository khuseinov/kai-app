import 'package:flutter_test/flutter_test.dart';
import 'package:kai_app/design_system/v3/organisms/nav_models.dart'
    show SessionPreview;
import 'package:kai_app/features/nav/session_groups.dart';

// ─── Helpers ─────────────────────────────────────────────────────────────────

/// Reference "now" used across all tests: 2026-05-28 12:00:00.
///
/// Using a fixed reference keeps every bucket boundary deterministic.
final _now = DateTime(2026, 5, 28, 12, 0, 0);

/// Builds a [SessionPreview] with a [createdAt] offset relative to [_now].
SessionPreview _session(
  String id,
  String title,
  Duration offset,
) {
  return SessionPreview(
    id: id,
    title: title,
    timeLabel: '9:41',
    createdAt: _now.subtract(offset),
  );
}

void main() {
  group('groupSessionsByDate', () {
    // ── Empty list ────────────────────────────────────────────────────────────

    test('empty list returns empty result', () {
      final result = groupSessionsByDate([], now: _now);
      expect(result, isEmpty);
    });

    // ── Today bucket ─────────────────────────────────────────────────────────

    test('session created at exact _now falls into today', () {
      final sessions = [_session('s1', 'Now session', Duration.zero)];
      final result = groupSessionsByDate(sessions, now: _now);

      expect(result.length, 1);
      expect(result.first.bucket, SessionBucket.today);
      expect(result.first.sessions.single.id, 's1');
    });

    test('session created earlier today (same calendar day) falls into today',
        () {
      // 3 hours ago — same calendar day as _now
      final sessions = [_session('s2', 'Earlier today', const Duration(hours: 3))];
      final result = groupSessionsByDate(sessions, now: _now);

      expect(result.first.bucket, SessionBucket.today);
    });

    test('session created at midnight today (boundary) falls into today', () {
      // Exactly midnight of the reference day
      final midnight = DateTime(2026, 5, 28, 0, 0, 0);
      final sessions = [
        SessionPreview(
          id: 's3',
          title: 'Midnight today',
          timeLabel: '0:00',
          createdAt: midnight,
        ),
      ];
      final result = groupSessionsByDate(sessions, now: _now);

      expect(result.first.bucket, SessionBucket.today);
    });

    test('future-dated session (clock skew) falls into today', () {
      // 2 hours in the future — matches v2 comment "Future-dated (clock skew)"
      final future = _now.add(const Duration(hours: 2));
      final sessions = [
        SessionPreview(
          id: 's4',
          title: 'Future skew',
          timeLabel: '14:00',
          createdAt: future,
        ),
      ];
      final result = groupSessionsByDate(sessions, now: _now);

      expect(result.first.bucket, SessionBucket.today);
    });

    test('future date on a different calendar day also falls into today', () {
      // Next calendar day (tomorrow)
      final tomorrow = _now.add(const Duration(hours: 36));
      final sessions = [
        SessionPreview(
          id: 's5',
          title: 'Tomorrow session',
          timeLabel: '12:00',
          createdAt: tomorrow,
        ),
      ];
      final result = groupSessionsByDate(sessions, now: _now);

      expect(result.first.bucket, SessionBucket.today);
    });

    // ── Yesterday bucket ──────────────────────────────────────────────────────

    test('session from yesterday falls into yesterday', () {
      // 1 day ago — 2026-05-27
      final sessions = [_session('s6', 'Yesterday session', const Duration(hours: 24))];
      final result = groupSessionsByDate(sessions, now: _now);

      expect(result.first.bucket, SessionBucket.yesterday);
    });

    test('session at midnight yesterday (boundary) falls into yesterday', () {
      final midnightYesterday = DateTime(2026, 5, 27, 0, 0, 0);
      final sessions = [
        SessionPreview(
          id: 's7',
          title: 'Midnight yesterday',
          timeLabel: '0:00',
          createdAt: midnightYesterday,
        ),
      ];
      final result = groupSessionsByDate(sessions, now: _now);

      expect(result.first.bucket, SessionBucket.yesterday);
    });

    test('session at 23:59 yesterday falls into yesterday', () {
      final lateYesterday = DateTime(2026, 5, 27, 23, 59, 59);
      final sessions = [
        SessionPreview(
          id: 's8',
          title: 'Late yesterday',
          timeLabel: '23:59',
          createdAt: lateYesterday,
        ),
      ];
      final result = groupSessionsByDate(sessions, now: _now);

      expect(result.first.bucket, SessionBucket.yesterday);
    });

    // ── thisWeek bucket ───────────────────────────────────────────────────────

    test('session 2 days ago falls into thisWeek', () {
      final sessions = [_session('s9', '2 days ago', const Duration(days: 2))];
      final result = groupSessionsByDate(sessions, now: _now);

      expect(result.first.bucket, SessionBucket.thisWeek);
    });

    test('session 5 days ago falls into thisWeek', () {
      final sessions = [
        _session('s10', '5 days ago', const Duration(days: 5)),
      ];
      final result = groupSessionsByDate(sessions, now: _now);

      expect(result.first.bucket, SessionBucket.thisWeek);
    });

    test('session exactly 7 days ago (boundary) falls into thisWeek', () {
      // day −7 is inclusive per v2: `if (!d.isBefore(lastWeek))`
      final sessions = [
        _session('s11', '7 days ago', const Duration(days: 7)),
      ];
      final result = groupSessionsByDate(sessions, now: _now);

      expect(result.first.bucket, SessionBucket.thisWeek);
    });

    test('session 7 days ago at midnight falls into thisWeek', () {
      final sevenDaysAgoMidnight = DateTime(2026, 5, 21, 0, 0, 0);
      final sessions = [
        SessionPreview(
          id: 's12',
          title: '7 days midnight',
          timeLabel: '0:00',
          createdAt: sevenDaysAgoMidnight,
        ),
      ];
      final result = groupSessionsByDate(sessions, now: _now);

      expect(result.first.bucket, SessionBucket.thisWeek);
    });

    // ── Older bucket ──────────────────────────────────────────────────────────

    test('session 8 days ago falls into older', () {
      final sessions = [
        _session('s13', '8 days ago', const Duration(days: 8)),
      ];
      final result = groupSessionsByDate(sessions, now: _now);

      expect(result.first.bucket, SessionBucket.older);
    });

    test('session 30 days ago falls into older', () {
      final sessions = [
        _session('s14', '30 days ago', const Duration(days: 30)),
      ];
      final result = groupSessionsByDate(sessions, now: _now);

      expect(result.first.bucket, SessionBucket.older);
    });

    test('session 365 days ago still appears (not silently dropped)', () {
      final sessions = [
        _session('s15', 'Old session', const Duration(days: 365)),
      ];
      final result = groupSessionsByDate(sessions, now: _now);

      expect(result, hasLength(1));
      expect(result.first.bucket, SessionBucket.older);
      expect(result.first.sessions.single.id, 's15');
    });

    // ── Multiple sessions in same bucket ─────────────────────────────────────

    test('multiple today sessions are all in the today group', () {
      final sessions = [
        _session('a', 'A', Duration.zero),
        _session('b', 'B', const Duration(hours: 1)),
        _session('c', 'C', const Duration(hours: 5)),
      ];
      final result = groupSessionsByDate(sessions, now: _now);

      expect(result.length, 1);
      expect(result.first.bucket, SessionBucket.today);
      expect(result.first.sessions.map((s) => s.id), containsAll(['a', 'b', 'c']));
    });

    // ── Multiple buckets at once ──────────────────────────────────────────────

    test('sessions spread across all four buckets produce four groups in order',
        () {
      final sessions = [
        _session('today',     'Today',     Duration.zero),
        _session('yesterday', 'Yesterday', const Duration(days: 1)),
        _session('week',      'This week', const Duration(days: 3)),
        _session('older',     'Older',     const Duration(days: 30)),
      ];
      final result = groupSessionsByDate(sessions, now: _now);

      expect(result.length, 4);
      expect(result[0].bucket, SessionBucket.today);
      expect(result[1].bucket, SessionBucket.yesterday);
      expect(result[2].bucket, SessionBucket.thisWeek);
      expect(result[3].bucket, SessionBucket.older);
    });

    test('result omits empty buckets (no yesterday session)', () {
      final sessions = [
        _session('today', 'Today',   Duration.zero),
        _session('week',  'Week',    const Duration(days: 3)),
        _session('older', 'Older',   const Duration(days: 30)),
      ];
      final result = groupSessionsByDate(sessions, now: _now);

      // yesterday bucket absent
      expect(result.length, 3);
      expect(result.map((g) => g.bucket), [
        SessionBucket.today,
        SessionBucket.thisWeek,
        SessionBucket.older,
      ]);
    });

    // ── Ordering preserved within bucket ─────────────────────────────────────

    test('insertion order within a bucket is preserved', () {
      final sessions = [
        _session('first',  'First',  Duration.zero),
        _session('second', 'Second', const Duration(minutes: 30)),
        _session('third',  'Third',  const Duration(hours: 2)),
      ];
      final result = groupSessionsByDate(sessions, now: _now);

      expect(result.first.sessions.map((s) => s.id).toList(),
          ['first', 'second', 'third']);
    });

    // ── now defaults to DateTime.now() ───────────────────────────────────────

    test('omitting now does not throw (uses DateTime.now())', () {
      final sessions = [
        SessionPreview(
          id: 'live',
          title: 'Live session',
          timeLabel: '9:41',
          createdAt: DateTime.now(),
        ),
      ];
      // Should not throw.
      final result = groupSessionsByDate(sessions);

      expect(result, hasLength(1));
      expect(result.first.bucket, SessionBucket.today);
    });

    // ── Single-session edge: only older ──────────────────────────────────────

    test('single very old session produces one older group', () {
      final sessions = [
        _session('ancient', 'Ancient', const Duration(days: 180)),
      ];
      final result = groupSessionsByDate(sessions, now: _now);

      expect(result.length, 1);
      expect(result.first.bucket, SessionBucket.older);
    });

    // ── Boundary between thisWeek and older: exactly 8 days ago ─────────────

    test('session at exactly today − 8 days falls into older', () {
      final eightDaysAgoMidnight = DateTime(2026, 5, 20, 0, 0, 0);
      final sessions = [
        SessionPreview(
          id: 's-8d',
          title: 'Eight days ago',
          timeLabel: '0:00',
          createdAt: eightDaysAgoMidnight,
        ),
      ];
      final result = groupSessionsByDate(sessions, now: _now);

      expect(result.first.bucket, SessionBucket.older);
    });
  });
}
