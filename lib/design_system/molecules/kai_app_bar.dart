import 'package:flutter/material.dart';

import '../atoms/atoms.dart';
import '../primitives/primitives.dart';
import '../theme/kai_theme.dart';
import '../tokens/kai_tokens.dart';

/// v3 canonical app bar for secondary screens.
///
/// Features a centered title and an optional left back button and trailing widget.
/// Designed according to COMPONENTS.md appbar specifications.
class KaiAppBar extends StatelessWidget implements PreferredSizeWidget {
  const KaiAppBar({
    required this.title,
    this.onBackPressed,
    this.trailing,
    super.key,
  });

  final String title;
  final VoidCallback? onBackPressed;
  final Widget? trailing;

  @override
  Widget build(BuildContext context) {
    final tokens = KaiTheme.of(context);
    final c = tokens.colors;

    final hasBack = onBackPressed != null || Navigator.of(context).canPop();

    return Padding(
      padding: const EdgeInsets.fromLTRB(KaiSpace.s4, KaiSpace.s4, KaiSpace.s4, 0), // 16, 16, 16, 0
      child: SizedBox(
        height: 28,
        child: Row(
          children: [
            // Left slot: back button or spacer
            if (hasBack)
              Transform.flip(
                flipX: true,
                child: KaiIconButton.surface(
                  onPressed: onBackPressed ?? () {
                    if (Navigator.of(context).canPop()) {
                      Navigator.of(context).pop();
                    }
                  },
                  icon: KaiIconName.chev,
                  iconSize: KaiIconButtonSize.sm,
                ),
              )
            else
              const SizedBox(width: 28),

            // Centered title
            Expanded(
              child: Center(
                child: Text(
                  title,
                  style: KaiType.small(color: c.ink1).copyWith(
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    letterSpacing: -0.005 * 13,
                  ),
                ),
              ),
            ),

            // Right slot: trailing widget or spacer matching left width
            SizedBox(
              width: 28,
              height: 28,
              child: trailing != null
                  ? Center(child: trailing)
                  : const SizedBox.shrink(),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Size get preferredSize => const Size.fromHeight(44); // 28 height + 16 top padding
}
