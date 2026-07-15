# Splash redesign: Living Tide + Haptic Tide

## Goal
Replace the current looping scale-pulse splash with a more distinctive, signature moment that communicates the Kai brand — "тихая система, с моментами прилива" — while fixing known transition and timing issues.

## Scope
- `lib/features/boot/splash_screen.dart`
- `lib/features/boot/booting_app.dart`
- `lib/features/boot/splash_config.dart` (new)
- `lib/design_system/atoms/kai_logo.dart`
- `ios/Runner/Assets.xcassets/AppIcon.appiconset/` icon handling
- `pubspec.yaml` launcher-icons config tweak

## Concept

### 1. Living Tide (primary visual)
Instead of scaling the whole glyph up and down, the **white brand curve inside the glyph draws itself** on every cold start.

- Stroke-dashoffset animation from empty to full curve.
- Duration: **1400 ms**.
- Curve: `easeInOutSine` — organic, tide-like acceleration.
- Once the curve is fully drawn, the wordmark "kai" and tagline fade in over **600 ms**.
- The glyph itself remains static in size; the motion lives *inside* the mark.

This mirrors the brand promise: the tide arrives, then the brand appears.

### 2. Haptic Tide (signature detail)
A single, subtle haptic event fires at the moment the curve reaches ~75 % drawn (the visual "crest" of the wave).

- Uses `HapticFeedback.lightImpact()`.
- Only on physical devices; disabled in simulator, tests, and when `MediaQuery.disableAnimations` is true.
- No sound for now — keep it silent and refined.

### 3. Timing adjustments
- Minimum splash visible duration: **2200 ms** (was 1500 ms).
- Cross-fade to app: keep **480 ms** but match background color to avoid black flash.
- Onboarding/room first frame must use the same background as the splash.

### 4. Black flash fix
Root cause: `AnimatedSwitcher` in `BootingApp` shows the default black background between splash and app, and the first screen uses `colors.surface` while splash uses `colors.bg`.

Fix:
- Add `backgroundColor` to `AnimatedSwitcher` equal to the current theme background.
- Wrap first route in a container with the same background for the first frame.
- Prefer `FadeTransition` over `AnimatedSwitcher` if the intermediate black frame persists.

### 5. Typography / sizing bump
- Logo glyph: **80 logical px** (was 64).
- Wordmark: **30 px / 700** (was 26).
- Tagline: **14 px / 400** (was 12.5).
- Gap logo → wordmark: **18 px**.
- Gap wordmark → tagline: **10 px**.

On very small screens (SE), scale down proportionally: `logoSize = min(80, screenWidth * 0.22)`.

## iOS icon theme fix
`flutter_launcher_icons` applies `remove_alpha_ios` to all variants. iOS 18 dark/tinted icons need transparency. Fix by removing the global `remove_alpha_ios: true` and ensuring only the primary light icon is opaque. If the generator cannot handle per-variant alpha, switch to a post-generation script that removes alpha only from `Icon-App-1024x1024@1x.png`.

## Accessibility
- Respect `MediaQuery.disableAnimations`:
  - Skip stroke animation; show fully drawn curve immediately.
  - Skip haptic.
- Keep text selectable-disabled to avoid selection handles.

## Success criteria
1. Cold start feels calm and intentional, not slow.
2. No black flash in light or dark theme.
3. iOS icon changes with system theme after clean build.
4. Splash tests pass with new animation timings.
5. `flutter analyze` is clean.

## Out of scope
- Sound.
- Weather/location-based scenes.
- 3D parallax.
- Morphing glyph shapes.
