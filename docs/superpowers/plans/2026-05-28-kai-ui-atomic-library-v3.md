# Kai UI — Clean Atomic Component Library (v3) — Implementation Plan

**Date:** 2026-05-28 · **Branch:** `master` · **Status:** APPROVED — ready for SDD execution
**Spec:** `docs/superpowers/specs/2026-05-28-kai-ui-atomic-library-v3-design.md`
**Audit (verified canon deltas):** `docs/superpowers/audits/2026-05-28-design-system-audit.md`

## Context

Kai's Flutter design system (`lib/design_system/`) is mature (9 atoms / 13 molecules / 4
organisms + 7 token files, 299 tests green) but a 2026-05-28 audit found structural debt that
incremental fixes won't cleanly resolve: an atom importing a molecule (`KaiBubble→SourceCard`),
SVG-render duplication caused by a self-imposed "atoms can't import atoms" rule, bespoke buttons
re-implementing atoms, hardcoded gradients/shadows, off-scale radii, and logic/nav leaks inside
presentational widgets. The user chose to **redesign the atomic vocabulary from scratch** against
the `new-design/` canon and rebuild it via a **strangler-fig** migration so the suite stays green
the whole way.

## Goal

Build a clean, maximally-coherent component library in `lib/design_system/v3/` (3 primitives +
12 atoms + ~16 molecules + 4 organisms), migrate the 4 screens with design-system deps to it,
delete the old component layer, and promote `v3/*` to the flat structure — with `flutter test`
≥299 green and `flutter analyze` clean at every wave boundary.

## Architecture & trade-off

