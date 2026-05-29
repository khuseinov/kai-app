# KAI App — Notes for Claude

Mobile-first Flutter app (iOS + Android). AI travel companion. Light-first
humanist design system, zero-UI. The v3 clean atomic component library is built
and live on `master` — all production screens run on it; the old layer is gone.

---

## iOS CI Build — DO NOT TOUCH

The iOS unsigned build pipeline is configured and working. Do not change the
signing settings without a specific reason.

### What's configured and why

**`ios/Runner.xcodeproj/project.pbxproj` — Runner target (Release + Profile):**
- `DEVELOPMENT_TEAM = PLACEHOLDER` — Flutter 3.x requires a non-empty value
  even with `--no-codesign`. Any non-empty string works; we use "PLACEHOLDER".
- `CODE_SIGN_STYLE = Manual` — prevents Xcode from contacting Apple servers
  to auto-provision with the placeholder team ID.
- `CODE_SIGNING_REQUIRED = NO` — xcodebuild skips the signing step.
- `CODE_SIGNING_ALLOWED = NO` — belt-and-suspenders: signing is not permitted.
- `CODE_SIGN_IDENTITY = ""` — no specific certificate required.

**`.github/workflows/ios_build.yml`:**
- `dart run build_runner build` is required — `*.g.dart` and `*.freezed.dart`
  are gitignored and must be generated on CI before the Flutter build.
- `CODE_SIGNING_REQUIRED: NO` and `CODE_SIGNING_ALLOWED: NO` env vars mirror
  the project settings as an extra safeguard.

### Build output
Artifact: `kai-app-ios-unsigned` → `app.ipa`
Install via: Sideloadly + USB cable → iPhone

### Repo must stay public
GitHub Actions macOS runners are free only for public repos.

---

## Project layout

```
lib/
  bootstrap.dart                  — async init: dotenv + Hive + ProviderContainer
  main.dart                       — runs BootingApp immediately (no blocking await)
  app.dart                        — KaiApp: MaterialApp.router + KaiTheme
  core/
    providers/root.dart           — Riverpod providers (env, dio, theme, repos)
    routing/router.dart           — go_router config + /_dev hub
    storage/                      — Hive entities + setup
    network/                      — Dio client + interceptor chain
    repositories/                 — mock + real chat / session
    telemetry/                    — NoOp service (swap before launch)
  design_system/                  — clean atomic library (v3), flat structure
    tokens/                       — kai_colors / kai_type / kai_space / kai_radius / kai_shadow / kai_motion / kai_tide / kai_tokens
    theme/                        — KaiTheme InheritedWidget + Material bridge
    primitives/ (3)               — KaiIcon (single SVG source), KaiSurface, KaiGradientBar — sub-atom layer; atoms MAY import these
    atoms/ (12)                   — KaiText (+tideWord), KaiButton (tide/ink/ghost/text · sm/md/lg · living tide gradient), KaiIconButton, KaiSendButton, KaiInput, KaiToggle, KaiChip, KaiBadge, KaiAvatar, KaiTideCurve, KaiDivider, KaiSheetShell
    molecules/ (16)               — KaiUserBubble / KaiKaiBubble / KaiSystemBubble, ComposeIsland, SourceCard, CareBlock, AlertCard, KaiToast (+ KaiToastController), KaiActionSheet, KaiMessageDetailSheet, KaiSegmentedControl, KaiSettingsRow, KaiSettingsGroup, KaiAccountHero, NavItem
    organisms/ (4)                — chat_list, nav_panel (+ nav_models view-models), edge_state_block, onboarding_card
  features/
    boot/                         — SplashScreen + BootingApp
    onboarding/                   — OnboardingScreen (4 steps)
    room/                         — RoomScreen (chat, 6 frames)
    nav/                          — NavScreen + side panel (+ session_groups.dart — pure date-bucketing presenter)
    settings/                     — SettingsScreen (7 sections)
    dev/                          — Storybook shell (sidebar + canvas + knobs) + theme showcase
new-design/                       — HTML mockups (22 files) — source of truth, READ-ONLY
brand/                            — SVG masters + generated PNG masters for icon/splash
tool/                             — Dart scripts (e.g. PNG generator)
test/                             — mirrors lib/ structure
```

