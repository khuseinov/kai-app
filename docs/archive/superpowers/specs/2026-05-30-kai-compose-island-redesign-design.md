# KaiComposeIsland redesign — design spec

**Date:** 2026-05-30 · **Branch:** `storybook-review-fixes` · **Source:** storybook-review handoff R2
**Status:** approved in brainstorming (V1 layout · O-A offline · waveform voice glyph)

---

## 1. Problem

The live Storybook review flagged the compose island (`lib/design_system/molecules/kai_compose_island.dart`):

- The **offline** mode reads as janky/alarming ("стрёмно выглядит").
- The user wants a **richer affordance set** in the pill: `+` (add/attach + travel menu),
  `mic` (dictation), `voice-Kai` (enter the full voice mode), and `send`.
- The core interaction idea: a **typing-driven swap** — mic when the field is empty, send when
  there is text; mic returns when the field empties again.

The current widget models this as a rigid `KaiComposeMode { standard, voice, offline }` enum, where
`voice` repurposes the mic as an accent toggle and `offline` disables the field with a bolted-on
mono hint. That conflates two different "voice" concepts and produces the janky offline look.

## 2. Decisions (locked in brainstorming)

- **Two distinct voice affordances:** `mic` = dictation (speech→text into the field, stay in chat);
  `voice-Kai` = navigate into the full voice mode (`voice.html` screen — live conversation).
- **`+` opens a combined action sheet** (attachments + travel quick-actions). Lives on the left.
- **Layout = Variant 1 "Swap":** `voice` is a persistent inner-right button; the far-right slot
  swaps `mic` (empty) ⇄ `send` (text). `+` on the left. Max 3 buttons + field at once → fits a
  narrow phone. (Chosen over the zero-UI "reveal-on-focus" variant, which adds a focus-without-text
  state and a class of fade animations for marginal resting-calm gain.)
- **Offline = O-A "Calm queue":** the field stays live (you can type offline); a warning-amber dot
  + calm hint communicate offline; `send` becomes a "queue" affordance (amber clock). `mic`/`voice`
  hide offline. Warning/amber token (`#B57A0B`), **never coral**.
- **`voice-Kai` glyph = waveform**, neutral `ink2/ink3`. A new `KaiIconName.waveform`. Chosen over a
  tide-mark glyph because the "one tide gradient per screen" rule reserves the gradient for `send`;
  a neutral waveform is unambiguous as "voice" and visually distinct from the line-art mic.

## 3. Public API (breaking change — `KaiComposeMode` removed)

Replace the rigid mode enum with composable affordances. Each optional button is shown iff its
callback is provided. This expresses both user-requested "variants" (full · and `+`/mic/voice) as
call-site configuration of one widget.

```dart
KaiComposeIsland({
  required TextEditingController controller,
  required VoidCallback onSend,
  VoidCallback? onAddTap,     // "+" attach/travel menu; null → hidden
  VoidCallback? onMicTap,     // dictation; null → no mic (far-right slot = send-on-text only)
  VoidCallback? onVoiceTap,   // enter voice mode (voice-Kai); null → hidden
  VoidCallback? onStop,       // stop streaming; used when sendState == streaming
  KaiSendState sendState = KaiSendState.ready,
  bool offline = false,       // O-A offline state
  VoidCallback? onQueue,      // offline queue action; defaults to onSend when null
  String placeholder = 'Спросить Kai…',
  Key? key,
})
```

Removed: `enum KaiComposeMode { standard, voice, offline }` and the `mode:` parameter.

## 4. States & layout (Variant 1 "Swap")

| State | Condition | Layout (left → right) |
|---|---|---|
| **Empty** | `controller.text` empty, not offline/streaming | `(+)` · field · `(voice)` · `(mic)` |
| **Typing** | `controller.text` non-empty | `(+)` · field · `(voice)` · `(send)` |
| **Streaming** | `sendState == streaming` | collapsed: `«Kai отвечает…»` · `(stop)` — no field, no `+`/`voice`/`mic` (canon room.html frame 3) |
| **Offline (empty)** | `offline`, text empty | `(+)` · `⚬ оффлайн — отправлю, когда вернётся сеть` (amber dot + hint in the field area; no trailing button — nothing to queue) |
| **Offline (typing)** | `offline`, text non-empty | `(+)` · field · `(в очередь)` (amber clock) |

