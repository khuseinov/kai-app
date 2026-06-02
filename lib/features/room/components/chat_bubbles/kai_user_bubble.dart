import 'package:flutter/material.dart';

import '../../../../design_system/theme/kai_theme.dart';
import '../../../../design_system/tokens/kai_tokens.dart';

/// v3 user message bubble — right-aligned pill.
///
/// Canon: `new-design/room.html § .user-b` (authoritative — real chat frame).
///
/// ## Sizing decisions (canon vs. token)
///
/// | Property     | Canon HTML (room.html)  | Dart value          | Source          |
/// |--------------|-------------------------|---------------------|-----------------|
/// | padding-v    | 9px                     | literal 9           | exact           |
/// | padding-h    | 13px                    | literal 13          | exact           |
/// | font-size    | 13px                    | literal 13          | exact           |
/// | line-height  | 18.85px ÷ 13px ≈ 1.45  | 1.45                | exact           |
/// | letter-spc   | -0.08px ÷ 13 ≈ -0.006em | -0.006 * 13        | exact           |
/// | border-radius| 16/16/4/16              | literal             | exact           |
///
/// Prior version used 18px radii and 12/16px padding from components.html.
/// room.html is the authoritative context (real chat frame, not catalog display).
/// All values verified with spec-viewer 2026-05-29.
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
            // canon: room.html .user-b — 9px vertical / 13px horizontal
            // — verified spec-viewer 2026-05-29
            vertical: 9, // canon: 9px
            horizontal: 13, // canon: 13px
          ),
          decoration: BoxDecoration(
            color: c.surface2,
            // canon: room.html .user-b border-radius = 16px 16px 4px 16px
            // — verified spec-viewer 2026-05-29 (was 18/18/4/18 from components.html)
            borderRadius: const BorderRadius.only(
              topLeft: Radius.circular(16), // canon: 16
              topRight: Radius.circular(16), // canon: 16
              bottomRight: Radius.circular(4), // canon: 4 (tail corner)
              bottomLeft: Radius.circular(16), // canon: 16
            ),
          ),
          child: Text(
            text,
            style: KaiType.small(color: c.ink1).copyWith(
              // canon: room.html .user-b — 13px font-size
              // — verified spec-viewer 2026-05-29 (was 13.5px from D2 decision
              //   which mis-targeted .txt inside .kai-b, not .user-b)
              fontSize: 13, // canon: 13px
              // 18.85px / 13px ≈ 1.45
              height: 1.45, // canon: line-height ~1.45
              // -0.08px / 13px ≈ -0.00615em
              letterSpacing: 13 * -0.006, // canon: letter-spacing -0.08px
            ),
          ),
        ),
      ),
    );
  }
}
