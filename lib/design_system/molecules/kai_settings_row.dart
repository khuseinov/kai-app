import 'package:flutter/material.dart';

import '../atoms/kai_icon.dart';
import '../theme/kai_theme.dart';

/// Single settings list row. Canon: `new-design/settings.html § .row`.
///
/// ```
/// padding 9 x 11, radius 8
/// grid: 16px icon | 1fr body | auto trail; gap 9
/// icon: 15 x 15 SVG, ink-3 color (or negative on danger row)
/// body title: Manrope 500/12, color ink-1, letter-spacing -0.005em
/// body subtitle: JetBrains Mono 400/10, color ink-3
/// trail: any widget — chevron, KaiToggle, KaiSegmentedControl, status text
/// ```
///
/// [danger] flips title + icon to the negative token (for "Удалить мои данные"
/// rows and "Выйти" link). Use inside a [KaiSettingsGroup] danger variant for
/// the full coral surface.
class KaiSettingsRow extends StatelessWidget {
  const KaiSettingsRow({
    required this.icon,
    required this.title,
    this.subtitle,
    this.trailing,
    this.onTap,
    this.danger = false,
    super.key,
  });

  final KaiIconName icon;
  final String title;
  final String? subtitle;

  /// Right-side widget. Common choices: KaiToggle, KaiSegmentedControl,
  /// chevron via KaiIcon(chev), a status Text + KaiIcon row, or null.
  final Widget? trailing;
  final VoidCallback? onTap;
  final bool danger;

  @override
  Widget build(BuildContext context) {
    final c = KaiTheme.of(context).colors;
    final titleColor = danger ? c.negative : c.ink1;
    final iconColor = danger ? c.negative : c.ink3;

    final content = Padding(
      padding: const EdgeInsets.symmetric(horizontal: 11, vertical: 9),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          SizedBox(
            width: 16,
            child: KaiIcon(icon, size: 15, color: iconColor),
          ),
          const SizedBox(width: 9),
          Expanded(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: TextStyle(
                    fontFamily: 'Manrope',
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                    color: titleColor,
                    letterSpacing: -0.005 * 12,
                  ),
                ),
                if (subtitle != null) ...[
                  const SizedBox(height: 1),
                  Text(
                    subtitle!,
                    style: TextStyle(
                      fontFamily: 'JetBrainsMono',
                      fontSize: 10,
                      fontWeight: FontWeight.w400,
                      color: c.ink3,
                    ),
                  ),
                ],
              ],
            ),
          ),
          if (trailing != null) ...[
            const SizedBox(width: 9),
            trailing!,
          ],
        ],
      ),
    );

    if (onTap == null) return content;
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(8),
      child: content,
    );
  }
}