**Strangler-fig in a `v3/` subfolder.** New components live under
`lib/design_system/v3/{primitives,atoms,molecules,organisms}`; the existing `tokens/` and
`theme/` are **shared and kept** (only additive changes). Screens migrate one at a time; each old
component is deleted when it reaches zero references; finally `v3/*` is promoted up and the
wrapper removed. Trade-off considered: an in-place big-bang rewrite gives a cleaner end-state with
no temporary duplication, but opens a long red-test window and can't be parallelized across SDD
subagents (they'd collide on shared screens/tests). Strangler-fig accepts brief two-system
coexistence in exchange for green-throughout safety and clean fan-out.

**New `primitives/` layer below atoms** removes the atom-can't-import-atom rule by construction:
`KaiIcon` becomes the one SVG source, `KaiSurface` the themed container, `KaiGradientBar` the
tide-pill — atoms import these, so the `KaiBubble→SourceCard` inversion can't recur.

## Locked decisions (from brainstorming)

- Bubble text = **13.5px** (room canon); user bubble 13→13.5, `who` label 9px.
- **Add `r8`/`r12`** radius tokens (canon uses them ~10×).
- **`primitives/` layer**; atoms may import primitives.
- Tide button gets **`emphasis: glow`** (money-gate) alongside default soft-shadow tide.
- New library at **`lib/design_system/v3/`**, promoted flat after migration.

## File map

### Tokens (MODIFY — additive only; shared by old + v3)
| File | Change |
|---|---|
| `tokens/kai_radius.dart` | add `r8`=8, `r12`=12 + `br8`,`br12` BorderRadius. (`r1/r2/r3/r4/r5/pill` already exist) |
| `tokens/kai_shadow.dart` *(NEW)* | `KaiShadow.button` (soft, rgba(43,168,201,0.18) blur8 y2), `KaiShadow.glow` (α0.384, money-gate). Replaces literal `Color(0x2E2BA8C9)` + comment-only shadows |

> `KaiMotion.micro`=120ms + `standardCurve`/`linearCurve` already exist — **no motion token
> additions**; widgets must reference them instead of literals.

### Primitives (NEW — `v3/primitives/`)
| File | Responsibility |
|---|---|
| `kai_icon.dart` | Single SVG source. Port `atoms/kai_icon.dart` near-verbatim (`KaiIconName` enum, 30 assets, `SvgPicture.asset` + `ColorFilter`) |
| `kai_surface.dart` | Themed container: bg/surface/surface2/surface3 + radius + optional border + optional `KaiShadow` |
| `kai_gradient_bar.dart` | Tiny tide-gradient pill (who-glyph 16×4, toast-bar 10×2.5), optional pulse |

### Atoms (NEW — `v3/atoms/`, 12)
| File | Variants / key API | Notes vs current |
|---|---|---|
| `kai_text.dart` | hero·display·h1·h2·h3·lead·body·small·micro·mono + `tideWord` gradient emphasis | port + add gradient-fill word |
| `kai_button.dart` | `tide`(+`emphasis:glow`)·`ink`(+`fullWidth`)·`ghost`(+`tone`/`pill`)·`text`(+`tone`) | replaces 5-variant button; uses `KaiMotion.micro`(120ms)+`standardCurve`, `KaiShadow.*`; absorbs new-btn(full-width r12), retry-pills(ghost+tone+pill), detail/toast `text` |
| `kai_icon_button.dart` | `surface`(surface2 pill,ink2)·`transparent`(ink3)·`bare` | split out of old `KaiButton.icon/.iconTransparent` |
| `kai_send_button.dart` | states `ready`/`disabled`(ink4,.5)/`sending`+`streaming`(scale-pulse) | **default 30×30, glyph ~12** (was 44/16) |
| `kai_input.dart` | `line`(r10)·`pill`(compose) | **class `KaiInput`** (fixes file↔class `KaiTextField` mismatch) |
| `kai_toggle.dart` | on(accent)/off(ink4)/disabled | tokenize `circular(999)`→`brPill`, white/shadow literals→tokens |
| `kai_chip.dart` *(net-new)* | `status`(mono uppercase, tone done/active/neutral)·`choice`(selectable) | currently inline (l-pill, segmented option, visa chips) |
| `kai_badge.dart` *(net-new)* | `dot`(6px+ring)·`count` | currently inline (nav memory dot) |
| `kai_avatar.dart` *(net-new)* | sizes; tide-corner gradient circle | extracted from account hero |
| `kai_tide_curve.dart` | 8 states (data-driven animations) | port `atoms/kai_tide_curve.dart` (legit stateful) |
| `kai_divider.dart` *(net-new)* | horizontal·vertical (1px `line`) | currently inline |
| `kai_sheet_shell.dart` | drag-pill + surface (r24 top) + scrim | port `kai_bottom_sheet_shell.dart`, tokenize |

### Molecules (NEW — `v3/molecules/`, ~16)
- Bubbles split: `kai_user_bubble.dart`, `kai_kai_bubble.dart` (label+text+`[N]`cite+meta-row+sources as `List<Widget>` — **no SourceCard import**), `kai_system_bubble.dart`.
- `compose_island.dart` (drop dead `.sheet` variant), `source_card.dart`, `care_block.dart`, `alert_card.dart` (CTA via `KaiButton`, drop dead `action` param), `kai_segmented_control.dart`, `kai_settings_row.dart`, `kai_settings_group.dart`, `kai_account_hero.dart`, `nav_item.dart`.
- `kai_toast.dart` + `kai_toast_controller.dart` *(NEW)* — gradient via `KaiTide.gradient`; overlay/Timer lifted into `ToastController` (presenter), widget stays dumb.
- `kai_action_sheet.dart`, `kai_message_detail_sheet.dart` — `Navigator` calls lifted to caller; widgets receive `onSelect`/`onClose` callbacks only.

### Organisms (NEW — `v3/organisms/`, 4)
- `chat_list.dart` (port; keep animation controllers — legit stateful).
- `nav_panel.dart` + `lib/features/nav/session_groups.dart` *(NEW)* — extract `_groupSessionsByDate` date-bucketing into a pure presenter/model; organism receives grouped data + l10n strings as params.
- `edge_state_block.dart` (port; already reuses atoms correctly).
- `onboarding_card.dart` (drop `_OnboardingCTA`, reuse `KaiButton`).

### Tests (NEW — mirror under `test/design_system/v3/...`)
Reuse `test/test_helpers.dart` → `buildTestWidget(child, themeMode:)` (ProviderScope+KaiTheme+Scaffold).
One test file per v3 component; behavior/structure assertions (no goldens, matching repo convention).

## Build sequence (5 waves; TDD per component)

**W0 — Foundation (serial).**
1. `kai_radius.dart` +r8/r12/br8/br12 — token test first.
2. `kai_shadow.dart` new — token test.
3. Primitives `KaiIcon`, `KaiSurface`, `KaiGradientBar` (parallelizable) — test + impl each.

**W1 — Atoms (parallel after W0).** 12 independent tasks, each: write widget test → implement →
`flutter analyze`. No cross-atom deps (icon needs come from `KaiIcon` primitive).

**W2 — Molecules (parallel after W1).** ~16 tasks; each composes already-built atoms/primitives.
Bubble split + toast controller + sheet nav-lift are the non-trivial ones.

**W3 — Organisms (parallel after W2).** 4 tasks + the `session_groups` presenter extraction (nav).

**W4 — Migration (serial, by effort).** For each screen **nav → onboarding → room → settings**:
switch imports to `v3`, update that screen's tests, `flutter test` green, delete each old component
at 0 refs, Playwright spec-viewer spot-check vs canon. After all 4: delete remaining old
`atoms/molecules/organisms`, **promote `v3/*`** to `lib/design_system/{primitives,atoms,molecules,organisms}`,
fix import paths repo-wide, final `flutter test` + `flutter analyze`. (`boot`/splash has 0
design-system deps — untouched.)

**SDD mapping:** each table row in W0–W3 = one independent subagent task (canon spec →
Playwright+spec-viewer value check → TDD → impl → analyze). Intra-wave parallel; wave boundaries
serialize. W4 is serialized per screen.

## Risks & open questions

1. **`KaiSystemNote` vs `KaiSystemBubble`** overlap — likely dedupe to one (`kai_system_bubble`). Confirm at W2.
2. **React thumbs** — `kai_kai_bubble` meta-row (thumb-up/down in room.html) has **no `thumbUp`/`thumbDown` icon assets** (enum has 30, not these). If the react row is in scope, add 2 SVGs + enum values in W0; else omit the row.
3. **Sheet top radius = 24px** (off-scale, not r28). Add `r24` token or keep a local literal in `KaiSheetShell` only — decide at W1.
4. **Shadow/glow home** — chose a new `kai_shadow.dart` over polluting `KaiTide`. Confirm naming.
5. **Promotion churn** — the final flatten rewrites every `v3/` import path. Option to keep `v3/` permanently to avoid churn; decide at W4 (default: promote for a conventional tree).
6. **Canon verification** runs through Playwright MCP + spec-viewer at build time (CLAUDE.md mandate); needs the local static server (`new-design` on :8743, Node fallback if Python absent — audit hit this).

## Acceptance criteria / verification

- `flutter test` ≥299 passing at **every** wave boundary (never red between merges); `flutter analyze` → "No issues found".
- Zero hardcoded `Color/padding/radius/duration` outside token files within `v3/`.
- Zero cross-layer import violations (no atom→molecule); primitives importable by atoms.
- Each migrated screen visually matches canon via Playwright spec-viewer spot-check; manual `flutter run` of room/onboarding/nav/settings + `/_dev` showcases.
- Old `design_system/{atoms,molecules,organisms}` fully deleted; `v3` (promoted) is the sole component layer.
- Commands: `cp .env.example .env` (if needed) · `dart run build_runner build --delete-conflicting-outputs` · `flutter test` · `flutter analyze`.

## Execution

Execute via **subagent-driven-development**: fan-out one subagent per W0–W3 component task
(parallel within a wave, serialized at wave boundaries), two-stage review per task. W4 migration
runs serialized per screen. The design spec already captured the canon deltas; no re-derivation
needed — but per-component pixel/token values are confirmed via Playwright MCP + spec-viewer at
build time (CLAUDE.md mandate).
