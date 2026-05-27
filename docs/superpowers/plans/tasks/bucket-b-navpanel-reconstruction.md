# Bucket B — NavPanel reconstruction

**Date**: 2026-05-27
**Branch**: `claude/hungry-lamport-e41998`
**Severity coverage**: 1 CRITICAL + 5 HIGH + 6 MEDIUM
**Estimated effort**: 4–6 hours
**Dependency**: независим (можно параллельно с любыми другими bucket'ами)

---

## 1 · Goal

Восстановить полную структуру NavPanel согласно `new-design/nav.html` + `new-design/room.html § f03 .panel` — добавить pinned trip section, trips folder section, date-grouped recent chats, плюс фиксы top-bar, search-box, sec-label, account anchor.

Phase 4 task T4.19 явно говорил «Implement pinned trip + trips section + dates grouping» — но в реализации это пропущено. Этот bucket закрывает план-implementation gap.

---

## 2 · Files to modify

| Файл | Что меняется |
|---|---|
| `lib/design_system/organisms/nav_panel.dart` | Полная переработка — добавить pin-trip widget, trips folder section с count badge, date-grouped recent chats. Фикс top-bar (Kai центрирован), search-box (radius 9, mono 11), sec-label (mono 8.5), account (tide-gradient 24×24 avatar + initial). |
| `lib/design_system/molecules/nav_item.dart` | Padding adjustment (14×6/7 вместо 12×10), font 11px вместо 16px, icon size 14 / 18. |

---

## 3 · HTML canon refs

- `E:/startup/kai-app/new-design/nav.html` — basic structure
- `E:/startup/kai-app/new-design/room.html` — line 208-313 (panel sub-structure внутри room frame 03)

Key sections in `room.html`:
- Panel container styling: lines 208-215
- Top bar (close, title, spacer): lines 216-230
- New chat button: lines 239-247
- Search box: lines 248-254
- Section labels: lines 255-261
- **Pin-trip widget**: lines 262-277 ⭐ (ЭТО ОТСУТСТВУЕТ В FLUTTER)
- Folder/app rows: lines 278-292
- **Chat rows + active state**: lines 293-300
- **Account anchor**: lines 301-313

---

## 4 · Detailed changes

### 4.1 — Top bar (`_TopBar` widget, `nav_panel.dart:113-153`)

**HTML canon** (`room.html:216-230`):
```css
.panel .panel-top {
  position: absolute; top: 0; left: 0; right: 0;
  height: 44px; padding: 0 22px;
  display: flex; align-items: center; justify-content: space-between;
}
.panel .panel-top .close {
  background: var(--surface-2); border: 0; border-radius: 50%;
  width: 28px; height: 28px; color: var(--ink-1);
}
.panel .panel-top .ttl {
  font: 600 14px var(--font-sans); color: var(--ink-1); letter-spacing: -0.005em;
}
.panel .panel-top .spacer { width: 28px; }
```

**Текущая реализация**: Row(close + Expanded(SizedBox) + KaiText.h3('Kai')) — title прибит вправо, h3 = 24px вместо 14.

**Фикс**:
```dart
class _TopBar extends StatelessWidget {
  // ...
  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 44,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 22),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            // Close 28×28
            GestureDetector(
              onTap: onClose,
              child: Container(
                width: 28,
                height: 28,
                decoration: BoxDecoration(
                  color: tokens.colors.surface2,
                  shape: BoxShape.circle,
                ),
                child: Center(
                  child: KaiIcon(
                    KaiIconName.close,
                    size: 14,                                  // ↘ 14 not 16
                    color: tokens.colors.ink1,                 // ↘ ink-1 not ink-2
                  ),
                ),
              ),
            ),
            // Centered title (через layout balance)
            Text(
              'Kai',                                            // TODO: l10n key 'appName'
              style: TextStyle(
                fontFamily: 'Manrope',
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: tokens.colors.ink1,
                letterSpacing: -0.005 * 14,
              ),
            ),
            // Spacer 28 (балансирует close, чтобы title оказался центрирован)
            const SizedBox(width: 28),
          ],
        ),
      ),
    );
  }
}
```

(Технически — `mainAxisAlignment: spaceBetween` + symmetric edges автоматически центрирует средний элемент.)

### 4.2 — New chat button (`nav_panel.dart:69-73`)

**HTML canon** (`room.html:239-247`):
```css
.panel .new-chat {
  margin: 0 12px 10px;                               /* horizontal 12, bottom 10 */
  background: var(--ink-1); color: var(--surface);
  border: 0; border-radius: 10px;                    /* radius 10 = r2 */
  padding: 9px;
  font: 600 12px var(--font-sans); letter-spacing: -0.005em;
  display: flex; align-items: center; justify-content: center; gap: 7px;
}
```

Используется `KaiButton.ink1` через atom. Проверить, что `KaiButton.ink1`:
- radius = `r2` (10) ✓ должно быть, если нет — фиксить в Bucket C
- padding `9` all sides
- font 600 12px
- icon + label gap 7px

Если `KaiButton.ink1` не соответствует — оставить TODO для Bucket C, но в этом bucket'е использовать как есть. Внешний margin задаётся wrapper'ом:

```dart
Padding(
  padding: const EdgeInsets.fromLTRB(12, 0, 12, 10),
  child: KaiButton.ink1(
    onPressed: onNewChat,
    label: l10n.newChat,                              // ← через l10n, not hardcoded
    icon: KaiIconName.plus,
  ),
),
```

**ARB key**: `newChat` = "Новый чат" / "New chat".

### 4.3 — Search box (`_SearchBox` widget, `nav_panel.dart:155-185`)

**HTML canon** (`room.html:248-254`):
```css
.panel .search-box {
  margin: 0 12px 8px;
  background: var(--surface-2);
  border-radius: 9px;                                /* НЕ pill */
  padding: 7px 10px;
  display: flex; align-items: center; gap: 7px;
  font-size: 11px; color: var(--ink-3);              /* mono 11 */
}
.panel .search-box svg { color: var(--ink-3); flex-shrink: 0; }
```

**Текущая реализация**: `brPill` + 16px sans body + ink-4 icon.

**Фикс**:
```dart
class _SearchBox extends StatelessWidget {
  // ...
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(12, 0, 12, 8),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 7),
        decoration: BoxDecoration(
          color: tokens.colors.surface2,
          borderRadius: BorderRadius.circular(9),     // ← 9px, не pill
        ),
        child: Row(
          children: [
            KaiIcon(
              KaiIconName.search,
              size: 14,                                // ← 14, not 16
              color: tokens.colors.ink3,               // ← ink-3, not ink-4
            ),
            const SizedBox(width: 7),
            Text(
              l10n.search,                             // ← l10n
              style: const TextStyle(
                fontFamily: 'Manrope',                 // sans (можно поменять на mono если visual better)
                fontSize: 11,
                color: ... tokens.colors.ink3,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
```

**ARB key**: `search` = "Поиск" / "Search".

### 4.4 — Section labels (`.sec-label`)

**HTML canon** (`room.html:255-261`):
```css
.panel .sec-label {
  font-family: var(--font-mono);                     /* MONO */
  font-size: 8.5px;                                  /* 8.5 ← не 12 */
  color: var(--ink-3);
  text-transform: uppercase;
  letter-spacing: 0.1em;
  padding: 10px 14px 4px;                            /* top 10, sides 14, bottom 4 */
  display: flex; align-items: baseline; justify-content: space-between;
}
.panel .sec-label .ct { color: var(--ink-4); font-size: 8.5px; }
```

Создать виджет `_SectionLabel`:
```dart
class _SectionLabel extends StatelessWidget {
  const _SectionLabel({required this.label, this.count});
  final String label;
  final int? count;

  @override
  Widget build(BuildContext context) {
    final tokens = KaiTheme.of(context);
    return Padding(
      padding: const EdgeInsets.fromLTRB(14, 10, 14, 4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.baseline,
        textBaseline: TextBaseline.alphabetic,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label.toUpperCase(),
            style: TextStyle(
              fontFamily: 'JetBrainsMono',
              fontSize: 8.5,
              color: tokens.colors.ink3,
              letterSpacing: 0.1 * 8.5,
            ),
          ),
          if (count != null)
            Text(
              count.toString(),
              style: TextStyle(
                fontFamily: 'JetBrainsMono',
                fontSize: 8.5,
                color: tokens.colors.ink4,
              ),
            ),
        ],
      ),
    );
  }
}
```

Использовать вместо текущего `KaiType.micro` `'ЧАТЫ'` (`nav_panel.dart:90-93`) и `'ПРИЛОЖЕНИЯ'` (`:245-248`).

### 4.5 — Pin-trip widget (CRITICAL — НОВЫЙ компонент)

**HTML canon** (`room.html:262-277`):
```css
.panel .pin-trip {
  margin: 0 12px 3px;
  padding: 8px 10px;
  background: linear-gradient(135deg, rgba(43,168,201,0.06), rgba(244,181,137,0.04));
  border: 1px solid var(--accent-line);
  border-radius: 10px;
  display: grid; grid-template-columns: 24px 1fr; gap: 9px; align-items: center;
}
.panel .pin-trip .gl {
  width: 24px; height: 24px; border-radius: 7px;
  background: var(--tide-gradient);                  /* tide gradient!  */
  background-size: 200% 100%;
  display: flex; align-items: center; justify-content: center;
  color: white; font-size: 9px; font-weight: 700;
}
.panel .pin-trip .t { font-size: 11px; color: var(--ink-1); font-weight: 600; letter-spacing: -0.005em; }
.panel .pin-trip .s { font-size: 9px; color: var(--ink-3); font-family: var(--font-mono); margin-top: 1px; }
```

Создать виджет `_PinnedTripCard`:
```dart
class _PinnedTripCard extends StatelessWidget {
  const _PinnedTripCard({
    required this.title,
    required this.subtitle,
    required this.initial,
    this.onTap,
  });

  final String title;       // "Япония · ноябрь"
  final String subtitle;    // mono — "12-26 ноя · черновик"
  final String initial;     // "Я" — первая буква destination
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final tokens = KaiTheme.of(context);
    return Padding(
      padding: const EdgeInsets.fromLTRB(12, 0, 12, 3),
      child: GestureDetector(
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
          decoration: BoxDecoration(
            // Custom subtle gradient — accent + warm beige
            gradient: const LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                Color.fromRGBO(43, 168, 201, 0.06),
                Color.fromRGBO(244, 181, 137, 0.04),
              ],
            ),
            border: Border.all(color: tokens.colors.accentLine, width: 1),
            borderRadius: BorderRadius.circular(10),
          ),
          child: Row(
            children: [
              // Tide-gradient glyph 24×24 r-7 with initial
              Container(
                width: 24,
                height: 24,
                decoration: BoxDecoration(
                  gradient: KaiTide.gradient,
                  borderRadius: BorderRadius.circular(7),
                ),
                child: Center(
                  child: Text(
                    initial,
                    style: const TextStyle(
                      fontFamily: 'Manrope',
                      color: Colors.white,
                      fontSize: 9,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 9),
              // Title + mono subtitle column
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: TextStyle(
                        fontFamily: 'Manrope',
                        fontSize: 11,
                        fontWeight: FontWeight.w600,
                        color: tokens.colors.ink1,
                        letterSpacing: -0.005 * 11,
                      ),
                    ),
                    const SizedBox(height: 1),
                    Text(
                      subtitle,
                      style: TextStyle(
                        fontFamily: 'JetBrainsMono',
                        fontSize: 9,
                        color: tokens.colors.ink3,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
```

**Использование** в NavPanel build:
```dart
// После search box, перед section label "ПОЕЗДКИ":
if (pinnedTrip != null) _PinnedTripCard(
  title: pinnedTrip.title,
  subtitle: pinnedTrip.subtitle,
  initial: pinnedTrip.initial,
  onTap: () => onTripTap?.call(pinnedTrip.id),
),
```

Расширить ctor `NavPanel`:
```dart
const NavPanel({
  this.onClose,
  this.onNewChat,
  this.pinnedTrip,                       // 🆕
  this.trips = const [],                 // 🆕 — список Trip
  this.dateGroupedSessions = const {},   // 🆕 — Map<DateGroup, List<Session>>
  this.activeSessionId,
  this.onSessionTap,
  this.onTripTap,                        // 🆕
  super.key,
});
```

Тип `Trip` — простой:
```dart
class TripInfo {
  final String id;
  final String title;
  final String subtitle;
  final String initial;
  const TripInfo({...});
}
```

В этом bucket'е — статическая структура (mock-data для showcase). Wire реального state в Phase следующая.

### 4.6 — Trips folder section (CRITICAL — продолжение C3)

**HTML canon** (`room.html:278-287`):
```css
.panel .folder-row {
  padding: 7px 14px;
  display: grid; grid-template-columns: 14px 1fr auto; gap: 9px; align-items: center;
}
.panel .folder-row svg { color: var(--ink-3); }
.panel .folder-row .t { font-size: 11px; color: var(--ink-1); font-weight: 500; }
.panel .folder-row .badge {
  font-family: var(--font-mono); font-size: 8.5px; color: var(--ink-3);
  padding: 1px 5px; background: var(--surface-2); border-radius: 999px;
}
```

Создать виджет `_FolderRow`:
```dart
class _FolderRow extends StatelessWidget {
  const _FolderRow({
    required this.label,
    this.count,
    this.onTap,
  });

  final String label;
  final int? count;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final tokens = KaiTheme.of(context);
    return GestureDetector(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 7),
        child: Row(
          children: [
            KaiIcon(KaiIconName.folder, size: 14, color: tokens.colors.ink3),
            const SizedBox(width: 9),
            Expanded(
              child: Text(
                label,
                style: TextStyle(
                  fontFamily: 'Manrope',
                  fontSize: 11,
                  fontWeight: FontWeight.w500,
                  color: tokens.colors.ink1,
                  letterSpacing: -0.005 * 11,
                ),
              ),
            ),
            if (count != null)
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 1),
                decoration: BoxDecoration(
                  color: tokens.colors.surface2,
                  borderRadius: BorderRadius.circular(999),
                ),
                child: Text(
                  count.toString(),
                  style: TextStyle(
                    fontFamily: 'JetBrainsMono',
                    fontSize: 8.5,
                    color: tokens.colors.ink3,
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}
```

**Section structure**:
```dart
_SectionLabel(label: l10n.tripsLabel, count: trips.length),
...trips.map((t) => _FolderRow(
  label: t.title,
  count: t.chatCount,
  onTap: () => onTripTap?.call(t.id),
)),
```

**ARB key**: `tripsLabel` = "ПОЕЗДКИ" / "TRIPS".

⚠️ `KaiIconName.folder` нужно добавить в `kai_icon.dart` enum, если не существует. Также SVG-asset `assets/icons/folder.svg` — извлечь из `room.html:472-473` inline SVG.

### 4.7 — Date-grouped recent chats (CRITICAL — продолжение C3)

**HTML canon** (`room.html:293-300` + section label pattern):

Структура:
```
СЕГОДНЯ          (sec-label с count)
├── chat-row "Виза в Японию" (mono date subtitle "9:41")
├── chat-row "JR Pass 14 дней"
ВЧЕРА            (sec-label с count)
├── chat-row "Стамбул бюджет"
ПРЕДЫДУЩИЕ 7     (sec-label с count)
├── chat-row "Шенген калькулятор"
```

`.chat-row`:
```css
.panel .chat-row {
  padding: 6px 14px;
  border-left: 2px solid transparent;
}
.panel .chat-row.active { background: var(--accent-wash); border-left-color: var(--accent); }
.panel .chat-row .t { font-size: 11px; color: var(--ink-1); font-weight: 500; letter-spacing: -0.005em; line-height: 1.3; }
.panel .chat-row.active .t { color: var(--accent); font-weight: 600; }
.panel .chat-row .s { font-size: 8.5px; color: var(--ink-3); font-family: var(--font-mono); margin-top: 1px; }
```

Это **очень близко** к `NavItem` molecule — но padding отличается (14×6 vs текущего 12×10) и font 11 vs 16. Реши:

**Опция А (рекомендую)**: создать новый виджет `_ChatRow` inline в `nav_panel.dart` со своими паддингами. Не трогать `NavItem` (он используется в `_AppsSection`).

**Опция Б**: расширить `NavItem` с `density: NavItemDensity.compact` параметром. Лучше для будущего, но больше работы.

В этом bucket'е — **Опция А**. Создать `_ChatRow`:

```dart
class _ChatRow extends StatelessWidget {
  const _ChatRow({
    required this.title,
    required this.subtitle,
    required this.active,
    this.onTap,
  });

  final String title;
  final String subtitle;     // mono — date or time
  final bool active;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final tokens = KaiTheme.of(context);
    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
        decoration: BoxDecoration(
          color: active ? tokens.colors.accentWash : Colors.transparent,
          border: Border(
            left: BorderSide(
              color: active ? tokens.colors.accent : Colors.transparent,
              width: 2,
            ),
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: TextStyle(
                fontFamily: 'Manrope',
                fontSize: 11,
                fontWeight: active ? FontWeight.w600 : FontWeight.w500,
                color: active ? tokens.colors.accent : tokens.colors.ink1,
                height: 1.3,
                letterSpacing: -0.005 * 11,
              ),
            ),
            const SizedBox(height: 1),
            Text(
              subtitle,
              style: TextStyle(
                fontFamily: 'JetBrainsMono',
                fontSize: 8.5,
                color: tokens.colors.ink3,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
```

**Section structure**:
```dart
class _DateGroup {
  final String label;   // "СЕГОДНЯ"
  final List<SessionPreview> sessions;
  const _DateGroup({required this.label, required this.sessions});
}

// in build:
...dateGroups.map((group) => Column(
  crossAxisAlignment: CrossAxisAlignment.stretch,
  children: [
    _SectionLabel(label: group.label, count: group.sessions.length),
    ...group.sessions.map((s) => _ChatRow(
      title: s.title,
      subtitle: s.timeLabel,           // mono time или date
      active: s.id == activeSessionId,
      onTap: () => onSessionTap?.call(s.id),
    )),
  ],
)),
```

Date-grouping logic (`Today` / `Yesterday` / `Previous 7 days`) — реализовать вспомогательной функцией в `nav_panel.dart` или extract в `lib/core/`. В этом bucket'е оставить inline:

```dart
List<_DateGroup> _groupSessionsByDate(
  List<SessionPreview> sessions,
  AppLocalizations l10n,
) {
  final now = DateTime.now();
  final today = DateTime(now.year, now.month, now.day);
  final yesterday = today.subtract(const Duration(days: 1));
  final lastWeek = today.subtract(const Duration(days: 7));

  final todayList = <SessionPreview>[];
  final yesterdayList = <SessionPreview>[];
  final previousList = <SessionPreview>[];

  for (final s in sessions) {
    final d = DateTime(s.createdAt.year, s.createdAt.month, s.createdAt.day);
    if (d.isAtSameMomentAs(today)) {
      todayList.add(s);
    } else if (d.isAtSameMomentAs(yesterday)) {
      yesterdayList.add(s);
    } else if (d.isAfter(lastWeek)) {
      previousList.add(s);
    }
  }

  return [
    if (todayList.isNotEmpty) _DateGroup(label: l10n.dateToday, sessions: todayList),
    if (yesterdayList.isNotEmpty) _DateGroup(label: l10n.dateYesterday, sessions: yesterdayList),
    if (previousList.isNotEmpty) _DateGroup(label: l10n.datePrevious7, sessions: previousList),
  ];
}
```

`SessionPreview` — простая модель:
```dart
class SessionPreview {
  final String id;
  final String title;
  final String timeLabel;      // "9:41" или "12 ноя"
  final DateTime createdAt;
  const SessionPreview({...});
}
```

Расширить `NavPanel` ctor — `sessions: List<SessionPreview>` вместо `List<Map<String, String>>`.

**ARB keys**:
- `dateToday` = "СЕГОДНЯ" / "TODAY"
- `dateYesterday` = "ВЧЕРА" / "YESTERDAY"
- `datePrevious7` = "ПРЕДЫДУЩИЕ 7 ДНЕЙ" / "PREVIOUS 7 DAYS"

### 4.8 — Apps section icons (MEDIUM)

**HTML canon**: Memory icon = `#i-mem` (head silhouette, `room.html:473`), не heart.

Если `KaiIconName.profile` или `head` существует — использовать. Иначе:
1. Извлечь SVG path `<circle cx=12 cy=8 r=4/><path d=M4 20c0-4 4-7 8-7s8 3 8 7/>` в `assets/icons/memory.svg`.
2. Добавить `KaiIconName.memory` в enum.
3. Использовать в `_AppsSection`:
   ```dart
   const NavItem(label: l10n.memoryAppLabel, icon: KaiIconName.memory, ...)
   ```

(Если bucket'у разрешено создавать новые иконки — выполнить. Если SVG manipulation вне scope — оставить TODO с явной ссылкой.)

### 4.9 — Account anchor (HIGH)

**HTML canon** (`room.html:301-313`):
```css
.panel .account {
  border-top: 1px solid var(--line);
  padding: 9px 12px;
  display: grid; grid-template-columns: 24px 1fr 11px; gap: 8px;
  align-items: center;
}
.panel .account .av {
  width: 24px; height: 24px; border-radius: 50%;
  background: var(--tide-gradient);                  /* tide!  */
  display: flex; align-items: center; justify-content: center;
  color: white; font-size: 9px; font-weight: 700;    /* initial letter */
}
.panel .account .n { font-size: 11px; color: var(--ink-1); font-weight: 500; letter-spacing: -0.005em; }
.panel .account .plan { font-size: 8.5px; color: var(--ink-3); font-family: var(--font-mono); text-transform: uppercase; letter-spacing: 0.06em; }
.panel .account svg { color: var(--ink-3); }       /* chev */
```

**Текущая реализация**: 32×32 surface-2 + KaiIcon person + 16px font + accent color для plan + нет chev.

**Фикс**:
```dart
class _AccountAnchor extends StatelessWidget {
  const _AccountAnchor({
    required this.tokens,
    required this.initial,
    required this.name,
    required this.plan,
    this.onTap,
  });

  // ...

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          border: Border(top: BorderSide(color: tokens.colors.line, width: 1)),
        ),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 9),
        child: Row(
          children: [
            // Tide-gradient avatar 24×24 with initial
            Container(
              width: 24,
              height: 24,
              decoration: const BoxDecoration(
                gradient: KaiTide.gradient,
                shape: BoxShape.circle,
              ),
              child: Center(
                child: Text(
                  initial,                          // "A" или "Г" — первая буква имени
                  style: const TextStyle(
                    fontFamily: 'Manrope',
                    color: Colors.white,
                    fontSize: 9,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    name,
                    style: TextStyle(
                      fontFamily: 'Manrope',
                      fontSize: 11,
                      fontWeight: FontWeight.w500,
                      color: tokens.colors.ink1,
                      letterSpacing: -0.005 * 11,
                    ),
                  ),
                  Text(
                    plan.toUpperCase(),
                    style: TextStyle(
                      fontFamily: 'JetBrainsMono',
                      fontSize: 8.5,
                      color: tokens.colors.ink3,
                      letterSpacing: 0.06 * 8.5,
                    ),
                  ),
                ],
              ),
            ),
            KaiIcon(KaiIconName.chev, size: 11, color: tokens.colors.ink3),
          ],
        ),
      ),
    );
  }
}
```

Использование в `NavPanel`:
```dart
_AccountAnchor(
  tokens: tokens,
  initial: accountInitial,        // computed: name.isNotEmpty ? name[0].toUpperCase() : 'A'
  name: accountName,              // "Anonymous" or session-derived
  plan: accountPlan,              // "Free"
  onTap: onAccountTap,
),
```

`KaiIconName.chev` (chevron) должен существовать в enum — если нет, добавить.

### 4.10 — NavItem padding adjustment (MEDIUM)

**Текущая реализация** (`nav_item.dart:51-54`): `EdgeInsets.symmetric(horizontal: KaiSpace.s3 = 12, vertical: KaiSpace.s2 + 2 = 10)`. Используется только в `_AppsSection` (после фикса section labels & chat rows).

**HTML canon** для `.folder-row` / `.app-row`: `padding: 7px 14px`.

**Фикс**: `EdgeInsets.symmetric(horizontal: 14, vertical: 7)`. Font также 11px вместо 16, icon 14 вместо default 24.

```dart
Padding(
  padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 7),
  child: Row(
    children: [
      if (icon != null) ...[
        KaiIcon(icon!, size: 14, color: iconColor),
        const SizedBox(width: 9),
      ],
      Expanded(
        child: Text(
          label,
          style: TextStyle(
            fontFamily: 'Manrope',
            fontSize: 11,
            fontWeight: FontWeight.w500,
            color: labelColor,
            letterSpacing: -0.005 * 11,
          ),
        ),
      ),
      ...
    ],
  ),
),
```

⚠️ Поменять public API `NavItem` нельзя без обновления Bucket A (там может быть использование). Решение — оставить `NavItem` сигнатуру, изменить внутренности.

---

## 5 · Tests to update / add

### 5.1 — `nav_panel_test.dart`

- Golden test: NavPanel с pin-trip + 2 trips + 3 date groups + 2 apps + account.
- Golden test: empty state (no pin, no trips, no sessions) → centered "Нет чатов".
- Widget test: tap on chat-row → `onSessionTap(id)` fires.
- Widget test: tap on folder-row → `onTripTap(id)` fires.
- Widget test: account tap → `onAccountTap()` fires.
- Dark mode parity test.

### 5.2 — `nav_item_test.dart`

- Golden: NavItem(active=true) → accent-wash + 2px accent border + accent label.
- Golden: NavItem(active=false) → transparent + ink-2 icon.

---

## 6 · Acceptance criteria

1. NavPanel визуально совпадает с `room.html § f03 .panel` при сравнении side-by-side.
2. Pin-trip widget виден когда `pinnedTrip != null`.
3. Trips section показывает folder-rows с count badge.
4. Sessions сгруппированы по СЕГОДНЯ / ВЧЕРА / ПРЕДЫДУЩИЕ 7 ДНЕЙ.
5. Top bar: close left + Kai центрирован 14px + 28px spacer right.
6. Search box radius 9 + mono 11 + ink-3.
7. Account avatar = 24×24 tide-gradient + initial letter.
8. Section labels = mono 8.5 + optional count badge.
9. `grep "Color(0xFF" lib/design_system/organisms/nav_panel.dart` → 0.
10. `grep "Color(0xFF" lib/design_system/molecules/nav_item.dart` → 0.
11. Все hardcoded RU strings (`'Новый чат'`, `'Поиск'`, `'ЧАТЫ'`, `'Память'`, `'Настройки'`, `'Anonymous'`, `'Free'`, `'Нет чатов'`) мигрированы в ARB.
12. `flutter test` зелёный + `flutter analyze` zero warnings.

---

## 7 · Out of scope

- **ChatList frames** — Bucket A.
- **ComposeIsland** — Bucket C.
- **AlertCard / Edge** — Bucket D.
- **Real session storage integration** — `NavPanel` принимает данные через ctor; реальная Hive-связка в Phase 5/6 (вне этих бакетов).
- **Add new icons (folder, memory)** — если SVG-extraction trivial, выполнить; если нет — оставить TODO.

---

## 8 · Commands

```bash
flutter test test/design_system/organisms/nav_panel_test.dart
flutter test test/design_system/molecules/nav_item_test.dart
flutter test test/design_system/organisms/nav_panel_test.dart --update-goldens
flutter analyze
flutter gen-l10n
```

---

## 9 · Commit message template

```
[bucket-b] NavPanel: pin-trip + trips + date-grouped recents, top-bar center, account tide-avatar

- C3: implement pinned trip card with tide-gradient initial + accent-wash gradient bg
- C3: implement trips folder section with mono count badges
- C3: implement date-grouped recent chats (today/yesterday/previous-7) with section labels
- HIGH: top bar — Kai centered at 14px (was 24px right-aligned)
- HIGH: search box radius 9px + mono 11px + ink-3 (was pill + 16px body + ink-4)
- HIGH: section labels — mono 8.5px ink-3 with optional count badge (was sans 12px ink-4)
- HIGH: account anchor — 24×24 tide-gradient avatar with initial letter + chev (was 32×32 surface-2 person icon)
- MEDIUM: NavItem padding adjusted to 14×7, font 11px sans, icon size 14

l10n:
- newChat, search, tripsLabel, dateToday, dateYesterday, datePrevious7,
  memoryAppLabel, settingsAppLabel, accountAnonymous, accountFreePlan

Tests:
- nav_panel_test goldens for empty + populated + active session state (light + dark)
- nav_item_test active/inactive goldens
```
