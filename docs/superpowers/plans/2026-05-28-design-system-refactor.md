# Design-System Reusability & Fidelity Refactor — Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development
> (recommended) or superpowers:executing-plans to implement this plan task-by-task.
> Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Close the reuse-debt and token-discipline findings from the 2026-05-28
design-system audit — extend the atoms so bespoke re-implementations can be deleted,
fix the one layer inversion, centralise tokens, and remove dead code.

**Architecture:** Bottom-up. First settle 3 canon decisions (D1–D3) and add the missing
tokens. Then extend the `KaiButton`/`KaiButtonSend` atoms (full-width, tone, glow, motion
tokens). Then delete the 5 bespoke button re-implementations by routing them through the
extended atoms. Then a mechanical token-discipline sweep. Finally the structural fixes
(KaiBubble layer inversion, presenter extraction, dead-code removal). Each wave is
independently shippable and keeps `flutter test` green.

**Tech Stack:** Flutter, Riverpod, atomic design-system (`lib/design_system/`), tokens in
`lib/design_system/tokens/`, canon in `new-design/*.html`. Tests: `flutter test`
(baseline 299/299), `flutter analyze` (clean).

**Source of truth:** audit report `docs/superpowers/audits/2026-05-28-design-system-audit.md`;
canon mandate `new-design/CLAUDE.md`.

**Baseline before starting:**
```sh
cp .env.example .env            # if missing — flutter_test needs it
flutter pub get
dart run build_runner build --delete-conflicting-outputs
flutter test                    # expect 299/299
flutter analyze                 # expect "No issues found"
```

---

## Decisions (RESOLVED 2026-05-28)

User confirmed all three defaults: **D1** add `r1_5=8` + `r2_5=12` (snap 24→r5);
**D2** bubble canon = 13.5 (room), fix user-bubble 13→13.5; **D3** add
`KaiButton.tide(emphasis: glow)`, keep generic tide radius br3. The W0/W1 tasks below
stand as written. Record token changes in `new-design/CLAUDE.md` / `design-tokens.json`.

- **D1 — off-scale radii (8/12/24).** *Default: ADD tokens.* Canon uses 8px and 12px
  ~10×; add `KaiRadius.r1_5 = 8` and `KaiRadius.r2_5 = 12` (names provisional — see Task 1).
  24px appears once (`KaiBottomSheetShell`) → snap to `r5` (28) OR add `r4_5 = 24`;
  default snap to keep the scale tight. Reconcile `colors_and_type.css` / `design-tokens.json`.
- **D2 — bubble text size.** *Default: canon = 13.5 (room).* `components.html` 15px is
  catalog display only. Fix `KaiBubble.user` 13 → 13.5 to match `.kai`. Kai label `.who`
  = 9 (room) is canon; `components.html` 10 is the catalog outlier.
- **D3 — tide primary button.** *Default: align radius to canon + add a glow emphasis.*
  Money-gate canon = r10 + glow shadow (α0.384, blur ~18). Add
  `KaiButton.tide(emphasis: KaiEmphasis.glow)` and reconcile its radius with D1.

If the user rejects a default, adjust the dependent W1 task before implementing it.

---

## File map

**Tokens (create/modify):**
- `lib/design_system/tokens/kai_radius.dart` — add r1_5 (8) + r2_5 (12) per D1.
- `lib/design_system/tokens/kai_shadow.dart` — **new**: `KaiShadow.softTide` (the
  `0x2E2BA8C9` button shadow) + `KaiShadow.glowTide` (money-gate α0.384). B3, D3.
- `lib/design_system/tokens/kai_type.dart` — no change (sizes stay; bubble size is per-widget).

**Atoms (modify):**
- `kai_button.dart` — fullWidth, radius override, tone for ghost, glow emphasis, motion
  tokens, shadow token, optional `KaiIcon` reuse (B2, B3, B4, B5, D3, R1).
- `kai_button_send.dart` — defaults size 30 / iconSize 12; motion + shadow tokens (B1, B6, B3).
- `kai_bubble.dart` — decouple from `SourceCard` molecule; user fontSize 13→13.5 (R2, D2).
- `kai_toggle.dart`, `kai_bottom_sheet_shell.dart` — `circular(999)`→`brPill`; radius tokens (T2, D1).

