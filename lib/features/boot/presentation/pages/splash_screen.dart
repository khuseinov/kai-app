import 'package:flutter/material.dart';

import 'package:kai_app/design_system/atoms/atoms.dart';
import 'package:kai_app/design_system/theme/kai_theme.dart';
import 'package:kai_app/design_system/tokens/kai_tokens.dart';
import 'package:kai_app/features/boot/presentation/widgets/splash_config.dart';

/// Canonical cold-start splash screen.
///
/// Centered lockup on a solid background: the Kai glyph pulses once, the
/// "kai" wordmark sits below it, and the tagline sits below that.
///
/// Honors `MediaQuery.disableAnimations` — reduced-motion users see a static,
/// fully-drawn splash.
class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => SplashScreenState();
}

class SplashScreenState extends State<SplashScreen>
    with SingleTickerProviderStateMixin {
  late final AnimationController _pulseController;
  late final Animation<double> _pulseAnimation;

  /// Exposed for widget tests.
  AnimationController get pulseController => _pulseController;

  @override
  void initState() {
    super.initState();
    _pulseController = AnimationController(
      vsync: this,
      duration: kSplashPulseDuration,
    );
    _pulseAnimation = TweenSequence<double>([
      TweenSequenceItem(
        tween: Tween<double>(begin: 1, end: 1.06)
            .chain(CurveTween(curve: Curves.easeInOut)),
        weight: 0.5,
      ),
      TweenSequenceItem(
        tween: Tween<double>(begin: 1.06, end: 1)
            .chain(CurveTween(curve: Curves.easeInOut)),
        weight: 0.5,
      ),
    ]).animate(_pulseController);
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final disabled = MediaQuery.maybeOf(context)?.disableAnimations ?? false;
    if (disabled) {
      _pulseController.value = 1.0;
    } else if (_pulseController.status == AnimationStatus.dismissed &&
        !_pulseController.isAnimating) {
      _pulseController.forward();
    }
  }

  @override
  void dispose() {
    _pulseController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final c = KaiTheme.of(context).colors;

    return SizedBox.expand(
      child: ColoredBox(
        color: c.bg,
        child: Column(
          children: [
            const Spacer(),
            ScaleTransition(
              scale: _pulseAnimation,
              child: const KaiLogo(size: kSplashLogoSize),
            ),
            const SizedBox(height: 16),
            Text('kai', style: KaiType.wordmark(color: c.ink1)),
            const SizedBox(height: 4),
            Text(
              'ваш компаньон путешественника',
              style: KaiType.tagline(color: c.ink3),
            ),
            const Spacer(),
          ],
        ),
      ),
    );
  }
}
