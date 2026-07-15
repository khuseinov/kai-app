# Plan: Design System Structure & UI Components Refactor (Global vs Local Split)

**Goal:** Навести порядок в архитектуре дизайн-системы и UI-компонентов: изолировать локальные (специфичные для конкретных фич) виджеты внутри папок соответствующих фич, оставить в `lib/design_system/` только переиспользуемые (глобальные) примитивы, атомы и молекулы, а также устранить дублирование кода, стилей и рисования логотипа.

---

## 1. Архитектурное видение (Architecture Decisions)

Мы разделяем все UI-компоненты на два уровня видимости:
1. **Глобальные (Global) — `lib/design_system/`**: Универсальные дизайн-примитивы, атомы ввода, универсальные кнопки, общие разделители, системные тосты и базовые группы списков (например, элементы настроек, которые планируется переиспользовать в Memory App).
2. **Локальные (Local) — `lib/features/<feature_name>/components/`**: Виджеты, которые используются только внутри одного экрана или одной бизнес-фичи (облака сообщений чата, панели навигации, карточки онбординга).

### Устранение дублирования (De-duplication)
* **Аватары:** Использовать глобальный атом `KaiAvatar` вместо ручной верстки контейнеров с инициалами в навигационной панели.
* **Сплайны логотипа:** Вынести `_GlyphCurvePainter` and `_SplashGlyph` в глобальный атом `KaiLogo` (или `KaiBrandCurve`) и использовать его в Onboarding, Splash и Storybook.
* **Шапки экранов:** Вынести `_SettingsTopBar` в глобальную молекулу `KaiAppBar` (с поддержкой переиспользования круглых кнопок с шевронами).
* **Стили текста:** Заменить хардкодные `TextStyle` дубликаты на вызовы `KaiType` или централизовать константы текстовых стилей шагов онбординга в одном месте.

---

## 2. Карта перемещения и создания файлов (File Map)

### А. Локализация компонентов (Перемещение из `lib/design_system/` в `lib/features/`)

