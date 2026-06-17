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

  /// Exposed for widget tests.
  AnimationController get pulseController => _pulseController;

  @override
  void initState() {
    super.initState();
    _pulseController = AnimationController(
      vsync: this,
      duration: kSplashPulseDuration,
    );
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
            AnimatedBuilder(
              animation: _pulseController,
              builder: (context, child) {
                // ponytail: animate inner curve drawing (wave appearance)
                final curveVal = CurvedAnimation(
                  parent: _pulseController,
                  curve: Curves.easeInOut,
                ).value;
                return KaiLogo(
                  size: kSplashLogoSize,
                  curveProgress: curveVal,
                );
              },
            ),
            const Spacer(),
            Padding(
              padding: const EdgeInsets.only(bottom: 24),
              child: Text(
                'by Wize',
                style: KaiType.mono(color: c.ink3).copyWith(
                  fontSize: 16,
                  letterSpacing: 12 * 0.08,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
