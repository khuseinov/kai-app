# KAI Design System — COMPONENTS.md

**Agent source of truth for all UI components in `lib/design_system/`.**

All computed styles in this file were extracted via Playwright iframe injection
(100% browser-accurate — cascades, inheritance, and token resolution applied).

**How to use this file:**
1. Find the HTML selector in Section 3 to get the authoritative Dart widget.
2. Look up the Dart component in Section 4 for constructor API and key dimensions.
3. Check Section 5 before editing — if HTML canon and Dart differ, note the reason.
4. Sections 6-7 cover screens/widgets in progress and new widgets still needed.

**Dev storybook (adaptive — sidebar + canvas + knobs + inspector):**
`/_dev/storybook` — best in browser (`flutter run -d chrome`). Includes live
light/dark segmented theme switch, search, and per-component state knobs.
Old per-layer routes (`/_dev/atoms`, etc.) are gone; this single route covers all layers.

**Import barrel:** `import 'package:kai_app/design_system/tokens/kai_tokens.dart';`
- Tokens: `KaiColors`, `KaiSpace`, `KaiRadius`, `KaiType`, `KaiTide`, `KaiMotion`, `KaiShadow`
- Access colors at runtime: `KaiTheme.of(context).colors.<name>`

---

## 1. QUICK TOKEN REFERENCE

### KaiSpace (4px grid, 11-step)
| Token | px  | Common use                        |
|-------|-----|-----------------------------------|
| s1    | 4   | icon gap, badge pad               |
| s2    | 8   | small gap, vertical bubble pad    |
| s3    | 12  | std padding, input pad            |
| s4    | 16  | appbar pad, compose left pad      |
| s5    | 20  | button horizontal pad             |
| s6    | 24  | button lg horizontal pad          |
| s7    | 32  | —                                 |
| s8    | 40  | —                                 |
| s9    | 56  | —                                 |
| s10   | 80  | —                                 |
| s11   | 120 | —                                 |

### KaiRadius
| Token       | px  | Common use                                         |
|-------------|-----|----------------------------------------------------|
| r1 / br1    | 6   | tags, small chips, index chips                     |
| r2 / br2    | 10  | inputs, src-card, search box                       |
| r3 / br3    | 14  | buttons (default), alert card                      |
| r4 / br4    | 20  | onboarding glyph, large cards                      |
| r5 / br5    | 28  | panel corners, hero surfaces                       |
| pill / brPill | 999 | toggles, toasts, suggestions, compose pill      |
| r8 / br8    | 8   | detail-row actions, small surfaces                 |
| r12 / br12  | 12  | nav new-chat, settings group, system note          |
| r24 / br24  | 24  | bottom-sheet top corners                           |

### KaiType (static factory, takes Color)
| Method  | px | Weight | Family        | Use                            |
|---------|----|--------|---------------|--------------------------------|
| hero    | 72 | w600   | Manrope       | Display hero copy              |
| display | 56 | w600   | Manrope       | Large display                  |
| h1      | 36 | w600   | Manrope       | Section heading                |
| h2      | 24 | w600   | Manrope       | Card heading                   |
| h3      | 18 | w600   | Manrope       | Sub-heading                    |
| lead    | 20 | w400   | Manrope       | Lead paragraph                 |
| body    | 16 | w400   | Manrope       | Body text                      |
| small   | 14 | w400   | Manrope       | Most UI text (base)            |
| micro   | 12 | w500   | Manrope       | Caps labels, badge text        |
| mono    | 12 | w400   | JetBrainsMono | Mono labels, timestamps        |

Note: most bubble/UI text is **off-scale** (9, 10, 11, 11.5, 12.5, 13, 13.5 px).
Use `KaiType.small(color:).copyWith(fontSize: X)` to apply family + features.

### KaiTide (two gradients, locked)
| Token          | Angle | Stops       | Use                                            |
|----------------|-------|-------------|------------------------------------------------|
| gradient       | 115°  | 0/0.52/1.0  | Tide curve, send button, primary CTA, toast memory |
| gradientCorner | 135°  | 0/0.55/1.0  | Square brand surfaces: avatar, icon, splash    |

Stop colors: stop1=`#1B4FB0`, stop2=`#2BA8C9`, stop3=`#F4B589`

### KaiMotion
| Token     | Duration | Curve              | Use                       |
|-----------|----------|--------------------|---------------------------|
| standard  | 240ms    | Cubic(0.2,0,0,1)   | UI panels, toggles        |
| ambient   | 2600ms   | Cubic(0.4,0,0.6,1) | Tide pulse, brand cycles  |
| micro     | 120ms    | Cubic(0.2,0,0,1)   | Button press scale        |

### KaiShadow
| Token  | Value                                       | Use                   |
|--------|---------------------------------------------|-----------------------|
| button | rgba(43,168,201,0.18) blur8 y+2             | Tide gradient buttons |
| glow   | rgba(43,168,201,0.384) blur16 y0            | Money-gate hero       |
| thumb  | rgba(0,0,0,0.18) blur3 y+1                 | Toggle thumb          |

---

## 2. COLOR TOKENS

All values are exact hex. Dark palette used when `data-theme="dark"` or device dark mode.

| Token        | Light hex | Dark hex         | Use case                                          |
|--------------|-----------|------------------|---------------------------------------------------|
| bg           | #FAFAF9   | #0E0E11          | Page / scaffold background                        |
| surface      | #FFFFFF   | #16161A          | Cards, sheets, panels, compose island             |
| surface2     | #F3F3F1   | #1E1E23          | Bubbles, inputs, settings groups, src cards       |
| surface3     | #ECECEA   | #25252A          | Toggle OFF, segmented control track               |
| ink1         | #111114   | #F5F5F2          | Primary text, buttons fill (dark island)          |
| ink2         | #43434A   | #C8C8C2          | Secondary text, care block copy                   |
| ink3         | #76767E   | #8E8E88          | Mono labels, icon buttons, disabled text          |
| ink4         | #A8A8AE   | #5C5C58          | Placeholders, disabled send, timestamp            |
| line         | #E8E8E5   | #2A2A2F          | Hairline borders, 0.8px compose border            |
| lineStrong   | #D2D2CE   | #3A3A3F          | Focused input border                              |
| accent       | #2C5BE5   | #5C8EFF          | Links, toggle ON, active indicators               |
| accentDeep   | #1E48C7   | #4275E5          | Pressed accent, hover                             |
| accentWash   | #EEF2FD   | rgba(5C8EFF,0.12) | Chat active bg, chip selected bg               |
| accentLine   | #C3D2F6   | rgba(5C8EFF,0.28) | Plan badge border                               |
| positive     | #1B8E4E   | #3DBE7A          | Toggle ON (memory), freshness, alerts             |
| positiveWash | #E6F4ED   | rgba(3DBE7A,0.12) | Positive alert bg                               |
| warning      | #B57A0B   | #D69E3E          | Inline notes, offline dot                         |
| warningWash  | #FBF1DC   | rgba(D69E3E,0.12) | Warning system bubble bg                        |
| negative     | #C44A3C   | #E66F60          | Crisis CTA, error, danger rows — coral NOT red    |
| negativeWash | #F8E6E3   | rgba(E66F60,0.12) | Alert card bg, danger border                    |

**Voice screen only:** bg=`#08080A` (Color(0xFF08080A)) — always dark, ignores theme.

