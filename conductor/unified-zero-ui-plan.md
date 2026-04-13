# План: Unified Zero UI (Слияние Онбординга и Настроек)

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Цель:** Удалить отдельные экраны онбординга и настроек. Сделать `ChatScreen` единственным экраном приложения. Реализовать разговорный онбординг и скрытую панель настроек (TopSheet) по свайпу вниз.

**Архитектура:**
1.  **Роутинг (`router.dart` / `app.dart`):** Удалить маршруты `/onboarding` и `/settings`. Сделать `/chat` (или `/`) стартовым экраном всегда.
2.  **Разговорный Онбординг:** Если в `localStorage` флаг `isOnboarded` равен `false`, при открытии `ChatScreen` ИИ сам отправляет первое системное сообщение (приветствие и вопрос об имени). Мы обрабатываем первые 2-3 ответа пользователя как контекст для сохранения профиля, после чего ставим `isOnboarded = true`.
3.  **Скрытые Настройки (TopSheet):** Добавить в `GestureDetector` на `ChatScreen` обработчик свайпа вниз (`onVerticalDragEnd` с положительной скоростью `> 300`). При свайпе вниз с верхнего края экрана поверх чата плавно выезжает полупрозрачная панель с техническими настройками (API URL, API Key, Очистка истории).
4.  **Удаление старого кода:** Полностью удалить папки `lib/features/onboarding/presentation` и `lib/features/settings/presentation`.

**Tech Stack:** Flutter, Riverpod

---

### Task 1: Подготовка роутинга и удаление старых экранов

**Файлы:**
- Удалить: `lib/features/onboarding/presentation/onboarding_screen.dart`
- Удалить: `lib/features/settings/presentation/settings_screen.dart`
- Обновить: `lib/app.dart` (или файл, где настроен `GoRouter`)

- [ ] **Step 1:** В файле конфигурации роутера (вероятно `lib/app.dart` или `lib/core/config/router.dart`) удалить маршруты `/onboarding` и `/settings`. Убедиться, что `/` всегда ведет на `ChatScreen`.
- [ ] **Step 2:** Удалить файлы `onboarding_screen.dart` и `settings_screen.dart`.
- [ ] **Step 3: Commit**
```bash
git rm lib/features/onboarding/presentation/onboarding_screen.dart lib/features/settings/presentation/settings_screen.dart
git add lib/app.dart
git commit -m "refactor: remove onboarding and settings screens for unified zero ui"
```

### Task 2: Разговорный Онбординг в ChatNotifier

**Файлы:**
- Обновить: `lib/features/chat/logic/chat_notifier.dart`

- [ ] **Step 1:** Добавить логику при инициализации. Если `isOnboarded == false`, добавить в локальный список сообщений приветственное сообщение от роли ИИ: "Привет! Я Kai, ваш компаньон. Как мне к вам обращаться?".
- [ ] **Step 2:** Перехватывать первые ответы пользователя, чтобы сохранить имя и интересы в `localStorage`, и затем перевести `isOnboarded` в `true`.
- [ ] **Step 3: Commit**
```bash
git add lib/features/chat/logic/chat_notifier.dart
git commit -m "feat: implement conversational onboarding logic"
```

### Task 3: Скрытая панель настроек (TopSheet)

**Файлы:**
- Создать: `lib/features/settings/presentation/widgets/settings_top_sheet.dart`
- Обновить: `lib/features/chat/presentation/chat_screen.dart`

- [ ] **Step 1:** Создать виджет `SettingsTopSheet` (содержащий инпуты для API ключа, URL и кнопку очистки истории).
- [ ] **Step 2:** В `ChatScreen` добавить обработку свайпа вниз. В `onVerticalDragEnd` проверять `primaryVelocity > 300` и вызывать кастомный `showGeneralDialog` или `showModalBottomSheet` (с якорем сверху, если возможно, или просто кастомную анимацию спуска панели сверху).
- [ ] **Step 3: Commit**
```bash
git add lib/features/settings/presentation/widgets/settings_top_sheet.dart lib/features/chat/presentation/chat_screen.dart
git commit -m "feat: add hidden top sheet for settings on swipe down"
```