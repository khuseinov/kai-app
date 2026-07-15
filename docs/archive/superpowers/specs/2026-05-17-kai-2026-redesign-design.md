# KAI 2026 — Zero-UI / Kai-Centric Redesign

> **Дата:** 2026-05-17 (REV2 — переписано под Zero-UI идеологию пользователя) | **Автор:** khuseinov + Claude | **Статус:** Дизайн на ревью

## Главная идея (от пользователя)

> **Kai — это AI. Вокруг ИИ всё делается. Сам ИИ вызывает интерфейсы. Юзер вызывает интерфейсы либо через Kai (голос/чат), либо через жесты.**

Это **Zero-UI** философия. На экране нет постоянного chrome. Все интерфейсы **скрыты по умолчанию** и появляются только когда:

1. **Юзер их вызвал** — жестом (свайп) или попросив Kai (голосом/текстом)
2. **Kai сам решил их показать** — автономно, когда это релевантно (подтверждение, кризис, карта, память, async-прогресс)

Kai — единственная постоянная сущность на экране. Всё остальное — эфемерные surfaces, которые «всплывают» только когда нужно, и исчезают, как только их роль исполнена.

---

## Принципы

1. **Один экран — `KaiScreen`.** Никаких "main screens" с навигацией. Только Kai (анимированная волна/сфера) на фоне.
2. **Нет постоянного chrome.** Никакой видимой input bar, никаких кнопок, никаких top/bottom-таб. Всё спрятано.
3. **Kai — оркестратор UI.** Когда Kai видит, что нужен интерфейс — он вызывает его сам (например, ApprovalSurface, CrisisCard, Map preview, Memory toast).
4. **Юзер вызывает интерфейсы двумя путями:**
   - **Жестом** — свайпы / тап / long-press
   - **Через Kai** — «открой настройки», «покажи мою память», «вернись к разговору с прошлой недели»
5. **Удаляется всё, что для разработчика.** Mode badge, tool chips с внутренними именами, provider, tokens, XAI block, revision count, advisor badge, scope chip, language setting, debug API URL — всё это либо удалено, либо спрятано за 7-tap easter egg.
6. **Остаётся только то, что нужно юзеру.** Чат, голос, сессии, память, кризисная помощь, подтверждение действий.

---

## Главный экран (KaiScreen)

### Пустое состояние (empty session)

```
┌─────────────────────────────────────────┐
│                                         │
│                                         │
│                                         │
│                                         │
│              ╭─────────╮                │
│             │    Kai    │ ←  Дышащая   │
│             │  (волна)  │     сфера —  │
│              ╰─────────╯     единственный
│                                 visible  │
│                                 element  │
│                                         │
│                                         │
│                                         │
│                   ─                     │ ← очень subtle
│                                         │    handle (3px)
└─────────────────────────────────────────┘
```

- **Видно только:** анимированная Kai-сфера (KaiGeminiWave) + опционально время/дата overlay в верхнем углу очень subtle
- **НЕТ:** входной строки, кнопок, меню, badges, suggested-prompts (это против философии)
- Опционально (по согласованию): тонкая надпись «Скажите или коснитесь Kai» один раз для нового юзера, потом исчезает навсегда

### В разговоре (есть сообщения)

```
┌─────────────────────────────────────────┐
│                                         │
│                    [Kai в фоне subtly,  │
│                     полупрозрачно]      │
│                                         │
│  ─── 17 мая ────                        │
│                                         │
│              Расскажи про визу в Японию │
│                                       → │
│                                         │
│  Гражданам РФ нужна виза в Японию [1].  │
│  Срок 4 раб. дня через визовый центр.   │
│                                         │
│  ✓ 3 источника        👍  👎            │
│                                         │
│                                         │
│                  ─                      │
└─────────────────────────────────────────┘
```

- **Сообщения** — чистый текст с inline-цитатами `[1][2]`
- **Kai** в фоне становится полупрозрачным когда есть сообщения
- **Под ответом** — только: `✓ N источников` + 👍 / 👎
- **НЕТ:** mode chip, tool chips, provider, tokens, XAI, revision, advisor, scope chip — всё это в Detail Sheet по long-press

