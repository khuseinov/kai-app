# Storybook-review fixes Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Resolve the five storybook-review findings (R1 badge, R2 compose-island redesign, R3 toast, R4 fork card, R5 voice transcript/karaoke) so every component is faithful to its `new-design/` canon and the Storybook renders correctly.

**Architecture:** Pure-presentational design-system widgets under `lib/design_system/{atoms,molecules}`. Each fix is one component, TDD'd against canon values recorded in `lib/design_system/COMPONENTS.md §5.1` and the R2 spec (`docs/superpowers/specs/2026-05-30-kai-compose-island-redesign-design.md`). Tokens only (`KaiTheme.of(context).colors.*`, `KaiType/KaiSpace/KaiRadius/KaiMotion/KaiTide/KaiShadow`); canon sub-token literals documented inline. Reduced-motion → static.

**Tech Stack:** Flutter (Dart), Riverpod, `flutter_test`, custom `KaiTheme` InheritedWidget, `flutter_svg` icons. Tests use `buildTestWidget` from `test/test_helpers.dart`.

**Baseline:** 838 tests green, `flutter analyze` clean, branch `storybook-review-fixes`.

**Conventions for every task:**
- Run `flutter test <file>` for the task's test, and `flutter analyze` before each commit.
- Sub-commit per component with `Co-Authored-By: Claude Opus 4.8 (1M context) <noreply@anthropic.com>`.
- Update the component's Storybook story + the matching `COMPONENTS.md` note/§5.1 status when the fix lands.
- Never hard-code colours/padding outside token files; document canon literals inline as the codebase already does.

