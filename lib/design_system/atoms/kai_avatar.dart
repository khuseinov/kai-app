import 'package:flutter/material.dart';

import 'package:kai_app/design_system/primitives/primitives.dart';
import 'package:kai_app/design_system/tokens/kai_tokens.dart';

/// Canonical diameter values for [KaiAvatar] named constructors.
///
/// - [sm] = 28px — compact contexts (inline mentions, tight lists).
/// - [md] = 40px — default (list rows, nav account hero).
/// - [lg] = 56px — hero / profile contexts.
enum KaiAvatarSize {
  /// 28px circle diameter.
  sm,

  /// 40px circle diameter (default).
  md,

  /// 56px circle diameter.
  lg,
}

/// v3 avatar atom.
///
/// Three constructors:
///
/// - [KaiAvatar()] — original default constructor kept for call-site
///   compatibility (takes `size` in pixels and optional `initial`).
/// - [KaiAvatar.user] — initial letter on [KaiTide.gradientCorner] circle.
///   Accepts [KaiAvatarSize] and optional [breathing].
/// - [KaiAvatar.kai] — Kai mark: gradient circle with the tide bar glyph.
///   No initial text. Accepts [KaiAvatarSize] and optional [breathing].
///
/// ### breathing
/// When `breathing: true`, a subtle scale 0.97↔1.03 loop runs via
/// [KaiMotion.ambient]. Respects `MediaQuery.maybeOf(context)?.disableAnimations`.
/// The animation controller is disposed properly. Non-breathing path is cheap.
class KaiAvatar extends StatelessWidget {
  // ---------------------------------------------------------------------------
  // Primary / legacy constructor
  // ---------------------------------------------------------------------------

  /// Legacy constructor — retained for call-site compatibility.
  ///
  /// [size] sets the diameter in logical pixels. Defaults to 40.
  /// [initial] is an optional single character shown at center in white.
  ///   If null or empty, no label is rendered.
  ///
  /// Prefer [KaiAvatar.user] or [KaiAvatar.kai] for new code.
  const KaiAvatar({
    this.size = _kDefaultSize,
    this.initial,
    super.key,
  })  : _avatarSize = null,
        _breathing = false,
        _isKai = false;

  // ---------------------------------------------------------------------------
  // Named: user
  // ---------------------------------------------------------------------------

  /// User avatar — initial letter on [KaiTide.gradientCorner] circle.
  ///
  /// [initial] is the character to display (uppercased automatically).
  /// [avatarSize] controls the diameter via [KaiAvatarSize]
  ///   (default [KaiAvatarSize.md] = 40px).
  /// [breathing] adds the ambient scale pulse when true (default false).
  const KaiAvatar.user(
    String this.initial, {
    KaiAvatarSize avatarSize = KaiAvatarSize.md,
    bool breathing = false,
    super.key,
  })  : size = null,
        _avatarSize = avatarSize,
        _breathing = breathing,
        _isKai = false;

  // ---------------------------------------------------------------------------
  // Named: kai
  // ---------------------------------------------------------------------------

  /// Kai avatar — tide-corner gradient circle with the KaiGradientBar mark.
  ///
  /// [avatarSize] controls the diameter via [KaiAvatarSize]
  ///   (default [KaiAvatarSize.md] = 40px).
  /// [breathing] adds the ambient scale pulse when true (default false).
  const KaiAvatar.kai({
    KaiAvatarSize avatarSize = KaiAvatarSize.md,
    bool breathing = false,
    super.key,
  })  : size = null,
        initial = null,
        _avatarSize = avatarSize,
        _breathing = breathing,
        _isKai = true;

  // ---------------------------------------------------------------------------
  // Fields
  // ---------------------------------------------------------------------------

  static const double _kDefaultSize = 40;

  /// Diameter override in logical pixels (legacy constructor only).
  ///
  /// When null, [_avatarSize] is used instead.
  final double? size;

