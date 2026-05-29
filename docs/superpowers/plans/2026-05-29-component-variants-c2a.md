# Component Variants C2a Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: superpowers:subagent-driven-development. Steps use `- [ ]`.

**Goal:** Add the agreed variant/state set to 10 existing v3 components (+ their Storybook stories), additive and dark-safe.

**Architecture:** Additive params with current-behaviour defaults → existing call sites unaffected. Tokens only. Each new variant shown in its `StoryPage`. Grouped into 3 SDD batches; sub-commit per component.

**Spec:** `docs/superpowers/specs/2026-05-29-component-variants-c2a-design.md` (per-component detail — implementers READ it).

**Conventions:** const-correct; colours via `KaiTheme.of(context).colors`; reduced-motion (`MediaQuery.disableAnimations`) → static for any animation; reuse `buildTestWidget(child, {themeMode})`; after each component `flutter analyze` clean + `flutter test` green. Do NOT touch pre-existing dirty files (`docs/.../2026-05-28-design-system-refactor.md`, deleted `new-design/*.html`). Trailer all commits: `Co-Authored-By: Claude Opus 4.8 (1M context) <noreply@anthropic.com>`.

---

## Batch 1 — simple atoms (one implementer, 4 sub-commits)

### Task 1.1: KaiChip — `size` + status `tone`
- Files: `lib/design_system/atoms/kai_chip.dart`, `test/design_system/atoms/kai_chip_test.dart`, story in `lib/features/dev/storybook/stories/atom_stories.dart`.
- [ ] Add `enum KaiChipSize { sm, md }` (default `md`). `sm` = font 11px/w500; `md` = current. Apply to both `.status` and `.choice`.
- [ ] Extend `.status` `tone` (KaiChipTone) with `positive`/`warning`/`negative` (text = semantic colour, bg = its wash, border = semantic) alongside existing neutral/done/active.
- [ ] Test: `sm` renders 11px; each new tone uses the right token (find Text colour / decoration). Light + dark.
- [ ] Story: add Sizes section (sm/md) + a Tones section showing all status tones.
- [ ] analyze + test + commit `feat(ds): KaiChip size sm/md + semantic status tones`.

### Task 1.2: KaiBadge — `.dot` tone + `KaiBadge.tide()`
- Files: `kai_badge.dart`, its test, story.
- [ ] `.dot({Color? color})` → add `KaiBadgeTone? tone` (accent default; positive/warning/negative map to tokens). Keep `color` override.
- [ ] Add `const KaiBadge.tide({super.key})` — a gradient dot (8px, `KaiTide.gradientCorner`, no ring or with surface ring) for the "Kai saved memory" signal.
- [ ] Test: tide dot renders a gradient decoration; tones map correctly.
- [ ] Story: Variants section dot(tones)/count/tide.
- [ ] analyze + test + commit `feat(ds): KaiBadge dot tones + tide memory dot`.

### Task 1.3: KaiAvatar — sizes + `.user`/`.kai` + breathing
- Files: `kai_avatar.dart`, its test, story.
- [ ] Add `enum KaiAvatarSize { sm, md, lg }` (28/40/56). Add named ctors `KaiAvatar.user(String initial, {KaiAvatarSize size, bool breathing})` (current initial-on-gradientCorner) and `KaiAvatar.kai({KaiAvatarSize size, bool breathing})` (renders the tide-curve glyph / a `KaiGradientBar`-style mark, no initial). Keep the existing default ctor working (or migrate it to `.user`).
- [ ] `breathing` (default false): subtle scale 0.97↔1.03 via `KaiMotion.ambient`; reduced-motion → static; dispose controller.
- [ ] Test: each size diameter; `.kai` has no initial text; `.user` shows initial; breathing:true builds + animates without throw (bounded pumps).
- [ ] Story: Sizes + user/kai + a breathing example.
- [ ] analyze + test + commit `feat(ds): KaiAvatar sizes + user/kai variants + breathing`.

### Task 1.4: KaiIconButton — size + `.toggle`
- Files: `kai_icon_button.dart`, its test, story.
- [ ] Add `enum KaiIconButtonSize { sm, md }` (icon 16/18). Add `KaiIconButton.toggle({required bool active, required VoidCallback? onPressed, required KaiIconName icon, KaiIconButtonSize size})` — active = `accent` icon on `accentWash` pill; inactive = transparent ink3.
- [ ] Test: toggle active vs inactive colours; sizes; tap fires.
- [ ] Story: surface/transparent/bare + toggle(active/inactive) + sizes.
- [ ] analyze + test + commit `feat(ds): KaiIconButton sizes + toggle variant`.