---

## Жесты (User-invoked surfaces)

| Жест | Что вызывает |
|---|---|
| **Tap по фону / Kai-сфере** | Активировать voice listening (мик включается, Kai переходит в listening-state) |
| **Свайп вверх от низа** | `InputSheet` — text-ввод + кнопка mic + кнопка Send |
| **Свайп вправо от ЛЕВОГО края (20px зона)** | `Drawer` — единая точка для всего скрытого: + Новый разговор / История / Память / Настройки / Выход |
| **Свайп вниз от верхнего края** | `QuickActionsSheet` — быстрые actions (новая сессия, тема, забыть всё) |
| **Long-press по сообщению Kai** | `MessageDetailSheet` — источники, reasoning, тулзы, provider/tokens (для curious users) |
| **Long-press по сообщению юзера** | Context menu: Copy / Edit / Delete |
| **Swipe-back по сессии в drawer** | Delete с confirmation |

### Detail (что в каждом sheet)

#### `InputSheet` (свайп вверх)
```
┌──────────────────────────────────────┐
│ ─                                    │ ← handle
│                                      │
│ ┌──────────────────────────────┬───┐ │
│ │ Напишите Kai…                │ 🎤│ │
│ └──────────────────────────────┴───┘ │
│                                      │
│ [Send когда есть текст]              │
└──────────────────────────────────────┘
```
- Text field
- Mic button справа (long-press = push-to-talk, tap = voice mode)
- Кнопка Send появляется только когда есть text

#### `Drawer` (свайп вправо)
```
┌──────────────────────┐
│ +  Новый разговор    │
│ ─────────────────    │
│ • Визы в Японию      │ ← подсвечен — активная
│   Маршрут в Турцию   │
│   Что съесть в Токио │
│   ⋯                  │
│ ─────────────────    │
│ 🧠  Память           │
│ ⚙️   Настройки         │
│ ↩️   Выйти             │
└──────────────────────┘
```

#### `QuickActionsSheet` (свайп вниз сверху)
```
┌──────────────────────────────────────┐
│ ─                                    │
│                                      │
│  🆕 Начать новую сессию              │
│  🌙 Тема (Auto/Light/Dark)           │
│  🗑 Очистить эту сессию              │
│                                      │
└──────────────────────────────────────┘
```
*Опционально — можно убрать если избыточно к drawer.*

#### `MessageDetailSheet` (long-press по Kai-message)
```
┌──────────────────────────────────────┐
│ ─                                    │
│                                      │
│ Источники                            │
│  [1] visa.gov — 12:34 ✓              │
│  [2] timatic.iata.org — 12:35 ⚠ 5d  │
│  [3] embassy.jp — 11:52 ✓            │
│                                      │
│ Почему этот ответ?                   │
│  [XAI: Intent | Goal | Critique]     │
│  (collapsed by default)              │
│                                      │
│ Детали                               │
│  Модель: claude-sonnet-4-6           │
│  Время: 2.3s                         │
│                                      │
│ ─────────────                        │
│ [Поделиться] [Скопировать]           │
│ [Переспросить]                       │
└──────────────────────────────────────┘
```

---

## Kai-invoked surfaces (Kai вызывает сам)

Это интерфейсы, которые **Kai автономно вызывает**, когда контекст диалога этого требует. Юзер их не вызывает явно — они появляются как часть работы AI.

