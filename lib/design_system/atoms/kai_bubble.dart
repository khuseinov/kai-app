import 'package:flutter/material.dart';
import 'package:flutter_markdown/flutter_markdown.dart';

import '../theme/kai_theme.dart';
import '../tokens/kai_tokens.dart';

/// Internal variant selector.
enum _KaiBubbleVariant { user, kai, system }

/// Atomic message bubble — 3 variants:
///
/// - `KaiBubble.user(content)` — surface-2 bg, right-aligned, max 78% width,
///   asymmetric radius (tail-down right).
/// - `KaiBubble.kai(content)` — bg-coloured (transparent visually), full
///   width, Markdown rendering.
/// - `KaiBubble.system(content)` — inline italic small text, ink-3, centered.
class KaiBubble extends StatelessWidget {
  const KaiBubble.user(this.content, {super.key})
      : _variant = _KaiBubbleVariant.user;

  const KaiBubble.kai(this.content, {super.key})
      : _variant = _KaiBubbleVariant.kai;

  const KaiBubble.system(this.content, {super.key})
      : _variant = _KaiBubbleVariant.system;

  final String content;
  final _KaiBubbleVariant _variant;

  @override
  Widget build(BuildContext context) {
    final tokens = KaiTheme.of(context);
    switch (_variant) {
      case _KaiBubbleVariant.user:
        return _user(tokens);
      case _KaiBubbleVariant.kai:
        return _kai(tokens);
      case _KaiBubbleVariant.system:
        return _system(tokens);
    }
  }

  Widget _user(KaiTokens tokens) {
    final c = tokens.colors;
    return LayoutBuilder(
      builder: (context, constraints) {
        final maxWidth = constraints.maxWidth * 0.78;
        return Align(
          alignment: Alignment.centerRight,
          child: ConstrainedBox(
            constraints: BoxConstraints(maxWidth: maxWidth),
            child: Container(
              padding: const EdgeInsets.symmetric(
                vertical: KaiSpace.s3,
                horizontal: KaiSpace.s4,
              ),
              decoration: BoxDecoration(
                color: c.surface2,
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(16),
                  topRight: Radius.circular(16),
                  bottomLeft: Radius.circular(16),
                  bottomRight: Radius.circular(4),
                ),
              ),
              child: Text(content, style: KaiType.body(color: c.ink1)),
            ),
          ),
        );
      },
    );
  }

  Widget _kai(KaiTokens tokens) {
    final c = tokens.colors;
    return Container(
      width: double.infinity,
      color: c.bg,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.only(
              left: KaiSpace.s4,
              top: KaiSpace.s3,
              bottom: 3,
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: 12,
                  height: 3,
                  decoration: const BoxDecoration(
                    gradient: KaiTide.gradient,
                    borderRadius: KaiRadius.brPill,
                  ),
                ),
                const SizedBox(width: 6),
                Text(
                  'KAI',
                  style: TextStyle(
                    fontFamily: 'JetBrainsMono',
                    fontSize: 9,
                    fontWeight: FontWeight.w400,
                    height: 1.4,
                    letterSpacing: 9 * 0.08,
                    color: c.ink3,
                  ),
                ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.only(
              left: KaiSpace.s4,
              right: KaiSpace.s4,
              bottom: KaiSpace.s3,
            ),
            child: MarkdownBody(
              data: content,
              styleSheet: MarkdownStyleSheet(
                p: KaiType.body(color: c.ink1),
                h1: KaiType.h1(color: c.ink1),
                h2: KaiType.h2(color: c.ink1),
                h3: KaiType.h3(color: c.ink1),
                code: KaiType.mono(color: c.ink1),
                codeblockDecoration: BoxDecoration(
                  color: c.surface2,
                  borderRadius: KaiRadius.br2,
                ),
                blockquote: KaiType.body(color: c.ink2).copyWith(
                  fontStyle: FontStyle.italic,
                ),
                listBullet: KaiType.body(color: c.ink1),
                em: KaiType.body(color: c.ink1).copyWith(
                  fontStyle: FontStyle.italic,
                ),
                strong: KaiType.body(color: c.ink1).copyWith(
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _system(KaiTokens tokens) {
    final c = tokens.colors;
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: KaiSpace.s2),
      child: Center(
        child: Text(
          content,
          textAlign: TextAlign.center,
          style: KaiType.small(color: c.ink3).copyWith(
            fontStyle: FontStyle.italic,
          ),
        ),
      ),
    );
  }
}
