# Kai App — Session Handoff (2026-05-28)

**Branch:** `master` · **Tip:** `31fd0b5` · **Tests:** 299/299 · **Analyze:** clean

---

## What landed this session

Eight commits on top of the earlier rebuild v3 merge (`97f28db`).

| Commit | Subject |
|---|---|
| `b2947b5` | chore(design): import `new-design/` bundle + add `KaiTide.gradientCorner` |
| `890a7bf` | feat(molecules): 4 missing molecules + AlertCard icons + CareBlock font |
| `a44d191` | feat(boot): Dart-side `SplashScreen` + `BootingApp` bootstrap wire-up |
| `aaaeb87` | chore(brand): SVG sources + Dart PNG generator + pubspec packages |
| `61181aa` | feat(brand): generated iOS + Android + Web launcher icons + splash screens |
| `320bfe8` | fix(brand): include `LaunchBackground.imageset` from native_splash output |
| `31fd0b5` | feat(settings): `SettingsScreen` + Toggle/SegmentedControl/SettingsRow/AccountHero/SettingsGroup |
| _(this file)_ | docs(handoff) + memory + gitignore cleanup |

### Counters delta

| | Start | End |
|---|---|---|
| Tests | 239 | **299** (+60) |
| Atoms | 7 | **9** (+`KaiBottomSheetShell`, `KaiToggle`) |
| Molecules | 5 | **13** (+`KaiToast`, `SystemNote`, `ActionSheet`, `MessageDetailSheet`, `SegmentedControl`, `SettingsRow`, `AccountHero`, `SettingsGroup`) |
| SVG icons | 20 | **30** (+ `check`, `info`, `palette`, `motion`, `speaker`, `globe`, `trash`, `shield`, `lock`, `logout`) |
| Tide gradients | 1 | **2** (`gradient` 115° + `gradientCorner` 135°) |
| Production screens implemented | 4 | **5** (+ `settings`) |
| Launcher icons | Flutter "F" defaults | Kai tide gradient (iOS 16 sizes + Android 5 densities + adaptive) |
| LaunchScreen | empty white | Branded splash (light + dark + Android 12+) |

### Audit closures

Drove from the three-agent audit (2026-05-27/28). All CRITICAL and HIGH gaps from the **Components** audit closed; all CRITICAL and most HIGH from **Brand** closed; **Foundations** has 0 critical findings (it was clean from the start).

Remaining HIGH from Components audit (deferred to follow-up):
- KaiBubble systematic deviation (room.html compact 13px vs components.html canon 15px) — needs **user decision** on which is canon
- KaiBubble.kai missing `.cite` accent for inline `[N]`, missing meta-row (react buttons + sources counter), streaming variant not exported as a `bool streaming` flag
- ComposeIsland.sheet variant — dead code, candidate for removal
- KaiButtonSend default size 44 — DX-trap, should be 30 by default

---

## What's left in `new-design/`

4 production screens not yet implemented:

| Screen | HTML | Difficulty | Notes |
|---|---|---|---|
| Memory | `memory.html` | Low–medium | Grouped facts + sources + GDPR forget. Reuses `KaiSettingsRow` / `KaiSettingsGroup` patterns. |
| Trip detail | `trip-detail.html` | Medium | Trip folder content — facts + chats + sources + actions tabs. |
| Fork | `fork.html` | Medium | Multi-country compare card (F-L1-05), moat L1+L3. |
| Voice | `voice.html` | High | Always-dark, karaoke text reveal, FSM-driven tide. Most complex. |

Plus `notifications-chat.html` integration — molecule exists, inline-in-feed integration doesn't.

---

## Tooling notes

- **Playwright MCP** is installed and connected (`plugin:playwright:playwright`). Next session should be able to call `mcp__plugin_playwright_playwright__browser_navigate(file:///E:/startup/kai-app/new-design/spec-viewer.html)` directly to drive the spec viewer and extract Flutter code from any element. This session hit a stale-profile lock on the first attempt (`E:\caches\playwright\mcp-chrome-b5211ca\lockfile`); resolved by closing the orphan Chrome window manually.
- **spec-viewer.html** has a `genFlutter()` function (lines ~1095–1300) that maps CSS to Dart with token resolution (`KaiColors.light.ink1`, `KaiTide.gradient`, `EdgeInsets.symmetric`, etc.). Use it for pixel-perfect translation rather than hand-reading HTML.
- **Brand asset pipeline** is end-to-end: `flutter test tool/generate_brand_pngs.dart` → `dart run flutter_launcher_icons` → `dart run flutter_native_splash:create`. See `brand/BRAND_README.md`.
- **`.env` is gitignored** but required for tests. If a fresh checkout fails `flutter test` with "No file or variants found for asset: .env", copy from `.env.example`.

---

## Outstanding before "ship"

1. **Push to origin/master** — 7 commits on local master not yet pushed. Auto-mode classifier denied direct push without explicit user authorization; user needs to either (a) explicitly approve in chat, or (b) run `! git push origin master` themselves.
2. **iOS CI verification** — after push, watch GitHub Actions `ios_build.yml`. Pubspec auto-modified `ios/Runner.xcodeproj/project.pbxproj` to register new dev-only packages (signing settings untouched per root CLAUDE.md). If CI red, that's the first place to revert.
3. **Visual verification on device** — never ran `flutter run` this session. Need to sideload IPA to confirm Kai tide icon replaces Flutter "F" on home screen + splash renders correctly + `/settings` route works in the dev navigation.

---

## Quick start for next session

```bash
# 0. Verify state
git status                              # should be clean
git log --oneline -8                    # commits b2947b5..31fd0b5 present
flutter test                            # 299/299

# 1. Generate freezed/json/hive — `*.g.dart` and `*.freezed.dart` are gitignored
dart run build_runner build --delete-conflicting-outputs

# 2. If pushing now
git push origin master

# 3. To start the next screen (memory.html recommended)
mcp__plugin_playwright_playwright__browser_navigate("file:///E:/startup/kai-app/new-design/spec-viewer.html")
# In spec viewer: click memory.html in left sidebar, then click any element to get Dart code from Inspector panel
```