| Исходный файл в `lib/design_system/...` | Новый локальный путь в `lib/features/...` | Ответственность виджета |
| :--- | :--- | :--- |
| **Фича Chat / Room (`lib/features/room/components/`)** | | |
| `organisms/kai_chat_list.dart` | `lib/features/room/components/kai_chat_list.dart` | Лента сообщений чата |
| `organisms/kai_edge_state_block.dart`| `lib/features/room/components/kai_edge_state_block.dart`| Инлайн-плашки сетевых ошибок и лимитов |
| `molecules/kai_compose_island.dart` | `lib/features/room/components/kai_compose_island.dart` | Остров ввода сообщения |
| `atoms/kai_send_button.dart` | `lib/features/room/components/kai_send_button.dart` | Кнопка отправки сообщения чата |
| `molecules/kai_user_bubble.dart` | `lib/features/room/components/chat_bubbles/kai_user_bubble.dart` | Пузырь сообщения пользователя |
| `molecules/kai_kai_bubble.dart` | `lib/features/room/components/chat_bubbles/kai_kai_bubble.dart` | Пузырь ответа ИИ |
| `molecules/kai_system_bubble.dart` | `lib/features/room/components/chat_bubbles/kai_system_bubble.dart` | Системные нотации чата |
| `molecules/kai_alert_card.dart` | `lib/features/room/components/cards/kai_alert_card.dart` | Карточка критического предупреждения |
| `molecules/kai_care_block.dart` | `lib/features/room/components/cards/kai_care_block.dart` | Блок ссылок экстренной помощи |
| `molecules/kai_source_card.dart` | `lib/features/room/components/cards/kai_source_card.dart` | Карточка источника цитирования чата |
| `molecules/kai_action_sheet.dart` | `lib/features/room/components/sheets/kai_action_sheet.dart` | Выпадающий список действий чата |
| `molecules/kai_message_detail_sheet.dart`| `lib/features/room/components/sheets/kai_message_detail_sheet.dart`| Детали сообщения чата |
| **Фича Onboarding (`lib/features/onboarding/components/`)** | | |
| `organisms/kai_onboarding_card.dart` | `lib/features/onboarding/components/kai_onboarding_card.dart`| Шаги приветственного слайдера |
| `atoms/kai_step_indicator.dart` | `lib/features/onboarding/components/kai_step_indicator.dart`| Точки шагов прогресса онбординга |
| **Фича Navigation Slider (`lib/features/nav/components/`)** | | |
| `organisms/kai_nav_panel.dart` | `lib/features/nav/components/kai_nav_panel.dart` | Выдвижная панель меню |
| `molecules/kai_nav_item.dart` | `lib/features/nav/components/kai_nav_item.dart` | Строка элемента меню навигации |
| `organisms/nav_models.dart` | `lib/features/nav/components/nav_models.dart` | Вспомогательные дата-модели панели |
| **Будущие фичи (Trip & Voice локализация)** | | |
| `atoms/kai_karaoke_text.dart` | `lib/features/voice/components/kai_karaoke_text.dart` | Караоке-текст для Voice |
| `molecules/kai_transcript_view.dart` | `lib/features/voice/components/kai_transcript_view.dart` | Поток стенограммы голосового чата |
| `molecules/kai_fork_card.dart` | `lib/features/trip_detail/components/kai_fork_card.dart` | Сравнение вариантов поездки |
| `atoms/kai_fork_chip.dart` | `lib/features/trip_detail/components/kai_fork_chip.dart` | Теги виз/погоды в карточке сравнения |
| `atoms/kai_fork_price_delta.dart` | `lib/features/trip_detail/components/kai_fork_price_delta.dart` | Обозначение разницы цен (зеленый/коралл)|
| `atoms/kai_fork_score_dots.dart` | `lib/features/trip_detail/components/kai_fork_score_dots.dart` | Оценочные точки отелей/погоды |
| `atoms/kai_budget_bar.dart` | `lib/features/trip_detail/components/kai_budget_bar.dart` | Распределение бюджета поездки |

*Примечание: папки `lib/features/voice/` и `lib/features/trip_detail/` будут созданы для хранения неиспользуемых пока в основном чате, но готовых UI-компонентов.*

---

### Б. Промоутирование в глобальную систему (Новые общие файлы)

| Путь создаваемого файла | Из какого локального виджета создается | Назначение |
| :--- | :--- | :--- |
| `lib/design_system/atoms/kai_logo.dart` | `_SplashGlyph` & `_GlyphCurvePainter` из `splash_screen.dart` | Глобальный бренд-логотип (кривая приливов) |
| `lib/design_system/molecules/kai_app_bar.dart`| `_SettingsTopBar` из `settings_screen.dart` | Каноничный верхний AppBar экрана с кнопкой назад |

---

## 3. Последовательность выполнения (Build Sequence)

Рефакторинг выполняется по шагам, с запуском `flutter analyze` и `flutter test` на каждой границе, чтобы suite всегда оставался зеленым.

