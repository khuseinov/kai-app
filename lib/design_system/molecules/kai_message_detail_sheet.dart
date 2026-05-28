import 'package:flutter/material.dart';

import '../theme/kai_theme.dart';
import '../tokens/kai_tokens.dart';
import '../atoms/atoms.dart';
import '../primitives/primitives.dart';

/// Freshness signal next to a source row.
enum KaiSourceFreshness { fresh, stale }

/// One numbered source entry in [KaiMessageDetailSheet].
///
/// Canon: `components.html § 03.9 .sheet.detail .src-mini`.
class KaiDetailSource {
  const KaiDetailSource({
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
  final KaiSourceFreshness? freshness;

  /// Display label for freshness (e.g. "fresh", "5d", "stale 7d"). When null
  /// and [freshness] is set, defaults match the canon ("fresh" / "stale").
  final String? freshnessLabel;
}

/// Visual emphasis for a detail action.
enum KaiDetailActionStyle { normal, primary, danger }

/// One row in the actions section of [KaiMessageDetailSheet].
///
/// Canon: `components.html § 03.9 .sheet.detail .ds-actions .act`.
class KaiDetailAction {
  const KaiDetailAction({
    required this.icon,
    required this.label,
    required this.onTap,
    this.style = KaiDetailActionStyle.normal,
  });

  final KaiIconName icon;
  final String label;
  final KaiDetailActionStyle style;
  final VoidCallback onTap;
}

/// Long-press detail sheet — surfaces sources + secondary actions for a Kai
/// message.
///
/// **v3 R3 fix**: this widget is DUMB. It calls action callbacks directly and
/// contains NO `Navigator` logic. Use [showKaiMessageDetailSheet] to present
/// the sheet as a modal and handle pop-then-callback.
///
/// Canon: `components.html § 03.9 .sheet.detail`:
/// ```
/// .sec-tt       mono 9.5 uppercase ink-3 letter-spacing 0.08em, padding 6 6 4
/// .src-mini     grid 20px 1fr auto, gap 8, padding 8 8, font 11.5 ink-2
/// .src-mini .n  mono 9 ink-3, bg surface-2, padding 2 5, r-4, center
/// .src-mini .url  ink-1 weight 500
/// .src-mini .ok   positive mono 10
/// .src-mini .warn warning mono 10
/// .ds-actions .act  grid 22 1fr, gap 10, padding 10 8, r-8
///                   font 500 12.5 ink-1 -0.005em
/// .primary          accent
/// .danger           negative
/// ```
class KaiMessageDetailSheet extends StatelessWidget {
  const KaiMessageDetailSheet({
    required this.sources,
    required this.actions,
    this.sourcesLabel = 'источники',
    this.actionsLabel = 'действия',
    super.key,
  });

  final List<KaiDetailSource> sources;
  final List<KaiDetailAction> actions;
  final String sourcesLabel;
  final String actionsLabel;

  @override
  Widget build(BuildContext context) {
    return KaiSheetShell(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          _SectionLabel(text: sourcesLabel),
          for (final src in sources) _SourceMiniRow(source: src),
          // canon: border-top 1px line between sources and actions sections
          const Padding(
            padding: EdgeInsets.only(top: KaiSpace.s1), // canon: top 6 — s1≈4, kept as s1+small visual gap
            child: KaiDivider(),
          ),
          _SectionLabel(text: actionsLabel),
          for (final action in actions) _DetailActionRow(action: action),
        ],
      ),
    );
  }
}

// ─── Presentation helper ──────────────────────────────────────────────────────

/// Presents [KaiMessageDetailSheet] as a modal bottom sheet.
///
/// This is the ONLY place that owns both `showModalBottomSheet` and
/// `Navigator.pop`. Each action's [KaiDetailAction.onTap] is wrapped so the
/// sheet dismisses first, then the caller's callback fires — keeping navigation
/// logic out of the widget tree.
Future<void> showKaiMessageDetailSheet(
  BuildContext context, {
  required List<KaiDetailSource> sources,
  required List<KaiDetailAction> actions,
  String sourcesLabel = 'источники',
  String actionsLabel = 'действия',
}) {
  return showModalBottomSheet<void>(
    context: context,
    backgroundColor: Colors.transparent,
    elevation: 0,
    builder: (sheetContext) => KaiMessageDetailSheet(
      sources: sources,
      actions: actions
          .map(
            (action) => KaiDetailAction(
              icon: action.icon,
              label: action.label,
              style: action.style,
              onTap: () {
                Navigator.of(sheetContext).pop();
                action.onTap();
              },
            ),
          )
          .toList(),
      sourcesLabel: sourcesLabel,
      actionsLabel: actionsLabel,
    ),
  );
}