---

## 3. CANON TO COMPONENT LOOKUP

Ordered by HTML source file. "D2" = authoritative design decision (overrides other files).

### room.html (D2 AUTHORITATIVE for chat bubbles)
| HTML selector             | Dart widget                          | Import barrel | Notes                                   |
|---------------------------|-------------------------------------|---------------|-----------------------------------------|
| `.user-b`                 | `KaiUserBubble`                     | molecules     | D2: 13px, pad 9/13, r 16/16/4/16       |
| `.kai-b` (container)      | `KaiKaiBubble`                      | molecules     | Column, no bg                           |
| `.kai-b .who`             | (inside KaiKaiBubble)               | —             | 9px JetBrains Mono, ink3, ls 0.72px    |
| `.kai-b .txt`             | (inside KaiKaiBubble)               | —             | D2: 13.5px/400/ink1, lh 1.55           |
| `.kai-b .cite`            | (inline TextSpan)                   | —             | 13.5px/500, accent                      |
| `.compose-island`         | `KaiComposeIsland`                  | molecules     | surface, brPill, pad 5/5/5/16           |
| `.compose-island send`    | `KaiSendButton`                     | atoms         | 30x30 circle, tide/ink4 state           |
| `.compose-island mic`     | `KaiIconButton.transparent`         | atoms         | 30x30, ink3                             |
| `.src-card`               | `KaiSourceCard`                     | molecules     | surface2, r10, pad 8/10                 |
| `.src-card .h`            | (inside KaiSourceCard)              | —             | 9px mono, ink3                          |
| `.src-card .t`            | (inside KaiSourceCard)              | —             | 11.5px/500, ink1                        |
| `.src-card .s`            | (inside KaiSourceCard)              | —             | 10px/400, ink3                          |
| `.sugg` (chip)            | `KaiChip.choice(selected:false)`    | atoms         | surface2, r12, pad 11/14               |
| `.day` (day label)        | inline `Text`                       | —             | 9px mono, ink3, ls 0.9px               |

### components.html (catalog display — slightly larger, NOT D2 canon)
| HTML selector             | Dart widget                          | Import barrel | Notes                                   |
|---------------------------|-------------------------------------|---------------|-----------------------------------------|
| `.bub.user`               | `KaiUserBubble`                     | molecules     | Catalog sizes differ — use room.html    |
| `.bub.kai`                | `KaiKaiBubble`                      | molecules     | Catalog sizes differ — use room.html    |
| `.bub.system`             | `KaiSystemBubble`                   | molecules     | 13.5px, r12, surface2/warningWash bg    |
| `.toast` (pill)           | `KaiToast`                          | molecules     | Dark island, brPill, 11px/500           |
| `.toast .open`            | (inside KaiToast)                   | —             | 12px/600, KaiTide.stop2 color           |
| `.src-row`                | `KaiSourceCard`                     | molecules     | 12.5px/400, r10, pad 8/10               |
| `.src-row .n`             | (index chip inside)                 | —             | 10px mono, r4, surface bg               |
| `.src-row .url`           | (url inside)                        | —             | 12.5px/500, ink1                        |
| `.sheet` (bottom)         | `KaiSheetShell`                     | atoms         | surface, r 24/24/0/0, pad 12/14/16      |
| `.sheet.compose`          | `KaiComposeIsland`                  | molecules     | Compose pill variant                    |
| `.sheet.actions .act-row` | `KaiActionSheet`                    | molecules     | r10, pad 10/8                           |
| `.sheet.detail .act`      | `KaiButton.text(size:sm)`           | atoms         | 12.5px/500, r8, pad 10/8               |
| drawer `.new-btn`         | `KaiButton.ink(fullWidth:true)`     | atoms         | 13.5px/600, r12, pad 11, bg ink1        |
| drawer `.ses.active`      | (inside KaiNavPanel)                | —             | accentWash, border-left 2px accent      |
| drawer `.dr-label`        | (section label in panel)            | —             | 10px mono, ink3, ls 0.8px              |

### nav.html (authoritative for nav panel)
| HTML selector             | Dart widget                          | Import barrel | Notes                                   |
|---------------------------|-------------------------------------|---------------|-----------------------------------------|
| `panel`                   | `KaiNavPanel`                       | organisms     | surface bg, r28, full-screen            |
| `.new-chat button`        | `KaiButton.ink(fullWidth:true)`     | atoms         | 13px/600, r12, pad 11, ink1 bg, white   |
| `.search-box`             | `KaiInput.line`                     | atoms         | 12.5px/400, ink3, r10, pad 9/12, surface2 |
| `.pin-trip`               | (inside KaiNavPanel)                | —             | r12, pad 11/12                          |
| `.pin-trip glyph`         | `KaiAvatar` (size ~20)              | atoms         | tide-corner, 11px/700, r9               |
| `.pin-trip title`         | inline `Text`                       | —             | 13px/600, ink1                          |
| `.sec-label`              | (inside KaiNavPanel)                | —             | 9px mono, ink3, pad 12/18/6             |
| `.folder-row`             | (inside KaiNavPanel)                | —             | pad 9/18                                |
| `.folder badge`           | `KaiBadge.count`                    | atoms         | 9px, ink3, surface2 bg, brPill          |
| `.chat-row`               | (inside KaiNavPanel)                | —             | accentWash, pad 8/18                    |
| `.chat-row .t`            | inline `Text`                       | —             | 12.5px/600, accent                      |
| `.app-row .dot`           | `KaiBadge.dot()`                    | atoms         | 5px circle, accent                      |
| `account .av`             | `KaiAvatar`                         | atoms         | tide-corner, circle, 11px/700 white     |
| `account .n`              | inline `Text`                       | —             | 13px/500, ink1                          |
| `account .plan`           | inline `Text`                       | —             | 9.5px/400, ink3                         |

### settings.html (authoritative for settings surface)
| HTML selector             | Dart widget                          | Import barrel | Notes                                   |
|---------------------------|-------------------------------------|---------------|-----------------------------------------|
| `.acc-hero`               | `KaiAccountHero`                    | molecules     | surface2, r12, pad 12                   |
| `.acc-hero .av`           | `KaiAvatar(size:36)`                | atoms         | 36px circle, tide-corner                |
| `.acc-hero .plan`         | (inside KaiAccountHero)             | —             | 9px/500 mono, accent, accentWash pill   |
| `.group`                  | `KaiSettingsGroup`                  | molecules     | surface2, r12, pad 3px                  |
| `.group .row`             | `KaiSettingsRow`                    | molecules     | r8, pad 9/11, bg transparent            |
| `.group .row .t`          | (inside KaiSettingsRow)             | —             | 12px/500, ink1, ls -0.005em             |
| `.group .row .s`          | (inside KaiSettingsRow)             | —             | 10px mono, ink3                         |
| `.group .row .trail`      | trailing param in row               | —             | 11px/500, ink3 (trailing value)          |
| `.danger-group`           | `KaiSettingsGroup(danger:true)`     | molecules     | surface bg, r12, negativeWash border    |
| `toggle`                  | `KaiToggle`                         | atoms         | 34x20, r999, surface3/accent            |
| `.seg`                    | `KaiSegmentedControl`               | molecules     | surface3 track, r8, inner r6            |
| `appbar .ttl`             | inline `Text`                       | —             | 13px/600, ink1                          |
| `.ic-btn`                 | `KaiIconButton.surface`             | atoms         | circle, surface2 bg                     |

