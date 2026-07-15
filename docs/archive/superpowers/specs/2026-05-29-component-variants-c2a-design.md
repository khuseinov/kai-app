# Component Variant Expansion — Cycle 2a — Design

**Date:** 2026-05-29 · **Branch:** `master` · **Status:** design approved — pending spec review
**Cycle:** 2a (of the C2 pair). C2b = new molecules (Fork/Karaoke/Transcript/Budget).

## Context

Cycle 1 turned the Storybook into a usable reference and surfaced that several v3
components expose too few variants/states to cover the `new-design/` canon and the "Kai"
feel the user wants. A live review enumerated gaps: GradientBar has no streaming state,
chips lack the small onboarding size, badges/avatars are too plain, the send button doesn't
communicate its state (especially "you can stop streaming"), compose-island has only one
form, toast/account-hero need more shapes, and KaiSettingsRow is unclear with too-strong
ripple. This cycle **extends existing components** with new variants/states (and their
Storybook stories). It does NOT add new molecules (C2b).

## Goal

Add the agreed variant/state set to 10 existing components, each fully token-driven and
dark-safe, with every new variant shown in its `StoryPage` story — `flutter test` green,
`flutter analyze` clean.

## Locked decisions

- Order C2a → C2b. GradientBar keeps its simple pill and gains only a `streaming` pulse;
  the full 8 tide states stay in `KaiTideCurve` (no duplication). New molecules built in C2b.

## Per-component changes (★ canon-grounded · ✦ Kai-spirit extension)

All components live in `lib/design_system/{primitives,atoms,molecules}/`. Add no hardcoded
colors (tokens only; sanctioned white-on-fill / theme-independent gradient excepted). Update
each component's story in `lib/features/dev/storybook/stories/` to show the new variants.

1. **KaiGradientBar** (primitive) — ✦ add `bool streaming = false`. When true, a calm
   responding-pulse (scale/opacity loop via `KaiMotion.ambient`, reduced-motion → static).
   Existing `pulse` stays. Used as the in-chat streaming glyph. 8 states remain in KaiTideCurve.

2. **KaiChip** (atom) — ★ add a `size` param `KaiChipSize { sm, md }` (default `md`);
   `sm` = 11px/w500 (onboarding selected chips). ✦ extend `KaiChip.status` `tone` to include
   `positive/warning/negative` (semantic status pills) alongside existing neutral/done/active.

3. **KaiBadge** (atom) — keep `.dot` / `.count`; ✦ add `tone` to `.dot` (accent default +
   positive/warning/negative); ✦ add `KaiBadge.tide()` — a gradient dot (tide-corner) for the
   "Kai saved a memory" signal.

4. **KaiAvatar** (atom) — ✦ add `KaiAvatarSize { sm, md, lg }` (28/40/56). ✦ add named ctors
   `KaiAvatar.user(initial)` (initial on tide-corner gradient — current behaviour) and
   `KaiAvatar.kai()` (the tide-curve glyph mark, no initial). ✦ optional `bool breathing`
   subtle presence pulse (reduced-motion → static).

5. **KaiIconButton** (atom) — ✦ add `KaiIconButtonSize { sm, md }` (icon 16/18, target 28/30).
   ✦ add `KaiIconButton.toggle({required bool active, ...})` — active state tints `accent` +
   `accentWash` fill; inactive = transparent ink3. Press state already exists.

6. **KaiSendButton** (atom) — ★ make state legible: `streaming` renders a **stop** glyph
   (square) instead of the up-arrow, so the user sees they can interrupt; `sending` keeps the
   scale-pulse with the arrow. `ready`/`disabled` unchanged. Add a `KaiIconName.stop` asset if
   absent (a rounded square). Story shows all four states with captions.

7. **KaiComposeIsland** (molecule) — ✦ add a `KaiComposeMode { standard, voice, offline }`:
   `voice` emphasises the mic (larger, accent) and hides send until text; `offline` disables
   input + shows a small "оффлайн" hint; `standard` = current. Keep `sendState`/controller API.

8. **KaiToast** (molecule) — ★ ensure the action child renders at the correct compact size
   (done in C1 story, verify in widget); ✦ add `showCountdown` wiring for the memory toast
   (thin progress bar) and an `undo` action convenience. Document one-at-a-time rule.

9. **KaiAccountHero** (molecule) — ✦ add `KaiAccountHeroVariant { full, compact }`: `compact`
   = avatar + name only (one line, for nav footer); `full` = current (avatar + name + email +
   plan). Optional `onTap`.

10. **KaiSettingsRow** (molecule) — clarify role (settings list row) in docs; reduce the
    `InkWell` ripple to a subtle `KaiMotion.micro` highlight (or `splashColor`/`highlightColor`
    toned down via tokens); story blurb explains what it is + when to use.

## File map

Modify the 10 component files above + their 10 story entries in
`lib/features/dev/storybook/stories/{primitive,atom,molecule}_stories.dart`. Add
`KaiIconName.stop` to `lib/design_system/primitives/kai_icon.dart` + a `assets/icons/stop.svg`
if missing. Tests: extend each component's test file under `test/design_system/...` for the
new variants/states.

## Build sequence (TDD per component)

Group into SDD-friendly batches (each batch one implementer, sub-commit per component):
- **Batch 1 — atoms-simple:** KaiChip (size+tone), KaiBadge (tone+tide), KaiAvatar (sizes+kai/user+breathing), KaiIconButton (size+toggle).
- **Batch 2 — send/gradient:** KaiSendButton (stop glyph + `stop.svg`/enum), KaiGradientBar (streaming pulse).
- **Batch 3 — molecules:** KaiComposeIsland (modes), KaiToast (countdown/undo verify), KaiAccountHero (compact/full), KaiSettingsRow (clarify + ripple).
- **Batch 4 — stories:** update all 10 stories to show new variants (may be folded into each batch's component sub-commit instead).

Each component: write/extend test → implement → `flutter analyze` clean → `flutter test`
green → commit. New variants default to current behaviour so existing call sites are
unaffected (additive, backward-compatible).

## Acceptance criteria

- `flutter analyze` → "No issues found"; `flutter test` green (≥695 + new tests).
- Every new variant/state visible in its Storybook StoryPage with a caption.
- All new variants dark-safe (verified by the dark-theme discipline: tokens only).
- Existing screens unaffected (additive params with current-behaviour defaults).
- KaiSendButton clearly distinguishes ready/sending/streaming(stop)/disabled.

## Out of scope

- C2b: `KaiForkCard`/`KaiForkChip`/`KaiForkScoreDots`, `KaiKaraokeText`,
  `KaiTranscriptView`, `KaiBudgetBar`.
- C3: onboarding step-indicator atom, nav-panel chrome removal, EdgeStateBlock button swap,
  final tide-anim default.
