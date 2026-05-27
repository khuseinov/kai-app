import 'dart:async';

import 'package:flutter/material.dart';

import '../atoms/kai_icon.dart';
import '../tokens/kai_tokens.dart';

/// Visual variant of a toast pill. Source: `new-design/components.html § 03.12`.
///
/// All variants share the same pill shape; only background + icon + countdown
/// behaviour differ:
/// - [neutral] / [positive] / [negative] use the dark `ink-1` pill with a
///   semantic icon tint
/// - [memory] is the only branded variant — tide-gradient bg + countdown bar
enum KaiToastType { neutral, positive, negative, memory }

/// Toast / Snackbar pill — brief system feedback.
///
/// Canon: `new-design/components.html § 03.12`.
///
/// Pill 999 radius, padding `7px 14px 7px 9px`, font 500 11 Manrope
/// letter-spacing `-0.005em`, shadow `0 2px 12px rgba(0,0,0,0.16)`. Entrance
/// animation 220ms `cubic-bezier(.2, 0, 0, 1)` translateY(8)→0 + opacity 0→1.
///
/// Auto-dismiss 3s for neutral/positive/memory; [negative] is sticky until
/// the user taps the action button (or swipe-down — not implemented yet).
///
/// Use [KaiToast.show] to display as an overlay above compose island.
class KaiToast extends StatefulWidget {
  const KaiToast({
    required this.type,
    required this.label,
    this.actionLabel,
    this.onAction,
    this.duration = const Duration(seconds: 3),
    this.onDismissRequested,
    super.key,
  });

  final KaiToastType type;
  final String label;

  /// Optional action label (e.g. "Повторить") — only renders for [negative]
  /// variant. Canon: negative pill sticks until user acts.
  final String? actionLabel;

  /// Tap handler for the action button.
  final VoidCallback? onAction;

  /// Auto-dismiss delay for non-negative variants. Negative variant ignores
  /// this and stays until [onAction] fires.
  final Duration duration;

  /// Fires when the toast wants to dismiss itself (used by [show] to remove
  /// the overlay entry).
  final VoidCallback? onDismissRequested;

  @override
  State<KaiToast> createState() => _KaiToastState();

  // ─── Overlay helper ────────────────────────────────────────────────────────

  /// Show a toast as an overlay above compose island.
  ///
  /// Replaces any currently-showing toast immediately (canon: "Only one
  /// toast at a time. New replaces old"). Returns a dismiss callback for
  /// manual closure (e.g. on navigation).
  ///
  /// [bottomOffset] is the gap from the bottom safe-area edge — canon 58px
  /// to sit just above the compose island in `room.html`.
  static VoidCallback show(
    BuildContext context, {
    required KaiToastType type,
    required String label,
    String? actionLabel,
    VoidCallback? onAction,
    Duration duration = const Duration(seconds: 3),
    double bottomOffset = 58,
  }) {
    return _KaiToastOverlay.show(
      context,
      type: type,
      label: label,
      actionLabel: actionLabel,
      onAction: onAction,
      duration: duration,
      bottomOffset: bottomOffset,
    );
  }
}

class _KaiToastState extends State<KaiToast>
    with TickerProviderStateMixin {
  late final AnimationController _entrance;
  late final AnimationController _countdown;
  late final Animation<double> _slide;
  late final Animation<double> _fade;

  Timer? _dismissTimer;

  @override
  void initState() {
    super.initState();

    // Entrance: 0.22s cubic-bezier(.2,0,0,1)
    _entrance = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 220),
    );
    const curve = Cubic(0.2, 0, 0, 1);
    _slide = Tween<double>(begin: 8, end: 0).animate(
      CurvedAnimation(parent: _entrance, curve: curve),
    );
    _fade = Tween<double>(begin: 0, end: 1).animate(
      CurvedAnimation(parent: _entrance, curve: curve),
    );

    // Countdown bar (memory variant only) — 3s linear width 100→0.
    _countdown = AnimationController(
      vsync: this,
      duration: widget.duration,
    );

    _entrance.forward();

    if (widget.type == KaiToastType.memory) {
      _countdown.forward();
    }

    // Negative is sticky; everyone else auto-dismisses.
    if (widget.type != KaiToastType.negative) {
      _dismissTimer = Timer(widget.duration, () {
        widget.onDismissRequested?.call();
      });
    }
  }

  @override
  void dispose() {
    _dismissTimer?.cancel();
    _entrance.dispose();
    _countdown.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final palette = _palette(widget.type);

    return AnimatedBuilder(
      animation: _entrance,
      builder: (context, child) {
        return Opacity(
          opacity: _fade.value,
          child: Transform.translate(
            offset: Offset(0, _slide.value),
            child: child,
          ),
        );
      },
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          _ToastPill(
            palette: palette,
            label: widget.label,
            actionLabel: widget.actionLabel,
            onAction: () {
              widget.onAction?.call();
              widget.onDismissRequested?.call();
            },
          ),
          if (widget.type == KaiToastType.memory) ...[
            const SizedBox(height: 5),
            _CountdownBar(controller: _countdown),
          ],
        ],
      ),
    );
  }
}

