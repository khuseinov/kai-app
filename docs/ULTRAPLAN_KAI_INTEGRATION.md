# KAI Mobile App — Ultraplan интеграции с сервисами KAI

## Context

Мобильное приложение KAI (Flutter) находится на ранней стадии разработки (Sprint 1). Бэкенд KAI-Core (Python/FastAPI) с когнитивным циклом PEOVUCARG **уже в продакшене** — работает чат, LLM-роутинг (KAI-FT → GLM-5 → DeepSeek V3), 3-слойная PII-защита, travel-инструменты (виза, маршруты, стоимость, здоровье), memory-системы (Redis/Qdrant/Neo4j). NestJS-бэкенд обеспечивает JWT-авторизацию, SSE-стриминг и фидбек.

**Цель:** Превратить мобильное приложение из скелета в полнофункционального клиента KAI-Core с чатом, сессиями, оффлайн-режимом, авторизацией и стримингом.

---

## Аудит: Критические баги в текущем коде

| # | Баг | Файл | Строка |
|---|-----|------|--------|
| 1 | `ChatRemoteSource` вызывает `_apiClient.sendMessage()` — метод НЕ существует (есть только `get<T>` и `post<T>`) | `lib/features/chat/data/chat_remote_source.dart` | :11 |
| 2 | `api_client.dart` хардкодит `baseUrl` вместо `EnvConfig` | `lib/core/api/api_client.dart` | :24 |
| 3 | `RetryInterceptor` импортирован но НЕ подключён в цепочке interceptors | `lib/core/api/api_client.dart` | :29-34 |
| 4 | `receiveTimeout: 10s` — слишком мало для когнитивного цикла KAI (может занять 30-90с) | `lib/core/api/api_client.dart` | :26 |
| 5 | `ChatRequestDto` содержит поле `client` — kai-core Pydantic `extra="forbid"` вернёт 422 | `lib/features/chat/data/dto/chat_request_dto.dart` | :12 |
| 6 | `ChatLocalSource` привязан к box `settings` вместо `chat_history`/`sessions` | `lib/features/chat/logic/chat_notifier.dart` | :83-84 |
| 7 | `ChatMessage` нет полей `sessionId` и `status` — невозможна фильтрация по сессии и отслеживание статуса | `lib/core/models/chat_message.dart` | — |
| 8 | `CircuitBreaker` существует но нигде не используется | `lib/core/api/circuit_breaker.dart` | — |
| 9 | `getMessagesForSession()` возвращает ВСЕ сообщения, не фильтрует по sessionId | `lib/features/chat/data/chat_local_source.dart` | :18-24 |

---

## Карта возможностей: KAI-Core → Mobile

| Возможность KAI-Core | Мобильный статус | Приоритет |
|---|---|---|
| POST /chat (основной чат) | Сломан (RemoteSource → несуществующий метод) | P0 |
| Метаданные ответа (confidence, model, latency, tokens) | DTO есть, UI нет | P1 |
| Travel-инструменты (виза, маршруты, стоимость, здоровье) | Не отображаются | P1 |
| GET /health | Не интегрировано | P2 |
| PII-индикатор | Поле есть, UI нет | P2 |
| Сессии и история | Модель есть, логика сломана | P0 |
| NestJS JWT Auth | Не реализовано | P1 |
| SSE стриминг (NestJS /kai/stream) | Не реализовано | P2 |
| Фидбек (NestJS /kai/feedback) | Не реализовано | P2 |
| Оффлайн-очередь | Box создан, логика нет | P1 |
| Локализация (en/ru) | Подготовлено, не реализовано | P2 |

---

## Фазы и задачи

### PHASE A: Починка фундамента (блокирует всё)
> **Все 4 задачи можно выполнять ПАРАЛЛЕЛЬНО**

