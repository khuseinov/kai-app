# Kai Design System — Component Reference

> Agent index: Read this to find the right widget for any UI element.
> Live Storybook: `/_dev/storybook` in the running app.
> Canon HTML server: `cd new-design && python -m http.server 8743`
> Spec-viewer: `http://localhost:8743/spec-viewer.html`
> Design rules (non-negotiable): `new-design/CLAUDE.md`

---

## Quick token reference

| Token class | File | Key constants |
|-------------|------|---------------|
| `KaiSpace` | `tokens/kai_space.dart` | s1=4 s2=8 s3=12 s4=16 s5=20 s6=24 s7=32 s8=40 s9=56 |
| `KaiRadius` | `tokens/kai_radius.dart` | r1=6 r2=10 r3=14 r4=20 r5=28 r8=8 r12=12 r24=24 pill=999 |
| `KaiType` | `tokens/kai_type.dart` | hero/display/h1/h2/h3/lead/body/small/micro/mono — all take `color:` |
| `KaiTide` | `tokens/kai_tide.dart` | gradient (115°) · gradientCorner (135°) · stop1=#1B4FB0 · stop2=#2BA8C9 · stop3=#F4B589 |
| `KaiShadow` | `tokens/kai_shadow.dart` | button · glow · thumb |
| `KaiMotion` | `tokens/kai_motion.dart` | fast/standard/slow durations + curves |
| `KaiColors` | `tokens/kai_colors.dart` | KaiColors.light / KaiColors.dark → `KaiColorTokens` |
| `KaiTokens` | `tokens/kai_tokens.dart` | KaiTokens.light / .dark — composite accessor |

### Color token quick reference (light palette)

| Token | Hex | Use |
|-------|-----|-----|
| `c.bg` | #FAFAF9 | Screen background |
| `c.surface` | #FFFFFF | Card / sheet base |
| `c.surface2` | #F3F3F1 | Input bg, bubble bg, fact cards |
| `c.surface3` | #ECECE A | Budget bar track, toggle off |
| `c.ink1` | #111114 | Primary text |
| `c.ink2` | #43434A | Secondary text |
| `c.ink3` | #76767E | Placeholder, meta, timestamps |
| `c.ink4` | #A8A8AE | Disabled text |
| `c.line` | #E8E8E5 | Hairline dividers, borders |
| `c.accent` | #2C5BE5 | Primary interactive (blue) |
| `c.accentWash` | #EEF2FD | Active state bg, chat-item bg |
| `c.positive` | #1B8E4E | Success, visa-free indicator |
| `c.warning` | #B57A0B | Caution states |
| `c.negative` | #C44A3C | Error / coral — never alarming red |

> Dark palette differs: accent=#5C8EFF, positive=#3DBE7A, negative=#E66F60, etc.
> Always access via `KaiTheme.of(context).colors` for theme-aware code.
> Use `KaiTokens.dark.colors` only for always-dark surfaces (toasts, voice screen).

### Tide gradient constants

```dart
KaiTide.gradient        // 115° — screen curves, hero text, buttons, wide surfaces
KaiTide.gradientCorner  // 135° — SQUARE brand surfaces only (avatar, icon, splash)
KaiTide.stop1           // Color(0xFF1B4FB0) — deep ocean blue
KaiTide.stop2           // Color(0xFF2BA8C9) — sea-glass cyan  ← tide-2
KaiTide.stop3           // Color(0xFFF4B589) — warm horizon     ← tide-3
```

---

## Canon → Component lookup table