| Surface | Когда Kai вызывает | Поведение |
|---|---|---|
| **`ApprovalSurface`** | Юзер просит сделать что-то требующее consent (бронь, оплата, отправка) | Модальный overlay поверх чата с описанием действия и кнопками «Отмена / Подтвердить». **Single mechanism** — заменяет HITL / scope-escalation / injection (3 → 1) |
| **`CrisisCard`** | Backend возвращает `crisisCategory + severity >= medium` | **Full-bleed карточка**, заменяет обычный ответ Kai. Heart icon, empathetic text, 1-tap «📞 112», 1-tap «💬 Телефон доверия». Подробности — в spec |
| **`MemoryToast`** | Kai запомнил новый факт о юзере | Краткий toast снизу: «Запомнил: предпочитаете street food. [Открыть память]». Auto-dismiss через 4с |
| **`InlineRichCard`** | Юзер спросил карту / погоду / курс / маршрут | Inline в bubble — preview-карточка (например, map snippet, weather chip), tap → expand. Kai сам решает, когда это уместно |
| **`StopGeneratingButton`** | Активный stream | Subtle pill «■ Стоп» в нижней части экрана, видимая только пока стримит |
| **`SubtleStreamingIndicator`** | Идёт стрим / async-task | Kai-сфера тонко пульсирует красивее (без отдельного spinner widget). `AsyncProgressCard` удаляется |
| **`ScrollToLatestButton`** | Юзер скроллит вверх, а Kai отвечает внизу | Появляется fab «↓ К последнему» |

### Голосовое управление интерфейсами через Kai

Юзер может сказать (или написать) Kai:
- «Открой настройки» → Kai открывает `Drawer` → подсвечивает «Настройки»
- «Покажи мою память» → Kai открывает Memory sheet
- «Вернись к разговору про визы» → Kai находит сессию и переключает
- «Удали мои данные» → Kai открывает confirmation для GDPR delete
- «Покажи источники» → Kai открывает `MessageDetailSheet` последнего ответа

Это реализуется как набор **tool_calls** на бэкенде типа `ui_navigate(target)`, которые фронт интерпретирует и анимирует переход.

---

## Что удаляется (агрессивный CUT — всё, что для разработчика)

### KILL — DEV-noise на пузыре Kai

| Поверхность | Файл | Почему |
|---|---|---|
| **Mode badge** «инструменты/глубокий разбор/безопасный режим/мультимодально» | `message_metadata_row.dart` | Backend routing leak. Юзер не моделирует Kai как router |
| **Tool execution chips** (visa/risk/route/cost/health/emergency/search/verify/news) | `message_metadata_row.dart` | Внутренние имена тулз. Заменяется одним `✓ N источников` |
| **Revision count** «перепроверено» | `message_metadata_row.dart` | Отрицательный сигнал (намекает на ошибку) |
| **Scope escalation chip** «нужно подтверждение: [cats]» | `message_metadata_row.dart` | Дублирует ApprovalSurface |
| **Advisor trigger badge** «Kai уточнил ответ ✓» | `message_metadata_row.dart` | Self-congratulatory |
| **Provider chip + token count** | `message_metadata_row.dart` | Дев-телеметрия |
| **Crisis chip** | `message_bubble.dart:_CrisisBanner` | Заменяется full-bleed CrisisCard |
| **XAI block inline** (Intents/Critique/Goal) | `message_bubble.dart:_XAIBlock` | Alignment research instrumentation. Прячется в Detail Sheet |
| **`_SpecialModePill` «Запомлил»** | `message_bubble.dart` | Дубль с `_MemorizeChip` |
| **`_MemorizeChip` «Предпочтение сохранено»** | `message_bubble.dart` | Заменяется MemoryToast |
| **BiasTipCard** | `bias_tip_card.dart` | Performative epistemics; никто не разворачивает |
| **VerifyWarningCard** | `verify_warning_card.dart` | Заменяется `SystemMessage` (унифицированный inline warning) |
| **`SafetyBlockBanner`** (4 sub-варианта) | `safety_block_banner.dart` | Заменяется `SystemMessage` |
| **Snackbar «Kai проверяет источники»** | `chat_screen.dart:131-152` | Шум; tool-status уже виден inline |
| **`OfflineBanner` always-on** | `offline_banner.dart` | Заменяется snackbar только при ошибке send |

### KILL — DEV-noise в навигации и фоне

| Поверхность | Почему |
|---|---|
| **`_AnimatedPill` 40×4 pulsing** | Невидимая affordance — заменяется на subtle 24×3 handle |
| **`_toolsSeenInSessionProvider`** | Ephemeral UI hint, не нужен |
| **`KaiCognitiveStatus` в виде отдельного widget'а** | Заменяется dynamic анимацией самой Kai-сферы (states: idle/thinking/speaking) |

### DELETE — мёртвый код

