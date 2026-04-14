# Splash Screen + App Icon Design

## Overview

Replace default Flutter splash and icon with branded Kai assets. Consistent visual identity across native splash, animated splash, and app icon.

## Brand Identity

- **Name**: Kai
- **Typography**: Merriweather Bold (serif, elegant)
- **Colors**: oceanPrimary (#0284C7) → stateListening cyan (#06B6D4) gradient
- **Motif**: Ocean wave — ties to AI companion personality

## App Icon

- **Content**: Text "Kai" (Merriweather Bold, white) with a smooth stylized wave flowing beneath/through the text
- **Background**: Gradient oceanPrimary → cyan
- **Style**: Minimal, flat, recognizable at all sizes (29px favicon to 1024px App Store)
- **Format**: SVG source → PNG exports via `flutter_launcher_icons`

## Splash Screen (Two Layers)

### Layer 1: Native Splash (instant)
- `flutter_native_splash` package
- Background: same ocean→cyan gradient
- Static centered logo ("Kai" + wave, white on gradient)
- Appears instantly while Flutter engine loads

### Layer 2: Animated Splash (~1.5s)
- Flutter-level animation after engine ready
- Wave rises smoothly from bottom, "Kai" text fades in from the wave
- Smooth easeOutCubic curve
- Fade transition to chat screen

## Implementation Steps

1. Create SVG logo ("Kai" + wave, white on transparent)
2. Add `flutter_native_splash` and `flutter_launcher_icons` to pubspec.yaml
3. Configure `flutter_native_splash` with gradient background + logo
4. Configure `flutter_launcher_icons` with logo on gradient background
5. Create animated splash screen widget in Flutter
6. Update router to show splash animation before chat
7. Run code generation for native assets
8. Test on iOS + Android

## Technical Notes

- Logo SVG must be created manually or with a design tool — cannot be generated programmatically
- iOS icon: 1024x1024 master + auto-generated sizes
- Android icon: adaptive icon (foreground SVG + background gradient)
- Native splash runs before Flutter, so no Dart animation possible at that stage
- Animated splash is a one-time widget shown on app launch only

## Packages

- `flutter_native_splash: ^2.4.0`
- `flutter_launcher_icons: ^0.14.0`
