/// Splash timing and sizing constants.
///
/// Centralised so product/brand tuning does not require touching widget code.
library;

/// Minimum time the splash should remain visible on a cold start.
const Duration kSplashMinVisibleDuration = Duration(milliseconds: 800);

/// Duration of the logo glyph scale pulse animation.
const Duration kSplashPulseDuration = Duration(milliseconds: 2400);

/// Duration of the cross-fade from splash to the real app.
const Duration kSplashCrossFadeDuration = Duration(milliseconds: 480);

/// Logo glyph size on the splash screen.
const double kSplashLogoSize = 112;