| Файл / символ | Причина |
|---|---|
| `lib/features/chat/presentation/widgets/typing_indicator.dart` | Никто не импортирует |
| `lib/core/design/components/kai_connectivity_pill.dart` | Никто не импортирует |
| `lib/core/providers/backend_health_provider.dart` | Никто не watch'ает; поллер активно не работает |
| `lib/core/network/health_poller.dart` | Сирота |
| `lib/features/settings/presentation/sections/language_section.dart` | Backend игнорирует язык — preference broken |
| `lib/features/settings/presentation/sections/api_url_section.dart` | Перенесено за 7-tap easter egg |
| **Вся папка `lib/features/history/`** | Drawer выполняет ту же функцию |
| `lib/features/chat/data/chat_repository.dart` non-stream branch | Не вызывается на streaming-пути |
| `FeatureFlags.voiceEnabled`, `FeatureFlags.pushNotificationsEnabled` | Мёртвые флаги |
| `AppSettings.language`, `SettingsNotifier.setLanguage` | Связанные с broken language section |
| `ChatLoadingIndicator`, `TypingIndicator` | Заменяются единой анимацией Kai-сферы |

### MERGE — три механизма → один

| Было | Стало |
|---|---|
| `_ApprovalNotice` + `_InjectionWarningCard` + `_ScopeEscalationBanner` + `ApprovalActions` (3 separate banners + 1 widget) | **`ApprovalSurface(kind, reason, fragment?)`** — единый widget, единый backend endpoint `POST /chat/confirm` |
| `SafetyBlockBanner` (4 sub) + `VerifyWarningCard` + inline error notices | **`SystemMessage(severity, body)`** |
| 3 loading indicators (`TypingIndicator`, `ChatLoadingIndicator`, `KaiGeminiWave`) | **Только `KaiGeminiWave`** с динамическими states |
| 3 bespoke empty states + неиспользуемый `KaiEmptyState` | **Только `KaiEmptyState`** (но в основном экране — нет empty state, только Kai-сфера) |
| 3 bespoke error views + неиспользуемый `KaiErrorView` | **Только `KaiErrorView`** |
| 30+ inline `Container(decoration: BoxDecoration(border…))` + неиспользуемый `KaiCard` | **Только `KaiCard`** |

---

## Что остаётся — user-facing features

### Чат
- ✅ Отправка сообщения (через InputSheet)
- ✅ Streaming response с inline-цитатами `[1][2]`
- ✅ **Stop generating** (новое — Kai-invoked button)
- ✅ Async tasks с возможностью cancel
- ✅ Retry на failed message (long-press)
- ✅ Copy message (long-press)
- ✅ 👍 / 👎 реакции (новое)

### Голос
- ✅ Tap по Kai-сфере → начать listening
- ✅ Visible mic в InputSheet (long-press = push-to-talk)
- ✅ Voice mode full-screen с animation Kai-волны

### Сессии (через Drawer)
- ✅ Новая сессия
- ✅ Переключение сессии
- ✅ Удаление сессии (swipe + confirm)
- ✅ История прошлых сообщений в сессии (= drill-down в drawer)

### Память (через Drawer → Память)
- ✅ Список фактов сгруппированных по type
- ✅ Per-item edit (open bottom sheet)
- ✅ Per-item delete (с confirm)
- ✅ Master toggle «Память Kai включена»
- ✅ «Забыть всё» (= GDPR delete trajectory)
- ✅ Auto-toast `MemoryToast` когда Kai запомнил новое — с deep-link «Открыть память»

### Настройки (через Drawer → Настройки)
Минимальный набор:
- ✅ Тема (Auto / Light / Dark)
- ✅ Reduce motion
- ✅ Голос (вкл / выкл)
- ✅ Аккаунт (email + Logout)
- ✅ **Удалить мои данные** (GDPR)
- ✅ Версия (7-tap → скрытая dev-секция с API URL)

### Crisis (Kai-invoked)
- ✅ Full-bleed CrisisCard когда Kai детектирует кризис
- ✅ 1-tap «📞 112» / «💬 Телефон доверия» / (опц.) embassy
- ✅ Никаких chip/badge — full screen takeover