**Task order (build sequence):** R2 (Tasks 1–3, the spec'd headline) → R4 fork (Tasks 4–7) → R5 voice (Tasks 8–9) → R3 toast (Task 10) → R1 badge (Task 11, needs live diagnosis). Order is flexible; the suite stays green after every sub-commit.

---

## File structure

| File | Responsibility | Tasks |
|---|---|---|
| `assets/icons/waveform.svg` (new) | voice-Kai glyph | 1 |
| `lib/design_system/primitives/kai_icon.dart` | add `waveform` enum entry | 1 |
| `lib/design_system/molecules/kai_compose_island.dart` | rebuilt composer (composable API, swap, offline, streaming) | 2 |
| `lib/features/room/room_screen.dart` | migrate call site to new API | 3 |
| `lib/features/dev/storybook/stories/molecule_stories.dart` | compose + toast story rewrites | 3, 10 |
| `lib/design_system/atoms/kai_fork_chip.dart` | mono/uppercase/warn tone/border | 4 |
| `lib/design_system/atoms/kai_fork_score_dots.dart` | tide-2 fill + optional `sl` label | 5 |
| `lib/design_system/atoms/kai_fork_price_delta.dart` (new) | `.fc-delta` price-change pill | 6 |
| `lib/design_system/atoms/atoms.dart` | export new atom | 6 |
| `lib/design_system/molecules/kai_fork_card.dart` | price-row, `.fc-sw` footer, badge "✓", `.fresh`, win-col gradient | 7 |
| `lib/design_system/atoms/kai_karaoke_text.dart` | ls/lh/now-radius | 8 |
| `lib/design_system/molecules/kai_transcript_view.dart` | rail + dots + who + mono ts + body colours | 9 |
| `lib/design_system/molecules/kai_toast.dart` | compact vs rich/action archetypes | 10 |
| `lib/features/dev/storybook/story_page.dart` | `_Cell` fix for badge sizing | 11 |
| `test/design_system/...` mirrors | tests per component | all |

---

## Task 1: Add `KaiIconName.waveform` (voice-Kai glyph)

**Files:**
- Create: `assets/icons/waveform.svg`
- Modify: `lib/design_system/primitives/kai_icon.dart` (enum, after `stop`)

- [ ] **Step 1: Inspect an existing icon SVG to match conventions**

Run: `Read assets/icons/mic.svg`
Expected: confirm attribute set (viewBox, `fill="none"`, `stroke="currentColor"`, `stroke-width`, `stroke-linecap`). Mirror exactly.

- [ ] **Step 2: Create the waveform SVG**

`assets/icons/waveform.svg` — four rounded vertical bars of varying height (a voice waveform). Use the SAME attribute conventions confirmed in Step 1 (adjust if `mic.svg` differs):

```svg
<svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round">
  <line x1="5" y1="10" x2="5" y2="14"/>
  <line x1="10" y1="6" x2="10" y2="18"/>
  <line x1="15" y1="8" x2="15" y2="16"/>
  <line x1="20" y1="11" x2="20" y2="13"/>
</svg>
```

- [ ] **Step 3: Add the enum entry**

In `lib/design_system/primitives/kai_icon.dart`, add after the `stop('stop')` entry (keep the existing trailing format):

```dart
  stop('stop'),
  waveform('waveform');
```

(If `stop` is the last entry it ends with `;` — move the `;` to `waveform`.)

- [ ] **Step 4: Verify asset is bundled**

Run: `Grep "assets/icons" pubspec.yaml`
Expected: `assets/icons/` directory is declared (glob). If individual files are listed, add `assets/icons/waveform.svg`.

- [ ] **Step 5: Smoke test the icon renders**

Add to `test/design_system/primitives/kai_icon_test.dart` (create if absent, else append):

```dart
testWidgets('waveform icon renders', (tester) async {
  await tester.pumpWidget(buildTestWidget(
    const KaiIcon(KaiIconName.waveform, size: 16),
  ));
  expect(find.byType(KaiIcon), findsOneWidget);
});
```

- [ ] **Step 6: Run + analyze**

Run: `flutter test test/design_system/primitives/kai_icon_test.dart` → PASS
Run: `flutter analyze` → No issues found

- [ ] **Step 7: Commit**

```bash
git add assets/icons/waveform.svg lib/design_system/primitives/kai_icon.dart test/design_system/primitives/kai_icon_test.dart pubspec.yaml
git commit -m "feat(ds): add KaiIconName.waveform for voice-Kai affordance"
```

---

## Task 2: Rebuild `KaiComposeIsland` (R2)

**Files:**
- Modify (full rewrite): `lib/design_system/molecules/kai_compose_island.dart`
- Test: `test/design_system/molecules/kai_compose_island_test.dart`

Implements the approved spec: composable callbacks, Variant-1 swap, O-A offline, streaming collapse. Removes `enum KaiComposeMode`.

- [ ] **Step 1: Read the current test + helpers**

Run: `Read test/design_system/molecules/kai_compose_island_test.dart` and `Read test/test_helpers.dart`
Expected: understand `buildTestWidget` signature and existing assertions (these will be replaced).

- [ ] **Step 2: Write the failing tests**

Replace `test/design_system/molecules/kai_compose_island_test.dart` with:

```dart
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:kai_app/design_system/atoms/atoms.dart';
import 'package:kai_app/design_system/molecules/kai_compose_island.dart';
import 'package:kai_app/design_system/primitives/primitives.dart';
import '../../test_helpers.dart';

KaiIcon? _iconOf(WidgetTester t, KaiIconName name) {
  return t.widgetList<KaiIcon>(find.byType(KaiIcon))
      .cast<KaiIcon?>()
      .firstWhere((i) => i!.name == name, orElse: () => null);
}

void main() {
  testWidgets('empty field shows mic, not send', (tester) async {
    final c = TextEditingController();
    await tester.pumpWidget(buildTestWidget(KaiComposeIsland(
      controller: c, onSend: () {}, onMicTap: () {}, onVoiceTap: () {},
    )));
    expect(_iconOf(tester, KaiIconName.mic), isNotNull);
    expect(find.byType(KaiSendButton), findsNothing);
  });

  testWidgets('typing swaps mic → send', (tester) async {
    final c = TextEditingController();
    await tester.pumpWidget(buildTestWidget(KaiComposeIsland(
      controller: c, onSend: () {}, onMicTap: () {}, onVoiceTap: () {},
    )));
    c.text = 'рейс в Токио';
    await tester.pump(const Duration(milliseconds: 300));
    expect(find.byType(KaiSendButton), findsOneWidget);
    expect(_iconOf(tester, KaiIconName.mic), isNull);
  });

  testWidgets('voice + add hidden when callbacks null', (tester) async {
    final c = TextEditingController();
    await tester.pumpWidget(buildTestWidget(KaiComposeIsland(
      controller: c, onSend: () {},
    )));
    expect(_iconOf(tester, KaiIconName.waveform), isNull);
    expect(_iconOf(tester, KaiIconName.plus), isNull);
    expect(_iconOf(tester, KaiIconName.mic), isNull);
  });

  testWidgets('voice + add shown when callbacks set', (tester) async {
    final c = TextEditingController();
    await tester.pumpWidget(buildTestWidget(KaiComposeIsland(
      controller: c, onSend: () {}, onAddTap: () {}, onVoiceTap: () {}, onMicTap: () {},
    )));
    expect(_iconOf(tester, KaiIconName.waveform), isNotNull);
    expect(_iconOf(tester, KaiIconName.plus), isNotNull);
  });

  testWidgets('streaming collapses to stop, hides field', (tester) async {
    final c = TextEditingController(text: 'x');
    var stopped = false;
    await tester.pumpWidget(buildTestWidget(KaiComposeIsland(
      controller: c, onSend: () {}, onStop: () => stopped = true,
      sendState: KaiSendState.streaming,
    )));
    expect(find.byType(TextField), findsNothing);
    final stopBtn = find.byType(KaiSendButton);
    expect(stopBtn, findsOneWidget);
    await tester.tap(stopBtn);
    expect(stopped, isTrue);
  });

  testWidgets('offline uses warning not negative, keeps field enabled', (tester) async {
    final c = TextEditingController();
    await tester.pumpWidget(buildTestWidget(KaiComposeIsland(
      controller: c, onSend: () {}, offline: true,
    )));
    // amber clock affordance appears only with text; empty offline shows hint.
    expect(find.text('оффлайн — отправлю, когда вернётся сеть'), findsOneWidget);
    // no coral icon anywhere
    expect(_iconOf(tester, KaiIconName.info), isNull);
  });

  testWidgets('offline + text shows queue affordance, fires onQueue', (tester) async {
    final c = TextEditingController(text: 'позже');
    var queued = false;
    await tester.pumpWidget(buildTestWidget(KaiComposeIsland(
      controller: c, onSend: () {}, offline: true, onQueue: () => queued = true,
    )));
    final clock = _iconOf(tester, KaiIconName.clock);
    expect(clock, isNotNull);
    await tester.tap(find.byWidget(clock!));
    expect(queued, isTrue);
  });
}
```

- [ ] **Step 3: Run tests to confirm they fail**

Run: `flutter test test/design_system/molecules/kai_compose_island_test.dart`
Expected: FAIL (API mismatch — `mode:` removed, `onAddTap`/`onVoiceTap`/`onStop`/`offline`/`onQueue` not yet defined).

- [ ] **Step 4: Rewrite the widget**

Replace `lib/design_system/molecules/kai_compose_island.dart` with:

```dart
import 'package:flutter/material.dart';

import '../theme/kai_theme.dart';
import '../tokens/kai_tokens.dart';
import '../atoms/atoms.dart';
import '../primitives/primitives.dart';

/// v3 compose island — the pill-shaped chat input bar.
///
/// Composable affordances (each optional button shows iff its callback is set):
/// `+` add/attach, `mic` dictation, `voice` (voice-Kai mode), `send`.
/// Variant-1 "swap": `voice` is a persistent inner-right button; the far-right
/// slot swaps `mic` (empty) ⇄ `send` (text). Streaming collapses to
/// "Kai отвечает…" + stop. Offline (O-A) keeps the field live with an amber
/// queue affordance. Canon: room.html .compose-island + 2026-05-30 spec.
class KaiComposeIsland extends StatelessWidget {
  const KaiComposeIsland({
    required this.controller,
    required this.onSend,
    this.onAddTap,
    this.onMicTap,
    this.onVoiceTap,
    this.onStop,
    this.sendState = KaiSendState.ready,
    this.offline = false,
    this.onQueue,
    this.placeholder = 'Спросить Kai…',
    super.key,
  });

  final TextEditingController controller;
  final VoidCallback onSend;
  final VoidCallback? onAddTap;
  final VoidCallback? onMicTap;
  final VoidCallback? onVoiceTap;
  final VoidCallback? onStop;
  final KaiSendState sendState;
  final bool offline;
  final VoidCallback? onQueue;
  final String placeholder;

  // Canon literals (room.html .compose-island).
  static const double _padLeft = 16; // s4
  static const double _padOther = 5;
  static const double _gap = 4;
  static const double _btn = 30;

  @override
  Widget build(BuildContext context) {
    final c = KaiTheme.of(context).colors;
    final streaming = sendState == KaiSendState.streaming;

    return Container(
      decoration: BoxDecoration(
        color: c.surface,
        border: Border.all(color: c.line, width: 0.8),
        borderRadius: KaiRadius.brPill,
      ),
      padding: EdgeInsets.fromLTRB(
        streaming ? _padLeft : _padLeft,
        _padOther,
        _padOther,
        _padOther,
      ),
      child: AnimatedSwitcher(
        duration: _motion(context),
        child: streaming
            ? _buildStreaming(context, c)
            : ListenableBuilder(
                key: const ValueKey('compose_active'),
                listenable: controller,
                builder: (_, __) => _buildActive(context, c),
              ),
      ),
    );
  }

  Duration _motion(BuildContext context) =>
      MediaQuery.maybeOf(context)?.disableAnimations ?? false
          ? Duration.zero
          : KaiMotion.standard.duration;

  // ── Streaming: "Kai отвечает…" + stop ─────────────────────────────────────
  Widget _buildStreaming(BuildContext context, KaiColorTokens c) {
    return Row(
      key: const ValueKey('compose_streaming'),
      children: [
        Expanded(
          child: Text(
            'Kai отвечает…',
            style: _fieldStyle(c).copyWith(color: c.ink4),
          ),
        ),
        const SizedBox(width: _gap),
        KaiSendButton(
          state: KaiSendState.streaming,
          onPressed: onStop,
          size: _btn,
          iconSize: 12,
        ),
      ],
    );
  }

  // ── Active (empty / typing / offline) ─────────────────────────────────────
  Widget _buildActive(BuildContext context, KaiColorTokens c) {
    final hasText = controller.text.isNotEmpty;

    final children = <Widget>[];

    // "+" add — present except streaming. Hidden in offline-empty is fine to
    // keep; spec keeps it always present offline.
    if (onAddTap != null) {
      children.add(_iconBtn(KaiIconName.plus, onAddTap!, c.ink3));
      children.add(const SizedBox(width: _gap));
    }

    // Field or offline-empty hint.
    if (offline && !hasText) {
      children.add(Expanded(child: _offlineHint(c)));
    } else {
      children.add(Expanded(
        child: _ComposeField(
          controller: controller,
          placeholder: placeholder,
          style: _fieldStyle(c),
          hintStyle: _fieldStyle(c).copyWith(color: c.ink4),
          cursor: c.accent,
        ),
      ));
    }

    // Trailing cluster.
    if (offline) {
      if (hasText) {
        children
          ..add(const SizedBox(width: _gap))
          ..add(_iconBtn(KaiIconName.clock, onQueue ?? onSend, c.warning));
      }
    } else {
      if (onVoiceTap != null) {
        children
          ..add(const SizedBox(width: _gap))
          ..add(_iconBtn(KaiIconName.waveform, onVoiceTap!, c.ink3));
      }
      children
        ..add(const SizedBox(width: _gap))
        ..add(_trailingSwap(hasText));
    }

    return Row(
      key: const ValueKey('compose_active_row'),
      crossAxisAlignment: CrossAxisAlignment.center,
      children: children,
    );
  }

  // Far-right slot: mic (empty) ⇄ send (text). When onMicTap is null, always send.
  Widget _trailingSwap(bool hasText) {
    final showSend = hasText || onMicTap == null;
    final child = showSend
        ? KaiSendButton(
            key: const ValueKey('compose_send'),
            state: hasText ? KaiSendState.ready : KaiSendState.disabled,
            onPressed: hasText ? onSend : null,
            size: _btn,
            iconSize: 12,
          )
        : SizedBox(
            key: const ValueKey('compose_mic'),
            width: _btn,
            height: _btn,
            child: KaiIconButton.transparent(
              onPressed: onMicTap,
              icon: KaiIconName.mic,
              size: 14,
            ),
          );
    return AnimatedSwitcher(duration: KaiMotion.micro.duration, child: child);
  }

  Widget _iconBtn(KaiIconName icon, VoidCallback onTap, Color color) {
    return SizedBox(
      width: _btn,
      height: _btn,
      child: KaiIconButton.bare(onPressed: onTap, icon: icon, color: color),
    );
  }

  Widget _offlineHint(KaiColorTokens c) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 6,
          height: 6,
          decoration: BoxDecoration(color: c.warning, shape: BoxShape.circle),
        ),
        const SizedBox(width: 8),
        Flexible(
          child: Text(
            'оффлайн — отправлю, когда вернётся сеть',
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: _fieldStyle(c).copyWith(color: c.ink3),
          ),
        ),
      ],
    );
  }

  TextStyle _fieldStyle(KaiColorTokens c) => TextStyle(
        fontFamily: 'Manrope',
        fontSize: 13.5,
        fontWeight: FontWeight.w400,
        color: c.ink1,
        letterSpacing: 13.5 * -0.005,
      );
}

/// Bare TextField for the pill (no internal border/fill — outer Container is chrome).
class _ComposeField extends StatelessWidget {
  const _ComposeField({
    required this.controller,
    required this.placeholder,
    required this.style,
    required this.hintStyle,
    required this.cursor,
  });

  final TextEditingController controller;
  final String placeholder;
  final TextStyle style;
  final TextStyle hintStyle;
  final Color cursor;

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: controller,
      minLines: 1,
      maxLines: 4,
      style: style,
      cursorColor: cursor,
      textInputAction: TextInputAction.newline,
      decoration: InputDecoration(
        isDense: true,
        contentPadding: EdgeInsets.zero,
        hintText: placeholder,
        hintStyle: hintStyle,
        border: InputBorder.none,
        enabledBorder: InputBorder.none,
        focusedBorder: InputBorder.none,
      ),
    );
  }
}
```

> Note during execution: confirm `KaiMotion.standard.duration` / `KaiMotion.micro.duration` accessor names (they may be `KaiMotion.standard` as a `Duration` or expose `.duration` + `.curve`). Adjust to the real API. Confirm `KaiColorTokens` is the colour-token type name (used already in `kai_fork_card.dart`). Confirm `KaiIconButton.bare` accepts `color:` (it does per COMPONENTS.md).

- [ ] **Step 5: Run the tests to verify pass**

Run: `flutter test test/design_system/molecules/kai_compose_island_test.dart`
Expected: PASS (all 7).

- [ ] **Step 6: Analyze**

Run: `flutter analyze` → No issues found (expect transient errors in `room_screen.dart` + `molecule_stories.dart` until Task 3 — that's fine; do NOT commit until Task 3 if analyze fails on those. If you want a green commit now, do Task 3 before committing.)

- [ ] **Step 7: (deferred commit)** Commit together with Task 3 so the tree compiles.

---

## Task 3: Migrate `RoomScreen` + Storybook compose story to new API (R2)

**Files:**
- Modify: `lib/features/room/room_screen.dart:174-179`
- Modify: `lib/features/dev/storybook/stories/molecule_stories.dart` (compose story ~127-141, 580-628; remove `KaiComposeMode`)

- [ ] **Step 1: Inspect RoomScreen state for the affordances to wire**

Run: `Read lib/features/room/room_screen.dart` (focus: `_onSend`, `_sendStateFrom`, `RoomStateData` fields `isOffline`/`isStreaming`, and whether mic/voice/attach handlers exist).
Expected: know what to pass for `onMicTap`/`onVoiceTap`/`onAddTap`/`onStop`/`offline`/`onQueue`.

- [ ] **Step 2: Update the call site**

Replace `lib/features/room/room_screen.dart:174-179` with (wire handlers that exist; use `null` for affordances RoomScreen doesn't yet implement — they will simply not render, preserving current behaviour + adding voice/attach when handlers land):

```dart
                child: KaiComposeIsland(
                  controller: _composeController,
                  onSend: _onSend,
                  onMicTap: _onMic,          // add a stub `_onMic` (focus dictation) if absent
                  onVoiceTap: _onVoiceMode,  // add a stub `_onVoiceMode` (push voice route) if absent
                  onAddTap: _onAddElements,  // add a stub `_onAddElements` (open action sheet) if absent
                  onStop: _onStopStreaming,  // add a stub mapping to existing stop logic
                  sendState: _sendStateFrom(roomState),
                  offline: roomState.isOffline,
                  placeholder: AppLocalizations.of(context).composePlaceholder,
                ),
```

Add the stub handlers in the State class if they don't exist, e.g.:

```dart
  void _onMic() {/* TODO: dictation — wire to speech service when available */}
  void _onVoiceMode() {/* TODO: Navigator push voice route when built */}
  void _onAddElements() {/* TODO: show KaiActionSheet (attachments + travel) */}
  void _onStopStreaming() => ref.read(roomControllerProvider.notifier).stopStreaming();
```

> During execution: match the real controller/provider names. If `stopStreaming` does not exist, point `onStop` at the existing cancel path or pass `null` (stop button then no-ops visually but still renders). `_sendStateFrom` already returns `disabled` for offline — that's fine; `offline:true` now drives the visual.

- [ ] **Step 3: Update `_sendStateFrom` doc** (optional) to note offline is now also surfaced via `offline:`.

- [ ] **Step 4: Rewrite the Storybook compose story**

In `molecule_stories.dart`: remove all `KaiComposeMode` references. Replace the three cells (`standard`/`voice`/`offline`) with four state cells using the new API. Replace `variants`, `usage`, and the `mode` `PropDoc` accordingly:

```dart
    variants: const ['empty', 'typing', 'streaming', 'offline'],
```
```dart
        StorySection('States', [
          StoryCell('empty (mic + voice + add)', SizedBox(width: 320,
            child: KaiComposeIsland(controller: _ctrl, onSend: () {},
              onMicTap: () {}, onVoiceTap: () {}, onAddTap: () {}))),
          StoryCell('typing (mic→send)', SizedBox(width: 320,
            child: KaiComposeIsland(controller: _typingCtrl, onSend: () {},
              onMicTap: () {}, onVoiceTap: () {}, onAddTap: () {}))),
          StoryCell('streaming', SizedBox(width: 320,
            child: KaiComposeIsland(controller: _ctrl, onSend: () {},
              onStop: () {}, sendState: KaiSendState.streaming))),
          StoryCell('offline (queue)', SizedBox(width: 320,
            child: KaiComposeIsland(controller: _offlineCtrl, onSend: () {},
              offline: true, onQueue: () {}))),
        ]),
```
Initialise `_typingCtrl` with text in `initState`:
```dart
  final _typingCtrl = TextEditingController(text: 'рейс в Токио на пятницу');
```
And `_offlineCtrl` with text so the queue affordance shows. Dispose all controllers. Update `usage` string + remove the `mode` `PropDoc`, add `onVoiceTap`/`onAddTap`/`offline` PropDocs.

- [ ] **Step 5: Run the full suite + analyze**

Run: `flutter analyze` → No issues found
Run: `flutter test` → all green (838 + new compose tests; old compose `mode` tests removed in Task 2)

- [ ] **Step 6: Commit (Tasks 2+3 together)**

```bash
git add lib/design_system/molecules/kai_compose_island.dart \
        test/design_system/molecules/kai_compose_island_test.dart \
        lib/features/room/room_screen.dart \
        lib/features/dev/storybook/stories/molecule_stories.dart
git commit -m "feat(ds): rebuild KaiComposeIsland — composable affordances, mic⇄send swap, O-A offline (R2)"
```

- [ ] **Step 7: Update COMPONENTS.md** — replace the `KaiComposeIsland` §4 entry to document the new API + states; mark R2 done in §5.1. Commit `docs(ds): COMPONENTS.md — KaiComposeIsland new API`.

---

## Task 4: `KaiForkChip` — JetBrains Mono UPPERCASE + warn tone + surface2/0.8 border (R4)

**Files:**
- Modify: `lib/design_system/atoms/kai_fork_chip.dart`
- Test: `test/design_system/atoms/kai_fork_chip_test.dart`

Canon (`fork.html .chip`): JetBrains Mono 8px/600, `text-transform: uppercase`, ls 0.04em (0.32px), pad 2/6, brPill. Tones: `bad` (negative/negativeWash), `neutral` (ink3/**surface2** + 0.8px line border), `ok` (positive/positiveWash), **`warn` (warning/warningWash)**.

- [ ] **Step 1: Write failing tests**

Append to/replace `test/design_system/atoms/kai_fork_chip_test.dart`:

```dart
testWidgets('chip renders uppercase JetBrains Mono', (tester) async {
  await tester.pumpWidget(buildTestWidget(
    const KaiForkChip('без визы', tone: KaiForkChipTone.ok)));
  final txt = tester.widget<Text>(find.byType(Text));
  expect(txt.data, 'БЕЗ ВИЗЫ');                 // uppercased
  expect(txt.style!.fontFamily, 'JetBrainsMono');
  expect(txt.style!.fontSize, 8);
  expect(txt.style!.fontWeight, FontWeight.w600);
  expect(txt.style!.letterSpacing, closeTo(8 * 0.04, 0.001));
});

testWidgets('warn tone exists', (tester) async {
  await tester.pumpWidget(buildTestWidget(
    const KaiForkChip('толпы', tone: KaiForkChipTone.warn)));
  expect(find.text('ТОЛПЫ'), findsOneWidget);
});
```

- [ ] **Step 2: Run → FAIL** (`warn` undefined; font is Manrope; not uppercased).

Run: `flutter test test/design_system/atoms/kai_fork_chip_test.dart` → FAIL

- [ ] **Step 3: Implement**

In `kai_fork_chip.dart`: add `warn` to `KaiForkChipTone`; in the switch add the warn case; change neutral bg to `c.surface2` and border to `width: 0.8`; uppercase the label; switch font to JetBrains Mono + letterSpacing.

```dart
enum KaiForkChipTone { bad, neutral, ok, warn }
```
In `build`, switch:
```dart
    switch (tone) {
      case KaiForkChipTone.bad:
        textColor = c.negative; bgColor = c.negativeWash; border = null;
      case KaiForkChipTone.neutral:
        textColor = c.ink3; bgColor = c.surface2;
        border = Border.all(color: c.line, width: 0.8); // canon 0.8px
      case KaiForkChipTone.ok:
        textColor = c.positive; bgColor = c.positiveWash; border = null;
      case KaiForkChipTone.warn:
        textColor = c.warning; bgColor = c.warningWash; border = null;
    }
```
Text:
```dart
      child: Text(
        label.toUpperCase(),                       // canon: text-transform uppercase
        style: TextStyle(
          fontFamily: 'JetBrainsMono',             // canon: .chip mono (was Manrope)
          fontSize: 8,
          fontWeight: FontWeight.w600,
          letterSpacing: 8 * 0.04,                 // canon: 0.04em
          color: textColor,
          height: 1.0,
        ),
      ),
```

- [ ] **Step 4: Run → PASS.** `flutter test test/design_system/atoms/kai_fork_chip_test.dart`

- [ ] **Step 5: Update the KaiForkChip story** in `atom_stories.dart` (~607-646): mention 4 tones; fix the misleading "More examples" cells (`'толпы↑'` neutral should be `warn`; `'толпы↓'` ok). Update blurb (JetBrains Mono uppercase, 4 tones).

- [ ] **Step 6: Analyze + full suite**

Run: `flutter analyze` → clean · `flutter test` → green

- [ ] **Step 7: Commit**

```bash
git add lib/design_system/atoms/kai_fork_chip.dart test/design_system/atoms/kai_fork_chip_test.dart lib/features/dev/storybook/stories/atom_stories.dart
git commit -m "fix(ds): KaiForkChip — JetBrains Mono uppercase + warn tone + surface2/0.8 border (R4)"
```

---

## Task 5: `KaiForkScoreDots` — tide-2 fill + optional `sl` label (R4)

**Files:**
- Modify: `lib/design_system/atoms/kai_fork_score_dots.dart`
- Test: `test/design_system/atoms/kai_fork_score_dots_test.dart`

Canon (`fork.html .fc-score`): filled `.d.f` = tide-2 `#2BA8C9` (`KaiTide.stop2`), empty `.d.e` = surface3; trailing `.sl` label ("4/5", JetBrains Mono 8.5px/500, ink3) after the dots.

- [ ] **Step 1: Write failing tests**

```dart
testWidgets('default fill is tide-2 not positive', (tester) async {
  await tester.pumpWidget(buildTestWidget(const KaiForkScoreDots(score: 4)));
  // first filled dot uses KaiTide.stop2
  final containers = tester.widgetList<Container>(find.byType(Container)).toList();
  final filled = containers.where((c) =>
      (c.decoration as BoxDecoration?)?.color == KaiTide.stop2);
  expect(filled.length, 4);
});

testWidgets('shows score label when showLabel', (tester) async {
  await tester.pumpWidget(buildTestWidget(
    const KaiForkScoreDots(score: 4, showLabel: true)));
  expect(find.text('4/5'), findsOneWidget);
});
```

- [ ] **Step 2: Run → FAIL.**

- [ ] **Step 3: Implement** — change default `fillColor` to `KaiTide.stop2`; add `showLabel` param + the label widget.

```dart
  const KaiForkScoreDots({
    required this.score,
    this.max = 5,
    this.fillColor,
    this.showLabel = false,
    super.key,
  }) : assert(score >= 0), assert(max > 0);
  ...
  final bool showLabel;
  ...
    final activeFill = fillColor ?? KaiTide.stop2; // canon: .d.f tide-2
    final filled = score.clamp(0, max);
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        for (int i = 0; i < max; i++) ...[
          if (i > 0) const SizedBox(width: 3),
          _Dot(filled: i < filled, fillColor: activeFill, emptyColor: c.surface3),
        ],
        if (showLabel) ...[
          const SizedBox(width: 6), // canon: gap before .sl
          Text('$filled/$max', style: TextStyle(
            fontFamily: 'JetBrainsMono', fontSize: 8.5,
            fontWeight: FontWeight.w500, color: c.ink3)),
        ],
      ],
    );
```
Add `import '../tokens/kai_tokens.dart';` already present (KaiTide).

- [ ] **Step 4: Run → PASS.**

- [ ] **Step 5: Update story** in `atom_stories.dart` (~647-694): change "default fill is positive" wording to tide-2; the "custom fill (tide-2)" cell is now the default — repoint the custom example to e.g. `c.accent`. Add a `showLabel: true` cell.

- [ ] **Step 6: Analyze + suite → green.**

- [ ] **Step 7: Commit**

```bash
git add lib/design_system/atoms/kai_fork_score_dots.dart test/design_system/atoms/kai_fork_score_dots_test.dart lib/features/dev/storybook/stories/atom_stories.dart
git commit -m "fix(ds): KaiForkScoreDots — tide-2 fill + optional score label (R4)"
```

---

## Task 6: New `KaiForkPriceDelta` atom (`.fc-delta`) (R4)

**Files:**
- Create: `lib/design_system/atoms/kai_fork_price_delta.dart`
- Modify: `lib/design_system/atoms/atoms.dart` (export)
- Test: `test/design_system/atoms/kai_fork_price_delta_test.dart`

Canon (`fork.html .fc-delta`): JetBrains Mono 8.5px/600, pad 1.5/5, brPill. `up` = `negative`/`negativeWash` (price rose = costlier), `down` = `positive`/`positiveWash` (price fell = cheaper).

- [ ] **Step 1: Write failing tests**

```dart
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:kai_app/design_system/atoms/kai_fork_price_delta.dart';
import 'package:kai_app/design_system/theme/kai_theme.dart';
import '../../test_helpers.dart';

void main() {
  testWidgets('up uses negative palette (costlier)', (tester) async {
    await tester.pumpWidget(buildTestWidget(
      const KaiForkPriceDelta('+\$500', direction: KaiPriceDirection.up)));
    final ctx = tester.element(find.byType(KaiForkPriceDelta));
    final c = KaiTheme.of(ctx).colors;
    final txt = tester.widget<Text>(find.byType(Text));
    expect(txt.style!.color, c.negative);
    expect(txt.style!.fontFamily, 'JetBrainsMono');
    expect(txt.style!.fontSize, 8.5);
  });

  testWidgets('down uses positive palette (cheaper)', (tester) async {
    await tester.pumpWidget(buildTestWidget(
      const KaiForkPriceDelta('−\$500', direction: KaiPriceDirection.down)));
    final ctx = tester.element(find.byType(KaiForkPriceDelta));
    final c = KaiTheme.of(ctx).colors;
    final txt = tester.widget<Text>(find.byType(Text));
    expect(txt.style!.color, c.positive);
  });
}
```

- [ ] **Step 2: Run → FAIL** (file absent).

- [ ] **Step 3: Implement**

`lib/design_system/atoms/kai_fork_price_delta.dart`:

```dart
import 'package:flutter/material.dart';

import '../theme/kai_theme.dart';
import '../tokens/kai_tokens.dart';

/// Direction of a price change. [up] = price rose (costlier → negative/coral);
/// [down] = price fell (cheaper → positive/green).
enum KaiPriceDirection { up, down }

/// Fork-card price-change pill — canon `fork.html .fc-delta`.
/// JetBrains Mono 8.5px/600, pad 1.5v/5h, brPill.
class KaiForkPriceDelta extends StatelessWidget {
  const KaiForkPriceDelta(this.label, {required this.direction, super.key});

  final String label;
  final KaiPriceDirection direction;

  @override
  Widget build(BuildContext context) {
    final c = KaiTheme.of(context).colors;
    final up = direction == KaiPriceDirection.up;
    final fg = up ? c.negative : c.positive;
    final bg = up ? c.negativeWash : c.positiveWash;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 1.5),
      decoration: BoxDecoration(color: bg, borderRadius: KaiRadius.brPill),
      child: Text(
        label,
        style: TextStyle(
          fontFamily: 'JetBrainsMono',
          fontSize: 8.5,
          fontWeight: FontWeight.w600,
          color: fg,
          height: 1.0,
        ),
      ),
    );
  }
}
```

- [ ] **Step 4: Export** — add to `lib/design_system/atoms/atoms.dart`:
```dart
export 'kai_fork_price_delta.dart';
```

- [ ] **Step 5: Run → PASS.** Analyze clean.

- [ ] **Step 6: Add a story** for `KaiForkPriceDelta` in `atom_stories.dart` (up/down cells). (Used by Task 7's card.)

- [ ] **Step 7: Commit**

```bash
git add lib/design_system/atoms/kai_fork_price_delta.dart lib/design_system/atoms/atoms.dart test/design_system/atoms/kai_fork_price_delta_test.dart lib/features/dev/storybook/stories/atom_stories.dart
git commit -m "feat(ds): KaiForkPriceDelta atom (.fc-delta price-change pill) (R4)"
```

---

## Task 7: `KaiForkCard` integration — price-row, `.fc-sw` footer, badge "✓", `.fresh`, win-col gradient (R4)

**Files:**
- Modify: `lib/design_system/molecules/kai_fork_card.dart`
- Test: `test/design_system/molecules/kai_fork_card_test.dart`

Adds: price + delta row; the winner-summary footer (`.fc-sw`); `.fc-badge` reduced to "✓"; freshness marker (`.fresh`) in header; win-column gradient bg (170° 7%→2% tide-2). Data-model additions: `KaiForkColumn.priceDelta` + `KaiForkColumn.priceDirection`; `KaiForkCard.winnerSummary` + `freshLabel`; `KaiForkRow` score dots gain the label.

- [ ] **Step 1: Write failing tests**

```dart
testWidgets('pick badge shows just check mark', (tester) async {
  await tester.pumpWidget(buildTestWidget(_demoCard(pick: 1)));
  expect(find.text('✓'), findsOneWidget);
  expect(find.textContaining('лучший'), findsNothing); // moved to footer
});

testWidgets('winner summary footer renders when provided', (tester) async {
  await tester.pumpWidget(buildTestWidget(_demoCard(
    pick: 1, summary: 'Корея — лучший выбор для \$2k.')));
  expect(find.textContaining('лучший выбор'), findsOneWidget);
});

testWidgets('price delta renders in price row', (tester) async {
  await tester.pumpWidget(buildTestWidget(_demoCard(pick: 1)));
  expect(find.byType(KaiForkPriceDelta), findsWidgets);
});
```
Add a `_demoCard({required int pick, String? summary})` helper building a 2-column `KaiForkCard` with `priceDelta`/`priceDirection` set and `winnerSummary: summary`.

- [ ] **Step 2: Run → FAIL.**

- [ ] **Step 3: Extend the data model**

In `KaiForkColumn` add:
```dart
    this.priceDelta,
    this.priceDirection,
  ...
  final String? priceDelta;            // e.g. "+$500"
  final KaiPriceDirection? priceDirection;
```
In `KaiForkCard` add:
```dart
    this.winnerSummary,                 // .fc-sw text (rich: bold country handled by caller string)
    this.freshLabel,                    // .fresh e.g. "✓ сегодня"
  ...
  final String? winnerSummary;
  final String? freshLabel;
```

- [ ] **Step 4: Implement the visual pieces**

(a) **Header `.fresh`** — in `_ForkHeader`, after the `Expanded(label)`, add (when a `freshLabel` is passed through):
```dart
          if (fresh != null)
            Text(fresh!, style: TextStyle(
              fontFamily: 'JetBrainsMono', fontSize: 8.5,
              fontWeight: FontWeight.w500, color: c.positive,
              letterSpacing: 8.5 * -0.01)),
```
Thread `freshLabel` into `_ForkHeader`.

(b) **Price row** — replace the standalone price `Text` in `_ForkColumn` with a baseline row:
```dart
              Row(
                crossAxisAlignment: CrossAxisAlignment.baseline,
                textBaseline: TextBaseline.alphabetic,
                children: [
                  Text(column.price, style: /* existing 19px/600 style */),
                  if (column.priceDelta != null && column.priceDirection != null) ...[
                    const SizedBox(width: 6), // canon: .fc-price-row gap
                    KaiForkPriceDelta(column.priceDelta!, direction: column.priceDirection!),
                  ],
                ],
              ),
```

(c) **Pick badge → "✓"** — in `_PickBadge`, change the text from `'✓ лучший'` to `'✓'` (keep style).

(d) **Win-column gradient bg** — replace the flat `color:` in the `isPick` `DecoratedBox` with:
```dart
                decoration: const BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter, end: Alignment.bottomCenter, // ~170°
                    colors: [Color(0x122BA8C9), Color(0x052BA8C9)], // 7% → 2% tide-2
                  ),
                ),