### edge-states.html (authoritative)
| HTML selector             | Dart widget                                    | Import barrel | Notes                              |
|---------------------------|-----------------------------------------------|---------------|------------------------------------|
| `.offline-strip`          | (inside KaiEdgeStateBlock)                    | —             | surface, r10, pad 8/12, 11px/500, ink2 |
| `.offline .dot`           | (inline Container)                            | —             | circle, warning bg                 |
| `.inline-note`            | `KaiSystemBubble(tone:KaiSystemTone.warning)` | molecules     | warningWash, r12, pad 11/14, 12.5px |
| `.inline-note .ttl`       | bold param in KaiSystemBubble                 | —             | 12.5px/600, warning                |
| `.retry button`           | `KaiButton.ghost(pill:true, tone:warning)`    | atoms         | 10px/600, brPill, warning          |
| `.care-block`             | `KaiCareBlock`                                | molecules     | neg-wash 4%, r 0/10/10/0, pad 12/14 |
| `.care-block .res`        | (KaiCareResource inside)                      | —             | 12px/500, negative                 |
| `.care-block .num`        | (number inside)                               | —             | 14px/600, negative (Manrope, not mono) |
| `KaiEdgeStateBlock`       | `KaiEdgeStateBlock`                           | organisms     | Composes above atoms by surface    |

### notifications-chat.html (alert card N-01, authoritative)
| HTML selector             | Dart widget                          | Import barrel | Notes                                   |
|---------------------------|-------------------------------------|---------------|-----------------------------------------|
| `.alert-card`             | `KaiAlertCard`                      | molecules     | negativeWash bg, r14                    |
| `.ac-head`                | (inside KaiAlertCard)               | —             | rgba(neg,0.08), pad 7/11/6              |
| `.ac-icon`                | (inside KaiAlertCard)               | —             | 16x16 r5, rgba(neg,0.15)               |
| `.ac-type`                | (inside KaiAlertCard)               | —             | 8px/700 mono, negative, UPPERCASE       |
| `.ac-time`                | (inside KaiAlertCard)               | —             | 8px/400 mono, ink4                      |
| `.ac-title`               | (inside KaiAlertCard)               | —             | 11.5px/600, ink1, lh 1.3               |
| `.ac-text`                | (inside KaiAlertCard)               | —             | 11px/400, ink2, lh 1.45                |
| `.ac-cta`                 | `KaiButton.ghost(pill:true)`        | atoms         | 10px/600, negative tone, brPill         |
| `.live-dot`               | (inline Container)                  | —             | 8px circle, negative                    |

### onboarding.html (authoritative)
| HTML selector             | Dart widget                          | Import barrel | Notes                                   |
|---------------------------|-------------------------------------|---------------|-----------------------------------------|
| `ob .glyph`               | `KaiAvatar(size:48)`                | atoms         | tide-corner, r20 (r4=20)               |
| `ob-btn` step 0           | `KaiButton.ink` + tide-flash on tap | atoms         | ink bg at rest; brief tide-gradient flash on tap before onNext |
| `ob-btn` steps 1-3        | `KaiButton.ink`                     | atoms         | Same dims, ink1 bg                      |
| `ob-dots`                 | `KaiStepIndicator`                  | atoms         | count:4, active=stepIndex; active pill = accent brPill 16×6; inactive = ink4 6×6 |
| `ob-form .input`          | `KaiInput.line`                     | atoms         | 12px/400, surface2, r10, pad 10/12      |
| `ob-form .chip`           | `KaiChip.choice(selected:true)`     | atoms         | 11px/500, accent, accentWash, brPill    |
| `gesture .t`              | inline `Text`                       | —             | 11px/500, ink1                          |
| `gesture .s`              | inline `Text`                       | —             | 9.5px/400, ink3                         |
| `KaiOnboardingCard`       | `KaiOnboardingCard`                 | organisms     | Composes tide curve + steps             |

### fork.html (authoritative for fork comparison molecule)
| HTML selector             | Dart widget                          | Import barrel | Notes                                   |
|---------------------------|-------------------------------------|---------------|-----------------------------------------|
| `.fc`                     | `KaiForkCard`                       | molecules     | surface, br3 (14px), 1px line border    |
| `.fc-h`                   | (inside KaiForkCard)                | —             | 8.5px/500 JetBrainsMono, ink3, pad 7/11 |
| `.fc-col`                 | (inside KaiForkCard)                | —             | equal-width Expanded; pick col = accentWash tint + 2px tide top |
| `.fc-glyph`               | (inside KaiForkCard)                | —             | 18×18, tide-corner, r5, 7px/700 Manrope white |
| `.fc-name`                | (inside KaiForkCard)                | —             | 11.5px/600, ink1                        |
| `.fc-price`               | (inside KaiForkCard)                | —             | 19px/600, ink1                          |
| `.fc-chip` / `.chip`      | `KaiForkChip`                       | atoms         | 8px/600 Manrope, brPill, pad 2/6; tone: bad/neutral/ok |
| `.fc-score`               | `KaiForkScoreDots`                  | atoms         | 5×5px circles, 3px gap, default fill=positive |
| `.fc-badge`               | (inside KaiForkCard._PickBadge)     | —             | "✓ лучший", 7.5px/600 mono, tide-2 color, accentWash(10%) pill |

### trip-detail.html (authoritative for trip screen atoms)
| HTML selector             | Dart widget                          | Import barrel | Notes                                   |
|---------------------------|-------------------------------------|---------------|-----------------------------------------|
| `.budget-bar`             | `KaiBudgetBar`                      | atoms         | brPill track, surface3 bg, segmented color fill; height=8 default |

### voice.html (authoritative for voice mode atoms)
| HTML selector             | Dart widget                          | Import barrel | Notes                                   |
|---------------------------|-------------------------------------|---------------|-----------------------------------------|
| `.karaoke`                | `KaiKaraokeText`                    | atoms         | **Dark-surface only.** 16px/500 Manrope; now=tide-3 bg, next=dim white |
| `.tr-view`                | `KaiTranscriptView`                 | molecules     | **Dark-surface only.** Event pad 52/9/22/9; ts 8.5px/500 white@0.4 |

### foundations.html (token reference only)
| HTML class | Dart equivalent    | Notes                              |
|------------|--------------------|------------------------------------|
| t-hero     | KaiType.hero       | 72px                               |
| t-display  | KaiType.display    | 56px                               |
| t-h1       | KaiType.h1         | 36px                               |
| t-h2       | KaiType.h2         | 24px                               |
| t-h3       | KaiType.h3         | 18px                               |
| t-lead     | KaiType.lead       | 20px                               |
| t-body     | KaiType.body       | 16px                               |
| t-small    | KaiType.small      | 14px                               |
| t-micro    | KaiType.micro      | 12px/500                           |
| t-mono     | KaiType.mono       | 12px JetBrains Mono                |
| m-1        | KaiMotion.standard | 240ms Cubic(0.2,0,0,1)             |
| m-2        | KaiMotion.ambient  | 2600ms ease-in-out                 |
| m-3        | KaiMotion.micro    | 120ms linear                       |
| r-1..r-5   | KaiRadius.r1..r5   | 6/10/14/20/28                      |

---