// ─── Pill (visual) ───────────────────────────────────────────────────────────

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
  final VoidCallback onAction;

  @override
  Widget build(BuildContext context) {
    return Container(
      // Canon: padding 7px 14px 7px 9px → LTRB(9, 7, 14, 7).
      // Action button (when present) reduces right padding via inner spacing.
      padding: const EdgeInsets.fromLTRB(9, 7, 14, 7),
      decoration: BoxDecoration(
        // gradient OR solid via palette
        gradient: palette.gradient,
        color: palette.bg,
        borderRadius: BorderRadius.circular(999),
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
          // Icon / marker (11×11 area)
          SizedBox(
            width: 11,
            height: 11,
            child: Center(child: palette.icon),
          ),
          const SizedBox(width: 6),
          // Label — Manrope 500 11, letter-spacing -0.005em = -0.055px
          Flexible(
            child: Text(
              label,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                fontFamily: 'Manrope',
                fontSize: 11,
                fontWeight: FontWeight.w500,
                letterSpacing: -0.005 * 11,
                color: palette.textColor,
              ),
            ),
          ),
          if (actionLabel != null) ...[
            const SizedBox(width: 10),
            _ActionButton(
              label: actionLabel!,
              color: palette.textColor,
              onTap: onAction,
            ),
          ],
        ],
      ),
    );
  }
}

// ─── Action button (negative variant) ────────────────────────────────────────

class _ActionButton extends StatelessWidget {
  const _ActionButton({
    required this.label,
    required this.color,
    required this.onTap,
  });

  final String label;
  final Color color;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: Text(
        label,
        style: TextStyle(
          fontFamily: 'Manrope',
          fontSize: 11,
          fontWeight: FontWeight.w600,
          letterSpacing: -0.005 * 11,
          color: color,
          decoration: TextDecoration.underline,
          decorationColor: color.withValues(alpha: 0.6),
        ),
      ),
    );
  }
}

// ─── Countdown bar (memory variant) ──────────────────────────────────────────

class _CountdownBar extends StatelessWidget {
  const _CountdownBar({required this.controller});

  final AnimationController controller;

