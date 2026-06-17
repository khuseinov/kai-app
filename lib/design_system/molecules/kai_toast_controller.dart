import 'dart:async';

import 'package:flutter/material.dart';

import 'package:kai_app/design_system/molecules/kai_toast.dart';

/// Overlay + timer presenter for [KaiToast].
///
/// ## Responsibility split (R3 audit fix)
/// - [KaiToast] (dumb widget): pure presentational — no Timer, no Overlay.
/// - [KaiToastController] (this class): owns the OverlayEntry, the dismiss
///   Timer, and the entrance animation. The widget only renders what it's told.
///
/// ## Design
/// Static state + class-level methods. There is at most one active toast at a
/// time across the entire app (canon: "Only one toast at a time. New replaces
/// old."). Static state is a pragmatic fit here — the overlay state is truly
/// global (there's one root Overlay). An instance-based alternative would
/// require injecting the controller into the widget tree, which is heavier than
/// warranted for a transient UI element.
///
/// If you need scoped toasts (e.g. per-sheet), create a separate instance and
/// call [showEntry] / [dismissEntry] manually.
///
/// ## Auto-dismiss
/// The timer fires after [duration] and removes the overlay entry. Set
/// `duration: Duration.zero` for a **persistent** toast (useful for negative
/// variant — canon says it stays until the user acts). The controller does
/// not enforce negative-is-sticky — callers control duration.
///
/// ## Entrance animation
/// A 220ms slide-up (translateY 8→0) + fade (0→1) driven by an
/// [AnimationController] owned by the [_AnimatedToastEntry] wrapper widget.
/// The wrapper is disposed cleanly when the overlay entry is removed.
///
/// ## Canon offset
/// [bottomOffset] defaults to 58px — positions the toast just above the
/// compose island per `room.html` canon.
class KaiToastController {
  // Static-only class.
  KaiToastController._();

  static OverlayEntry? _entry;
  static Timer? _timer;

  // ─── Public API ────────────────────────────────────────────────────────────

  /// Show a [KaiToast] as an overlay above the compose island.
  ///
  /// Replaces any currently-showing toast (canon: one at a time).
  ///
  /// Returns a dismiss callback for programmatic removal (e.g. on navigation).
  ///
  /// Set [duration] to [Duration.zero] for a persistent toast.
  static VoidCallback show(
    BuildContext context, {
    required KaiToastType type,
    required String label,
    String? actionLabel,
    VoidCallback? onAction,
    Duration duration = const Duration(seconds: 3),
    double bottomOffset = 58,
  }) {
    // Replace any existing toast immediately.
    _cancelAndRemove();

    final overlay = Overlay.of(context, rootOverlay: true);

    void dismissCallback() => dismiss();

    // onAction wrapper: fire the caller's callback and dismiss.
    final wrappedAction = onAction != null
        ? () {
            onAction();
            dismiss();
          }
        : null;

    _entry = OverlayEntry(
      builder: (overlayCtx) {
        final padding = MediaQuery.of(overlayCtx).padding;
        return Positioned(
          left: 0,
          right: 0,
          bottom: bottomOffset + padding.bottom,
          child: SafeArea(
            top: false,
            bottom: false,
            child: Center(
              child: _AnimatedToastEntry(
                child: KaiToast(
                  type: type,
                  label: label,
                  actionLabel: actionLabel,
                  onAction: wrappedAction,
                ),
              ),
            ),
          ),
        );
      },
    );

    overlay.insert(_entry!);

    // Schedule auto-dismiss only when duration is positive.
    if (duration > Duration.zero) {
      _timer = Timer(duration, dismiss);
    }

    return dismissCallback;
  }

  /// Remove the active toast immediately (if any). Safe to call when no toast
  /// is showing.
  static void dismiss() => _cancelAndRemove();

  // ─── Internal ──────────────────────────────────────────────────────────────

  static void _cancelAndRemove() {
    _timer?.cancel();
    _timer = null;

    if (_entry != null) {
      if (_entry!.mounted) {
        _entry!.remove();
      }
      _entry = null;
    }
  }
}

// ─── Entrance animation wrapper ───────────────────────────────────────────────

/// Slide-up + fade entrance for the toast.
///
/// Canon: 220ms `cubic-bezier(.2, 0, 0, 1)` translateY(8→0) + opacity (0→1).
/// This wrapper is owned by the overlay entry; it disposes its controllers when
/// the entry is removed from the tree.
class _AnimatedToastEntry extends StatefulWidget {
  const _AnimatedToastEntry({required this.child});

  final Widget child;

  @override
  State<_AnimatedToastEntry> createState() => _AnimatedToastEntryState();
}

class _AnimatedToastEntryState extends State<_AnimatedToastEntry>
    with SingleTickerProviderStateMixin {
  late final AnimationController _ctrl;
  late final Animation<double> _slide;
  late final Animation<double> _fade;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 220),
    );
    const curve = Cubic(0.2, 0, 0, 1);
    _slide = Tween<double>(begin: 8, end: 0).animate(
      CurvedAnimation(parent: _ctrl, curve: curve),
    );
    _fade = Tween<double>(begin: 0, end: 1).animate(
      CurvedAnimation(parent: _ctrl, curve: curve),
    );
    _ctrl.forward();
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _ctrl,
      builder: (ctx, child) => Opacity(
        opacity: _fade.value,
        child: Transform.translate(
          offset: Offset(0, _slide.value),
          child: child,
        ),
      ),
      child: widget.child,
    );
  }
}