## 4. DART COMPONENTS BY LAYER

### PRIMITIVES — `lib/design_system/primitives/`
Import: `import 'package:kai_app/design_system/primitives/primitives.dart';`

#### KaiIcon
File: `primitives/kai_icon.dart`
```dart
KaiIcon(KaiIconName.send, size: 18, color: c.ink2)
```
Renders an SVG icon from the `KaiIconName` enum. No background. Pure primitive.
Common sizes: 10 (alert chip), 11 (toast, react), 14 (mic), 15 (settings row),
16 (system note), 18 (default button icon), 20 (lg button icon).

#### KaiGradientBar
File: `primitives/kai_gradient_bar.dart`
```dart
KaiGradientBar(width: 16, height: 4)         // "who" glyph before KAI label
KaiGradientBar(width: 10, height: 2.5)       // toast memory marker
KaiGradientBar(width: 16, height: 4, pulse: true)      // breathing scale animation
KaiGradientBar(width: 16, height: 4, streaming: true)  // opacity pulse 0.6↔1.0 (Kai responding)
```
Pill-shaped (`brPill`) filled with `KaiTide.gradient`. Default 16x4.
`pulse`: scale 0.92↔1.08, `KaiMotion.ambient`. `streaming`: opacity 0.6↔1.0, same duration.
`streaming` takes precedence over `pulse` when both set.

#### KaiSurface
File: `primitives/kai_surface.dart`
Generic themed container. Uses surface token as bg.

---

### ATOMS — `lib/design_system/atoms/`
Import: `import 'package:kai_app/design_system/atoms/atoms.dart';`

#### KaiButton
File: `atoms/kai_button.dart`
4 named constructors × 3 size tiers.

```dart
KaiButton.tide(label:, onPressed:, [icon:, emphasis: KaiButtonEmphasis.normal,
    size: KaiButtonSize.md, tideAnim: KaiTideAnim.onInteraction, busy: false])
KaiButton.ink(label:, onPressed:, [icon:, fullWidth: false, size: KaiButtonSize.md])
KaiButton.ghost(label:, onPressed:, [tone: KaiButtonTone.neutral, pill: false, size: KaiButtonSize.md])
KaiButton.text(label:, onPressed:, [tone: KaiButtonTone.neutral, size: KaiButtonSize.md])
```

Size tiers:
| Size | Font         | Padding   | Icon | Use                                       |
|------|-------------|-----------|------|-------------------------------------------|
| sm   | 12.5px/w500 | 8v x 12h  | 16   | toast .open, detail sheet action          |
| md   | 13.5px/w600 | 12v x 20h | 18   | default everywhere                        |
| lg   | 15px/w600   | 16v x 24h | 20   | hero CTA (onboarding step 0, money-gate)  |

Special case — `ink(fullWidth:true)`: all-sides 11px padding, r12, full width.
Canon: nav "new-chat" button.

Variants:
- `tide`: KaiTide.gradient + KaiShadow.button. Tide gradient animates (respects reduce-motion).
  - `tideAnim: KaiTideAnim.onInteraction` (DEFAULT) — gradient flows on hover/press.
  - `tideAnim: KaiTideAnim.onState` + `busy: true` — flows while Kai is streaming/busy.
  - `tideAnim: KaiTideAnim.none` — always static.
- `ink`: ink1 bg, **`surface` (theme-aware white) text** (legible in dark mode), br3 (or br12 if fullWidth).
- `ghost`: transparent fill, 1px border. `pill:true` -> brPill. Tone: neutral/warning/negative.
- `text`: no fill, no border. Tone: neutral/accent/negative.

Disabled: opacity 0.5, no tap. Press: AnimatedScale 0.97 / KaiMotion.micro.

#### KaiIconButton
File: `atoms/kai_icon_button.dart`
4 named constructors.
```dart
KaiIconButton.surface(onPressed:, icon:, [iconSize: KaiIconButtonSize.md, size:])    // surface2 fill, brPill, ink2
KaiIconButton.transparent(onPressed:, icon:, [iconSize: KaiIconButtonSize.md, size:]) // no bg, ink3
KaiIconButton.bare(onPressed:, icon:, [color:, iconSize: KaiIconButtonSize.md, size:]) // no bg, color-overridable
KaiIconButton.toggle(active:, onPressed:, icon:, [iconSize: KaiIconButtonSize.md])    // active=accentWash+accent; inactive=transparent+ink3
```
Size enum: `KaiIconButtonSize.sm` = 16px icon / 28px target; `KaiIconButtonSize.md` = 18px icon / 30px target (default).
Raw pixel override: pass `size:` double to win over `iconSize` (e.g. reaction icons at 11px).
Canon: `ic-btn` appbar (surface), compose mic (transparent), sheet close (bare), compose voice mode (toggle).

#### KaiSendButton
File: `atoms/kai_send_button.dart`
```dart
KaiSendButton(state: KaiSendState.ready, onPressed:, [size: 30, iconSize: 12])
```
States: ready (tide gradient + KaiShadow.button, tappable), disabled (ink4, opacity 0.5, not tappable),
sending (tide + scale-pulse), streaming (tide + scale-pulse, **shows `stop` glyph** instead of arrowUp).
Default: 30x30 circle, iconSize 12. Canon: compose island send button.

#### KaiToggle
File: `atoms/kai_toggle.dart`
```dart
KaiToggle(value: true, onChanged: (v) {})
```
Dimensions: track 34x20, thumb 16x16, inner padding 2px.
Track: surface3 (OFF) / accent (ON per settings.html). Thumb: white + KaiShadow.thumb.
Animation: AnimatedContainer + AnimatedAlign, KaiMotion.standard.
Note: memory.html shows toggle ON = `positive` (green). See Section 5 discrepancy.

#### KaiInput
File: `atoms/kai_input.dart`
2 named constructors.
```dart
KaiInput.line(controller:, [placeholder:, maxLines:1, onChanged:, enabled:true])
KaiInput.pill(controller:, [placeholder:, maxLines:1, onChanged:, enabled:true])
```
Both: surface2 fill, 0.8px line border (focused: lineStrong), 13.5px/400/lh1.4 Manrope.
`.line`: r10 (br2). Canon: nav search (pad 9/12).
`.pill`: brPill. Canon: compose-island textarea (pad 5/5/5/14).

#### KaiAvatar
File: `atoms/kai_avatar.dart`
```dart
KaiAvatar([size: 40, initial: 'R'])                              // legacy pixel-size ctor
KaiAvatar.user('R', [avatarSize: KaiAvatarSize.md, breathing: false])  // initial on gradient circle
KaiAvatar.kai([avatarSize: KaiAvatarSize.md, breathing: false])        // Kai mark (tide bar glyph)
```
All variants: circle filled with `KaiTide.gradientCorner`.
`KaiAvatarSize` enum: `sm`=28px, `md`=40px (default), `lg`=56px.
`breathing: true` adds scale 0.97↔1.03 `KaiMotion.ambient` pulse (respects reduce-motion).
Canon sizes: 36px legacy (settings acc-hero), 40px (nav account), 28px (compact hero), 20px approx (pin-trip glyph).

