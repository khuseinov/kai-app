import 'package:flutter/material.dart';

import '../tokens/kai_tokens.dart';
import '../atoms/atoms.dart';
import '../primitives/primitives.dart';

// ─── KaiToastType ─────────────────────────────────────────────────────────────

/// Visual variant of a toast pill.
///
/// Source: `new-design/components.html § 03.12`.
///
/// - [neutral] / [positive] / [negative] — dark `ink-1` pill with a semantic
///   icon tint. Text color is always dark-palette `ink1` (F5F5F2) — the toast
///   is an always-dark "dark island" element regardless of the app theme.
/// - [memory] — tide-gradient pill, white text, `KaiGradientBar` marker.
///   Gradient MUST come from `KaiTide.gradient` (T1 audit fix — never a raw hex).
enum KaiToastType { neutral, positive, negative, memory }

// ─── KaiToast ─────────────────────────────────────────────────────────────────

/// Pure-presentational toast pill — v3 dumb widget.
///
/// Canon: `new-design/components.html § 03.12`.
///
/// ## Design notes
/// Padding: `7px 14px 7px 9px` → `EdgeInsets.fromLTRB(9, 7, 14, 7)`.
/// The token closest to this is `KaiSpace.s3 (12) / s1 (4)`. Canon is 7/14/9;
/// we preserve the literal from the HTML spec and document the drift.
///
/// Shape: `KaiRadius.brPill` (999px).
///
/// Shadow: `0 2px 12px rgba(0,0,0,0.16)` — not yet in `KaiShadow`; literal
/// used here per convention for sub-token shadow values.
///
/// ## v3 audit fixes applied
/// - **T1 (HIGH):** `memory` background uses `KaiTide.gradient` (the locked
///   token) — never a hardcoded hex `LinearGradient`.
/// - **R3 (MED):** NO Timer, NO Overlay, NO `show()` static method. All
///   overlay / timer logic lives in `KaiToastController`.
///
/// ## Icon tint mapping
/// | type     | icon        | tint                        | token source           |
/// |----------|-------------|-----------------------------|------------------------|
/// | neutral  | copy        | `dark.ink3` (#8E8E88)       | dark palette ink3      |
/// | positive | check       | `dark.positive` (#3DBE7A)   | dark palette positive  |
/// | negative | info        | `dark.negative` (#E66F60)   | dark palette negative  |
/// | memory   | KaiGradientBar 10×2.5 | white (0.75 alpha) | n/a                |
///
/// The dark-palette tokens are used for all solid variants because the toast
/// is always rendered on a dark (`ink-1`) surface — it's the canonical
/// "dark-island" pattern that ignores the surrounding theme.
class KaiToast extends StatelessWidget {
  const KaiToast({
    required this.type,
    required this.label,
    this.actionLabel,
    this.onAction,
    this.showCountdown = false,
    super.key,
  })  : _description = null,
        _rich = false;

  /// Rich / action toast archetype.
  ///
  /// Canon `components.html § 03.12` — the `.toast` with a 24px round `.glyph`,
  /// a `.body` (title + `<small>` description) and an `.open` action. This is
  /// the archetype that carries an **action**; the compact [KaiToast] should
  /// stay action-free (only the rich toast pairs text with a tappable affordance,
  /// which resolves the "what is this button?" ambiguity of compact+action).
  const KaiToast.rich({
    required String title,
    required String description,
    this.actionLabel,
    this.onAction,
    this.type = KaiToastType.neutral,
    super.key,
  })  : label = title,
        _description = description,
        _rich = true,
        showCountdown = false;

  /// Convenience factory for an undo toast.
  ///
  /// Sets [actionLabel] = 'Отменить' and [onAction] = [onUndo]. The action
  /// renders in tide-2 accent colour (same as all toast actions). Caller
  /// controls [type] and [label]; defaults to [KaiToastType.neutral] +
  /// [showCountdown] true so the auto-dismiss window is visible.
  factory KaiToast.undo({
    required String label,
    required VoidCallback onUndo,
    KaiToastType type = KaiToastType.neutral,
    bool showCountdown = true,
    Key? key,
  }) {
    return KaiToast(
      type: type,
      label: label,
      actionLabel: 'Отменить',
      onAction: onUndo,
      showCountdown: showCountdown,
      key: key,
    );
  }

  final KaiToastType type;

  /// Main message text. Manrope 500 11, letter-spacing -0.005em.
  final String label;

