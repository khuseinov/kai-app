# Kai Design-System Reusability & Fidelity Audit — Report

**Date:** 2026-05-28 · **Branch:** `master` · **Status:** Ф1 + Ф2 complete · Ф3 in progress (visual-confirm ✅ · content-audit ✅ · refactor plan pending)
**Design/spec:** `docs/superpowers/specs/2026-05-28-design-system-audit-design.md`

---

## Method

Per-component evaluation on 6 axes: (1) reusability/"dumbness", (2) variants vs canon,
(3) states vs canon, (4) token discipline, (5) architecture placement, (6) pixel
fidelity. Verdicts: **dumb (keep)** / **leaky** / **needs-split** / **merge/dedupe** /
**dead code**.

**Canon toolchain.** `new-design/*.html` is source of truth, inspected via Playwright
MCP. `file://` is blocked in this MCP config and a static server is required; Python is
absent, so a minimal Node static server runs detached on `http://127.0.0.1:8743`
(spawned via `Start-Process`; background-job servers did not persist). Computed styles
+ CSS-rule reads come from the iframe DOM; the spec-viewer inspector adds token mapping.

**Visual-confirmation protocol.** spec-viewer computed reads can be imprecise — every
material finding is visually confirmed with a Playwright screenshot of the canon before
being reported as fact. Visually-confirmed cells marked `✔vis`. Layers: raw HTML →
computed styles → screenshot.

**Canon scope for visual fidelity:** foundations · components · room · edge-states ·
tide-states. Other screens get reuse/token checks only.

**Deferred #1–#4** = the four HIGH findings carried over from the 2026-05-27/28
Components fidelity audit (see spec §2).

---

## Ф1 — Buttons (format-validated slice)

Canon note: `components.html` shows buttons **in context** (compose `.send`/`.mic`,
action-sheet `.act-row`, detail `.act`, toast `.open`, drawer `.new-btn`) rather than as
a variant gallery. The `KaiButton` atom is therefore cross-referenced against the
widgets that actually render each canon context.

### `KaiButton` (atom · 5 variants) — `lib/design_system/atoms/kai_button.dart`