#### KaiBadge
File: `atoms/kai_badge.dart`
```dart
KaiBadge.dot([tone: KaiBadgeTone.accent, color:])  // 6px circle, 10px total with surface ring
KaiBadge.count(int count)                           // accent pill, white mono text; caps at "99+"
KaiBadge.tide()                                     // 8px tide-gradient dot, 12px total (memory-saved signal)
```
Dot variant: 6px inner + 2px surface ring each side = 10px outer.
`KaiBadgeTone`: `accent` (default) / `positive` / `warning` / `negative`. `color:` explicit override wins over tone.
Count variant: accent bg, br8, min 16px.
Tide variant: `KaiTide.gradientCorner` 8px dot inside 12px surface ring.

#### KaiChip
File: `atoms/kai_chip.dart`
```dart
KaiChip.status('LABEL', [tone: KaiChipTone.neutral, size: KaiChipSize.md])
KaiChip.choice('Label', selected: bool, [onTap:, size: KaiChipSize.md])
```
`KaiChipSize`: `sm` (status=11px/w500 mono; choice=12px) · `md` default (status=12px/w400 mono; choice=14px).
Status tones: neutral / done / active / **positive** / **warning** / **negative** (semantic tones added in C2).
- neutral: ink3, line border, no fill. done/positive: positiveWash+positive. active: accentWash+accent.
- warning: warningWash+warning. negative: negativeWash+negative.
Choice: brPill. Selected: surface bg + ink1. Unselected: transparent + ink3.
Note: onboarding chips use 11px/500 accent+accentWash — use `size:sm` + call-site color override (see Section 5).

#### KaiTideCurve
File: `atoms/kai_tide_curve.dart`
```dart
KaiTideCurve(state: KaiTide.idle, [height: 28, demoLoop: false])
```
Animated Kai tide line at the top of screens. 8 named states + muted static.
`demoLoop: true` — keeps ephemeral states (success/error/memory) looping instead of reverting. Storybook only; never set in production.
States via `KaiTide.*`:
| State      | Stroke | Opacity | Animation | Duration |
|------------|--------|---------|-----------|----------|
| idle       | 1.5px  | 0.40    | breathe   | 5500ms   |
| listening  | 2.0px  | 0.80    | bob       | 2200ms   |
| thinking   | 2.0px  | 0.85    | flow (dash 6/4) | 3000ms |
| responding | 2.5px  | 1.00    | stream (dash 12/4) | 1400ms |
| success    | 2.5px  | 1.00    | flash (ephemeral) | 1200ms |
| error      | 2.0px  | 0.95    | wobble (ephemeral) | 600ms |
| memory     | 2.0px  | 1.00    | pop (ephemeral) | 900ms |
| sleep      | 1.0px  | 0.20    | breathe   | 7000ms   |
| muted      | 1.8px  | 0.40    | none (gradient static) | — |

#### KaiSheetShell
File: `atoms/kai_sheet_shell.dart`
```dart
KaiSheetShell(child: Content())
```
Bottom-sheet chrome: surface bg, br24 top corners, pad 12/14/16. Standard modal bottom-sheet wrapper.

#### KaiStepIndicator
File: `atoms/kai_step_indicator.dart`
```dart
KaiStepIndicator(count: 4, active: stepIndex)
```
Animated step-progress dots. Active dot = elongated accent pill 16×6 (brPill, `c.accent`). Inactive dots = 6×6 circles (`c.ink4`). Gap 3px per side (6px between dots).
Uses `AnimatedContainer` with `KaiMotion.standard` (duration drops to zero when `MediaQuery.disableAnimations` is true).
Canon: `onboarding.html .ob-dots`.

#### KaiForkChip
File: `atoms/kai_fork_chip.dart`
```dart
KaiForkChip('безвиз', tone: KaiForkChipTone.ok)
```
Fork-card visa-status pill. 8px/w600 Manrope (sub-token — no KaiType method at 8px), brPill, pad 2v/6h.
`KaiForkChipTone`: `bad` (negativeWash+negative) / `neutral` (surface3+ink3+line border) / `ok` (positiveWash+positive).
Distinct from `KaiChip.status` (12px mono uppercase) — this is 8px Manrope, mixed-case, smaller.
Canon: `fork.html .chip` / `.fc-chip`.

#### KaiForkScoreDots
File: `atoms/kai_fork_score_dots.dart`
```dart
KaiForkScoreDots(score: 3, [max: 5, fillColor:])
```
Row of `max` (default 5) x 5px circles. First `score` are filled with `fillColor` (default `c.positive`); remainder with `c.surface3`. Gap 3px between dots.
Score is clamped to `[0, max]` at build time.
Canon: `fork.html .fc-score`.

#### KaiBudgetBar
File: `atoms/kai_budget_bar.dart`
```dart
KaiBudgetBar(
  segments: [KaiBudgetSegment(fraction: 0.45, color: c.accent, label: 'Отель')],
  [height: 8, showLegend: false],
)
```
`KaiBudgetSegment({required fraction, required color, required label})` — `fraction` in 0.0–1.0; sum ≤ 1.0 (remainder shows `surface3` track).
Track: `brPill`, `surface3` bg, `height` px tall. Segments implemented as `Expanded(flex)` inside `ClipRRect(brPill)`.
`showLegend: true` renders a `Wrap` of color-swatch + label rows below the track.
Canon: `trip-detail.html .budget-bar`.

#### KaiKaraokeText
File: `atoms/kai_karaoke_text.dart`
```dart
KaiKaraokeText(words: ['Дай', 'рейс', 'из', 'Москвы'], currentIndex: 2)
```
**Dark-surface only** — fixed white/tide literals, does NOT adapt to light mode.
Words before `currentIndex`: full white `0xFFFFFFFF` (spoken). Word at `currentIndex`: tide-3 amber bg `0x47F4B589` (r4, pad 1v/5h) + white text (now). Words after: dim white `0x52FFFFFF` (next).
Font: 16px/w500 Manrope. Layout: `Wrap(spacing:4, runSpacing:4)`.
Canon: `voice.html .karaoke`.

---

### MOLECULES — `lib/design_system/molecules/`
Import: `import 'package:kai_app/design_system/molecules/molecules.dart';`

#### KaiUserBubble (D2 authoritative: room.html)
File: `molecules/kai_user_bubble.dart`
```dart
KaiUserBubble(text: 'Hello')
```
Right-aligned, maxWidth 78% of screen.
Container: surface2 bg, r 16/16/4/16 (NOT 18px from components.html), pad 9v/13h.
Text: 13px/400, ink1, lh 1.45, ls -0.006em (= -0.08px at 13px).

#### KaiKaiBubble (D2 authoritative: room.html)
File: `molecules/kai_kai_bubble.dart`
```dart
KaiKaiBubble(
  text: 'Response [1].',
  sourcesLabel: '2 источника',
  sources: [KaiSourceCard(url: ...)],
  streaming: false,
  onThumbUp: () {},
  onThumbDown: () {},
)
```
No background. Column layout.
".who" row: KaiGradientBar(16x4) + "KAI" 9px mono ink3 ls 0.72px. Gap 6px.
".txt": 13.5px/400, ink1, lh 1.55, ls -0.0675px. Gap 5px below who.
Citations `[N]`: accent/500 TextSpan via regex parser.
Streaming caret: 7x14px block, ink1, blink 500ms half-period.
React row: KaiIconButton.bare 11px thumbUp/thumbDown, ink3.

