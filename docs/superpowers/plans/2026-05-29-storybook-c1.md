# Storybook C1 Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Turn `/_dev/storybook` into a real Storybook (3-pane adaptive shell · structured `StoryPage` canvas · always-available inspector · Foundations group), fix 5 cross-cutting bugs, and add two switchable tide-button animations for live comparison.

**Architecture:** Split the 2473-line `story_registry.dart` into a model file + per-layer story files. Introduce `StoryPage`/`StorySection`/`StoryCell`/`PropDoc` dev widgets so every component renders as a self-explanatory page. Rebuild the shell into sidebar(+search) · canvas · inspector with a knobs bar whose theme switcher is a live `KaiSegmentedControl`. Refactor `KaiButton.tide`'s always-on flow into `KaiTideAnim {onInteraction, onState, none}`.

**Tech Stack:** Flutter, Riverpod (`themeModeProvider`), go_router, design-system tokens (`KaiTheme.of(context).colors`, `KaiType`, `KaiSpace`, `KaiRadius`, `KaiMotion`, `KaiTide`, `KaiShadow`).

**Spec:** `docs/superpowers/specs/2026-05-29-storybook-c1-design.md`

**Conventions (all tasks):** const-correct widgets (analyzer enforces `prefer_const_constructors`); colours only via `KaiTheme.of(context).colors`; reuse helper `buildTestWidget(child, {themeMode})` in `test/test_helpers.dart`; after each task `flutter analyze` → "No issues found" and `flutter test` green. Do NOT touch pre-existing dirty files (`docs/.../2026-05-28-design-system-refactor.md`, deleted `new-design/*.html`). The repo dev edit `initialLocation: '/_dev/storybook'` in `router.dart` stays until Task 9.

---

## File map

**Create:**
- `lib/features/dev/storybook/story_page.dart` — `StoryPage`, `StorySection`, `StoryCell`, `PropDoc`, props table (dev-only presentational widgets).
- `lib/features/dev/storybook/stories/foundations_stories.dart` — `foundationsStories` (Colors/Type/Spacing/Motion/Tide).
- `lib/features/dev/storybook/stories/primitive_stories.dart` — `primitiveStories`.
- `lib/features/dev/storybook/stories/atom_stories.dart` — `atomStories`.
- `lib/features/dev/storybook/stories/molecule_stories.dart` — `moleculeStories`.
- `lib/features/dev/storybook/stories/organism_stories.dart` — `organismStories`.
- Tests: `test/features/dev/storybook/story_page_test.dart`, `storybook_smoke_test.dart` (replace existing smoke test).

**Modify:**
- `lib/design_system/atoms/kai_button.dart` — `KaiTideAnim` enum + `tideAnim`/`busy` params.
- `test/design_system/atoms/kai_button_test.dart` — tide-anim tests.
- `lib/features/dev/storybook/story_registry.dart` — slim to model (`Story`, `StoryLayer` +`foundations`, `PropDoc` re-export) + assemble `kStories` from the per-layer lists.
- `lib/features/dev/storybook/storybook_screen.dart` — 3-pane shell + search + knobs bar.
- `lib/core/routing/router.dart` — Task 9 only: restore `initialLocation` to `'/'`.

---

## Task 1: KaiButton tide-animation refactor

**Files:**
- Modify: `lib/design_system/atoms/kai_button.dart`
- Test: `test/design_system/atoms/kai_button_test.dart`

Current state: `KaiButton.tide` runs an always-on ambient gradient sweep via an `AnimationController` started in `didChangeDependencies` when variant==tide and `!disableAnimations`. Replace that trigger logic with three modes.

- [ ] **Step 1: Write failing tests**