| HTML file | CSS selector | Dart widget | Import | Notes |
|-----------|-------------|-------------|--------|-------|
| `room.html` | `.bub.user` | `KaiUserBubble` | molecules | D2: 13.5px body, asymm radii |
| `room.html` | `.bub.kai` | `KaiKaiBubble` | molecules | D2: 13.5px body, 9px who-label |
| `room.html` | `.bub.kai.streaming` | `KaiKaiBubble(streaming:true)` | molecules | caret indicator |
| `room.html` | `.bub.system` | `KaiSystemBubble` | molecules | 3 tones: neutral/warning/negative |
| `components.html` | `.sheet.compose-sheet .compose` | `KaiComposeIsland` | molecules | pill r999, send+mic buttons |
| `components.html` | `.sheet` | `KaiSheetShell` | atoms | r24/24/0/0 top corners |
| `components.html` | `.sheet.actions` | `showKaiActionSheet()` | molecules | imperative show fn |
| `components.html` | `.sheet.detail` | `showKaiMessageDetailSheet()` | molecules | sources + actions |
| `components.html` | `.toast` | `KaiToast` | molecules | pill, dark-island, 4 types |
| `components.html` | `.toast .open` | `KaiToast(actionLabel:,onAction:)` | molecules | color = KaiTide.stop2 |
| `components.html` | `.src-row` | `KaiSourceCard` | molecules | url+title+snippet+index chip |
| `nav.html` | `.drawer` | `KaiNavPanel` | organisms | full-screen side panel |
| `nav.html` | `.drawer .ses` | `KaiNavItem` | molecules | active: accent-wash + border |
| `nav.html` | `.mem-dot` | `KaiBadge.dot()` | atoms | memory indicator |
| `edge-states.html` | `.care-block` | `KaiCareBlock` | molecules | crisis C3 pattern |
| `edge-states.html` | `.edge-state` | `KaiEdgeStateBlock` | organisms | offline/error/rateLimit/crisis |
| `notifications-chat.html` | `.alert-card` | `KaiAlertCard` | molecules | 4 severity types |
| `onboarding.html` | `.ob` | `KaiOnboardingCard` | organisms | 4-step, steps 0-3 |
| `room.html` | `.chat` | `KaiChatList` | organisms | 6 RoomFrame variants |
| `foundations.html` | `.icon-grid svg` | `KaiIcon` | primitives | tinted SVG from assets/icons/ |
| `foundations.html` | `.surface-demo` | `KaiSurface` | primitives | token-driven BoxDecoration |
| `components.html` | `.k-who::before` | `KaiGradientBar` | primitives | tide-gradient pill, pulse opt |
| `tide-states.html` | `.tide-curve` | `KaiTideCurve` | atoms | 8 states, animated |
| `foundations.html` | `.type-scale` | `KaiText.*` | atoms | 10 named constructors |
| `components.html` | `.btn-grid .btn` | `KaiButton.tide/ink/ghost/text` | atoms | 4 variants |
| `components.html` | `.icon-btn` | `KaiIconButton.surface/transparent/bare` | atoms | 3 variants |
| `components.html` | `.compose .send` | `KaiSendButton` | atoms | 4-state lifecycle |
| `components.html` | `.compose textarea` | `KaiInput.line/pill` | atoms | 2 variants |
| `settings.html` | `.toggle` | `KaiToggle` | atoms | 34×20 pill switch |
| `components.html` | `.chip` | `KaiChip.status/choice` | atoms | status+choice, 3 tones |
| `nav.html` | `.mem-dot` | `KaiBadge.dot/count` | atoms | dot + numeric |
| `settings.html` | `.acc-hero .avatar` | `KaiAvatar` | atoms | tide-corner gradient circle |
| `foundations.html` | `hr, .divider` | `KaiDivider` | atoms | horizontal + vertical |
| `settings.html` | `.seg` | `KaiSegmentedControl` | molecules | index-based pill control |
| `settings.html` | `.row` | `KaiSettingsRow` | molecules | icon+title+subtitle+trailing |
| `settings.html` | `.group` | `KaiSettingsGroup` | molecules | labeled section wrapper |
| `settings.html` | `.acc-hero` | `KaiAccountHero` | molecules | avatar+name+email+plan |

---

## Components by layer

### Primitives
`import 'package:kai_app/design_system/primitives/primitives.dart';`

#### `KaiIcon`
```dart
KaiIcon(KaiIconName.send, size: 24, color: c.ink2)
```
- SVG icon rendered via `ColorFiltered` on `assets/icons/<name>.svg`
- `KaiIconName` enum covers all system icons (see `kai_icon.dart`)
- `size`: logical pixels (both width & height)
- `color`: defaults to `c.ink1` if null

#### `KaiSurface`
```dart
KaiSurface(
  color: c.surface2,
  radius: KaiRadius.br3,
  border: true,           // adds c.line border
  shadow: KaiShadow.button,
  padding: EdgeInsets.all(KaiSpace.s4),
  child: ...,
)
```
- Token-driven `BoxDecoration` wrapper
- `border: true` adds 0.8px `c.line` border
- `shadow` accepts `List<BoxShadow>` from `KaiShadow.*`

