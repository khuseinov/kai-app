import 'package:flutter/material.dart';

import '../atoms/kai_icon.dart';
import '../theme/kai_theme.dart';
import '../tokens/kai_tokens.dart';

/// Side-panel row used by the nav drawer.
///
/// Source: `new-design/nav.html § chat-row` — active state pulls accent-wash
/// background with a 2px left border in accent.
///
/// Layout (left → right):
///
///   [icon? 14×14]   [label 11px Manrope w500]   [trailing?]
///
/// `padding: 14 horizontal × 7 vertical`.
class NavItem extends StatelessWidget {
  const NavItem({
    required this.label,
    this.icon,
    this.trailing,
    this.active = false,
    this.onTap,
    super.key,
  });

  /// Primary label text.
  final String label;

  /// Optional leading icon (size 18).
  final KaiIconName? icon;

  /// Optional trailing widget (e.g. unread dot, badge count, chevron).
  final Widget? trailing;

  /// When true, paints the active surface + accent left border.
  final bool active;

  /// Optional tap callback. When null, the row is non-interactive but still
  /// renders.
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final c = KaiTheme.of(context).colors;
    final labelColor = active ? c.accent : c.ink1;
    final iconColor = active ? c.accent : c.ink2;

    final row = Padding(
      padding: const EdgeInsets.symmetric(
        horizontal: 14,
        vertical: 7,
      ),
      child: Row(
        children: [
          if (icon != null) ...[
            KaiIcon(icon!, size: 14, color: iconColor),
            const SizedBox(width: 9),
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
            width: 2,
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
