# Bucket C — Compose + Buttons polish

**Date**: 2026-05-27
**Branch**: `claude/hungry-lamport-e41998`
**Severity coverage**: 1 CRITICAL + 3 HIGH + 4 MEDIUM
**Estimated effort**: 2–3 hours
**Dependency**: независим. **Должен быть запущен в первом раунде** (его выходы — новый `KaiButton.iconTransparent` variant — могут быть нужны Bucket A).

---

## 1 · Goal

Привести ComposeIsland (pill compose) и кнопки к pixel-perfect соответствию `room.html § .compose-island` и `components.html`. Главное — mic transparent (не surface-2 chip), button.ghost border = `line` (не ink-3), send size 30 для pill, padding 5×16.

---

## 2 · Files to modify

| Файл | Что меняется |
|---|---|
| `lib/design_system/molecules/compose_island.dart` | Padding 5×16 (не 6×8), button size 30 (не 32), mic = transparent (новая variant) |
| `lib/design_system/atoms/kai_button.dart` | Новая variant `KaiButton.iconTransparent` (transparent + ink-3, без pill background). Фикс ghost border `line` (не ink-3). |
| `lib/design_system/atoms/kai_button_send.dart` | Optional: добавить параметр `iconSize` для customизации (canon = 12-13px для pill compose). |

---

## 3 · HTML canon refs

- `E:/startup/kai-app/new-design/room.html` — line 116-135 (frame 01 compose), 188-197 (frame 02 compose), 380-403 (frames 5+6 compose)
- `E:/startup/kai-app/new-design/components.html` — line 200-219 (compose-sheet variant + buttons)
- `E:/startup/kai-app/new-design/CLAUDE.md § Layout` — hard rules для compose

---

## 4 · Detailed changes

### 4.1 — C4: ComposeIsland mic transparent (CRITICAL)

**HTML canon** (`room.html:132,196,402`):
```css
.f01 .compose-island .mic { background: transparent; color: var(--ink-3); }
.f02 .compose-island .mic { background: transparent; color: var(--ink-3); }
.f06 .compose-island .mic { ... background: transparent; color: var(--ink-3); ... }
```

Mic в pill compose — это **воздушная иконка ink-3**, не отдельная кнопка-капсула.

**Текущая реализация** (`compose_island.dart:161-166`):
```dart
final child = KaiButton.icon(
  onPressed: onTap,
  icon: KaiIconName.mic,
  size: 18,
  key: const ValueKey<String>('compose_mic_button'),
);
```
`KaiButton.icon` в `kai_button.dart:152-155` форсирует `color: c.surface2, borderRadius: brPill` — получается серый pill вместо transparent.

**Подход**: добавить новый variant `KaiButton.iconTransparent` в `kai_button.dart`. Использовать его в `_MicSlot`.

**Изменения в `kai_button.dart`**:
```dart
// Existing static factories: tide(), ink1(), ghost(), icon()
// Add new:
factory KaiButton.iconTransparent({
  required VoidCallback? onPressed,
  required KaiIconName icon,
  double size = 18,
  Key? key,
}) {
  return KaiButton._(
    variant: KaiButtonVariant.iconTransparent,
    onPressed: onPressed,
    iconOnly: icon,
    iconSize: size,
    key: key,
  );
}
```

В `_decoration` switch добавить:
```dart
case KaiButtonVariant.iconTransparent:
  return const BoxDecoration(color: Colors.transparent);
```

Color для иконки — `c.ink3` (ink-3 как в HTML canon).

**Изменения в `_MicSlot`** (`compose_island.dart:144-179`):
```dart
class _MicSlot extends StatelessWidget {
  // ...
  @override
  Widget build(BuildContext context) {
    final c = KaiTheme.of(context).colors;
    final child = KaiButton.iconTransparent(            // ⭐ новая variant
      onPressed: onTap,
      icon: KaiIconName.mic,
      size: 14,                                          // ⭐ HTML canon size 14×14
      key: const ValueKey<String>('compose_mic_button'),
    );
    // active state — оставить accent-wash pill (когда recording)
    if (!active) return SizedBox(height: size, child: child);
    return SizedBox(
      height: size,
      child: Container(
        decoration: BoxDecoration(
          color: c.accentWash,
          borderRadius: KaiRadius.brPill,
        ),
        child: child,
      ),
    );
  }
}
```

(Active mic = recording mode — accent-wash pill, чтобы видно было "live". В idle — transparent.)

### 4.2 — H7: KaiButton.ghost border fix (HIGH)

**HTML canon** (`components.html:26` `l-pill` pattern):
```css
.l-pill {
  border: 1px solid var(--line);          /* line = #E8E8E5 */
  color: var(--ink-3);
}
```