Production screens on the v3 library: **room · onboarding · nav · settings**
(+ boot/splash). edge-states is not a standalone screen — it renders inline in
room via the `edge_state_block` organism. Remaining from `new-design/`:
voice, memory, trip-detail, fork.

---

## Setup (fresh checkout)

```sh
cp .env.example .env                                       # required by pubspec — flutter_test fails without it
flutter pub get
dart run build_runner build --delete-conflicting-outputs    # *.g.dart / *.freezed.dart are gitignored
flutter test                                                # expect 681/681 passing
flutter analyze                                             # expect "No issues found"
```

Run locally: `flutter run -d <device>`. Dev hub at `/_dev`.

### Component playground (Storybook) — where to poke the design system

`/_dev/storybook` is an **adaptive Storybook-style shell**: a left sidebar
(component tree grouped by primitives / atoms / molecules / organisms) + a
central canvas rendering the selected component's variants & states + knobs
(light/dark theme · device-frame). Wide window → persistent sidebar; narrow →
sidebar in a drawer. This is the place to eyeball every component live.

Best viewed in a browser (URL-routable, hot-reload):
```sh
flutter run -d chrome      # then open  http://localhost:<port>/#/_dev/storybook
```
On a device/emulator (no URL bar): temporarily set
`initialLocation: '/_dev/storybook'` in `lib/core/routing/router.dart`,
hot-restart (revert after). `/_dev/theme-showcase` shows raw tokens
(color / type / space / radius / tide).

---

## Design system conventions (non-negotiable)

Source of truth is `new-design/CLAUDE.md` — read it for any design work.

- **Always go through tokens.** `KaiTheme.of(context).colors.<name>` for colours,
  `KaiType.*` / inline `TextStyle(fontFamily: 'Manrope' | 'JetBrainsMono', ...)`
  for text, `KaiSpace.s*` / `KaiRadius.r*` / `KaiMotion.*` for the rest. No
  hard-coded `Color(0xFF...)` or magic padding numbers in `lib/design_system/`
  or `lib/features/` — only in token files.
- **Tide gradient is locked.** Two variants only:
  - `KaiTide.gradient` (115° / stops 0/52/100) — tide curve at top of every
    screen, hero text emphasis, wide/thin surfaces.
  - `KaiTide.gradientCorner` (135° / stops 0/55/100) — square brand surfaces
    only (app icon, splash glyph, OG card, avatar circles).
- **Error = `#C44A3C` coral**, never alarming red. Lives in the `negative` token.
- **Zero-UI**: no persistent chrome. Surfaces are summoned by gesture or by Kai.
- **One primary action per screen** carries the tide gradient (usually Send).
  All others use ink-1 or ghost.
- **Phone-frame sizes** are HTML-mockup-only — don't migrate them to Dart.
- **Language**: app UI is Russian-first via ARB; Claude responds to user in
  Russian (per memory).

---

## HTML → Flutter workflow

> **RULE: always use Playwright MCP + spec-viewer for any design work.**
> Never eyeball-extract values from raw HTML. Computed styles differ from
> source CSS; only the browser resolves cascades, inheritance, and tokens correctly.

**Step 1 — start the server** (if not already running):
```sh
cd new-design && python -m http.server 8743
```

**Step 2 — open spec-viewer via Playwright MCP:**
```
mcp__plugin_playwright_playwright__browser_navigate(
  "http://localhost:8743/spec-viewer.html"
)
```

**Step 3 — inspect elements:**
Click any element in the preview iframe → Props / CSS / Flutter tabs update.
`genFlutter()` in spec-viewer is the authoritative CSS→Dart mapping.