#### KaiComposeIsland
File: `molecules/kai_compose_island.dart`
```dart
KaiComposeIsland(
  controller: controller,
  onSend: () {},
  onMicTap: () {},            // omit to hide mic in standard mode
  sendState: KaiSendState.ready,
  placeholder: 'Сообщение Kai…',
  mode: KaiComposeMode.standard,
)
```
`KaiComposeMode`: `standard` (default) / `voice` (mic accent-toggle, send hidden until text) / `offline` (input disabled, "оффлайн" hint, send always disabled).
Outer: surface bg, 0.8px line border, brPill, pad 5/5/5/16, gap 4 between children.
Text field: bare `TextField` (no double-border), 13.5px/400/lh1.4 Manrope.
Mic: `KaiIconButton.transparent` (standard) or `KaiIconButton.toggle(active:true)` (voice mode), size 14, 30x30.
Send: `KaiSendButton` 30x30, iconSize 12. State derived from text unless explicitly passed.

#### KaiSourceCard
File: `molecules/kai_source_card.dart`
```dart
KaiSourceCard(url: 'example.com', title: 'Title', snippet: 'Snippet', index: 1, fresh: false, onTap: () {})
```
Container: surface2 bg, r10, pad 8/10.
Index chip: JetBrains Mono 9px, surface bg, br1 (6px), 1px line border, pad 2/4.
Favicon: 10x10 tide-2 square, br1.
URL: JetBrains Mono 9px, ink3. (Catalog shows 12.5px — D2 room.html = 9px.)
Title: Manrope 11.5px/500. Snippet: 10px/400, ink3.

#### KaiSystemBubble
File: `molecules/kai_system_bubble.dart`
```dart
KaiSystemBubble('Message', bold: 'Note —', tone: KaiSystemTone.warning, icon: KaiIconName.alert)
```
Tones: neutral (surface2/ink2), warning (warningWash/warning), negative (negativeWash/negative).
Full width, r12, pad 12v/14h (drift: canon 11v/14h — +1px).
Text: 13.5px/400, lh 1.5. Bold prefix: w600.

#### KaiToast
File: `molecules/kai_toast.dart`
```dart
KaiToast(type: KaiToastType.neutral, label: 'Скопировано', actionLabel: 'Открыть', onAction: () {}, showCountdown: false)
KaiToast.undo(label:, onUndo:, [type: KaiToastType.neutral, showCountdown: true])
```
Types: neutral / positive / negative / memory. Always dark surface (dark-island pattern).
Pill: brPill, pad 7/14/7/9, shadow 0 2px 12px rgba(0,0,0,0.16).
Label: Manrope 11px/500, ls -0.005em. Text: `#F5F5F2` (dark.ink1).
Action: 12px/600 Manrope, `KaiTide.stop2` color — NOT dark-palette accent.
Countdown bar (`showCountdown:true`): static 110×2px pill (20% white track + 60% white fill). Animation driven externally by KaiToastController.
Memory variant: KaiTide.gradient bg, white text, white-75% pill marker.
`KaiToast.undo` — convenience factory: `actionLabel='Отменить'`, `showCountdown` defaults true.

#### KaiAlertCard
File: `molecules/kai_alert_card.dart`
```dart
KaiAlertCard(type: KaiAlertType.urgent, title: 'Title', body: 'Body', time: '9:41', cta: 'Action', onCtaTap: () {})
```
Types: urgent (negative palette), warning, positive, neutral.
Header: rgba(tone,0.08) bg, pad 7/11/6. Icon box: 16x16 r5, rgba(tone,0.15) fill.
Type label: 8px/700 JetBrains Mono, UPPERCASE, ls 0.1em.
Title: 11.5px/600, ink1, lh 1.3. Body: 11px/400, ink2, lh 1.45.
CTA: `KaiButton.ghost(tone:, pill:true)` — not a bespoke pill.

#### KaiCareBlock
File: `molecules/kai_care_block.dart`
```dart
KaiCareBlock(
  heading: 'Я слышу тебя.',
  body: 'Body copy...',
  resources: [KaiCareResource(label: 'Lifeline', number: '988')],
  closing: 'Closing italic.',
  onResourceTap: (r) {},
)
```
Left border 2px negative (coral). Right corners r2 (10px). Left corners flush (r0).
Bg: `negative.withValues(alpha: 0.04)`. Pad 14px all sides.
Numbers: Manrope 600/14, negative. NOT mono — warm and direct, not alarming.

#### KaiAccountHero
File: `molecules/kai_account_hero.dart`
```dart
KaiAccountHero(name: 'Name', email: 'email@...', initial: 'N', [planLabel:, variant: KaiAccountHeroVariant.full, onTap:])
```
`KaiAccountHeroVariant`: `full` (default — avatar 36px + name + email + plan badge) / `compact` (avatar 28px + name only, single row).
`onTap:` wraps the card in an `InkWell(br12)` when provided.
Container: surface2, r12, pad 12. Full: `KaiAvatar(size:36)`.
Name: Manrope 600/13, ink1, ls -0.01em. Email: JetBrains Mono 400/10, ink3.
Plan badge: JetBrains Mono 500/9 UPPERCASE, accent on accentWash, brPill, accentLine border, ls 0.06em. (Full variant only.)

#### KaiSegmentedControl
File: `molecules/kai_segmented_control.dart`
```dart
KaiSegmentedControl(options: ['A', 'B'], selectedIndex: 0, onSelected: (i) {})
```
Track: surface3 bg, br8 (8px), pad 2. Option: pad 4/9, 11px/500 Manrope.
Active: surface bg + ink1. Inactive: ink3. Inner segment br1 (6px). Gap 2 between options.

#### KaiSettingsRow
File: `molecules/kai_settings_row.dart`
```dart
KaiSettingsRow(icon: KaiIconName.settings, title: 'Label', subtitle: 'Sub', trailing: KaiToggle(...), onTap: () {}, danger: false)
```
Pad 9/11, br8 tap ripple. Icon slot 16px wide, icon 15px, ink3 (or negative on danger).
Title: Manrope 500/12, ink1, ls -0.005em. Subtitle: JetBrains Mono 400/10, ink3.
Trailing: any widget (KaiToggle, KaiSegmentedControl, KaiIcon.chevRight, Text).

#### KaiSettingsGroup
File: `molecules/kai_settings_group.dart`
```dart
KaiSettingsGroup(label: 'внешний вид', danger: false, children: [...])
```
Normal: surface2 bg, r12, pad 3px inner.
Danger: surface bg, r12, 1px negativeWash border, pad 4px inner.
Label: JetBrains Mono 400/9, ink3, ls 0.1em, pad 2/4/0. Gap 6px below label.

#### KaiNavItem
File: `molecules/kai_nav_item.dart`
Nav row widget for panel rows. Wraps icon + label + optional badge.

#### KaiActionSheet
File: `molecules/kai_action_sheet.dart`
Bottom-sheet action list. Uses KaiSheetShell as chrome. Rows: r10, pad 10/8.

#### KaiMessageDetailSheet
File: `molecules/kai_message_detail_sheet.dart`
Detail sheet for a single message. Actions: `KaiButton.text(size:sm)`, 12.5px/500, r8.