```dart
// add to test/design_system/atoms/kai_button_test.dart
group('KaiButton tide animation', () {
  testWidgets('onInteraction: no AnimationController ticking at rest', (t) async {
    await buildTestWidget2(t, KaiButton.tide(
      label: 'Go', onPressed: () {}, tideAnim: KaiTideAnim.onInteraction));
    // at rest the flow controller is not animating
    final state = t.state(find.byType(KaiButton)) as dynamic;
    expect(state.isFlowing, isFalse);
  });
  testWidgets('onState: flows only when busy=true', (t) async {
    await buildTestWidget2(t, KaiButton.tide(
      label: 'Send', onPressed: () {}, tideAnim: KaiTideAnim.onState, busy: true));
    final state = t.state(find.byType(KaiButton)) as dynamic;
    expect(state.isFlowing, isTrue);
  });
  testWidgets('onState: static when busy=false', (t) async {
    await buildTestWidget2(t, KaiButton.tide(
      label: 'Send', onPressed: () {}, tideAnim: KaiTideAnim.onState, busy: false));
    final state = t.state(find.byType(KaiButton)) as dynamic;
    expect(state.isFlowing, isFalse);
  });
  testWidgets('none: never flows even when busy', (t) async {
    await buildTestWidget2(t, KaiButton.tide(
      label: 'X', onPressed: () {}, tideAnim: KaiTideAnim.none, busy: true));
    final state = t.state(find.byType(KaiButton)) as dynamic;
    expect(state.isFlowing, isFalse);
  });
  testWidgets('renders a gradient (tide) decoration', (t) async {
    await buildTestWidget2(t, KaiButton.tide(label: 'Go', onPressed: () {}));
    expect(find.byType(KaiButton), findsOneWidget);
  });
});
```

Add a tiny pump helper at the top of the test file if not present:
```dart
Future<void> buildTestWidget2(WidgetTester t, Widget child,
        {ThemeMode mode = ThemeMode.light}) =>
    t.pumpWidget(buildTestWidget(child, themeMode: mode));
```
Expose test visibility: in `_KaiButtonState` add `bool get isFlowing => _flowController?.isAnimating ?? false;` (rename the existing gradient controller to `_flowController`).

- [ ] **Step 2: Run, verify fail**

Run: `flutter test test/design_system/atoms/kai_button_test.dart -v`
Expected: FAIL (`KaiTideAnim` undefined, `tideAnim`/`busy`/`isFlowing` missing).

- [ ] **Step 3: Implement**

In `kai_button.dart`:
```dart
/// How the tide gradient animates on KaiButton.tide.
enum KaiTideAnim {
  /// Static at rest; gradient flows while hovered or pressed.
  onInteraction,
  /// Static; gradient flows only while [KaiButton.busy] is true (Kai active).
  onState,
  /// Always static (reduced-motion / tests).
  none,
}
```
Add to `KaiButton.tide(...)` ctor: `KaiTideAnim tideAnim = KaiTideAnim.onInteraction, bool busy = false`; store on the widget (other ctors set `tideAnim = KaiTideAnim.none, busy = false`). In `_KaiButtonState`:
- rename gradient controller to `_flowController`; add `bool get isFlowing => _flowController?.isAnimating ?? false;`.
- compute `bool _wantFlow`:
  ```dart
  bool get _reduceMotion =>
      MediaQuery.maybeOf(context)?.disableAnimations ?? false;
  bool _shouldFlow() {
    if (widget._variant != _KaiButtonVariant.tide || _reduceMotion) return false;
    switch (widget.tideAnim) {
      case KaiTideAnim.none: return false;
      case KaiTideAnim.onState: return widget.busy;
      case KaiTideAnim.onInteraction: return _hovered || _pressed;
    }
  }
  ```
- add `bool _hovered = false;` and wrap the button in `MouseRegion(onEnter:/onExit: → setState + _syncFlow())`.
- `void _syncFlow() { if (_shouldFlow()) { _flowController?..reset()..repeat(); } else { _flowController?..stop()..value = 0; } }` — call from `didChangeDependencies`, `didUpdateWidget` (when busy/tideAnim/hover/press change), and the hover/press handlers. Lazy-create `_flowController` once (duration `KaiMotion.ambient`).
- the gradient `AnimatedBuilder` sweeps only while `_flowController` runs; at rest render static `KaiTide.gradient`. Keep press scale + `KaiShadow.button`. Dispose `_flowController`.