```
(0x12≈7%, 0x05≈2% alpha on #2BA8C9.)

(e) **`.fc-sw` footer** — after the `IntrinsicHeight(Row(columns))` in `KaiForkCard.build`, add (when `winnerSummary != null`):
```dart
          if (winnerSummary != null)
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 11, vertical: 8),
              decoration: BoxDecoration(
                color: const Color(0x0A2BA8C9), // tide-2 @ 4%
                border: Border(top: BorderSide(color: c.line, width: 0.8)),
              ),
              child: Row(
                children: [
                  Container(width: 5, height: 5, decoration: const BoxDecoration(
                    color: KaiTide.stop2, shape: BoxShape.circle)), // .wd
                  const SizedBox(width: 5),
                  Expanded(child: Text(winnerSummary!, style: TextStyle(
                    fontFamily: 'Manrope', fontSize: 10.5,
                    fontWeight: FontWeight.w500, color: c.ink2))),
                ],
              ),
            ),
```
(Keep `clipBehavior: Clip.hardEdge` so the footer's bg respects the card radius.)

(f) **Score label** — pass `showLabel: true` to `KaiForkScoreDots` inside `_ForkRow` (now that the atom supports it), matching canon `.sl`.

- [ ] **Step 5: Run → PASS.** Analyze clean.

- [ ] **Step 6: Update the KaiForkCard story** in `molecule_stories.dart`: set `priceDelta`/`priceDirection`, `winnerSummary`, `freshLabel` so the live card shows all pieces.

- [ ] **Step 7: Update COMPONENTS.md** fork section (§3 fork.html + §4 KaiForkCard) to reflect new props; mark R4 done in §5.1.

- [ ] **Step 8: Commit**

```bash
git add lib/design_system/molecules/kai_fork_card.dart test/design_system/molecules/kai_fork_card_test.dart lib/features/dev/storybook/stories/molecule_stories.dart lib/design_system/COMPONENTS.md
git commit -m "fix(ds): KaiForkCard fidelity — price delta row, winner footer, ✓ badge, fresh marker, gradient pick bg (R4)"
```

---

## Task 8: `KaiKaraokeText` — ls/lh + now-radius 4px (R5)

**Files:**
- Modify: `lib/design_system/atoms/kai_karaoke_text.dart`
- Test: `test/design_system/atoms/kai_karaoke_text_test.dart`

Canon (`voice.html .karaoke`): 16px/500, ls -0.01em, lh 1.5 (24px); `.now` radius 4px (currently `KaiRadius.br1` = 6px).

- [ ] **Step 1: Write failing tests**

```dart
testWidgets('karaoke uses canon ls + line-height', (tester) async {
  await tester.pumpWidget(buildTestWidget(const KaiKaraokeText(
    words: ['a','b','c'], currentIndex: 1)));
  final txts = tester.widgetList<Text>(find.byType(Text));
  for (final t in txts) {
    expect(t.style!.letterSpacing, closeTo(16 * -0.01, 0.001));
    expect(t.style!.height, 1.5);
  }
});
```
(Plus keep existing colour/state tests.)

- [ ] **Step 2: Run → FAIL.**

- [ ] **Step 3: Implement** — add `letterSpacing: _fontSize * -0.01` and `height: 1.5` to both the now-word `Text` and the spoken/next `Text`; change `_nowRadius`:
```dart
  static const double _lineHeight = 1.5;
  static const double _letterSpacing = 16 * -0.01;
  // now highlight radius: canon 4px (literal, between nothing and br1=6px)
  static const BorderRadius _nowRadius = BorderRadius.all(Radius.circular(4));