#### `KaiGradientBar`
```dart
KaiGradientBar()                          // 16×4 static (Kai who-glyph)
KaiGradientBar(pulse: true)               // animated pulse
KaiGradientBar(width: 10, height: 2.5)   // toast tide-bar size
```
- Always uses `KaiTide.gradient` (locked)
- Used as Kai "who" glyph (16×4) and toast tide marker (10×2.5)

---

### Atoms
`import 'package:kai_app/design_system/atoms/atoms.dart';`

#### `KaiText`
```dart
KaiText.hero('72px heading')
KaiText.display('56px')
KaiText.h1('36px', gradient: true)   // ShaderMask tide gradient
KaiText.h2('24px')
KaiText.h3('18px')
KaiText.lead('20px paragraph')
KaiText.body('16px')
KaiText.small('14px', color: c.ink2)
KaiText.micro('12px', color: c.ink3)  // caller uppercases if needed
KaiText.mono('12px monospace')        // JetBrains Mono
```
- All constructors accept optional `color:` (defaults to nearest ink token)
- `gradient: true` on h1/h2/display/hero applies `KaiTide.gradient` via `ShaderMask`
- Manrope font features: ss03 + cv11 (friendly 'a')

#### `KaiButton`
```dart
KaiButton.tide(onPressed: () {}, label: 'Start')     // primary CTA — tide gradient
KaiButton.tide(onPressed: () {}, label: 'Glow', emphasis: KaiButtonEmphasis.glow)
KaiButton.ink(onPressed: () {}, label: 'Action')     // solid dark
KaiButton.ghost(onPressed: () {}, label: 'Cancel')   // outline
KaiButton.ghost(onPressed: () {}, label: 'Warn', tone: KaiButtonTone.warning)
KaiButton.ghost(onPressed: () {}, label: 'Pill', pill: true)
KaiButton.text(onPressed: () {}, label: 'Link')
KaiButton.text(onPressed: () {}, label: 'Accent', tone: KaiButtonTone.accent)
```
- `fullWidth: true` makes button fill container width
- `null` `onPressed` = disabled state
- One `tide` button per screen maximum (Zero-UI rule)

#### `KaiIconButton`
```dart
KaiIconButton.surface(onPressed: () {}, icon: KaiIconName.attach)
KaiIconButton.transparent(onPressed: () {}, icon: KaiIconName.mic)
KaiIconButton.bare(onPressed: () {}, icon: KaiIconName.close)
```
- `surface`: bg `c.surface2`, circle
- `transparent`: no bg, circle hit area
- `bare`: no bg, minimal padding

#### `KaiSendButton`
```dart
KaiSendButton(state: KaiSendState.ready, onPressed: () {})
```
- States: `ready` · `disabled` · `sending` · `streaming`
- Tide gradient fill; primary CTA in compose island
- `null` onPressed disables tap but widget still renders

#### `KaiInput`
```dart
KaiInput.line(controller: ctrl, placeholder: 'Search…')
KaiInput.pill(controller: ctrl, placeholder: 'Message…', maxLines: 4)
KaiInput.line(controller: ctrl, enabled: false)
```
- `line`: bg `c.surface2`, r10, border `c.line` — for search bars
- `pill`: bg `c.surface2`, r999, border `c.line` — for compose textarea
- Canon: 13.5px Manrope 400, lh 1.4

#### `KaiToggle`
```dart
KaiToggle(value: isOn, onChanged: (v) => setState(() => isOn = v))
KaiToggle(value: true, onChanged: null)  // disabled
```
- 34×20 track, r999, `c.positive` when on / `c.surface3` when off
- White knob with `KaiShadow.thumb`

#### `KaiChip`
```dart
KaiChip.status('done', tone: KaiChipTone.done)
KaiChip.status('active', tone: KaiChipTone.active)
KaiChip.status('neutral')
KaiChip.choice('Selected', selected: true, onTap: () {})
KaiChip.choice('Unselected', selected: false, onTap: () {})
```
- Status: non-interactive, uppercase monospace label, semantic tints
- Choice: selectable filter pills

#### `KaiBadge`
```dart
KaiBadge.dot()       // 8px dot — memory indicator in nav
KaiBadge.count(5)    // numeric, caps at 99+
```

#### `KaiAvatar`
```dart
KaiAvatar()                           // 40px default, tide-corner gradient
KaiAvatar(initial: 'R', size: 40)    // letter centered
KaiAvatar(size: 56, initial: 'K')    // large
```
- Always uses `KaiTide.gradientCorner` (square surface gradient)
- Letter: 13px w700 white

