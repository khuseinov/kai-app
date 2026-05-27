# Bucket E — Screen positioning + Tide wiring

**Date**: 2026-05-27
**Branch**: `claude/hungry-lamport-e41998`
**Severity coverage**: 2 MEDIUM + 2 LOW
**Estimated effort**: 1–2 hours
**Dependency**: независим. Самый маленький bucket.

---

## 1 · Goal

Привести `RoomScreen` и `OnboardingScreen` к layout-правилам из `CLAUDE.md § Layout`:
- Tide curve на top of every product screen, `height: 16px`, 4px ниже safe area.
- OnboardingScreen step 2 (tide intro) использует `KaiTide.responding` state (не idle) — потому что step 2 показывает живую анимированную кривую.
- Убедиться, что Zero-UI соблюдён (нет persistent chrome, кроме status bar).

---

## 2 · Files to modify

| Файл | Что меняется |
|---|---|
| `lib/features/room/room_screen.dart` | KaiTideCurve `height: 48` → `16`, explicit 4px gap от status bar. |
| `lib/features/onboarding/onboarding_screen.dart` | Step 2 (tide intro) tide state = `responding` вместо `idle`. Top gap adjustment. |

---

## 3 · HTML canon refs

- `E:/startup/kai-app/new-design/CLAUDE.md § 3 Hard rules — Layout`
- `E:/startup/kai-app/new-design/room.html:47-48` — phone tide-svg positioning canon
- `E:/startup/kai-app/new-design/onboarding.html:226-230` — step 2 tide canon (responding gradient stream)
- `E:/startup/kai-app/new-design/tide-states.html` — token reference for states

CSS canon:
```css
.phone .tide-svg {
  position: absolute;
  top: 46px;                                  /* 4px below status bar + island ≈ 42 */
  left: 18px;
  width: calc(100% - 36px);
  height: 16px;                               /* ⭐ 16px, не 48 */
  z-index: 2;
}
```

---

## 4 · Detailed changes

### 4.1 — RoomScreen tide curve (MEDIUM)

**Файл**: `room_screen.dart` (line ~95-100 — KaiTideCurve usage)

**Текущая реализация**:
```dart
// room_screen.dart:97 (примерно)
KaiTideCurve(state: roomState.tideState, height: 48),
```

**Фикс**:
```dart
@override
Widget build(BuildContext context) {
  final tokens = KaiTheme.of(context);
  final mediaQuery = MediaQuery.of(context);
  final topInset = mediaQuery.padding.top;        // status bar + safe area

  return Scaffold(
    backgroundColor: tokens.colors.bg,
    body: SafeArea(
      top: false,                                  // мы сами управляем top
      child: Column(
        children: [
          SizedBox(height: topInset + 4),         // 4px ниже status bar
          SizedBox(
            height: 16,                           // tide canon height
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 18),
              child: KaiTideCurve(
                state: roomState.tideState,
                height: 16,
              ),
            ),
          ),
          // ... rest of layout (ChatList + ComposeIsland)
        ],
      ),
    ),
  );
}
```

`KaiTideCurve(height: 16)` — это явный размер. Если внутри атома не учитывается явный height — нужно проверить `kai_tide_curve.dart`, не блокировать на этом, скорее всего CustomPainter уже параметризован.

### 4.2 — OnboardingScreen step 2 tide state (LOW)

**Файл**: `onboarding_screen.dart:100` (примерно — где hardcoded `KaiTide.idle`)

**HTML canon** (`onboarding.html:226-230`):
```html
<!-- Step 2 — tide intro — показывает живую responding кривую -->
<svg ...>
  <path stroke="url(#g-tide)" stroke-width="2.5" stroke-dasharray="12 4" ...>
    <animate attributeName="stroke-dashoffset" from="0" to="-32" dur="1.4s" repeatCount="indefinite"/>
  </path>
</svg>
```

То есть step 2 — это **responding** tide state (dashed 12-4, 1.4s flow).

**Текущая реализация**: hardcoded `KaiTide.idle` для всех 1-3 шагов.

**Фикс**: маппить tide state по step index:
```dart
KaiTide _tideForStep(int step) {
  switch (step) {
    case 0: return KaiTide.idle;        // welcome — нет tide overlay в HTML (см. canon)
    case 1: return KaiTide.responding;  // tide intro — живая
    case 2: return KaiTide.idle;        // gestures
    case 3: return KaiTide.idle;        // context
    default: return KaiTide.idle;
  }
}

// in build:
KaiTideCurve(state: _tideForStep(currentStep), height: 16),
```

Или, если step 0 не имеет tide overlay в HTML (`onboarding.html:202-220` — step 0 без tide-svg) — рендерить tide только для steps 1-3:
```dart
if (currentStep > 0)
  SizedBox(
    height: 16,
    child: KaiTideCurve(state: _tideForStep(currentStep), height: 16),
  )
else
  const SizedBox(height: 16),    // зарезервированное место (или 0 если без gap)
```