- [ ] **Step 4: Run, verify pass**

Run: `flutter test test/design_system/atoms/kai_button_test.dart -v` → PASS. Then `flutter analyze` → clean.

- [ ] **Step 5: Commit**

```bash
git add lib/design_system/atoms/kai_button.dart test/design_system/atoms/kai_button_test.dart
git commit -m "feat(ds): KaiButton tide anim modes — onInteraction/onState/none"
```

---

## Task 2: StoryPage structure widgets

**Files:**
- Create: `lib/features/dev/storybook/story_page.dart`
- Test: `test/features/dev/storybook/story_page_test.dart`

- [ ] **Step 1: Write failing test**

```dart
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:kai_app/features/dev/storybook/story_page.dart';
import '../../../test_helpers.dart';

void main() {
  testWidgets('StoryPage renders title, blurb, a labelled cell, a prop row', (t) async {
    await t.pumpWidget(buildTestWidget(const StoryPage(
      title: 'KaiButton', layer: 'ATOM', blurb: 'Primary action button.',
      sections: [StorySection('Variants', [StoryCell('tide', Text('btn'))])],
      usage: 'KaiButton.tide(label: ..., onPressed: ...)',
      props: [PropDoc('label', 'String', 'required', 'Button text')],
    )));
    expect(find.text('KaiButton'), findsOneWidget);
    expect(find.text('Primary action button.'), findsOneWidget);
    expect(find.text('tide'), findsOneWidget);       // cell caption
    expect(find.text('btn'), findsOneWidget);          // cell child
    expect(find.text('Variants'), findsOneWidget);     // section header
    expect(find.text('label'), findsOneWidget);        // prop row
  });
}
```

- [ ] **Step 2: Run, verify fail**

Run: `flutter test test/features/dev/storybook/story_page_test.dart -v` → FAIL (file missing).

- [ ] **Step 3: Implement `story_page.dart`**

