import 'package:flutter/material.dart';

import '../theme/kai_theme.dart';
import '../tokens/kai_tokens.dart';

/// v3 bottom-sheet container — pure visual shell.
///
/// Canon: `new-design/components.html § 03.9 .sheet` —
/// ```
/// background: surface (#FFF)
/// border-radius: 24px 24px 0 0   → KaiRadius.r24
/// border-top: 1px line
/// padding: 12px 14px 16px
/// ::before drag indicator: 36×4 r-pill ink-4 opacity 0.4, mb 4
/// ```
///
/// Tokenized from the v2 `KaiBottomSheetShell`:
/// - Top-corner radius: [KaiRadius.r24] (was hard-coded `circular(24)`).
/// - Drag-pill radius: [KaiRadius.brPill] (was `circular(999)`).
///
/// Inherent component dimensions (not available as generic tokens):
/// - Drag pill: 36×4 dp — these are the literal HTML-canon pixel sizes and
///   are acceptable as named constants within the component.
/// - Outer horizontal padding: 14 dp; vertical: top 12 dp, bottom 16 dp.
///   These match [KaiSpace.s3/s3_5/s4] approximately but the HTML spec uses
///   bespoke values; preserved as-is to stay pixel-faithful.
///
/// Wraps any content with the canonical sheet chrome. Caller is responsible
/// for showing it via `showModalBottomSheet` or an `Overlay`.
class KaiSheetShell extends StatelessWidget {
  const KaiSheetShell({required this.child, super.key});

  final Widget child;

  // ---------------------------------------------------------------------------
  // Inherent component dimensions
  // ---------------------------------------------------------------------------

  /// Drag-pill width: HTML canon 36 dp.
  static const double _pillWidth = 36;

  /// Drag-pill height: HTML canon 4 dp.
  static const double _pillHeight = 4;

  /// Drag-pill bottom margin separating it from the content: HTML canon 4 dp.
  static const double _pillBottomMargin = 4;

  /// Outer horizontal padding: HTML canon 14 dp.
  static const double _paddingH = 14;

  /// Outer top padding: HTML canon 12 dp.
  static const double _paddingTop = 12;

  /// Outer bottom padding: HTML canon 16 dp.
  static const double _paddingBottom = 16;

  @override
  Widget build(BuildContext context) {
    final c = KaiTheme.of(context).colors;
    return Container(
      decoration: BoxDecoration(
        color: c.surface,
        borderRadius: const BorderRadius.vertical(
          top: Radius.circular(KaiRadius.r24),
        ),
        border: Border(top: BorderSide(color: c.line)),
      ),
      padding: const EdgeInsets.fromLTRB(
        _paddingH,
        _paddingTop,
        _paddingH,
        _paddingBottom,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Drag indicator — 36×4 r-pill ink-4 op 0.4, centered, mb 4
          Center(
            child: Container(
              width: _pillWidth,
              height: _pillHeight,
              margin: const EdgeInsets.only(bottom: _pillBottomMargin),
              decoration: BoxDecoration(
                color: c.ink4.withValues(alpha: 0.4),
                borderRadius: KaiRadius.brPill,
              ),
            ),
          ),
          child,
        ],
      ),
    );
  }
}
