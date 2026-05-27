import 'package:flutter/material.dart';

import '../theme/kai_theme.dart';

/// Bottom-sheet container — pure visual shell.
///
/// Canon: `new-design/components.html § 03.9 .sheet` —
/// ```
/// background: surface (#FFF)
/// border-radius: 24px 24px 0 0
/// border-top: 1px line
/// padding: 12px 14px 16px
/// ::before drag indicator: 36×4 r-pill ink-4 opacity 0.4, mb 4
/// ```
///
/// Wraps any content with the canonical sheet chrome. Caller is responsible
/// for showing it via `showModalBottomSheet` or an `Overlay`.
class KaiBottomSheetShell extends StatelessWidget {
  const KaiBottomSheetShell({required this.child, super.key});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    final c = KaiTheme.of(context).colors;
    return Container(
      decoration: BoxDecoration(
        color: c.surface,
        borderRadius: const BorderRadius.only(
          topLeft: Radius.circular(24),
          topRight: Radius.circular(24),
        ),
        border: Border(top: BorderSide(color: c.line, width: 1)),
      ),
      padding: const EdgeInsets.fromLTRB(14, 12, 14, 16),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Drag indicator — 36×4 r-pill ink-4 op 0.4, centered, mb 4
          Center(
            child: Container(
              width: 36,
              height: 4,
              margin: const EdgeInsets.only(bottom: 4),
              decoration: BoxDecoration(
                color: c.ink4.withValues(alpha: 0.4),
                borderRadius: BorderRadius.circular(999),
              ),
            ),
          ),
          child,
        ],
      ),
    );
  }
}
