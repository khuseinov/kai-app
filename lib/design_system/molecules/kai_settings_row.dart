import 'package:flutter/material.dart';

import '../theme/kai_theme.dart';
import '../tokens/kai_tokens.dart';
import '../primitives/kai_icon.dart';

/// A single row in a settings list.
///
/// Use this widget to build settings screens: it handles the canonical layout
/// of a leading icon, a title, an optional subtitle, and an optional trailing
/// widget. It also handles tap highlighting and the danger (coral) variant for
/// destructive actions such as "Удалить мои данные" or "Выйти".
///
/// ## Layout
/// ```
/// padding 9 × 11, radius 8
/// grid: 16px icon | 1fr body | auto trail; gap 9
/// icon: 15 × 15 SVG, ink-3 color (or negative on danger row)
/// body title: Manrope 500/12, color ink-1, letter-spacing -0.005em
/// body subtitle: JetBrains Mono 400/10, color ink-3
/// trail: any widget — chevron, KaiToggle, KaiSegmentedControl, status text
/// ```
///
/// ## When to use
/// - Inside [KaiSettingsGroup] to build a section of settings.
/// - Trailing slot accepts any widget: [KaiToggle], [KaiSegmentedControl],
///   `KaiIcon(KaiIconName.chevRight, ...)`, or plain text.
///
/// ## Danger variant
/// Pass `danger: true` for destructive-action rows. This flips the title and
/// icon to the `negative` coral token. Typically combined with a
/// [KaiSettingsGroup] with `danger: true` for the full coral surface.
///
/// ## Tap feedback
/// The [InkWell] splash is softened: transparent splash colour + a faint
/// `surface2`-based highlight, so the tap is calm rather than the default
/// opaque ripple.
///
/// Canon: `new-design/settings.html § .row`.
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
  /// chevron via KaiIcon(chevRight), a status Text + KaiIcon row, or null.
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
    // Softened tap feedback: transparent splash + faint surface2/line highlight
    // so the tap reads as calm rather than the default opaque Material ripple.
    return InkWell(
      onTap: onTap,
      borderRadius: KaiRadius.br8,
      splashColor: Colors.transparent,
      highlightColor: c.surface2.withValues(alpha: 0.6),
      child: content,
    );
  }
}
