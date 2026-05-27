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
| `splash-glyph.svg` | 1024×1024 (with built-in rounded corners) | Splash screen glyph image. Used by `flutter_native_splash`. |
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
brand/splash-glyph-1024.png
```

Then run the platform asset generators:

```sh
dart run flutter_launcher_icons
dart run flutter_native_splash:create
```

These overwrite the platform-specific assets:

- `ios/Runner/Assets.xcassets/AppIcon.appiconset/` — 15 sizes
- `android/app/src/main/res/mipmap-*/` — 5 densities + adaptive `mipmap-anydpi-v26/`
- `ios/Runner/Base.lproj/LaunchScreen.storyboard` — replaced with native splash
- `android/app/src/main/res/drawable*/launch_background.xml` — replaced

Configs for both tools live in `pubspec.yaml` under their named keys.

---

## Editing the masters

- Keep all four masters at 1024×1024 (3 icons + splash glyph).
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

- **OG card** (`brand/og-default.png`, 1200×630) — marketing asset, only needed
  when a landing page or share-link previews are added. Mark TODO when that
  work begins.
- **Favicon** (`brand/favicon-32.png`, `brand/favicon-16.png`) — web-only, not
  required for the mobile app.