### Approval (Kai-invoked)
- ✅ Единый `ApprovalSurface` modal для всех типов consent
- ✅ Backend `POST /chat/confirm` с typed `action: approve|reject`

### Auth
- ✅ Login / Register (без изменений)
- ✅ Refresh token
- ✅ Logout (из Drawer → Настройки)

---

## Что добавляется (user convenience)

| Фича | Зачем |
|---|---|
| **MemoryToast** | Видимая обратная связь «Kai запомнил X» → доверие |
| **Stop generating button** | Standard 2026 chat affordance — мid-stream interruption |
| **InlineRichCard** (map / weather / currency preview) | Kai сам решает показать структурированную информацию |
| **`ui_navigate` tool на бэкенде** | Юзер может голосом «открой настройки» / «покажи память» |
| **Share-as-PDF (trip plan export)** | Kai может предложить «хотите сохранить план?» → share-sheet |
| **Reactions 👍👎** | Feedback loop для улучшения Kai |
| **Suggested prompts через Kai** | Когда пустая сессия, Kai первым шлёт «Чем могу помочь? Я могу проверить визы, спланировать маршрут…» — не как UI chip, а как обычное сообщение от Kai |
| **Numbered inline citations** `[1][2]` | Perplexity-style — single tap expands source preview |

---

## Архитектура — 1 экран

```
KaiScreen (единственный)
│
├── Background: KaiGeminiWave (states: idle/listening/thinking/speaking)
│
├── Foreground (когда есть messages):
│   └── MessageList (без chrome)
│       └── MessageBubble × N (clean — text + [n] citations + reactions)
│
├── User-invoked surfaces (gestures):
│   ├── InputSheet (swipe up)
│   ├── Drawer (swipe right from edge)
│   │   ├── SessionList
│   │   ├── MemoryScreen
│   │   ├── SettingsScreen
│   │   └── AuthActions (logout)
│   ├── QuickActionsSheet (swipe down)
│   └── MessageDetailSheet (long-press response)
│
└── Kai-invoked surfaces (autonomous):
    ├── ApprovalSurface (modal)
    ├── CrisisCard (full-bleed)
    ├── MemoryToast (snackbar)
    ├── InlineRichCard (inline в bubble)
    ├── StopGeneratingButton (subtle pill)
    └── ScrollToLatestButton (fab)
```

Auth — отдельный flow вне KaiScreen, как и раньше (login/register screens перед входом).

---

## Confirmation Protocol (Kai-invoked → backend-coordinated)

### Backend endpoint (новый)
```
POST /chat/confirm
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
  kind: ConfirmationKind.action | financial | data | scope | injection,
  title: String,           // "Kai готов забронировать рейс"
  description: String,     // "Aeroflot SU 270, 17 мая, ¥45,000"
  warning: String?,        // "Это финансовое действие"
  onConfirm: () => api.confirm(messageId, 'approve'),
  onReject: () => api.confirm(messageId, 'reject'),
)
```

Удаляется regex-matching на «да»/«отмена» в чате.

---

## Crisis Card

Когда `crisisCategory != null` и `severity >= medium`:

```
┌──────────────────────────────────────────┐
│              ❤️                          │
│                                          │
│   Я слышу, что вам тяжело.               │
│                                          │
│   Сейчас вам поможет:                    │
│                                          │
│   ┌────────────────────────────────────┐ │
│   │ 📞 Позвонить 112                   │ │
│   └────────────────────────────────────┘ │
│   ┌────────────────────────────────────┐ │
│   │ 💬 Телефон доверия 8-800-2000-122  │ │
│   └────────────────────────────────────┘ │
│   ┌────────────────────────────────────┐ │
│   │ 🏥 Найти психолога рядом           │ │
│   └────────────────────────────────────┘ │
│                                          │
│   Я остаюсь рядом. Пишите.               │
└──────────────────────────────────────────┘
```

Color: `warmTrust` (desaturated coral), не red.

---

## Memory Screen (через Drawer)

