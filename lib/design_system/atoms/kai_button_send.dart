import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

import '../theme/kai_theme.dart';
import '../tokens/kai_tokens.dart';

/// Lifecycle states for the send button.
enum KaiSendState {
  /// Ready to submit — tide gradient, soft shadow, white send icon.
  ready,

  /// Disabled (e.g. empty composer) — ink-4 fill, opacity 0.5.
  disabled,

  /// Submission in flight — tide gradient + pulse.
  sending,

  /// Streaming response active — tide gradient + pulse.
  streaming,
}

/// Specialised send button — 4-state lifecycle with optional pulse animation.
///
/// Tap callback only fires when [state] is [KaiSendState.ready]. The atom
/// internally gates the tap on state, so callers may pass `null` as an
/// additional defensive layer when their own state derivation says "disabled"
/// — see `ComposeIsland` for the double-gate pattern.
class KaiButtonSend extends StatefulWidget {
  const KaiButtonSend({
    required this.state,
    required this.onPressed,
    this.size = 44,
    this.iconSize = 16,
    super.key,
  });

  /// Current lifecycle state. Drives visuals + tap behaviour.
  final KaiSendState state;

  /// Fires only when [state] == [KaiSendState.ready]. Nullable so callers
  /// can explicitly opt out at the call site even before the atom's
  /// internal state gate runs.
  final VoidCallback? onPressed;

  /// Total tap-target size (square). Default 44 (HIG min).
  final double size;

  /// SVG icon size inside the circle. Default 16.
  ///
  /// Pill compose uses 12 (HTML canon: frame01/02 send icon ≈ 12–13 px inside
  /// a 30×30 circle).
  final double iconSize;

  @override
  State<KaiButtonSend> createState() => _KaiButtonSendState();
}

class _KaiButtonSendState extends State<KaiButtonSend>
    with SingleTickerProviderStateMixin {
  late final AnimationController _pulse;
  late final Animation<double> _pulseScale;

  @override
  void initState() {
    super.initState();
    _pulse = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 120),
    );
    _pulseScale = Tween<double>(begin: 0.95, end: 1.05).animate(
      CurvedAnimation(parent: _pulse, curve: Curves.easeInOut),
    );
    _syncAnimation();
  }

  @override
  void didUpdateWidget(covariant KaiButtonSend old) {
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
    // Canon: room.html `.send { background: var(--ink-4); color: var(--surface);
    // opacity: 0.5 }` — the disabled state uses surface for the icon and
    // dims via Opacity below, not via swapping the icon color.
    final iconColor = tokens.colors.surface;

    final core = AnimatedBuilder(
      animation: _pulseScale,
      builder: (_, child) {
        final scale = _pulse.isAnimating ? _pulseScale.value : 1.0;
        return Transform.scale(scale: scale, child: child);
      },
      child: Opacity(
        opacity: widget.state == KaiSendState.disabled ? 0.5 : 1.0,
        child: Container(
          width: widget.size,
          height: widget.size,
          decoration: decoration,
          alignment: Alignment.center,
          child: SvgPicture.asset(
            'assets/icons/send.svg',
            width: widget.iconSize,
            height: widget.iconSize,
            colorFilter: ColorFilter.mode(iconColor, BlendMode.srcIn),
          ),
        ),
      ),
    );

    final onPressed = widget.onPressed;
    return Semantics(
      button: true,
      enabled: widget.state == KaiSendState.ready && onPressed != null,
      label: 'send',
      child: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap:
            widget.state == KaiSendState.ready ? onPressed : null,
        child: core,
      ),
    );
  }

  BoxDecoration _decoration(KaiTokens tokens) {
    switch (widget.state) {
      case KaiSendState.ready:
      case KaiSendState.sending:
      case KaiSendState.streaming:
        return const BoxDecoration(
          gradient: KaiTide.gradient,
          shape: BoxShape.circle,
          boxShadow: [
            BoxShadow(
              color: Color(0x2E2BA8C9),
              blurRadius: 8,
              offset: Offset(0, 2),
            ),
          ],
        );
      case KaiSendState.disabled:
        return BoxDecoration(
          color: tokens.colors.ink4,
          shape: BoxShape.circle,
        );
    }
  }
}