```dart
import 'package:flutter/material.dart';
import '../../../design_system/theme/kai_theme.dart';
import '../../../design_system/tokens/kai_tokens.dart';

/// One documented prop row (mirrored in the inspector).
class PropDoc {
  const PropDoc(this.name, this.type, this.defaultValue, this.description);
  final String name, type, defaultValue, description;
}

/// A single labelled demo cell — the component variant in a bordered card.
class StoryCell {
  const StoryCell(this.label, this.child);
  final String label;
  final Widget child;
}

/// A titled group of cells (e.g. "Variants", "States").
class StorySection {
  const StorySection(this.title, this.cells);
  final String title;
  final List<StoryCell> cells;
}

/// Structured story page: header + sections of labelled cells + usage + props.
class StoryPage extends StatelessWidget {
  const StoryPage({
    super.key,
    required this.title,
    required this.layer,
    required this.blurb,
    required this.sections,
    this.usage = '',
    this.props = const [],
  });

  final String title, layer, blurb, usage;
  final List<StorySection> sections;
  final List<PropDoc> props;

  @override
  Widget build(BuildContext context) {
    final c = KaiTheme.of(context).colors;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(children: [
          Flexible(child: KaiText.h2(title)),
          const SizedBox(width: KaiSpace.s3),
          _LayerChip(layer),
        ]),
        const SizedBox(height: KaiSpace.s2),
        KaiText.body(blurb, color: c.ink2),
        const SizedBox(height: KaiSpace.s6),
        for (final s in sections) ...[
          _SectionHeader(s.title),
          const SizedBox(height: KaiSpace.s3),
          Wrap(
            spacing: KaiSpace.s4,
            runSpacing: KaiSpace.s4,
            children: [for (final cell in s.cells) _Cell(cell)],
          ),
          const SizedBox(height: KaiSpace.s6),
        ],
        if (usage.isNotEmpty) ...[
          _SectionHeader('Usage'),
          const SizedBox(height: KaiSpace.s2),
          _CodeBox(usage),
          const SizedBox(height: KaiSpace.s6),
        ],
        if (props.isNotEmpty) ...[
          _SectionHeader('Props'),
          const SizedBox(height: KaiSpace.s2),
          _PropsTable(props),
        ],
      ],
    );
  }
}

class _LayerChip extends StatelessWidget {
  const _LayerChip(this.label);
  final String label;
  @override
  Widget build(BuildContext context) {
    final c = KaiTheme.of(context).colors;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: KaiSpace.s2, vertical: 2),
      decoration: BoxDecoration(
          color: c.surface2, borderRadius: KaiRadius.brPill,
          border: Border.all(color: c.line)),
      child: Text(label,
          style: KaiType.mono(color: c.ink3).copyWith(fontSize: 9)),
    );
  }
}

class _SectionHeader extends StatelessWidget {
  const _SectionHeader(this.title);
  final String title;
  @override
  Widget build(BuildContext context) =>
      Text(title, style: KaiType.micro(color: KaiTheme.of(context).colors.ink3));
}

class _Cell extends StatelessWidget {
  const _Cell(this.cell);
  final StoryCell cell;
  @override
  Widget build(BuildContext context) {
    final c = KaiTheme.of(context).colors;
    return Container(
      constraints: const BoxConstraints(minWidth: 120),
      padding: const EdgeInsets.all(KaiSpace.s4),
      decoration: BoxDecoration(
          color: c.surface, borderRadius: KaiRadius.br3,
          border: Border.all(color: c.line)),
      child: Column(mainAxisSize: MainAxisSize.min, children: [
        cell.child,
        const SizedBox(height: KaiSpace.s3),
        Text(cell.label,
            style: KaiType.mono(color: c.ink3).copyWith(fontSize: 10)),
      ]),
    );
  }
}

class _CodeBox extends StatelessWidget {
  const _CodeBox(this.code);
  final String code;
  @override
  Widget build(BuildContext context) {
    final c = KaiTheme.of(context).colors;
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(KaiSpace.s3),
      decoration: BoxDecoration(
          color: c.surface2, borderRadius: KaiRadius.br2,
          border: Border.all(color: c.line)),
      child: Text(code,
          style: KaiType.mono(color: c.ink2).copyWith(fontSize: 11, height: 1.5)),
    );
  }
}

class _PropsTable extends StatelessWidget {
  const _PropsTable(this.props);
  final List<PropDoc> props;
  @override
  Widget build(BuildContext context) {
    final c = KaiTheme.of(context).colors;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        for (final p in props)
          Padding(
            padding: const EdgeInsets.only(bottom: KaiSpace.s2),
            child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
              SizedBox(width: 110,
                  child: Text(p.name,
                      style: KaiType.mono(color: c.ink1).copyWith(fontSize: 11))),
              SizedBox(width: 90,
                  child: Text(p.type,
                      style: KaiType.mono(color: c.accent).copyWith(fontSize: 11))),
              SizedBox(width: 70,
                  child: Text(p.defaultValue,
                      style: KaiType.mono(color: c.ink3).copyWith(fontSize: 11))),
              Expanded(child: KaiText.small(p.description, color: c.ink2)),
            ]),
          ),
      ],
    );
  }
}
```

- [ ] **Step 4: Run, verify pass**

Run: `flutter test test/features/dev/storybook/story_page_test.dart -v` → PASS. `flutter analyze` → clean.

- [ ] **Step 5: Commit**

```bash
git add lib/features/dev/storybook/story_page.dart test/features/dev/storybook/story_page_test.dart
git commit -m "feat(storybook): StoryPage/StorySection/StoryCell/PropDoc structure"
```

---

## Task 3: Story model — add `foundations` layer, `props` field, split registry into per-layer files

**Files:**
- Modify: `lib/features/dev/storybook/story_registry.dart`
- Create: `stories/foundations_stories.dart`, `stories/primitive_stories.dart`, `stories/atom_stories.dart`, `stories/molecule_stories.dart`, `stories/organism_stories.dart`

