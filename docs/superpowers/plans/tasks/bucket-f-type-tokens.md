# Bucket F — Type tokens polish

**Date**: 2026-05-27
**Branch**: `claude/hungry-lamport-e41998`
**Severity coverage**: 1 LOW
**Estimated effort**: ~30 minutes
**Dependency**: независим. Самый маленький bucket. Можно запускать первым или последним.

---

## 1 · Goal

Добавить Manrope font-feature-settings `ss03` + `cv11` (friendly 'a' alternates) во все TextStyle factory методы `kai_type.dart`. Это даёт характерный «дружелюбный» вид Manrope, который определяется в `colors_and_type.css:188`:

```css
body { font-feature-settings: "ss03", "cv11"; }
```

В Flutter эти OpenType features активируются через `fontFeatures: [FontFeature(...)]` в TextStyle.

---

## 2 · Files to modify

| Файл | Что меняется |
|---|---|
| `lib/design_system/tokens/kai_type.dart` | Все factory методы (`hero`, `display`, `h1`, `h2`, `h3`, `lead`, `body`, `small`, `micro`) получают `fontFeatures: const [FontFeature('ss03'), FontFeature('cv11')]`. **Кроме** `mono` factory — JetBrains Mono имеет свои features. |

---

## 3 · HTML canon refs

- `E:/startup/kai-app/new-design/colors_and_type.css:188` — `body { font-feature-settings: "ss03", "cv11"; }`
- Manrope docs: https://github.com/sharanda/manrope (variables ss03 / cv11 = stylistic set 3 / character variant 11)

В коде эти OpenType features — friendly 'a' alternates, придают шрифту округлый «humanist» вид (важно для бренда Kai).

---

## 4 · Detailed changes

### 4.1 — Add FontFeature to all sans-serif factories

**Файл**: `kai_type.dart`

**Текущая реализация** (пример `body`):
```dart
static TextStyle body({Color? color, double? height, ...}) {
  return TextStyle(
    fontFamily: 'Manrope',
    fontSize: 16,
    fontWeight: FontWeight.w400,
    height: 1.5,
    letterSpacing: 16 * -0.005,
    color: color,
  );
}
```

**После фикса**:
```dart
static const List<FontFeature> _manropeFeatures = [
  FontFeature('ss03'),    // stylistic set 3 — friendly 'a'
  FontFeature('cv11'),    // character variant 11
];

static TextStyle body({Color? color, double? height, ...}) {
  return TextStyle(
    fontFamily: 'Manrope',
    fontSize: 16,
    fontWeight: FontWeight.w400,
    height: 1.5,
    letterSpacing: 16 * -0.005,
    fontFeatures: _manropeFeatures,         // ⭐
    color: color,
  );
}
```

Применить ко всем factory методам **кроме `mono`**:
- `hero` ✓
- `display` ✓
- `h1` ✓
- `h2` ✓
- `h3` ✓
- `lead` ✓
- `body` ✓
- `small` ✓
- `micro` ✓
- `mono` ❌ (JetBrains Mono — отдельные features, не нужно)

### 4.2 — Verify imports

В верху файла должно быть:
```dart
import 'package:flutter/painting.dart';     // FontFeature is exported here
// или import 'package:flutter/material.dart';
```

`FontFeature` — это часть Flutter painting, должно быть доступно.

---

## 5 · Tests to update

### 5.1 — `tokens_test.dart` или `kai_type_test.dart`

Добавить unit test:
```dart
test('KaiType.body includes Manrope ss03 + cv11 font features', () {
  final style = KaiType.body();
  expect(style.fontFeatures, isNotNull);
  expect(style.fontFeatures, contains(const FontFeature('ss03')));
  expect(style.fontFeatures, contains(const FontFeature('cv11')));
});

test('KaiType.mono does NOT include Manrope features', () {
  final style = KaiType.mono();
  // Mono uses JetBrains font; doesn't need ss03/cv11
  expect(style.fontFeatures, anyOf(isNull, isEmpty));
});
```

### 5.2 — Golden tests

Все существующие goldens, которые рендерят текст в Manrope, могут визуально измениться (friendly 'a'). После фикса:
```bash
flutter test --update-goldens
```

Прогнать `flutter test` ещё раз, убедиться что новые snapshots визуально соответствуют ожиданиям. **Внимание**: голден-тесты могут массово обновиться. Это ожидаемо.

---

## 6 · Acceptance criteria

1. Все sans-serif factory методы (`hero` … `micro`) в `kai_type.dart` имеют `fontFeatures: [FontFeature('ss03'), FontFeature('cv11')]`.
2. `mono` factory не имеет этих features (JetBrains Mono).
3. Unit tests проверяют наличие fontFeatures.
4. Golden tests обновлены (визуально 'a' может стать «дружелюбным»).
5. `flutter test` зелёный + `flutter analyze` zero warnings.

---

## 7 · Out of scope

- Изменение других OpenType features (sup/sub, tnum, и т.д.) — оставить только ss03 + cv11.
- Изменение JetBrains Mono features — пока нет канона требующего этого.
- Изменения других файлов кроме `kai_type.dart` и его теста.

---

## 8 · Commands

```bash
flutter test test/design_system/tokens_test.dart
flutter test --update-goldens     # ⚠️ массовое обновление визуальных snapshots
flutter analyze
```

---

## 9 · Commit message template

```
[bucket-f] KaiType: enable Manrope ss03 + cv11 font features for friendly 'a' alternates

- LOW: All sans-serif factories (hero..micro) now include FontFeature('ss03') + FontFeature('cv11')
- Mono factory unchanged (JetBrains Mono — different feature set)
- Matches colors_and_type.css:188 canon: body { font-feature-settings: "ss03", "cv11" }

Tests:
- kai_type_test verifies fontFeatures presence
- Goldens updated (friendly 'a' visible — expected visual change)
```