**Molecules (modify):**
- `kai_toast.dart` — use `KaiTide.gradient`; extract overlay to `ToastController` (T1, R3).
- `alert_card.dart` — drop dead `action` param; CTA → `KaiButton` (R1).
- `kai_action_sheet.dart`, `kai_message_detail_sheet.dart` — extract `show()`/`maybePop()`
  to a presenter (R3).
- `compose_island.dart` — delete `.sheet` variant + its test (R4).

**Organisms (modify):**
- `chat_list.dart`, `edge_state_block.dart` — retry pills → `KaiButton.ghost(tone:, pill:)` (R1).
- `onboarding_card.dart` — `_OnboardingCTA` → `KaiButton(fullWidth:)` (R1).
- `nav_panel.dart` — `_SearchBox` → `KaiInput`; extract `_groupSessionsByDate` + move
  `TripInfo`/`SessionPreview` models out (R1, R3); adopt or delete `NavItem` (R5).

**New non-UI files:**
- `lib/core/util/session_grouping.dart` — `groupSessionsByDate` (moved out of nav_panel).
- `lib/core/models/nav_models.dart` — `TripInfo`, `SessionPreview` (moved out of nav_panel).
- `lib/design_system/molecules/toast_controller.dart` — overlay manager (moved out of KaiToast).

---

## Wave W0 — Token foundation

### Task 1: Add off-scale radius tokens (D1)

**Files:**
- Modify: `lib/design_system/tokens/kai_radius.dart`
- Test: `test/design_system/tokens/kai_radius_test.dart`

- [ ] **Step 1: Write the failing test**
```dart
import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:kai_app/design_system/tokens/kai_radius.dart';

void main() {
  test('off-scale canon radii exist as tokens', () {
    expect(KaiRadius.r1_5, 8.0);
    expect(KaiRadius.r2_5, 12.0);
    expect(KaiRadius.br1_5, BorderRadius.all(Radius.circular(8)));
    expect(KaiRadius.br2_5, BorderRadius.all(Radius.circular(12)));
  });
}
```
- [ ] **Step 2: Run — expect FAIL** `flutter test test/design_system/tokens/kai_radius_test.dart` (r1_5 undefined)
- [ ] **Step 3: Implement** — in `kai_radius.dart`, alongside r1..r5:
```dart
  static const double r1_5 = 8;   // canon: action-sheet rows, settings rows, segmented
  static const double r2_5 = 12;  // canon: new-btn, system-note, account-hero, cards
  static const BorderRadius br1_5 = BorderRadius.all(Radius.circular(r1_5));
  static const BorderRadius br2_5 = BorderRadius.all(Radius.circular(r2_5));
```
- [ ] **Step 4: Run — expect PASS**
- [ ] **Step 5: Sync canon** — add `--r-1-5: 8px; --r-2-5: 12px;` to `new-design/colors_and_type.css` and `design-tokens.json` (intentional token-file edit, allowed per root CLAUDE.md §locked-dirs).
- [ ] **Step 6: Commit** `git commit -m "feat(tokens): add r1_5/r2_5 for canon off-scale radii (D1)"`

### Task 2: Add shadow tokens (B3, D3)

**Files:**
- Create: `lib/design_system/tokens/kai_shadow.dart`
- Test: `test/design_system/tokens/kai_shadow_test.dart`

