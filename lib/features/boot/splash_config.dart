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
const double kSplashLogoSize = 80;

/// Minimum logo glyph size on very small screens.
const double kSplashLogoSizeMin = 64;

/// Fraction of screen width used as the logo size cap.
const double kSplashLogoWidthFactor = 0.22;

/// Wordmark font size.
const double kSplashWordmarkSize = 30;

/// Tagline font size.
const double kSplashTaglineSize = 14;

/// Space between logo and wordmark.
const double kSplashLogoToWordmarkGap = 18;

/// Space between wordmark and tagline.
const double kSplashWordmarkToTaglineGap = 10;

/// Resolve the logo size for the given screen width.
double resolveSplashLogoSize(double screenWidth) {
  return (screenWidth * kSplashLogoWidthFactor).clamp(
    kSplashLogoSizeMin,
    kSplashLogoSize,
  );
}