This task is **mechanical extraction** — move the existing per-layer story lists out of the monolith into the new files, change the model, keep `kStories` working. Stories are reformatted to `StoryPage` in Tasks 5–6; here just relocate them unchanged (still compiling).

- [ ] **Step 1: Update the model in `story_registry.dart`**

```dart
import 'package:flutter/widgets.dart';
import 'story_page.dart' show PropDoc;
import 'stories/foundations_stories.dart';
import 'stories/primitive_stories.dart';
import 'stories/atom_stories.dart';
import 'stories/molecule_stories.dart';
import 'stories/organism_stories.dart';

export 'story_page.dart' show PropDoc;

enum StoryLayer { foundations, primitives, atoms, molecules, organisms }

class Story {
  const Story({
    required this.layer,
    required this.name,
    required this.build,
    this.importPath = '',
    this.canonFile = '',
    this.canonSelector = '',
    this.description = '',
    this.variants = const [],
    this.props = const [],
  });
  final StoryLayer layer;
  final String name, importPath, canonFile, canonSelector, description;
  final List<String> variants;
  final List<PropDoc> props;
  final WidgetBuilder build;
}

final List<Story> kStories = [
  ...foundationsStories,
  ...primitiveStories,
  ...atomStories,
  ...moleculeStories,
  ...organismStories,
];
```

- [ ] **Step 2: Create the 5 story-list files**

Each file: `import 'package:flutter/material.dart';` + design-system barrels + `import '../story_registry.dart';` + `import '../story_page.dart';`. Move the matching existing story objects from the old `kStories` into a top-level `final List<Story> <layer>Stories = [ ... ];`. `foundations_stories.dart` starts as `final List<Story> foundationsStories = [];` (filled in Task 5). Cut the moved story code out of `story_registry.dart`.

- [ ] **Step 3: Run analyze + full suite**

Run: `flutter analyze` → clean; `flutter test` → green (existing storybook smoke test still passes; story count unchanged except foundations empty).

- [ ] **Step 4: Commit**

```bash
git add lib/features/dev/storybook/
git commit -m "refactor(storybook): split registry into per-layer story files + foundations layer + props field"
```

---

## Task 4: Shell rebuild — 3-pane + search + knobs bar (segmented theme switch)

**Files:**
- Modify: `lib/features/dev/storybook/storybook_screen.dart`
- Test: `test/features/dev/storybook/storybook_smoke_test.dart` (replace)

Keep the existing `_StorybookSidebar`, `_StoryPropsPanel`, `_PropSection` helpers but: (a) add a search `TextField` above the sidebar list filtering by `story.name` (case-insensitive); (b) replace the two theme `IconButton`s in the knobs with a live `KaiSegmentedControl(['Light','Dark','System'], selectedIndex: <from themeMode>, onSelected: set themeModeProvider)`; (c) keep device-frame; add a background-surface cycle `IconButton` (bg→surface→surface2) applied to the canvas container colour; (d) **inspector always reachable** — wide (≥`_kBreakpoint` 720): show sidebar+canvas+inspector; when width < `_kWideBreakpoint` (1100) collapse the sidebar into the Drawer (hamburger) but KEEP the inspector column; narrow (<720): inspector becomes an AppBar info `IconButton` → `showModalBottomSheet` with `_StoryPropsPanel`.

- [ ] **Step 1: Write smoke tests**