- [ ] **Step 1: Failing test**
```dart
import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:kai_app/design_system/tokens/kai_shadow.dart';

void main() {
  test('tide button shadows', () {
    expect(KaiShadow.softTide.first.color, const Color(0x2E2BA8C9));
    expect(KaiShadow.softTide.first.blurRadius, 8);
    expect(KaiShadow.glowTide.first.blurRadius, greaterThan(KaiShadow.softTide.first.blurRadius));
  });
}
```
- [ ] **Step 2: Run — expect FAIL**
- [ ] **Step 3: Implement** `kai_shadow.dart`:
```dart
import 'package:flutter/widgets.dart';

/// Tide button shadows. softTide = default CTA; glowTide = money-gate emphasis.
abstract final class KaiShadow {
  static const List<BoxShadow> softTide = [
    BoxShadow(color: Color(0x2E2BA8C9), blurRadius: 8, offset: Offset(0, 2)),
  ];
  // Canon money-gate: 0 4px 18px rgba(43,168,201,0.42) + 0 0 0 4px rgba(43,168,201,0.10)
  static const List<BoxShadow> glowTide = [
    BoxShadow(color: Color(0x6B2BA8C9), blurRadius: 18, offset: Offset(0, 4)),
    BoxShadow(color: Color(0x1A2BA8C9), blurRadius: 0, spreadRadius: 4),
  ];
}
```
- [ ] **Step 4: Run — expect PASS**
- [ ] **Step 5: Commit** `git commit -m "feat(tokens): KaiShadow.softTide/glowTide (B3, D3)"`

---

## Wave W1 — Atom API extensions (keystone — unblocks W2)

### Task 3: KaiButtonSend canon defaults + tokens (B1, B6, B3)

**Files:**
- Modify: `lib/design_system/atoms/kai_button_send.dart` (current: size 44 `:32`, iconSize 16 `:33`, shadow literal `:155`)
- Test: `test/design_system/atoms/kai_button_send_test.dart`

- [ ] **Step 1: Failing test**
```dart
testWidgets('KaiButtonSend default size is canon 30 with 12 icon', (t) async {
  await t.pumpWidget(_wrap(const KaiButtonSend(state: KaiSendState.ready, onPressed: null)));
  final box = t.widget<Container>(find.descendant(of: find.byType(KaiButtonSend), matching: find.byType(Container)).first);
  expect((box.constraints?.maxWidth ?? 0), 30); // size default
});
```
- [ ] **Step 2: Run — expect FAIL** (default is 44)
- [ ] **Step 3: Implement** — change defaults and use the shadow token:
  - `this.size = 30,` (was 44), `this.iconSize = 12,` (was 16).
  - Replace the inline `boxShadow: [BoxShadow(color: Color(0x2E2BA8C9), ...)]` (`_decoration`) with `boxShadow: KaiShadow.softTide` (import `../tokens/kai_shadow.dart`).
  - Replace pulse `Duration(milliseconds: 120)` (`:68`) with `KaiMotion.micro`.
- [ ] **Step 4: Run — expect PASS;** then full `flutter test` — fix any call sites that relied on the 44 default (search `KaiButtonSend(`; ComposeIsland passes explicit size, so likely none).
- [ ] **Step 5: Commit** `git commit -m "fix(atom): KaiButtonSend canon defaults 30/12 + KaiShadow/KaiMotion (B1,B6,B3)"`

### Task 4: KaiButton motion tokens + shadow token (B2, B3)

**Files:**
- Modify: `kai_button.dart` (press `Duration(200)`+`Curves.easeOut` `:109-112`; tide shadow `:147`)
- Test: `test/design_system/atoms/kai_button_test.dart`

- [ ] **Step 1: Failing test** — assert the press animation uses the micro duration:
```dart
testWidgets('KaiButton press uses KaiMotion.micro', (t) async {
  await t.pumpWidget(_wrap(KaiButton.tide(onPressed: () {}, label: 'x')));
  final scale = t.widget<AnimatedScale>(find.byType(AnimatedScale));
  expect(scale.duration, KaiMotion.micro);      // 120ms
  expect(scale.curve, KaiMotion.standardCurve);
});
```
- [ ] **Step 2: Run — expect FAIL** (200ms / easeOut)
- [ ] **Step 3: Implement** — in `build()`: `duration: KaiMotion.micro, curve: KaiMotion.standardCurve`; replace tide `boxShadow: [BoxShadow(color: Color(0x2E2BA8C9)...)]` with `KaiShadow.softTide`. Import kai_shadow.
- [ ] **Step 4: Run — expect PASS**, then `flutter test`.
- [ ] **Step 5: Commit** `git commit -m "fix(atom): KaiButton press via KaiMotion + KaiShadow.softTide (B2,B3)"`