```
Replace `borderRadius: KaiRadius.br1` → `borderRadius: _nowRadius`; add `letterSpacing`/`height` to both styles. Drop the now-unused `kai_radius.dart` import if `KaiRadius` no longer referenced.

- [ ] **Step 4: Run → PASS.** Analyze clean.

- [ ] **Step 5: Commit**

```bash
git add lib/design_system/atoms/kai_karaoke_text.dart test/design_system/atoms/kai_karaoke_text_test.dart
git commit -m "fix(ds): KaiKaraokeText — canon ls/line-height + 4px now-radius (R5)"
```

---

## Task 9: `KaiTranscriptView` rebuild — rail + dots + who-label + mono ts + body colours (R5)

**Files:**
- Modify (rewrite): `lib/design_system/molecules/kai_transcript_view.dart`
- Test: `test/design_system/molecules/kai_transcript_view_test.dart`

Canon (`voice.html .tr-view`): timeline with a 1px vertical rail (white@0.12 at x=36) + 9px rail dot per event (you = white@0.5 fill + 1.6px `#08080A` ring; kai = `KaiTide.gradientCorner` fill + tide-2@0.25 glow). `.ts` row = JetBrains Mono 8.5px/500 UPPERCASE ls 0.14em: `.who` ("YOU"/"KAI", white@0.55) + time (white@0.4). `.body` = Manrope 12px/400 lh 1.5: you = white@0.6, kai = full white. **Remove the invented `KaiGradientBar` above the timestamp.**