- Far-right slot swaps `mic` ⇄ `send` on text presence. `voice` is the inner-right persistent
  button (hidden only in streaming/offline). `+` hidden in streaming.
- A button whose callback is `null` is simply omitted (e.g. `onMicTap: null` → no mic; the far-right
  slot then shows `send`, disabled when empty — the room.html canon behaviour).

## 5. Tokens (all Playwright-verified from canon)

- Pill: `c.surface` bg, `0.8px c.line` border, `KaiRadius.brPill`, padding `LTRB 16/5/5/5`, gap `4`,
  cross-axis center.
- Field: bare `TextField` (no internal border/fill), Manrope `13.5px/400`, ls `-0.005em`, `c.ink1`,
  hint `c.ink4`, `minLines: 1, maxLines: 4`, cursor `c.accent`.
- `(+)` / `(mic)` / `(voice)`: `KaiIconButton.transparent`, 30×30 target, glyph `c.ink3`,
  icon ~14–16px (mic 14px per canon).
- `(send)`: `KaiSendButton`, 30×30, tide gradient + `KaiShadow.button`, arrow 12px. The single
  tide-gradient CTA on screen.
- `(stop)`: `KaiSendButton(state: streaming)` — stop glyph, 30×30, tide.
- **Offline (O-A):** dot `⚬` = `c.warning`; hint text `c.ink3` 13.5px Manrope; "queue" =
  `KaiIconButton.bare(icon: KaiIconName.clock, color: c.warning)`. Pill border stays `c.line`
  (calm); amber appears only on the dot + clock — no coral, no full-amber pill.
- Streaming placeholder `«Kai отвечает…»`: `c.ink4` 13.5px Manrope (same as hint).

No hard-coded colours or magic padding outside token files; canon literals (0.8 border, 5/16 pad,
30 button, 14 glyph) are documented inline as today.

## 6. Animation

- `mic` ⇄ `send` swap and `voice` show/hide use `AnimatedSwitcher` (fade + subtle scale),
  `KaiMotion.standard` (240ms, `Cubic(0.2,0,0,1)`).
- Collapse into streaming / offline uses the same switcher.
- `MediaQuery.disableAnimations == true` → zero-duration (instant), per project reduced-motion rule.

## 7. Migration

- `RoomScreen` (`lib/features/room/`) is the only production call site. Migrate from `mode:` to the
  new callbacks: wire `onAddTap`, `onMicTap`, `onVoiceTap`, `onStop`, `offline`, `onQueue` from the
  room state. Map the existing streaming/sending logic onto `sendState` + `onStop`.
- Storybook story `KaiComposeIsland` in `molecule_stories.dart` updated to show all states
  (empty / typing / streaming / offline) and the "full" vs "+/mic/voice (no send button until text)"
  configurations.
- Add `KaiIconName.waveform` (one SVG) to the single-source icon set.

## 8. Testing

`test/design_system/molecules/kai_compose_island_test.dart` (reuse `buildTestWidget`):

- mic↔send swap follows `controller.text`.
- each optional affordance hidden when its callback is null; shown when provided.
- streaming collapses to `«Kai отвечает…»` + stop; `onStop` fires.
- offline renders the amber dot + queue affordance and uses `c.warning` (assert it is **not**
  `c.negative`); field remains enabled; `onQueue` fires (falls back to `onSend`).
- reduced-motion (`MediaQuery(disableAnimations: true)`) → switcher duration is zero.

Gate: `flutter analyze` clean + full suite green (currently 838 tests).

## 9. Out of scope

- The contents of the `+` action sheet (attachment/travel items) — feature-level, separate work.
- Actual offline message-queue persistence — the widget only exposes `onQueue` + the offline visual.
- The voice-mode screen (`voice.html`) assembly — separate (R5 covers its transcript/karaoke atoms).
