import 'package:flutter/material.dart';

import '../atoms/kai_icon.dart';
import '../atoms/kai_text.dart';
import '../theme/kai_theme.dart';
import '../tokens/kai_tokens.dart';

/// Side-panel row used by the nav drawer.
///
/// Source: `new-design/nav.html § chat-row` — active state pulls accent-wash
/// background with a 2px left border in accent.
///
/// Layout (left → right):
///
///   [icon? 18×18]   [label]   [trailing?]
///
/// `padding: 12 horizontal × 10 vertical`.
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
        horizontal: KaiSpace.s3,
        vertical: KaiSpace.s2 + 2, // 10
      ),
      child: Row(
        children: [
          if (icon != null) ...[
            KaiIcon(icon!, color: iconColor),
            const SizedBox(width: KaiSpace.s3),
          ],
          Expanded(
            child: KaiText.body(label, color: labelColor),
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
