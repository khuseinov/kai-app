import 'package:flutter/material.dart';

import '../atoms/kai_bottom_sheet_shell.dart';
import '../atoms/kai_icon.dart';
import '../theme/kai_theme.dart';

/// Freshness signal next to a source row.
enum SourceFreshness { fresh, stale }

/// One numbered source entry in [KaiMessageDetailSheet].
///
/// Canon: `components.html § 03.9 .sheet.detail .src-mini`.
class MessageDetailSource {
  const MessageDetailSource({
    required this.number,
    required this.url,
    this.freshness,
    this.freshnessLabel,
  });

  /// Source index (1-based) shown in the numbered chip on the left.
  final int number;

  /// Hostname / display URL — bolded, ink-1.
  final String url;

  /// Optional freshness indicator (positive ✓ / warning ⚠).
  final SourceFreshness? freshness;

  /// Display label for freshness (e.g. "fresh", "5d", "stale 7d"). When null
  /// and [freshness] is set, defaults match the canon ("fresh" / "stale").
  final String? freshnessLabel;
}

/// Visual emphasis for a detail action.
enum DetailActionStyle { normal, primary, danger }

/// One row in the actions list at the bottom of [KaiMessageDetailSheet].
///
/// Canon: `components.html § 03.9 .sheet.detail .ds-actions .act`.
class DetailAction {
  const DetailAction({
    required this.icon,
    required this.label,
    required this.onTap,
    this.style = DetailActionStyle.normal,
  });

  final KaiIconName icon;
  final String label;
  final DetailActionStyle style;
  final VoidCallback onTap;
}

/// Long-press detail sheet — surfaces sources + secondary actions for a Kai
/// message.
///
/// Canon: `components.html § 03.9 .sheet.detail`:
///
/// ```
/// .sec-tt         mono 9.5 uppercase ink-3 letter-spacing 0.08em, padding 6 6 4
/// .src-mini       grid 20px 1fr auto, gap 8, padding 8 8, font 11.5 ink-2
/// .src-mini .n    mono 9 ink-3, bg surface-2, padding 2 5, r-4, center
/// .src-mini .url  ink-1 weight 500
/// .src-mini .ok   positive mono 10
/// .src-mini .warn warning mono 10
/// .ds-actions .act grid 22 1fr, gap 10, padding 10 8, r-8
///                  font 500 12.5 ink-1 -0.005em
/// .primary        accent
/// .danger         negative
/// ```
class KaiMessageDetailSheet extends StatelessWidget {
  const KaiMessageDetailSheet({
    required this.sources,
    required this.actions,
    this.sourcesLabel = 'источники',
    this.actionsLabel = 'действия',
    super.key,
  });

  final List<MessageDetailSource> sources;
  final List<DetailAction> actions;
  final String sourcesLabel;
  final String actionsLabel;

  /// Present as a modal bottom sheet.
  static Future<void> show(
    BuildContext context, {
    required List<MessageDetailSource> sources,
    required List<DetailAction> actions,
    String sourcesLabel = 'источники',
    String actionsLabel = 'действия',
  }) {
    return showModalBottomSheet<void>(
      context: context,
      backgroundColor: Colors.transparent,
      elevation: 0,
      builder: (sheetContext) => KaiMessageDetailSheet(
        sources: sources,
        actions: actions,
        sourcesLabel: sourcesLabel,
        actionsLabel: actionsLabel,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final c = KaiTheme.of(context).colors;

    return KaiBottomSheetShell(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          _SectionLabel(text: sourcesLabel),
          for (final src in sources) _SourceMiniRow(source: src),
          // Divider before actions (canon: `border-top: 1px line` on the
          // actions section label).
          Padding(
            padding: const EdgeInsets.only(top: 6),
            child: Container(
              height: 1,
              color: c.line,
            ),
          ),
          _SectionLabel(text: actionsLabel),
          for (final action in actions)
            _DetailActionRow(
              action: action,
              onTap: () {
                Navigator.of(context).maybePop();
                action.onTap();
              },
            ),
        ],
      ),
    );
  }
}