**A1. Fix ApiClient + ChatRemoteSource** `[S]`
- Использовать `EnvConfig.apiBaseUrl` вместо хардкода
- Увеличить `receiveTimeout` до 90с (когнитивный цикл)
- Подключить `RetryInterceptor` в цепочку
- Исправить `ChatRemoteSource` — использовать `_apiClient.post<Map<String, dynamic>>('/chat', data: request.toJson())`
- Файлы: `lib/core/api/api_client.dart`, `lib/features/chat/data/chat_remote_source.dart`

**A2. Fix ChatMessage + LocalSource** `[S]`
- Добавить `sessionId` и `status` (MessageStatus) в ChatMessage
- Исправить `chatLocalSourceProvider` — box `chat_history` и `sessions` вместо `settings`
- Реализовать фильтрацию `getMessagesForSession` по `sessionId`
- Запустить `build_runner`
- Файлы: `lib/core/models/chat_message.dart`, `lib/features/chat/data/chat_local_source.dart`, `lib/features/chat/logic/chat_notifier.dart`

**A3. Fix ChatRequestDto** `[S]`
- Удалить поле `client` (kai-core `extra="forbid"` → 422)
- Обновить `ChatRepository` — убрать передачу `client`
- Запустить `build_runner`
- Файлы: `lib/features/chat/data/dto/chat_request_dto.dart`, `lib/features/chat/data/chat_repository.dart`

**A4. Integrate CircuitBreaker** `[S]`
- Обернуть удалённые вызовы в `ChatRepository` через `CircuitBreaker.execute`
- Добавить `CircuitBreakerException` в sealed `KaiApiException`
- Expose CB state для UI через provider
- Файлы: `lib/core/api/api_exceptions.dart`, `lib/core/api/circuit_breaker.dart`, `lib/features/chat/data/chat_repository.dart`

---

### PHASE B: Ядро чат-UI (максимальная ценность для пользователя)
> **B1 первым, затем B2-B5 параллельно**

**B1. Chat Messages List** `[M]` — зависит от A1, A2
- Scrollable ListView с user-bubbles (правое выравнивание) и KAI-bubbles (левое)
- Рендеринг Markdown через `flutter_markdown`
- Автоскролл при новых сообщениях
- Typing indicator при `isLoading`
- Hologram как компактный header
- Файлы: создать `widgets/message_bubble.dart`, `widgets/message_list.dart`, `widgets/typing_indicator.dart`; модифицировать `chat_screen.dart`

**B2. Chat Input Bar** `[S]` — зависит от B1
- KaiTextField с кнопкой отправки
- Очистка при отправке, блокировка при loading
- Submit по Enter
- Файлы: создать `widgets/chat_input_bar.dart`; модифицировать `chat_screen.dart`

**B3. Message Status Indicators** `[S]` — зависит от A2, B1
- Иконки: sending (spinner), sent (check), failed (! + retry), queued (clock)
- Обновление статуса через ChatRepository lifecycle
- Файлы: модифицировать `widgets/message_bubble.dart`, `chat_repository.dart`

**B4. Error States + Recovery UI** `[M]` — зависит от B1, A4
- Компоненты: `KaiErrorView`, `KaiEmptyState`
- Контекстные ошибки: network (retry), rate-limit 429 (countdown), timeout (hint), circuit breaker open
- Empty state с suggested prompts
- Файлы: создать `components/kai_error_view.dart`, `components/kai_empty_state.dart`, `widgets/chat_empty_state.dart`

**B5. Confidence + Metadata Display** `[S]` — зависит от A3, B1
- Под KAI-ответом: confidence bar (green >0.8, yellow 0.5-0.8, red <0.5)
- Бейдж model/provider, latency
- Tap для полных метаданных
- PII-индикатор если `piiBlocked == true`
- Файлы: создать `widgets/message_metadata.dart`

---

### PHASE C: Авторизация (необходима для продакшена)
> **C1 затем C2 последовательно**

