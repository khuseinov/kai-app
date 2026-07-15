# Kai App — Design System Fidelity Review

**Date**: 2026-05-27  
**From**: Phase 6 controller (rebuild v3 complete)  
**To**: New coordinator — design review session  
**Task**: Проверить соответствие Flutter-реализации дизайн-макетам

---

## 1 · Твоя задача

Ты координатор дизайн-ревью. Твоя цель — сравнить **HTML/CSS макеты** (`E:/startup/kai-app/new-design/`) с **Flutter-реализацией** (`E:/startup/kai-app/.claude/worktrees/hungry-lamport-e41998/lib/design_system/`) и выявить расхождения.

Это НЕ продолжение rebuild. Ты НЕ пишешь код. Ты оцениваешь дизайн-фиделити и составляешь список отклонений с приоритетами.

---

## 2 · Пути к файлам

### Дизайн-макеты (source of truth)
```
E:/startup/kai-app/new-design/
├── CLAUDE.md                  ← жёсткие правила дизайн-системы (ЧИТАТЬ ПЕРВЫМ)
├── colors_and_type.css        ← все токены (цвет, типографика, spacing, radius, motion)
├── design-tokens.json         ← токены в JSON для Flutter codegen
├── foundations.html           ← визуальный манифест. Палитра, типографика, motion
├── components.html            ← Layer 1 (atoms) + Layer 2 (molecules)
├── room.html                  ← chat surface — 6 фреймов (empty/live/panel/compose/streaming/error)
├── edge-states.html           ← offline · error · rate-limit · crisis
├── onboarding.html            ← first-run, 4 шага
├── tide-states.html           ← 8 состояний tide curve с CSS анимациями (SOURCE OF TRUTH)
├── nav.html                   ← side panel
├── handoff.html               ← Flutter widget specs (KaiTheme, KaiTokens, KaiTideCurve, etc.)
└── dark.html                  ← dark mode pass
```

### Flutter-реализация
```
E:/startup/kai-app/.claude/worktrees/hungry-lamport-e41998/lib/
├── design_system/
│   ├── tokens/
│   │   ├── kai_colors.dart        ← цветовые токены (light + dark)
│   │   ├── kai_type.dart          ← типографика
│   │   ├── kai_space.dart         ← spacing scale
│   │   ├── kai_radius.dart        ← border radius
│   │   ├── kai_motion.dart        ← easing + duration tokens
│   │   ├── kai_tide.dart          ← 8 tide states + gradient
│   │   └── kai_tokens.dart        ← агрегатный класс
│   ├── theme/
│   │   ├── kai_theme.dart         ← InheritedWidget с KaiTokens
│   │   └── kai_theme_ext.dart     ← MaterialTheme bridge (material light/dark)
│   ├── atoms/
│   │   ├── kai_bubble.dart        ← user + kai chat bubble
│   │   ├── kai_button.dart        ← primary/ghost/icon/tide buttons
│   │   ├── kai_button_send.dart   ← send button (4 states)
│   │   ├── kai_icon.dart          ← icon atom (KaiIconName enum)
│   │   ├── kai_input.dart         ← text input field
│   │   ├── kai_text.dart          ← typed text (h1-h3, body, small, micro, mono)
│   │   └── kai_tide_curve.dart    ← tide curve widget (8 animated states)
│   ├── molecules/
│   │   ├── alert_card.dart        ← 4-type alert card
│   │   ├── care_block.dart        ← crisis pattern (C3)
│   │   ├── compose_island.dart    ← pill input + mic + send
│   │   ├── nav_item.dart          ← nav panel list item
│   │   └── source_card.dart       ← Kai response receipt
│   └── organisms/
│       ├── chat_list.dart         ← 6-frame chat surface (RoomFrame enum)
│       ├── edge_state_block.dart  ← 4 edge surfaces (EdgeSurface enum)
│       ├── nav_panel.dart         ← side navigation panel
│       └── onboarding_card.dart   ← 4-step onboarding wizard
├── features/
│   ├── room/room_screen.dart      ← главный экран чата
│   ├── onboarding/onboarding_screen.dart
│   └── nav/nav_screen.dart
└── l10n/                          ← AppLocalizations (ru + en)
```

### Showcase (визуальный browser компонентов)
```
E:/startup/kai-app/.claude/worktrees/hungry-lamport-e41998/lib/features/dev/
├── atoms_showcase_screen.dart
├── molecules_showcase_screen.dart
└── organisms_showcase_screen.dart
```

---

## 3 · Что проверять

### Приоритет 1 — Токены и цвета (CRITICAL)