  /// Optional action label — renders as a compact [_ToastActionButton] (tide-2,
  /// 12px/w600, 4px padding). Readable on the dark pill surface.
  final String? actionLabel;

  /// Tap handler for [actionLabel].
  final VoidCallback? onAction;

  /// When `true`, renders a 110×2px countdown bar below the pill.
  ///
  /// This is a **static full-width bar** — the widget does not run a Timer
  /// or animation. The actual countdown animation is driven externally by
  /// [KaiToastController] via an AnimationController it passes in (future
  /// enhancement). For now: bar is visible when `showCountdown` is true,
  /// hidden when false.
  final bool showCountdown;

  /// Rich-archetype description line (the `<small>` under the title). Null for
  /// the compact archetype.
  final String? _description;

  /// Whether this is the rich (glyph + title + description + action) archetype.
  final bool _rich;

  @override
  Widget build(BuildContext context) {
    if (_rich) {
      return _RichToastPill(
        title: label,
        description: _description ?? '',
        actionLabel: actionLabel,
        onAction: onAction,
      );
    }

    final palette = _buildPalette(context, type);

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        _ToastPill(
          palette: palette,
          label: label,
          actionLabel: actionLabel,
          onAction: onAction,
        ),
        if (showCountdown) ...[
          // canon: 5px gap between pill and countdown bar
          const SizedBox(height: 5),
          const _CountdownBar(),
        ],
      ],
    );
  }
}

// ─── Pill (presentational) ────────────────────────────────────────────────────

class _ToastPill extends StatelessWidget {
  const _ToastPill({
    required this.palette,
    required this.label,
    required this.actionLabel,
    required this.onAction,
  });

  final _ToastPalette palette;
  final String label;
  final String? actionLabel;
  final VoidCallback? onAction;

  @override
  Widget build(BuildContext context) {
    return Container(
      // Canon padding: 7px top/bottom, 14px right, 9px left.
      // Nearest token combo: KaiSpace.s1 (4) top/bottom is too tight; s3 (12)
      // is too wide. Literal 7/14/9 from spec preserved — documented drift.
      padding: const EdgeInsets.fromLTRB(9, 7, 14, 7),
      decoration: BoxDecoration(
        gradient: palette.gradient,
        color: palette.bg,
        borderRadius: KaiRadius.brPill,
        boxShadow: const [
          BoxShadow(
            // Canon: 0 2px 12px rgba(0,0,0,0.16)
            color: Color.fromRGBO(0, 0, 0, 0.16),
            blurRadius: 12,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          // Icon / marker — 11×11 bounding box
          SizedBox(
            width: 11,
            height: 11,
            child: Center(child: palette.icon),
          ),
          // canon: 6px icon-to-label gap (between KaiSpace.s1=4 and s2=8)
          const SizedBox(width: 6),
          // Label: Manrope 500 11 letter-spacing -0.005em
          Flexible(
            child: Text(
              label,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                fontFamily: 'Manrope',
                fontSize: 11,
                fontWeight: FontWeight.w500,
                // canon: -0.005em × 11px = -0.055px
                letterSpacing: -0.005 * 11,
                color: palette.textColor,
              ),
            ),
          ),
          if (actionLabel != null && onAction != null) ...[
            // canon: 10px gap before action button
            const SizedBox(width: 10),
            // canon: .toast .open = 12px / w600 / tide-2 (#2BA8C9 = KaiTide.stop2)
            // — verified spec-viewer 2026-05-29.
            // KaiButton.text sm = 12.5px/w500 — that's a 0.5px/w100 delta.
            // Custom _ToastActionButton used for pixel-exact spec match.
            _ToastActionButton(
              label: actionLabel!,
              onTap: onAction!,
            ),
          ],
        ],
      ),
    );
  }
}

// ─── Rich pill (glyph + title + description + action) ──────────────────────────

/// Rich/action toast layout — canon `components.html § 03.12 .toast` with
/// `.glyph` + `.body` (`<strong>` title + `<small>` desc) + `.open` action.
///
/// 24px tide-gradient Kai glyph, title (Manrope 13.5px/600), description
/// (11.5px/500, muted), and the canon-exact tide-2 action. Sits on the same
/// near-black dark-island pill as the compact variant.
class _RichToastPill extends StatelessWidget {
  const _RichToastPill({
    required this.title,
    required this.description,
    required this.actionLabel,
    required this.onAction,
  });