- [ ] **Step 1: Write failing tests**

```dart
testWidgets('shows who label uppercased', (tester) async {
  await tester.pumpWidget(buildTestWidget(const KaiTranscriptView(events: [
    KaiTranscriptEvent(who: 'kai', text: 'Найдено', timestamp: '9:41'),
    KaiTranscriptEvent(who: 'you', text: 'Дешевле?', timestamp: '9:42'),
  ])));
  expect(find.text('KAI'), findsOneWidget);
  expect(find.text('YOU'), findsOneWidget);
});

testWidgets('timestamp is JetBrains Mono', (tester) async {
  await tester.pumpWidget(buildTestWidget(const KaiTranscriptView(events: [
    KaiTranscriptEvent(who: 'kai', text: 'x', timestamp: '9:41'),
  ])));
  final ts = tester.widget<Text>(find.text('9:41'));
  expect(ts.style!.fontFamily, 'JetBrainsMono');
  expect(ts.style!.fontSize, 8.5);
});

testWidgets('no gradient bar in transcript', (tester) async {
  await tester.pumpWidget(buildTestWidget(const KaiTranscriptView(events: [
    KaiTranscriptEvent(who: 'kai', text: 'x', timestamp: '9:41'),
  ])));
  expect(find.byType(KaiGradientBar), findsNothing);
});

testWidgets('body 12px', (tester) async {
  await tester.pumpWidget(buildTestWidget(const KaiTranscriptView(events: [
    KaiTranscriptEvent(who: 'kai', text: 'Hello', timestamp: '9:41'),
  ])));
  expect(tester.widget<Text>(find.text('Hello')).style!.fontSize, 12);
});
```