Сравни `new-design/colors_and_type.css` с Dart-токенами:

| CSS переменная | Dart файл | Проверить |
|---|---|---|
| `--bg`, `--surface`, `--surface-2`, `--surface-3` | `kai_colors.dart` | HEX совпадают light+dark |
| `--ink-1` .. `--ink-4` | `kai_colors.dart` | 4 уровня ink (не 3, не 5) |
| `--accent`, `--accent-wash` | `kai_colors.dart` | accent = `#2BA8C9` |
| `--tide-1` `--tide-2` `--tide-3` | `kai_tide.dart` | `#1B4FB0 → #2BA8C9 → #F4B589` |
| `--negative`, `--negative-wash` | `kai_colors.dart` | coral `#C44A3C` (not red) |
| `--warning`, `--warning-wash` | `kai_colors.dart` | |
| type scale (h1-h3, body, small, micro, mono) | `kai_type.dart` | font-size + weight + line-height |
| spacing scale (s1-s10) | `kai_space.dart` | matches CSS `--s1`..`--s10` |
| radius (r1-r4, pill) | `kai_radius.dart` | `--r1=6, --r2=12, --r3=16, --r4=24, pill=999` |

### Приоритет 2 — Tide Curve (CRITICAL)

Сравни `new-design/tide-states.html` с `lib/design_system/atoms/kai_tide_curve.dart` и `kai_tide.dart`:

8 состояний из канона — проверь каждое:
- `idle`: breathe animation (HTML canon — JSON has null, HTML wins), strokePx=1.5, opacity=0.4
- `listening`: bob 2200ms, strokePx=2, opacity=0.8
- `thinking`: flow R→L 3000ms, dash [6,4], opacity=0.85
- `responding`: stream R→L 1400ms, dash [12,4], opacity=1.0
- `success`: flash 1200ms ephemeral, opacity=1.0
- `error`: wobble 600ms ephemeral, opacity=0.95
- `memory`: pop 900ms ephemeral, opacity=1.0
- `sleep`: breathe 7000ms, strokePx=1.0, opacity=0.2

Проверь что `KaiTideCurve` рендерит правильный path (синусоидальную кривую), а не просто линию.

### Приоритет 3 — Atoms vs `components.html`

Открой `new-design/components.html` и проверь Layer 1 (atoms):

| Компонент в HTML | Dart файл | Ключевые правила |
|---|---|---|
| KaiButton.tide | `kai_button.dart` | tide gradient fill, white text, soft shadow `0 2px 8px rgba(43,168,201,0.18)` |
| KaiButton.ghost | `kai_button.dart` | ink-1 text, no fill, 1px border --line |
| KaiButton.icon | `kai_button.dart` | pill radius, no overflow corner |
| KaiButton.send (disabled) | `kai_button_send.dart` | ink-4 fill, opacity 0.5 |
| KaiButton.send (ready) | `kai_button_send.dart` | tide gradient, white icon |
| KaiButton.send (streaming) | `kai_button_send.dart` | tide gradient + scale-pulse |
| KaiBubble.user | `kai_bubble.dart` | tide gradient bg, white text, pill right-align |
| KaiBubble.kai | `kai_bubble.dart` | surface-2 bg, ink-1 text, left-align |
| KaiText.h1..h3, body, small, micro | `kai_text.dart` | Manrope variable font |
| KaiText.mono | `kai_text.dart` | JetBrains Mono |

### Приоритет 4 — Molecules vs `components.html`

| Компонент | HTML ref | Ключевые правила |
|---|---|---|
| ComposeIsland | `room.html § compose-sheet`, `components.html` | Pill container, mic hug LEFT, send hug RIGHT, no overflow, surface=`#FFFFFF` (pure white, not --bg) |
| AlertCard | `notifications-chat.html` | 4 типа (urgent/warning/positive/neutral), N-01 anatomy |
| CareBlock | `edge-states.html § 04 Crisis · C3` | coral `#C44A3C` left-border, никогда не takeover, compose остаётся видимым |
| SourceCard | `components.html` | source receipt под ответом Kai |
| NavItem | `nav.html` | trip item в панели |

### Приоритет 5 — Organisms vs screens

| Организм | HTML ref | Ключевые правила |
|---|---|---|
| ChatList (6 frames) | `room.html` | empty / live / panel / compose / streaming / error — все 6 визуально совпадают |
| EdgeStateBlock (4 surfaces) | `edge-states.html` | offline / error / rateLimit / crisis |
| NavPanel | `nav.html` | side panel, полноэкранный slide, не pinned |
| OnboardingCard (4 steps) | `onboarding.html` | welcome / tide / gestures / context |

