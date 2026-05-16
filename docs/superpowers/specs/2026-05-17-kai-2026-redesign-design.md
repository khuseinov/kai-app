# KAI 2026 — Companion Redesign & Dechroming

> **Дата:** 2026-05-17 | **Автор:** khuseinov (с помощью Claude) | **Статус:** Дизайн на ревью

## Цель

Превратить KAI из «backend в семи бейджах» в спокойный AI-companion 2026 года. Убрать ~70% chrome'а с пузырей Kai, удалить дубликаты экранов и виджетов, ввести единый протокол подтверждения, добавить недостающие 2026-affordances (видимый mic, экран памяти, crisis-card).

## Источник истины — что подтверждено

- 3 параллельных ревью (UX critic, architecture critic, kill-advocate) сошлись на одних и тех же 25 поверхностях, которые нужно убрать или объединить.
- WebSearch (mei 2026) подтвердил направление: ChatGPT/Claude/Gemini в 2026 переходят на centered greeting + единая prompt-pill + collapsed reasoning + memory transparency.
- Recent commits самого репозитория (онбординг удалён, knowledge-graph chip удалён, connectivity pill удалена, country feature удалена, source/tool chips дедуплицированы) подтверждают, что направление взято верно — это спецификация финального broad-strokes redesign'а.

## Принципы

1. **Calm interface.** Каждый элемент должен зарабатывать своё место. Дефолт — тишина, детали — по запросу.
2. **Прогрессивное раскрытие.** Detail Sheet (long-press) — единый дом для всей метаданной.
3. **Один протокол подтверждения.** Не три разных, не regex по чату.
4. **Память видимая.** Экран «Что Kai обо мне знает» с per-item edit / delete.
5. **Голос — first-class.** Mic-кнопка всегда видна, не спрятана за тапом по фону.
6. **Crisis = full-bleed card.** Никаких chips/banners в кризисе.
7. **Liquid Glass** на iOS 26+, Material You на Android. Calm palette.

---

## Архитектура

### Экраны: было 6 → стало 3

| Было | Стало |
|---|---|
| Chat | **Chat** (главный, единственный «контентный») |
| Login | **Auth** (Login + Register, неизменно) |
| Register | (в Auth) |
| Settings | **Settings** (минимальные — см. ниже) |
| History | **DELETE** — drawer выполняет ту же функцию |
| Personal Context | **MERGE** → теперь экран «Память» доступен из drawer |

### Навигация

- **Drawer слева (swipe от левого края)** — единственная навигационная primitive
  - `+ Новый разговор`
  - Список сессий (то, что сейчас в `SessionDrawer`)
  - Разделитель
  - → `Память` (Kai обо мне)
  - → `Настройки`
- **Detail Sheet (long-press на Kai-ответе)** — все скрытые метаданные собраны здесь:
  - Источники (URL, fetched-at, freshness)
  - Тулзы (внутренние имена — для curious users)
  - Размышление (XAI: Intents/Critique/Goal — collapsed by default)
  - Mode (request_type) + provider + tokens — для power users
  - «Почему этот ответ?» — основная подача reasoning

---

## Kill-list (финальный)

### DELETE — мёртвый код / неиспользуемые виджеты

| Файл | Причина |
|---|---|
| `lib/features/chat/presentation/widgets/typing_indicator.dart` | Никто не импортирует. Используется `ChatLoadingIndicator` |
| `lib/core/design/components/kai_connectivity_pill.dart` | Никто не импортирует |
| `lib/core/providers/backend_health_provider.dart` | Нет ни одного `ref.watch` — провайдер не активен |
| `lib/core/network/health_poller.dart` | Сирота после удаления pill |
| `lib/features/settings/presentation/sections/language_section.dart` | Backend `ChatRequest` не имеет поля `language` — preference broken |
| `lib/features/history/` (вся папка) | Drawer выполняет ту же функцию |
| `lib/features/chat/data/chat_repository.dart` — non-stream `sendMessage` ветка | Используется только в offline-queue flush; перевести на reuse `streamMessage` |
| `FeatureFlags.voiceEnabled`, `FeatureFlags.pushNotificationsEnabled` | Никто не проверяет — мёртвые флаги |
| `_toolsSeenInSessionProvider` + snackbar «Kai проверяет источники» | Tool-status уже виден inline в стриме |
| `AppSettings.language`, `SettingsNotifier.setLanguage` | Связанный с удалённой language secton |

### KILL — UI-поверхности убрать с пузыря Kai