#### KaiForkCard
File: `molecules/kai_fork_card.dart`
```dart
KaiForkCard(
  columns: [
    KaiForkColumn(name: 'Япония', glyph: 'JP', price: '\$2,100', rows: [
      KaiForkRow(label: 'виза', value: '', chipTone: KaiForkChipTone.ok, chipLabel: 'безвиз'),
      KaiForkRow(label: 'погода', value: '27°C', score: 4),
    ]),
    KaiForkColumn(...),
  ],
  pickIndex: 0,
  [headerLabel:],
)
```
`KaiForkColumn({required name, required glyph, required price, required rows})`.
`KaiForkRow({required label, required value, chipTone?, chipLabel?, score?})` — `chipTone`+`chipLabel` renders `KaiForkChip`; `score` renders `KaiForkScoreDots`.
2-column (or more) comparison rendered in the chat feed. Outer: surface, br3 (14px), 1px line border.
Pick column (`pickIndex`): accentWash tint + 2px tide-gradient top border + "✓ лучший" badge.
Header: 8.5px/500 JetBrainsMono ink3, 5px positive live-dot. Glyph: 18×18 tide-corner r5.
Canon: `fork.html .fc`.

#### KaiTranscriptView
File: `molecules/kai_transcript_view.dart`
```dart
KaiTranscriptView(events: [KaiTranscriptEvent(who: 'kai', text: 'Найдено…', timestamp: '9:41')])
```
`KaiTranscriptEvent({required who, required text, required timestamp})` — `who` must be `'you'` or `'kai'`.
**Dark-surface only** — fixed white literals, does NOT adapt to light mode.
Event padding: `EdgeInsets.fromLTRB(52, 9, 22, 9)`. Kai events show `KaiGradientBar(16×4)` above timestamp.
Timestamp: 8.5px/w500 Manrope, white@0.4 (`0x66FFFFFF`). Body: 13px/w400, full white, lh 1.5.
Canon: `voice.html .tr-view / .tr-event`.

---

### ORGANISMS — `lib/design_system/organisms/`
Import: `import 'package:kai_app/design_system/organisms/organisms.dart';`

#### KaiChatList
File: `organisms/kai_chat_list.dart`
Scrollable chat feed. Composes KaiUserBubble, KaiKaiBubble, KaiSystemBubble,
KaiAlertCard, KaiCareBlock, KaiSourceCard, day labels.

#### KaiNavPanel
File: `organisms/kai_nav_panel.dart`
```dart
KaiNavPanel(sessions: [...], onNewChat: () {}, strings: KaiNavStrings.russian, ...)
```
Full-screen surface panel, r28. **No top-bar X button and no "kai" title** — panel closes by swipe-left only (zero-UI).
Sections: new-chat button, search, pin-trip, section labels, folder rows, chat rows, app rows (Memory/Settings), account hero.
New-chat: `KaiButton.ink(fullWidth:true)`. Search: `KaiInput.line`. Account: `KaiAccountHero`.
App rows use `KaiBadge.dot()` for Memory indicator.

#### KaiEdgeStateBlock
File: `organisms/kai_edge_state_block.dart`
```dart
KaiEdgeStateBlock(surface: KaiEdgeSurface.offline, onRetry: () {}, onPlans: () {}, countdown: 42)
```
Surfaces: offline (strip + warning retry ghost), error (negative retry ghost),
rateLimit (tide glow CTA for money-gate), crisis (KaiCareBlock inline).
All buttons delegate to KaiButton atoms. Zero hardcoded colors.

#### KaiOnboardingCard
File: `organisms/kai_onboarding_card.dart`
4-step onboarding surface. Tide curve header (muted state on passive steps), KaiAvatar glyph,
`KaiStepIndicator(count:4, active:stepIndex)`, primary button — **step 0: `KaiButton.ink` with a tide-flash on tap** (ink at rest, tide flash confirms tap before calling `onNext`); steps 1-3: plain `KaiButton.ink`. Gesture hints, optional form input + choice chips.

---

## 5. COMPONENT DISCREPANCIES

HTML canon vs. current Dart implementation. Always read before editing.

