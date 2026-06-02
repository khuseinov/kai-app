import 'package:flutter/material.dart';

import '../../../design_system/theme/kai_theme.dart';
import '../../../design_system/tokens/kai_tokens.dart';
import '../../../design_system/primitives/primitives.dart';

// ---------------------------------------------------------------------------
// State enum — re-exported by the barrel so consumers get it for free.
// ---------------------------------------------------------------------------

/// Lifecycle states for [KaiSendButton].
enum KaiSendState {
  /// Ready to submit — tide gradient, soft shadow, white arrow.
  ready,

  /// Disabled (empty composer) — ink4 fill, opacity 0.5, not tappable.
  disabled,

  /// Submission in flight — tide gradient + scale-pulse animation.
  sending,

  /// Streaming response — tide gradient + scale-pulse animation.
  streaming,
}

// ---------------------------------------------------------------------------
// KaiSendButton
// ---------------------------------------------------------------------------

/// v3 circular send button — 4-state lifecycle with optional pulse animation.
///
/// Default [size] 30, [iconSize] 12 — matches the canonical compose-island
/// pill in `new-design/room.html` frame 01/02.
///
/// States:
/// - [KaiSendState.ready]     — tide gradient + [KaiShadow.button], tappable.
/// - [KaiSendState.disabled]  — ink4 fill, Opacity(0.5), NOT tappable.
/// - [KaiSendState.sending]   — tide gradient + scale-pulse, tappable.
/// - [KaiSendState.streaming] — tide gradient + scale-pulse, tappable.
///
/// White `Color(0xFFFFFFFF)` is the sanctioned literal for icon fill on
/// tide/ink surfaces — used here for the arrow icon in all states.
class KaiSendButton extends StatefulWidget {
  const KaiSendButton({
    required this.state,
    required this.onPressed,
    this.size = 30,
    this.iconSize = 12,
    super.key,
  });

  /// Current lifecycle state. Drives visuals + tap behaviour.
  final KaiSendState state;

  /// Callback fired when the button is tapped.
  ///
  /// For [KaiSendState.disabled] the tap is always suppressed regardless of
  /// this value. For all other states the caller's value is used.
  final VoidCallback? onPressed;

  /// Circle diameter in logical pixels. Default 30.
  final double size;

  /// Arrow icon size in logical pixels. Default 12.
  final double iconSize;

  @override
  State<KaiSendButton> createState() => _KaiSendButtonState();
}

// ---------------------------------------------------------------------------
// State
// ---------------------------------------------------------------------------

class _KaiSendButtonState extends State<KaiSendButton>
    with SingleTickerProviderStateMixin {
  late final AnimationController _pulse;
  late final Animation<double> _pulseScale;

  @override
  void initState() {
    super.initState();
    _pulse = AnimationController(
      vsync: this,
      duration: KaiMotion.micro,
    );
    _pulseScale = Tween<double>(begin: 0.95, end: 1.05).animate(
      CurvedAnimation(parent: _pulse, curve: KaiMotion.ambientCurve),
    );
    _syncAnimation();
  }

  @override
  void didUpdateWidget(covariant KaiSendButton old) {
    super.didUpdateWidget(old);
    if (old.state != widget.state) _syncAnimation();
  }

  void _syncAnimation() {
    final shouldPulse = widget.state == KaiSendState.sending ||
        widget.state == KaiSendState.streaming;
    if (shouldPulse && !_pulse.isAnimating) {
      _pulse.repeat(reverse: true);
    } else if (!shouldPulse && _pulse.isAnimating) {
      _pulse.stop();
      _pulse.value = 0;
    }
  }

  @override
  void dispose() {
    _pulse.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final tokens = KaiTheme.of(context);
    final decoration = _decoration(tokens);
    const white = Color(0xFFFFFFFF);

    final isDisabled = widget.state == KaiSendState.disabled;
    final tappable = !isDisabled && widget.onPressed != null;

    final iconName = widget.state == KaiSendState.streaming
        ? KaiIconName.stop
        : KaiIconName.arrowUp;

    final circle = Container(
      width: widget.size,
      height: widget.size,
      decoration: decoration,
      alignment: Alignment.center,
      child: KaiIcon(
        iconName,
        size: widget.iconSize,
        color: white,
      ),
    );

    final animated = AnimatedBuilder(
      animation: _pulseScale,
      builder: (_, child) {
        final scale = _pulse.isAnimating ? _pulseScale.value : 1.0;
        return Transform.scale(scale: scale, child: child);
      },
      child: Opacity(
        opacity: isDisabled ? 0.5 : 1.0,
        child: circle,
      ),
    );

    return Semantics(
      button: true,
      enabled: !isDisabled,
      label: 'send',
      child: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: tappable ? widget.onPressed : null,
        child: animated,
      ),
    );
  }

  // -------------------------------------------------------------------------
  // Helpers
  // -------------------------------------------------------------------------

  BoxDecoration _decoration(KaiTokens tokens) {
    switch (widget.state) {
      case KaiSendState.ready:
      case KaiSendState.sending:
      case KaiSendState.streaming:
        return const BoxDecoration(
          gradient: KaiTide.gradient,
          shape: BoxShape.circle,
          boxShadow: KaiShadow.button,
        );
      case KaiSendState.disabled:
        return BoxDecoration(
          color: tokens.colors.ink4,
          shape: BoxShape.circle,
        );
    }
  }
}