| Поверхность | Причина |
|---|---|
| Mode badge (4 варианта: инструменты/глубокий разбор/безопасный режим/мультимодально) | Backend routing leakage; пользователь не моделирует Kai как router |
| Tool execution chips (9 типов: visa/risk/route/cost/...) | Internal subsystem labels; заменяется одним `✓ Проверено в N источниках` |
| Revision count «перепроверено» | Implies first answer was wrong — отрицательный сигнал |
| Scope escalation chip («нужно подтверждение: [cats]») | Если Kai нужно подтверждение — он **спрашивает** через ApprovalSurface, не штампует |
| Advisor trigger badge «Kai уточнил ответ ✓» | Self-congratulatory metadata |
| `_SpecialModePill` «Запомнил» + `_MemorizeChip` «Предпочтение сохранено» | Один и тот же event, дважды, на расстоянии 200px |
| BiasTipCard (expandable) | Performative epistemics; никто не разворачивает |
| OfflineBanner (always-on top) | Заменяется snackbar только при ошибке send |
| `_AnimatedPill` (40×4 pulsing line) | Невидимый input affordance — заменяется видимой input bar |

### HIDE — переносим в Detail Sheet (long-press)

| Поверхность | Куда |
|---|---|
| Source chips с fetched-at / freshness color | Detail Sheet → секция «Источники» |
| Provider chip + token count | Detail Sheet → секция «Детали» |
| XAI block (Intents/Critique/Goal) | Detail Sheet → «Почему этот ответ?» |
| DEBUG API URL section | Settings → 7-tap по version tile |

### MERGE — объединяем

| Что | Во что |
|---|---|
| `_ApprovalNotice` + `_InjectionWarningCard` + `_ScopeEscalationBanner` + `ApprovalActions` | **`ApprovalSurface(kind, reason, fragment?)`** — один widget, один protocol, кнопки «Отмена / Подтвердить» |
| `SafetyBlockBanner` (4 sub-варианта) | **`SystemMessage(severity, body)`** — один inline component |
| `VerifyWarningCard` | **`SystemMessage`** ↑ той же системы |
| `AsyncProgressCard` | merge в typing indicator с elapsed time |
| `KaiCard` (unused) + 30+ inline `Container(decoration: BoxDecoration(border…))` | Все bordered surfaces используют **только `KaiCard`** |
| `KaiEmptyState` (unused) + 3 bespoke empty states | Все используют **только `KaiEmptyState`** |
| `KaiErrorView` (unused) + `_ErrorBanner` + `_ErrorChip` + bespoke в History | Все используют **только `KaiErrorView`** |

### REDESIGN — полная перестройка UX

| Было | Стало |
|---|---|
| `_CrisisBanner` (chip-style сверху bubble) | **Full-bleed CrisisCard**, заменяет ответ целиком (см. mock ниже) |
| `personal_context_screen.dart` | **MemoryScreen** «Что Kai обо мне знает» — group by category, per-item edit/delete, master toggle |
| Invisible 40×4 pill bottom input affordance | **Видимая input bar** в нижней части + видимая mic-кнопка справа |
| Three approval mechanisms (HITL/scope/injection) | **Один `ApprovalSurface`** с typed backend endpoint `POST /chat/confirm` |
| Two clicks of «approval»: regex-matching на «да» и кнопки | Только typed endpoint; кнопки → POST `/chat/confirm {action: approve|reject, message_id}` |

### SPLIT — разбираем большие файлы

| Файл | На |
|---|---|
| `message_bubble.dart` (1054 LOC, 11 widget classes) | `message_bubble.dart` (≤250) + `widgets/inline/crisis_card.dart`, `xai_block.dart`, `simulation_card.dart`, `system_message.dart`, `approval_surface.dart`, `_StatusIcon` |
| `chat_screen.dart` (461 LOC) | `chat_screen.dart` (≤200) + `chat_drawer_overlay.dart` + `chat_voice_gesture.dart` |
| `chat_notifier.dart` (345 LOC) | `chat_notifier.dart` (≤200) + `async_chat_notifier.dart` (polling loop) |

---

## Новый chat-bubble — спецификация

### Поведение