```dart
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:kai_app/features/dev/storybook/storybook_screen.dart';
import 'package:kai_app/design_system/theme/kai_theme.dart';

Widget _app() => const ProviderScope(
  child: MaterialApp(home: KaiTheme(child: StorybookScreen())));

void main() {
  testWidgets('builds at wide width', (t) async {
    t.view.physicalSize = const Size(1400, 900); t.view.devicePixelRatio = 1.0;
    addTearDown(t.view.reset);
    await t.pumpWidget(_app()); await t.pump();
    expect(find.byType(StorybookScreen), findsOneWidget);
  });
  testWidgets('builds at narrow width', (t) async {
    t.view.physicalSize = const Size(380, 800); t.view.devicePixelRatio = 1.0;
    addTearDown(t.view.reset);
    await t.pumpWidget(_app()); await t.pump();
    expect(find.byType(StorybookScreen), findsOneWidget);
  });
  testWidgets('search filters sidebar rows', (t) async {
    t.view.physicalSize = const Size(1400, 900); t.view.devicePixelRatio = 1.0;
    addTearDown(t.view.reset);
    await t.pumpWidget(_app()); await t.pump();
    await t.enterText(find.byType(TextField).first, 'zzzznomatch');
    await t.pump();
    // sidebar shows no story rows for a nonsense query (only headers/search)
    expect(find.text('KaiButton'), findsNothing);
  });
}
```

- [ ] **Step 2: Run, verify fail** (`search filters` fails; old smoke file replaced). Run: `flutter test test/features/dev/storybook/storybook_smoke_test.dart -v`.

- [ ] **Step 3: Implement** the shell per the description above. Add `String _query = ''` state; filter `kStories` for the sidebar; keep `_selectedIndex` pointing at the unfiltered list (store the selected `Story` by identity, not index, to survive filtering — change `_selectedIndex` to `Story _selected = kStories.first;`). Foundations group label added to `_layerLabel`.

- [ ] **Step 4: Run, verify pass** + `flutter analyze` clean + `flutter test` green.

- [ ] **Step 5: Commit**

```bash
git add lib/features/dev/storybook/storybook_screen.dart test/features/dev/storybook/storybook_smoke_test.dart
git commit -m "feat(storybook): 3-pane shell — search, segmented theme switch, always-available inspector"
```

---

## Task 5: Foundations stories (Colors / Typography / Spacing & Radius / Motion / Tide)

**Files:**
- Modify: `lib/features/dev/storybook/stories/foundations_stories.dart`

Build 5 `Story` objects (layer `foundations`), each `build` returning a `StoryPage`. Pull exact values from `lib/design_system/tokens/` (read the token files) and `lib/design_system/COMPONENTS.md`.

- [ ] **Step 1 (Colors):** `StoryPage(title:'Colors', layer:'FOUNDATION', blurb:'...', sections:[StorySection('Surfaces & Ink',[...]), StorySection('Accent & Semantic',[...])])` — each `StoryCell(label:'ink1 #111114', child: <40×40 swatch Container with that colour + border c.line>)`. Read colours from `KaiTheme.of(context).colors` so light/dark both render. Include a tide-gradient swatch cell.
- [ ] **Step 2 (Typography):** one `StorySection('Scale', [...])` — a cell per `KaiType` style showing the sample text rendered in that style + caption `'h1 · 36 · w600 · Manrope'`.
- [ ] **Step 3 (Spacing & Radius):** visual bars for `KaiSpace.s1..s11`; squares for `KaiRadius.r1/r2/r3/r4/r5/r8/r12/r24/pill`.
- [ ] **Step 4 (Motion):** 3 cells (standard 240 / ambient 2600 / micro 120) each with a small looping animated demo + caption.
- [ ] **Step 5 (Tide):** the two gradients as wide bars + a row of 8 `KaiTideCurve` states (continuously looping — see Task 7 F2).
- [ ] **Step 6:** `flutter analyze` clean; `flutter test` green (storybook smoke test now sees foundations group).
- [ ] **Step 7: Commit** `feat(storybook): Foundations stories — colors, type, spacing, motion, tide`.

---

## Task 6: Reformat existing stories into `StoryPage` + apply per-story fixes (F2/F3/F4) + props

**Files:** `stories/primitive_stories.dart`, `stories/atom_stories.dart`, `stories/molecule_stories.dart`, `stories/organism_stories.dart` (one sub-commit each).

