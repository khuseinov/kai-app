import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../design_system/atoms/atoms.dart';
import '../../design_system/theme/kai_theme.dart';
import '../../design_system/tokens/kai_tokens.dart';
import 'splash_config.dart';

/// Canonical cold-start splash screen.
///
/// "Bottom signature" layout: the Kai glyph draws itself via the Living Tide
/// animation in the centre of the screen, while the "by Wize" attribution
/// fades in near the bottom. No separate "kai" wordmark — the logo mark
/// already carries the name.
///
/// Honors `MediaQuery.disableAnimations` — reduced-motion users see a static,
/// fully-drawn splash.
class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => SplashScreenState();
}

class SplashScreenState extends State<SplashScreen>
    with TickerProviderStateMixin {
  late final AnimationController _drawController;
  late final AnimationController _fadeController;
  late final Animation<double> _curveProgress;
  late final Animation<double> _signatureOpacity;

  bool _hapticFired = false;
  Timer? _signatureFadeTimer;

  /// Exposed for widget tests.
  AnimationController get drawController => _drawController;

  /// Exposed for widget tests.
  AnimationController get fadeController => _fadeController;

  @override
  void initState() {
    super.initState();
    _drawController = AnimationController(
      vsync: this,
      duration: kSplashDrawDuration,
    );
    _curveProgress = CurvedAnimation(
      parent: _drawController,
      curve: Curves.easeInOutSine,
    );

    _fadeController = AnimationController(
      vsync: this,
      duration: kSplashTextFadeDuration,
    );
    _signatureOpacity = CurvedAnimation(
      parent: _fadeController,
      curve: Curves.easeInOut,
    );

    _curveProgress.addListener(_onCurveProgressChanged);
  }

  void _onCurveProgressChanged() {
    if (_hapticFired) return;
    if (_curveProgress.value >= 0.75) {
      _hapticFired = true;
      _fireHaptic();
    }
  }

  void _fireHaptic() {
    final disabled = MediaQuery.maybeOf(context)?.disableAnimations ?? false;
    if (disabled) return;
    // Only fire on physical devices; HapticFeedback is a no-op on simulators.
    HapticFeedback.lightImpact();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final disabled = MediaQuery.maybeOf(context)?.disableAnimations ?? false;
    if (!disabled) {
      if (_drawController.status == AnimationStatus.dismissed &&
          !_drawController.isAnimating) {
        _drawController.forward();
      }
      if (_fadeController.status == AnimationStatus.dismissed &&
          !_fadeController.isAnimating) {
        // Start signature fade slightly before the curve finishes for overlap.
        _signatureFadeTimer = Timer(
          const Duration(milliseconds: 800),
          () {
            if (mounted &&
                _fadeController.status == AnimationStatus.dismissed &&
                !_fadeController.isAnimating) {
              _fadeController.forward();
            }
          },
        );
      }
    } else {
      // Reduced motion: show everything immediately.
      _drawController.value = 1.0;
      _fadeController.value = 1.0;
    }
  }

  @override
  void dispose() {
    _curveProgress.removeListener(_onCurveProgressChanged);
    _signatureFadeTimer?.cancel();
    _drawController.dispose();
    _fadeController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final c = KaiTheme.of(context).colors;
    final screenWidth = MediaQuery.of(context).size.width;
    final logoSize = resolveSplashLogoSize(screenWidth);

    return SizedBox.expand(
      child: ColoredBox(
        color: c.bg,
        child: Column(
          children: [
            const Spacer(),
            AnimatedBuilder(
              animation: _curveProgress,
              builder: (context, child) => KaiLogo(
                size: logoSize,
                curveProgress: _curveProgress.value,
              ),
            ),
            const Spacer(),
            FadeTransition(
              opacity: _signatureOpacity,
              child: SelectionContainer.disabled(
                child: Padding(
                  padding: const EdgeInsets.only(
                    bottom: kSplashSignatureBottomPadding,
                  ),
                  child: Text(
                    'by Wize',
                    style: KaiType.splashSignature(color: c.ink3),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