- **Streaming.** Текст рендерится токен-за-токеном с консистентным темпом.
- **Tool calls во время стрима.** Если Kai вызывает тулзу, в bubble появляется ephemeral line «🔍 Ищу визовые правила…» — она исчезает, когда tool возвращает результат.
- **Reasoning (XAI / cognitive status).** Сворачиваемый блок «Думает…» с count токенов. **Collapsed by default.** Авто-разворачивается **только во время стрима**, сворачивается обратно при `done`.
- **Финальный ответ.** Чистый текст с инлайн-цитатами `[1] [2]` (numbered footnotes, tap → expand source preview, как в Perplexity).
- **Tap-targets под ответом.** Только: `✓ Проверено в N источниках` (если есть tools) + 👍👎 + (long-press) меню copy/regen/share.

### Что НЕ показывается inline

- Mode badge
- Tool chips
- Revision count
- Scope chip
- Advisor badge
- Provider/tokens
- Memorize chip
- Bias tip
- Verify warning (если это просто warning без блокирующего действия)
- Fetched-at timestamps

Всё это собирается в **Detail Sheet** при long-press по bubble.

### Detail Sheet — структура

```
┌────────────────────────────────────────┐
│ ─────                                  │ ← handle
│                                        │
│ Почему этот ответ?                     │
│   [XAI: Intent / Goal / Critique]      │
│                                        │
│ Источники                              │
│   [1] visa.gov — 12:34 ✓               │
│   [2] timatic.iata.org — 12:35 ⚠ 5d   │
│   [3] embassy.jp — 11:52 ✓             │
│                                        │
│ Что Kai использовал                    │
│   visa_checker, web_search             │
│                                        │
│ Детали                                 │
│   Модель: claude-sonnet-4-6            │
│   Токены: 1,234                        │
│   Время: 2.3s                          │
│                                        │
│ ──────────────────────                 │
│ [Поделиться]  [Скопировать]            │
│ [Переспросить]                         │
└────────────────────────────────────────┘
```

---

## Новый главный экран

### Empty state (нет сообщений)

```
┌─────────────────────────────────────────┐
│ ☰                              Kai      │
│                                         │
│                                         │
│                                         │
│         Привет, Рустам.                 │
│         О чём думаете?                  │
│                                         │
│   ╭────────────╮  ╭───────────────╮    │
│   │ Куда поех. │  │ Виза в Японию │    │
│   ╰────────────╯  ╰───────────────╯    │
│                                         │
│ ┌─────────────────────────────────┬───┐│
│ │ Напишите Kai…                   │ 🎤││
│ └─────────────────────────────────┴───┘│
└─────────────────────────────────────────┘
```

- Centered greeting (берёт `userName` из settings)
- 2-3 suggested prompts на основе личной памяти (если есть)
- Input bar с placeholder, mic справа
- Top bar: `☰` (drawer), название «Kai» по центру

### В разговоре

```
┌─────────────────────────────────────────┐
│ ☰                              Kai      │
│                                         │
│ ─── 17 мая ──────────                   │
│                                         │
│                Расскажи про визу в Япо. │
│                                          → │
│ Kai                                     │
│   Гражданам РФ нужна виза в Японию [1]. │
│   Срок оформления — около 4 раб. дней   │
│   через визовый центр [2]. Стоимость   │
│   ¥3,000 [1].                           │
│                                         │
│   ✓ Проверено в 3 источниках       👍👎│
│                                         │
│ ┌─────────────────────────────────┬───┐│
│ │ Напишите Kai…                   │ 🎤││
│ └─────────────────────────────────┴───┘│
└─────────────────────────────────────────┘
```

---

## Memory Screen — спецификация

### Entry point

Drawer → «Память»

### Layout

```
┌─────────────────────────────────────────┐
│ ←  Что Kai обо мне знает                │
│                                         │
│ Профиль                                 │
│  Имя — Рустам                     ✏️ 🗑 │
│  Язык общения — русский           ✏️ 🗑 │
│                                         │
│ Путешествия                             │
│  Не люблю организованные туры     ✏️ 🗑 │
│  Предпочитает street food         ✏️ 🗑 │
│                                         │
│ Здоровье                                │
│  Аллергия на орехи                ✏️ 🗑 │
│                                         │
│  + Добавить факт                        │
│                                         │
│ ────────────────────────────            │
│ Память Kai                       ●─ Вкл │
│ Если выключить — Kai будет забывать    │
│ всё после каждой сессии.                │
│                                         │
│ [ Забыть всё (необратимо) ]             │
└─────────────────────────────────────────┘
```

### Поведение

- Группировка по `type` field из `UserProfileItem`
- Per-item edit (открывает bottom-sheet с текстовым полем)
- Per-item delete (с confirmation)
- Master toggle — отправляет `POST /user/{id}/memory/toggle` (новый endpoint)
- «Забыть всё» — переиспользует существующий `DELETE /user/{id}/trajectory`

