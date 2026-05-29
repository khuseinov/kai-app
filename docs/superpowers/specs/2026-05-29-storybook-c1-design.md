# Storybook Redesign — Cycle 1 (tool + cross-cutting fixes + tide variants) — Design

**Date:** 2026-05-29 · **Branch:** `master` · **Status:** design approved — pending spec review
**Cycle:** 1 of 3. C2 = component variant expansion + new molecules. C3 = interaction atoms + decisions.

## Context

The v3 design system is built, migrated, and live (681 tests green). A live review of
`/_dev/storybook` surfaced that the Storybook **tool itself** is not usable as a design
reference: components are dumped top-to-bottom in a plain scroll, the props panel only
appears at ≥1100px (so it reads as "missing"), there is no colour palette / typography /
token reference, the dark-theme toggle leaves gaps, and several components render
confusingly in isolation (toast action button looks huge, input `pill` looks like a broken
half-round shape, TideCurve's ephemeral states play once then vanish). The user also wants
to compare two candidate behaviours for the "living tide" button animation.

This cycle fixes the **tool** and the **cross-cutting bugs**, and builds the **two tide
animation variants** for live comparison. It does NOT add new component variants or new
molecules (that is Cycle 2) — it reformats the *existing* components into a beautiful,
informative Storybook.

## Goal

Turn `/_dev/storybook` into a real Storybook/Figma-style reference: 3-pane adaptive shell
(searchable sidebar · structured canvas · always-available inspector), a Foundations group
(colours/type/spacing/motion/tide), a reusable `StoryPage` structure that makes every
component block self-explanatory (variants in labelled cells + states + usage + props), the
five cross-cutting bug fixes, and two switchable tide-button animation behaviours — with
`flutter test` green and `flutter analyze` clean.

## Locked decisions (brainstorming)

- **Decomposition:** C1 → C2 → C3 sequentially; each its own spec→plan→SDD.
- **Tide animation:** build **two** variants for live comparison — **A `onInteraction`**
  (idle static → hover/press starts the gradient flow) and **B `onState`** (static; flows
  only while `sending`/`streaming` — reflects Kai activity). Final default chosen in C3.
- **Onboarding step-0 button** (C3): default ink/ghost → tide flashes **after tap**.
- **EdgeStateBlock** (C3): replace tide button with **`KaiButton.ghost` + tone + pill**.

## Architecture

### Storybook shell (`lib/features/dev/storybook/`)

Three panes via `LayoutBuilder`:
- **Sidebar (left, ~260px):** search box (filters `kStories` by name) + component tree
  grouped by `StoryLayer` (Foundations · Primitives · Atoms · Molecules · Organisms),
  active row highlighted. Narrow (<720px) → Drawer.
- **Canvas (center):** renders the active story via the new `StoryPage` structure (below),
  inside a scroll view; device-frame + background-surface knobs apply here.
- **Inspector (right, ~280px):** import path, canon file+selector, description, variants,
  props table. **Always available** — on wide it is a fixed column (drop the 1100px gate so
  it shows alongside sidebar+canvas; if all three don't fit, collapse the sidebar to icons
  before hiding the inspector); on narrow it is a toggle button → bottom sheet (never
  silently absent).

**Knobs bar (AppBar actions):**
- **Theme:** a live `KaiSegmentedControl` `[Light · Dark · System]` bound to
  `themeModeProvider` (fixes "segmented must switch theme" + dogfoods the component).
- **Device frame:** phone 390px ↔ full-width.
- **Background surface:** bg / surface / surface2 (test components on different grounds).

### Story structure (new dev-only widgets, `storybook/story_page.dart`)

```
StoryPage(
  title, layer, blurb,          // header: name + layer chip + one-line "what is this"
  sections: [
    StorySection('Variants', [StoryCell(label, child), ...]),  // responsive Wrap of
    StorySection('States',   [StoryCell(label, child), ...]),  //   labelled bordered cells
  ],
  usage:  '<constructor snippet>',
  props:  [PropDoc(name, type, def, desc), ...],   // table; mirrored in Inspector
)
```

`Story` (in `story_registry.dart`) keeps `layer/name/importPath/canonFile/canonSelector/
description/variants/build`; `build` now returns a `StoryPage`. `props` is added to `Story`
so the inspector + the page table share one source.

### Foundations stories (`storybook/foundations_stories.dart`)

New `StoryLayer.foundations` (ordered first). Stories: **Colors** (full palette from
`foundations.html` — name+hex swatches, light/dark side-by-side, semantic, tide gradient),
**Typography** (10 styles as a table: sample · token · px/weight/family/use), **Spacing &
Radius** (visual scales), **Motion** (3 buckets, live demos), **Tide** (8 states + 2
gradients).

### Cross-cutting fixes

| # | Fix | Where |
|---|-----|-------|
| F1 | Dark theme gaps: audit shell + every story for hardcoded colours / tokens read outside the themed subtree; route all through `KaiTheme.of(context).colors`; verify canvas re-resolves on toggle | shell + `story_registry.dart` |
| F2 | TideCurve demo: show all 8 states each in its own continuously-looping cell (loop ephemeral states in the demo, per `tide-states.html`) | TideCurve story (+ a `demoLoop`/replay hook on `KaiTideCurve` only if needed) |
| F3 | Toast: constrain to natural pill width in its story cell so the action button reads correctly | Toast story |
| F4 | Input `pill`: render inside a compose-context cell + label it "compose-island field"; document why standalone looks odd | Input story |
| F5 | SegmentedControl: the knobs theme switcher is a live `KaiSegmentedControl` | shell |

### Two tide animation variants (`lib/design_system/atoms/kai_button.dart`)

Replace the current always-on ambient flow with a parameter:
`KaiButton.tide({..., KaiTideAnim tideAnim = KaiTideAnim.onInteraction})`
- `KaiTideAnim.onInteraction` — static at rest; gradient flow (ambient sweep) runs while
  hovered/pressed; respects `MediaQuery.disableAnimations`.
- `KaiTideAnim.onState` — static; flow runs only when the button is in a "busy" context.
  Since `KaiButton` is stateless about Kai, expose a `busy` bool the caller sets (the send
  button / compose island drive it); when `busy` true the flow runs.
- `KaiTideAnim.none` — always static (for reduced-motion / tests).
The KaiButton story shows A and B side-by-side with captions for live comparison. Default
stays `onInteraction` pending the C3 decision. Dispose controllers; reduced-motion → static.

## File map

**New:** `storybook/story_page.dart` (StoryPage/StorySection/StoryCell/PropDoc + table),
`storybook/foundations_stories.dart` (5 foundations stories).
**Modify:** `storybook/storybook_screen.dart` (3-pane + search + knobs bar with segmented
theme switch + always-available inspector), `storybook/story_registry.dart` (add
`foundations` layer + `props` field; reformat all existing stories into `StoryPage`; apply
F2–F4 per-story fixes), `lib/design_system/atoms/kai_button.dart` (`KaiTideAnim` enum +
`tideAnim`/`busy` params, replace always-on flow), `kai_button` test (new params).

## Build sequence (TDD where it fits)

1. `story_page.dart` structure widgets + `PropDoc` table (widget tests: renders cells,
   props table).
2. `KaiButton` tide-anim refactor: `KaiTideAnim` enum + `tideAnim`/`busy`; tests for each
   mode (onInteraction static-at-rest, onState flows when busy, none static,
   disableAnimations → static); analyze.
3. Shell rebuild: 3-pane + search + knobs (segmented theme switch, device, background) +
   always-available inspector. Smoke tests at wide/narrow.
4. Foundations stories (colors/type/spacing/motion/tide).
5. Reformat existing stories into `StoryPage` + apply F2–F4 (TideCurve loop, toast width,
   input context) + add `props`.
6. Dark-theme audit pass (F1) across shell + all stories; manual toggle verification.
7. Revert the dev-only `initialLocation: '/_dev/storybook'` in `router.dart` back to `'/'`
   (it was a temporary aid).

## Acceptance criteria / verification

- `flutter analyze` → "No issues found"; `flutter test` green (≥681, plus new dev tests).
- Inspector visible/ reachable at every width (never silently absent).
- Foundations group present with Colors/Type/Spacing/Motion/Tide.
- Every story renders via `StoryPage` with labelled variant cells + states + usage + props.
- Theme switch via the segmented control flips **all** elements (no dark-theme gaps) — manual
  toggle check on every story group.
- TideCurve story shows all 8 states animating continuously; toast + input read correctly.
- KaiButton tide story shows variant A and B side-by-side, both behaving per spec; reduced
  motion → static.
- `router.dart` `initialLocation` restored to `'/'`.

## Out of scope (later cycles)

- C2: new component variants, `KaiForkCard`/`ForkChip`/`ScoreDots`, `KaiKaraokeText`,
  `KaiTranscriptView`, `KaiBudgetBar`, GradientBar state variants, chip `.small`, toggle
  positive-tone, avatar animation/variants, account-hero variants, compose-island variants.
- C3: onboarding step-indicator atom + step-0 button trigger, nav-panel chrome removal
  (X + "kai"), EdgeStateBlock button swap, final tide-anim default.