**C1. Auth Flow с NestJS Backend** `[L]` — зависит от A1
- Login/Register/Refresh/Logout
- JWT + refresh token в SecureStorage
- Auto-refresh при 401
- Auth state provider
- Login/Register экраны
- GoRouter: auth guard, redirect на login
- Файлы: создать `features/auth/` (data/, logic/, presentation/); модифицировать `secure_storage.dart`, `auth_interceptor.dart`, `router_provider.dart`

**C2. Dual API Client** `[S]` — зависит от C1
- `KaiCoreClient` (direct → `api.kai.wize.io`, user_id в body, без JWT)
- `BackendClient` (→ NestJS, JWT Bearer)
- Общие interceptors: connectivity, logging
- Файлы: модифицировать `api_client.dart`, `env_config.dart`, `chat_remote_source.dart`

---

### PHASE D: Управление сессиями
> **D1 затем D2**

**D1. Session Lifecycle** `[M]` — зависит от A2
- SessionNotifier: create, list, switch, delete
- Авто-заголовок после 2 сообщений
- ChatNotifier зависит от активной сессии
- Файлы: создать `logic/session_notifier.dart`; модифицировать `chat_local_source.dart`, `chat_repository.dart`, `chat_notifier.dart`

**D2. Session Drawer UI** `[M]` — зависит от D1, B1
- Slide-out drawer с историей сессий
- Строка: title, дата, кол-во сообщений
- Swipe для удаления, кнопка "New conversation"
- Файлы: создать `widgets/session_drawer.dart`; модифицировать `chat_screen.dart`

---

### PHASE E: Offline Queue
**E1. Offline Message Queue** `[M]` — зависит от A2, B3
- Сохранение в `pending_messages` Hive box при offline
- Отображение queued status
- Auto-flush FIFO при reconnect с задержкой
- Offline banner в чате
- Файлы: создать `data/offline_queue.dart`, `shared/widgets/offline_banner.dart`; модифицировать `chat_repository.dart`, `chat_screen.dart`

---

### PHASE F: SSE Streaming
**F1. SSE Streaming Client** `[L]` — зависит от C1, C2, B1
- SSE клиент через Dio `responseType: ResponseType.stream`
- Парсинг событий (THINKING_PARTIAL, tool calls, step completions)
- Прогрессивный рендеринг сообщений
- KaiCognitiveStatus для шагов PEOVUCARG
- Reconnection при обрыве
- Файлы: создать `data/sse_stream_source.dart`, `logic/stream_notifier.dart`; модифицировать `chat_screen.dart`, `message_bubble.dart`

> **Примечание:** Требует NestJS endpoint `/kai/stream/:taskId`. Если NestJS ещё не возвращает taskId — отложить до координации с бэкендом. Без SSE чат работает в режиме request-response.

---

### PHASE G: Фидбек + Отображение инструментов

**G1. Feedback Mechanism** `[S]` — зависит от C1, B1
- Thumbs up/down под каждым ответом KAI
- POST /kai/feedback через NestJS (JWT)
- Опциональный комментарий через bottom sheet
- Локальное сохранение чтобы не дублировать
- Файлы: создать `features/feedback/`, `widgets/feedback_buttons.dart`

**G2. Tool Results Cards** `[M]` — зависит от B1
- Парсинг markdown ответа на наличие tool data
- Rich-карточки: VisaInfoCard, RoutePlanCard, CostEstimateCard, HealthRequirementsCard
- Inline рендеринг в message_bubble
- Файлы: создать `widgets/tool_cards/` (4 карточки + parser)

---

### PHASE H: Health Monitoring + Proactive Suggestions

**H1. Health Monitoring** `[S]` — зависит от A1
- Polling GET /health каждые 60с
- Status dot в AppBar: green/yellow/red
- Detail sheet с состоянием сервисов
- Файлы: создать `features/health/` (data/, logic/, presentation/)