#### `KaiTideCurve`
```dart
KaiTideCurve(state: KaiTide.idle)
KaiTideCurve(state: KaiTide.listening)
KaiTideCurve(state: KaiTide.thinking)
KaiTideCurve(state: KaiTide.responding)
KaiTideCurve(state: KaiTide.success)   // ephemeral 1200ms
KaiTideCurve(state: KaiTide.error)     // ephemeral 600ms
KaiTideCurve(state: KaiTide.memory)    // ephemeral 900ms
KaiTideCurve(state: KaiTide.sleep)
KaiTideCurve(state: KaiTide.muted)     // static gradient, for onboarding
```
- Animated SVG-like curve painted with CustomPainter
- Place in a `SizedBox(height: 28)` at screen top
- States listed in `KaiTide.all`

#### `KaiDivider`
```dart
KaiDivider()                  // horizontal, full width, 1px c.line
KaiDivider(color: c.line)     // explicit color
KaiDivider.vertical()         // fills available height
```

#### `KaiSheetShell`
```dart
KaiSheetShell(child: ...)
```
- r24/24/0/0 top corners, drag handle, border-top `c.line`
- Wraps bottom-sheet content — does NOT manage `showModalBottomSheet`

---

### Molecules
`import 'package:kai_app/design_system/molecules/molecules.dart';`