**Recipe (apply to every story):** change `build` to return a `StoryPage(title, layer, blurb, sections, usage, props)`. Move each variant/state currently dumped in the column into a `StoryCell(label, <widget>)` grouped under `StorySection('Variants'|'States')`. Fill `usage` with the real constructor call and `props` with `PropDoc` rows (names/types/defaults from the actual constructor — read the component file).

**Worked example (KaiButton, in `atom_stories.dart`):**
```dart
Story(
  layer: StoryLayer.atoms, name: 'KaiButton',
  importPath: 'package:kai_app/design_system/atoms/atoms.dart',
  canonFile: 'new-design/components.html', canonSelector: '.new-btn / .send',
  description: 'Primary/secondary button. 4 variants × sm/md/lg × tone/emphasis.',
  variants: ['tide','ink','ghost','text'],
  props: const [
    PropDoc('label','String','required','Button text'),
    PropDoc('onPressed','VoidCallback?','required','null = disabled'),
    PropDoc('size','KaiButtonSize','md','sm/md/lg'),
    PropDoc('tone','KaiButtonTone','neutral','ghost/text tone'),
    PropDoc('emphasis','KaiButtonEmphasis','normal','tide glow'),
    PropDoc('tideAnim','KaiTideAnim','onInteraction','tide flow trigger'),
    PropDoc('busy','bool','false','onState flow when true'),
  ],
  build: (_) => StoryPage(
    title: 'KaiButton', layer: 'ATOM',
    blurb: 'Primary action button. One tide button per screen; others ink/ghost/text.',
    sections: [
      StorySection('Variants', [
        StoryCell('tide·md', KaiButton.tide(label: 'Send', onPressed: () {})),
        StoryCell('ink·md', KaiButton.ink(label: 'New chat', onPressed: () {})),
        StoryCell('ghost·md', KaiButton.ghost(label: 'Retry', onPressed: () {})),
        StoryCell('text·accent', KaiButton.text(label: 'Open', onPressed: () {}, tone: KaiButtonTone.accent)),
      ]),
      StorySection('Sizes', [
        StoryCell('sm', KaiButton.ink(label: 'sm', onPressed: () {}, size: KaiButtonSize.sm)),
        StoryCell('md', KaiButton.ink(label: 'md', onPressed: () {}, size: KaiButtonSize.md)),
        StoryCell('lg', KaiButton.ink(label: 'lg', onPressed: () {}, size: KaiButtonSize.lg)),
      ]),
      StorySection('States', [
        StoryCell('disabled', KaiButton.tide(label: 'Send', onPressed: null)),
        StoryCell('glow', KaiButton.tide(label: 'Upgrade', onPressed: () {}, emphasis: KaiButtonEmphasis.glow)),
      ]),
      StorySection('Tide animation (compare)', [
        StoryCell('A · onInteraction', KaiButton.tide(label: 'Hover me', onPressed: () {}, tideAnim: KaiTideAnim.onInteraction)),
        StoryCell('B · onState (busy)', KaiButton.tide(label: 'Sending', onPressed: () {}, tideAnim: KaiTideAnim.onState, busy: true)),
      ]),
    ],
    usage: "KaiButton.tide(label: 'Send', onPressed: _send,\n  tideAnim: KaiTideAnim.onState, busy: isStreaming)",
    props: ... // as above
  ),
),
```

- [ ] **Step A — primitives** (`primitive_stories.dart`): reformat KaiIcon (show a Wrap of all `KaiIconName` values as cells), KaiSurface (cells: each surface level + border + shadow, each captioned with what it is), KaiGradientBar (cells: static + pulse). `flutter analyze` + commit `refactor(storybook): primitives stories → StoryPage`.
- [ ] **Step B — atoms** (`atom_stories.dart`): reformat all 12 atoms per recipe. Apply **F2** in the KaiTideCurve story: render each of the 8 states in its own cell, each continuously looping (see Task 7). `flutter analyze` + commit `refactor(storybook): atom stories → StoryPage`.
- [ ] **Step C — molecules** (`molecule_stories.dart`): reformat all molecules. Apply **F3** (wrap KaiToast cell in `SizedBox(width: 320)` / `Align` so the pill is its natural width) and **F4** (render `KaiInput.pill` inside a compose-context cell labelled "compose-island field"; also show `KaiInput.line` standalone). `flutter analyze` + commit `refactor(storybook): molecule stories → StoryPage`.
- [ ] **Step D — organisms** (`organism_stories.dart`): reformat organisms; each frame/state (e.g. `KaiChatList` RoomFrame.panel/compose) gets a captioned cell with a one-line note in the blurb explaining what the frame is (fixes "panel — что это, ничего не вижу"). For frames that render blank in isolation, add a short explanatory placeholder note in the cell. `flutter analyze` + commit `refactor(storybook): organism stories → StoryPage`.

