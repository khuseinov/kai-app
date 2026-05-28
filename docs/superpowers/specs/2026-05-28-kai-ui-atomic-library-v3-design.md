# Kai UI — Clean Atomic Component Library (v3) — Design

**Date:** 2026-05-28 · **Branch:** `master` · **Status:** design — pending user review
**Strategy:** Strangler-Fig + atoms-first · **Endpoint:** approved spec → `writing-plans` → SDD execution.

This spec defines a clean-slate atomic UI component library for Kai, derived from the
`new-design/` canon, built to replace the current `lib/design_system/` component layer
without breaking the 299 tests or 5 production screens during the transition. It folds in
the verified findings of the 2026-05-28 design-system audit
(`docs/superpowers/audits/2026-05-28-design-system-audit.md`) as the per-component spec.

---

## 1. Goal & rationale

Produce the **ideal atomic vocabulary** for Kai (button, label/text, input, icon, and the
rest), designed fresh from the source of truth rather than constrained by the current
implementation, then build it. The current system (9 atoms / 13 molecules / 4 organisms)
is mature but the audit found structural issues that a clean redesign fixes by construction:

- **Layer inversion** — `KaiBubble` (atom) imports `SourceCard` (molecule).
- **SVG duplication ×3** — caused by the self-imposed "atoms can't import atoms" rule.
- **Bespoke buttons** re-implementing atoms (onboarding CTA, retry pills, alert CTA).
- **Token leaks** — hardcoded tide gradient in `KaiToast`, off-scale radii, motion literals.
- **Logic/nav leaks** in presentational widgets (nav date-bucketing, sheet `Navigator` calls).

The clean library is **maximally coherent**: one icon source, strict presentational atoms,
consistent variant/state/tone API, full token discipline.

## 2. Locked decisions (this session)

| # | Decision | Choice |
|---|----------|--------|
| Strategy | Build approach | **A — Strangler-Fig + atoms-first** (parallel build, incremental screen migration) |
| D2 | Bubble text size canon | **13.5px** (room.html — real chat context); user bubble 13→13.5, `who` label 9px. components.html 15px is catalog display only |
| D1 | Off-scale radii | **Add `r8` + `r12` tokens** to the scale (they recur ~10×: new-btn 12, detail-act 8, system-note 12) |
| Arch | "atoms can't import atoms" rule | **Replace with a `primitives/` layer below atoms**; atoms may import primitives |
| D3 | Tide primary button | **Add `emphasis: glow`** variant (money-gate: glow α0.384, r10) alongside default tide (soft shadow α0.18, r14) |
| Namespace | New library location | **`lib/design_system/v3/`** (single design home); promoted to flat structure after migration |

## 3. Architecture & layering

```
lib/design_system/
  tokens/      ← SHARED, KEPT. Additions only: r8/r12 radii, KaiMotion.micro fix
               (120ms linear), shadow + glow tokens, no rebuild.
  theme/       ← SHARED, KEPT. KaiTheme.of(context).colors.* unchanged.
  v3/          ← NEW clean library (strangler-fig)
    primitives/   KaiIcon · KaiSvg · KaiSurface · KaiGradientBar
    atoms/        12 atoms (see §4)
    molecules/    bubbles · compose · toast · sheets · cards · settings rows
    organisms/    chat_list · nav_panel · edge_state_block · onboarding_card
  atoms/ molecules/ organisms/   ← OLD, deleted per-component as migration completes
```

**Principles**
- **Tokens/theme are shared, never duplicated.** v3 imports the existing token + theme
  files. The floor is canonical (synced with `design-tokens.json`); only additive changes.
- **`primitives/` is a new layer below atoms.** `KaiIcon` is the single SVG source
  (eliminates the ×3 duplication); `KaiSurface` is the themed container building block;
  `KaiGradientBar` is the tiny tide-pill (who-glyph 16×4, toast-bar 10×2.5). Atoms import
  primitives — the `KaiBubble→SourceCard` inversion cannot recur.
- **Atoms are strictly presentational ("dumb"):** data via params only; no Riverpod reads,
  no navigation, no I/O, no domain models. Logic lives in screens/presenters.
- **Promotion:** when every screen has migrated and old components are deleted, `v3/*` is
  moved up to `lib/design_system/{primitives,atoms,molecules,organisms}` and the `v3/`
  wrapper removed. Final tree is conventional.

## 4. Atomic vocabulary (4 primitives + 12 atoms)

API conventions (uniform): named constructors per variant (`KaiButton.tide(...)`,
`KaiText.h1(...)`); colors only via `KaiTheme.of(context).colors.*`; ephemeral interaction
state (pressed) via internal `StatefulWidget`, domain state (send) via enum param;
`tone`/`emphasis`/`fullWidth`/`pill` as options, not separate classes.