  @override
  Widget build(BuildContext context) {
    // Canon: 110px × 2px, base rgba(255,255,255,0.2), bar rgba(255,255,255,0.6).
    return SizedBox(
      width: 110,
      height: 2,
      child: ClipRRect(
        borderRadius: BorderRadius.circular(999),
        child: Stack(
          children: [
            const Positioned.fill(
              child: ColoredBox(
                color: Color.fromRGBO(255, 255, 255, 0.2),
              ),
            ),
            AnimatedBuilder(
              animation: controller,
              builder: (context, _) {
                return FractionallySizedBox(
                  alignment: Alignment.centerLeft,
                  widthFactor: 1 - controller.value,
                  child: const ColoredBox(
                    color: Color.fromRGBO(255, 255, 255, 0.6),
                  ),
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}

// ─── Palette model ───────────────────────────────────────────────────────────

class _ToastPalette {
  const _ToastPalette({
    required this.bg,
    required this.gradient,
    required this.textColor,
    required this.icon,
  });

  /// Solid background. Null when [gradient] is set (memory variant).
  final Color? bg;

  /// Tide gradient — only for [KaiToastType.memory].
  final LinearGradient? gradient;

  final Color textColor;
  final Widget icon;
}

/// Build palette for a toast variant.
///
/// Dark colours (ink-1 bg, ink-3 text) are intentional even in light theme —
/// toast is the "dark island" pattern from canon. We pull from
/// [KaiTokens.dark] for consistency rather than hard-coding HEX values.
_ToastPalette _palette(KaiToastType type) {
  // Always-dark surface — toast is a dark-island element regardless of theme.
  final dark = KaiTokens.dark.colors;

  switch (type) {
    case KaiToastType.neutral:
      // Canon: bg ink-1, icon ink-3 #8E8E88, text #F5F5F2 (= dark ink-1)
      return _ToastPalette(
        bg: dark.ink1,
        gradient: null,
        textColor: dark.ink1,
        // copy icon — canon § 03.12 .t-neutral inline SVG (clipboard outline)
        icon: KaiIcon(KaiIconName.copy, size: 11, color: dark.ink3),
      );
    case KaiToastType.positive:
      // Canon: bg ink-1, icon positive #3DBE7A (dark positive), text ink-1
      return _ToastPalette(
        bg: dark.ink1,
        gradient: null,
        textColor: dark.ink1,
        icon: KaiIcon(KaiIconName.check, size: 11, color: dark.positive),
      );
    case KaiToastType.negative:
      // Canon: bg ink-1, icon negative #E66F60 (dark negative), text ink-1.
      // Sticky — won't auto-dismiss until user taps action.
      return _ToastPalette(
        bg: dark.ink1,
        gradient: null,
        textColor: dark.ink1,
        // Canon HTML: info-style circle with "i" (not triangle-alert).
        icon: KaiIcon(KaiIconName.info, size: 11, color: dark.negative),
      );
    case KaiToastType.memory:
      // Canon: bg tide-gradient, marker = 10×2.5 white pill (not an icon).
      return const _ToastPalette(
        bg: null,
        gradient: LinearGradient(
          // Tide canon: 115deg, stops 0/52/100.
          // CSS 115° → Alignment: (-cos(25°), -sin(25°)) → (cos(25°), sin(25°))
          // ≈ (-0.906, -0.423) → (0.906, 0.423).
          begin: Alignment(-0.906, -0.423),
          end: Alignment(0.906, 0.423),
          stops: [0.0, 0.52, 1.0],
          colors: [
            Color(0xFF1B4FB0),
            Color(0xFF2BA8C9),
            Color(0xFFF4B589),
          ],
        ),
        textColor: Color(0xFFFFFFFF),
        icon: _TideMarker(),
      );
  }
}

/// Inline pill marker for the memory variant — 10×2.5 white pill.
/// Canon: `.t-tide-bar { width: 10px; height: 2.5px; border-radius: 999px;
/// background: rgba(255,255,255,0.75) }`.
class _TideMarker extends StatelessWidget {
  const _TideMarker();

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 10,
      height: 2.5,
      decoration: BoxDecoration(
        color: const Color.fromRGBO(255, 255, 255, 0.75),
        borderRadius: BorderRadius.circular(999),
      ),
    );
  }
}

// ─── Overlay controller ─────────────────────────────────────────────────────

/// Internal overlay manager — keeps a single active toast, auto-dismiss, etc.
class _KaiToastOverlay {
  static OverlayEntry? _current;
  static VoidCallback? _currentDismiss;

  static VoidCallback show(
    BuildContext context, {
    required KaiToastType type,
    required String label,
    String? actionLabel,
    VoidCallback? onAction,
    Duration duration = const Duration(seconds: 3),
    double bottomOffset = 58,
  }) {
    // Canon: one toast at a time. New replaces old.
    _currentDismiss?.call();

    final overlay = Overlay.of(context, rootOverlay: true);
    late OverlayEntry entry;

    void dismiss() {
      if (_current == entry) {
        _current = null;
        _currentDismiss = null;
      }
      if (entry.mounted) {
        entry.remove();
      }
    }

    entry = OverlayEntry(
      builder: (overlayContext) {
        final padding = MediaQuery.of(overlayContext).padding;
        return Positioned(
          left: 0,
          right: 0,
          bottom: bottomOffset + padding.bottom,
          child: SafeArea(
            top: false,
            bottom: false,
            child: Center(
              child: KaiToast(
                type: type,
                label: label,
                actionLabel: actionLabel,
                onAction: onAction,
                duration: duration,
                onDismissRequested: dismiss,
              ),
            ),
          ),
        );
      },
    );

    _current = entry;
    _currentDismiss = dismiss;
    overlay.insert(entry);
    return dismiss;
  }
}
