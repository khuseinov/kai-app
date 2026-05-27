# Bucket D — AlertCard + EdgeStateBlock polish

**Date**: 2026-05-27
**Branch**: `claude/hungry-lamport-e41998`
**Severity coverage**: 1 CRITICAL + 4 HIGH + 6 MEDIUM
**Estimated effort**: 3–4 hours
**Dependency**: независим (можно параллельно с любыми bucket'ами)

---

## 1 · Goal

Закрыть структурные баги в `AlertCard` (neutral palette) и `EdgeStateBlock` (offline / error / rate-limit / crisis):
- Убрать дублирующие KaiTideCurve в error/crisis (нарушение Zero-UI).
- Привести offline к канону warning-wash + wifi-off icon + body text.
- Rate-limit с clock icon + конкретное время сброса.
- Crisis с правильным left-border treatment + 2 CareResources.

**Note**: AlertCard 4-zone N-01 (notifications-chat full integration) **не в v1 scope**. Этот bucket исправляет только конкретный баг — neutral type использует accent-wash вместо surface-2. Анатомия остаётся 1-Column simplified (acknowledged tech debt).

---

## 2 · Files to modify

| Файл | Что меняется |
|---|---|
| `lib/design_system/molecules/alert_card.dart` | Палитра neutral type: surface-2 + line border (не accent-wash + accent). Optional: per-type icons. |
| `lib/design_system/organisms/edge_state_block.dart` | Удалить duplicate KaiTideCurve из error/crisis surfaces. Offline → warning-wash + wifi-off + body. Rate-limit → clock icon + countdown formatting. Crisis → left-border + rgba(196,74,60,0.04) bg. |
| `lib/design_system/molecules/care_block.dart` | Минимальные правки если нужны: left-border 2px negative + radius 0 10 10 0 (правый край скруглён). |

---

## 3 · HTML canon refs

- `E:/startup/kai-app/new-design/edge-states.html` — все 4 surfaces (offline / error / rate-limit / crisis), также см. inline-note и care-block patterns
- `E:/startup/kai-app/new-design/notifications-chat.html` — AlertCard N-01 (но full integration вне scope)

Конкретные классы в edge-states.html:
- `.inline-note` general structure
- `.inline-note.warning` для offline (rgba warning-wash bg)
- `.inline-note.error` для error (rgba negative-wash bg)
- `.rate-limit` для rate-limit
- `.care-block` для crisis (left-border 2px negative)

---

## 4 · Detailed changes

### 4.1 — C5: AlertCard.neutral palette (CRITICAL)

**HTML canon** (`notifications-chat.html:108-111`):
```css
.alert-card.neutral {
  background: var(--surface-2);         /* НЕ accent-wash */
  border: 1px solid var(--line);
}
```

**Текущая реализация** (`alert_card.dart:89-90`):
```dart
case AlertType.neutral:
  return _AlertPalette(
    background: c.accentWash,        // ❌ accent-wash
    accent: c.accent,                // ❌ accent
  );
```

**Фикс**:
```dart
case AlertType.neutral:
  return _AlertPalette(
    background: c.surface2,          // ✅ surface-2
    accent: c.ink3,                  // ✅ ink-3 для нейтральности
  );
```

Проверь использование `_AlertPalette.accent` в виджете — где-то рисуется border, icon color, title color. Для neutral все они должны быть **ink-3** (не цветовая категория).

### 4.2 — H2: EdgeStateBlock error duplicate Tide (HIGH)

**Файл**: `edge_state_block.dart:131`

**Текущая реализация** включает `KaiTideCurve(state: KaiTide.error, height: 28)` ВНУТРИ error surface. Это нарушает Zero-UI правило «одна Tide наверху экрана».

**HTML canon** (`edge-states.html:257-261`): error tide живёт в общем top tide-bar экрана. Inline-note (error block) — это только текст + icon + retry, без tide.

**Фикс**: удалить `KaiTideCurve` из `_ErrorSurface`. RoomScreen tide curve остаётся наверху и **переключается на error state снаружи** через RoomState.

```dart
// Удалить из _ErrorSurface build():
// KaiTideCurve(state: KaiTide.error, height: 28),

// Оставить только:
// - Icon (alert circle)
// - Title (error)
// - Body
// - Retry button
```

### 4.3 — H3: EdgeStateBlock crisis duplicate Tide (HIGH)

**Файл**: `edge_state_block.dart:229-232`

**Текущая реализация**: `KaiTideCurve(state: KaiTide.idle)` внутри crisis surface — то же самое нарушение.

**HTML canon** (`edge-states.html:321-324`): top tide-bar = g-mute idle (тусклый), не дублируется внутри care-block.

**Фикс**: удалить `KaiTideCurve` из `_CrisisSurface`. RoomScreen tide остаётся idle снаружи (через RoomState логику).

### 4.4 — H4: EdgeStateBlock offline structure (HIGH)

**HTML canon** (`edge-states.html:72,230-238`):
```css
.inline-note.warning {
  background: var(--warning-wash);
  color: var(--warning);
}
/* structure: */
<div class="inline-note warning">
  <svg use="#i-wifi-off"/>             <!-- 18×18 wifi-off icon -->
  <div class="ttl">Нет сети</div>      <!-- 600 11.5 sans warning color -->
  <div class="body">Отправлю когда выйдете в онлайн. Очередь сохранена.</div>
  <!-- 400 11 sans ink-2 -->
  <button class="retry-pill">↻ повторить</button>  <!-- 500 10.5 sans warning border -->
</div>
```

**Текущая реализация** (`edge_state_block.dart:68-108`):
- Container `tokens.colors.surface2` (не warning-wash)
- жёлтая точка вместо wifi-off icon
- одиночный title через `l10n.offlineTitle` без body

**Фикс**: полная переработка `_OfflineSurface`:

```dart
class _OfflineSurface extends StatelessWidget {
  const _OfflineSurface({this.onRetry});
  final VoidCallback? onRetry;

  @override
  Widget build(BuildContext context) {
    final tokens = KaiTheme.of(context);
    final l10n = AppLocalizations.of(context);
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 13, vertical: 11),
      decoration: BoxDecoration(
        color: tokens.colors.warningWash,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: Color.fromRGBO(181, 122, 11, 0.18),  // warning border alpha
          width: 1,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 18, height: 18,
                decoration: BoxDecoration(
                  color: Color.fromRGBO(181, 122, 11, 0.12),
                  shape: BoxShape.circle,
                ),
                child: Center(
                  child: KaiIcon(
                    KaiIconName.wifiOff,                          // 🆕 new icon enum
                    size: 10,
                    color: tokens.colors.warning,
                  ),
                ),
              ),
              const SizedBox(width: 6),
              Text(
                l10n.offlineTitle,
                style: TextStyle(
                  fontFamily: 'Manrope',
                  fontSize: 11.5,
                  fontWeight: FontWeight.w600,
                  color: tokens.colors.warning,
                  letterSpacing: -0.005 * 11.5,
                ),
              ),
            ],
          ),
          const SizedBox(height: 7),
          Text(
            l10n.offlineBody,                                       // 🆕 ARB key
            style: TextStyle(
              fontFamily: 'Manrope',
              fontSize: 11,
              color: tokens.colors.ink2,
              height: 1.45,
            ),
          ),
          const SizedBox(height: 9),
          // retry-pill
          if (onRetry != null) GestureDetector(
            onTap: onRetry,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 11, vertical: 5),
              decoration: BoxDecoration(
                color: Colors.transparent,
                border: Border.all(
                  color: Color.fromRGBO(181, 122, 11, 0.25),
                  width: 1,
                ),
                borderRadius: KaiRadius.brPill,
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  KaiIcon(KaiIconName.retry, size: 12, color: tokens.colors.warning),
                  const SizedBox(width: 4),
                  Text(
                    l10n.retry,
                    style: TextStyle(
                      fontFamily: 'Manrope',
                      fontSize: 10.5,
                      fontWeight: FontWeight.w500,
                      color: tokens.colors.warning,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
```

**KaiIconName.wifiOff** — нужно добавить enum + SVG asset.

**ARB keys**:
- `offlineTitle` = "Нет сети" / "Offline"
- `offlineBody` = "Отправлю, когда выйдете в онлайн. Очередь сохранена." / "Will send when you're back online. Queue saved."

### 4.5 — MEDIUM: EdgeStateBlock rateLimit clock icon + body (MEDIUM)

**Текущая реализация**: использует `alert` icon + `KaiText.body` без warning-цветного title.

**HTML canon** (`edge-states.html:294-303`):
```html
<svg use="#i-clock"/>                                  <!-- clock icon, не alert -->
<div class="ttl">Лимит запросов</div>                  <!-- warning color, 600 11.5 -->
<div class="body">Сброс в 14:32 (через 4 мин). Plan Pro — без лимита.</div>
<button class="upgrade-btn">Plan Pro</button>
```

**Фикс**: аналогично offline, но с:
- `KaiIconName.clock` (нужно добавить если нет)
- `l10n.rateLimitTitle` (уже есть)
- body string с countdown — `'${l10n.rateLimitBodyPrefix} $time. ${l10n.rateLimitUpgradeHint}'`
- upgrade button через `KaiButton.tide` или ghost (опционально)

**ARB keys**:
- `rateLimitBodyPrefix` = "Сброс в" / "Resets at"
- `rateLimitUpgradeHint` = "Plan Pro — без лимита." / "Plan Pro removes limits."
- `viewPlans` (уже должен быть) = "Plan Pro" / "View plans"

`KaiIconName.clock` — добавить в enum + SVG asset (см. `room.html:474` для базовой формы).

### 4.6 — MEDIUM: EdgeStateBlock crisis structure (MEDIUM)

**Текущая реализация**: Container surface (не negative-wash 0.04), без left-border.

**HTML canon** (`edge-states.html:97-103`):
```css
.care-block {
  border-left: 2px solid var(--negative);          /* 2px coral left border */
  border-radius: 0 10px 10px 0;                    /* only right corners rounded */
  background: rgba(196,74,60,0.04);                /* very subtle coral tint */
  padding: 11px 13px;
}
```

**Фикс** для `_CrisisSurface` в `edge_state_block.dart`:
```dart
class _CrisisSurface extends StatelessWidget {
  // ...
  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        color: Color.fromRGBO(196, 74, 60, 0.04),
        border: Border(left: BorderSide(
          color: Color(0xFFC44A3C),                  // должно быть через token!
          width: 2,
        )),
        borderRadius: BorderRadius.only(
          topRight: Radius.circular(10),
          bottomRight: Radius.circular(10),
        ),
      ),
      // ... CareBlock с 2 CareResources
    );
  }
}
```

⚠️ **Не использовать hardcode** `Color(0xFFC44A3C)` — нужен токен. Лучше через `KaiTheme.of(context).colors.negative` (но это требует non-const). Пример:
```dart
Widget build(BuildContext context) {
  final tokens = KaiTheme.of(context);
  return Container(
    decoration: BoxDecoration(
      color: tokens.colors.negative.withAlpha(10),    // 0x0A = 4% ≈ rgba 0.04
      border: Border(left: BorderSide(
        color: tokens.colors.negative,
        width: 2,
      )),
      borderRadius: const BorderRadius.only(
        topRight: Radius.circular(10),
        bottomRight: Radius.circular(10),
      ),
    ),
    // ...
  );
}
```

### 4.7 — MEDIUM: Crisis с двумя CareResources

**HTML canon** (`edge-states.html:331-334`): два resources блока подряд — 988 (suicide hotline) + 741741 (crisis text).

**Текущая реализация**: одна CareResource через `resources: [CareResource(label: l10n.crisisResourceLabel, number: l10n.crisisResourceNumber)]`.

**Фикс**: добавить второй resource. Расширить ctor `_CrisisSurface` чтобы принимать `List<CareResource>` или hardcode две в `EdgeStateBlock(...crisis...)`:
```dart
resources: [
  CareResource(
    label: l10n.crisisResourceLabelPhone,           // "Доверие · Россия"
    number: l10n.crisisResourceNumberPhone,         // "8 800 2000 122"
    type: CareResourceType.phone,
  ),
  CareResource(
    label: l10n.crisisResourceLabelText,            // "Crisis Text Line"
    number: l10n.crisisResourceNumberText,          // "Текст HOME на 741741"
    type: CareResourceType.text,
  ),
],
```

**ARB keys** добавить (RU + EN):
- `crisisResourceLabelPhone`
- `crisisResourceNumberPhone`
- `crisisResourceLabelText`
- `crisisResourceNumberText`

(Реальные номера должны соответствовать территории — для российских пользователей это телефон доверия, для US — 988. Выбирать на основе locale.)

### 4.8 — MEDIUM/LOW: CareBlock partial radius

**Файл**: `care_block.dart:73-78`

**Текущая реализация**: `BorderRadius.only(topRight: r2, bottomRight: r2)` — только правые углы скруглены (для left-border style). Это **корректно** для left-border treatment, но проверить что padding соответствует канону `11px 13px`.

Если CareBlock уже соответствует — оставить как есть. Если нет — фиксить padding.

---

## 5 · Tests to update / add

### 5.1 — `alert_card_test.dart`

- Golden per type: urgent / warning / positive / **neutral** (с surface-2 + line border, не accent-wash)
- Dark mode parity

### 5.2 — `edge_state_block_test.dart`

- Golden per surface: offline / error / rateLimit / crisis
- Offline: warning-wash + wifi-off icon + body text
- Error: NO duplicate tide curve inside block
- Crisis: NO duplicate tide curve + left-border 2px + 2 CareResources
- RateLimit: clock icon + countdown body + plans button
- Dark mode goldens для всех 4

### 5.3 — `care_block_test.dart`

- Golden с правильным radius (только правые углы)

---

## 6 · Acceptance criteria

1. `alert_card.dart` neutral type использует `surface-2` bg + `line` border + `ink-3` accent.
2. `_ErrorSurface` и `_CrisisSurface` НЕ содержат внутреннего `KaiTideCurve`.
3. `_OfflineSurface` имеет warning-wash bg, wifi-off icon, body text "Отправлю когда выйдете в онлайн".
4. `_RateLimitSurface` имеет clock icon (не alert), body с countdown, plans CTA.
5. `_CrisisSurface` имеет 2px negative left-border + rgba 0.04 bg + 2 CareResources.
6. `KaiIconName.wifiOff` и `KaiIconName.clock` существуют в enum (+ SVG assets).
7. `grep "Color(0xFF" lib/design_system/molecules/alert_card.dart` → 0.
8. `grep "Color(0xFF" lib/design_system/organisms/edge_state_block.dart` → 0.
9. `grep "Color(0xFF" lib/design_system/molecules/care_block.dart` → 0.
10. `flutter test` зелёный + `flutter analyze` zero warnings.
11. Golden tests обновлены (light + dark).

---

## 7 · Out of scope

- **AlertCard 4-zone N-01 anatomy** (.ac-head + .ac-body + .ac-actions с per-type icon + type label + time) — **acknowledged tech debt**, не в v1 scope.
- **AlertCard integration в chat feed** (notifications-chat full pattern) — не в v1 scope.
- **Per-type icons** для AlertCard (urgent → alert, warning → triangle, positive → check, neutral → info) — оставить TODO в коде.
- **Tide state wiring** в RoomScreen для error/crisis (внешнее переключение tide on top) — Bucket E.
- **Connectivity_plus integration** для real offline detection — Phase 6 backend integration.

---

## 8 · Commands

```bash
flutter test test/design_system/molecules/alert_card_test.dart
flutter test test/design_system/molecules/care_block_test.dart
flutter test test/design_system/organisms/edge_state_block_test.dart
flutter analyze
flutter gen-l10n
```

---

## 9 · Commit message template

```
[bucket-d] AlertCard neutral palette + EdgeStateBlock: remove duplicate tide, add wifi-off/clock icons, crisis left-border

- C5: AlertCard.neutral now uses surface-2 + line border + ink-3 (was accentWash + accent)
- H2: _ErrorSurface no longer renders internal KaiTideCurve (canon: tide lives at top of screen)
- H3: _CrisisSurface no longer renders internal KaiTideCurve (same canon rule)
- H4: _OfflineSurface uses warning-wash bg + wifi-off icon-circle + body text + retry-pill (was surface-2 + dot)
- MEDIUM: _RateLimitSurface uses clock icon (not alert) + countdown body + plans CTA
- MEDIUM: _CrisisSurface gets 2px negative left-border + rgba(196,74,60,0.04) bg + 2 CareResources
- MEDIUM: CareBlock padding aligned to canon 11×13

Icons added:
- KaiIconName.wifiOff (assets/icons/wifi-off.svg)
- KaiIconName.clock (assets/icons/clock.svg)

l10n:
- offlineTitle, offlineBody, rateLimitBodyPrefix, rateLimitUpgradeHint
- crisisResourceLabelPhone, crisisResourceNumberPhone, crisisResourceLabelText, crisisResourceNumberText

Tests:
- alert_card_test goldens for 4 types (light + dark)
- edge_state_block_test goldens for 4 surfaces (light + dark) verifying no internal tide
- care_block_test golden refresh
```