- [ ] **Step 2: Run → FAIL** (who labels absent, gradient bar present, ts Manrope, body 13).

- [ ] **Step 3: Rewrite the widget**

Replace the body builder. Key structure per event: a `Stack`/`Row` placing the rail dot in the 52px left gutter (dot centred ~x=32, 9px) over a shared 1px rail line; then the `.ts` row (who + time) then the body. Drop the `KaiGradientBar` import.

```dart
import 'package:flutter/material.dart';

import '../tokens/kai_tokens.dart'; // KaiTide

class KaiTranscriptEvent {
  const KaiTranscriptEvent({required this.who, required this.text, required this.timestamp});
  final String who;       // 'you' | 'kai'
  final String text;
  final String timestamp;
}

class KaiTranscriptView extends StatelessWidget {
  const KaiTranscriptView({required this.events, super.key});
  final List<KaiTranscriptEvent> events;

  static const Color _white = Color(0xFFFFFFFF);
  static const Color _whoColor = Color(0x8CFFFFFF);   // white@0.55
  static const Color _tsColor = Color(0x66FFFFFF);    // white@0.4
  static const Color _youBody = Color(0x99FFFFFF);    // white@0.6
  static const Color _railColor = Color(0x1FFFFFFF);  // white@0.12
  static const Color _voiceBg = Color(0xFF08080A);

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        // Rail line at x=36 (relative to the 52px gutter).
        Positioned(top: 0, bottom: 0, left: 36,
          child: Container(width: 1, color: _railColor)),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [for (final e in events) _event(e)],
        ),
      ],
    );
  }

  Widget _event(KaiTranscriptEvent e) {
    final isKai = e.who == 'kai';
    return Padding(
      padding: const EdgeInsets.fromLTRB(52, 9, 22, 9), // canon
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          // Rail dot — gutter centred ~x=-20 from content (52-32=20 left of body), top ~5.
          Positioned(left: -20, top: 5, child: _dot(isKai)),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Row(mainAxisSize: MainAxisSize.min, children: [
                Text(e.who.toUpperCase(), style: _ts(_whoColor)),
                const SizedBox(width: 6),
                Text(e.timestamp, style: _ts(_tsColor)),
              ]),
              const SizedBox(height: 3),
              Text(e.text, style: TextStyle(
                fontFamily: 'Manrope', fontSize: 12, fontWeight: FontWeight.w400,
                height: 1.5, letterSpacing: 12 * -0.005,
                color: isKai ? _white : _youBody)),
            ],
          ),
        ],
      ),
    );
  }

  TextStyle _ts(Color color) => TextStyle(
        fontFamily: 'JetBrainsMono', fontSize: 8.5, fontWeight: FontWeight.w500,
        letterSpacing: 8.5 * 0.14, color: color);

  Widget _dot(bool isKai) {
    return Container(
      width: 9, height: 9,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: isKai ? null : const Color(0x80FFFFFF), // you: white@0.5
        gradient: isKai ? KaiTide.gradientCorner : null,
        border: Border.all(color: _voiceBg, width: 1.6),
        boxShadow: isKai
            ? const [BoxShadow(color: Color(0x402BA8C9), blurRadius: 0, spreadRadius: 1)]
            : null,
      ),
    );
  }
}
```

