import 'package:flutter/material.dart';

import '../theme/kai_theme.dart';

/// Settings group container with optional section label + danger variant.
///
/// Canon: `new-design/settings.html § .s-label, .group, .danger-group`.
///
/// ```
/// (optional) s-label: JetBrains Mono 9/uppercase, ink-3,
///                     letter-spacing 0.1em, padding 2 4 0 (top/sides only)
/// .group:
///   bg surface-2, radius 12, padding 3, flex column
/// .danger-group:
///   bg surface, border 1px negative-wash, radius 12, padding 4
/// ```
///
/// Children should be [KaiSettingsRow] instances (or visually-compatible
/// widgets). Direct children — no Column wrapper needed inside.
class KaiSettingsGroup extends StatelessWidget {
  const KaiSettingsGroup({
    required this.children,
    this.label,
    this.danger = false,
    super.key,
  });

  /// Section label shown above the group. Lowercase canon ("внешний вид",
  /// "голос"); the widget uppercases via letter-spacing-heavy mono styling.
  /// Pass already-Russian text; localisation happens at caller.
  final String? label;

  /// Switches to negative-wash bordered "danger" variant for destructive
  /// rows like "Удалить мои данные".
  final bool danger;

  final List<Widget> children;

  @override
  Widget build(BuildContext context) {
    final c = KaiTheme.of(context).colors;

    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        if (label != null)
          Padding(
            padding: const EdgeInsets.fromLTRB(4, 2, 4, 0),
            child: Text(
              label!,
              style: TextStyle(
                fontFamily: 'JetBrainsMono',
                fontSize: 9,
                fontWeight: FontWeight.w400,
                color: c.ink3,
                letterSpacing: 0.1 * 9,
              ),
            ),
          ),
        if (label != null) const SizedBox(height: 6),
        Container(
          padding: EdgeInsets.all(danger ? 4 : 3),
          decoration: BoxDecoration(
            color: danger ? c.surface : c.surface2,
            border: danger ? Border.all(color: c.negativeWash, width: 1) : null,
            borderRadius: BorderRadius.circular(12),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: children,
          ),
        ),
      ],
    );
  }
}