| # | Component | Layer | Variants | States | Canon source |
|---|-----------|-------|----------|--------|--------------|
| P1 | **KaiIcon** | primitive | enum `KaiIconName` (single SVG source) | tint via param | components.html icon `<defs>` |
| P2 | **KaiSvg** | primitive | raw asset render | — | — |
| P3 | **KaiSurface** | primitive | bg/surface/2/3 · radius · border · shadow | — | base container |
| P4 | **KaiGradientBar** | primitive | sizes | optional pulse | who-glyph, toast-bar |
| 1 | **KaiText** | atom | hero·display·h1·h2·h3·lead·body·small·micro·mono + `tideWord` gradient emphasis | — | foundations type scale |
| 2 | **KaiButton** | atom | `tide`(+`emphasis:glow`) · `ink`(+`fullWidth`) · `ghost`(+`tone`/`pill`) · `text`(+`tone`) | default · pressed (scale .97 @120ms micro `cubic(.2,0,0,1)`) · disabled (opacity .5) | onboarding, money-gate, new-btn, retry-pills, detail `.act`, toast `.open`, crisis `.a` |
| 3 | **KaiIconButton** | atom | `surface` (surface-2 pill, ink2) · `transparent` (ink3) · `bare` | default · pressed · disabled | compose `.mic` 30×30 |
| 4 | **KaiSendButton** | atom | circular, gradient, 30×30, glyph ~12 | ready · disabled (ink4, opacity .5) · sending+streaming (scale-pulse m-3) | room `.send` |
| 5 | **KaiInput** | atom | `line` (r10) · `pill` (compose island) | default · focus · disabled · placeholder (ink4) | compose textarea, nav search |
| 6 | **KaiToggle** | atom | — | on (accent) · off (ink4) · disabled | settings |
| 7 | **KaiChip** | atom | `status` (mono uppercase, tone: done/active/neutral) · `choice` (selectable) | default · selected | l-pill, segmented, visa chips |
| 8 | **KaiBadge** | atom | `dot` (6px + ring) · `count` | — | nav memory dot |
| 9 | **KaiAvatar** | atom | sizes (tide-corner gradient circle) | — | account hero |
| 10 | **KaiTideCurve** | atom | 8 states: idle/listening/thinking/responding/success/error/memory/sleep | data-driven animations | tide-states.html |
| 11 | **KaiDivider** | atom | horizontal · vertical (1px `--line`) | — | global |
| 12 | **KaiSheetShell** | atom | drag-pill + surface (r24 top corners) + scrim | — | components `.sheet` |

Notes: the citation `[N]` (`.cite` accent) is rich text inside the Kai bubble, not its own
atom. Sheet top radius is canon **24px** (not the r28 foundations token) — logged as a minor
canon-vs-scale note; resolve at build (add `r24` or accept 24 literal in `KaiSheetShell` only).

## 5. Molecules & organisms (compose atoms)

**Molecules** — map to canon, mostly exist; rebuilt clean:
- Bubbles split into `KaiUserBubble` / `KaiKaiBubble` (label + text + meta-row + sources) /
  `KaiSystemBubble` (neutral/warning/negative). Sources passed as `List<Widget>` — no
  atom→molecule inversion.
- `KaiComposeIsland` (input + mic + send; drop dead `.sheet` variant).
- `KaiSourceCard`, `KaiCareBlock`, `KaiAlertCard` (CTA via `KaiButton`, not bespoke).
- `KaiToast` (gradient via `KaiTide.gradient`; overlay/Timer extracted to `ToastController`).
- `KaiActionSheet` / `KaiMessageDetailSheet` (navigation lifted out to caller/presenter).
- `KaiSegmentedControl`, `KaiSettingsRow`, `KaiSettingsGroup`, `KaiAccountHero`, `KaiNavItem`.

**Organisms** — compose molecules; domain logic extracted:
- `KaiChatList`, `KaiNavPanel` (date-bucketing + models → presenter), `KaiEdgeStateBlock`,
  `KaiOnboardingCard` (remove `_OnboardingCTA`, reuse `KaiButton`).

## 6. Build waves & SDD shape

- **W0 — Foundation:** token additions (r8/r12, `KaiMotion.micro` 120ms, shadow + glow
  tokens) + the 4 primitives.
- **W1 — Atoms:** the 12 atoms. Independent within the wave → parallelizable subagents.
- **W2 — Molecules:** depend on atoms → run after W1.
- **W3 — Organisms:** depend on molecules → run after W2.
- **W4 — Migration:** migrate screens one at a time (`room → onboarding → nav →
  edge-states → settings`), delete each old component when it has 0 references, then promote
  `v3/*` to flat structure.

**Per-component subagent task =** canon spec (from audit + HTML) → **Playwright MCP +
spec-viewer** verification of pixel/token values → **TDD** (test first) → implementation →
`flutter analyze` clean. Cross-wave dependencies serialize; intra-wave tasks parallelize.

**Verification:** `flutter test` (≥299 green throughout — never let the suite go red between
merges), `flutter analyze` ("No issues found"). Canon fidelity confirmed via Playwright +
spec-viewer per CLAUDE.md mandate; audit deltas are the starting spec, not the final word.

## 7. Scope

**In:** `lib/design_system/v3/` (primitives + atoms + molecules + organisms); additive token
changes; migration of the 5 existing screens; deletion of the old component layer.

**Out (YAGNI):** backend / providers / repositories / Hive; iOS CI signing; brand pipeline;
screens not yet built (voice, memory, trip-detail, fork) — built later from these atoms;
token/theme rewrite (additive only); a `/_dev` showcase gallery (optional follow-up, not
required for the library itself).

## 8. Deliverable artifacts

1. This design doc — `docs/superpowers/specs/2026-05-28-kai-ui-atomic-library-v3-design.md`.
2. Implementation plan — `docs/superpowers/plans/2026-05-28-kai-ui-atomic-library-v3.md`
   (via `writing-plans`).
3. The library itself — `lib/design_system/v3/` → promoted to `lib/design_system/`.