---

## Batch 2 — send + gradient (one implementer, 2 sub-commits)

### Task 2.1: KaiSendButton — legible streaming (stop glyph)
- Files: `kai_send_button.dart`, `primitives/kai_icon.dart` (+ `assets/icons/stop.svg` if missing), tests, story.
- [ ] Add `KaiIconName.stop` (rounded square glyph) — create `assets/icons/stop.svg` (`<svg viewBox="0 0 24 24"><rect x="7" y="7" width="10" height="10" rx="2" fill="none" stroke="currentColor" stroke-width="2"/></svg>`) and the enum value `stop('stop')`.
- [ ] `streaming` state renders the `stop` glyph (square) instead of `arrowUp`, keeping the gradient + pulse — signalling "tap to stop". `sending` keeps arrow + pulse. `ready`/`disabled` unchanged.
- [ ] Test: streaming renders stop icon; ready renders arrowUp; disabled not tappable.
- [ ] Story: 4 states each captioned (ready / sending / streaming=stop / disabled).
- [ ] analyze + test + commit `feat(ds): KaiSendButton streaming shows stop glyph (+stop icon)`.

### Task 2.2: KaiGradientBar — streaming pulse
- Files: `primitives/kai_gradient_bar.dart`, its test, story.
- [ ] Add `bool streaming = false`: a calm responding-pulse (scale/opacity loop, `KaiMotion.ambient`), reduced-motion → static, dispose controller. Existing `pulse` retained.
- [ ] Test: streaming:true builds + animates without throw; default static.
- [ ] Story: static / pulse / streaming cells.
- [ ] analyze + test + commit `feat(ds): KaiGradientBar streaming pulse`.

---

## Batch 3 — molecules (one implementer, 4 sub-commits)

### Task 3.1: KaiComposeIsland — modes
- Files: `molecules/kai_compose_island.dart`, test, story.
- [ ] Add `enum KaiComposeMode { standard, voice, offline }` (default standard). `voice`: mic emphasised (larger/accent), send hidden until text present. `offline`: input disabled + small "оффлайн" hint, send disabled. `standard` = current. Keep controller/onSend/sendState API.
- [ ] Test: each mode renders expected affordances (voice → prominent mic; offline → disabled + hint).
- [ ] Story: standard/voice/offline cells.
- [ ] analyze + test + commit `feat(ds): KaiComposeIsland standard/voice/offline modes`.

### Task 3.2: KaiToast — countdown + undo
- Files: `molecules/kai_toast.dart` (+ controller if needed), test, story.
- [ ] Ensure action child renders compact (verify the C1 width fix at widget level). Add `showCountdown` thin progress bar for memory toast; add an `undo` convenience (actionLabel 'Отменить' + onAction). Document one-at-a-time.
- [ ] Test: countdown bar present when showCountdown; action fires.
- [ ] Story: 4 types + countdown + undo.
- [ ] analyze + test + commit `feat(ds): KaiToast countdown + undo action`.

### Task 3.3: KaiAccountHero — compact/full
- Files: `molecules/kai_account_hero.dart`, test, story.
- [ ] Add `enum KaiAccountHeroVariant { full, compact }` (default full). `compact` = avatar + name only (one line); `full` = current. Optional `VoidCallback? onTap`.
- [ ] Test: compact omits email/plan; full shows them; onTap fires.
- [ ] Story: full + compact cells.
- [ ] analyze + test + commit `feat(ds): KaiAccountHero compact/full variants`.

### Task 3.4: KaiSettingsRow — clarify + soften ripple
- Files: `molecules/kai_settings_row.dart`, test, story.
- [ ] Soften the `InkWell` feedback (toned `splashColor`/`highlightColor` via tokens, or a subtle `KaiMotion.micro` highlight). No API change. Add a clear doc comment (what it is / when to use).
- [ ] Story blurb explains the component; show with toggle/segmented trailing + danger.
- [ ] analyze + test + commit `refactor(ds): KaiSettingsRow clarify docs + soften ripple`.

---

## Verification (whole plan)
- `flutter analyze` "No issues found" + `flutter test` green at every sub-commit.
- All new variants visible in Storybook; dark-safe; existing screens unaffected.
- Final: `flutter run -d chrome` → `/#/_dev/storybook`, eyeball new variants light+dark.

## Self-review
Spec coverage: all 10 spec components have a task ✓. Types: enums (KaiChipSize/KaiBadgeTone/KaiAvatarSize/KaiIconButtonSize/KaiComposeMode/KaiAccountHeroVariant) named consistently between spec + plan ✓. No placeholders (each task lists concrete API + test + commit) ✓.
