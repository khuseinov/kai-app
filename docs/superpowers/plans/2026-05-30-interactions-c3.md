# Interaction Refinements C3 Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: superpowers:subagent-driven-development.

**Goal:** 4 production-screen interaction refinements + 1 new animated atom.

**Spec (detail — implementers READ it):** `docs/superpowers/specs/2026-05-30-interactions-c3-design.md`.

**Conventions:** const-correct; colours via `KaiTheme.of(context).colors`; animations respect `MediaQuery.disableAnimations` (→ instant) + dispose controllers; reuse `buildTestWidget`. These touch PRODUCTION organisms — run the FULL suite after each step (the migrated screens have tests). Do NOT touch pre-existing dirty files. Trailer: `Co-Authored-By: Claude Opus 4.8 (1M context) <noreply@anthropic.com>`.

---

## Task 1: KaiStepIndicator (new atom)
- Files: create `lib/design_system/atoms/kai_step_indicator.dart` + export in `atoms/atoms.dart`; test `test/design_system/atoms/kai_step_indicator_test.dart`; story in `lib/features/dev/storybook/stories/atom_stories.dart`.
- [ ] `KaiStepIndicator({required int count, required int active, super.key})`. Render a `Row` of `count` dots; the `active` one is an elongated accent pill (e.g. width 16 vs 6 for inactive, height 6, `KaiRadius.brPill`); inactive dots `c.ink4` (or `c.line`), active `c.accent`. Animate transitions with `AnimatedContainer(duration: KaiMotion.standard, curve: KaiMotion.standardCurve)` per dot (width + colour) so moving `active` slides smoothly; reduced motion → `Duration.zero`.
- [ ] Test: with active=1, the dot at index 1 is the accent pill (wider + accent colour), others are small/ink4; changing active rebuilds without throw.
- [ ] Story: an interactive `_StepperDemo` (a StatefulWidget with prev/next buttons cycling `active` 0..3) so the animation is visible.
- [ ] analyze + FULL test + commit `feat(ds): KaiStepIndicator animated step dots`.

## Task 2: Onboarding — step-0 ink→tide-after-tap + use KaiStepIndicator
- Files: `lib/design_system/organisms/kai_onboarding_card.dart`, its test, its story.
- [ ] Replace the internal `_StepDots(count: 4, active: stepIndex)` with `KaiStepIndicator(count: 4, active: stepIndex)`. Remove the now-dead `_StepDots`.
- [ ] `_buildCTA` step 0: instead of `KaiButton.tide`, render a private `_Step0Cta(label, onPressed)` stateful widget: at rest shows `KaiButton.ink(label, onPressed: _handleTap)`; on tap it plays a brief tide-gradient flash (overlay a `KaiTide.gradient` container crossfading in over the button for `KaiMotion.standard`), then calls the real callback (`onNext`). Reduced motion (`disableAnimations`) → skip the flash, call callback immediately. Dispose any controller. Steps 1–3 stay `KaiButton.ink` unchanged.
- [ ] Update the class doc comment (step-0 is now ink-with-tide-flash, not tide-default).
- [ ] Test: step 0 renders a `KaiButton.ink` (not a tide button) at rest; tapping it eventually fires `onNext` (pump past the flash duration). Steps 1–3 unchanged. Existing onboarding_screen test still green.
- [ ] analyze + FULL test + commit `feat(ds): onboarding step-0 ink→tide-flash + KaiStepIndicator`.

## Task 3: EdgeStateBlock — rate-limit CTA ghost+tone
- Files: `lib/design_system/organisms/kai_edge_state_block.dart`, its test, its story.
- [ ] Replace the rate-limit/upgrade CTA `KaiButton.tide(emphasis: KaiButtonEmphasis.glow)` (~line 263) with `KaiButton.ghost(label: ..., onPressed: ..., tone: KaiButtonTone.accent)` (pill optional to match retry style). Keep the offline retry (ghost/warning/pill) and crisis care-block unchanged. Update the doc comment that referenced the money-gate glow canon.
- [ ] Test: the rate-limit surface renders a `KaiButton` that is NOT tide/glow (assert no glow / it's the ghost variant — e.g. find KaiButton and check it's not the gradient one, or assert the CTA label renders within a ghost-style button). Keep existing edge-state tests green.
- [ ] Story (EdgeStateBlock in organism_stories.dart): rate-limit cell now shows the ghost CTA.
- [ ] analyze + FULL test + commit `fix(ds): EdgeStateBlock rate-limit CTA tide→ghost(accent)`.

## Task 4: NavPanel — remove top-bar X + "kai" title
- Files: `lib/design_system/organisms/kai_nav_panel.dart`, its test, its story.
- [ ] Remove the top-bar widget (the `_NavTopBar`/header around lines 340–390: the close-circle using `KaiIconName.close`, the centred title "kai"/"Kai", and the 28px balancing spacer). The panel's first visible content becomes the new-chat button / search. Keep the `onClose` field + the swipe-left `onHorizontalDragEnd` that calls it. If `onClose` becomes otherwise-unused as a tapped affordance, that's fine — it's still the swipe handler.
- [ ] Update the class doc comment (no top bar; closes by swipe-left).
- [ ] Test: nav panel renders WITHOUT a close icon (`KaiIconName.close`) and without a "kai" title text; swipe-left still triggers `onClose` (simulate `drag` with negative velocity OR assert the GestureDetector wiring). Keep existing nav_panel + nav_screen tests green (update any that asserted the close button / title presence).
- [ ] analyze + FULL test + commit `feat(ds): nav panel — remove X + title, swipe-close only`.

## Task 5: Tide default doc tweak
- Files: KaiButton tide story in `atom_stories.dart` (+ optional doc line in `kai_button.dart`).
- [ ] In the KaiButton story, relabel the "Tide animation (compare)" section so `onInteraction` reads as the default/canonical and `onState` as the busy-context example. Optional: a one-line doc note in `kai_button.dart` that `onInteraction` is the default. No behavioural change.
- [ ] analyze + FULL test + commit `docs(ds): tide animation default = onInteraction`.

---

## Verification
- `flutter analyze` "No issues found" + `flutter test` green at every commit (production screens — watch onboarding/nav/edge screen tests).
- All spec acceptance criteria met.

## Self-review
Spec coverage: 4 refinements + new atom + tide-default all have tasks ✓. Types: `KaiStepIndicator(count, active)`, `KaiButtonTone.accent`, `KaiTideAnim.onInteraction` consistent with existing code ✓. No placeholders ✓. Reduced-motion paths specified ✓.