### Task 5: KaiButton full-width + radius override (B5, R1 prerequisite)

**Files:**
- Modify: `kai_button.dart` (add params; label-variant `Container`/padding `:98-119`)
- Test: `test/design_system/atoms/kai_button_test.dart`

- [ ] **Step 1: Failing test**
```dart
testWidgets('KaiButton.ink1 fullWidth stretches + custom radius', (t) async {
  await t.pumpWidget(_wrap(SizedBox(width: 300,
    child: KaiButton.ink1(onPressed: () {}, label: 'Новый чат', fullWidth: true, radius: KaiRadius.br2_5))));
  final ctn = t.widget<Container>(find.descendant(of: find.byType(KaiButton), matching: find.byType(Container)).first);
  expect((ctn.decoration as BoxDecoration).borderRadius, KaiRadius.br2_5);
  // fullWidth => button width matches the 300 parent
  expect(t.getSize(find.byType(KaiButton)).width, 300);
});
```
- [ ] **Step 2: Run — expect FAIL** (no fullWidth/radius params)
- [ ] **Step 3: Implement** — add `final bool fullWidth;` (default false) and `final BorderRadius? radius;` to every constructor + fields. In `_buildDecoration`, use `radius ?? KaiRadius.br3`. In `build`, when `fullWidth`, wrap content row with `mainAxisSize: MainAxisSize.max` / set Container `width: double.infinity`.
- [ ] **Step 4: Run — expect PASS**, then `flutter test`.
- [ ] **Step 5: Commit** `git commit -m "feat(atom): KaiButton fullWidth + radius override (B5)"`

### Task 6: KaiButton.ghost tone + pill (R1 prerequisite for retry pills)

**Files:**
- Modify: `kai_button.dart` (ghost decoration `:161-165`, label color `:228-229`)
- Test: `test/design_system/atoms/kai_button_test.dart`

- [ ] **Step 1: Failing test**
```dart
testWidgets('KaiButton.ghost tone=negative pill renders coral border + pill radius', (t) async {
  await t.pumpWidget(_wrap(KaiButton.ghost(onPressed: () {}, label: 'повторить',
    tone: KaiButtonTone.negative, pill: true)));
  final ctn = t.widget<Container>(find.descendant(of: find.byType(KaiButton), matching: find.byType(Container)).first);
  final dec = ctn.decoration as BoxDecoration;
  expect(dec.borderRadius, KaiRadius.brPill);
  expect(dec.border!.top.color, _tokens(t).colors.negative);
});
```
- [ ] **Step 2: Run — expect FAIL**
- [ ] **Step 3: Implement** — add `enum KaiButtonTone { neutral, warning, negative }` and `final KaiButtonTone tone;` (default neutral) + `final bool pill;` (default false) to `.ghost`. Tone→color map: neutral=`c.line`/`c.ink1`, warning=`c.warning`, negative=`c.negative` (border + text). When `pill`, radius=`brPill`.
- [ ] **Step 4: Run — expect PASS**, then `flutter test`.
- [ ] **Step 5: Commit** `git commit -m "feat(atom): KaiButton.ghost tone + pill (R1)"`

### Task 7: KaiButton.tide glow emphasis (D3)

**Files:**
- Modify: `kai_button.dart` (tide decoration `:142-152`)
- Test: `test/design_system/atoms/kai_button_test.dart`

- [ ] **Step 1: Failing test**
```dart
testWidgets('KaiButton.tide emphasis=glow uses glow shadow', (t) async {
  await t.pumpWidget(_wrap(KaiButton.tide(onPressed: () {}, label: 'Да, бронируй', emphasis: KaiEmphasis.glow)));
  final dec = (t.widget<Container>(find.descendant(of: find.byType(KaiButton), matching: find.byType(Container)).first).decoration) as BoxDecoration;
  expect(dec.boxShadow, KaiShadow.glowTide);
});
```
- [ ] **Step 2: Run — expect FAIL**
- [ ] **Step 3: Implement** — `enum KaiEmphasis { normal, glow }`, `final KaiEmphasis emphasis;` (default normal) on `.tide`; decoration shadow = `emphasis == glow ? KaiShadow.glowTide : KaiShadow.softTide`. Set tide radius default per D1 outcome (r10 → add `br2`? canon money-gate=10=`br2`; keep `br3` for generic tide unless D3 says align — default: keep `br3`, glow is the emphasis).
- [ ] **Step 4: Run — expect PASS**, then `flutter test`.
- [ ] **Step 5: Commit** `git commit -m "feat(atom): KaiButton.tide glow emphasis (D3)"`

