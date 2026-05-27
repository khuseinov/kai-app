# Kai Design System

This project holds the full design system for **Kai** — an AI travel companion (mobile, iOS + Android). Light-first, humanist, zero-UI. The brand mark is the **tide curve** — a gradient SVG path that lives at the top of every screen and carries every system state.

If you're a new agent and a user asks you to build, modify, or extend something — **read this file first**, then the four pillars below in order.

---

## 1 · Read in this order

```
1. colors_and_type.css        ← every token (color, type, space, radius, motion). The CSS source of truth.
2. uploads/KAI_CHARACTER.md   ← who Kai is (Explorer archetype, ocean metaphor, quiet confidence)
3. uploads/KAI_VOICE.md       ← how Kai talks (lowercase status, no emoji, first-person, calm)
4. foundations.html           ← visual manifest. Hero, palette, type, motion, brand anchor, file index.
```

Everything else builds on these four. **Do not invent new tokens, fonts, or colors.** Pull from `colors_and_type.css`. If it isn't there, ask first.

---

## 2 · The system — file map

Every HTML file in this project is a **single visual reference**. They are not pages of a real app. Each demonstrates one layer of the system. **Source of truth chain**: tokens → foundations → components → nav → room → deeper screens.

| File | Purpose | Status |
|------|---------|--------|
| `colors_and_type.css` | CSS tokens. Light + dark + tide. Import this in every artifact. | canonical |
| `design-tokens.json` | Same tokens in JSON for Flutter codegen. | canonical |
| `foundations.html` | The floor. Hero, palette, type, space, motion, brand mark, file index. | canonical |
| `components.html` | Layer 1 (atoms) + Layer 2 (molecules). Buttons, inputs, bubbles, sheets, drawer. | canonical |
| `nav.html` | Side panel. Trips + dates + apps (Memory/Settings). No "Tools" section. | canonical |
| `room.html` | Layer 3. Chat surface — **6 frames**: empty / live / panel / compose / streaming / error. | canonical |
| `voice.html` | Voice mode. Tide-only state, karaoke text reveal, timeline transcript. | canonical |
| `edge-states.html` | Offline · error · rate-limit · crisis (in-conversation pattern). | canonical |
| `onboarding.html` | First-run · 4 screens (welcome / tide / gestures / context). | canonical |
| `trip-detail.html` | Trip folder content — facts + chats + sources + actions. | canonical |
| `memory.html` | Memory app — grouped facts + sources + GDPR forget. | canonical |
| `settings.html` | Settings — account / appearance / voice / data / privacy | canonical |
| `dark.html` | Dark mode pass — all four core frames re-rendered dark. | canonical |
| `brand.html` | App icon (3 variants × 7 sizes), splash, OG card, brand rules. | canonical |
| `handoff.html` | Flutter widget specs (KaiTheme, KaiTokens, KaiTideCurve, KaiButton, etc). | canonical |
| `fork.html` | Multi-Country Fork — comparison card molecule (F-L1-05, L1+L3 moat). | canonical |
| `landing.html` | Marketing landing page EN — hero + demo + 3 pillars + waitlist CTA. | canonical |
| `tide-states.html` | Tide curve · 8 live states with CSS/SMIL animations + token reference. Source of truth for tide state implementation. | canonical |
| `notifications-chat.html` | Alert Card N-01 — proactive alerts in chat feed. 4 types (urgent/warning/positive/neutral) + anatomy + rules. | canonical |
| `roadmap.html` | Design roadmap — gaps, 8 new screens, 8 components, 6 improvements, 5 system tasks. With variants. | planning |
| `review.html` | Design audit 2026-05-26 — 8 issues logged and resolved. Historical reference. | reference |
| `uploads/` | User-supplied character docs. Source of truth for tone, voice, character. | read-only |
| `reference/` | Old Flutter source from pre-redesign. Backend reference only. | legacy |

---

## 3 · Hard rules — design language

These are non-negotiable. If a user asks for something that violates them, push back before building.

### Brand mark
- **The tide curve is the brand.** Single SVG path with the Tide gradient (`#1B4FB0 → #2BA8C9 → #F4B589`). Lives at the top of every product screen, 4 px below safe area.
- **8 live states** carry meaning: idle / listening / thinking / responding / success / error / memory / sleep. Each defined in `design-tokens.json § tide-states`.
- **Two gradient variants — locked:**
  - **`--tide-gradient` (115° / stops 0/52/100)** — default. Use for tide curve, hero text emphasis, thin/wide surfaces. The brand mark.
  - **`--tide-gradient-corner` (135° / stops 0/55/100)** — for **square surfaces only**: app icon, splash glyph, OG card bg-curve, avatar circles, square brand fills. The 135° angle flows corner-to-corner; stop-2 shifted to 55% to land brighter on the diagonal. **Do NOT use on the tide curve** — too steep for a wide-thin line.
- **No other gradients.** No recolors, no holiday variants, no client-specific tints. Only these two.

### Layout
- **Zero-UI.** No persistent chrome. Side panel opens by swipe from left edge — full-screen, not pinned. Compose opens by swipe up from bottom — sheet, not pinned.
- **One primary action per screen.** Only one button per screen carries the Tide gradient (typically Send or "Start using Kai"). All others are `ink-1` or ghost.
- **Buttons inside inputs hug the edge.** Use `border-radius: 999px` (pill) on compose-island. Never let a circular button overflow a rounded corner. See `room.html` and `edge-states.html` for the locked compose pattern.
- **Send-button states (canon).**
  - *ready* (text in input) → `--tide-gradient` fill, white icon, optional 2px soft shadow `0 2px 8px rgba(43,168,201,0.18)`
  - *disabled* (empty input, no draft) → `--ink-4` fill, white icon, `opacity: 0.5`
  - *sending / streaming* → `--tide-gradient` + subtle scale-pulse (m-3 micro)
  - Never use solid `--ink-1` as send fill — black-in-pill reads as a fake CTA in zero-UI.
