# KAI-APP: Mobile Architecture Plan

> **Status:** In Progress | **Started:** 2026-04-09 | **Owner:** khuseinov
> **Goal:** Довести kai-app до production-quality, matching kai-core backend architecture level.

---

## Sprint Overview

| Sprint | Фокус | Статус |
|--------|-------|--------|
| S1 | Foundation — Core Infrastructure | 🔄 In Progress |
| S2 | Data Layer + Chat Overhaul | ⬜ Todo |
| S3 | Design System + UI Components | ⬜ Todo |
| S4 | Offline, Sessions, Localization | ⬜ Todo |
| S5 | Polish + Release Prep (TestFlight) | ⬜ Todo |

---

## S1: Foundation — Core Infrastructure

**Цель:** Production-grade инфраструктура, на которой строится всё остальное.

### Group A — No dependencies

| Файл | Действие | Статус |
|------|----------|--------|
| `lib/bootstrap.dart` | NEW: async init (Hive 4 boxes) | ✅ Done |
| `lib/core/config/env_config.dart` | NEW: dev/staging/prod URLs | ✅ Done |
| `lib/core/config/feature_flags.dart` | NEW: gate F0-F4 | ✅ Done |
| `lib/core/api/api_exceptions.dart` | NEW: sealed exception hierarchy (7 types) | ⬜ Todo |
| `lib/core/storage/secure_storage.dart` | NEW: API key → iOS Keychain / Android EncryptedSharedPreferences | ⬜ Todo |
| `lib/core/storage/cache_manager.dart` | NEW: TTL cache wrapper over Hive | ⬜ Todo |
| `lib/core/network/connectivity_service.dart` | NEW: connectivity stream + providers | ⬜ Todo |

### Group B — Depends on api_exceptions.dart

| Файл | Действие | Статус |
|------|----------|--------|
| `lib/core/api/interceptors/auth_interceptor.dart` | NEW: inject API key header | ⬜ Todo |
| `lib/core/api/interceptors/retry_interceptor.dart` | NEW: exp backoff, 3 attempts, skip 4xx | ⬜ Todo |
| `lib/core/api/interceptors/error_interceptor.dart` | NEW: DioException → KaiApiException | ⬜ Todo |
| `lib/core/api/interceptors/logging_interceptor.dart` | NEW: structured log with correlation_id | ⬜ Todo |
| `lib/core/api/interceptors/connectivity_interceptor.dart` | NEW: offline pre-check before request | ⬜ Todo |
| `lib/core/api/circuit_breaker.dart` | NEW: client-side CB (threshold=3, timeout=30s) | ⬜ Todo |

### Group C — Depends on Groups A+B

| Файл | Действие | Статус |
|------|----------|--------|
| `lib/core/api/api_client.dart` | REFACTOR: interceptor chain, remove inline Hive reads | ⬜ Todo |
| `lib/main.dart` | MODIFY: use bootstrap.dart | ⬜ Todo |
| `pubspec.yaml` | MODIFY: add `connectivity_plus: ^6.0.0` | ⬜ Todo |

### S1 Tests (minimum 15)

| Файл | Статус |
|------|--------|
| `test/core/api/circuit_breaker_test.dart` | ⬜ Todo |
| `test/core/api/interceptors/retry_interceptor_test.dart` | ⬜ Todo |
| `test/core/api/interceptors/error_interceptor_test.dart` | ⬜ Todo |
| `test/core/storage/cache_manager_test.dart` | ⬜ Todo |

---

## S2: Data Layer + Chat Overhaul

**Цель:** Repository pattern, persistent sessions, message retry, DTOs.

| Файл | Действие | Статус |
|------|----------|--------|
| `lib/features/chat/data/chat_remote_source.dart` | NEW: API calls с DTOs | ⬜ Todo |
| `lib/features/chat/data/chat_local_source.dart` | NEW: Hive CRUD для messages + sessions | ⬜ Todo |
| `lib/features/chat/data/chat_repository.dart` | NEW: orchestrator (cache + remote + offline queue) | ⬜ Todo |
| `lib/features/chat/domain/chat_session.dart` | NEW: Freezed session model | ⬜ Todo |
| `lib/features/chat/domain/message_status.dart` | NEW: enum {sending, sent, failed, queued} | ⬜ Todo |
| `lib/features/chat/data/dto/chat_request_dto.dart` | NEW: Freezed DTO matching kai-core ChatRequest | ⬜ Todo |
| `lib/features/chat/data/dto/chat_response_dto.dart` | NEW: Freezed DTO matching kai-core ChatResponse | ⬜ Todo |
| `lib/features/chat/logic/chat_notifier.dart` | REFACTOR: StateNotifier → AsyncNotifier + repository | ⬜ Todo |
| `lib/features/chat/logic/session_notifier.dart` | NEW: session lifecycle management | ⬜ Todo |
| `lib/features/settings/data/settings_repository.dart` | NEW | ⬜ Todo |
| `lib/features/settings/logic/settings_notifier.dart` | NEW: extract from screen | ⬜ Todo |
| `lib/features/health/data/health_repository.dart` | NEW | ⬜ Todo |
| `lib/features/health/logic/health_notifier.dart` | NEW | ⬜ Todo |
| `test/helpers/test_helpers.dart` | NEW | ⬜ Todo |
| Tests: 25+ | NEW | ⬜ Todo |

---

## S3: Design System + UI Components

**Цель:** Token-based design system, component library, accessibility.