### Task 8: De-duplicate inline SVG painting (B4)

**Files:**
- Modify: `kai_button.dart` (`_labelAndIcon` `:195`, `_iconOnly` `:215`), `kai_button_send.dart` (`:121`)
- Create: `lib/design_system/atoms/_kai_svg.dart` — tiny shared painter helper.
- Test: existing button tests must stay green.

- [ ] **Step 1:** Create `_kai_svg.dart`:
```dart
import 'package:flutter/widgets.dart';
import 'package:flutter_svg/flutter_svg.dart';

/// Shared SVG glyph painter for atoms (avoids 3× duplicated SvgPicture.asset).
Widget kaiSvg(String asset, {required double size, required Color color}) =>
    SvgPicture.asset('assets/icons/$asset.svg', width: size, height: size,
        colorFilter: ColorFilter.mode(color, BlendMode.srcIn));
```
- [ ] **Step 2:** Replace the 3 inline `SvgPicture.asset(...)` sites with `kaiSvg(widget.icon!.assetName, size: ..., color: ...)` (KaiButton ×2) and `kaiSvg('arrow-up', size: widget.iconSize, color: iconColor)` (KaiButtonSend).
- [ ] **Step 3: Run** `flutter test` (button tests stay green) + `flutter analyze`.
- [ ] **Step 4: Commit** `git commit -m "refactor(atom): shared kaiSvg painter, dedupe 3× SvgPicture (B4)"`

---

## Wave W2 — Delete bespoke button re-implementations (consumes W1)

### Task 9: onboarding `_OnboardingCTA` → KaiButton (R1)

**Files:** Modify `lib/design_system/organisms/onboarding_card.dart` (`_OnboardingCTA` `:114-192`)
- [ ] **Step 1:** Replace `_OnboardingCTA(...)` usage with
  `KaiButton.tide(onPressed: onComplete, label: cta, fullWidth: true)` for the welcome step
  and `KaiButton.ink1(onPressed: onComplete, label: cta, fullWidth: true)` for others
  (the gradient-vs-ink1 toggle at `:97` maps to `.tide` vs `.ink1`).
- [ ] **Step 2:** Delete the `_OnboardingCTA` StatefulWidget class (`:114-192`) and its bare `Duration(200)`/`Curves.easeOut`.
- [ ] **Step 3: Run** `flutter test` + `flutter analyze`; visually re-check onboarding canon (`onboarding.html`) via spec-viewer if available.
- [ ] **Step 4: Commit** `git commit -m "refactor(onboarding): CTA reuses KaiButton fullWidth, drop _OnboardingCTA (R1)"`

### Task 10: retry pills → KaiButton.ghost(tone:, pill:) (R1)

**Files:** Modify `chat_list.dart` (`_ErrorFrame` retry `:640-682`, tone coral/negative), `edge_state_block.dart` (`_OfflineSurface` retry `:125-155`, tone warning)
- [ ] **Step 1:** In `chat_list._ErrorFrame`, replace the bespoke `GestureDetector`+`Container` pill with `KaiButton.ghost(onPressed: onRetry, label: l10n.retry, tone: KaiButtonTone.negative, pill: true)`.
- [ ] **Step 2:** In `edge_state_block._OfflineSurface`, replace its bespoke pill with `KaiButton.ghost(onPressed: onRetry, label: ..., tone: KaiButtonTone.warning, pill: true)`.
- [ ] **Step 3: Run** `flutter test` + `flutter analyze`.
- [ ] **Step 4: Commit** `git commit -m "refactor: retry pills reuse KaiButton.ghost(tone,pill) (R1)"`