  /// Optional uppercase initial to show inside the circle.
  ///
  /// Null or empty string renders no label. Unused by [KaiAvatar.kai].
  final String? initial;

  final KaiAvatarSize? _avatarSize;
  final bool _breathing;
  final bool _isKai;

  // ---------------------------------------------------------------------------
  // Helpers
  // ---------------------------------------------------------------------------

  double get _resolvedSize {
    if (size != null) return size!;
    switch (_avatarSize ?? KaiAvatarSize.md) {
      case KaiAvatarSize.sm:
        return 28;
      case KaiAvatarSize.md:
        return 40;
      case KaiAvatarSize.lg:
        return 56;
    }
  }

  // ---------------------------------------------------------------------------
  // Build
  // ---------------------------------------------------------------------------

  @override
  Widget build(BuildContext context) {
    final d = _resolvedSize;
    if (_breathing) {
      return _BreathingWrapper(size: d, isKai: _isKai, initial: initial);
    }
    return _circleWidget(size: d, isKai: _isKai, initial: initial);
  }
}

// ---------------------------------------------------------------------------
// Shared circle factory (top-level so the Stateful wrapper can reuse it)
// ---------------------------------------------------------------------------

Widget _circleWidget({
  required double size,
  required bool isKai,
  required String? initial,
}) {
  Widget? child;
  if (isKai) {
    // Kai mark: a proportional gradient bar centered in the circle.
    final barW = (size * 0.4).clamp(8.0, 24.0);
    final barH = (size * 0.1).clamp(2.0, 6.0);
    child = KaiGradientBar(width: barW, height: barH);
  } else {
    final hasInitial = initial != null && initial.isNotEmpty;
    if (hasInitial) {
      child = Text(
        initial.toUpperCase(),
        style: KaiType.small(
          color: const Color(0xFFFFFFFF), // sanctioned white-on-fill
        ),
      );
    }
  }

  return Container(
    constraints: BoxConstraints.tightFor(width: size, height: size),
    decoration: const BoxDecoration(
      gradient: KaiTide.gradientCorner,
      shape: BoxShape.circle,
    ),
    alignment: Alignment.center,
    child: child,
  );
}

// ---------------------------------------------------------------------------
// Breathing wrapper (Stateful — only created when breathing: true)
// ---------------------------------------------------------------------------

class _BreathingWrapper extends StatefulWidget {
  const _BreathingWrapper({
    required this.size,
    required this.isKai,
    required this.initial,
  });

  final double size;
  final bool isKai;
  final String? initial;

  @override
  State<_BreathingWrapper> createState() => _BreathingWrapperState();
}

class _BreathingWrapperState extends State<_BreathingWrapper>
    with SingleTickerProviderStateMixin {
  AnimationController? _controller;
  Animation<double>? _scale;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _syncAnimation();
  }

  void _syncAnimation() {
    final disabled =
        MediaQuery.maybeOf(context)?.disableAnimations ?? false;
    if (disabled) {
      _controller?.stop();
      return;
    }
    if (_controller != null) return; // already running
    _controller = AnimationController(
      vsync: this,
      duration: KaiMotion.ambient,
    )..repeat(reverse: true);
    _scale = Tween<double>(begin: 0.97, end: 1.03).animate(
      CurvedAnimation(
        parent: _controller!,
        curve: KaiMotion.ambientCurve,
      ),
    );
  }

  @override
  void dispose() {
    _controller?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final disabled =
        MediaQuery.maybeOf(context)?.disableAnimations ?? false;

    final circle = _circleWidget(
      size: widget.size,
      isKai: widget.isKai,
      initial: widget.initial,
    );

    if (disabled || _scale == null) {
      return circle;
    }

    return AnimatedBuilder(
      animation: _scale!,
      builder: (context, child) => Transform.scale(
        scale: _scale!.value,
        child: child,
      ),
      child: circle,
    );
  }
}
