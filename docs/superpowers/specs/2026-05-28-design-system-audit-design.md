# Kai Design-System Reusability & Fidelity Audit — Design

**Date:** 2026-05-28 · **Branch:** `master` · **Status:** design approved, execution pending
**Endpoint:** audit report + prioritized refactor plan. **No code changes this session.**

---

## 1. Goal

Audit the Flutter design system (`lib/design_system/`) through a **reusability +
correct-decomposition** lens, verified against the `new-design/` HTML canon via the
mandated Playwright MCP + spec-viewer toolchain. Produce:

1. An **audit report** — per-component matrices (variant × state × token-vs-canon ×
   verdict), a reuse/split map, and a reusability scorecard.
2. A **prioritized refactor plan** (via `writing-plans`) that lets us reuse "dumb"
   (presentational) components or split them correctly across the existing atomic
   architecture.

This is a NEW lens layered on top of the 2026-05-27/28 fidelity audit
(Components/Brand/Foundations), not a repeat of it.

## 2. Context

- Mature atomic design system: **9 atoms / 13 molecules / 4 organisms** + 7 token
  files (`kai_colors / kai_type / kai_space / kai_radius / kai_motion / kai_tide /
  kai_tokens`). Hard rule: no hardcoded `Color/padding/radius/duration` outside token
  files. 299/299 tests, analyze clean.
- `new-design/*.html` is the visual source of truth; `spec-viewer.html` is the
  inspector. **Mandated** (both CLAUDE.md): all design work goes through Playwright
  MCP + spec-viewer (`lint`, `json↓`, `ruler`, State Simulator, Widget Tree).
  Computed styles ≠ source CSS — never eyeball raw HTML.
- Prior audit left 4 deferred HIGH (Components), folded into this audit:
  1. `KaiBubble` 13px (room) vs 15px (components) — **needs user decision** on canon.
  2. `KaiBubble.kai` missing `.cite` accent for `[N]`, missing meta-row (react +
     sources count), `streaming` not a `bool` flag.
  3. `ComposeIsland.sheet` variant — dead code, removal candidate.
  4. `KaiButtonSend` default size 44 → should be 30.

## 3. Approach (A — vertical slice → template → broaden)

Audit **buttons end-to-end first** as a complete worked example to validate the
matrix format, get user sign-off on the format, then broaden the same template across
all atoms → molecules → organisms in waves. Static Dart reads can be parallelized via
subagents; spec-viewer canon inspection stays on one serialized Playwright session
(browser is stateful; a profile-lock was hit last session).

## 4. Audit lens (per component)

| # | Axis | What | Source |
|---|------|------|--------|
| 1 | Reusability / "dumbness" | Pure presentational? No business logic / Riverpod reads / nav / I-O? All data via params? | Dart read |
| 2 | Variants | Declared vs canon; missing/redundant; API consistency (named ctors vs enum) | components.html |
| 3 | States | default/hover/pressed/focused/disabled/loading + domain states vs canon | components.html State Simulator; tide-states.html |
| 4 | Tokens | No hardcode outside token files; token mapping matches computed values | spec-viewer lint + genFlutter |
| 5 | Architecture placement | Right layer? Split/merge candidate? Duplication? | Dart tree |
| 6 | Pixel fidelity | Computed px/hex/ms vs Dart token values; deltas logged | spec-viewer inspect |

Each component gets a verdict per axis and a reuse/split recommendation:
**dumb (keep)** / **leaky (extract logic)** / **needs-split** / **merge/dedupe** /
**dead code**.

## 4a. Visual-confirmation protocol

spec-viewer computed-style reads can be imprecise. Every material finding gets a
**final visual confirmation**: a Playwright screenshot of the canon element/screen,
eyeballed against the computed delta, before it enters the report as fact. The matrix
marks visually-confirmed cells `✔vis`. Verification layers, each catching what the one
below misses: raw HTML → computed styles (spec-viewer) → visual screenshot.

## 5. Output format

- **Per-component matrix:** `variant × state → token value | canon value | delta | verdict`.
- **Reuse/split map:** what to extract into shared dumb components, what to move across
  layers, what is dead code.
- **Reusability scorecard:** per-component rating across the 6 axes.
- **Needs-user-decision list:** e.g. the 13/15px bubble canon.

## 6. Phasing

- **Ф0 — Setup.** `cd new-design && python -m http.server 8743`; Playwright →
  `spec-viewer.html`; confirm inspector drives (clear profile-lock if any).
- **Ф1 — Buttons slice (template validation).** Full audit of `KaiButton`
  (tide/ink1/ghost/icon/iconTransparent) + `KaiButtonSend`
  (ready/sending/streaming/disabled). Canon sources: `components.html` (button catalog
  + State Simulator), `room.html` (send states, compose), `edge-states.html`
  (money-gate glow button, retry pill, upgrade CTA), `foundations.html` (r3=14, tide
  gradient, shadow, motion), and the send-button canon rules in `new-design/CLAUDE.md
  §3`. → present filled buttons section, get format sign-off.
- **Ф2 — Broaden.** Same template across remaining atoms → molecules → organisms.
  Visual canon limited to the 5 named HTML files; reuse/token checks for all.
  Parallelize static Dart reads via subagents; serialize spec-viewer inspection.
- **Ф3 — Synthesis.** Assemble audit report; run `sp-content-audit` as a verify-only
  gap/consistency pass over the report; then `writing-plans` to produce the prioritized
  refactor plan. Fold in the 4 deferred HIGHs.

## 7. Skill orchestration

- `using-superpowers` ✓ → `brainstorming` ✓ (this doc).
- Audit execution Ф0–Ф2: Playwright MCP + spec-viewer + Explore/general subagents
  (read-only investigation).
- `sp-content-audit` (Ф3): verify-only review of the produced audit report for gaps /
  inconsistencies before locking the plan.
- `writing-plans` (Ф3): the prioritized refactor plan (brainstorming's terminal handoff).
- `frontend-design` + `subagent-driven-development`: **deferred to the refactor
  execution session** (after the plan is approved) — implementation skills come after
  planning.

## 8. Scope

**In:** `lib/design_system/` (atoms/molecules/organisms/tokens/theme), buttons first;
visual canon = foundations + components + room + edge-states + tide-states.

**Out (YAGNI):** no code changes this session; no live Flutter/web render; screens
outside the named 5 get reuse/token checks but not pixel-canon; backend/providers/data
untouched; other `new-design/*.html` not read.

## 9. Deliverable artifacts

1. This design doc — `docs/superpowers/specs/2026-05-28-design-system-audit-design.md`.
2. Audit report — `docs/superpowers/audits/2026-05-28-design-system-audit.md`
   (produced Ф1–Ф3).
3. Refactor plan — `docs/superpowers/plans/2026-05-28-design-system-refactor.md`
   (via writing-plans, Ф3).