> Execution note: the rail-dot `Positioned(left: -20)` reaches into the 52px gutter; verify it lands on the x=36 rail line in the Storybook (`voice.html`: dot x=32, line x=36, both inside the gutter). Tune `left`/`top` against the live render. Alpha hexes: white@0.55≈0x8C, @0.5=0x80, @0.4=0x66, @0.12=0x1F, @0.6=0x99; tide-2@0.25≈0x40 on #2BA8C9 → `0x402BA8C9`.

- [ ] **Step 4: Run → PASS.** Analyze clean.

- [ ] **Step 5: Update the KaiTranscriptView story** (`molecule_stories.dart`) — ensure it sits on `_voiceBg`; verify you/kai dots + who labels visually.

- [ ] **Step 6: Update COMPONENTS.md** voice section (§3/§4) + mark R5 transcript done in §5.1.

- [ ] **Step 7: Commit**

```bash
git add lib/design_system/molecules/kai_transcript_view.dart test/design_system/molecules/kai_transcript_view_test.dart lib/features/dev/storybook/stories/molecule_stories.dart lib/design_system/COMPONENTS.md
git commit -m "fix(ds): KaiTranscriptView — rail+dots, who label, mono ts, speaker body colours; drop invented gradient bar (R5)"
```

---

## Task 10: `KaiToast` — compact vs rich/action archetypes (R3)

**Files:**
- Modify: `lib/design_system/molecules/kai_toast.dart`
- Test: `test/design_system/molecules/kai_toast_test.dart`

Canon (`components.html § 03.12`): **compact** status toast (`.ti` 11px icon + 11px/500 label, no action); **rich** toast (24px round `.glyph` + `.body` title 13.5px/600 + `<small>` desc 11.5px/500 + `.open` action 12px/600 tide-2). Goal: provide a `KaiToast.rich(...)` (or `body`+`description`+`glyph`) constructor for the action archetype, and keep the compact constructor action-free by default. Action affordance (`.open`) reads as a tappable text-link (canon) — clarify with a slightly larger hit area + keep tide-2 colour.

- [ ] **Step 1: Read current toast test + story**

Run: `Read test/design_system/molecules/kai_toast_test.dart` and the toast story in `molecule_stories.dart`.
Expected: know which existing assertions/cells reference the action on compact variants (to re-home them onto the rich variant).

- [ ] **Step 2: Write failing tests**

```dart
testWidgets('compact toast has no action by default', (tester) async {
  await tester.pumpWidget(buildTestWidget(const KaiToast(
    type: KaiToastType.neutral, label: 'Скопировано')));
  expect(find.text('Открыть'), findsNothing);
});

testWidgets('rich toast shows title, description, action', (tester) async {
  var opened = false;
  await tester.pumpWidget(buildTestWidget(KaiToast.rich(
    title: 'Сохранено.',
    description: 'Учту при планировании.',
    actionLabel: 'Открыть',
    onAction: () => opened = true,
  )));
  expect(find.text('Сохранено.'), findsOneWidget);
  expect(find.text('Учту при планировании.'), findsOneWidget);
  await tester.tap(find.text('Открыть'));
  expect(opened, isTrue);
});
```

