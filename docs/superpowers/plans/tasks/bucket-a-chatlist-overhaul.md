# Bucket A — ChatList overhaul (pixel-perfect 6 frames)

**Date**: 2026-05-27
**Branch**: `claude/hungry-lamport-e41998`
**Severity coverage**: 4 CRITICAL + 8 HIGH + 5 MEDIUM
**Estimated effort**: 6–10 hours
**Dependency**: Bucket C должен быть готов до начала (нужна `KaiButton.iconTransparent` variant — но в этом bucket'е она не критична, есть workaround)
**Source review**: `docs/superpowers/handoffs/2026-05-27-design-system-review.md` + master plan

---

## 1 · Goal

Привести `ChatList` (все 6 frames) и `KaiBubble` к pixel-perfect соответствию с `new-design/room.html § f01..f06`. Конкретно — добавить partial Kai streaming, error embedding в kai-b, .who row с tide-glyph, SourceCard integration, фикс empty suggestion chips, убрать chrome-hardcode цвета.

---

## 2 · Files to modify

| Файл | Что меняется |
|---|---|
| `lib/design_system/organisms/chat_list.dart` | Полная переработка `_EmptyFrame` (suggestion chip структура), `_LiveFrame` (day header + sourceCard hook), `_StreamingFrame` (partial Kai bubble + cursor), `_ErrorFrame` (embed в kai-b). Замена hardcode `Color(0xFFC44A3C)` на token. |
| `lib/design_system/atoms/kai_bubble.dart` | Добавить `.who` row с tide-glyph для `KaiBubble.kai`. Опционально новая factory `KaiBubble.kaiResponse(...)` с source card hook. Фикс radius user bubble 16-16-4-16. |
| `lib/design_system/molecules/source_card.dart` | Привести структуру к `room.html § .src-card` каноном (favicon + url-mono + snippet + ok-checkmark + expand-hint). Минимально — обновить fonts/sizes. |

---

## 3 · HTML canon refs (читать перед началом)

Все пути абсолютные. Открыть и держать рядом во время работы:

- `E:/startup/kai-app/new-design/room.html` — line 88-403 для всех 6 frames
- `E:/startup/kai-app/new-design/components.html` — line 54-95 (bubble user/kai/system)
- `E:/startup/kai-app/new-design/colors_and_type.css` — токены

Конкретные line-spans в room.html:
- **Frame 01 Empty**: lines 88-135
- **Frame 02 Live**: lines 137-197
- **Frame 03 Panel**: lines 199-313 (Bucket B уже работает с NavPanel — здесь Bucket A только видит dimmed `_LiveFrame`)
- **Frame 04 Compose sheet**: lines 315-353
- **Frame 05 Streaming**: lines 355-382
- **Frame 06 Error**: lines 384-403

---

## 4 · Detailed changes

### 4.1 — D1 hardcode fix (CRITICAL — 1 минута, обязательно)

**Файл**: `chat_list.dart:331,341`

**Текущий код**:
```dart
decoration: BoxDecoration(
  color: tokens.colors.negativeWash,        // line 330 — ОК
  borderRadius: KaiRadius.br3,
),
// ...
const KaiIcon(
  KaiIconName.alert,
  size: 18,
  color: Color(0xFFC44A3C),                  // line 341 — ❌ HARDCODE
),
```

**После фикса**: `color: tokens.colors.negative` (использует токен, dark mode становится корректным).

Также проверить, нет ли других hardcode `Color(0xFF...)` в файле — `grep "Color(0xFF" lib/design_system/organisms/chat_list.dart`. Должно быть 0 совпадений после фикса.

### 4.2 — `_EmptyFrame` suggestion chips (HIGH)

**Файл**: `chat_list.dart:125-209`

**HTML canon** (`room.html:102-115`):
```css
.f01 .suggest { display: flex; flex-direction: column; gap: 8px; margin-top: 8px; }
.f01 .sugg {
  background: var(--surface-2);          /* НЕ transparent */
  border: 1px solid var(--line);
  border-radius: 12px;                   /* НЕ pill (999) */
  padding: 11px 14px;                    /* vertical:11, horizontal:14 */
  display: flex; flex-direction: column;
  gap: 1px;
  text-align: left;                      /* НЕ centered */
}
.f01 .sugg .q { font: 500 13px var(--font-sans); color: var(--ink-1); letter-spacing: -0.005em; }
.f01 .sugg .hint { font: 400 11px var(--font-mono); color: var(--ink-3); }
```

Текущая реализация `_SuggestionChip` (`chat_list.dart:185-209`):
- `BorderRadius.brPill` → должно быть кастомный `BorderRadius.all(Radius.circular(12))` или новый токен `r2` (=10) близкий.
- `Colors.transparent` background → должно быть `c.surface2`
- Одна строка `KaiType.small(label)` → должно быть Column с 2 строки: `.q` (13 sans 500) + `.hint` (11 mono 400 ink3)
- `EdgeInsets.symmetric(horizontal: 16, vertical: 8)` → должно быть `EdgeInsets.symmetric(horizontal: 14, vertical: 11)`
- `CrossAxisAlignment` parent — должно гарантировать `start` (left-align)

**Margin-top suggest section**: текущий `SizedBox(height: KaiSpace.s5 + 3)` = 23 (`chat_list.dart:167`) → должен быть `SizedBox(height: 8)` (`KaiSpace.s2`).

**Изменить сигнатуру** `_SuggestionChip`:
```dart
class _SuggestionChip extends StatelessWidget {
  const _SuggestionChip({required this.question, required this.hint});
  final String question;
  final String hint;
  // ...
}
```

Обновить `_EmptyFrame` чтобы передавать оба значения. Добавить новые keys в `app_ru.arb` + `app_en.arb`:
- `suggestionVisaQuestion` / `suggestionVisaHint`
- `suggestionTripQuestion` / `suggestionTripHint`
- `suggestionRecommendationsQuestion` / `suggestionRecommendationsHint`

(Старые ключи `suggestionVisa` / `suggestionTrip` / `suggestionRecommendations` можно удалить, если они нигде больше не используются — `grep`.)

### 4.3 — `_LiveFrame` day header (HIGH)

**Файл**: `chat_list.dart:225-234`

**HTML canon** (`room.html:141`):
```css
.f02 .day {
  text-align: center;
  font-family: var(--font-mono);          /* MONO */
  font-size: 9px;                          /* 9px */
  color: var(--ink-3);
  text-transform: uppercase;
  letter-spacing: 0.1em;
  margin: 4px 0 0;
}
```
В JSX: `<div class="day">— today —</div>` (em-dashes по бокам).

**Текущая реализация** использует `KaiType.micro(l10n.today)` = sans 12px ink4. Нужно:
1. Создать новый TextStyle через `KaiType.mono(...)` или inline `TextStyle(fontFamily: 'JetBrainsMono', fontSize: 9, ...)`.
2. Обернуть `l10n.today` em-dashes: `'— ${l10n.today} —'` либо обновить ARB ключ на готовую строку `'— today —'` / `'— сегодня —'`.
3. Color: `tokens.colors.ink3` (не ink4).
4. Padding/margin: `EdgeInsets.only(top: 4)` вместо `EdgeInsets.symmetric(vertical: KaiSpace.s2)` (=8).

### 4.4 — `_LiveFrame` + `KaiBubble.kai` integration: .who row + SourceCard (CRITICAL C6 + HIGH H1)

**HTML canon** (`room.html:150-186`):

Структура `.kai-b`:
```html
<div class="kai-b">
  <span class="who">kai</span>                <!-- mono 9px ink3 uppercase + tide-glyph 12×3px before -->
  <div class="txt">…ответ с <span class="cite">[1]</span> citations…</div>
  <div class="src-card">                       <!-- molecule -->
    <div class="h"><span class="fav"></span>visa.go.jp · официальный<span class="ok">✓ fresh</span></div>
    <div class="t">Сбор за визу — ¥3,000 · 4 дня</div>
    <div class="s">Выдержка из источника…</div>
    <div class="expand-hint">tap to expand ↓</div>
  </div>
  <div class="conf high">high confidence</div>  <!-- LOW — можно отложить, не в v1 spec -->
</div>
```

Нужно:

**Step 1**: Добавить в `kai_bubble.dart` метод `KaiBubble.kai(...)` поддерживающий .who row. Структура (после изменений):

```dart
KaiBubble.kai(
  String content, {
  List<Source>? sources,          // если не null — рендерится SourceCard под ответом
  bool showWhoLabel = true,       // .who row с tide-glyph
  Key? key,
})
```

`.who` row структура:
- `Row(crossAxisAlignment: CrossAxisAlignment.center, children: [TideGlyph(12, 3), SizedBox(6), Text('kai', mono 9 ink3 uppercase letter-spacing 0.08em)])`
- Виджет `TideGlyph` — Container 12×3 + `decoration: BoxDecoration(gradient: KaiTide.gradient, borderRadius: KaiRadius.brPill)`.
- Если позже потребуется ephemeral animation (streaming "тёк tide-pill") — extending `TideGlyph` принимает `animated: bool` параметр; в этом bucket'е делаем static.

**Step 2**: column gap между .who и .txt = 5px (`gap: 5px` в HTML `.kai-b`).

**Step 3**: `.txt` font — `13.5px line-height: 1.5 ink1 letter-spacing -0.005em`. Внутри MarkdownBody — придётся передать `styleSheet: MarkdownStyleSheet(p: TextStyle(...))`. Citations `[1]` рендерить inline accent через regex (опционально, можно в v1.1).

**Step 4**: Если `sources != null`, рендерить SourceCard под .txt с `margin-top: 3px`.

**SourceCard** обновить структуру (`source_card.dart`) на:
```
Column(
  children: [
    Row(.h: Favicon 10x10 r3 tide-2 + url 9px mono ink3 + ok 9px mono positive),
    Text('.t' 11.5px 500 ink1),
    Text('.s' 10px ink3 line 1.4),
    Text('.expand-hint' 9px mono accent uppercase),
  ],
)
```
Bg `surface-2`, radius 10, padding 8×10, column gap 3.

**Step 5**: Wire SourceCard в `_LiveFrame` `chat_list.dart:240-260`. Когда `msg['sources'] != null`, передать в `KaiBubble.kai(sources: ...)`.

Mock-data для теста: каждое kai message получает `sources: [Source(url: 'visa.go.jp/...', title: '...', snippet: '...', fresh: true)]`.

**Step 6**: Обновить тесты `kai_bubble_test.dart` — golden для `KaiBubble.kai` с sources и без.

### 4.5 — KaiBubble.user (MEDIUM)

**Файл**: `kai_bubble.dart:43-72`

**Текущий код**:
```dart
borderRadius: BorderRadius.only(
  topLeft: const Radius.circular(KaiRadius.r4),       // 20
  topRight: const Radius.circular(KaiRadius.r4),      // 20
  bottomLeft: const Radius.circular(KaiRadius.r4),    // 20
  bottomRight: const Radius.circular(4),
),
```

**HTML canon** (`room.html:146`): `border-radius: 16px 16px 4px 16px;` (top-left, top-right, bottom-right=4, bottom-left=16).

Изменить:
```dart
borderRadius: const BorderRadius.only(
  topLeft: Radius.circular(16),
  topRight: Radius.circular(16),
  bottomLeft: Radius.circular(16),
  bottomRight: Radius.circular(4),
),
```

(Альтернатива — добавить токен `KaiRadius.r3b = 16` если хочется через токен. Поскольку 16 не существует в текущей шкале r1=6, r2=10, r3=14, r4=20, r5=28 — оставить hardcoded inline.)

**Font** user bubble: HTML `.user-b { font-size: 13px; line-height: 1.45; letter-spacing: -0.005em; }`. Сейчас вероятно используется `KaiType.body` = 16. Создать или использовать `KaiType.small(fontSize: 13, height: 1.45, letterSpacing: 13 * -0.005)`. **Padding**: `9px 13px` (sans top/bottom 9, sides 13).

### 4.6 — `_StreamingFrame` (CRITICAL C1)

**Файл**: `chat_list.dart:265-303`

**Полное переписывание frame**. HTML canon (`room.html:355-382`):

```html
<div class="kai-b">
  <span class="who">
    <!-- ::before — animated tide-gradient pill 10→22px width, height 3px, animation 1.6s -->
    kai <span class="st">думаю</span>
  </span>
  <div class="stream-txt">
    JR Pass на 14 дней стоит ¥50,000 [1]. Подача — в первые дни в Японии после прибытия…
    <!-- ::after — blinking cursor 2×14px, animation 0.9s steps(1) infinite -->
  </div>
</div>
```

Реализация:

```dart
class _StreamingFrame extends StatelessWidget {
  const _StreamingFrame({
    required this.messages,
    required this.partialContent,   // string — текущая partial Kai response
    required this.tideBarController,
    required this.cursorController,
  });

  final List<Map<String, dynamic>> messages;
  final String partialContent;
  final AnimationController tideBarController;
  final AnimationController cursorController;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // Day header (если есть messages — копируется из _LiveFrame logic)
        if (messages.isNotEmpty) Expanded(child: _LiveFrame(messages: messages)),
        // Streaming Kai bubble — внутри потока сообщений
        _StreamingKaiBubble(
          partialContent: partialContent,
          tideBarController: tideBarController,
          cursorController: cursorController,
        ),
      ],
    );
  }
}
```

`_StreamingKaiBubble` — column с:
1. `_AnimatedTideBar` (10→22px width, height 3px, tide-gradient, 1.6s ease-in-out reverse loop)
2. `Text('kai', mono 9 ink3 uppercase)`
3. partialContent + blinking cursor (через ValueListenableBuilder на cursorController)

Cursor: 2×14px Container с `tokens.colors.ink1` bg, opacity 0/1 через blink controller (500ms steps animation).

**Animation controllers** — поменять initState:
```dart
_tideBarController = AnimationController(
  vsync: this,
  duration: const Duration(milliseconds: 1600),   // канон 1.6s
)..repeat(reverse: true);

_cursorController = AnimationController(
  vsync: this,
  duration: const Duration(milliseconds: 900),
)..repeat();    // steps(1) → linear toggle
```

**API change**: `ChatList` ctor должен принять `partialContent: String?` — null для не-streaming frames. Wire в `RoomState.streamingPartial` (это уже должно быть в Phase 5/6).

Если `RoomState` пока не имеет partial — добавить TODO + mock в showcase.

### 4.7 — `_ErrorFrame` (CRITICAL C2)

**Файл**: `chat_list.dart:308-362`

**HTML canon** (`room.html:384-403`):

```html
<div class="kai-b">
  <span class="who">kai</span>             <!-- mono 9 + tide-glyph -->
  <div class="err-bub">
    <div class="eh">
      <div class="ei">⚠</div>              <!-- 18×18 circle, rgba(196,74,60,0.12) bg, negative color -->
      <div class="et">Не удалось ответить</div>  <!-- 600 12 sans negative -->
    </div>
    <div class="eb">Возможно проблема со связью. Можно повторить или попробовать иначе.</div>
    <!-- 400 11.5 sans ink-2 line 1.45 -->
    <div class="retry-row">
      <button class="retry-btn">↻ повторить</button>   <!-- 500 10.5 sans negative -->
      <span class="retry-hint">или напишите снова</span>  <!-- 400 10 mono ink-4 -->
    </div>
  </div>
</div>
```

**Полное переписывание `_ErrorFrame`**. Структура:

```dart
class _ErrorFrame extends StatelessWidget {
  // ...
  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Expanded(child: _LiveFrame(messages: messages)),
        // Error block — внутри Kai-bubble container
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 8),
          child: Align(
            alignment: Alignment.centerLeft,
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: ...),   // 92% of parent
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // .who row
                  _TideGlyphWithLabel(label: 'kai'),
                  SizedBox(height: 5),
                  // err-bub
                  Container(
                    decoration: BoxDecoration(
                      color: tokens.colors.negativeWash,
                      borderRadius: BorderRadius.circular(14),
                      border: Border.all(
                        color: Color.fromRGBO(196, 74, 60, 0.15),
                        width: 1,
                      ),
                    ),
                    padding: const EdgeInsets.symmetric(horizontal: 13, vertical: 11),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // .eh — icon circle + title
                        Row(children: [
                          Container(
                            width: 18, height: 18,
                            decoration: BoxDecoration(
                              color: Color.fromRGBO(196, 74, 60, 0.12),
                              shape: BoxShape.circle,
                            ),
                            child: Center(
                              child: KaiIcon(
                                KaiIconName.alert,
                                size: 10,
                                color: tokens.colors.negative,    // 🟢 TOKEN, not hardcode
                              ),
                            ),
                          ),
                          SizedBox(width: 6),
                          Text(
                            l10n.errorTitle,
                            style: TextStyle(
                              fontFamily: 'Manrope',
                              fontSize: 12,
                              fontWeight: FontWeight.w600,
                              color: tokens.colors.negative,
                              letterSpacing: -0.005 * 12,
                            ),
                          ),
                        ]),
                        SizedBox(height: 7),
                        // .eb — body text
                        Text(
                          l10n.errorBody,    // 🆕 new ARB key
                          style: TextStyle(
                            fontFamily: 'Manrope',
                            fontSize: 11.5,
                            color: tokens.colors.ink2,
                            height: 1.45,
                          ),
                        ),
                        SizedBox(height: 9),    // gap 2 + retry margin-top 2 ≈ 4 ... use 9 for visual rhythm
                        // .retry-row
                        Row(children: [
                          // Custom retry button — coral-themed
                          GestureDetector(
                            onTap: onRetry,
                            child: Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 11, vertical: 5,
                              ),
                              decoration: BoxDecoration(
                                color: Colors.transparent,
                                border: Border.all(
                                  color: Color.fromRGBO(196, 74, 60, 0.25),
                                  width: 1,
                                ),
                                borderRadius: KaiRadius.brPill,
                              ),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  KaiIcon(KaiIconName.retry, size: 12, color: tokens.colors.negative),
                                  SizedBox(width: 4),
                                  Text(
                                    l10n.retry,
                                    style: TextStyle(
                                      fontFamily: 'Manrope',
                                      fontSize: 10.5,
                                      fontWeight: FontWeight.w500,
                                      color: tokens.colors.negative,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                          SizedBox(width: 8),
                          Text(
                            l10n.errorRetryHint,    // 🆕 new ARB key — "или напишите снова"
                            style: TextStyle(
                              fontFamily: 'JetBrainsMono',
                              fontSize: 10,
                              color: tokens.colors.ink4,
                            ),
                          ),
                        ]),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }
}
```

**Не используй `KaiButton.ghost`** для retry — он не coral-themed. Сделай inline custom Container.

**ARB keys to add** (`l10n/app_ru.arb` + `app_en.arb`):
- `errorTitle` = "Не удалось ответить" / "Couldn't respond"
- `errorBody` = "Возможно, проблема со связью. Можно повторить или попробовать иначе." / "Something went wrong. Try again or rephrase."
- `errorRetryHint` = "или напишите снова" / "or type a new message"
- `retry` (уже должен быть) = "повторить" / "retry"

После добавления — `flutter gen-l10n`.

### 4.8 — Empty/Live/Compose padding adjustments (MEDIUM)

`.f01 .chat`: `padding: 70px 22px 100px` (vertical 70 top, 22 horizontal, 100 bottom). Текущий код использует `EdgeInsets.symmetric(horizontal: 22, vertical: KaiSpace.s4 = 16)` → нужен asymmetric `EdgeInsets.fromLTRB(22, 70, 22, 100)`. Поскольку room screen handles top tide curve и bottom compose, обычно эти отступы делегируются `RoomScreen` (Bucket E). **В Bucket A — оставить symmetric, но убедиться, что внешний `RoomScreen` даёт правильное вертикальное пространство.** Если в showcase frame смотрится сжато — это OK, в реальном screen всё разрулится.

---

## 5 · Tests to update / add

### 5.1 — `chat_list_test.dart`

Покрыть:
- `_EmptyFrame` golden (suggestion chips as cards с question + hint mono)
- `_LiveFrame` golden (with .who row + SourceCard) — добавить `messages` с `'sources'` key в mock
- `_StreamingFrame` golden (with partial content + animated bar + cursor)
- `_ErrorFrame` golden (err-bub structure: icon-circle + title + body + retry + hint)
- `_ErrorFrame` widget test: onRetry callback fires

### 5.2 — `kai_bubble_test.dart`

- `KaiBubble.kai(content, sources: [...])` golden — с .who row + tide-glyph + SourceCard под ответом
- `KaiBubble.kai(content)` golden — без sources, только .who row
- `KaiBubble.user(content)` golden — radius 16-16-4-16, font 13px

### 5.3 — `source_card_test.dart`

- Golden с favicon + url + ok-checkmark
- Без `.expand-hint` (expand-hint hidden state)

### 5.4 — Dark mode regression

После D1 фикса — добавить golden test (light + dark) для `_ErrorFrame`. Coral icon должен меняться с `#C44A3C` → `#E66F60` между temas.

```dart
testWidgets('_ErrorFrame dark mode uses dark negative token', (tester) async {
  await tester.pumpWidget(buildTestWidget(
    themeMode: ThemeMode.dark,
    child: ChatList(frame: RoomFrame.error, messages: const []),
  ));
  await expectLater(
    find.byType(ChatList),
    matchesGoldenFile('goldens/chat_list_error_dark.png'),
  );
});
```

---

## 6 · Acceptance criteria

После завершения bucket'а:

1. `grep "Color(0xFF" lib/design_system/organisms/chat_list.dart` → 0 совпадений.
2. `grep "Color(0xFF" lib/design_system/atoms/kai_bubble.dart` → 0 совпадений.
3. Все 6 `RoomFrame` визуально соответствуют `new-design/room.html` frames при сравнении через showcase (`/_dev/organisms`).
4. `KaiBubble.kai(...)` имеет .who row с tide-glyph.
5. SourceCard рендерится под Kai-ответом когда `sources != null`.
6. Streaming frame показывает partial content + animated tide bar (1.6s) + blinking cursor (0.9s).
7. Error frame embedded в Kai-bubble container со всеми 4 элементами (.eh + .et + .eb + .retry-row).
8. `flutter test` зелёный.
9. `flutter analyze` zero warnings.
10. Golden tests updated (light + dark).

---

## 7 · Out of scope

- **NavPanel structure** (pin-trip, trips, dates) — Bucket B.
- **ComposeIsland mic** transparent fix — Bucket C.
- **AlertCard / EdgeStateBlock** — Bucket D.
- **RoomScreen tide curve positioning** — Bucket E.
- **Type tokens font-feature-settings** — Bucket F.
- **`.f02 .conf` confidence chip** — не в v1 spec scope. Оставить TODO с ссылкой на master plan.
- **Markdown citation `[1]` rendering** in accent — можно отложить до v1.1.

---

## 8 · Commands

```bash
# Тесты только этого bucket'а:
flutter test test/design_system/organisms/chat_list_test.dart
flutter test test/design_system/atoms/kai_bubble_test.dart
flutter test test/design_system/molecules/source_card_test.dart

# Обновить goldens (запускать только если визуальные изменения интенциональны):
flutter test test/design_system/organisms/chat_list_test.dart --update-goldens

# Analyze + общий test pass:
flutter analyze
flutter test

# l10n:
flutter gen-l10n
```

---

## 9 · Commit message template

```
[bucket-a] ChatList overhaul: partial bubble streaming, embedded error, .who row + SourceCard

- C1: _StreamingFrame now renders partial Kai content + 1.6s animated tide bar + 0.9s cursor blink
- C2: _ErrorFrame embedded in kai-b with icon-circle, title, body, coral-themed retry + hint
- C6: KaiBubble.kai gains .who row with tide-glyph (12×3px) + SourceCard integration when sources != null
- D1: replace hardcoded Color(0xFFC44A3C) with tokens.colors.negative (fixes dark mode parity)
- HIGH: empty suggestion chips become 2-line cards (question sans + hint mono) with surface-2 bg + 12px radius
- HIGH: day header now uses mono 9px ink-3 with em-dashes per HTML canon
- MEDIUM: KaiBubble.user radius adjusted to 16-16-4-16, font 13px / line 1.45

Tests:
- Updated chat_list_test goldens (light + dark per frame)
- Added kai_bubble dark-mode regression test
- Updated source_card golden with full canon structure
- Added new ARB keys: errorBody, errorRetryHint, suggestionXxxHint
```