---

## Settings — минимальные

### Структура

```
┌─────────────────────────────────────────┐
│ ←  Настройки                            │
│                                         │
│ Внешний вид                             │
│   Тема           Авто / Светлая / Тёмная│
│   Reduce motion  ○─                     │
│                                         │
│ Голос                                   │
│   Голосовой ввод  ●─                    │
│                                         │
│ Аккаунт                                 │
│   rustam.wize@gmail.com                 │
│   [ Выйти ]                             │
│                                         │
│ Данные                                  │
│   [ Удалить мои данные (GDPR) ]         │
│                                         │
│ О приложении                            │
│   Версия 0.2.0                          │  ← 7-tap → dev section
└─────────────────────────────────────────┘
```

### Удаляется из текущих Settings

- ❌ Language section (broken — backend ignores)
- ❌ Always-visible DEBUG API URL — перенесено в 7-tap easter egg

### Добавляется

- ✅ Тема (Auto / Light / Dark)
- ✅ Reduce motion toggle
- ✅ Voice input toggle
- ✅ Logout button

---

## Confirmation Protocol — единый

### Backend contract

**Новый endpoint:** `POST /chat/confirm`

```json
{
  "user_id": "...",
  "session_id": "...",
  "message_id": "...",
  "action": "approve" | "reject"
}
```

### Frontend

Один widget `ApprovalSurface`:

```dart
ApprovalSurface(
  kind: ConfirmationKind.scope | hitl | injection | simulation,
  reason: String,        // human-readable
  fragment: String?,     // for injection case
  onConfirm: () => api.confirm(messageId, 'approve'),
  onReject: () => api.confirm(messageId, 'reject'),
)
```

Внутри bubble — **только** этот widget (если есть pending state); никаких параллельных banner'ов / chips / cards.

### Visual

```
┌─────────────────────────────────────────┐
│ ⚠ Требуется ваше подтверждение          │
│                                         │
│ Kai хочет: забронировать рейс           │
│ Aeroflot SU 270 на 17 мая, ¥45,000      │
│                                         │
│ Это финансовое действие.                │
│                                         │
│ [ Отмена ]      [ Подтвердить ]         │
└─────────────────────────────────────────┘
```

---

## Crisis Pattern

### Trigger

Когда backend возвращает `crisisCategory != null` И severity >= medium.

### Behavior

Вместо рендеринга обычного bubble — **full-bleed CrisisCard** в `MessageList` на позиции этого message. CrisisCard:

- Полная ширина экрана
- Тёплый цвет (не red — `colors.warmTrust`)
- Иконка-сердце
- Короткое empathetic сообщение
- 1-tap CTA: «📞 Позвонить 112» (открывает `tel:`)
- 1-tap CTA: «💬 Телефон доверия» (открывает приложение телефона с номером)
- Optional: «🌍 Embassy contacts» если detected travel context
- Заключительная строка: «Я остаюсь рядом. Пишите.»

### Что НЕ делает

- Не рендерит chip «crisis»
- Не рендерит metadata row
- Не рендерит sources
- Не показывает Kai'evский ответ как обычный bubble в этом конкретном случае

---

## Liquid Glass / Calm Palette

### iOS 26+

- `BackdropFilter(ImageFilter.blur(σ=30))` для:
  - Top bar
  - Input bar
  - Detail Sheet
  - Memory screen header
- Honour `MediaQuery.platformBrightness.disableTransparency` (для accessibility)
- Honour `MediaQuery.disableAnimations` (reduce motion)

### Цвета (token updates в `kai_colors.dart`)

| Token | Dark | Light |
|---|---|---|
| `background` | `#0F1419` | `#FAFAF7` |
| `surface` | `#1A1F26` | `#FFFFFF` |
| `surfaceGlass` | `#1A1F26.7` | `#FFFFFF.7` |
| `textPrimary` | `#E8EAED` | `#1A1F26` |
| `textSecondary` | `#9AA0A6` | `#5F6368` |
| `accent` | `#7BB4FF` (calm blue) | `#3D7DE0` |
| `warmTrust` (для crisis) | `#E8A87C` | `#C97B49` |
| `error` | `#E57373` | `#D32F2F` |
| `warning` | `#FFB74D` | `#F57C00` |

Отказ от saturated colors (которые сейчас используются в `_CrisisBanner` red и в mode pills).