| Файл | Действие | Статус |
|------|----------|--------|
| `lib/core/design/tokens/kai_colors.dart` | NEW: semantic color tokens via ThemeExtension | ⬜ Todo |
| `lib/core/design/tokens/kai_typography.dart` | NEW: SF Pro (iOS) / Roboto (Android) | ⬜ Todo |
| `lib/core/design/tokens/kai_spacing.dart` | NEW: 4px grid constants | ⬜ Todo |
| `lib/core/design/tokens/kai_radii.dart` | NEW: border radius tokens | ⬜ Todo |
| `lib/core/design/tokens/kai_shadows.dart` | NEW: elevation levels | ⬜ Todo |
| `lib/core/design/theme/app_theme.dart` | REFACTOR: built from tokens | ⬜ Todo |
| `lib/core/design/theme/theme_extensions.dart` | NEW: KaiColors + KaiTypography ThemeExtension | ⬜ Todo |
| `lib/core/design/components/kai_button.dart` | NEW | ⬜ Todo |
| `lib/core/design/components/kai_card.dart` | NEW | ⬜ Todo |
| `lib/core/design/components/kai_text_field.dart` | NEW | ⬜ Todo |
| `lib/core/design/components/kai_avatar.dart` | NEW | ⬜ Todo |
| `lib/core/design/components/kai_badge.dart` | NEW | ⬜ Todo |
| `lib/core/design/components/kai_loading.dart` | NEW: shimmer + skeleton | ⬜ Todo |
| `lib/core/design/components/kai_error_view.dart` | NEW: retry-able error state | ⬜ Todo |
| `lib/core/design/components/kai_empty_state.dart` | NEW | ⬜ Todo |
| `lib/core/design/components/kai_bottom_sheet.dart` | NEW | ⬜ Todo |
| Extract from `chat_screen.dart`: 6 widget files | EXTRACT | ⬜ Todo |
| `lib/shared/widgets/offline_banner.dart` | NEW | ⬜ Todo |
| `lib/features/health/presentation/health_indicator.dart` | NEW: status dot in AppBar | ⬜ Todo |
| Accessibility pass (Semantics, 48dp targets) | MODIFY | ⬜ Todo |
| Tests: 15+ | NEW | ⬜ Todo |

---

## S4: Offline, Sessions, Localization

**Цель:** Offline-first UX, session history, i18n (en + ru).

| Файл | Действие | Статус |
|------|----------|--------|
| `lib/features/chat/presentation/widgets/session_drawer.dart` | NEW: session history sidebar | ⬜ Todo |
| Offline queue flush on reconnect | MODIFY chat_repository | ⬜ Todo |
| Message status indicators (✓ / ⏱ / !) | MODIFY chat widgets | ⬜ Todo |
| `lib/l10n/app_en.arb` | NEW: ~60 English strings | ⬜ Todo |
| `lib/l10n/app_ru.arb` | NEW: ~60 Russian strings | ⬜ Todo |
| `lib/core/providers/locale_provider.dart` | NEW | ⬜ Todo |
| Wire `flutter_localizations` in `app.dart` | MODIFY | ⬜ Todo |
| Deep link: `/chat/:sessionId` | MODIFY router | ⬜ Todo |
| `lib/core/utils/debouncer.dart` | NEW | ⬜ Todo |
| `lib/core/utils/date_formatter.dart` | NEW | ⬜ Todo |
| `lib/core/utils/haptic_feedback.dart` | NEW: iOS-style haptics | ⬜ Todo |
| `test/integration/chat_flow_test.dart` | NEW | ⬜ Todo |

---

## S5: Polish + Release Prep

**Цель:** Production readiness, TestFlight submission.

| Действие | Статус |
|----------|--------|
| Page transitions + message animations | ⬜ Todo |
| Error handling audit (every catch → KaiErrorView) | ⬜ Todo |
| Strict lint: `strict-casts`, `strict-raw-types` | ⬜ Todo |
| Codemagic: add `flutter test --coverage` step | ⬜ Todo |
| App icons + splash screen | ⬜ Todo |
| iOS: `NSAppTransportSecurity`, `Info.plist` strings | ⬜ Todo |
| Performance: `const`, `RepaintBoundary`, lazy load | ⬜ Todo |
| `CLAUDE.md` для kai-app | ⬜ Todo |
| Final: 75%+ coverage на data + logic | ⬜ Todo |

---

## Architecture Decisions

| Decision | Choice | Reason |
|----------|--------|--------|
| Design tokens | `ThemeExtension<T>` | Native Flutter, participates in lerp |
| Exceptions | Sealed class | Exhaustive switch, all cases handled |
| State management | `AsyncNotifier` (Riverpod 2.x) | Better async, auto loading state |
| Data pattern | Repository (Remote + Local + Orchestrator) | Mirrors kai-core clean arch |
| API key storage | `flutter_secure_storage` | iOS Keychain / Android EncryptedSharedPreferences |
| Navigation | `ShellRoute` | Ready for bottom tabs (Gate 3-4) |
| Client CB | `CircuitBreaker` (threshold=3, 30s) | Mirrors `kai_shared.CircuitBreaker` |

## Kai-core API Integration

```
POST /chat
{message, user_id, session_id}
→ {response, language, model, provider, request_type, confidence, latency_ms, tokens_used, pii_blocked, correlation_id}

GET /health          # No auth, basic status
GET /health/full     # X-Internal-Token required
```

Rate limits: 30/min per IP, 10/min per user.

---

## Verification Checklist (per sprint)

- [ ] `flutter analyze` — zero warnings
- [ ] `flutter test` — all tests green
- [ ] iOS Simulator: full chat flow
- [ ] Dark/light theme toggle
- [ ] Offline → online: queue flushes

dontTouch=M4tLYO28K0xgm5a2vH