  final String title;
  final String description;
  final String? actionLabel;
  final VoidCallback? onAction;

  @override
  Widget build(BuildContext context) {
    final dark = KaiTokens.dark.colors;
    final nearBlack = KaiTokens.light.colors.ink1; // #111114 dark-island bg

    return Container(
      // canon: same pill padding as compact (7/14/7/9)
      padding: const EdgeInsets.fromLTRB(9, 7, 14, 7),
      decoration: BoxDecoration(
        color: nearBlack,
        borderRadius: KaiRadius.brPill,
        boxShadow: const [
          BoxShadow(
            color: Color.fromRGBO(0, 0, 0, 0.16),
            blurRadius: 12,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          // canon: .glyph — 24px round Kai mark (tide gradient)
          Container(
            width: 24,
            height: 24,
            decoration: const BoxDecoration(
              gradient: KaiTide.gradientCorner,
              shape: BoxShape.circle,
            ),
          ),
          // canon: 8px glyph-to-body gap
          const SizedBox(width: 8),
          Flexible(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // canon: .body strong — 13.5px/600
                Text(
                  title,
                  style: TextStyle(
                    fontFamily: 'Manrope',
                    fontSize: 13.5,
                    fontWeight: FontWeight.w600,
                    letterSpacing: -0.005 * 13.5,
                    color: dark.ink1, // near-white on the dark pill
                    height: 1.45,
                  ),
                ),
                const SizedBox(height: 2), // canon: .body small margin-top 2px
                // canon: .body small — 11.5px/500 (muted caption)
                Text(
                  description,
                  style: TextStyle(
                    fontFamily: 'Manrope',
                    fontSize: 11.5,
                    fontWeight: FontWeight.w500,
                    letterSpacing: -0.005 * 11.5,
                    color: dark.ink3, // muted on dark pill
                    height: 1.45,
                  ),
                ),
              ],
            ),
          ),
          if (actionLabel != null && onAction != null) ...[
            const SizedBox(width: 10), // canon: 10px gap before action
            _ToastActionButton(label: actionLabel!, onTap: onAction!),
          ],
        ],
      ),
    );
  }
}

// ─── Countdown bar (static) ───────────────────────────────────────────────────

/// Static countdown bar — 110×2px pill with translucent track.
///
/// Canon: `.countdown-bar { width: 110px; height: 2px; border-radius: 999px;
/// background: rgba(255,255,255,0.2) }` with a `.bar { background:
/// rgba(255,255,255,0.6) }` fill at 100% width (static, no animation here).
///
/// Countdown animation is driven externally by [KaiToastController].
class _CountdownBar extends StatelessWidget {
  const _CountdownBar();

  @override
  Widget build(BuildContext context) {
    return const SizedBox(
      width: 110,
      height: 2,
      child: ClipRRect(
        borderRadius: KaiRadius.brPill,
        child: Stack(
          children: [
            // Track — full width, 20% white
            Positioned.fill(
              child: ColoredBox(color: Color.fromRGBO(255, 255, 255, 0.2)),
            ),
            // Static bar at full width (controller drives animation externally)
            Positioned.fill(
              child: ColoredBox(color: Color.fromRGBO(255, 255, 255, 0.6)),
            ),
          ],
        ),
      ),
    );
  }
}

// ─── Palette model ─────────────────────────────────────────────────────────────

class _ToastPalette {
  const _ToastPalette({
    required this.bg,
    required this.gradient,
    required this.textColor,
    required this.icon,
  });

  /// Solid background color. Null when [gradient] is set (memory variant).
  final Color? bg;

  /// Tide gradient — only for [KaiToastType.memory]. MUST be [KaiTide.gradient].
  final LinearGradient? gradient;

  final Color textColor;
  final Widget icon;
}