| Variant | Flutter (tokens) | Canon (computed) | Δ | Verdict |
|---|---|---|---|---|
| tide | `KaiTide.gradient`, `br3`=14, shadow `0x2E2BA8C9`, white, pad 12/20, body w600 | standalone not in components (lives in onboarding/edge-states); `.send` carries same gradient ✓ | confirm tide button in edge-states money-gate (Ф2) | dumb; tide canon check deferred to Ф2 |
| ink1 | `c.ink1`, `br3`=14, white, pad 12/20, hug | `.new-btn`: ink1, **r12**, full-width, **p11** | **r14↔12; hug↔full-width** | reuses `KaiButton.ink1` in NavPanel; r14↔12 / hug↔full-width canon delta (B5) |
| ghost | transparent, `br3`=14, border 1px `line`(#E8E8E5), ink1 | `.l-pill` (border 1px line) — confirm | — | dumb; confirm l-pill |
| icon | `surface2`, pill, ink2, pad6, icon18 | icon-pill surface2 — confirm | — | dumb |
| iconTransparent | transparent, ink3, pad6+icon18 (=30×30) | `.mic`: transparent, ink3, **30×30** ✓ | none | **dumb ✓ exact match** |

**States (all variants):** `default` / `pressed` (scale .97 @ **200 ms** easeOut) /
`disabled` (opacity .5). Canon press = m-3 **micro 120 ms** `cubic(.2,0,0,1)` → **Δ
duration+curve, off-token** (B2). No `hover`/`focus` (mobile-first; no focus ring — B7).

### `KaiButtonSend` (atom · 4 states) — `lib/design_system/atoms/kai_button_send.dart`

| State | Flutter | Canon (room/components) | Δ | Verdict |
|---|---|---|---|---|
| ready | gradient, circle, shadow, icon=surface, **size 44**/icon16 | `.send`: gradient ✓, circle ✓, **30×30**, icon ~12–13 | **size 44↔30; icon 16↔12** | visual ✓; size-default DX-trap (B1) |
| sending | gradient + pulse .95↔1.05 @120 ms | m-3 micro pulse ✓ | none | ✓ |
| streaming | = sending | responding pulse ✓ | none | ✓ |
| disabled | ink4, circle, opacity .5, icon=surface | `.send`-disabled: ink4, opacity .5 ✓ | none | ✓ |

### Findings

| # | Severity | Finding | Action |
|---|---|---|---|
| B1 | HIGH | `KaiButtonSend.size` default 44 vs canon 30 | default → 30 (confirms deferred #4) |
| B2 | HIGH | `KaiButton` press 200 ms easeOut vs canon micro 120 ms `cubic(.2,0,0,1)`; off-token | → `KaiMotion.micro` + `standardCurve` |
| B3 | MED | Hardcoded durations (200/120) + shadow color literal `0x2E2BA8C9` — not token refs | extract `KaiMotion.*` + shadow token |
| B4 | MED | SVG painting duplicated 3× (KaiButton ×2 paths, KaiButtonSend) due to "atoms can't import atoms" | shared icon-painter / allow `KaiIcon` import |
| B5 | MED | `.new-btn` (NavPanel) **reuses** `KaiButton.ink1` (not bespoke), but the atom renders r14/hug vs canon new-btn r12/full-width | extend `KaiButton.ink1` (`fullWidth`+radius) to close the canon delta |
| B6 | LOW | `KaiButtonSend.iconSize` default 16 vs canon 12–13 (compose passes 12) | default → 12 |
| B7 | LOW | No focus ring on `KaiButton` (a11y) | accept (mobile) or focus token |

### Needs user decision

- **D1:** canon uses **off-scale radii** — `.new-btn` 12 px, detail `.act` 8 px — not in
  the foundations radius scale (6/10/14/20/28). Add `r=8/12` tokens, or snap to nearest?
  (Canon is source-of-truth but violates its own foundations scale.)

### Visual confirmation (Ф1)

Canon `components.html` rendered and screenshotted (`canon-components-full.png`):
catalog structure confirmed (bubbles → sheets → drawer `.new-btn` → toasts). Headline
deltas (send 30×30, mic transparent/ink3, new-btn ink1) consistent with computed reads.
Visual confirmation completed in Ф3 via fullPage canon screenshots; per-element close-ups deferred to refactor-time verification (not required to establish the findings).

---

## Ф2 — Broaden (atoms · molecules · organisms)

Static Dart analysis via 3 parallel subagents (read-only); canon computed/visual checks
on the Playwright session (components, room, edge-states). 24 components. Axes are
captured per component as Verdict + Note plus the consolidated reuse/token/fidelity
tables; full variant×state matrices are reserved for interactive components (buttons,
Ф1) — the remaining components have ≤2 states, noted inline.

### Per-layer verdicts

**Atoms (9)**

| Atom | Verdict | Note |
|---|---|---|
| KaiText | dumb ✓ | clean; 10 type variants |
| KaiIcon | dumb ✓ | canonical icon source — siblings should route through it |
| KaiInput (`KaiTextField`) | dumb ✓ | file/class name mismatch (kai_input.dart ↔ `KaiTextField`) |
| KaiTideCurve | dumb-stateful ✓ | only legit stateful atom; durations data-driven from `KaiTide` |
| KaiButton | dumb ✓ | reuse gaps (R1); radius/motion deltas (B2, D3, ink1) |
| KaiButtonSend | dumb ✓ | size default 44→30 (B1) |
| KaiToggle | leaky-token | `circular(999)`→brPill (:41); white/shadow literals |
| KaiBottomSheetShell | leaky-token | `circular(24)` off-scale + drag-pill `circular(999)`→brPill |
| **KaiBubble** | **needs-split** | **atom imports molecule SourceCard (R2)**; fontSize literals 13/13.5 |

**Molecules (13)**

| Molecule | Verdict | Note |
|---|---|---|
| ComposeIsland | dead-code(.sheet) / best-reuse | `.sheet` only in test (R4); reuses KaiButtonSend + KaiButton.iconTransparent ✓ |
| CareBlock | dumb ✓ | cleanest; `EdgeInsets.all(14)` nit; canon care-block confirmed ✔vis |
| NavItem | dumb ✓ | unused in production; dev/test only (R5) |
| SourceCard | dumb ✓ | no `onTap` despite expandHint |
| KaiSystemNote | dumb ✓ | radius 12 literal |
| KaiSegmentedControl | dumb ✓ | radius 8/6 literals |
| KaiSettingsRow | dumb ✓ | composes Toggle/Segmented |
| KaiAccountHero | dumb ✓ | reuses `KaiTide.gradient` correctly |
| KaiSettingsGroup | dumb ✓ | radius 12 |
| AlertCard | leaky-ish | dead `action` param; bespoke CTA pill (R1) |
| KaiActionSheet | leaky(nav) | static `show()`+`Navigator.maybePop()` (R3) |
| KaiMessageDetailSheet | leaky(nav) | same nav leak (R3); radii 4/8 |
| **KaiToast** | **needs-split** | **hardcoded tide gradient HEX (T1)** + static overlay manager (R3) |

**Organisms (4)**

| Organism | Verdict | Note |
|---|---|---|
| edge_state_block | dumb ✓ | bespoke offline-retry pill (R1); reuses KaiButton.ghost/CareBlock elsewhere |
| chat_list | leaky | anim controllers force Stateful; bespoke retry + chips + streaming bubbles |
| onboarding_card | leaky/merge | `_OnboardingCTA` re-implements KaiButton (R1) |
| nav_panel | leaky/needs-split | date logic + domain models in organism (R3); new-chat **correctly reuses** `KaiButton.ink1` |

### Consolidated findings — reuse / decomposition (primary lens)

| # | Sev | Finding | Action |
|---|---|---|---|
| R1 | HIGH | Bespoke buttons re-implement atoms: onboarding `_OnboardingCTA`; chat_list (coral) + edge_state_block (warning-tone) retry pills; AlertCard CTA pill; nav_panel `_SearchBox` (vs KaiInput) | extend atoms (`KaiButton` `fullWidth`; `KaiButton.ghost(tone:, pill:)`; reuse `KaiInput`), then replace bespokes |
| R2 | HIGH | Layer inversion: `KaiBubble` atom imports molecule `SourceCard` (kai_bubble.dart:4) | decouple (`List<Widget> sources`) or promote KaiBubble → molecule |
| R3 | MED | Logic/nav/overlay leaks in presentational layer: nav_panel date-bucketing+models; ActionSheet/MessageDetailSheet `show()`+`Navigator.maybePop()`; KaiToast static overlay+Timer | extract to models / presenter / `ToastController` |
| R4 | MED | `ComposeIsland.sheet` dead code (test-only) | delete variant+test, or wire it (confirms deferred #3) |
| R5 | LOW | `NavItem` molecule unused in production (only dev showcase/test); nav_panel rows bespoke | adopt NavItem in nav_panel or remove it |

### Consolidated findings — token discipline (cross-cutting)

| # | Sev | Finding | Action |
|---|---|---|---|
| T1 | HIGH | KaiToast hardcodes tide gradient HEX (kai_toast.dart:402-404) vs locked `KaiTide.gradient` | reuse `KaiTide.gradient` |
| T2 | MED | `circular(999)` literals (~10 sites) vs `KaiRadius.brPill/pill` | swap |
| T3 | MED | Off-scale literal radii 8/12/24 scattered, never centralized | D1 |
| T4 | MED | Motion literals (200/220/900/1600 ms, bare Curves) bypass `KaiMotion` | route via `KaiMotion`; incl. B2 (200→micro 120 + standardCurve) |
| T5 | LOW | Raw spacing (EdgeInsets/SizedBox numbers) widespread vs `KaiSpace.s*` | tokenize on-grid; D for off-grid |
| T6 | LOW | Raw fontSize literals vs `KaiType` (inline `fontFamily` sanctioned) | tokenize where on-scale |

### Canon-vs-atom fidelity deltas (✔vis = Ф3 screenshot pass)

| Element | Flutter | Canon | Δ |
|---|---|---|---|
| Bubble text | user 13 / kai 13.5 | room 13.5 / components 15 | D2 (canon split) + user 13→13.5 |
| Kai label `.who` | 9 | room 9 / components 10 | canon internal split |
| KaiButton.tide | r14 (br3), shadow α0.18 | money-gate r10 + GLOW α0.384 | D3 (radius + glow variant) |
| KaiButton.ink1 | r14, hug | new-btn r12, full-width | reuses `KaiButton.ink1`; r14↔12 / hug↔full-width canon delta (B5) |
| KaiButton.ghost | r14, line border, ink1 text | retry r999 (pill), tone text (warn/neg) | needs pill+tone → R1 |
| KaiButtonSend | size 44 | 30 | B1 |
| CareBlock | r2, borderLeft | borderLeft 2.4px neg, r 0/10/10/0 | ✓ match ✔vis |

### Needs user decision

- **D1 — off-scale radii.** ✅ RESOLVED 2026-05-28: **add tokens `r1_5=8` + `r2_5=12`**;
  snap the single 24 → `r5` (28).
- **D2 — bubble text size.** ✅ RESOLVED 2026-05-28: **canon = 13.5 (room)**; fix
  user-bubble 13→13.5; `.who` = 9. components.html 15 = catalog display only.
- **D3 — tide primary button.** ✅ RESOLVED 2026-05-28: **add `KaiButton.tide(emphasis:
  glow)`** for money-gate; keep generic tide radius `br3` (no global radius change).

## Ф3 — Synthesis (in progress)

1. ✅ **Visual-confirmation pass** (Playwright fullPage): `canon-components-full.png`,
   `canon-edge-states-full.png`, `canon-room-full.png`. Canon renders consistent with
   computed reads — money-gate tide+glow, tone retry-pills, crisis care-block, compose
   send/mic 30×30, user/kai bubbles, streaming stop. Primary canon source was
   `getComputedStyle` on the iframe DOM (not the inspector's `genFlutter` mapping), which
   is robust to the spec-viewer imprecision the user flagged. tide-states (KaiTideCurve)
   left computed-only — data-driven from `KaiTide`, low fidelity risk.
2. ✅ `sp-content-audit` verify-only pass (3 verifiers). Code claims accurate — **no
   WRONG verdicts** (16/17 CONFIRMED, 1 imprecise notation). Fixed report-consistency
   defects: B5 reconciled (new-chat **reuses** `KaiButton.ink1`), orphan `R-tide`→D3,
   retry-pill tones (chat_list coral / edge_state_block warning), NavItem production-
   scope, stale status header.
3. ✅ `writing-plans` → refactor plan at
   `docs/superpowers/plans/2026-05-28-design-system-refactor.md` (W0–W4, 22 tasks; D1–D3
   as decisions with defaults). **Report + plan delivered — endpoint reached; no code
   changes this session.**