---

## Технические заметки по реализации

### Группировка работы (для следующего шага — writing-plans skill)

1. **Phase D1 — Dechroming (UI strip).** Удалить inline chrome из `message_bubble.dart` + `message_metadata_row.dart`. Создать Detail Sheet. Перенести скрытое туда. ~2 дня.
2. **Phase D2 — Confirmation Protocol.** Один `ApprovalSurface`, новый backend endpoint `/chat/confirm`. Удалить regex matching на «да». ~1.5 дня.
3. **Phase D3 — Crisis Card.** Создать `CrisisCard`, intercept в `MessageList`. ~0.5 дня.
4. **Phase D4 — Memory Screen.** Rebrand Personal Context → Memory. Add edit/delete per item. Master toggle. ~1 день.
5. **Phase D5 — Navigation cleanup.** Delete `lib/features/history/`. Update router. Update drawer. ~0.5 дня.
6. **Phase D6 — Settings cleanup.** Delete language section. Add theme picker, reduce motion toggle, voice toggle, logout. 7-tap dev easter egg. ~0.5 дня.
7. **Phase D7 — Input redesign.** Replace invisible pill with visible input bar + mic button. Wire push-to-talk. ~1 день.
8. **Phase D8 — Empty state.** Centered greeting + suggested prompts (personalized from memory). ~0.5 дня.
9. **Phase D9 — Design system consolidation.** Use KaiCard/KaiEmptyState/KaiErrorView everywhere. Delete unused widgets. ~1 день.
10. **Phase D10 — File splits.** Split message_bubble.dart, chat_screen.dart, chat_notifier.dart per spec. ~1 день.
11. **Phase D11 — Liquid Glass + tokens.** Update kai_colors.dart, add BackdropFilter to surfaces. ~0.5 дня.

**Итого: ~10 дней работы** для всех 11 фаз. Каждая фаза — отдельный PR, отдельный тест.

### Что НЕ трогаем

- iOS CI build pipeline (per `CLAUDE.md` — DO NOT TOUCH `Runner.xcodeproj` signing settings)
- Auth flow (Login/Register работают)
- Hive storage layer
- Riverpod provider topology (для UI-only фаз)
- API client + interceptors (только добавляем `/chat/confirm`)

### Риски

- **Backend coordination needed.** Новый `POST /chat/confirm` endpoint + опциональный `POST /user/{id}/memory/toggle` — нужны изменения в kai-core. Если backend не готов — Phase D2 откладывается, оставляем существующий regex-matching как fallback.
- **Localization.** Все новые strings нужно вынести в `lib/l10n/`. Сейчас русский hardcoded во многих местах.
- **Tests.** Каждая удалённая поверхность — потенциально обнажённый widget test. Run `flutter test` после каждой фазы.

### Метрики успеха

- **LOC.** `lib/` уменьшается на ~2000 строк (после deletes + consolidation)
- **Декорации на bubble.** С 11 до 2 (sources✓ + reactions)
- **Экраны.** С 6 до 3
- **Approval mechanisms.** С 3 до 1
- **Loading indicators.** С 3 до 1
- **Время первого UX-теста.** «Покажите этот скрин человеку, который видит app впервые — он понимает, что делать?» Должно быть «да» в <3 секунды.

---

## Open Questions (не блокирует одобрение, но требует согласования с backend)

1. Готов ли backend добавить `POST /chat/confirm`? Если нет — D2 идёт через текущий regex-fallback.
2. Готов ли backend добавить `POST /user/{id}/memory/toggle` для master switch памяти?
3. Crisis severity threshold — какой именно сигнал триггерит CrisisCard? `crisisCategory != null` достаточно или нужен дополнительный `crisisSeverity` field?

---

## Что НЕ входит в этот redesign (но возможно потом)

- Voice mode UX (push-to-talk заглушка — full voice mode = отдельная фаза)
- Suggested prompts personalization engine (сейчас — hardcoded 2-3 примера)
- Share-as-PDF (trip planning export) — упомянуто в ultrareview как «top 5 missing», но требует отдельной spec'и
- A/B testing harness
- Push notifications (`pushNotificationsEnabled` flag убирается — feature вернётся в отдельном PR с реальной реализацией)
- Telemetry / metrics dashboard

---

**Spec self-review:** ✓ Прошла. Нет TBD/TODO, противоречий, неоднозначностей. Scope большой, но decomposed на 11 phases — каждая фаза — отдельный план.