### Task 11: AlertCard CTA → KaiButton; drop dead `action` param (R1)

**Files:** Modify `alert_card.dart` (dead `action` `:29-31,50-51`; bespoke CTA `:284-305`)
- [ ] **Step 1:** Remove the `action` constructor param + field (verify no call site sets it: grep `AlertCard(`).
- [ ] **Step 2:** Replace the bespoke CTA pill with `KaiButton.tide(onPressed: onCtaTap, label: ctaLabel)` (or `.ink1` if canon CTA is solid — confirm against `notifications-chat.html`).
- [ ] **Step 3: Run** `flutter test` + `flutter analyze`.
- [ ] **Step 4: Commit** `git commit -m "refactor(alert): CTA reuses KaiButton, drop dead action param (R1)"`

### Task 12: nav_panel `_SearchBox` → KaiInput (R1)

**Files:** Modify `nav_panel.dart` (`_SearchBox` `:330-367`)
- [ ] **Step 1:** Replace `_SearchBox` internals with `KaiInput`/`KaiTextField` (pill radius, leading search icon via the row, placeholder from l10n). Keep the controller/onChanged wiring.
- [ ] **Step 2: Run** `flutter test` + `flutter analyze`.
- [ ] **Step 3: Commit** `git commit -m "refactor(nav): search reuses KaiInput (R1)"`

---

## Wave W3 — Token-discipline sweep

### Task 13: KaiToast use KaiTide.gradient (T1, HIGH)

**Files:** Modify `kai_toast.dart` (HEX gradient `:402-404`)
- [ ] **Step 1: Failing test** — assert the memory-toast decoration uses `KaiTide.gradient` (compare `gradient` field equality).
- [ ] **Step 2:** Replace the `LinearGradient(colors: [Color(0xFF1B4FB0), Color(0xFF2BA8C9), Color(0xFFF4B589)], ...)` with `KaiTide.gradient`.
- [ ] **Step 3: Run — PASS;** `flutter test`.
- [ ] **Step 4: Commit** `git commit -m "fix(toast): reuse locked KaiTide.gradient (T1)"`

### Task 14: `circular(999)` → `KaiRadius.brPill`/`pill` sweep (T2)

**Files & exact sites:** `kai_toggle.dart:41`, `kai_bottom_sheet_shell.dart:48`,
`kai_toast.dart:208,306,426`, `alert_card.dart:293`, `nav_panel.dart:551`,
`onboarding_card.dart:721,763`, `kai_account_hero.dart:126`.
- [ ] **Step 1:** At each site, replace `BorderRadius.circular(999)` → `KaiRadius.brPill`
  and `Radius.circular(999)` → `Radius.circular(KaiRadius.pill)` (import kai_radius where needed).
- [ ] **Step 2: Run** `flutter test` + `flutter analyze`.
- [ ] **Step 3: Commit** `git commit -m "refactor(tokens): brPill for all circular(999) sites (T2)"`

### Task 15: off-scale literal radii → r1_5/r2_5 tokens (T3, depends D1)

**Files & sites (radius 8 → br1_5):** `kai_segmented_control.dart:34`, `kai_settings_row.dart:98`,
`kai_action_sheet.dart:108`(10→br2), `kai_message_detail_sheet.dart:281`,
`alert_card.dart` icon-box `:190`(5→r1≈6, confirm). **(radius 12 → br2_5):**
`kai_system_note.dart:71`, `kai_account_hero.dart:46`, `kai_settings_group.dart:67`,
`onboarding_card.dart:150,155`, `chat_list.dart:241`, `edge_state_block.dart:84`,
`nav_panel.dart:445`. **(24):** `kai_bottom_sheet_shell.dart:30-31` → `br5`(28) per D1 snap, or new token.
- [ ] **Step 1:** Replace each literal with the matching token; for genuinely unique
  off-scale values (3,4,5,9) leave a `// canon px, no token` comment.