/// Builds the palette for a toast variant.
///
/// Dark palette tokens are used for all solid variants because toast is an
/// always-dark surface (dark-island pattern).
///
/// T1 audit fix: memory variant uses [KaiTide.gradient] — never a raw hex
/// `LinearGradient`. This is enforced by using the token const directly.
_ToastPalette _buildPalette(BuildContext context, KaiToastType type) {
  // Always-dark surface — pull from KaiTokens.dark regardless of theme.
  final dark = KaiTokens.dark.colors;
  // Dark-island background = the near-black ink (#111114 = light-palette ink1),
  // NOT dark.ink1 (#F5F5F2, which is the light TEXT colour). Canon
  // components.html .toast bg = rgb(17,17,20). (Prior code used dark.ink1 for the
  // bg → a near-white pill with near-white text, i.e. an invisible toast.)
  final nearBlack = KaiTokens.light.colors.ink1;

  switch (type) {
    case KaiToastType.neutral:
      // Canon: bg ink-1, icon ink-3 (#8E8E88 — muted on dark), text ink-1
      return _ToastPalette(
        bg: nearBlack,
        gradient: null,
        textColor: dark.ink1,
        icon: KaiIcon(KaiIconName.copy, size: 11, color: dark.ink3),
      );

    case KaiToastType.positive:
      // Canon: bg ink-1, icon positive (#3DBE7A dark-green), text ink-1
      return _ToastPalette(
        bg: nearBlack,
        gradient: null,
        textColor: dark.ink1,
        icon: KaiIcon(KaiIconName.check, size: 11, color: dark.positive),
      );

    case KaiToastType.negative:
      // Canon: bg ink-1, icon negative (#E66F60 coral), text ink-1.
      // Note: negative variant is sticky — controller keeps it visible until
      // user taps the action. The widget itself is ignorant of this; it just
      // renders. Sticky behaviour lives in KaiToastController.
      return _ToastPalette(
        bg: nearBlack,
        gradient: null,
        textColor: dark.ink1,
        icon: KaiIcon(KaiIconName.info, size: 11, color: dark.negative),
      );

    case KaiToastType.memory:
      // T1 FIX: background MUST be KaiTide.gradient — the locked token const.
      // Canon: bg tide-gradient, marker = 10×2.5 white pill, text white.
      // textColor is white — sits on the tide gradient.
      return const _ToastPalette(
        bg: null,
        gradient: KaiTide.gradient, // <-- token, never a hex literal
        textColor: Color(0xFFFFFFFF),
        icon: _TideMarker(),
      );
  }
}

// ─── Tide pill marker (memory variant) ───────────────────────────────────────

// ─── Toast action button (canon-exact) ───────────────────────────────────────

/// Pixel-exact action button for the toast pill.
///
/// Canon: `components.html .toast .open` — 12px / w600 / tide-2 (#2BA8C9 = KaiTide.stop2).
/// Padding: 4px all sides.
/// [KaiButton.text] sm = 12.5px/w500 diverges by 0.5px and one weight step;
/// this widget reproduces the HTML spec exactly.
/// Color is tide-2 (sea-glass, KaiTide.stop2), NOT the dark-palette accent.
/// — verified spec-viewer 2026-05-29.
class _ToastActionButton extends StatelessWidget {
  const _ToastActionButton({required this.label, required this.onTap});

  final String label;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    // Canon: components.html .toast .open { color: rgb(43,168,201) }
    // That is tide-2 (sea-glass) = KaiTide.stop2 = 0xFF2BA8C9.
    // NOT the dark-palette accent (#5C8EFF) — verified spec-viewer 2026-05-29.
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: onTap,
      child: Padding(
        // canon: .open { padding: 4px } — verified spec-viewer 2026-05-29
        padding: const EdgeInsets.all(4),
        child: Text(
          label,
          style: const TextStyle(
            fontFamily: 'Manrope',
            // canon: .open { font-size: 12px; font-weight: 600 }
            // — verified spec-viewer 2026-05-29
            fontSize: 12, // canon: 12px
            fontWeight: FontWeight.w600, // canon: w600
            color: KaiTide.stop2, // tide-2 sea-glass #2BA8C9
          ),
        ),
      ),
    );
  }
}

/// Inline pill glyph for the memory variant.
///
/// Canon: `.t-tide-bar { width: 10px; height: 2.5px; border-radius: 999px;
/// background: rgba(255,255,255,0.75) }`.
///
/// We intentionally use a plain white-ish pill here rather than [KaiGradientBar]
/// because the toast background is already the tide gradient — a gradient-on-
/// gradient glyph would be invisible. The white pill reads as a "memory saved"
/// marker against the gradient bg.
class _TideMarker extends StatelessWidget {
  const _TideMarker();

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 10,
      height: 2.5,
      decoration: const BoxDecoration(
        color: Color.fromRGBO(255, 255, 255, 0.75),
        borderRadius: KaiRadius.brPill,
      ),
    );
  }
}
