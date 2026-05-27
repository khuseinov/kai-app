import 'package:flutter/material.dart';

import '../atoms/kai_bottom_sheet_shell.dart';
import '../atoms/kai_icon.dart';
import '../theme/kai_theme.dart';

/// A single row in a [KaiActionSheet].
///
/// Canon: `components.html § 03.9 .sheet.actions .act-row`.
class ActionSheetItem {
  const ActionSheetItem({
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
/// Canon: `components.html § 03.9 .sheet.actions`:
///
/// ```
/// .act-row {
///   grid: 22px 1fr auto;
///   gap: 12;
///   padding: 10 8;
///   border-radius: 10;
/// }
/// .title  { 13.5 / 500 / ink-1 / -0.005em }
/// .meta   { mono 10.5 / ink-3 }
/// .icon   { svg 18 / ink-2 }
/// .danger { title + icon = negative }
/// ```
///
/// Use [KaiActionSheet.show] to present via `showModalBottomSheet`. The shell
/// (radius `24 24 0 0`, drag indicator, padding 12×14×16) is provided by
/// [KaiBottomSheetShell].
class KaiActionSheet extends StatelessWidget {
  const KaiActionSheet({required this.items, super.key});

  final List<ActionSheetItem> items;

  /// Show as a modal bottom sheet. Returns when the sheet is dismissed.
  static Future<void> show(
    BuildContext context, {
    required List<ActionSheetItem> items,
  }) {
    return showModalBottomSheet<void>(
      context: context,
      // Sheet shell paints its own background + radius; let modal stay transparent.
      backgroundColor: Colors.transparent,
      // Canon: shell has border-top, no shadow — match showModalBottomSheet defaults
      // but suppress its own elevation.
      elevation: 0,
      isScrollControlled: false,
      builder: (sheetContext) => KaiActionSheet(items: items),
    );
  }

  @override
  Widget build(BuildContext context) {
    return KaiBottomSheetShell(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          for (final item in items)
            _ActionRow(
              item: item,
              onTap: () {
                Navigator.of(context).maybePop();
                item.onTap();
              },
            ),
        ],
      ),
    );
  }
}

class _ActionRow extends StatelessWidget {
  const _ActionRow({required this.item, required this.onTap});

  final ActionSheetItem item;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final c = KaiTheme.of(context).colors;
    // Canon: danger variant → title + icon = negative; non-danger uses ink-1/ink-2.
    final titleColor = item.danger ? c.negative : c.ink1;
    final iconColor = item.danger ? c.negative : c.ink2;

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(10),
      child: Padding(
        // Canon: padding 10 8 = vertical 10, horizontal 8
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 10),
        child: Row(
          children: [
            // Icon column — grid 22, SVG 18×18 within
            SizedBox(
              width: 22,
              child: KaiIcon(item.icon, size: 18, color: iconColor),
            ),
            const SizedBox(width: 12),
            // Title (1fr)
            Expanded(
              child: Text(
                item.title,
                style: TextStyle(
                  fontFamily: 'Manrope',
                  fontSize: 13.5,
                  fontWeight: FontWeight.w500,
                  letterSpacing: -0.005 * 13.5,
                  color: titleColor,
                ),
              ),
            ),
            // Meta (auto) — mono 10.5 ink-3
            if (item.meta != null) ...[
              const SizedBox(width: 12),
              Text(
                item.meta!,
                style: TextStyle(
                  fontFamily: 'JetBrainsMono',
                  fontSize: 10.5,
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
