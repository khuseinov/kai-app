import 'package:flutter/material.dart';

import '../theme/kai_theme.dart';
import '../tokens/kai_tokens.dart';
import '../primitives/kai_icon.dart';

/// v3 side-panel nav row. Canon: `new-design/nav.html § chat-row`.
///
/// Active state pulls accent-wash background with a 2px left border in accent.
///
/// Layout (left → right):
///
///   [icon? 14×14]   [label 11px Manrope w500]   [trailing?]
///
/// `padding: 14 horizontal × 7 vertical`.
///
/// Pass [KaiBadge.dot()] as [trailing] to render the memory notification dot.
class KaiNavItem extends StatelessWidget {
  const KaiNavItem({
    required this.label,
    this.icon,
    this.trailing,
    this.active = false,
    this.onTap,
    super.key,
  });

  /// Primary label text.
  final String label;

  /// Optional leading icon (size 14 per canon nav row).
  final KaiIconName? icon;

  /// Optional trailing widget (e.g. [KaiBadge.dot()], count badge, chevron).
  final Widget? trailing;

  /// When true, paints the active surface (accent-wash bg + 2px left accent border).
  final bool active;

  /// Optional tap callback. When null, the row is non-interactive but still renders.
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final c = KaiTheme.of(context).colors;
    final labelColor = active ? c.accent : c.ink1;
    final iconColor = active ? c.accent : c.ink2;

    final row = Padding(
      padding: const EdgeInsets.symmetric(
        horizontal: 14, // canon: nav row horizontal padding
        vertical: 7, // canon: nav row vertical padding
      ),
      child: Row(
        children: [
          if (icon != null) ...[
            KaiIcon(icon!, size: 14, color: iconColor),
            const SizedBox(width: 9), // canon: gap between icon and label
          ],
          Expanded(
            child: Text(
              label,
              style: TextStyle(
                fontFamily: 'Manrope',
                fontSize: 11,
                fontWeight: FontWeight.w500,
                color: labelColor,
                letterSpacing: -0.005 * 11,
              ),
            ),
          ),
          if (trailing != null) ...[
            const SizedBox(width: KaiSpace.s2),
            trailing!,
          ],
        ],
      ),
    );

    final decorated = DecoratedBox(
      decoration: BoxDecoration(
        color: active ? c.accentWash : Colors.transparent,
        border: Border(
          left: BorderSide(
            color: active ? c.accent : Colors.transparent,
            width: 2, // canon: 2px accent left border on active row
          ),
        ),
      ),
      child: row,
    );

    if (onTap == null) return decorated;
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        child: decorated,
      ),
    );
  }
}
