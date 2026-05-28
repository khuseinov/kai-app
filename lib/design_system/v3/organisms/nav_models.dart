// Canonical view-model types for the nav-panel organisms (v2 + v3).
//
// Extracted here (W4-prep) so that v3 code has no compile-time dependency on
// the v2 `nav_panel.dart` file. v2 re-exports these types unchanged, so every
// existing call-site continues to compile without modification.

/// A trip folder shown in the trips section and as the pinned trip card.
class TripInfo {
  const TripInfo({
    required this.id,
    required this.title,
    required this.subtitle,
    required this.initial,
    this.chatCount = 0,
  });

  final String id;
  final String title;
  final String subtitle;

  /// Single character shown inside the tide-gradient glyph.
  final String initial;

  /// Number of chats in this trip folder (used as count badge).
  final int chatCount;
}

/// A single chat session for display in the session list.
class SessionPreview {
  const SessionPreview({
    required this.id,
    required this.title,
    required this.timeLabel,
    required this.createdAt,
  });

  final String id;
  final String title;

  /// Mono time or date label, e.g. "9:41" or "12 ноя".
  final String timeLabel;
  final DateTime createdAt;
}
