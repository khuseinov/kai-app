import 'package:flutter/material.dart';

import '../../../../core/design/theme/theme_extensions.dart';

/// Kai-invoked subtle FAB — appears when the user scrolls up while Kai
/// is streaming a response below the viewport. Tap returns to the
/// latest message. Auto-hides when already at the bottom.
class ScrollToLatestButton extends StatelessWidget {
  final VoidCallback onTap;
  final bool visible;

  const ScrollToLatestButton({
    super.key,
    required this.onTap,
    required this.visible,
  });

  @override
  Widget build(BuildContext context) {
    final colors = context.kaiColors;

    return AnimatedOpacity(
      opacity: visible ? 1 : 0,
      duration: const Duration(milliseconds: 200),
      child: IgnorePointer(
        ignoring: !visible,
        child: Material(
          color: colors.surface,
          shape: const CircleBorder(),
          elevation: 4,
          child: InkWell(
            customBorder: const CircleBorder(),
            onTap: onTap,
            child: Padding(
              padding: const EdgeInsets.all(10),
              child: Icon(
                Icons.arrow_downward_rounded,
                size: 18,
                color: colors.textSecondary,
              ),
            ),
          ),
        ),
      ),
    );
  }
}
