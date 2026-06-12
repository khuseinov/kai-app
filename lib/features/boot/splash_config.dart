/// Splash timing and sizing constants.
///
/// Centralised so product/brand tuning does not require touching widget code.
library;

/// Minimum time the splash should remain visible on a cold start.
const Duration kSplashMinVisibleDuration = Duration(milliseconds: 2200);

/// Duration of the "living tide" stroke-draw animation.
const Duration kSplashDrawDuration = Duration(milliseconds: 1400);

/// Duration of the signature label fade-in.
const Duration kSplashTextFadeDuration = Duration(milliseconds: 600);

/// Duration of the cross-fade from splash to the real app.
const Duration kSplashCrossFadeDuration = Duration(milliseconds: 480);

/// Default logo glyph size on most screens.
const double kSplashLogoSize = 112;

/// Minimum logo glyph size on very small screens.
const double kSplashLogoSizeMin = 88;

/// Fraction of screen width used as the logo size cap.
const double kSplashLogoWidthFactor = 0.32;

/// Bottom signature label font size (e.g. "by Wize").
const double kSplashSignatureSize = 18;

/// Bottom padding for the signature label.
const double kSplashSignatureBottomPadding = 64;

/// Resolve the logo size for the given screen width.
double resolveSplashLogoSize(double screenWidth) {
  return (screenWidth * kSplashLogoWidthFactor).clamp(
    kSplashLogoSizeMin,
    kSplashLogoSize,
  );
}