**H2. Proactive Suggestions** `[S]` — зависит от B1, B5
- 2-3 suggestion chips после ответа KAI
- На основе request_type и ключевых слов
- Tap = отправка как новое сообщение
- Файлы: создать `logic/suggestion_engine.dart`, `widgets/suggestion_chips.dart`

---

### PHASE I: Локализация
**I1. i18n Setup (en + ru)** `[M]` — зависит от Phase B
- ARB файлы (~80 строк en + ru)
- Locale provider из LocalStorage.language
- Dynamic switching из Settings
- Файлы: создать `l10n/app_en.arb`, `l10n/app_ru.arb`, `providers/locale_provider.dart`; модифицировать `app.dart`, все presentation файлы

---

### PHASE J: Polish
**J1. Loading Skeletons** `[S]` — зависит от B1, D2
- Shimmer-скелеты для: загрузки чата, отправки, списка сессий
- Файлы: создать `components/kai_skeleton.dart`, `widgets/message_skeleton.dart`

**J2. Animations** `[S]` — зависит от B1
- Message appear (slide+fade), hologram sync с chat state, page transitions, haptic на send
- Файлы: модифицировать `message_list.dart`, `chat_screen.dart`

---

## Граф зависимостей и параллелизация

```
TRACK 1 (Chat-focused):
  [A1+A2+A3+A4 параллельно] -> B1 -> [B2+B3+B5 параллельно] -> B4 -> G2 -> D1 -> D2 -> E1 -> [J1+J2]

TRACK 2 (Infrastructure):
  A1 -> C1 -> C2 -> F1 -> G1 -> H1 -> H2 -> I1
```

**Итого: 22 задачи** (9S + 9M + 4L)

---

## Верификация

| Milestone | После фазы | Проверка |
|---|---|---|
| **First Message** | A + B1 + B2 | Отправить сообщение -> увидеть ответ KAI с markdown |
| **Full Chat** | B complete | 10+ сообщений, circuit breaker test, error states |
| **Auth Works** | C | Register -> Login -> JWT refresh -> Logout -> redirect |
| **Sessions Persist** | D + E | 3 сессии -> switch -> kill app -> relaunch -> все на месте; airplane mode -> queue -> reconnect -> send |
| **Streaming** | F | Сложный запрос -> посимвольный стриминг -> PEOVUCARG индикатор |
| **Production Ready** | All | `flutter analyze` 0 warnings, coverage >75% data+logic, iOS+Android, dark/light, ru/en |

---

## Ключевые архитектурные решения

1. **Чат напрямую в kai-core** (не через NestJS) — `user_id` в body, без JWT. NestJS только для auth, feedback, SSE.
2. **Dual API Client** — KaiCoreClient + BackendClient с разными interceptors
3. **Tool cards — клиентский парсинг markdown** (kai-core не возвращает структурированные tool data в API response)
4. **SSE опционален** — Phase F можно отложить, чат работает в request-response режиме
5. **`client` поле УДАЛИТЬ из ChatRequestDto** — kai-core вернёт 422 (Pydantic `extra="forbid"`)

---

## Полная карта сервисов KAI (аудит)

### Продакшен-сервисы (готовы к интеграции)

| Сервис | Стек | Статус | Порт | Назначение |
|---|---|---|---|---|
| **kai-core** | Python/FastAPI | PROD | 8000 | Мозг агента, PEOVUCARG цикл |
| **kai-ft** | Python/C++/llama.cpp | PROD | 8001 | Локальный LLM (Qwen 3.5 9B) |
| **Redis** | 7-alpine | PROD | 6379 | Working memory, rate limits |
| **Qdrant** | v1.13.0 | PROD | 6333 | Vector DB, episodic memory |
| **Neo4j** | 5 Community | PROD | 7687 | Knowledge graph |
| **NATS** | 2.10-alpine | PROD | 4222 | Event bus, async tasks |
| **Prometheus** | v3.2.1 | PROD | 9090 | Metrics & monitoring |
| **Nginx** | 1.27-alpine | PROD | 80 | Reverse proxy |
| **NestJS Backend** | NestJS 11/TypeScript | ACTIVE | — | Auth, booking, chat proxy |