### Приоритет 6 — Layout rules (Zero-UI)

Проверь по `new-design/CLAUDE.md § 3 Hard rules`:
- [ ] Нет persistent chrome (нет bottom tabs, нет top nav bar)
- [ ] Только одна KaiButton.tide на экран
- [ ] Compose-island hug-edge buttons не вылезают за скругление
- [ ] Тёмный режим — parity remap, не отдельный дизайн
- [ ] `--bg: #FAFAF9`, pure `#FFFFFF` только для elevated content (compose island)
- [ ] Error = coral `#C44A3C`, никогда `#DC2626`

---

## 4 · Методология

### Шаг 1 — Spawn parallel agents

Dispatch 3 агентов параллельно:
1. **Token reviewer**: сравнивает `colors_and_type.css` + `design-tokens.json` с Dart-токенами
2. **Component reviewer**: сравнивает `components.html` + `handoff.html` с atoms + molecules
3. **Screen reviewer**: сравнивает `room.html` + `edge-states.html` + `onboarding.html` с organisms + screens

### Шаг 2 — Aggregate findings

Собери расхождения в таблицу:

```
| Component | Issue | Severity | HTML says | Flutter has |
|---|---|---|---|---|
| ... | ... | CRITICAL/HIGH/MEDIUM/LOW | ... | ... |
```

Severities:
- **CRITICAL**: неправильный цвет, неправильный токен, сломанная анимация
- **HIGH**: неправильный размер, отсутствующий shadow, неправильный border-radius
- **MEDIUM**: minor spacing, неточный opacity
- **LOW**: cosmetic, tech debt acceptable for v1

### Шаг 3 — Deliver report

Отдай user-readable отчёт с:
1. Summary (сколько issue по каждой severity)
2. Полный список по компонентам
3. Рекомендации что чинить сейчас vs v2

---

## 5 · Технический контекст (для агентов)

### Ветка и worktree
- **Worktree**: `E:\startup\kai-app\.claude\worktrees\hungry-lamport-e41998`
- **Branch**: `claude/hungry-lamport-e41998`
- **HEAD**: `95607b2`
- **State**: 197/197 tests passing, analyze clean, Phase 6 complete

### Что УЖЕ известно как tech debt (не считать за новые issue)
Из handoff-документа — принятые отклонения для v1:
1. `AlertCard` упрощённый (1 Column, не 4-zone как N-01 canonical) — acceptable v1
2. `AlertCard` всегда использует `KaiIconName.alert` — per-type иконки deferred
3. Idle/sleep `strokePx`/`opacity` в `kai_tide.dart` — overridden by breathe animation (dead fields)
4. Messages typed как `List<Map<String,dynamic>>` — переход на `List<Message>` deferred

### Showcase для визуальной проверки
Есть dev screens с showcase всех компонентов:
- Route `/_dev/atoms` → все атомы
- Route `/_dev/molecules` → все молекулы
- Route `/_dev/organisms` → все организмы
- Route `/_dev/theme` → light/dark theme switcher

Агент может читать showcase-файлы чтобы понять как компоненты используются.

### Дизайн-токены: источник истины
- `new-design/colors_and_type.css` — CSS канон
- `new-design/design-tokens.json` — JSON для Flutter
- `new-design/tide-states.html` — tide канон (HTML wins над JSON для idle/sleep breathe)
- `new-design/handoff.html` — Flutter widget specs

### Важные правила (non-negotiable, из `new-design/CLAUDE.md`)
1. Tide gradient строго `#1B4FB0 → #2BA8C9 → #F4B589`, angle 115°
2. `--bg: #FAFAF9`, pure `#FFFFFF` только для elevated
3. Error = `#C44A3C` (coral), НИКОГДА `#DC2626`
4. Manrope (variable 300–800) для всего текста
5. JetBrains Mono для mono labels
6. Zero-UI: нет persistent chrome
7. Один KaiButton.tide на экран

---

## 6 · Immediate next steps

1. Прочитай `new-design/CLAUDE.md` полностью
2. Прочитай `new-design/colors_and_type.css` (токены)
3. Прочитай `new-design/handoff.html` (Flutter widget specs)
4. Dispatch 3 review агентов параллельно (см. §4)
5. Aggregate → отчёт пользователю

Агенты должны читать HTML-файлы через абсолютные пути: `E:/startup/kai-app/new-design/*.html`.
Flutter-файлы читать через: `E:/startup/kai-app/.claude/worktrees/hungry-lamport-e41998/lib/design_system/`.

**Не трогай код, не создавай новых веток, не коммить.** Это read-only ревью.
