# Kai App — Design Fidelity Fixes Master Plan

**Date**: 2026-05-27
**Branch**: `claude/hungry-lamport-e41998` (worktree)
**Source**: Multi-agent design fidelity review (Token + Component + Screen reviewers + Playwright + Pixel-perfect cross-check)
**Status**: Draft — ready to dispatch to parallel Sonnet agents

---

## 1 · Goal

Привести Flutter rebuild v3 к pixel-perfect соответствию с HTML канонами в `new-design/` — устранить все CRITICAL + HIGH + MEDIUM + LOW расхождения, обнаруженные ревью от 2026-05-27. Декомпозиция на 6 независимых бакетов (файлы не пересекаются) для параллельного запуска.

---

## 2 · Source of truth

- **HTML канон**: `E:/startup/kai-app/new-design/*.html` (read-only)
- **Дизайн-токены**: `new-design/colors_and_type.css` + `new-design/design-tokens.json`
- **Tide канон**: `new-design/tide-states.html` (HTML wins над JSON для idle/sleep breathe)
- **Hard rules**: `new-design/CLAUDE.md § 3`
- **Spec rebuild v3**: `docs/superpowers/specs/2026-05-26-kai-app-rebuild-v3-design.md`
- **Implementation plan**: `docs/superpowers/plans/2026-05-26-kai-app-rebuild-v3-implementation.md`
- **Phase 6 handoff**: `docs/superpowers/handoffs/2026-05-27-design-system-review.md`

---

## 3 · Decomposition (6 атомарных бакетов)

Каждый бакет = независимый набор файлов. Бакеты не пересекаются по файлам → можно запускать параллельно.

| Bucket | Файлы | Главные фиксы | Severity coverage | Est. effort |
|---|---|---|---|---|
| **A** [ChatList overhaul](./tasks/bucket-a-chatlist-overhaul.md) | `organisms/chat_list.dart`, `atoms/kai_bubble.dart`, `molecules/source_card.dart` | C1 streaming partial bubble, C2 error embed, C6 .who row + SourceCard, D1 hardcode, empty chip cards, day header em-dashes | 4 CRITICAL + 8 HIGH + 5 MEDIUM | 6–10h |
| **B** [NavPanel reconstruction](./tasks/bucket-b-navpanel-reconstruction.md) | `organisms/nav_panel.dart`, `molecules/nav_item.dart` | C3 pin-trip + trips + dates, top bar center, search-box r-9 + mono, sec-label mono 8.5, account tide-avatar, NavItem padding 14×6/7 | 1 CRITICAL + 5 HIGH + 6 MEDIUM | 4–6h |
| **C** [Compose + Buttons polish](./tasks/bucket-c-compose-buttons-polish.md) | `molecules/compose_island.dart`, `atoms/kai_button.dart`, `atoms/kai_button_send.dart` | C4 mic transparent, button.ghost border `line`, send-size 30 default for pill, padding 5×16, send icon 12-13 | 1 CRITICAL + 3 HIGH + 4 MEDIUM | 2–3h |
| **D** [AlertCard + EdgeStateBlock](./tasks/bucket-d-alertcard-edge-states.md) | `molecules/alert_card.dart`, `organisms/edge_state_block.dart`, `molecules/care_block.dart` | C5 neutral palette, H2-H4 (no duplicate tide, offline warning-wash + wifi-off, rateLimit clock, crisis border-left) | 1 CRITICAL + 4 HIGH + 6 MEDIUM | 3–4h |
| **E** [Screen positioning + Tide wiring](./tasks/bucket-e-screen-positioning.md) | `features/room/room_screen.dart`, `features/onboarding/onboarding_screen.dart` | tide curve height 16 vs 48, 4px gap from safe area, onboarding step 2 tide = responding (не idle) | 2 MEDIUM + 2 LOW | 1–2h |
| **F** [Type tokens polish](./tasks/bucket-f-type-tokens.md) | `tokens/kai_type.dart` | font-feature-settings `ss03`, `cv11` (Manrope friendly 'a' alternates) | 1 LOW | 30min |

**Total estimated effort**: 16–25 hours of focused work across 6 parallel agents.

---

## 4 · Cross-bucket invariants (must not break)

Все агенты обязаны соблюдать:

1. **Theme tokens only** — никаких `Color(0xFF...)` вне `design_system/tokens/`. Все цвета через `KaiTheme.of(context).colors.<name>`.
2. **Tide gradient locked** — `#1B4FB0 → #2BA8C9 → #F4B589` @ 115°. Не пересоздавать.
3. **Error = coral** — `negative` token = `#C44A3C` (light) / `#E66F60` (dark). Никогда `#DC2626`.
4. **Zero-UI** — не добавлять persistent chrome (AppBar/BottomNav/TabBar) в production screens.
5. **One primary action per screen** — только один `KaiButton.tide()` (gradient fill) на экран.
6. **Test coverage** — тесты per layer должны продолжать проходить (`flutter test` зелёный).
7. **iOS CI** — не трогать `ios/Runner.xcodeproj/project.pbxproj`, `.github/workflows/ios_build.yml`.
8. **Locked dirs** — не трогать `android/`, `web/`, `windows/`, `macos/`, `linux/`.

---