**Текущая реализация** (`kai_button.dart:145-150`):
```dart
case KaiButtonVariant.ghost:
  return BoxDecoration(
    color: Colors.transparent,
    border: Border.all(color: c.ink3, width: 1),       // ❌ ink3 = #76767E (в 4× темнее канона)
    borderRadius: KaiRadius.brPill,
  );
```

**Фикс**: `color: c.line` (= #E8E8E5).

### 4.3 — H9: ComposeIsland button size 30 (HIGH)

**HTML canon** (`room.html:128,195`): `width: 30px; height: 30px;` для **pill** compose (frame 01, 02, 06). А **sheet** compose (frame 04) = 32×32. Это разные варианты.

**Текущая реализация** (`compose_island.dart:85`): `const buttonSize = 32.0;` всегда.

**Подход**: передать `buttonSize` через ctor или через context (pill vs sheet variant). В этом bucket'е — простой фикс:

```dart
class ComposeIsland extends StatelessWidget {
  const ComposeIsland({
    required this.controller,
    required this.onSend,
    this.onMicToggle,
    this.state = ComposeState.idle,
    this.placeholder = '...',
    this.showMic = true,
    this.variant = ComposeIslandVariant.pill,           // 🆕
    super.key,
  });

  final ComposeIslandVariant variant;

  // ...

  @override
  Widget build(BuildContext context) {
    final buttonSize = variant == ComposeIslandVariant.pill ? 30.0 : 32.0;
    // ...
  }
}

enum ComposeIslandVariant { pill, sheet }
```

Default = pill. Sheet variant — для frame 04 (compose sheet). Если нет места для sheet — оставить только pill в этом bucket'е.

### 4.4 — MEDIUM: ComposeIsland padding 5×5×5×16

**HTML canon** (`room.html:119,191,400`):
```css
.compose-island {
  padding: 5px 5px 5px 16px;                     /* top, right, bottom, left */
}
```
**Текущая реализация** (`compose_island.dart:98-101`):
```dart
padding: const EdgeInsets.symmetric(
  vertical: KaiSpace.s1 + 2,   // 6
  horizontal: KaiSpace.s2,     // 8
),
```

**Фикс**:
```dart
padding: const EdgeInsets.fromLTRB(16, 5, 5, 5),
```

(Это даёт текстовому полю смещение влево 16px от pill края, и tight 5px справа для send button.)

### 4.5 — MEDIUM: ComposeIsland gap

**HTML canon**: `.compose-island { gap: 4px; }`.

**Текущая реализация**: `SizedBox(width: KaiSpace.s2)` = 8 между mic→field и field→send.

**Фикс**: `SizedBox(width: 4)` (или новый токен `KaiSpace.s0_5 = 4` — но 4 уже = `KaiSpace.s1`).

### 4.6 — MEDIUM: Send icon size

**HTML canon** (`room.html:544,589`): `<svg width="13" height="13">` для frame01, `<svg width="12" height="12">` для frame02. Маленькая иконка внутри 30×30 круга.

**Текущая реализация** (`kai_button_send.dart:115-118`): `width: 20, height: 20` hardcoded.

**Фикс**: сделать параметризованным:
```dart
class KaiButtonSend extends StatefulWidget {
  const KaiButtonSend({
    required this.state,
    required this.onPressed,
    this.size = 44,
    this.iconSize = 16,                                   // 🆕
    super.key,
  });
  // ...
  final double iconSize;
}

// в build:
child: SvgPicture.asset(
  'assets/icons/send.svg',
  width: widget.iconSize,
  height: widget.iconSize,
  // ...
),
```

В ComposeIsland передать:
```dart
KaiButtonSend(
  state: sendState,
  onPressed: ...,
  size: buttonSize,       // 30 для pill
  iconSize: 12,           // канон 12-13 для pill
),
```

### 4.7 — MEDIUM: input font + min-width

**HTML canon** (`room.html:124`):
```css
.f01 .compose-island input {
  flex: 1; border: 0; outline: 0; background: transparent;
  font: 400 13.5px var(--font-sans); color: var(--ink-1);
  letter-spacing: -0.005em;
}
.f01 .compose-island input::placeholder { color: var(--ink-4); }
```

**Текущая реализация** (`compose_island.dart:194-219`): `KaiType.body` для текста + `KaiType.body` для placeholder. `KaiType.body` = 16px sans.

**Фикс**: создать новый style 13.5 sans:
```dart
final inputStyle = TextStyle(
  fontFamily: 'Manrope',
  fontSize: 13.5,
  color: c.ink1,
  letterSpacing: -0.005 * 13.5,
);
final placeholderStyle = inputStyle.copyWith(color: c.ink4);
```

(Если в `kai_type.dart` нет 13.5px стиля — можно добавить factory `KaiType.input(...)` либо использовать `KaiType.body.copyWith(fontSize: 13.5)`. Не критично, главное — финальный font 13.5.)

### 4.8 — MEDIUM: Sheet variant compose row (only if variant=sheet)

**HTML canon** (`room.html:336-353` frame04):
```css
.f04 .sheet .compose-row {
  background: var(--surface-2);
  border-radius: 24px;                              /* НЕ pill */
  padding: 6px 6px 6px 16px;
  display: flex; align-items: flex-end; gap: 6px;
}
.f04 .sheet textarea {
  font: 400 13.5px var(--font-sans); color: var(--ink-1);
  line-height: 1.45; min-height: 36px; padding: 7px 0 0;
}
.f04 .sheet .send { background: var(--tide-gradient); ... 32×32 ... }
.f04 .sheet .mic { background: transparent; color: var(--ink-3); }
```

Если поддержка variant=sheet в этом bucket'е — добавить condition:
```dart
final decoration = variant == ComposeIslandVariant.pill
  ? BoxDecoration(
      color: c.surface,
      border: Border.all(color: c.line, width: 1),
      borderRadius: KaiRadius.brPill,
    )
  : BoxDecoration(
      color: c.surface2,                              // surface-2 не surface
      borderRadius: BorderRadius.circular(24),
    );
final padding = variant == ComposeIslandVariant.pill
  ? const EdgeInsets.fromLTRB(16, 5, 5, 5)
  : const EdgeInsets.fromLTRB(16, 6, 6, 6);
final crossAxis = variant == ComposeIslandVariant.pill
  ? CrossAxisAlignment.center
  : CrossAxisAlignment.end;                          // align-items: flex-end
```

Если объём слишком большой — оставить sheet variant как TODO. Bucket A в frame 04 будет работать через Container(scrim) + LiveFrame (без sheet) — это допустимо для v1.

---

## 5 · Tests to update / add

### 5.1 — `compose_island_test.dart`

- Golden: pill variant (idle/ready/disabled/sending/streaming)
- Golden: pill variant с active mic (accent-wash)
- Golden: sheet variant (если реализован)
- Widget test: tap send → onSend(); tap mic → onMicToggle()
- Dark mode golden

### 5.2 — `kai_button_test.dart`

- Golden: tide / ink1 / ghost (с правильным `line` border) / icon / iconTransparent (NEW)
- Все 4 variants — light + dark

---

## 6 · Acceptance criteria

1. ComposeIsland в pill mode: padding `5×5×5×16`, mic transparent (ink-3 icon без bg), gap 4, button size 30.
2. ComposeIsland в sheet mode (if implemented): surface-2 bg, radius 24, padding `6×6×6×16`, button size 32.
3. `KaiButton.ghost` border = `tokens.colors.line` (был ink-3).
4. `KaiButton.iconTransparent` существует как variant.
5. `KaiButtonSend(iconSize: ...)` параметризован, default 16.
6. Никаких `Color(0xFF...)` хардкодов в трёх затронутых файлах.
7. `flutter test` зелёный + `flutter analyze` zero warnings.
8. Golden tests обновлены (включая dark mode).

---

## 7 · Out of scope

- **ChatList использование ComposeIsland** — Bucket A может потребоваться обновить вызов `KaiButton.icon` → `KaiButton.iconTransparent`, но это его задача.
- **RoomScreen integration** sheet variant — Bucket E (если он рендерит compose).
- **Stop button** для streaming state — `room.html:382 .stop-btn` — оставить TODO (не CRITICAL для v1, отдельная variant нужна).

---

## 8 · Commands

```bash
flutter test test/design_system/molecules/compose_island_test.dart
flutter test test/design_system/atoms/kai_button_test.dart
flutter test test/design_system/atoms/kai_button_send_test.dart
flutter analyze
```

---

## 9 · Commit message template

```
[bucket-c] Compose + buttons: pill 30×30 mic transparent, ghost border line, send iconSize parameterized

- C4: ComposeIsland mic now uses KaiButton.iconTransparent (no surface-2 pill bg)
- H7: KaiButton.ghost border color fixed to tokens.colors.line (was ink3 — 4× darker than canon)
- H9: ComposeIsland button size = 30 for pill variant (was hardcoded 32)
- MEDIUM: ComposeIsland padding 5/5/5/16 + gap 4 + input font 13.5px Manrope (canon)
- MEDIUM: KaiButtonSend(iconSize) parameterized — default 16, pill compose uses 12
- API: KaiButton gains .iconTransparent variant (transparent + ink-3 icon)
- API: ComposeIsland gains ComposeIslandVariant enum (pill | sheet)

Tests:
- compose_island_test goldens for pill/sheet variants × idle/ready/sending/streaming/disabled (light + dark)
- kai_button_test golden for iconTransparent variant
- kai_button_test golden updated for ghost (line border, not ink3)
```