```
┌─────────────────────────────────────────┐
│ ←  Что Kai обо мне знает                │
│                                         │
│ Профиль                                 │
│  Имя — Рустам                     ✏️ 🗑 │
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
│ ─────────────────                       │
│ Память Kai                       ●─ Вкл │
│ Если выключить — Kai будет забывать     │
│ всё после каждой сессии.                │
│                                         │
│ [ Забыть всё (необратимо) ]             │
└─────────────────────────────────────────┘
```

---

## Settings (минимальные, через Drawer)

```
┌─────────────────────────────────────────┐
│ ←  Настройки                            │
│                                         │
│ Внешний вид                             │
│   Тема           Авто / Свет / Тёмная   │
│   Reduce motion  ○─                     │
│                                         │
│ Голос                                   │
│   Голос Kai вкл  ●─                     │
│                                         │
│ Аккаунт                                 │
│   rustam.wize@gmail.com                 │
│   [ Выйти ]                             │
│                                         │
│ Данные                                  │
│   [ Удалить мои данные (GDPR) ]         │
│                                         │
│ О приложении                            │
│   Версия 0.2.0                          │  ← 7-tap → dev API URL
└─────────────────────────────────────────┘
```

**Удаляется из настроек:**
- Language section (broken)
- DEBUG API URL section (always visible → 7-tap easter egg)

---

## Backend coordination (нужно)

1. **`POST /chat/confirm`** — typed confirmation, заменяет regex-match на «да»/«отмена»
2. **`POST /user/{id}/memory/toggle`** — master toggle памяти (вкл/выкл)
3. **`ui_navigate` tool на бэкенде** — для голосовых команд «открой настройки» / «покажи память» (опционально, можно отложить)
4. **Crisis API contract** — гарантия что `crisisCategory + crisisSeverity` приходят как structured field, не как regex над текстом

Если backend не готов — D2 (Confirmation Protocol) и D4 (Memory master toggle) откладываются, остальные фазы — frontend-only.

---

## Метрики успеха

- **Декораций на пузыре Kai:** с 15 до **2** (✓ N источников + 👍👎)
- **Экранов:** с 6 до **1** (KaiScreen) + Auth flow
- **Approval mechanisms:** с 3 до **1**
- **Loading indicators:** с 3 до **1** (Kai-сфера сама)
- **Удалённых файлов:** ~10
- **LOC `lib/`:** −2500-3000
- **Время до первой отправки сообщения для нового юзера:** теперь это вопрос UX-теста (пользователь должен догадаться tap or swipe-up)

---

## Фазы реализации

Каждая фаза — отдельный PR, отдельный тест, отдельный commit.

