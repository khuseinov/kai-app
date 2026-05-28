import 'package:flutter/material.dart';

import '../../tokens/kai_tokens.dart';
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
  });

  final KaiToastType type;

  /// Main message text. Manrope 500 11, letter-spacing -0.005em.
  final String label;

  /// Optional action label — renders as a `KaiButton.text` on the right.
  /// Readable on the dark pill (white/translucent text).
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

  @override
  Widget build(BuildContext context) {
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
            KaiButton.text(
              label: actionLabel!,
              onPressed: onAction,
              // tone: neutral gives ink-1 text which is white on dark pill
              tone: KaiButtonTone.neutral,
            ),
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

  switch (type) {
    case KaiToastType.neutral:
      // Canon: bg ink-1, icon ink-3 (#8E8E88 — muted on dark), text ink-1
      return _ToastPalette(
        bg: dark.ink1,
        gradient: null,
        textColor: dark.ink1,
        icon: KaiIcon(KaiIconName.copy, size: 11, color: dark.ink3),
      );

    case KaiToastType.positive:
      // Canon: bg ink-1, icon positive (#3DBE7A dark-green), text ink-1
      return _ToastPalette(
        bg: dark.ink1,
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
        bg: dark.ink1,
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