| Component                   | Property          | HTML Canon (file)                    | Dart Value              | Severity | Notes                                                        |
|-----------------------------|-------------------|--------------------------------------|-------------------------|----------|--------------------------------------------------------------|
| `KaiToggle`                 | ON track color    | `positive` (#1B8E4E) — memory.html  | `accent` (#2C5BE5)     | LOW      | settings.html shows accent; memory.html shows green. Both may be intentional (context-specific use). |
| `KaiChip.choice`            | Font size (selected) | 11px/500 — onboarding.html        | 14px/400 (KaiType.small) | MED    | Onboarding chips are smaller. Call-site can `.copyWith(fontSize:11, fontWeight:w500)` or use a new `KaiChip.small` constructor. |
| `KaiChip.choice`            | Colors (selected) | accent text + accentWash — onboarding.html | surface bg + ink1 | MED  | Onboarding selected = accent/accentWash. Generic choice selected = surface/ink1. Customization needed at onboarding call site. |
| `KaiButton.ink(fullWidth)`  | Font size         | 13px — nav.html `.new-btn`          | 13.5px (md tier)        | LOW      | 0.5px delta. Visually negligible. Both files show 13–13.5px range. |
| `KaiSourceCard`             | URL font size     | 12.5px — components.html            | 9px — room.html D2      | RESOLVED | D2 decision: room.html is authoritative. 9px is correct for inline chat. |
| `KaiSystemBubble`           | Vertical padding  | 11px — components.html              | 12px (KaiSpace.s3)      | LOW      | +1px drift. Documented in source comments. |
| `KaiSourceCard`             | Index chip radius | r4 (4px) — components.html         | br1 (6px)               | LOW      | Sub-pixel on a 9-10px chip. Imperceptible in use. |
| `KaiKaiBubble`              | Body line-height  | 1.5 (20.25/13.5) — room.html       | 1.55                    | LOW      | 0.05 drift. Near-identical visually. |
| `KaiButton.ghost(sm)`       | Font size         | 12px/600 — components.html `.act`   | 12.5px/500 (sm tier)    | LOW      | Toast `.open` is handled by internal `_ToastActionButton` (12px/600 exact). Generic sm tier is close but not identical. |
| `KaiCareBlock`              | Interior padding  | 14px — edge-states.html             | 14px literal            | MATCH    | Correctly uses literal 14 between s3(12) and s4(16). |

---

## 6. SCREENS / FEATURES IN PROGRESS

### 6.1 Voice Mode — `new-design/voice.html`

**Critical rule:** Background is ALWAYS `#08080A` (Color(0xFF08080A)). Never responds to theme toggle.

Gradients (named in HTML):
- `g-tide`: `KaiTide.gradient` (standard)
- `g-blue`: `#1B4FB0` -> `#6FA7FF` (listening state)
- `g-warm`: `#2BA8C9` -> `#F4B589` (speaking state — tide stop2->stop3)
- `g-mute`: `#5C5C58` -> `#76767E` (muted state)

4 frames:
1. `01-waiting`: Tide curve idle, minimal UI
2. `02-listening`: Tide curve listening, g-blue gradient elements
3. `03-speaking-karaoke`: Active karaoke text with g-warm
4. `04-transcript`: Full transcript timeline view

**Karaoke widget (`.karaoke`)** — **BUILT: `KaiKaraokeText` (atom)**
Row of word spans with now/next/spoken styling. See Section 4.

**Transcript view (`.tr-view`)** — **BUILT: `KaiTranscriptView` (molecule)**
Timestamped event list. See Section 4.

**Tide states used:** All 8 standard KaiTide states via `KaiTideCurve`.

Still needed (screen assembly):
- `KaiVoiceScaffold` — dark scaffold bg Color(0xFF08080A), no theme switching — screen-level wrapper, not a DS component

### 6.2 Memory App — `new-design/memory.html`

Appbar: pad 0/16, title 13px/600, `KaiIconButton.surface`.
Search: `KaiInput.line`, 12.5px/400, ink3, r10, pad 9/12, surface2 (same as nav).

**Memory hero (`.mem-hero`)**
Container: r16, pad 14.
Title (`.t`): 14px/600, ink1. Sub (`.s`): 11px/400, ink3.

**Memory groups**
Container: surface2, r12, pad 4px (identical to `KaiSettingsGroup`).
Row (`.fact-item`): r8, pad 9/11 (identical to `KaiSettingsRow`).
Body text: ~13px Manrope.
Source attribution (`.src`): 9.5px/400, ink3.
Menu dots (`.dots`): ink3, pad 4px.

**Danger row (`.danger-row`)**
r8, pad 11/12, negative color. Maps to `KaiSettingsRow(danger:true)`.

**Toggle ON state**: `positive` (green #1B8E4E) — NOT accent.
This is memory-specific context. Settings uses accent. Both use same `KaiToggle` atom
but the color discrepancy exists (see Section 5).

Reuses existing DS: `KaiInput.line`, `KaiSettingsGroup`, `KaiSettingsRow`,
`KaiToggle`, `KaiAccountHero` pattern.
New widget needed: `KaiMemoryHero` (r16 card with title + sub).

### 6.3 Trip Detail — `new-design/trip-detail.html`

Appbar: pad 0/16. Title: 13px/600. `KaiIconButton.surface` back button.

**Trip hero (`.trip-hero`)**
Container: r16, pad 16, transparent bg.
Glyph: `KaiAvatar(size:36)`, tide-corner, 13px/700 white, r11.
Name (`.name`): 16px/600, lh 1.2.
Sub (`.sub`): 11px/400, ink3.
Stats `.n`: 16px/600, lh 1.0 (number). Stats `.l`: 9px/500, ink3 (label).
Budget bar: brPill, surface3 bg — segmented with color fill.

**Facts grid**
Fact container: surface2, r12, pad 4px.
Key (`.k`): 11px/400, ink3. Value (`.v`): 11.5px/500, ink1.

**Chat items (`.chat-item`)**
Container: accentWash, r10, pad 9/10.
Title (`.t`): 12px/600, accent. Preview (`.preview`): 10.5px/400, ink3.

**Source items (`.src-item`)**
Pad 8/10. URL (`.u`): 11px/500, ink2.

**Ask button**: `KaiButton.ink(fullWidth:true)` — 13px/600, white, r12, ink1 bg, pad 11.

**QA chips (`.qa`)**: surface2, r10, pad 9/6.

**Budget bar (`.budget-bar`)** — **BUILT: `KaiBudgetBar` (atom)**. See Section 4.

Still needed (screen assembly):
- `TripHeroCard` — trip header with avatar, name, stats, budget bar (feature-level, not DS)
- `KaiFactGrid` — 2-col key/value grid using surface2 cards
- `KaiChatPreviewItem` — compact accentWash chat row (could reuse nav chat-row pattern)

### 6.4 Fork Card Molecule — `new-design/fork.html`

**BUILT: `KaiForkCard` (molecule), `KaiForkChip` (atom), `KaiForkScoreDots` (atom)**. See Section 4.

The main 2-column comparison molecule renders inside the chat feed as a Kai response. Pick badge ("✓ лучший") and tide-accent top border highlight the recommended option.

Still needed:
- `KaiForkPriceDelta` — color-coded price + directional delta indicator (`.fc-delta` — not yet extracted to a dedicated widget; currently inline in feature code)

---

## 7. WIDGETS STILL NEEDED (seen in HTML, not yet in Dart system)

Built in C1-C3 cycles and removed from this list: `KaiKaraokeText`, `KaiTranscriptView`,
`KaiBudgetBar`, `KaiForkCard`, `KaiForkChip`, `KaiForkScoreDots`, `KaiStepIndicator`.

| Widget name         | Source file              | Description                                                      |
|---------------------|-------------------------|------------------------------------------------------------------|
| `KaiVoiceScaffold`  | voice.html              | Dark scaffold Color(0xFF08080A), always dark, no theme toggle    |
| `KaiFactGrid`       | trip-detail.html        | 2-col key/value grid in surface2 cards                           |
| `KaiChatPreviewItem`| trip-detail.html        | accentWash r10 compact row: title accent + preview ink3          |
| `KaiForkPriceDelta` | fork.html               | Price + directional delta indicator (`.fc-delta`)                |
| `KaiBadge.folder`   | nav.html                | 9px ink3 count on surface2 brPill (vs accent count badge)        |
| `KaiSuggChip`       | room.html               | Suggestion chips: surface2, r12, pad 11/14 (currently inline)   |
| `KaiDayLabel`       | room.html               | Day separator: 9px mono ink3 ls 0.9px (currently inline Text)    |
| `KaiLiveDot`        | notifications-chat.html | 8px negative circle, proactive presence indicator                |
| `KaiMemoryHero`     | memory.html             | r16 card with 14px/600 title + 11px/400 sub                     |

**KaiIconName enum (33 entries as of C3):**
arrowUp, mic, plus, chevRight, person, settings, send, close, search, menu, retry, alert, check,
info, heart, copy, wifiOff, clock, folder, chev, memory, press, palette, motion, speaker, globe,
trash, shield, lock, logout, thumbUp, thumbDown, stop.

---

## 8. TOKENS BARREL CHEAT-SHEET

```dart
// All tokens
import 'package:kai_app/design_system/tokens/kai_tokens.dart';
// Provides: KaiColors, KaiSpace, KaiRadius, KaiType, KaiTide,
//           KaiMotion, KaiShadow, KaiTokens, KaiColorTokens

// Runtime colors (always use, never hardcode)
final c = KaiTheme.of(context).colors;
c.surface2       // surface-2 bg
c.ink1           // primary text
c.accent         // links, toggles, active state
c.negative       // coral (#C44A3C light / #E66F60 dark)

// Type styles
Text('Label', style: KaiType.small(color: c.ink1))
// Off-scale (adjust via copyWith):
Text('KAI', style: KaiType.mono(color: c.ink3).copyWith(fontSize: 9, letterSpacing: 9 * 0.08))
Text('plan', style: KaiType.small(color: c.ink1).copyWith(fontSize: 13.5, fontWeight: FontWeight.w600))

// Atoms
import 'package:kai_app/design_system/atoms/atoms.dart';
// Molecules
import 'package:kai_app/design_system/molecules/molecules.dart';
// Organisms
import 'package:kai_app/design_system/organisms/organisms.dart';
// Primitives
import 'package:kai_app/design_system/primitives/primitives.dart';
```

---

*Generated 2026-05-30. Playwright-verified computed styles from 18 new-design/ HTML files:
room (D2 for bubbles), components, nav, settings, edge-states, notifications-chat,
onboarding, voice, trip-detail, memory, fork, foundations, handoff, dark, brand,
landing, tide-states. Test suite: 838 tests.*
