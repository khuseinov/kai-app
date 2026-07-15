# Interaction Refinements — Cycle 3 — Design

**Date:** 2026-05-30 · **Branch:** `master` · **Status:** design approved (scope) — pending spec review
**Cycle:** 3 (final of the C1–C3 arc). Small refinements to production screens + one new atom.

## Context

Cycles 1–2 rebuilt the Storybook and extended/added components. The live review left four
interaction/chrome refinements on production screens, plus finalising the tide-button
animation default. This cycle delivers them. It touches production organisms (onboarding,
nav, edge-state) — additive/behavioural, kept backward-compatible where possible. 833 tests
green going in.

## Locked decisions

- **Onboarding step-0 button:** default **not tide** — ink at rest, the tide gradient
  flashes **after tap** as confirmation, then the step advances.
- **EdgeStateBlock:** replace the rate-limit `KaiButton.tide(emphasis: glow)` with
  `KaiButton.ghost` + an appropriate `tone` (the tide button is too heavy for an edge state).
- **Nav panel:** remove the top-bar **close (X) button + "kai" title**; the panel closes by
  swipe-left (already wired via `onClose`).
- **Tide animation default:** `KaiButton.tide` already defaults to `KaiTideAnim.onInteraction`
  — that is the **final default** (works for any primary CTA; `onState`/`busy` remains
  available for send/streaming contexts). No code change; document + drop the story's
  "compare" framing to show `onInteraction` as canonical (keep `onState` as a labelled
  example).

## Changes

### 1. New atom: `KaiStepIndicator` — `lib/design_system/atoms/kai_step_indicator.dart`
Extract the onboarding `_StepDots` into a reusable animated atom. API:
`KaiStepIndicator({required int count, required int active})`. Renders `count` dots; the
`active` dot is an elongated accent pill, others are small `ink4`/`line` dots. **Animate the
transition**: when `active` changes, the active pill smoothly slides/resizes
(`AnimatedContainer`/`AnimatedAlign` with `KaiMotion.standard` + `standardCurve`; reduced
motion → instant). Tokens only. Story in `atom_stories.dart` with an interactive stepper demo.

### 2. Onboarding step-0 button → ink, tide-after-tap
`lib/design_system/organisms/kai_onboarding_card.dart`: `_buildCTA` step 0 currently uses
`KaiButton.tide`. Change to: at rest a `KaiButton.ink` (or ghost) labelled "Start"; on tap,
play a brief tide-flash confirmation, then call the step callback. Implement as a small
private stateful CTA (`_Step0Cta`) that crossfades/overlays the tide gradient for ~`KaiMotion.standard`
on tap, then invokes `onNext`/`onComplete`. Reduced motion → no flash, immediate advance.
Steps 1–3 unchanged (ink). Replace the internal `_StepDots` usage with the new
`KaiStepIndicator` (so the dot transition animates between steps).

### 3. EdgeStateBlock rate-limit CTA → ghost+tone
`lib/design_system/organisms/kai_edge_state_block.dart`: the rate-limit/upgrade CTA at
~line 263 (`KaiButton.tide(emphasis: KaiButtonEmphasis.glow)`) → `KaiButton.ghost(tone:
KaiButtonTone.accent, ...)` (accent reads as an actionable upsell without the heavy tide;
pill optional to match the retry pills). Keep the offline retry (`ghost`, warning, pill) and
the crisis care-block as-is. Update the doc comment that referenced the glow canon.

### 4. Nav panel — remove top-bar X + title
`lib/design_system/organisms/kai_nav_panel.dart`: remove the top bar's close-circle
(`KaiIconName.close`), the centred title ("kai"), and the balancing 28px spacer (the
`_NavTopBar`/header around lines 340–390). Keep `onClose` (driven by the existing swipe-left
`onHorizontalDragEnd`). The first visible content becomes the "new chat" button / search.
Update the class doc that described the top bar.

## File map

**Create:** `lib/design_system/atoms/kai_step_indicator.dart` (+ export in `atoms/atoms.dart`),
test `test/design_system/atoms/kai_step_indicator_test.dart`, story in `atom_stories.dart`.
**Modify:** `kai_onboarding_card.dart` (step-0 CTA + use KaiStepIndicator),
`kai_edge_state_block.dart` (ghost CTA), `kai_nav_panel.dart` (remove top bar) + their tests
+ their stories. KaiButton tide story: mark `onInteraction` as default (doc only).

## Build sequence (TDD; SDD batch)

1. `KaiStepIndicator` atom — test (active pill at index; animates on change) → implement →
   analyze → test → commit.
2. Onboarding — step-0 `_Step0Cta` (ink→tide-flash→advance) + swap `_StepDots`→`KaiStepIndicator`;
   update onboarding test (step-0 starts ink, advances on tap) → commit.
3. EdgeStateBlock — rate-limit CTA → ghost(accent); update test/story → commit.
4. NavPanel — remove top-bar X/title/spacer; update test (no close icon; swipe still closes) →
   commit.
5. Tide story doc tweak (onInteraction default) → commit (may fold into #1).

Each step: `flutter analyze` clean + `flutter test` green.

## Acceptance criteria

- `flutter analyze` "No issues found"; `flutter test` green (≥833 + new tests).
- `KaiStepIndicator` is a reusable atom with an animated active transition; onboarding uses it.
- Onboarding step-0 CTA is ink at rest and flashes tide on tap before advancing (reduced
  motion → immediate, no flash).
- EdgeStateBlock rate-limit CTA is a ghost button (no tide glow); offline retry + crisis
  unchanged.
- Nav panel has no X button and no "kai" title; swipe-left still closes it; new-chat/search
  is the top content.
- Tide default documented as `onInteraction`.

## Out of scope

- Assembling the unbuilt screens (voice/memory/trip-detail/fork) — later.
- Doc refresh (COMPONENTS.md / CLAUDE.md for C1–C3) — separate housekeeping pass.
