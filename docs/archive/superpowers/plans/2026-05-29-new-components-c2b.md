# New Components C2b Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: superpowers:subagent-driven-development.

**Goal:** Build 6 new canon-grounded components + Storybook stories, replacing the unbuilt-screen canon-preview placeholders.

**Spec (per-component APIs + canon values — implementers READ it):** `docs/superpowers/specs/2026-05-29-new-components-c2b-design.md`. Canon detail also in `lib/design_system/COMPONENTS.md` ("Screens not yet built").

**Conventions:** const-correct; theme colours via `KaiTheme.of(context).colors` EXCEPT the two always-dark voice widgets (KaiKaraokeText, KaiTranscriptView) which use fixed white/tide literals by design (document this); animations respect `disableAnimations`; reuse `buildTestWidget`; after each component `flutter analyze` clean + `flutter test` green. Add exports to `atoms/atoms.dart` / `molecules/molecules.dart`. Do NOT touch pre-existing dirty files. Trailer: `Co-Authored-By: Claude Opus 4.8 (1M context) <noreply@anthropic.com>`.

---

## Batch 1 — fork family (one implementer, 3 sub-commits, in order)

### Task 1.1: KaiForkChip (atom)
- [ ] Create `lib/design_system/atoms/kai_fork_chip.dart`: `KaiForkChip(String label, {KaiForkChipTone tone = neutral})` + `enum KaiForkChipTone { bad, neutral, ok }`. 8px/w600, `KaiRadius.brPill`, pad 2/6. bad→negative/negativeWash; neutral→ink3/surface3; ok→positive/positiveWash. Export from atoms barrel.
- [ ] Test `test/design_system/atoms/kai_fork_chip_test.dart`: each tone → right text colour + bg; label renders.
- [ ] analyze + test + commit `feat(ds): KaiForkChip visa-status pill`.

### Task 1.2: KaiForkScoreDots (atom)
- [ ] Create `kai_fork_score_dots.dart`: `KaiForkScoreDots({required int score, int max = 5, Color? fillColor})`. Row of `max` 5×5px dots (gap ~3); first `score` filled (`fillColor ?? positive`), rest `surface3`. Export.
- [ ] Test: score=3,max=5 → 3 filled + 2 empty (count by decoration colour).
- [ ] analyze + test + commit `feat(ds): KaiForkScoreDots rating row`.

### Task 1.3: KaiForkCard (molecule)
- [ ] Create `lib/design_system/molecules/kai_fork_card.dart` + data classes `KaiForkColumn{name,glyph,price,rows}` / `KaiForkRow{label,value,chipTone?,chipLabel?,score?}`. `KaiForkCard({required List<KaiForkColumn> columns, int? pickIndex})`. Surface card (`surface`, br4, line border); 2 columns; each column header (glyph/KaiAvatar + name + price), then rows (label + value + optional `KaiForkChip` + optional `KaiForkScoreDots`); picked column gets accent highlight + "Kai's pick" badge. Compose KaiForkChip + KaiForkScoreDots + KaiText. Export.
- [ ] Test: renders 2 columns + names + a chip + dots; pickIndex column shows the badge.
- [ ] analyze + test + commit `feat(ds): KaiForkCard 2-column comparison`.

---

## Batch 2 — voice family (one implementer, 2 sub-commits) — ALWAYS DARK

### Task 2.1: KaiKaraokeText (atom)
- [ ] Create `kai_karaoke_text.dart`: `KaiKaraokeText({required List<String> words, required int currentIndex})`. 16px/w500. Words < currentIndex = full white `Color(0xFFFFFFFF)`; == = "now" (white text, bg `Color(0x47F4B589)` = tide-3@0.28, `KaiRadius.br1`, pad 1/5); > = "next" `Color(0x52FFFFFF)` (white@0.32). Render via `Wrap`/`RichText`. Doc: dark-surface-only (fixed colours, not theme tokens — canon voice.html #08080A). Export.
- [ ] Test: now word has the tide-3 highlight bg; next words dimmed; spoken full white.
- [ ] analyze + test + commit `feat(ds): KaiKaraokeText voice word-reveal (dark-only)`.

### Task 2.2: KaiTranscriptView (molecule)
- [ ] Create `kai_transcript_view.dart` + `class KaiTranscriptEvent { final String who; final String text; final String timestamp; }`. `KaiTranscriptView({required List<KaiTranscriptEvent> events})`. Dark timeline; event pad 9/22/9/52; timestamp 8.5px white@0.4 (`Color(0x66FFFFFF)`); `kai` events show the tide who-glyph (KaiGradientBar). Fixed dark palette. Export.
- [ ] Test: renders each event's text + timestamp; you vs kai distinguished.
- [ ] analyze + test + commit `feat(ds): KaiTranscriptView voice timeline (dark-only)`.

---

## Batch 3 — budget + story swap (one implementer, 2 sub-commits)

### Task 3.1: KaiBudgetBar (atom)
- [ ] Create `kai_budget_bar.dart` + `class KaiBudgetSegment { final double fraction; final Color color; final String label; }`. `KaiBudgetBar({required List<KaiBudgetSegment> segments, double height = 8})`. Pill track `surface3`; proportional coloured segments (flex Row, rounded ends); optional legend row (swatch + label). Export.
- [ ] Test: segments render proportional widths; track is surface3.
- [ ] analyze + test + commit `feat(ds): KaiBudgetBar segmented budget bar`.

### Task 3.2: Storybook — swap canon previews for real components
- [ ] In `lib/features/dev/storybook/stories/` add real stories: Fork group (KaiForkChip / KaiForkScoreDots / KaiForkCard), Voice group (KaiKaraokeText / KaiTranscriptView — each in a dark `Container(color: Color(0xFF08080A))` cell), KaiBudgetBar. Place the leaf ones in `atom_stories.dart`, ForkCard/TranscriptView in `molecule_stories.dart`.
- [ ] Replace the Fork/Voice/TripDetail "(canon)" placeholder stories in `organism_stories.dart` with pointers to the real component stories (or remove them); keep Memory as a screen-level canon preview (no single component). Remove now-dead preview widgets from `_story_helpers.dart` where a real component replaced them (keep `MemoryCanonPreview` + `SpecSection`/`SpecNote` if still used).
- [ ] analyze + test + commit `refactor(storybook): real Fork/Voice/Budget stories replace canon placeholders`.

---

## Verification
- `flutter analyze` "No issues found" + `flutter test` green at every sub-commit.
- Each component matches canon; always-dark voice widgets render on dark cells.
- Storybook shows the 6 as real StoryPages; Fork/Voice/Budget placeholders gone (Memory placeholder may remain).

## Self-review
Spec coverage: all 6 components + story swap have tasks ✓. Types consistent (KaiForkChipTone, KaiForkColumn/Row, KaiBudgetSegment, KaiTranscriptEvent) between spec + plan ✓. Always-dark exception explicit ✓. No placeholders ✓.
