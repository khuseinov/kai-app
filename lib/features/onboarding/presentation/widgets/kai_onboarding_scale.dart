import 'package:flutter/material.dart';
import 'package:kai_app/design_system/theme/kai_theme.dart';

/// Computes the visual scale factor for the onboarding flow based on the
/// viewport's shortest side.
///
/// The onboarding cards and CTA are intentionally larger than the rest of the
/// app so that first-time users can read and tap comfortably on any screen.
///
/// Breakpoints:
///   < 360  → compact phones (e.g. iPhone SE 1st gen)        0.95
///   360–429 → baseline phones (iPhone SE 3, iPhone 14 Pro)  1.00
///   430–599 → large phones (iPhone 14 Pro Max, Android XL)  1.05
///   ≥ 600   → tablets, foldables, storybook/desktop frames    1.12
///
/// The result is clamped to [0.95, 1.15] to avoid absurd extremes.
double onboardingScale(BuildContext context) {
  return context.scale;
}

/// Test-friendly variant that works directly with a [Size].
double onboardingScaleForSize(Size size) {
  final s = size.shortestSide;
  final scale = switch (s) {
    < 360 => 0.95,
    < 430 => 1.0,
    < 600 => 1.05,
    _ => 1.12,
  };
  return scale.clamp(0.95, 1.15);
}

