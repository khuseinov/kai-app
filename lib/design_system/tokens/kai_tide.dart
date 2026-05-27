import 'package:flutter/painting.dart';

/// Animation type for a tide state.
enum KaiTideAnimation {
  /// No animation (idle/sleep use HTML-defined breathe — see [KaiTideState.breathe]).
  none,

  /// Soft breathing pulse — HTML-derived for idle/sleep (JSON has null,
  /// HTML wins per lessons learned).
  breathe,

  /// Up-down bob — listening.
  bob,

  /// Right-to-left dashed flow — thinking.
  flow,

  /// Right-to-left streaming — responding.
  stream,

  /// Brief gradient flash — success.
  flash,

  /// Side-to-side wobble — error.
  wobble,

  /// Quick scale pop — memory.
  pop,
}

/// One tide state configuration. Theme-independent.
class KaiTideState {
  const KaiTideState({
    required this.name,
    required this.strokePx,
    required this.opacity,
    required this.animation,
    this.durationMs,
    this.dashPattern,
    this.ephemeral = false,
    this.useGradient = false,
    // For breathe states only.
    this.breatheStrokeFrom,
    this.breatheStrokeTo,
    this.breatheOpacityFrom,
    this.breatheOpacityTo,
  });

  final String name;
  final double strokePx;
  final double opacity;
  final KaiTideAnimation animation;
  final int? durationMs;

  /// Dash pattern as a list of [on, off] lengths. Null = solid.
  final List<double>? dashPattern;

  /// True if the state should auto-dismiss after [durationMs].
  final bool ephemeral;

  /// If true, the curve renders with the tide gradient even for animation
  /// types that default to solid (none / breathe). Used by [KaiTide.muted]
  /// to paint a static gradient curve at low opacity, e.g. onboarding
  /// header overlays on passive steps.
  final bool useGradient;

  // Breathe-specific fields (HTML-derived, for idle/sleep).
  final double? breatheStrokeFrom;
  final double? breatheStrokeTo;
  final double? breatheOpacityFrom;
  final double? breatheOpacityTo;
}

/// Tide gradient + 8 state configs.
///
/// Source: `new-design/design-tokens.json § color.tide` + `§ tide-states`.
/// HTML wins for idle/sleep breathe animations per lessons learned.
class KaiTide {
  const KaiTide._();

  // Three gradient stops — deep ocean → sea-glass → warm horizon.
  static const Color stop1 = Color(0xFF1B4FB0);
  static const Color stop2 = Color(0xFF2BA8C9);
  static const Color stop3 = Color(0xFFF4B589);

  /// 115° gradient. CSS `linear-gradient(115deg, ...)` maps to Flutter's
  /// `Alignment` space as follows:
  ///
  /// CSS 0deg → bottom-to-top; rotation is clockwise.
  /// CSS 115deg → start vector points 115° clockwise from "north" (top),
  /// which is the upper-left quadrant pointing down-right at 25° past east.
  ///
  /// In Alignment-space (x: -1..1 left→right, y: -1..1 top→bottom):
  ///   theta_alignment = (115 - 90) * pi/180 ≈ 0.4363 rad
  ///   begin = Alignment(-cos(theta), -sin(theta)) ≈ (-0.906, -0.423)
  ///   end   = Alignment( cos(theta),  sin(theta)) ≈ ( 0.906,  0.423)
  static const LinearGradient gradient = LinearGradient(
    colors: [stop1, stop2, stop3],
    stops: [0.0, 0.52, 1.0],
    begin: Alignment(-0.906, -0.423),
    end: Alignment(0.906, 0.423),
  );

  // 8 states. JSON null animations for idle/sleep overridden by HTML breathe.
  static const KaiTideState idle = KaiTideState(
    name: 'idle',
    strokePx: 1.5,
    opacity: 0.4,
    animation: KaiTideAnimation.breathe,
    durationMs: 5500,
    breatheStrokeFrom: 1.3,
    breatheStrokeTo: 1.7,
    breatheOpacityFrom: 0.32,
    breatheOpacityTo: 0.46,
  );

  static const KaiTideState listening = KaiTideState(
    name: 'listening',
    strokePx: 2.0,
    opacity: 0.8,
    animation: KaiTideAnimation.bob,
    durationMs: 2200,
  );

  static const KaiTideState thinking = KaiTideState(
    name: 'thinking',
    strokePx: 2.0,
    opacity: 0.85,
    animation: KaiTideAnimation.flow,
    durationMs: 3000,
    dashPattern: [6, 4],
  );

  static const KaiTideState responding = KaiTideState(
    name: 'responding',
    strokePx: 2.5,
    opacity: 1.0,
    animation: KaiTideAnimation.stream,
    durationMs: 1400,
    dashPattern: [12, 4],
  );

  static const KaiTideState success = KaiTideState(
    name: 'success',
    strokePx: 2.5,
    opacity: 1.0,
    animation: KaiTideAnimation.flash,
    durationMs: 1200,
    ephemeral: true,
  );

  static const KaiTideState error = KaiTideState(
    name: 'error',
    strokePx: 2.0,
    opacity: 0.95,
    animation: KaiTideAnimation.wobble,
    // Canon: design-tokens.json § tide-states.error.animation-duration-ms = 600.
    // The HTML-wins exception applies ONLY to idle/sleep breathe; all other
    // states track the JSON.
    durationMs: 600,
    ephemeral: true,
  );

  static const KaiTideState memory = KaiTideState(
    name: 'memory',
    strokePx: 2.0,
    opacity: 1.0,
    animation: KaiTideAnimation.pop,
    durationMs: 900,
    ephemeral: true,
  );

  static const KaiTideState sleep = KaiTideState(
    name: 'sleep',
    strokePx: 1.0,
    opacity: 0.2,
    animation: KaiTideAnimation.breathe,
    durationMs: 7000,
    breatheStrokeFrom: 0.9,
    breatheStrokeTo: 1.1,
    breatheOpacityFrom: 0.18,
    breatheOpacityTo: 0.24,
  );

  /// Static gradient curve at low opacity.
  ///
  /// Used by the onboarding header overlay on passive steps (gestures /
  /// context) where the tide should be visible as a brand anchor but not
  /// communicate any active state. Matches `new-design/onboarding.html`
  /// steps 03–04: `stroke="url(#g-tide)" stroke-width="1.8" opacity="0.4"`.
  static const KaiTideState muted = KaiTideState(
    name: 'muted',
    strokePx: 1.8,
    opacity: 0.4,
    animation: KaiTideAnimation.none,
    useGradient: true,
  );

  /// All 8 canonical states, ordered.
  static const List<KaiTideState> all = [
    idle,
    listening,
    thinking,
    responding,
    success,
    error,
    memory,
    sleep,
  ];
}