### 4.3 — OnboardingScreen top inset (LOW)

**Текущая реализация**: `top: topInset + 26` (вместо 4 как канон).

**Фикс**: `top: topInset + 4` для consistency с RoomScreen.

```dart
SizedBox(height: topInset + 4),
SizedBox(
  height: 16,
  child: KaiTideCurve(state: _tideForStep(currentStep), height: 16),
),
const SizedBox(height: 8),     // gap до основного контента шага
// ... OnboardingCard
```

(Если визуально выглядит сжато на мобиле — можно добавить вторичный gap внутри OnboardingCard, не путём top inset.)

### 4.4 — Zero-UI check

Пройтись по `room_screen.dart`, `onboarding_screen.dart`, `nav_screen.dart` и убедиться:
- Никаких `AppBar`, `BottomNavigationBar`, `TabBar`.
- Если что-то есть для dev (debug overlay) — обернуть в `kDebugMode`.

`grep -E "AppBar|BottomNavigationBar|TabBar" lib/features/` — ожидаем результаты только в `lib/features/dev/`.

### 4.5 — RoomScreen tide state wiring (опционально, MEDIUM)

Если RoomState не маппит свои состояния на правильный KaiTide (`idle / listening / thinking / responding / success / error / memory / sleep`) — проверить и зафиксировать. Это уже было в plan T6.8:

```dart
// RoomState.dart logic:
KaiTide get tideState {
  if (isStreaming) return KaiTide.responding;
  if (isThinking) return KaiTide.thinking;
  if (isListening) return KaiTide.listening;
  if (lastEventWasError) return KaiTide.error;
  if (lastEventWasSuccess) return KaiTide.success;
  if (inactiveFor > Duration(seconds: 60)) return KaiTide.sleep;
  return KaiTide.idle;
}
```

Если RoomState так не сделан — оставить TODO + ссылку на T6.8.

---

## 5 · Tests to update / add

### 5.1 — `room_screen_test.dart` (если существует)

- Smoke test: tide curve рендерится в Column с height=16.
- Golden (light + dark): RoomScreen с tide на правильной позиции.

### 5.2 — `onboarding_screen_test.dart`

- Step 0 (welcome): нет tide overlay (или idle).
- Step 1 (tide intro): tide.state == responding.
- Step 2-3: idle.

### 5.3 — `tide_states_test.dart`

Если уже существует regression test для tide state transitions — добавить test для step 2 = responding.

---

## 6 · Acceptance criteria

1. `RoomScreen`: KaiTideCurve(height: 16), позиционирован `topInset + 4` от верха экрана.
2. `OnboardingScreen` step 1 (tide intro): tide state = responding.
3. `OnboardingScreen` step 0: нет tide overlay (или зарезервированное место без рендера).
4. Нет AppBar/BottomNav/TabBar в production screens (только в `lib/features/dev/`).
5. `flutter test` зелёный + `flutter analyze` zero warnings.
6. Visual cross-check: tide на iOS симуляторе совпадает с HTML канон (тонкая 16px полоса, 4px ниже status bar).

---

## 7 · Out of scope

- **RoomState tide state machine** (полная реализация) — Phase 6 task T6.8. В этом bucket'е — только проверить, что mapping имеется или TODO.
- **60-second inactivity timer** для sleep state — Phase 6 task T6.11. Не трогаем.
- **ChatList/ComposeIsland изменения** — Buckets A и C.
- **NavPanel** — Bucket B.

---

## 8 · Commands

```bash
flutter test test/features/room_test.dart
flutter test test/features/onboarding_test.dart
flutter test test/features/tide_states_test.dart
flutter analyze
```

Проверка Zero-UI:
```bash
# Не должно быть совпадений в production screens:
rg "AppBar|BottomNavigationBar|TabBar" lib/features/room/ lib/features/onboarding/ lib/features/nav/
```

---

## 9 · Commit message template

```
[bucket-e] Screen positioning: tide curve height 16 + 4px gap from safe area, onboarding step 2 → responding

- MEDIUM: RoomScreen KaiTideCurve height 48 → 16 (per CLAUDE.md § Layout)
- MEDIUM: RoomScreen explicit 4px gap from status bar (was implicit/zero)
- LOW: OnboardingScreen step 1 (tide intro) now uses KaiTide.responding (was idle for all steps)
- LOW: OnboardingScreen top inset 26 → 4 for consistency with RoomScreen

Verified:
- No AppBar/BottomNav/TabBar in production screens (showcase only)
- RoomState → KaiTide mapping confirmed (or TODO added pointing to T6.8 if not implemented)
```
