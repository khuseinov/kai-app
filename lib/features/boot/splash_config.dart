/// Splash timing and sizing constants.
///
/// Centralised so product/brand tuning does not require touching widget code.
library;

/// Minimum time the splash should remain visible on a cold start.
const Duration kSplashMinVisibleDuration = Duration(milliseconds: 2200);

/// Duration of the "living tide" stroke-draw animation.
const Duration kSplashDrawDuration = Duration(milliseconds: 1400);

/// Duration of the wordmark + tagline fade-in.
const Duration kSplashTextFadeDuration = Duration(milliseconds: 600);

/// Duration of the cross-fade from splash to the real app.
const Duration kSplashCrossFadeDuration = Duration(milliseconds: 480);

/// Default logo glyph size on most screens.
const double kSplashLogoSize = 96;

/// Minimum logo glyph size on very small screens.
const double kSplashLogoSizeMin = 80;

/// Fraction of screen width used as the logo size cap.
const double kSplashLogoWidthFactor = 0.28;

/// Wordmark font size.
const double kSplashWordmarkSize = 40;

/// Secondary label font size (e.g. "by Wize").
const double kSplashSecondarySize = 14;

/// Space between logo and wordmark.
const double kSplashLogoToWordmarkGap = 20;

/// Space between wordmark and secondary label.
const double kSplashWordmarkToSecondaryGap = 8;

/// Resolve the logo size for the given screen width.
double resolveSplashLogoSize(double screenWidth) {
  return (screenWidth * kSplashLogoWidthFactor).clamp(
    kSplashLogoSizeMin,
    kSplashLogoSize,
  );
}
