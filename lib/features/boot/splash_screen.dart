import 'package:flutter/material.dart';

import '../../design_system/atoms/atoms.dart';
import '../../design_system/theme/kai_theme.dart';
import '../../design_system/tokens/kai_tokens.dart';

/// Canonical cold-start splash screen.
///
/// Reproduces `new-design/brand.html` § 02.2:
/// - 64×64 gradient glyph (r = 20) with a looping 3.0s ease-in-out-sine pulse;
/// - "kai" wordmark at 26px/700;
/// - tagline "ваш компаньон путешественника" at 12.5px/400;
/// - wordmark + tagline fade in over 600 ms once the glyph is visible;
/// - centered on the themed background (`colors.bg`).
///
/// Honors `MediaQuery.disableAnimations` — reduced-motion users see a static
/// splash.
class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => SplashScreenState();
}

class SplashScreenState extends State<SplashScreen>
    with TickerProviderStateMixin {
  late final AnimationController _pulseController;
  late final AnimationController _fadeController;
  late final Animation<double> _scale;
  late final Animation<double> _textOpacity;

  /// Exposed for widget tests.
  AnimationController get pulseController => _pulseController;

  /// Exposed for widget tests.
  AnimationController get fadeController => _fadeController;

  @override
  void initState() {
    super.initState();
    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 3000),
    );
    _scale = TweenSequence<double>([
      TweenSequenceItem(
        tween: Tween(begin: 1.0, end: 1.04)
            .chain(CurveTween(curve: Curves.easeInOutSine)),
        weight: 50,
      ),
      TweenSequenceItem(
        tween: Tween(begin: 1.04, end: 1.0)
            .chain(CurveTween(curve: Curves.easeInOutSine)),
        weight: 50,
      ),
    ]).animate(_pulseController);

    _fadeController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 600),
    );
    _textOpacity = CurvedAnimation(
      parent: _fadeController,
      curve: Curves.easeInOut,
    );
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final disabled = MediaQuery.maybeOf(context)?.disableAnimations ?? false;
    if (!disabled) {
      if (_pulseController.status == AnimationStatus.dismissed &&
          !_pulseController.isAnimating) {
        _pulseController.repeat();
      }
      if (_fadeController.status == AnimationStatus.dismissed &&
          !_fadeController.isAnimating) {
        _fadeController.forward();
      }
    }
  }

  @override
  void dispose() {
    _pulseController.dispose();
    _fadeController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final c = KaiTheme.of(context).colors;

    return SizedBox.expand(
      child: ColoredBox(
        color: c.bg,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            ScaleTransition(
              scale: _scale,
              child: const KaiLogo(size: 64),
            ),
            const SizedBox(height: 14),
            FadeTransition(
              opacity: _textOpacity,
              child: SelectionContainer.disabled(
                child: Column(
                  children: [
                    Text('kai', style: KaiType.wordmark(color: c.ink1)),
                    const SizedBox(height: 14),
                    Text(
                      'ваш компаньон путешественника',
                      style: KaiType.tagline(color: c.ink3),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