### Шаг 1: Промоутирование глобальных компонентов и дедупликация логотипа
1. Создать `lib/design_system/atoms/kai_logo.dart`. Реализовать в нем `KaiLogo` (или `KaiBrandCurve`) на основе `_GlyphCurvePainter`.
2. Заменить локальный `_SplashGlyph` в [splash_screen.dart](file:///E:/startup/kai-app/lib/features/boot/splash_screen.dart) на импорт глобального `KaiLogo`.
3. Заменить `_WavePainter` в [kai_onboarding_card.dart](file:///E:/startup/kai-app/lib/design_system/organisms/kai_onboarding_card.dart#L205) на использование импортируемого `KaiLogo`.
4. Создать `lib/design_system/molecules/kai_app_bar.dart`. Перенести туда шапку экрана с поддержкой центрированного заголовка и канонической круглой кнопки назад (через `KaiIconButton.surface`).

### Шаг 2: Дедупликация кнопок, аватаров и стилей в настройках и навигации
1. В [settings_screen.dart](file:///E:/startup/kai-app/lib/features/settings/settings_screen.dart) заменить локальный `_SettingsTopBar` на использование нового `KaiAppBar`. Отрефакторить кнопку назад через `KaiIconButton.surface`.
2. В [kai_nav_panel.dart](file:///E:/startup/kai-app/lib/design_system/organisms/kai_nav_panel.dart) заменить ручной рендеринг аватарок пользователя (строки 599–615) на использование атома `KaiAvatar(size: 24, initial: initial)` с правильным токеном `KaiTide.gradientCorner`.
3. В `kai_nav_panel.dart` отрефакторить аватарку направления (строки 475–492), удалив дублируемый `TextStyle` и привязав параметры текста к токенам.
4. Вынести вспомогательные хелперы `_ChevTrail`, `_TextChevTrail` и `_StatusTrail` из настроек в [kai_settings_row.dart](file:///E:/startup/kai-app/lib/design_system/molecules/kai_settings_row.dart), сделав их доступными для будущих экранов.

### Шаг 3: Локализация компонентов в папки фич (Move & Refactor)
1. Создать локальные директории `components/` внутри `lib/features/onboarding/`, `lib/features/nav/`, `lib/features/room/`, `lib/features/voice/` и `lib/features/trip_detail/`.
2. Физически переместить файлы согласно разделу 2А.
3. Исправить пути импорта в перемещенных файлах (так как они теперь лежат глубже в фичах).
4. Обновить экспортные файлы дизайн-системы (удалить экспорты перенесенных файлов из `atoms.dart`, `molecules.dart`, `organisms.dart`).

### Шаг 4: Обновление импортов в экранах и тестах
1. Обновить импорты в экранах:
   * [room_screen.dart](file:///E:/startup/kai-app/lib/features/room/room_screen.dart)
   * [onboarding_screen.dart](file:///E:/startup/kai-app/lib/features/onboarding/onboarding_screen.dart)
   * [nav_screen.dart](file:///E:/startup/kai-app/lib/features/nav/nav_screen.dart)
   * [settings_screen.dart](file:///E:/startup/kai-app/lib/features/settings/settings_screen.dart)
2. Обновить импорты во всей директории `test/` (так как тесты компонентов дизайн-системы теперь должны тестировать их по новым локальным адресам).
3. Запустить `flutter analyze` и `flutter test` для полной валидации.

### Шаг 5: Дедупликация TextStyle в Onboarding
1. Сгруппировать 4 дублирующихся стиля заголовков шагов онбординга (`22px/w600/ls-0.02`) и 4 стиля тела шагов (`13px/w400/lh1.5`) в константные поля класса `KaiOnboardingCard` или вынести их в отдельный внутренний хелпер.

---

## 4. Риски и открытые вопросы (Risks & Open Questions)

1. **Storybook Route Mappings:** 
   Storybook (`lib/features/dev/dev_screen.dart`) импортирует и отображает все эти компоненты. После перемещения компонентов в локальные папки фич нам потребуется обновить пути импорта в файле Storybook. Это механическая работа, но важно ее не пропустить.
2. **Экспорты в Barrel-файлах:**
   Мы должны убедиться, что удалили локализованные компоненты из глобальных barrel-экспортов (`atoms.dart`, `molecules.dart`, `organisms.dart`), чтобы избежать случайного импорта старых путей.

---

## 5. Критерии приемки (Acceptance Criteria)

* [ ] `flutter analyze` возвращает "No issues found" (нет ошибок импорта или типов).
* [ ] Выполнение `flutter test` завершается со статусом `All tests passed!` (все 843+ тестов зеленые).
* [ ] Папка `lib/design_system/` содержит исключительно независимые переиспользуемые виджеты и токены.
* [ ] Ручные дубликаты `TextStyle`, CustomPainter бренда и круглых аватарок в панели меню заменены на системные токены и атомы.
