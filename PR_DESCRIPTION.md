# PR draft — feature/zero-backend-parity-2026-05-04 → master

**Open PR at:** https://github.com/khuseinov/kai-app/pull/new/feature/zero-backend-parity-2026-05-04

**Title:**
```
feat(kai-app): zero-backend feature parity — APP-A0/A5/B1-B4
```

---

## Summary

Surfaces 6 features that already exist in `services/kai-core` but were not wired in the Flutter app. **Pure frontend work** — no backend changes, no `pubspec.yaml` changes, no schema additions.

Closes `APP-A0`, `APP-A5`, `APP-B1`, `APP-B2`, `APP-B3`, `APP-B4` per `docs/planning/kai-app-tracker.md` (in the kai backend repo).

## What's in this PR

| ID | Commit | What |
|----|--------|------|
| `APP-A0` | `f472ef1` | HITL Approve/Reject buttons under Kai bubble (uses backend's existing `pending_confirmation` / `requires_human_approval` / `confirmation_type` fields) |
| `APP-A5` | `53e64b1` | Backend connectivity pill polling public `/health` every 60s; combines device + server state |
| `APP-B1` | `dbe4762` | Settings screen scaffold + `/settings` GoRoute + gear icon next to connectivity pill |
| `APP-B2` | `dbe4762` | GDPR "Delete my data" flow → calls existing `DELETE /user/{user_id}/trajectory` (App Store / Google Play privacy mandate) |
| `APP-B3` | `dbe4762` | Language preference toggle (Авто / Русский / English) — migrated to Flutter 3.32+ `RadioGroup` API |
| `APP-B4` | `dbe4762` | API base URL debug override (kDebugMode-gated) |

## Adversarial verifier finding (caught critical bug pre-merge)

The original APP-A0 plan canned `"Подтверждаю"` / `"Отменяю"` text. The `superpowers:subagent-driven-development` adversarial verifier discovered that backend `_CONFIRM_YES_RE` (`services/kai-core/src/api/security_scan.py:40`) does **not** match either string — only `\b(yes|allow|ok|proceed|legitimate|да|разреши|продолжи|легитимно)\b`. The Approve button was end-to-end broken; unit test passed only because it mocked the callback.

Fixed in `f472ef1`:
1. **Backend contract**: send `"да"` (matches regex → consumes pending key as approval) / `"отмена"` (deliberately falls through → denial branch).
2. **In-flight guard**: `ApprovalActions.isBusy` blocks parallel `sendMessage` races during streaming.
3. **Stale-button hygiene**: actions hidden unless message is the latest in active session AND `message.sessionId == notifier.currentSessionId`. Prevents tapping historical bubbles after navigation/restart.
4. **Idiomatic Riverpod**: switched from `ProviderScope.containerOf(context)` to `ref.read(...)` via `ConsumerWidget`.

## Test plan

- [x] `flutter test` — **52 passed, 0 failed** (added 12 new test cases across 5 new test files)
- [x] `flutter analyze <touched files>` — no issues introduced
- [x] `flutter analyze` (full project) — 10 pre-existing warnings in `env_config.dart` + `chat_notifier.dart`, **none from this PR** (surgical-changes rule)
- [ ] `flutter build apk --debug` — not run locally (no Android SDK in dev env); needs CI / device verification before merge
- [ ] iOS device QA — covered by `APP-IOS-QA-1` follow-up: HITL approve/reject in `/s` simulation, settings screen reachable, GDPR delete flow against test user, connectivity pill states

## Out of scope (intentional)

- **Auth**: `lib/features/auth/` calls non-existent `/auth/*` endpoints — deferred to Phase 3/4 per product decision. `auth_remote_source.dart` untouched.
- **APP-A1/A2/A3/A4** (source chips, revision badge, bias tips, distinct safety blocks): require backend `ChatResponse` schema extension `APP-A-BE-1` to be merged first.
- **Phase C/D/E**: require new backend endpoints (`/user/{id}/profiles`, `/sessions`, `COG-TOOL-GATE-1`).
- **Voice / push / files / IAP**: pubspec.yaml Gate 3/4 — separate path.

## Notes for reviewers

- New file `test/test_helpers/fake_settings.dart`: `initHiveForTest` / `tearDownHiveForTest` helpers because `settingsProvider` depends on `localStorageProvider` which opens 2 Hive boxes — widget tests need them in a temp dir.
- `chat_screen.dart` has no AppBar (immersive Stack-based UI). Pill + gear mounted as Positioned widget in top-right cluster inside SafeArea.
- `MessageBubble` migrated `StatelessWidget` → `ConsumerWidget` to allow Riverpod access for the HITL helper.

---

🤖 Generated with [Claude Code](https://claude.com/claude-code)
