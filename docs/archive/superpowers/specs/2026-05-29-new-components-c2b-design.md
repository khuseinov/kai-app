# New Components — Cycle 2b — Design

**Date:** 2026-05-29 · **Branch:** `master` · **Status:** design approved — pending spec review
**Cycle:** 2b. Builds the 6 components the unbuilt screens (fork / voice / trip-detail) need,
as reusable widgets shown in Storybook — replacing the current canon-preview placeholders.

## Context

Cycle 1 documented (in `lib/design_system/COMPONENTS.md`, "Screens not yet built") the
Playwright-verified canon for four unbuilt screens, and Storybook currently shows them as
static "(canon)" spec-preview placeholders. The user chose to build the reusable components
now (not wait for the screens). This cycle creates 6 components from the fork / voice /
trip-detail canon and swaps the placeholders for live stories. The screens themselves
(assembling these) remain out of scope — a later cycle.

## Goal

Build 6 token-driven, dark-safe components matching the `new-design/` canon, each with a
Storybook story, replacing the canon-preview placeholders — `flutter test` green, `analyze`
clean.

## Layering decision

Leaf presentational widgets are **atoms**; composing widgets are **molecules**:
- Atoms: `KaiForkChip`, `KaiForkScoreDots`, `KaiBudgetBar`, `KaiKaraokeText`.
- Molecules: `KaiForkCard` (composes ForkChip + ForkScoreDots + KaiText + KaiAvatar),
  `KaiTranscriptView` (composes timestamped events).

## Components (canon values from COMPONENTS.md / `new-design/`)

### 1. KaiForkChip (atom) — `lib/design_system/atoms/kai_fork_chip.dart`
Tiny visa-status pill. Canon `fork.html .fc-chip`: 8px/w600 Manrope, `KaiRadius.brPill`,
padding 2/6. `enum KaiForkChipTone { bad, neutral, ok }`:
- `bad` → text `negative`, bg `negativeWash`.
- `neutral` → text `ink3`, bg `surface3`.
- `ok` → text `positive`, bg `positiveWash`.
API: `KaiForkChip(String label, {KaiForkChipTone tone = neutral})`.

### 2. KaiForkScoreDots (atom) — `lib/design_system/atoms/kai_fork_score_dots.dart`
A row of 5×5px rating dots. Canon `fork.html .fc-score`: filled dots = `positive`,
empty = `surface3`. API: `KaiForkScoreDots({required int score, int max = 5, Color? fillColor})`
— renders `max` dots, first `score` filled (default `positive`), rest `surface3`. 5×5px,
gap ~3px.

### 3. KaiBudgetBar (atom) — `lib/design_system/atoms/kai_budget_bar.dart`
Segmented budget progress bar. Canon `trip-detail.html .budget-bar`: `KaiRadius.brPill`
track `surface3`, coloured segments. API: `KaiBudgetBar({required List<KaiBudgetSegment> segments, double height = 8})`
where `class KaiBudgetSegment { final double fraction; final Color color; final String label; }`.
Renders a pill track with proportional coloured segments (Row of flex-weighted coloured
boxes, rounded ends). Optional legend row below (label + colour swatch + value).

### 4. KaiKaraokeText (atom) — `lib/design_system/atoms/kai_karaoke_text.dart`
Word-level reveal for voice mode. Canon `voice.html .karaoke`: 16px/w500 white; the current
("now") word has bg `tide-3 @ 0.28` (`Color(0x47F4B589)`), `KaiRadius.br1` (≈r4), pad 1/5;
upcoming ("next") words are white @ 0.32 (`Color(0x52FFFFFF)`); spoken words full white.
**Always-dark context** — colours are fixed white/tide (NOT theme tokens, like voice.html
`#08080A`). API: `KaiKaraokeText({required List<String> words, required int currentIndex})`
— words before `currentIndex` = spoken (full white), at = now (highlighted), after = next
(dim). Document that this is a dark-surface-only widget.

### 5. KaiForkCard (molecule) — `lib/design_system/molecules/kai_fork_card.dart`
In-chat 2-column country comparison. Canon `fork.html .fc`. Composes: per column a
`KaiAvatar`/glyph + country name (`KaiText`), a price row, data rows each with a
`KaiForkChip` (visa status) + `KaiForkScoreDots` (rating), and a "Kai's pick" badge
(`fc-badge`, accent) on the winning column. API:
`KaiForkCard({required List<KaiForkColumn> columns, int? pickIndex})` with
`class KaiForkColumn { final String name; final String glyph; final String price; final List<KaiForkRow> rows; }`
and `class KaiForkRow { final String label; final String value; final KaiForkChipTone? chipTone; final String? chipLabel; final int? score; }`.
Surface card (`surface`, `KaiRadius.br4`, border `line`). The picked column gets an accent
highlight + badge.

### 6. KaiTranscriptView (molecule) — `lib/design_system/molecules/kai_transcript_view.dart`
Voice transcript timeline. Canon `voice.html .tr-view`: dark; events padding 9/22/9/52;
timestamp 8.5px white@0.4; who-label; speaker rows (you / kai). **Always-dark context.**
API: `KaiTranscriptView({required List<KaiTranscriptEvent> events})` with
`class KaiTranscriptEvent { final String who; /* 'you'|'kai' */ final String text; final String timestamp; }`.
Renders a vertical list; `kai` events may show the tide who-glyph. Fixed dark palette.

## File map

**Create (atoms):** `kai_fork_chip.dart`, `kai_fork_score_dots.dart`, `kai_budget_bar.dart`,
`kai_karaoke_text.dart`. **Create (molecules):** `kai_fork_card.dart`, `kai_transcript_view.dart`.
**Modify barrels:** `atoms/atoms.dart`, `molecules/molecules.dart` (add exports).
**Modify stories:** in `lib/features/dev/storybook/stories/` replace the 4 canon-preview
stories (Voice/Fork/TripDetail — Memory stays a screen-level preview, no new component) with
real-component stories: a Fork story group (ForkChip/ForkScoreDots/ForkCard), a Voice group
(KaraokeText/TranscriptView on a dark cell), a BudgetBar story. Keep `_story_helpers.dart`
canon-preview widgets only where no real component replaces them (Memory). Tests under
`test/design_system/{atoms,molecules}/`.

## Build sequence (TDD; SDD batches)

- **Batch 1 — fork family:** KaiForkChip → KaiForkScoreDots → KaiForkCard (card composes the
  first two). Sub-commit each + stories.
- **Batch 2 — voice family:** KaiKaraokeText → KaiTranscriptView (both always-dark; story
  cells use a dark background container). Sub-commit each + stories.
- **Batch 3 — budget:** KaiBudgetBar + story. Then swap the canon-preview stories to the real
  components and remove now-dead preview widgets from `_story_helpers.dart` where replaced.

Each component: test → implement → `analyze` clean → `flutter test` green → commit.

## Acceptance criteria

- `flutter analyze` "No issues found"; `flutter test` green (≥762 + new tests).
- Each component matches canon values (ForkChip 8px tones; ScoreDots 5px; KaraokeText
  now/next/spoken; BudgetBar segments; ForkCard 2-col + pick; TranscriptView dark timeline).
- Storybook shows each as a real StoryPage; Fork/Voice/Budget placeholders replaced.
- Always-dark components (KaraokeText, TranscriptView) documented as dark-surface-only and
  render correctly on a dark cell regardless of app theme.

## Out of scope

- The actual voice / fork / trip-detail / memory SCREENS (assembly) — later cycle.
- C3: onboarding step-indicator, nav chrome removal, EdgeStateBlock button swap, final tide.
