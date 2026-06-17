import 'package:flutter/material.dart';

import 'package:kai_app/design_system/atoms/atoms.dart';
import 'package:kai_app/design_system/primitives/primitives.dart';
import 'package:kai_app/design_system/theme/kai_theme.dart';
import 'package:kai_app/design_system/tokens/kai_tokens.dart';

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

    // Use ModalRoute instead of Navigator.canPop() so KaiAppBar rebuilds
    // automatically whenever the route stack changes (e.g. after a bottom
    // sheet opens on top). Navigator.canPop() is a one-shot snapshot that
    // does not register a dependency, so StatelessWidget would not rebuild.
    final hasBack =
        onBackPressed != null || (ModalRoute.of(context)?.canPop ?? false);

    return Padding(
      padding: const EdgeInsets.fromLTRB(KaiSpace.s4, KaiSpace.s4, KaiSpace.s4, 0), // 16, 16, 16, 0
      child: SizedBox(
        height: 28,
        child: Row(
          children: [
            // Left slot: back button or spacer
            if (hasBack)
              Transform.flip(
                key: const Key('kai_app_bar_back'),
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
