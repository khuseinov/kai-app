import 'package:flutter/material.dart';

import '../../../../design_system/theme/kai_theme.dart';
import '../../../../design_system/tokens/kai_tokens.dart';
import '../../../../design_system/atoms/atoms.dart';
import '../../../../design_system/primitives/primitives.dart';

/// A single row in a [KaiActionSheet].
///
/// Canon: `components.html § 03.9 .sheet.actions .act-row`.
class KaiActionItem {
  const KaiActionItem({
    required this.icon,
    required this.title,
    required this.onTap,
    this.meta,
    this.danger = false,
  });

  final KaiIconName icon;
  final String title;

  /// Optional right-aligned metadata (e.g. "⌘N", "auto", "off"). Mono font.
  final String? meta;

  /// When true, title + icon use the negative colour.
  final bool danger;

  final VoidCallback onTap;
}

/// Quick-actions bottom sheet — swipe-down from top.
///
/// **v3 R3 fix**: this widget is DUMB. It calls `item.onTap` directly and
/// contains NO `Navigator` logic. Use [showKaiActionSheet] to present the
/// sheet as a modal and handle pop-then-callback.
///
/// Canon: `components.html § 03.9 .sheet.actions`:
/// ```
/// .act-row {
///   grid: 22px 1fr auto;
///   gap: 12;
///   padding: 10 8;           // vertical 10, horizontal 8
///   border-radius: 10;       // → KaiRadius.r2 (10px)
/// }
/// .title  { 13.5 / 500 / ink-1 / -0.005em }
/// .meta   { mono 10.5 / ink-3 }
/// .icon   { svg 18 / ink-2 }
/// .danger { title + icon = negative }
/// ```
///
/// Shell chrome (radius `24 24 0 0`, drag indicator, padding 12×14×16)
/// is provided by [KaiSheetShell].
class KaiActionSheet extends StatelessWidget {
  const KaiActionSheet({required this.items, super.key});

  final List<KaiActionItem> items;

  @override
  Widget build(BuildContext context) {
    return KaiSheetShell(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          for (final item in items)
            _ActionRow(item: item),
        ],
      ),
    );
  }
}

// ─── Presentation helper ──────────────────────────────────────────────────────

/// Presents [KaiActionSheet] as a modal bottom sheet.
///
/// This is the ONLY place that owns both `showModalBottomSheet` and
/// `Navigator.pop`. Each item's [KaiActionItem.onTap] is wrapped so the sheet
/// dismisses first, then the caller's callback fires — keeping navigation
/// logic out of the widget tree.
Future<void> showKaiActionSheet(
  BuildContext context, {
  required List<KaiActionItem> items,
}) {
  return showModalBottomSheet<void>(
    context: context,
    backgroundColor: Colors.transparent,
    elevation: 0,
    isScrollControlled: false,
    builder: (sheetContext) => KaiActionSheet(
      items: items
          .map(
            (item) => KaiActionItem(
              icon: item.icon,
              title: item.title,
              meta: item.meta,
              danger: item.danger,
              onTap: () {
                Navigator.of(sheetContext).pop();
                item.onTap();
              },
            ),
          )
          .toList(),
    ),
  );
}

// ─── Private row widget ───────────────────────────────────────────────────────

class _ActionRow extends StatelessWidget {
  const _ActionRow({required this.item});

  final KaiActionItem item;

  @override
  Widget build(BuildContext context) {
    final c = KaiTheme.of(context).colors;
    // Canon: danger variant → title + icon = negative; non-danger uses ink-1/ink-2.
    final titleColor = item.danger ? c.negative : c.ink1;
    final iconColor = item.danger ? c.negative : c.ink2;

    return InkWell(
      onTap: item.onTap,
      // canon: border-radius 10 → KaiRadius.r2 (10px)
      borderRadius: const BorderRadius.all(Radius.circular(KaiRadius.r2)),
      child: Padding(
        // canon: padding 10 8 (vertical 10, horizontal 8)
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 10),
        child: Row(
          children: [
            // Icon column — grid 22px, SVG 18×18 within
            SizedBox(
              width: 22, // canon: grid 22px column
              child: KaiIcon(item.icon, size: 18, color: iconColor),
            ),
            const SizedBox(width: KaiSpace.s3), // canon: gap 12
            // Title (1fr)
            Expanded(
              child: Text(
                item.title,
                style: TextStyle(
                  fontFamily: 'Manrope',
                  // canon: 13.5 / 500 / ink-1 / -0.005em
                  fontSize: 13.5,
                  fontWeight: FontWeight.w500,
                  letterSpacing: -0.005 * 13.5,
                  color: titleColor,
                ),
              ),
            ),
            // Meta (auto) — mono 10.5 ink-3
            if (item.meta != null) ...[
              const SizedBox(width: KaiSpace.s3), // canon: gap 12
              Text(
                item.meta!,
                style: TextStyle(
                  fontFamily: 'JetBrainsMono',
                  fontSize: 10.5, // canon: mono 10.5
                  color: c.ink3,
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
