# Handoff — Storybook component review (fixes + compose-island redesign + canon re-audit)

**Date:** 2026-05-30 · **Branch:** `master` · **For:** a fresh agent in a new session.
**Status going in:** 838 tests green, `flutter analyze` clean. Design system flat at
`lib/design_system/` (3 primitives / 17 atoms / 18 molecules / 4 organisms). Live Storybook
at `/_dev/storybook`. This handoff is a prompt/context — read it fully, then orient yourself
from the repo before changing anything.

---

## 0. How to orient (do this first)

1. Read `CLAUDE.md` (project rules) and `lib/design_system/COMPONENTS.md` (the agent-facing
   canon→Dart index — single source of truth for every component's API + canon mapping).
2. **MANDATORY design toolchain (CLAUDE.md §0):** all design verification goes through
   **Playwright MCP + `spec-viewer.html`**, never eyeballed from raw HTML. Start the static
   server, then drive spec-viewer:
   - `cd new-design && python -m http.server 8743` (Python may be absent → use a Node static
     server on `127.0.0.1:8743`; the previous sessions used a tiny `node -e` http server).
   - Navigate Playwright to `http://127.0.0.1:8743/spec-viewer.html`; the loader function is
     `loadScreen('<file>.html', '<label>')`; computed styles come from the iframe DOM
     (`getComputedStyle`), which is more reliable than the inspector's genFlutter mapping.
   - For bulk extraction: inject each HTML file into a hidden iframe and read computed styles
     of the canon selectors (this is how the existing COMPONENTS.md values were gathered).
3. See the components live: temporarily set `initialLocation: '/_dev/storybook'` in
   `lib/core/routing/router.dart`, `flutter run -d chrome --web-port 8744`, open
   `http://localhost:8744` (revert the router edit when done — it's a dev aid, never commit it).
4. **Process:** this is creative/design work → use `brainstorming` → `writing-plans` →
   `subagent-driven-development` (the established flow this project uses). Tokens only
   (`KaiTheme.of(context).colors.*`, `KaiType/KaiSpace/KaiRadius/KaiMotion/KaiTide/KaiShadow`),
   no hardcoded colours/padding outside token files; const-correct; reduced-motion → static;
   every change keeps `flutter analyze` clean + `flutter test` green; sub-commit per component.

---

## 1. The review (verbatim intent — preserve meaning)

The user reviewed the live Storybook and flagged these. Treat each as a requirement.

### R1 — KaiBadge: variants are far too large
The three badge variants render **huge — they fill the screen** in the Storybook. The badge
itself is meant to be tiny (dot 6–8px, count pill ~16px). Likely the **story cell** scales
them up, or a variant has wrong intrinsic sizing. Fix so badges render at their true small
size (verify dot ≈6–8px, count ≈16px, tide dot ≈8px) and the story shows them at real scale.
Component: `lib/design_system/atoms/kai_badge.dart`; story in
`lib/features/dev/storybook/stories/atom_stories.dart`. Re-check against canon (nav memory dot
in `nav.html`, count usage).

### R2 — KaiComposeIsland: offline state unclear + needs new island variants + typing logic
- The **offline** mode is confusing and looks janky ("стрёмно выглядит") — redesign it so it
  reads clearly as "offline" (calm, not alarming; coral is the error token but offline is more
  a muted/disabled state — decide via canon `edge-states.html` offline strip + `room.html`).
- **Add new island variants.** The user wants a richer compose island family:
  - a variant with: **mic + push(send)-text + voice-Kai + an "add elements" (+) button**;
  - another variant with: **"add elements" (+) + mic + voice-Kai**.
- **Typing-driven state machine (the user's core idea — refine it):**
  - Default (empty field): island shows **[+ / input field] + mic + voice-Kai**.
  - When the user **starts typing**: the **mic disappears** and a **push/send button appears**
    in its place.
  - When the field is **empty again**: the mic returns.
  - i.e. mic ⇄ send swap is driven by text-presence (mic when empty, send when typing).
- **Your job (next agent):** think through this logic and the visual design, *refine the
  user's idea*, AND *propose a new/alternative idea* (e.g. how "+ add elements", voice-Kai,
  mic, and send coexist without crowding the pill; what "voice-Kai" affordance looks like; how
  offline/disabled/voice modes compose with the typing swap). Present options in brainstorming
  and let the user choose before building. Canon refs: `room.html` (compose-island frames:
  empty / typing / streaming), `voice.html` (voice entry), `components.html` `.compose`.
  Component: `lib/design_system/molecules/kai_compose_island.dart` (currently has
  `KaiComposeMode { standard, voice, offline }` from C2a — extend/redesign).

### R3 — KaiToast: re-review against components.html, button + padding unclear
In `components.html` (toast section ~03.12): the user doesn't understand the **action button**
on neutral/positive/negative+action variants ("не понимаю дизайна кнопки или что это?"), and
there's a **large padding gap between the text and the icon**. Only `memory+action` and
`memory+countdown` read clearly; the others don't. **Re-audit the toast canon via Playwright**
(`.toast`, `.toast .open`, `.toast .ti`/icon, `.toast .body`, the `t-neutral/positive/negative/
memory` variants, countdown bar) and fix: the action affordance's meaning/size, and the
icon↔text spacing. Component: `lib/design_system/molecules/kai_toast.dart` (+ its
`kai_toast_controller.dart`); story in `molecule_stories.dart`. NOTE: a prior fix set the
action colour to `KaiTide.stop2` (#2BA8C9) per `.toast .open`; verify that's right and that
the action reads as a tappable button.

### R4 — KaiForkCard: not faithful to fork.html
The card doesn't fully convey the `fork.html` design. **Re-review `fork.html` via Playwright**
(all `.fc*` selectors: `.fc`, `.fc-h`, `.fc-cols`, `.fc-col`, `.fc-country`, `.fc-glyph`,
`.fc-name`, `.fc-price-row`, `.fc-price`, `.fc-delta` (price up/down), `.fc-row`, `.fc-chip`
(visa), `.fc-score` (rating dots), `.fc-badge` (Kai's pick), `.fc-sw` (winner marker)) and
make `KaiForkCard` + its parts (`KaiForkChip`, `KaiForkScoreDots`) faithful — including any
missing pieces (e.g. a `fc-delta` price-change element was flagged earlier as not yet built).
Components: `lib/design_system/molecules/kai_fork_card.dart`,
`atoms/kai_fork_chip.dart`, `atoms/kai_fork_score_dots.dart`.

### R5 — KaiTranscriptView: verify it matches voice.html
The user questions where `KaiTranscriptView` came from / whether it matches `voice.html`
("что это, откуда взял с voice.html?"). **Re-review `voice.html` via Playwright** (the
transcript/timeline: `.tr-view`, `.tr-event`, `.tr-rail`, `.you`, `.kai`, `.ts` timestamp,
`.who`; also the karaoke `.karaoke .now/.next` for `KaiKaraokeText`). Confirm `KaiTranscriptView`
(and `KaiKaraokeText`) faithfully reproduce the canon; correct anything that drifted. Both are
**always-dark** (voice field is `#08080A`, never theme-aware) — keep that. Components:
`lib/design_system/molecules/kai_transcript_view.dart`, `atoms/kai_karaoke_text.dart`.

---

## 2. Suggested approach for the next agent

1. **Re-audit canon first (Playwright MCP):** `fork.html`, `voice.html`, and the toast section
   of `components.html`. Capture computed values (font/size/padding/colour/radius) for every
   selector above. Update `lib/design_system/COMPONENTS.md` where reality differs.
2. **Brainstorm the compose-island redesign (R2)** with the user — present the refined
   user-idea + at least one alternative, with mockups (the Storybook itself, or AskUserQuestion
   previews). Lock the design before building.
3. **Fix R1 (badge sizing) + R3 (toast)** — likely small, canon-driven corrections.
4. **R4/R5 (fork/voice fidelity)** — correct components to match the re-audited canon.
5. Each fix: spec (if non-trivial) → TDD → token-clean impl → analyze + full suite green →
   sub-commit. Update the relevant Storybook story so the user can re-review live.

## 3. Guardrails
- Do NOT touch the pre-existing unrelated dirty files in the tree
  (`docs/superpowers/plans/2026-05-28-design-system-refactor.md`, deleted
  `new-design/review.html` / `new-design/roadmap.html`).
- `new-design/` is READ-ONLY source of truth.
- Always-dark voice widgets use fixed white/tide literals by design — not a token violation.
- Confirm visual results with the user in Storybook; the user does the visual sign-off.

## 4. Key paths
- Components: `lib/design_system/{primitives,atoms,molecules,organisms}/`
- Storybook: `lib/features/dev/storybook/` (shell `storybook_screen.dart`, structure
  `story_page.dart`, stories `stories/{foundations,primitive,atom,molecule,organism}_stories.dart`)
- Canon HTML: `new-design/*.html` + `spec-viewer.html`; rules `new-design/CLAUDE.md`
- Index: `lib/design_system/COMPONENTS.md`
- Tests: `test/design_system/...` (reuse `buildTestWidget` in `test/test_helpers.dart`)