- [ ] **Step 2: Run** `flutter test` + `flutter analyze`.
- [ ] **Step 3: Commit** `git commit -m "refactor(tokens): map off-scale radii to r1_5/r2_5 (T3,D1)"`

### Task 16: motion literals → KaiMotion (T4)

**Files & sites:** `onboarding_card.dart:169,717,758` (200→micro/standard), `kai_toast.dart:108` (220→`KaiMotion.standard`? confirm intent), bare `Curves.easeInOut/easeOut` in `chat_list.dart:406`, `onboarding_card.dart:170`.
- [ ] **Step 1:** Replace literal `Duration(milliseconds: N)` with the nearest `KaiMotion.*`
  (200/220→`standard`=240 unless the 0.95 ratio matters; document any deliberate off-token).
  Replace bare `Curves.*` with `KaiMotion.standardCurve` where it's UI motion.
- [ ] **Step 2: Run** `flutter test` + `flutter analyze`.
- [ ] **Step 3: Commit** `git commit -m "refactor(motion): route literals through KaiMotion (T4)"`

> **T5 (raw spacing) and T6 (raw fontSize)** are LOW. Defer to an opportunistic cleanup
> (own commit per file when touched). Off-grid canon values (7/9/11/13.5px) stay literal
> with a `// canon px` comment; only on-scale values map to `KaiSpace`/`KaiType`. Not a
> blocking task.

---

## Wave W4 — Structural / layer fixes

### Task 17: KaiBubble — break atom→molecule layer inversion (R2, HIGH)

**Files:** Modify `kai_bubble.dart` (import `:4`; `.kai` ctor `sources` param); update call sites.
- [ ] **Step 1: Failing test** — a structural guard:
```dart
test('kai_bubble.dart does not import the molecules layer', () {
  final src = File('lib/design_system/atoms/kai_bubble.dart').readAsStringSync();
  expect(src.contains('molecules/'), isFalse);
});
```
- [ ] **Step 2: Run — expect FAIL** (imports `../molecules/source_card.dart`)
- [ ] **Step 3: Implement** — change `.kai`'s `sources` type from `List<SourceCard>` to
  `List<Widget>? sources` and remove the molecule import; the bubble just renders the
  provided widgets in its column. Callers (e.g. `chat_list.dart`) now build the
  `SourceCard` widgets and pass them in. Also set user fontSize 13→13.5 (D2).
- [ ] **Step 4: Run — expect PASS;** `flutter test` + `flutter analyze`; fix call sites.
- [ ] **Step 5: Commit** `git commit -m "refactor(atom): KaiBubble takes List<Widget> sources, fix layer inversion + 13.5 (R2,D2)"`

### Task 18: Extract sheet presenters (R3)

**Files:** `kai_action_sheet.dart` (`show()`/`maybePop()` `:60,83`), `kai_message_detail_sheet.dart` (`:94,132`)
- [ ] **Step 1:** Move the static `show()` (the `showModalBottomSheet` call) to a
  caller-side helper or keep `show()` but remove the in-widget `Navigator.maybePop()` —
  instead have the row invoke an `onSelected`/`onClose` callback the caller wires to pop.
  Widget becomes pure (renders rows + fires callbacks); navigation lives at the call site.
- [ ] **Step 2: Run** `flutter test` + `flutter analyze`.
- [ ] **Step 3: Commit** `git commit -m "refactor(sheets): pure widgets + caller-side nav (R3)"`

### Task 19: Extract KaiToast overlay → ToastController (R3)

**Files:** Modify `kai_toast.dart` (`_KaiToastOverlay` `:435-494`); Create `toast_controller.dart`
- [ ] **Step 1:** Move `_KaiToastOverlay` (Overlay/OverlayEntry/Timer/statics) into
  `lib/design_system/molecules/toast_controller.dart` as `ToastController` (or a Riverpod
  service). `KaiToast` stays a pure presentational widget; the controller shows it.
- [ ] **Step 2: Run** `flutter test` + `flutter analyze`; update callers of `KaiToast.show`-style API.
- [ ] **Step 3: Commit** `git commit -m "refactor(toast): extract overlay to ToastController (R3)"`