- [ ] **Step 3: Implement**

Add a `KaiToast.rich({required String title, required String description, String? actionLabel, VoidCallback? onAction, KaiToastType type = KaiToastType.memory, Key? key})` factory + an internal `_RichToastBody` that renders the 24px round glyph (use `KaiAvatar.kai(avatarSize: KaiAvatarSize.sm)` scaled to 24, or a 24px tide-corner circle) + title (`13.5px/600`) + description (`11.5px/500`, white, lh 1.45, 2px top margin) + the existing `_ToastActionButton`. Keep the existing compact `KaiToast(...)` constructor but ensure its `actionLabel`/`onAction` remain supported for back-compat (the user's confusion was on compact+action; document that compact action is discouraged — prefer `.rich`). The compact icon↔label gap stays 6px (canon).

> During execution: confirm the cleanest split. Minimum viable: add the `.rich` factory + body; leave compact as-is but update the story so neutral/positive/negative cells show NO action (canon), and a dedicated "rich + action" cell shows the title/desc/open layout. This directly resolves the "не понимаю кнопку" confusion by only ever showing the action on the rich layout.

- [ ] **Step 4: Run → PASS.** Analyze clean.

- [ ] **Step 5: Rewrite the toast story** (`molecule_stories.dart`): compact cells (neutral/positive/negative/memory) with NO action; a "rich · action" cell; a "rich · countdown" cell. Update blurb to explain the two archetypes.

- [ ] **Step 6: Update COMPONENTS.md** toast section + mark R3 done in §5.1.

- [ ] **Step 7: Commit**

```bash
git add lib/design_system/molecules/kai_toast.dart test/design_system/molecules/kai_toast_test.dart lib/features/dev/storybook/stories/molecule_stories.dart lib/design_system/COMPONENTS.md
git commit -m "fix(ds): KaiToast — split compact (no action) vs rich/action archetypes (R3)"
```

---

## Task 11: `KaiBadge` Storybook sizing fix (R1)

**Files:**
- Modify: `lib/features/dev/storybook/story_page.dart` (`_Cell`) — most likely; OR the badge story cells in `atom_stories.dart`
- (Atom itself is canon-correct — do NOT resize the badge.)

The badge atom renders at true size (dot 6px+ring=10px, count min16px, tide 12px). The "huge" report is a Storybook layout artifact. Diagnose live, then apply the minimal fix at the story/cell layer.

- [ ] **Step 1: Reproduce live**

Temporarily set `initialLocation: '/_dev/storybook'` in `lib/core/routing/router.dart`, then:
Run: `flutter run -d chrome --web-port 8744`
Open `http://localhost:8744`, navigate to KaiBadge. Observe the oversize. Use Flutter DevTools / widget inspector to find which ancestor forces the size (suspect: `_Cell`'s `Column` giving the badge unbounded/!stretched constraints, or the count `Container(minWidth:16)` interacting with a wide cell). **Revert the router edit immediately after.**

- [ ] **Step 2: Confirm the cause**

Likely: the badge `Container(constraints: BoxConstraints.tightFor(...))` is fine in isolation; the cell content `Column(mainAxisSize: min)` centres children, so width should not stretch. If the badge is huge, the most probable cause is an enclosing `SizedBox.expand`/stretch or a theme-driven `IconTheme`/`DefaultTextStyle` size. Capture the exact widget that imposes the large constraint.

- [ ] **Step 3: Apply the minimal fix**

Most likely fix — wrap each cell's child in an `Align`/`Center` that does not stretch, or wrap the badge demo cells in a `SizedBox`(intrinsic). Concretely, in `_Cell` change the child column's first item to be size-respecting:

```dart
      child: Column(mainAxisSize: MainAxisSize.min, children: [
        Center(child: cell.child),     // ← do not let the demo child stretch
        const SizedBox(height: KaiSpace.s3),
        Text(cell.label, ...),
      ]),
```

If the cause is specific to the badge (not all cells), instead wrap only the badge story cells in `atom_stories.dart` with `Align(alignment: Alignment.center, child: KaiBadge...)`. Choose the fix with the smallest blast radius confirmed by Step 2 (prefer the `_Cell` `Center` if it doesn't regress other stories).

- [ ] **Step 4: Verify live again** — badges render tiny; other stories unaffected. Revert router edit.

- [ ] **Step 5: Add a guard test** (`test/features/dev/storybook/...` or a widget test) asserting `KaiBadge.dot()` lays out at 10×10 inside a wide parent:

```dart
testWidgets('dot stays 10x10 in a wide cell', (tester) async {
  await tester.pumpWidget(buildTestWidget(
    SizedBox(width: 400, child: Center(child: KaiBadge.dot()))));
  final size = tester.getSize(find.byType(KaiBadge));
  expect(size, const Size(10, 10));
});
```

- [ ] **Step 6: Analyze + full suite → green.**

- [ ] **Step 7: Update §5.1** R1 status → fixed (note the root cause found). Commit:

```bash
git add lib/features/dev/storybook/story_page.dart test/ lib/design_system/COMPONENTS.md
git commit -m "fix(storybook): KaiBadge renders at true size — stop cell from stretching demo child (R1)"
```

---

## Self-review

**Spec coverage (R2 spec + COMPONENTS.md §5.1):**
- R2: composable API ✓ (T2), swap ✓ (T2), O-A offline ✓ (T2), streaming collapse ✓ (T2), waveform glyph ✓ (T1), RoomScreen migration ✓ (T3), storybook ✓ (T3), tests ✓ (T2). 
- R4: chip font/tone/border ✓ (T4), score tide-2+label ✓ (T5), price delta atom ✓ (T6), price-row + fc-sw + ✓-badge + fresh + win-gradient ✓ (T7).
- R5: karaoke ls/lh/radius ✓ (T8); transcript rail/dots/who/mono-ts/body/no-bar ✓ (T9).
- R3: compact vs rich split ✓ (T10).
- R1: storybook sizing ✓ (T11).

**Placeholder scan:** Implementation steps contain real code/values. Three execution-time look-ups are explicitly flagged (not placeholders): KaiMotion accessor shape (T2), RoomScreen provider/handler names (T3), and the live R1 root cause (T11) — each is a "read the real code / observe the live render then apply the shown fix" instruction, not a vague TODO.

**Type consistency:** `KaiForkPriceDirection`→ named `KaiPriceDirection` (T6) and reused verbatim in `KaiForkColumn.priceDirection` (T7). `KaiForkChipTone.warn` added in T4 and used by callers. `KaiForkScoreDots.showLabel` added in T5, used in T7. `KaiComposeIsland` params (`onAddTap/onMicTap/onVoiceTap/onStop/offline/onQueue`) defined in T2 and used identically in T3. `KaiIconName.waveform` defined T1, used T2.

**Open risks to confirm during execution (not blockers):**
- `KaiMotion.standard`/`.micro` may be `Duration` constants vs objects exposing `.duration`/`.curve` — match the real token API in T2/T8.
- Exact alpha hex rounding for white-opacity literals in T9 — verify against the live voice screen.
- T11 fix location depends on the live diagnosis.
