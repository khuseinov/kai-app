import 'package:flutter/material.dart';
import 'package:flutter_markdown/flutter_markdown.dart';

import '../molecules/source_card.dart';
import '../theme/kai_theme.dart';
import '../tokens/kai_tokens.dart';

/// Internal variant selector.
enum _KaiBubbleVariant { user, kai, system }

/// Small tide-gradient pill used before the "kai" label in .who rows.
///
/// Static variant: 12×3px, tide-gradient, brPill.
/// Pass [width] to animate (used in _StreamingKaiBubble).
class TideGlyph extends StatelessWidget {
  const TideGlyph({
    this.width = 12,
    this.height = 3,
    super.key,
  });

  final double width;
  final double height;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: width,
      height: height,
      decoration: const BoxDecoration(
        gradient: KaiTide.gradient,
        borderRadius: KaiRadius.brPill,
      ),
    );
  }
}

/// Atomic message bubble — 3 variants:
///
/// - `KaiBubble.user(content)` — surface-2 bg, right-aligned, max 78% width,
///   asymmetric radius 16-16-4-16 per HTML canon.
/// - `KaiBubble.kai(content, {sources})` — bg-coloured (transparent visually),
///   full width, Markdown rendering, .who row with TideGlyph, optional SourceCard.
/// - `KaiBubble.system(content)` — inline italic small text, ink-3, centered.
class KaiBubble extends StatelessWidget {
  const KaiBubble.user(this.content, {super.key})
      : _variant = _KaiBubbleVariant.user,
        _sources = null;

  const KaiBubble.kai(
    this.content, {
    List<SourceCard>? sources,
    super.key,
  })  : _variant = _KaiBubbleVariant.kai,
        _sources = sources;

  const KaiBubble.system(this.content, {super.key})
      : _variant = _KaiBubbleVariant.system,
        _sources = null;

  final String content;
  final _KaiBubbleVariant _variant;
  final List<SourceCard>? _sources;

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
              // HTML canon: padding 9px 13px
              padding: const EdgeInsets.symmetric(
                vertical: 9,
                horizontal: 13,
              ),
              decoration: BoxDecoration(
                color: c.surface2,
                // HTML canon room.html:146 — 16px 16px 4px 16px
                // (topLeft, topRight, bottomRight=4, bottomLeft=16)
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(16),
                  topRight: Radius.circular(16),
                  bottomLeft: Radius.circular(16),
                  bottomRight: Radius.circular(4),
                ),
              ),
              child: Text(
                content,
                // HTML canon: 13px / 1.45 / -0.005em
                style: TextStyle(
                  fontFamily: 'Manrope',
                  fontSize: 13,
                  fontWeight: FontWeight.w400,
                  height: 1.45,
                  letterSpacing: 13 * -0.005,
                  color: c.ink1,
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _kai(KaiTokens tokens) {
    final c = tokens.colors;
    return LayoutBuilder(
      builder: (context, constraints) {
        final maxWidth = constraints.maxWidth * 0.92;
        return ConstrainedBox(
          constraints: BoxConstraints(maxWidth: maxWidth),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // .who row — TideGlyph 12×3 + "kai" mono 9 ink3
              Row(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  const TideGlyph(width: 12, height: 3),
                  const SizedBox(width: 6),
                  Text(
                    'kai'.toUpperCase(), // canonical lowercase source per design voice rules
                    style: TextStyle(
                      fontFamily: 'JetBrainsMono',
                      fontSize: 9,
                      fontWeight: FontWeight.w400,
                      height: 1.4,
                      // HTML canon: letter-spacing 0.08em
                      letterSpacing: 9 * 0.08,
                      color: c.ink3,
                    ),
                  ),
                ],
              ),
              // Gap 5px between .who and .txt
              const SizedBox(height: 5),
              // .txt — MarkdownBody, 13.5px / 1.5 / -0.005em ink1
              MarkdownBody(
                data: content,
                styleSheet: MarkdownStyleSheet(
                  p: TextStyle(
                    fontFamily: 'Manrope',
                    fontSize: 13.5,
                    fontWeight: FontWeight.w400,
                    height: 1.5,
                    letterSpacing: 13.5 * -0.005,
                    color: c.ink1,
                  ),
                  h1: KaiType.h1(color: c.ink1),
                  h2: KaiType.h2(color: c.ink1),
                  h3: KaiType.h3(color: c.ink1),
                  code: KaiType.mono(color: c.ink1),
                  codeblockDecoration: BoxDecoration(
                    color: c.surface2,
                    borderRadius: KaiRadius.br2,
                  ),
                  blockquote: TextStyle(
                    fontFamily: 'Manrope',
                    fontSize: 13.5,
                    height: 1.5,
                    fontStyle: FontStyle.italic,
                    color: c.ink2,
                  ),
                  listBullet: TextStyle(
                    fontFamily: 'Manrope',
                    fontSize: 13.5,
                    color: c.ink1,
                  ),
                  em: TextStyle(
                    fontFamily: 'Manrope',
                    fontSize: 13.5,
                    fontStyle: FontStyle.italic,
                    color: c.ink1,
                  ),
                  strong: TextStyle(
                    fontFamily: 'Manrope',
                    fontSize: 13.5,
                    fontWeight: FontWeight.w600,
                    color: c.ink1,
                  ),
                ),
              ),
              // SourceCard — margin-top 3px when sources present
              if (_sources != null && _sources.isNotEmpty) ...[
                const SizedBox(height: 3),
                ..._sources,
              ],
            ],
          ),
        );
      },
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