#### `KaiUserBubble`
```dart
KaiUserBubble(text: 'Привет, Kai!')
```
- Right-aligned bubble, bg `c.surface2` (#F3F3F1)
- Padding: 11/15 (top-bottom/left-right)
- Border radius: 18/18/4/18 (tl/tr/br/bl) — sharp bottom-right corner
- Canon (D2 locked): 13.5px Manrope 400, lh 22.5px, ls -0.005em
- Source of truth: `room.html` not `components.html`

#### `KaiKaiBubble`
```dart
KaiKaiBubble(
  text: 'Ответ с [1] ссылкой',
  sourcesLabel: '1 источник · только что',
  sources: [KaiSourceCard(url: 'mofa.go.jp', ...)],
  onThumbUp: () {},
  onThumbDown: () {},
)
KaiKaiBubble(text: 'Печатает…', streaming: true)
```
- No background, no border — column layout
- Who-glyph: `KaiGradientBar(16×4)` + "WHO" label: 9px JetBrains Mono, `c.ink3`
- Canon (D2 locked): body 13.5px Manrope 400, lh 23.25px (≈1.55), ls -0.005em
- Citation `[n]` inline → accent color, w500
- `streaming: true` shows animated caret instead of reaction buttons
- Source of truth: `room.html` not `components.html`

#### `KaiSystemBubble`
```dart
KaiSystemBubble('Kai обновил воспоминание.', tone: KaiSystemTone.neutral)
KaiSystemBubble('Внимание!', bold: 'Внимание!', tone: KaiSystemTone.warning)
KaiSystemBubble('Ошибка сети', tone: KaiSystemTone.negative)
```
- Full-width, r12, pad 11/14
- `neutral`: bg `c.surface2`, text `c.ink2`
- `warning`: bg `c.warningWash`, text `c.warning`
- `negative`: bg `c.negativeWash`, text `c.negative`
- Canon: 13.5px Manrope 400

#### `KaiComposeIsland`
```dart
KaiComposeIsland(
  controller: textCtrl,
  onSend: () {},
  onMicTap: () {},
  sendState: KaiSendState.ready,
)
```
- Pill r999, bg `c.surface2`, border 0.8px `c.line`
- Pad: 5/5/5/14 (top/right/bottom/left)
- Textarea: 13.5px Manrope 400, lh 1.4
- Send button: `KaiSendButton` circle, right side
- Mic button: `KaiIconButton.transparent`

#### `KaiSourceCard`
```dart
KaiSourceCard(
  url: 'mofa.go.jp',
  title: 'Ministry of Foreign Affairs',
  snippet: 'Visa requirements…',
  index: 1,
  fresh: true,
)
```
- `.src-row`: 12.5px Manrope ink2, lh 19.375px
- Index chip: 10px JetBrains Mono, r4, pad 2/6, bg `c.surface`, border `c.line`
- URL: 12.5px w500, ink1
- `fresh: true` shows freshness indicator

#### `KaiCareBlock`
```dart
KaiCareBlock(
  heading: 'Я здесь для тебя.',
  body: 'Если тяжело — ты не один.',
  resources: [KaiCareResource(label: 'Телефон', number: '8-800-...')],
  closing: 'Просто дыши.',
)
```
- C3 in-conversation crisis pattern
- Coral (`c.negative`) left border, never a full-screen takeover

#### `KaiAlertCard`
```dart
KaiAlertCard(
  type: KaiAlertType.urgent,   // urgent/warning/positive/neutral
  title: 'Виза истекает',
  body: 'Через 3 дня.',
  time: '9:41',
  cta: 'Продлить',
  onCtaTap: () {},
)
```
- Two-zone layout: colored header + white body
- Injected into chat feed as a message item

#### `KaiToast`
```dart
KaiToast(type: KaiToastType.neutral,  label: 'Скопировано')
KaiToast(type: KaiToastType.positive, label: 'Сохранено', showCountdown: true)
KaiToast(type: KaiToastType.negative, label: 'Ошибка', actionLabel: 'Повторить', onAction: () {})
KaiToast(type: KaiToastType.memory,   label: 'Kai запомнил', actionLabel: 'Открыть', onAction: () {})
```
- Dark-island pill — always on `c.ink1` bg regardless of theme
- Padding: 7/14/7/9; r999; shadow 0 2px 12px rgba(0,0,0,0.16)
- Label: 11px Manrope w500, dark ink1 (#F5F5F2)
- Action button: 12px Manrope w600, color = `KaiTide.stop2` (#2BA8C9) — **tide-2, NOT accent**
- `memory` variant: tide gradient bg, white text, `KaiGradientBar(10×2.5)` marker
- `showCountdown: true`: 110×2px bar below pill (static, animation driven by controller)

#### `KaiActionSheet` / `showKaiActionSheet()`
```dart
showKaiActionSheet(context, items: [
  KaiActionItem(icon: KaiIconName.copy, title: 'Скопировать', meta: '⌘C', onTap: () {}),
  KaiActionItem(icon: KaiIconName.trash, title: 'Удалить', danger: true, onTap: () {}),
]);
```
- Bottom sheet, r10 action rows, pad 10/8
- `danger: true` renders title in `c.negative`

#### `showKaiMessageDetailSheet()`
```dart
showKaiMessageDetailSheet(context,
  sources: [KaiDetailSource(number: 1, url: 'mofa.go.jp', freshness: KaiSourceFreshness.fresh)],
  actions: [
    KaiDetailAction(icon: KaiIconName.copy, label: 'Скопировать', onTap: () {}),
    KaiDetailAction(icon: KaiIconName.heart, label: 'Сохранить', style: KaiDetailActionStyle.primary, onTap: () {}),
    KaiDetailAction(icon: KaiIconName.trash, label: 'Удалить', style: KaiDetailActionStyle.danger, onTap: () {}),
  ],
);
```
- Detail action sheet: sources list + action grid
- Action rows: 12.5px w500, r8, pad 10/8

#### `KaiSegmentedControl`
```dart
KaiSegmentedControl(
  options: const ['Авто', 'Светлая', 'Тёмная'],
  selectedIndex: _index,
  onSelected: (i) => setState(() => _index = i),
)
```

#### `KaiSettingsRow` / `KaiSettingsGroup`
```dart
KaiSettingsGroup(
  label: 'внешний вид',
  children: [
    KaiSettingsRow(
      icon: KaiIconName.palette,
      title: 'Тема',
      subtitle: 'системная',
      trailing: KaiToggle(value: on, onChanged: ...),
      onTap: () {},
    ),
    KaiSettingsRow(icon: KaiIconName.trash, title: 'Удалить', danger: true, onTap: () {}),
  ],
)
// Danger group:
KaiSettingsGroup(danger: true, children: [...])
```
- `KaiSettingsGroup`: r12 container, section label
- `KaiSettingsRow`: icon+title+subtitle+trailing; `danger: true` → negative color

#### `KaiAccountHero`
```dart
KaiAccountHero(name: 'Rustam K.', email: 'rustam@example.com', initial: 'R')
KaiAccountHero(name: 'Rustam K.', email: 'rustam@example.com', initial: 'R', planLabel: 'Pro')
```

#### `KaiNavItem`
```dart
KaiNavItem(label: 'Поездка', icon: KaiIconName.folder, onTap: () {})
KaiNavItem(label: 'Активный', icon: KaiIconName.memory, active: true, onTap: () {})
KaiNavItem(label: 'Память', icon: KaiIconName.memory, trailing: KaiBadge.dot())
```
- Active: bg `c.accentWash`, left 2px accent border
- Title: 14px ink1 / active → 600 accent

---

### Organisms
`import 'package:kai_app/design_system/organisms/organisms.dart';`

#### `KaiChatList`
```dart
KaiChatList(
  frame: RoomFrame.live,    // empty/live/panel/compose/streaming/error
  messages: msgs,           // List<Map<String,dynamic>> — role+content
  partialContent: 'Ищу…',  // for streaming frame
  onRetry: () {},
)
```
- `RoomFrame.empty`: empty state with tide curve
- `RoomFrame.live`: normal chat
- `RoomFrame.panel`: nav panel open, chat dimmed
- `RoomFrame.compose`: compose sheet visible
- `RoomFrame.streaming`: partial Kai message with `partialContent`
- `RoomFrame.error`: error edge state

Message map shape:
```dart
{'role': 'user', 'content': '...'}
{'role': 'kai', 'content': '...', 'sourcesLabel': '...', 'sources': [...]}
{'role': 'system', 'content': '...', 'tone': 'warning'}
{'role': 'alert', 'alertType': 'warning', 'content': '...', 'body': '...', 'time': '...'}
```

#### `KaiNavPanel`
```dart
KaiNavPanel(
  strings: KaiNavStrings.russian,
  onClose: () {},
  onNewChat: () {},
  trips: trips,                 // List<TripInfo>
  sessions: sessions,           // List<SessionPreview>
  activeSessionId: 'session-1',
  onSessionTap: (id) {},
  onTripTap: (id) {},
  accountInitial: 'R',
  accountName: 'Rustam K.',
  accountPlan: 'Pro',
  hasUnseenMemory: true,
  onMemoryTap: () {},
  onSettingsTap: () {},
  pinnedTrip: trips.first,
)
```
- Full-screen overlay drawn over room screen
- Session title: 14px ink1 → active 600 accent
- Session subtitle: 11px JetBrains Mono, ink3
- Section labels: 10px JetBrains Mono, ink3, ls 0.8px, pad 12/16/6
- New chat button: 13.5px w600, r12, pad 11px, bg ink1

#### `KaiEdgeStateBlock`
```dart
KaiEdgeStateBlock(surface: KaiEdgeSurface.offline, onRetry: () {})
KaiEdgeStateBlock(surface: KaiEdgeSurface.error, onRetry: () {})
KaiEdgeStateBlock(surface: KaiEdgeSurface.rateLimit, onPlans: () {}, countdown: Duration(seconds: 42))
KaiEdgeStateBlock(surface: KaiEdgeSurface.crisis)
```
- 4 surfaces with distinct CTA styles
- `crisis`: no CTA button, shows `KaiCareBlock`

#### `KaiOnboardingCard`
```dart
KaiOnboardingCard(
  stepIndex: _step,    // 0–3
  onNext: () {},
  onComplete: () {},
)
```
- Step 0: tide CTA button
- Steps 1–3: solid ink-1 button
- Tide curve: `KaiTide.muted` on passive steps

---

## Screens not yet built in Dart (canon exists)

These screens have complete HTML specs in `new-design/` but no Dart implementation yet.
Each has a spec-preview story in the Storybook under Organisms.

### Voice Screen
- **Canon**: `new-design/voice.html`
- **Storybook**: "Voice Screen (canon)" story
- **Key specs** (Playwright-verified):
  - Bg: `Color(0xFF08080A)` — **always dark, NEVER responds to theme**
  - Karaoke NOW word: bg `rgba(244,181,137,0.28)` = `Color(0x47F4B589)`, r4, pad 1/5, 16px w500 white
  - Karaoke NEXT words: `Color(0x52FFFFFF)` (rgba(white,0.32)), same font
  - Karaoke default: 16px w500 white, transparent bg
  - Transcript events: pad 9/22/9/52
  - Timestamp: 8.5px w500, `Color(0x66FFFFFF)` (rgba(white,0.4))
  - Hint labels: 9px Manrope, `Color(0x40FFFFFF)` (rgba(white,0.25))
  - Reuse: `KaiTideCurve`, `KaiButton.ink`, `KaiText`
  - New: `VoiceKaraoke`, `VoiceTranscriptRow`, `VoiceHintLabel`

### Memory Screen
- **Canon**: `new-design/memory.html`
- **Storybook**: "Memory Screen (canon)" story
- **Key specs** (Playwright-verified):
  - Search bar: 12.5px ink3, r10, pad 9/12, bg surface-2 → use `KaiInput.line`
  - Fact groups: bg surface-2, r12, pad 4px
  - Fact items: r8, pad 9/11; body 13px ink1; source 9.5px ink3
  - Forget rows: r8, pad 11/12, `c.negative` color
  - Memory hero: r16, pad 14; title 14px w600; sub 11px ink3
  - Toggle: `KaiToggle` — positive (green = on)
  - App bar: title 13px w600; icon buttons circle bg surface-2
  - Reuse: `KaiInput.line`, `KaiToggle`, `KaiButton.ink(fullWidth:true)`, `KaiAvatar`
  - New: `MemoryFactGroup`, `MemoryFactItem`, `MemoryHero`

### Trip Detail Screen
- **Canon**: `new-design/trip-detail.html`
- **Storybook**: "Trip Detail Screen (canon)" story
- **Key specs** (Playwright-verified):
  - App bar icon buttons: circle, bg surface-2, ~32×32
  - App bar title: 13px w600, ink1
  - Trip hero: r16, pad 16 — contains glyph + name + sub + stats + budget
  - Glyph: tide-corner gradient circle, 13px w700 white, r11 → `KaiAvatar(size:~36)`
  - Trip name: 16px w600, lh 1.2; sub: 11px ink3
  - Stats: `.stat .n` 16px w600; `.stat .l` 9px w500 ink3
  - Budget bar: r999, bg surface-3, colored segments (flights/stays/food/local)
  - Facts grid: `.fact .k` 11px ink3; `.fact .v` 11.5px w500 ink1; card bg surface-2 r12 pad 4
  - Chat items: r10, pad 9/10, bg accent-wash; title 12px w600 accent; preview 10.5px ink3
  - Source items: pad 8/10; url 11px w500 ink2
  - "Ask about this": 13px w600 white, bg ink1, r12, pad 11px = `KaiButton.ink(fullWidth:true)`
  - Q&A chips: bg surface-2, r10, pad 9/6
  - Reuse: `KaiAvatar`, `KaiButton.ink`, `KaiSourceCard`, `KaiInput.line`
  - New: `TripHeroCard`, `TripFactGrid`, `TripBudgetBar`, `TripChatItem`

### Fork Card (in-chat molecule)
- **Canon**: `new-design/fork.html`  `.fc`
- **Storybook**: "KaiForkCard (canon)" story
- **Key specs** (Playwright-verified):
  - In-chat molecule, NOT a full screen
  - CSS classes: `.fc`, `.fc-h`, `.fc-cols`, `.fc-col`, `.fc-id`, `.fc-country`, `.fc-glyph`
  - `.fc-country` header: ~65px wide
  - Visa chips: 8px w600, r999, pad 2/6, negative-wash/neutral bg
  - Rating dots: 5×5px circles, positive/neutral/negative colors
  - `.fc-score`: 5-dot rating row
  - `.fc-badge`: win/recommended badge
  - Two columns side by side: price, delta, budget rows, facts
  - Reuse: `KaiText`, `KaiTide.gradientCorner` (glyph)
  - New: `KaiForkCard`, `ForkColumn`, `ForkVisaChip`, `ForkRatingDots`

---

## Design rules (summary)

1. **Token-only**: no `Color(0xFF...)` or magic padding in `lib/design_system/` or `lib/features/`. Hardcoded values allowed only in `lib/design_system/tokens/`.
2. **Tide gradient locked**: `KaiTide.gradient` (screens/buttons) or `KaiTide.gradientCorner` (square brand surfaces). No other gradients.
3. **Error color**: `c.negative` (#C44A3C light / #E66F60 dark) — coral, never alarming red.
4. **Zero-UI**: no persistent chrome. One primary action per screen (tide gradient).
5. **D2 locked**: bubble body text 13.5px / who-label 9px. Source = `room.html`. Do NOT change to 15px/10px from `components.html`.
6. **Toast action button**: `KaiTide.stop2` (#2BA8C9), not `c.accent`.
7. **Language**: app UI Russian-first (ARB), Claude responds in Russian.
8. **Voice screen**: always `Color(0xFF08080A)` bg, never theme-aware.