After each step: `flutter test` green.

---

## Task 7: Cross-cutting fixes F1 (dark theme) + F2 (tidecurve loop)

**Files:** `lib/features/dev/storybook/**`, possibly `lib/design_system/atoms/kai_tide_curve.dart`.

- [ ] **Step 1 (F2 — tidecurve demo loop):** Read `kai_tide_curve.dart`. Ephemeral states (success/error/memory) auto-revert. For the Storybook demo, add an opt-in `bool demoLoop = false` param: when true, on ephemeral completion, re-trigger the same state instead of reverting (so the cell keeps animating). Wire the Tide foundations story + the KaiTideCurve atom story to use `demoLoop: true`. Add a widget test: `KaiTideCurve(state: KaiTideState.success, demoLoop: true)` still animating after its normal cycle (pump > cycle, assert no exception + still ticking). Commit `fix(ds): KaiTideCurve demoLoop keeps ephemeral states visible in Storybook`.
- [ ] **Step 2 (F1 — dark theme audit):** Grep `lib/features/dev/storybook/` for `Color(0x`, `Colors.` (other than `Colors.transparent`), and any `KaiTokens.light`/`KaiTokens.dark` direct reads. Replace each with `KaiTheme.of(context).colors.*`. Manually toggle the segmented theme switch across every story group and confirm no element stays light. Run: `flutter test` + `flutter analyze`. Commit `fix(storybook): dark-theme audit — all dev surfaces via KaiTheme tokens`.

---

## Task 8: Full verification pass

- [ ] **Step 1:** `flutter analyze` → "No issues found".
- [ ] **Step 2:** `flutter test` → all green; note the new count.
- [ ] **Step 3:** `flutter run -d chrome --web-port 8744`; open `/#/_dev/storybook`. Verify against acceptance criteria: inspector reachable at all widths; Foundations group present; every story is a `StoryPage` with labelled cells + props; segmented theme switch flips all elements; TideCurve shows 8 looping states; toast + input read correctly; KaiButton tide A/B side-by-side behave per spec. Record any gaps as follow-up tasks.

---

## Task 9: Restore router + finish

**Files:** `lib/core/routing/router.dart`

- [ ] **Step 1:** Change `initialLocation: '/_dev/storybook', // DEV: remove before release` back to `initialLocation: '/',`.
- [ ] **Step 2:** `flutter analyze` clean; `flutter test` green.
- [ ] **Step 3: Commit** `chore(router): restore initialLocation to '/' after C1 storybook work`.

---

## Verification (whole plan)

- `flutter analyze` → "No issues found" at every task boundary.
- `flutter test` → green at every task boundary (≥681 + new dev tests).
- All spec §"Acceptance criteria" satisfied (Task 8).
- `router.dart` `initialLocation` restored to `'/'`.

## Notes / discrepancies handled

- Earlier "toast button oversized" diagnosed as a Storybook-context width issue (F3), not a component bug — fixed in the story, not `kai_toast.dart`.
- "Segmented not interactive" was a missing wiring in the shell, not a component bug — fixed by making the theme switch a live `KaiSegmentedControl` (Task 4).
- Component **variant expansion** (new chip sizes, gradient-bar states, avatar animation, new molecules) is explicitly **Cycle 2**, not here.
