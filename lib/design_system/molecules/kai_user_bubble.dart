import 'package:flutter/material.dart';

import '../theme/kai_theme.dart';
import '../tokens/kai_tokens.dart';

/// v3 user message bubble — right-aligned pill.
///
/// Canon: `new-design/components.html § .bub.user`
///
/// ## Sizing decisions (canon vs. token)
///
/// | Property     | Canon HTML     | Token used           | Drift   |
/// |--------------|----------------|----------------------|---------|
/// | padding-v    | 11px           | `KaiSpace.s3` (12px) | +1px    |
/// | padding-h    | 15px           | `KaiSpace.s4` (16px) | +1px    |
/// | font-size    | 13.5px (room)  | literal 13.5         | exact   |
/// | border-radius| 18/18/4/18     | literal — bubble-specific, not in scale |
///
/// The +1px drift on padding is within sub-pixel tolerance; token values are
/// preferred for grid consistency. The 18px and 4px radii are bubble-specific
/// values with no token equivalent; they are documented as `// canon:` literals.
///
/// Font size is **13.5px** per the locked D2 decision: room.html is the real
/// chat context and is canon; components.html's 15px is catalog display only.
/// Applied as `.copyWith(fontSize: 13.5)` on `KaiType.small` (14px base),
/// keeping all other Manrope metrics (weight, features, height) from the token.
///
/// API: `KaiUserBubble(text: 'Hello')`
class KaiUserBubble extends StatelessWidget {
  const KaiUserBubble({required this.text, super.key});

  final String text;

  @override
  Widget build(BuildContext context) {
    final c = KaiTheme.of(context).colors;

    return Align(
      alignment: Alignment.centerRight,
      child: ConstrainedBox(
        constraints: BoxConstraints(
          maxWidth: MediaQuery.sizeOf(context).width * 0.78,
        ),
        child: Container(
          padding: const EdgeInsets.symmetric(
            // canon: 11px vertical / 15px horizontal
            // token: KaiSpace.s3 (12) / KaiSpace.s4 (16) — ~1px drift each
            vertical: KaiSpace.s3,
            horizontal: KaiSpace.s4,
          ),
          decoration: BoxDecoration(
            color: c.surface2,
            // canon: border-radius 18px 18px 4px 18px
            // 18px and 4px are bubble-specific — no token; documented literals.
            borderRadius: const BorderRadius.only(
              topLeft: Radius.circular(18), // canon: 18
              topRight: Radius.circular(18), // canon: 18
              bottomRight: Radius.circular(4), // canon: 4 (tail corner)
              bottomLeft: Radius.circular(18), // canon: 18
            ),
          ),
          child: Text(
            text,
            style: KaiType.small(color: c.ink1).copyWith(
              // canon (D2 locked): 13.5px — room.html chat context, not the
              // components.html 15px catalog display. small base 14px.
              fontSize: 13.5, // canon: 13.5 (room / D2)
              height: 1.5, // canon: line-height 1.5
              letterSpacing: 13.5 * -0.005, // canon: letter-spacing -0.005em
            ),
          ),
        ),
      ),
    );
  }
}