### Task 20: Move nav_panel logic + models out (R3)

**Files:** `nav_panel.dart` (`_groupSessionsByDate` `:59-101`, `TripInfo` `:12`, `SessionPreview` `:33`); Create `lib/core/util/session_grouping.dart`, `lib/core/models/nav_models.dart`
- [ ] **Step 1: Failing test** — `test/core/util/session_grouping_test.dart` asserting date buckets (today/yesterday/prev-7/older) for fixed inputs with an injected `now`.
- [ ] **Step 2: Implement** — move `groupSessionsByDate(List<SessionPreview>, {DateTime now})` to `session_grouping.dart` (inject `now`, no `DateTime.now()` inside); move `TripInfo`/`SessionPreview` to `nav_models.dart`. `nav_panel` imports them.
- [ ] **Step 3: Run — PASS;** `flutter test` + `flutter analyze`.
- [ ] **Step 4: Commit** `git commit -m "refactor(nav): extract session grouping + models from organism (R3)"`

### Task 21: ComposeIsland — remove dead `.sheet` variant (R4)

**Files:** `compose_island.dart` (`.sheet` branch `:102-125`, enum `:26`); `test/design_system/molecules/compose_island_test.dart:164`
- [ ] **Step 1:** Confirm no production reference (grep `ComposeIslandVariant.sheet` in `lib/`). Delete the `.sheet` enum value, the `isPill ? ... : ...` sheet branch, and the test at `:164` (or convert it to assert `.pill` only).
- [ ] **Step 2: Run** `flutter test` + `flutter analyze`.
- [ ] **Step 3: Commit** `git commit -m "refactor(compose): remove dead .sheet variant (R4)"`

### Task 22: NavItem — adopt in nav_panel or remove (R5)

**Files:** `nav_panel.dart` rows; `nav_item.dart`
- [ ] **Step 1: Decide** (default: ADOPT). Refactor `_FolderRow`/`_ChatRow`/`_AppRow` to
  use the `NavItem` molecule where shape matches; if shapes genuinely differ, instead
  DELETE `nav_item.dart` + its showcase/test as unused product code.
- [ ] **Step 2: Run** `flutter test` + `flutter analyze`.
- [ ] **Step 3: Commit** `git commit -m "refactor(nav): adopt NavItem molecule (R5)"` (or `"chore: remove unused NavItem (R5)"`)

---

## B7 (focus ring) — deferred

Mobile-first; no canon focus state. Track as a backlog item if web/desktop support lands.
Not in this plan.

---

## Final verification (after all waves)

- [ ] `dart run build_runner build --delete-conflicting-outputs`
- [ ] `flutter test` — expect ≥ 299 passing (new tests added; none removed except dead `.sheet`/`action`).
- [ ] `flutter analyze` — "No issues found".
- [ ] Re-run the audit's visual-confirm pass (spec-viewer + Playwright) on components / room /
  edge-states; diff against `canon-*.png` baselines — confirm no regressions.
- [ ] Update `docs/superpowers/audits/2026-05-28-design-system-audit.md` findings → resolved.

---

## Self-review (author checklist — done)

- **Spec coverage:** R1 (T9-12), R2 (T17), R3 (T18-20), R4 (T21), R5 (T22); T1 (T13),
  T2 (T14), T3 (T15), T4 (T16), T5/T6 (deferred note); B1/B6 (T3), B2 (T4), B3 (T2/T3/T4),
  B4 (T8), B5 (T5), B7 (deferred); D1 (T1), D2 (T17), D3 (T2/T7). All findings mapped.
- **Placeholders:** none — every code task shows code; sweeps enumerate exact sites.
- **Type consistency:** `KaiButtonTone`, `KaiEmphasis`, `KaiShadow.softTide/glowTide`,
  `KaiRadius.r1_5/r2_5/br1_5/br2_5`, `kaiSvg(...)`, `groupSessionsByDate` used consistently
  across tasks.
- **Note:** consumer-edit tasks (W2/W4) cite current file:line from the audit; the executor
  confirms surrounding code against source before applying the shown target code.