// ─── Section label (.sec-tt) ─────────────────────────────────────────────────

class _SectionLabel extends StatelessWidget {
  const _SectionLabel({required this.text});

  final String text;

  @override
  Widget build(BuildContext context) {
    final c = KaiTheme.of(context).colors;
    return Padding(
      // canon: padding 6 6 4 (top 6, right 6, bottom 4, left 6)
      padding: const EdgeInsets.fromLTRB(6, 6, 6, 4),
      child: Text(
        text.toUpperCase(),
        style: TextStyle(
          fontFamily: 'JetBrainsMono',
          fontSize: 9.5, // canon: mono 9.5
          fontWeight: FontWeight.w400,
          letterSpacing: 0.08 * 9.5, // canon: letter-spacing 0.08em
          color: c.ink3,
        ),
      ),
    );
  }
}

// ─── Source row (.src-mini) ──────────────────────────────────────────────────

class _SourceMiniRow extends StatelessWidget {
  const _SourceMiniRow({required this.source});

  final KaiDetailSource source;

  @override
  Widget build(BuildContext context) {
    final c = KaiTheme.of(context).colors;
    return Padding(
      // canon: padding 8 8 (all 8)
      padding: const EdgeInsets.all(KaiSpace.s2),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          // .n — mono 9 ink-3 on surface-2 chip, 20px-wide grid cell
          SizedBox(
            width: 20, // canon: grid 20px column
            child: Container(
              padding: const EdgeInsets.symmetric(
                horizontal: 5, // canon: padding 2 5
                vertical: 2,
              ),
              decoration: BoxDecoration(
                color: c.surface2,
                // canon: r-4 → nearest token KaiRadius.r1 (6px) — closest below;
                // actual HTML value is 4px. Document literal: 4px used as-is.
                borderRadius: BorderRadius.circular(4), // canon: r-4 (4px)
              ),
              child: Text(
                source.number.toString(),
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontFamily: 'JetBrainsMono',
                  fontSize: 9, // canon: mono 9
                  color: c.ink3,
                ),
              ),
            ),
          ),
          const SizedBox(width: KaiSpace.s2), // canon: gap 8
          // .url — ink-1 weight 500 / 11.5
          Expanded(
            child: Text(
              source.url,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                fontFamily: 'Manrope',
                fontSize: 11.5, // canon: 11.5
                fontWeight: FontWeight.w500,
                color: c.ink1,
              ),
            ),
          ),
          if (source.freshness != null) ...[
            const SizedBox(width: KaiSpace.s2), // canon: gap 8
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

  final KaiSourceFreshness freshness;
  final String? label;

  @override
  Widget build(BuildContext context) {
    final c = KaiTheme.of(context).colors;
    // canon: .ok positive mono 10, .warn warning mono 10
    final isFresh = freshness == KaiSourceFreshness.fresh;
    final color = isFresh ? c.positive : c.warning;
    final glyph = isFresh ? '✓' : '⚠';
    final text = label ?? (isFresh ? 'fresh' : 'stale');
    return Text(
      '$glyph $text',
      style: TextStyle(
        fontFamily: 'JetBrainsMono',
        fontSize: 10, // canon: mono 10
        color: color,
      ),
    );
  }
}

// ─── Action row (.ds-actions .act) ───────────────────────────────────────────

class _DetailActionRow extends StatelessWidget {
  const _DetailActionRow({required this.action});

  final KaiDetailAction action;

  @override
  Widget build(BuildContext context) {
    final c = KaiTheme.of(context).colors;
    final color = switch (action.style) {
      KaiDetailActionStyle.normal => c.ink1,
      KaiDetailActionStyle.primary => c.accent,
      KaiDetailActionStyle.danger => c.negative,
    };
    final iconColor = switch (action.style) {
      KaiDetailActionStyle.normal => c.ink2,
      KaiDetailActionStyle.primary => c.accent,
      KaiDetailActionStyle.danger => c.negative,
    };

    return InkWell(
      onTap: action.onTap,
      // canon: r-8 → KaiRadius.r8 (8px)
      borderRadius: KaiRadius.br8,
      child: Padding(
        // canon: padding 10 8 (vertical 10, horizontal 8)
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 10),
        child: Row(
          children: [
            // Icon column — grid 22px, SVG 14×14 within (canon: .act svg width 14)
            SizedBox(
              width: 22, // canon: grid 22px column
              child: KaiIcon(action.icon, size: 14, color: iconColor),
            ),
            const SizedBox(width: 10), // canon: gap 10
            Expanded(
              child: Text(
                action.label,
                style: TextStyle(
                  fontFamily: 'Manrope',
                  // canon: 500 12.5 ink-1 -0.005em
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
