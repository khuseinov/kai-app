# Kai · Brand Assets

Master vector sources for app icons, splash glyph, and OG card. Generated PNG
assets are produced from these via `tool/generate_brand_pngs.dart`.

> **Source of truth**: `new-design/brand.html § 02.1–02.3` + `new-design/CLAUDE.md § 3 Brand mark`. Do not invent new gradients or recolour stops.

---

## Files in this directory

| File | Master | Use |
|------|--------|-----|
| `icon-primary.svg` | 1024×1024 | Primary app icon — tide-gradient corner (135°) + white curve. iOS / Android default. |
| `icon-dark.svg` | 1024×1024 | iOS tinted dark mode + dark splash anchor. Slate gradient bg + tide-gradient curve. |
| `icon-mono.svg` | 1024×1024 | Single-colour stencil — watch faces, accessibility tinting, mono print. |
| `icon-mono-tinted.svg` | 1024×1024 | iOS 18 tinted mode stencil — transparent background + white curve. |
| `splash-glyph.svg` | 1024×1024 (with built-in rounded corners) | Splash screen glyph image. Used by `flutter_native_splash`. |
| `og-default.png` | 1200×630 | OG card for social sharing. Generated from `brand.html § 02.2`. Also copied to `web/og-default.png`. |
| `favicon-32.png` | 32×32 | Web favicon with brand glyph. |
| `favicon-16.png` | 16×16 | Tiny web favicon — gradient square, curve invisible at this size. |
| `BRAND_README.md` | — | This file. |

Square masters carry **no rounded corners** — iOS / Android apply their own platform mask (iOS round-rect 22% radius, Android adaptive). `splash-glyph.svg` is the exception: it bakes in a corner radius (`r=320` on the 1024 master = canon 22%) because it ships as a self-contained tile, not an icon.

---

## Gradient locks

Two canonical gradients (`new-design/CLAUDE.md § 3 Brand mark`):

| Variant | Angle / stops | Where |
|---|---|---|
| `--tide-gradient` | **115° / 0 · 52 · 100** | Tide curve at top of every product screen. Hero text. Wide/thin surfaces. |
| `--tide-gradient-corner` | **135° / 0 · 55 · 100** | Square surfaces only: app icon, splash glyph, OG card glow, avatar circles. |

All bright stops are locked: `#1B4FB0 → #2BA8C9 → #F4B589`. No recolours, no holiday variants, no client-specific tints.

---

## Platform-specific notes

### Favicon 16×16

`brand/favicon-16.png` and `web/favicon-16.png` are rendered as a pure gradient square (`KaiTide.gradientCorner`: 135° `#1B4FB0 → #2BA8C9 55% → #F4B589`). The brand curve is intentionally omitted — it is illegible at 16×16.

### Android adaptive icon

Android adaptive icons use a single foreground layer, not separate fg/bg PNGs. `pubspec.yaml` configures `flutter_launcher_icons` with:

- `adaptive_icon_background: "#FAFAF9"`
- `adaptive_icon_foreground: "brand/icon-1024.png"`

`brand/icon-1024.png` already contains the gradient corner + white curve with the recommended 16% inset, so Android masks it directly. There are no `icon-adaptive-fg.png` / `icon-adaptive-bg.png` masters.

### iOS 18 tinted mode

- Source master: `brand/icon-mono-tinted.svg` (transparent background, white curve stencil).
- Generated PNG: `brand/icon-1024-mono-tinted.png` is produced by `tool/generate_brand_pngs.dart`.
- Wired in `pubspec.yaml` as `image_path_ios_tinted_grayscale: "brand/icon-1024-mono-tinted.png"`. `remove_alpha_ios: false` keeps the transparent stencil so iOS can tint the curve.

---

## Regenerating PNGs

The Dart-side splash screen (`lib/features/boot/splash_screen.dart`) renders entirely from `KaiTide.gradientCorner` at runtime — it does not require any PNG. The PNGs are only needed for:

- iOS / Android launcher icons (via `flutter_launcher_icons`)
- Native cold-start splash background (via `flutter_native_splash`)

To regenerate from SVG sources:

```sh
flutter test tool/generate_brand_pngs.dart
```

This produces:

```
brand/icon-1024.png
brand/icon-1024-dark.png
brand/icon-1024-mono.png
brand/icon-1024-mono-tinted.png
brand/splash-glyph-1024.png
brand/og-default.png
web/og-default.png
```

Then run the web icon generator:

```sh
dart run tool/generate_web_icons.dart
```

This produces:

```
web/favicon.png
web/favicon-16.png
web/icons/Icon-192.png
web/icons/Icon-512.png
web/icons/Icon-maskable-192.png
web/icons/Icon-maskable-512.png
brand/favicon-32.png
brand/favicon-16.png
```

Then run the platform asset generators:

```sh
dart run flutter_launcher_icons
dart run flutter_native_splash:create
```

> **Note:** `flutter_native_splash:create` regenerates iOS and web launch
> surfaces. The design decision is to keep native launch screens as solid theme
> colors only; the brand glyph animates exclusively inside the Flutter
> `SplashScreen`. Do not re-add a native brand glyph — that would reintroduce
> the duplicate-logo / position-jump problem fixed in `5a4352a`.

These overwrite the platform-specific assets:

- `ios/Runner/Assets.xcassets/AppIcon.appiconset/` — 15 sizes
- `android/app/src/main/res/mipmap-*/` — 5 densities + adaptive `mipmap-anydpi-v26/`
- `ios/Runner/Base.lproj/LaunchScreen.storyboard` — replaced with native splash
- `android/app/src/main/res/drawable*/launch_background.xml` — replaced

Configs for both tools live in `pubspec.yaml` under their named keys.

---

## Editing the masters

- Keep all five masters at 1024×1024 (4 icon variants + splash glyph).
- Curve uses path `M 2 10 Q 14 2, 28 10 T 56 6` in a 60×16 viewBox for icons,
  and `M 2 11 Q 9 3, 18 11 T 34 7` in a 36×18 viewBox for the splash glyph.
  Both paths come from `new-design/brand.html`. **Do not redraw the curve** —
  copy the existing path exactly.
- Stroke width on master: 3 (icons), 2.5 (splash glyph). The relative weight
  matches the HTML reference at the canvas-mockup scale.
- Test changes visually by opening the SVG in a browser at 100% zoom; it
  should match `new-design/brand.html § 02.1` side-by-side.

---

## Out of scope

Nothing currently.