// ─── Section label (.sec-tt) ─────────────────────────────────────────────────

class _SectionLabel extends StatelessWidget {
  const _SectionLabel({required this.text});

  final String text;

  @override
  Widget build(BuildContext context) {
    final c = KaiTheme.of(context).colors;
    return Padding(
      // Canon: padding 6 6 4
      padding: const EdgeInsets.fromLTRB(6, 6, 6, 4),
      child: Text(
        text.toUpperCase(),
        style: TextStyle(
          fontFamily: 'JetBrainsMono',
          fontSize: 9.5,
          fontWeight: FontWeight.w400,
          letterSpacing: 0.08 * 9.5,
          color: c.ink3,
        ),
      ),
    );
  }
}

// ─── Source row (.src-mini) ──────────────────────────────────────────────────

class _SourceMiniRow extends StatelessWidget {
  const _SourceMiniRow({required this.source});

  final MessageDetailSource source;

  @override
  Widget build(BuildContext context) {
    final c = KaiTheme.of(context).colors;
    return Padding(
      // Canon: padding 8 8
      padding: const EdgeInsets.all(8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          // .n — mono 9 ink-3 on surface-2 chip, 20px-wide grid cell
          SizedBox(
            width: 20,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 2),
              decoration: BoxDecoration(
                color: c.surface2,
                borderRadius: BorderRadius.circular(4),
              ),
              child: Text(
                source.number.toString(),
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontFamily: 'JetBrainsMono',
                  fontSize: 9,
                  color: c.ink3,
                ),
              ),
            ),
          ),
          const SizedBox(width: 8),
          // .url — ink-1 weight 500 / 11.5
          Expanded(
            child: Text(
              source.url,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                fontFamily: 'Manrope',
                fontSize: 11.5,
                fontWeight: FontWeight.w500,
                color: c.ink1,
              ),
            ),
          ),
          if (source.freshness != null) ...[
            const SizedBox(width: 8),
            _FreshnessBadge(
              freshness: source.freshness!,
              label: source.freshnessLabel,
            ),
          ],
        ],
      ),
    );
  }
}

class _FreshnessBadge extends StatelessWidget {
  const _FreshnessBadge({required this.freshness, this.label});

  final SourceFreshness freshness;
  final String? label;

  @override
  Widget build(BuildContext context) {
    final c = KaiTheme.of(context).colors;
    // Canon: .ok positive mono 10, .warn warning mono 10
    final isFresh = freshness == SourceFreshness.fresh;
    final color = isFresh ? c.positive : c.warning;
    final glyph = isFresh ? '✓' : '⚠';
    final text = label ?? (isFresh ? 'fresh' : 'stale');
    return Text(
      '$glyph $text',
      style: TextStyle(
        fontFamily: 'JetBrainsMono',
        fontSize: 10,
        color: color,
      ),
    );
  }
}

// ─── Action row (.ds-actions .act) ───────────────────────────────────────────

class _DetailActionRow extends StatelessWidget {
  const _DetailActionRow({required this.action, required this.onTap});

  final DetailAction action;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final c = KaiTheme.of(context).colors;
    final color = switch (action.style) {
      DetailActionStyle.normal => c.ink1,
      DetailActionStyle.primary => c.accent,
      DetailActionStyle.danger => c.negative,
    };
    final iconColor = switch (action.style) {
      DetailActionStyle.normal => c.ink2,
      DetailActionStyle.primary => c.accent,
      DetailActionStyle.danger => c.negative,
    };

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(8),
      child: Padding(
        // Canon: padding 10 8
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 10),
        child: Row(
          children: [
            // Icon column — grid 22, SVG 14×14 within (.act svg width 14)
            SizedBox(
              width: 22,
              child: KaiIcon(action.icon, size: 14, color: iconColor),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: Text(
                action.label,
                style: TextStyle(
                  fontFamily: 'Manrope',
                  fontSize: 12.5,
                  fontWeight: FontWeight.w500,
                  letterSpacing: -0.005 * 12.5,
                  color: color,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