**Step 4 — use agent tools when doing audits or new screens:**
- `lint` button — finds token violations before writing any Dart
- `json ↓` — downloads structured JSON spec for the whole screen
- `ruler` (Shift+click two elements) — measures gaps in px + token
- State Simulator — forces `:hover`/`:focus`/`:active` states before copying styles
- `tree` button (Flutter tab) — copies nested widget tree for flex containers

**Fallback order** (only when Playwright MCP is unavailable):
1. Direct HTML read — slower, misses computed cascades
2. Existing molecules first — check atoms/molecules list before writing new widgets

---

## Brand assets pipeline

Source of truth: `brand/BRAND_README.md`. Quick regen:

```sh
flutter test tool/generate_brand_pngs.dart     # SVG → 1024×1024 master PNGs
dart run flutter_launcher_icons                # → iOS AppIcon set + Android mipmap + adaptive
dart run flutter_native_splash:create          # → LaunchScreen.storyboard + launch_background.xml
```

The Dart-side splash widget (`lib/features/boot/splash_screen.dart`) renders
from `KaiTide.gradientCorner` at runtime — no PNG dependency at runtime, only
at launcher / native-splash generation time.

---

## Hive — adapters are hand-rolled

`@HiveType` / `@HiveField` annotations are documentation only. Adapters live
under `lib/core/storage/entities/*.g.dart` and are written by hand because
`hive_generator ^2.0.1` conflicts with `freezed ^2.5.6` via `analyzer`. When
adding a field, manually update the adapter's `read()` / `write()`.

---

## Where to find things

- **Per-screen HTML canon**: `new-design/<screen>.html` (foundations, room,
  components, edge-states, onboarding, nav, voice, memory, settings,
  trip-detail, fork, brand, landing, dark, tide-states, notifications-chat,
  handoff)
- **Hard rules + design philosophy**: `new-design/CLAUDE.md`
- **Live design system — poke it**: `/_dev/storybook` in the running app (see Setup).
  Code at `lib/design_system/{primitives,atoms,molecules,organisms}`.
- **Agent component index** (READ THIS FIRST for any design work): `lib/design_system/COMPONENTS.md` —
  canon→Dart lookup table, constructor signatures, Playwright-verified computed values for
  every component + 4 unbuilt screens (voice/memory/trip-detail/fork).
- **Clean atomic library (v3) — spec + plan**:
  `docs/superpowers/specs/2026-05-28-kai-ui-atomic-library-v3-design.md` +
  `docs/superpowers/plans/2026-05-28-kai-ui-atomic-library-v3.md`
- **Design-system audit (reusability + fidelity)**:
  `docs/superpowers/audits/2026-05-28-design-system-audit.md`
- **Latest session handoff**: `docs/superpowers/handoffs/2026-05-28-design-fidelity-v2-session.md`
- **Rebuild v3 spec (original)**: `docs/superpowers/specs/2026-05-26-kai-app-rebuild-v3-design.md`
- **Design fidelity plan (with bucket task-docs)**: `docs/superpowers/plans/2026-05-27-design-fidelity-fixes.md`
- **Brand pipeline**: `brand/BRAND_README.md`
- **Memory** (point-in-time observations, may be stale): `C:\Users\79050\.claude\projects\E--startup-kai-app\memory\`

---

## Locked directories

Don't touch without an explicit reason. Diffs there are usually accidental:

- `ios/` (except iOS-CI signing rules above) — Xcode-managed
- `android/` — Gradle-managed; native splash + launcher icons are
  regenerated from `brand/` via the pipeline above
- `web/`, `windows/`, `macos/`, `linux/` — out of mobile scope for v1
- `new-design/` — HTML source of truth; only the designer (or an explicit
  design task) edits this. CSS/JSON token files are the exception — they
  sync with `lib/design_system/tokens/` when intentional changes happen.