- **Phone-frame sizes (canon).** Use tokens, not hard-coded pixels:
  - `--phone-w-cv` / `--phone-h-cv` = 390×844 (canvas — 1:1 iPhone viewport, for hi-fi specs)
  - `--phone-w-md` / `--phone-h-md` = 280×620 (medium — 2-col bento like memory/settings/trip-detail)
  - `--phone-w-sm` / `--phone-h-sm` = 240×480 (small — 4-col bento like voice/edge-states)
  - Tide-curve sits at `--phone-tide-top` (46px for md/cv, 40px for sm), 4 px below the island.

### Voice mode
- **Voice is always dark.** `voice.html` uses `#08080A` background — not a theme token. Voice mode is the one surface that never responds to light/dark theme switching: the dark field is the aesthetic container for the tide curve. Document this in any screen that hosts voice.

### Color
- **Light-first.** Dark mode is a parity remap, not a separate design. Same components, same spacing, only token values flip.
- **Warm off-whites only.** `--bg: #FAFAF9`. Pure `#FFFFFF` is reserved for elevated content like the chat input island.
- **No alarming red.** Error uses `#C44A3C` (muted coral), never `#DC2626`. Crisis surfaces use the same warm coral palette — never red.

### Type
- **Manrope** for everything. Variable weights 300–800.
- **JetBrains Mono** for micro-labels, timestamps, source URLs, code.
- No serif fonts. No display fonts. No icon-only labels without an `aria-label`.

### Voice
- **English-first.** RU available but secondary.
- **Lowercase status copy.** "listening", "thinking", "kai" — never "LISTENING".
- **No emoji in chrome.** No 🌙 next to theme, no 🎉 on success. Heart icon in crisis is the one exception (SVG, not emoji).
- **First-person Kai.** "I hear you" not "Kai hears you".

### Tools / backend
- **Kai orchestrates tools in the backend.** Do NOT add a "Tools" section to the nav. Do NOT show "tool history" as a panel surface. Tool transparency lives **in the message itself** — as a source card under each Kai response.
- **Three tool/state surfaces**: tide curve at top (live state) · source card under each response (receipt) · `voice.html` karaoke reveal (live caption).

### Crisis
- **C3 in-conversation pattern** is locked. See `edge-states.html § 04`.
- Kai stays in the chat — care-block alongside the reply, never a takeover screen. Compose remains visible. User keeps agency.

---

## 4 · How to build a new screen

If a user asks for a new screen (e.g., "settings notifications" or "shared trip"), follow this exact sequence:

1. **Check if it exists.** Read `foundations.html § 08` index first — there may already be a canonical reference.
2. **Pull tokens.** Import `colors_and_type.css` at the top.
3. **Use existing molecules.** Compose from `components.html` (Layer 2). Don't invent new component shapes.
4. **Frame inside the device.** Use the same iPhone phone-frame pattern from `room.html` / `trip-detail.html` (280×620 default).
5. **Tide at top of every product screen.** Even on settings, voice, etc. The state matches the surface — idle on settings, listening on voice.
6. **One layout, two themes.** Build light first. Dark falls out automatically via `[data-theme="dark"]` tokens (see `dark.html`).
7. **Add to foundations.html § 08** when the screen is locked, so future agents discover it.

---

## 5 · How to handoff to engineering

When the user asks for production handoff:

- `design-tokens.json` is the single source for Dart constants. Run `build_runner` from this file.
- `handoff.html` documents the four core widgets: `KaiTheme`, `KaiTokens`, `KaiTideCurve`, `KaiButton`, `KaiBubble`, `KaiCompose`, `KaiMotion`.
- Reference Flutter source under `reference/flutter_source/` is **legacy** (pre-redesign). Use it only to understand the backend integration shape, never copy styling.

---

## 6 · When to push back

Push back on user requests that:
- Add chrome to the room (persistent input bar, top nav, bottom tabs).
- Use bright red for errors.
- Add tool-management surfaces (the backend owns this).
- Invent new gradients or colors outside `--tide-*` and `--accent`.
- Build a takeover crisis modal (C3 pattern is locked).
- Add emoji as decoration (only as data — flags in passport, etc).

Frame the pushback as a choice: "This conflicts with [rule]. We can do it your way, or [alternative that keeps the rule]. Which?"

---

## 7 · Glossary

| Term | Meaning |
|------|---------|
| Tide | The brand. The gradient (#1B4FB0 → #2BA8C9 → #F4B589). The curve at the top of every screen. |
| Zero-UI | No persistent chrome. Surfaces are summoned by gesture, not always visible. |
| Compose-island | The pill-shaped input + mic + send at the bottom of the chat. |
| Panel | The side surface summoned by swipe-from-left. Full-screen, not pinned. |
| Trip | A folder of chats grouped by destination. First-class entity. |
| Memory | Structured facts Kai stores about the user. Visible, editable, GDPR-forgettable. |
| Care-block | The crisis pattern — phone numbers as a left-border block inside Kai's normal reply. |

---

**Last sync:** 2026-05-26 · v2 pass. 18 canonical artifacts + `review.html` (audit) + `roadmap.html` (planning). New: `tide-states.html` (8 animated states), `notifications-chat.html` (Alert Card N-01), `room.html` +2 frames (streaming/error). System ready for production handoff.