### Плановые сервисы (НЕ готовы)

| Сервис | Стек | Статус | Назначение |
|---|---|---|---|
| **Auth Service** | Go/Fiber | PLACEHOLDER | Paseto v4 tokens |
| **Gateway** | Rust/Axum | PLACEHOLDER | API gateway, WAF |

### API Endpoints для мобильного приложения

**KAI-Core (прямые вызовы):**
```
POST /chat                     # Основной чат
  Request:  {message, user_id, session_id}
  Response: {response, confidence, language, model, provider, request_type,
             latency_ms, tokens_used, pii_blocked, correlation_id}

GET /health                    # Базовый статус
GET /health/full               # Полный статус (X-Internal-Token)
GET /health/circuit-breakers   # Статус LLM провайдеров
GET /health/confidence         # Метрики confidence
GET /health/costs              # Бюджет токенов
```

**NestJS Backend (JWT-защищённые):**
```
POST /kai/chat                 # Прокси к kai-core (JwtAuthGuard)
GET  /kai/stream/:taskId       # SSE стриминг событий агента
POST /kai/feedback             # Отправка фидбека
GET  /kai/feedback/:taskId     # Получение фидбека
POST /auth/sign-up             # Регистрация
POST /auth/sign-in             # Вход
POST /auth/refresh             # Обновление токена
DELETE /auth/sign-out           # Выход
```

### Когнитивный цикл PEOVUCARG (для SSE-стриминга)

1. **P (Perception)** — Загрузка контекста, RAG через Qdrant, entities из Neo4j
2. **E (Enact)** — Генерация ответа через LLM Router, вызов инструментов
3. **O (Observe)** — Оценка генерации, проверка бюджета токенов
4. **V (Value)** — Рейтинг качества ответа, confidence score
5. **U (Update)** — Обновление памяти (Qdrant episodic, Neo4j graph)
6. **C (Critique)** — Проверка цитат, hallucination, PII scan
7. **A (Alignment)** — Goal alignment, compliance, budget
8. **R (Response)** — Форматирование и возврат ответа
9. **G (Goal)** — Трекинг долгосрочных целей

### LLM Router (приоритеты)

```
FAST       -> KAI-FT (0 cost)     -> fallback GLM-5 (confidence < 0.75)
STANDARD   -> KAI-FT (thinking)   -> fallback GLM-5
ORCHESTRATOR -> GLM-5             -> fallback DeepSeek V3
REASONING  -> GLM-5 (deep)        -> fallback DeepSeek V3
SENSITIVE  -> GLM-5 (low temp)    -> fallback DeepSeek V3
```

### Travel-инструменты KAI

| Инструмент | Назначение | Данные для карточек |
|---|---|---|
| `visa.py` | Визовые требования | Страна, тип визы, срок, документы |
| `route_planner.py` | Планирование маршрутов | Точки, расстояния, время |
| `cost_estimator.py` | Оценка стоимости | Категории расходов, валюта |
| `health_requirements.py` | Медицинские требования | Прививки, страховка |
| `emergency_contacts.py` | Экстренные контакты | Посольства, SOS, полиция |
| `risk.py` | Оценка рисков | Уровень безопасности, предупреждения |
| `intelligence.py` | Веб-поиск (Serper/Tavily) | Cross-source verification |

### Безопасность

- **3-слойная PII-защита:** Input anonymization -> Pre-LLM verification -> Output cleaning
- **PII Guardian:** Presidio + custom Russian recognizers (паспорт, СНИЛС, ИНН)
- **Шифрование:** AES-256-GCM
- **Language Lock:** Определение языка через lingua-py
- **Prompt Injection Detection:** Regex + NLP
- **Rate Limiting:** 30 req/60s per IP, 10 req/60s per user
