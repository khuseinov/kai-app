import 'package:flutter/material.dart';

import '../../design_system/theme/kai_theme.dart';
import '../../design_system/tokens/kai_tokens.dart';

/// First-run / cold-start splash surface.
///
/// Canon: `new-design/brand.html § 02.2`.
///
/// Layout (centered column, gap 16):
/// 1. Glyph 64×64 — `KaiTide.gradientCorner` 135° fill, radius 20, with a small
///    tide curve drawn inside (canon path `M 2 11 Q 9 3, 18 11 T 34 7` in a
///    36×18 viewBox, white 2.5 stroke).
/// 2. Wordmark "kai" — Manrope 700/26, letter-spacing -0.025em, ink-1.
/// 3. Tag — Manrope 400/12.5, ink-3.
///
/// Glyph pulses scale `1 → 1.06 → 1` over 2.4s, ease-in-out, infinite — canon
/// `@keyframes glyph-pulse`.
///
/// Caller controls when to remove the splash (via [onExitRequested] or by
/// dismissing the widget tree). This widget does not auto-dismiss — the
/// bootstrap layer decides when the app is "ready".
class SplashScreen extends StatefulWidget {
  const SplashScreen({
    this.tag = 'ваш компаньон путешественника',
    this.onExitRequested,
    super.key,
  });

  /// Sub-wordmark tag line. Default is the RU canon copy. Caller may swap
  /// for the EN canon ("your travel companion") via l10n when ready.
  final String tag;

  /// Optional callback when the splash decides it's safe to fade out. Not
  /// fired by default — bootstrap layer is expected to remove the widget
  /// when it has finished hydration.
  final VoidCallback? onExitRequested;

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with SingleTickerProviderStateMixin {
  late final AnimationController _pulse;
  late final Animation<double> _scale;

  @override
  void initState() {
    super.initState();
    _pulse = AnimationController(
      vsync: this,
      // Canon: glyph-pulse 2.4s ease-in-out.
      // A full cycle (1.0 -> 1.06 -> 1.0) takes 2.4s.
      // So forward (1200ms) + reverse (1200ms) = 2400ms.
      duration: const Duration(milliseconds: 1200),
    );

    _scale = Tween<double>(begin: 1.0, end: 1.06).animate(
      CurvedAnimation(parent: _pulse, curve: Curves.easeInOut),
    );

    // Pulse exactly once on boot
    _pulse.forward().then((_) {
      if (mounted) {
        _pulse.reverse();
      }
    });
  }

  @override
  void dispose() {
    _pulse.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final c = KaiTheme.of(context).colors;
    return ColoredBox(
      color: c.bg,
      child: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ScaleTransition(scale: _scale, child: const _SplashGlyph()),
            const SizedBox(height: 16),
            Text(
              'kai',
              style: TextStyle(
                fontFamily: 'Manrope',
                fontSize: 26,
                fontWeight: FontWeight.w700,
                letterSpacing: -0.025 * 26,
                color: c.ink1,
              ),
            ),
            const SizedBox(height: 16),
            Text(
              widget.tag,
              style: TextStyle(
                fontFamily: 'Manrope',
                fontSize: 12.5,
                fontWeight: FontWeight.w400,
                color: c.ink3,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// 64×64 tide-gradient square with the canonical curve inside.
class _SplashGlyph extends StatelessWidget {
  const _SplashGlyph();

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 64,
      height: 64,
      decoration: BoxDecoration(
        // Canon: linear-gradient(135deg, ...) — square corner gradient.
        gradient: KaiTide.gradientCorner,
        borderRadius: BorderRadius.circular(20),
      ),
      child: const Center(
        // SVG is 36×18 inside the 64 glyph, centered.
        child: SizedBox(
          width: 36,
          height: 18,
          child: CustomPaint(painter: _GlyphCurvePainter()),
        ),
      ),
    );
  }
}

/// Renders the canon brand curve inside a 36×18 viewport.
///
/// Path canon: `M 2 11 Q 9 3, 18 11 T 34 7`. Used in the splash glyph and
/// — at a smaller scale — in the brand wordmark/glyph at the top-left of
/// design references (`<svg width="28" height="6">…`).
class _GlyphCurvePainter extends CustomPainter {
  const _GlyphCurvePainter();

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = const Color(0xFFFFFFFF)
      ..style = PaintingStyle.stroke
      // Canon: stroke-width 2.5
      ..strokeWidth = 2.5
      ..strokeCap = StrokeCap.round;

    // SVG path "M 2 11 Q 9 3, 18 11 T 34 7" decoded:
    //   M 2,11           — move to (2, 11)
    //   Q 9,3 18,11      — quadratic Bezier, control (9, 3), end (18, 11)
    //   T 34,7           — smooth quadratic: control auto-reflected from prev,
    //                       reflected control = 2 * (18, 11) - (9, 3) = (27, 19)
    //                       end (34, 7)
    final path = Path()
      ..moveTo(2, 11)
      ..quadraticBezierTo(9, 3, 18, 11)
      ..quadraticBezierTo(27, 19, 34, 7);

    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(_GlyphCurvePainter oldDelegate) => false;
}