## 5 · Execution model

### Parallel dispatch

Каждый bucket → отдельный Sonnet-агент. Все 6 могут идти параллельно (файлы не пересекаются). Каждый агент:

1. Читает свой task-doc + master plan + `new-design/CLAUDE.md`.
2. Открывает HTML canon файлы для своих компонентов (читает только нужные секции по line-references из task-doc).
3. Открывает текущий Dart, применяет фиксы.
4. Обновляет тесты (golden + widget per layer).
5. Прогоняет `flutter analyze` + `flutter test` локально, ждёт зелёного.
6. Делает 1 commit per bucket с осмысленным сообщением.
7. НЕ пушит, НЕ создаёт PR. Master controller проверит результат.

### Dependency ordering

Бакеты в основном независимы, но есть **2 порядковых ограничения**:

- **Bucket C** должен быть готов **до** Bucket A — потому что Bucket A использует `KaiButton.iconTransparent` variant, которую создаёт Bucket C (для mic).
- **Bucket F** (type tokens) можно делать любым моментом — не блокирует никого.

Рекомендованный порядок запуска:

```
Round 1 (parallel): C, D, E, F
Round 2 (parallel): A, B
```

Альтернатива — если C создаст `iconTransparent` variant раньше A, можно запускать все 6 одновременно.

---

## 6 · Acceptance criteria (master-level)

После завершения всех 6 бакетов:

1. **Visual fidelity**: каждый из 4 экранов (room / onboarding / nav / edge surfaces) визуально совпадает с HTML каноном при сравнении side-by-side через Playwright или dev showcase.
2. **Pixel diffs**: все CRITICAL + HIGH closed; MEDIUM closed; LOW либо closed, либо явно acknowledged.
3. **Tests**: `flutter test` зелёный; golden tests обновлены под новые визуалы; покрытие не упало.
4. **Analyze**: `flutter analyze` без warnings.
5. **iOS CI**: зелёный после push.
6. **Dark mode parity**: ни одного `Color(0xFF...)` хардкода в `lib/design_system/` и `lib/features/` (`grep -r "Color(0xFF" lib/`).
7. **i18n**: все user-visible strings через `AppLocalizations`. Hardcoded русские строки в `nav_panel.dart` / `onboarding_card.dart` мигрированы в ARB.

---

## 7 · Risk management

| Risk | Mitigation |
|---|---|
| Bucket conflict при параллельном запуске | Файлы не пересекаются по дизайну. Если агент A и B оба захотят редактировать общий файл — задача спроектирована неправильно, нужно ревью |
| KaiButton API изменения сломают использования | Bucket C добавляет новые variants без удаления старых; только дополняет |
| Golden tests падают после визуальных изменений | Каждый bucket обязан обновить golden snapshots после своих изменений (`flutter test --update-goldens` для своих тестов) |
| Hardcoded strings без l10n keys | Если ARB не имеет ключа — добавить в `app_ru.arb` + `app_en.arb` + regenerate (`flutter gen-l10n`) |
| Plan vs HTML canon coverage gap | Все task-doc'и ссылаются на конкретные line-references HTML канонов. План rebuild v3 не используется как single source — HTML wins |

---

## 8 · Out of scope (для этих 6 бакетов)

- **Voice mode** (`voice.html`) — не в v1 scope.
- **Memory app** (`memory.html`) — не в v1 scope.
- **Settings screen** (`settings.html`) — не в v1 scope.
- **Trip detail** (`trip-detail.html`) — не в v1 scope.
- **Multi-Country Fork** (`fork.html`) — не в v1 scope.
- **Notifications-chat full integration** (`notifications-chat.html`) — AlertCard молекула фиксится в Bucket D, но интеграция в chat feed (Alert Card N-01 inline в conversation) — не в v1 scope.
- **Marketing landing** (`landing.html`) — не в v1 scope.
- **Authentication** — anonymous mode only в v1.
- **Android** — iOS-only в v1.

Если в процессе обнаруживается, что фикс требует выйти за scope бакета — оставить TODO с ссылкой на этот документ и **не расширять scope без явного approval**.

---

## 9 · After completion

1. Каждый bucket-агент делает 1 commit per bucket.
2. После всех 6 — controller прогоняет финальный `flutter analyze` + `flutter test`.
3. Контрольный визуальный pass через Playwright (повторить ту же сверку, что в ревью 2026-05-27).
4. Если всё ок — merge worktree в master через PR.
5. Тэг `phase-6-design-fidelity-v1.0`.

---

## 10 · Index of bucket task-docs

- 📄 [Bucket A — ChatList overhaul](./tasks/bucket-a-chatlist-overhaul.md)
- 📄 [Bucket B — NavPanel reconstruction](./tasks/bucket-b-navpanel-reconstruction.md)
- 📄 [Bucket C — Compose + Buttons polish](./tasks/bucket-c-compose-buttons-polish.md)
- 📄 [Bucket D — AlertCard + EdgeStateBlock](./tasks/bucket-d-alertcard-edge-states.md)
- 📄 [Bucket E — Screen positioning + Tide wiring](./tasks/bucket-e-screen-positioning.md)
- 📄 [Bucket F — Type tokens polish](./tasks/bucket-f-type-tokens.md)
