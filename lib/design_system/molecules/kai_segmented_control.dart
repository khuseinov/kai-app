import 'package:flutter/material.dart';

import 'package:kai_app/design_system/theme/kai_theme.dart';
import 'package:kai_app/design_system/tokens/kai_tokens.dart';

/// v3 segmented pill control. Canon: `new-design/settings.html § .seg`.
///
/// ```
/// container: surface-3 bg, KaiRadius.br8 (8px), padding 2, gap 2 between options
/// option: padding 4 × 9, font 500/11 Manrope, color ink-3, KaiRadius.br1 (6px)
/// active: surface bg, color ink-1
/// ```
///
/// Selection is index-based. Caller maps label strings to whatever T their
/// state uses (theme enum, locale code, etc.).
class KaiSegmentedControl extends StatelessWidget {
  const KaiSegmentedControl({
    required this.options,
    required this.selectedIndex,
    required this.onSelected,
    super.key,
  });

  final List<String> options;
  final int selectedIndex;
  final ValueChanged<int> onSelected;

  @override
  Widget build(BuildContext context) {
    final c = KaiTheme.of(context).colors;
    return Container(
      padding: const EdgeInsets.all(2),
      decoration: BoxDecoration(
        color: c.surface3,
        borderRadius: KaiRadius.br8,
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          for (var i = 0; i < options.length; i++) ...[
            if (i > 0) const SizedBox(width: 2),
            _SegmentOption(
              label: options[i],
              active: i == selectedIndex,
              onTap: () => onSelected(i),
            ),
          ],
        ],
      ),
    );
  }
}

class _SegmentOption extends StatelessWidget {
  const _SegmentOption({
    required this.label,
    required this.active,
    required this.onTap,
  });

  final String label;
  final bool active;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final c = KaiTheme.of(context).colors;
    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 4),
        decoration: BoxDecoration(
          color: active ? c.surface : null,
          borderRadius: KaiRadius.br1, // 6px — canon inner segment radius
        ),
        child: Text(
          label,
          style: TextStyle(
            fontFamily: 'Manrope',
            fontSize: 11,
            fontWeight: FontWeight.w500,
            color: active ? c.ink1 : c.ink3,
          ),
        ),
      ),
    );
  }
}