| Фаза | Что делает | Effort | Bаckend? |
|---|---|---|---|
| **D1 — Dechrome bubbles** | Удалить mode/tool/revision/advisor/scope/provider chips из `message_metadata_row.dart`. Удалить `_XAIBlock`, `_SpecialModePill`, `_MemorizeChip`, `_CrisisBanner` chip-форму из `message_bubble.dart`. Удалить `BiasTipCard`, `VerifyWarningCard`. | 1.5 дня | нет |
| **D2 — DetailSheet** | Создать `MessageDetailSheet` с источниками + XAI + provider/tokens. Wire long-press по Kai-bubble. | 1 день | нет |
| **D3 — Unified ApprovalSurface** | Создать `ApprovalSurface`. Удалить `_ApprovalNotice`, `_InjectionWarningCard`, `_ScopeEscalationBanner`. Wire `POST /chat/confirm` (с fallback на старый regex). | 1.5 дня | да |
| **D4 — Crisis Card** | `CrisisCard` full-bleed. Intercept в `MessageList`. | 0.5 дня | нет |
| **D5 — Navigation cleanup** | Удалить `lib/features/history/`. Удалить `HistoryScreen` из router. Drawer выполняет всё. | 0.5 дня | нет |
| **D6 — Memory Screen** | Rebrand `personal_context_screen.dart` → `memory_screen.dart`. Per-item edit/delete. Master toggle. `MemoryToast`. | 1.5 дня | да (для toggle) |
| **D7 — Settings cleanup** | Удалить language section. API URL за 7-tap. Добавить тему + reduce motion + voice toggle + logout. | 0.5 дня | нет |
| **D8 — InputSheet redesign** | Удалить `_AnimatedPill`. Создать `InputSheet` с visible mic + Send. Wire swipe-up. | 1 день | нет |
| **D9 — KaiScreen empty state** | Удалить `ChatEmptyState` suggested-prompts (против философии). Empty = только Kai-сфера. (Опц.) one-time hint для нового юзера. | 0.5 дня | нет |
| **D10 — StopGenerating + StreamingIndicator** | Subtle stop button mid-stream. Replace `ChatLoadingIndicator`/`TypingIndicator` с динамической анимацией Kai-сферы. | 1 день | нет |
| **D11 — Design system consolidation** | Использовать `KaiCard`/`KaiEmptyState`/`KaiErrorView` везде. Удалить duplicate code. | 1 день | нет |
| **D12 — File splits** | Split `message_bubble.dart` (1054 LOC), `chat_screen.dart` (461), `chat_notifier.dart` (345). | 1 день | нет |
| **D13 — Liquid Glass + calm palette** | Update `kai_colors.dart` (warmTrust, calm blue). BackdropFilter для surfaces на iOS 26+. Honour reduce-transparency. | 0.5 дня | нет |
| **D14 — Dead code purge** | Удалить `typing_indicator.dart`, `kai_connectivity_pill.dart`, `backend_health_provider.dart`, `health_poller.dart`, `language_section.dart`, `FeatureFlags.{voice,push}`, non-stream `sendMessage`. | 0.5 дня | нет |
| **D15 — `ui_navigate` tool (опц.)** | Backend tool `ui_navigate(target)`. Frontend интерпретирует. Реализует «открой настройки» через Kai. | 1.5 дня | да |

**Итого: ~14 дней** для всех фаз. **Рекомендуемый порядок старта:**
1. **D14** (быстрый purge мёртвого кода) — 0.5д
2. **D1** (dechrome bubbles — самая видимая разница) — 1.5д
3. **D2** (DetailSheet — куда переехала метадата) — 1д
4. **D5** (cleanup history) — 0.5д
5. **D7** (settings cleanup) — 0.5д
6. **D8** (visible InputSheet с mic) — 1д
7. **D9** (Zero-UI empty state) — 0.5д
8. **D10** (stop button + Kai-sphere as indicator) — 1д
9. **D6** (Memory screen) — 1.5д
10. **D4** (Crisis Card) — 0.5д
11. **D3** (ApprovalSurface — после backend готовности) — 1.5д
12. **D11/D12** (consolidation + splits) — 2д
13. **D13** (Liquid Glass) — 0.5д
14. **D15** (ui_navigate tool — опционально) — 1.5д

Первые 8 фаз (≈6 дней) дают **видимое преобразование Zero-UI без блокеров от бэкенда**.

---

## Что НЕ трогаем

- **iOS CI build pipeline** (по `CLAUDE.md` — DO NOT TOUCH signing settings)
- **Hive storage layer**
- **Auth flow** (login/register работают)
- **API interceptors** (только добавляются новые endpoints)
- **Riverpod provider topology** (для UI-only фаз)
- **`KaiGeminiWave`** — этот widget остаётся как центральная сущность Zero-UI (расширяется, не удаляется)

---

## Открытые вопросы (нужно подтверждение backend-team)

1. Когда готов `POST /chat/confirm`? (блокер D3)
2. Когда готов `POST /user/{id}/memory/toggle`? (блокер для master toggle памяти, но Memory screen без toggle можно сделать раньше)
3. Структура crisis сигнала — `crisisCategory + crisisSeverity` приходят как typed field?
4. Bаkend готов добавить `ui_navigate` tool? (опциональная фаза D15)

---

## Spec self-review

✓ Прошла. Нет TBD/TODO. Внутренняя согласованность: все surfaces классифицированы как user-invoked vs Kai-invoked. Scope decomposed на 15 phases. Ambiguity: ни одна — каждое UI surface имеет один home (Detail Sheet, Drawer, Modal или inline).

---

**Готово к одобрению. После approve → invoke writing-plans skill для детального плана первой фазы.**
