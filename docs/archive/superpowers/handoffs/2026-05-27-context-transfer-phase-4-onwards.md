# Kai App Rebuild v3 — Context Transfer for Phase 5+

**Date**: 2026-05-27 (updated after Phase 5 completion)
**From session**: Phase 5 controller (Phases 0-5 complete)
**To**: new agent session starting Phase 6
**Reason**: каждая фаза = новая сессия (user requirement)

---

## 1 · Your job

You are the SDD (subagent-driven-development) **controller** continuing execution of the Kai app rebuild v3 plan from **Phase 6** onwards. Phases 0–5 are DONE. You inherit state, not history.

**Mandatory first action**: read these files before doing anything else:
1. `docs/superpowers/specs/2026-05-26-kai-app-rebuild-v3-design.md` (design spec)
2. `docs/superpowers/plans/2026-05-26-kai-app-rebuild-v3-implementation.md` (134-task plan, Phase 6 section)
3. `new-design/CLAUDE.md` (design system hard rules — non-negotiable)
4. This file in full.

Then verify state with `git log --oneline -6` and `flutter test` before dispatching any implementer.

**Do NOT run a Phase 0-5 review** — that was already done. Go straight to Phase 6.

---

## 2 · Hard constraints (NEVER violate)

### Branch & worktree

- **Work ONLY on branch `claude/hungry-lamport-e41998`** (the worktree branch).
- Working directory: `E:\startup\kai-app\.claude\worktrees\hungry-lamport-e41998`
- DO NOT create new branches.
- DO NOT touch `master` — it's the legacy app, the backup if rebuild fails.
- DO NOT push tags to origin. Phase tags are LOCAL ONLY.

### Lock-list (NEVER edit)

- `ios/Runner.xcodeproj/project.pbxproj` — iOS CI signing config
- `.github/workflows/ios_build.yml` — Flutter CI workflow
- `android/`, `web/`, `windows/`, `macos/`, `linux/` — out-of-scope platforms
- `new-design/` — read-only source of truth for design

`ios/Runner/Info.plist` IS editable (Phase 0 already removed NSMicrophoneUsageDescription from it).

### User language

User communicates **in Russian**. Reply to user in Russian. Code and commit messages stay in English.

### Platform

User is on **Windows 11**. `gh` CLI is NOT installed. Cannot programmatically verify iOS CI — user verifies manually in browser. Use Bash tool with POSIX commands, not PowerShell, for git operations.

---

## 3 · Current state (as of 2026-05-27 — after Phase 5 + blank-screen fix)

### Branch position

- HEAD: `751ae63` on `origin/claude/hungry-lamport-e41998`
- 20 commits since branch off master:
  ```
  751ae63 fix: add Далее button to onboarding steps 0-2 and Scaffold to RoomScreen
  8f96882 phase-5b fix: concurrency race + takeWhile cancel + ref.watch + T33 rename
  cfea1aa phase-5b: real repositories + SSE pipeline
  c9ad2b5 phase-5a fix: subscription leak + streaming frame + color literal + nav barrier
  555bdb2 phase-5a: RoomScreen + OnboardingScreen + NavScreen + SseParser + router
  45bebda docs(handoff): update for Phase 5 controller — Phase 4b state + next steps
  dcfa341 phase-4b fix: controller leak + tautological cancel test
  7590b69 phase-4b: repo interfaces + mocks + showcase
  ...
  ```

### Local tags (NOT pushed to origin)

- `phase-0-wipe` → `cd8ba93`
- `phase-1-foundation` → `1d215dd`
- `phase-2-atoms` → `46a2ec5`
- `phase-3-molecules` → `54332c8`
- `phase-4a-organisms` → `d62e867`
- `phase-4-organisms` → `dcfa341`
- `phase-5-screens` → `8f96882`

### Worktree setup note

When creating a new worktree for this branch, you MUST run:
```bash
cp .env.example .env          # flutter test fails without .env asset
dart run build_runner build   # generates *.freezed.dart and *.g.dart (gitignored)
```
Both steps are required before `flutter test` and `flutter analyze` will succeed.

### Test + lint state

- `flutter analyze` → 2 warnings only (unused imports in test files — pre-existing, verified at `751ae63`)
- `flutter test` → 197/197 passing (verified at `751ae63`)

### iOS CI

Status unknown to controller (no `gh` CLI). User verifies manually at https://github.com/khuseinov/kai-app/actions filtered by branch `claude/hungry-lamport-e41998`.

---

## 4 · What's been built (Phase 0-5 summary)

### Phase 0-4b — See previous handoff sections (unchanged)

All Phase 0-4b content remains valid. Summary: tokens, theme, fonts, network skeleton, atoms, molecules, organisms, repo interfaces + mocks are complete.

### Phase 5a — Screens + Router + SSE Parser ✅ (commits 555bdb2 + c9ad2b5)

**New files:**
- `lib/features/room/room_state.dart` — `RoomStateData` + `RoomNotifier` (plain `NotifierProvider`)
  - Fields: `messages` (List<Map<String,dynamic>>), `currentFrame` (RoomFrame), `tideState` (KaiTideState), `isStreaming`, `activeSessionId`, `streamingMessageId`
  - Methods: `sendMessage`, `cancelStreaming`, `openNavPanel`, `closeNavPanel`, `switchSession`
  - `_subscription` field stored; `ref.onDispose` cancels subscription + completer
  - `currentFrame` = `RoomFrame.streaming` immediately on `sendMessage` (not `live`)
  - `ChatEventCorrection` REPLACES content (not appends)
  - `ChatEventDone`: frame = `empty` if no messages, else `live`
  - `closeNavPanel` called via `.then()` on `NavPanelRoute` push — works for barrier/back too
  - Retry guard: `if (lastUserText.isNotEmpty)` before calling sendMessage

- `lib/features/room/room_screen.dart` — `ConsumerStatefulWidget`
  - **Scaffold(backgroundColor: colors.bg)** wraps GestureDetector (fix: commit `751ae63`)
  - KaiTideCurve (top) + ChatList + EdgeStateBlock (offline/rate-limit/crisis inline) + ComposeIsland
  - Left-edge swipe (dragStart.dx < 24, velocity > 200) → push `NavPanelRoute`, `.then()` calls `closeNavPanel`

- `lib/features/onboarding/onboarding_screen.dart` — 4-step `PageView`
  - `OnboardingCard` steps 0-3, `_DotsIndicator` (uses `colors.accent`, NOT raw Color literal)
  - **KaiButton.tide('Далее') visible when `_currentPage < 3`** (fix: commit `751ae63`) — steps 0-2 now advance; step 3 uses `OnboardingCard`'s own 'Начать' button
  - Step 3 finish: `HiveSetup.settings.put(settingsKey, settings.copyWith(onboarded: true))` → `context.go('/room')`

- `lib/features/nav/nav_screen.dart` — `NavScreen` + `NavPanelRoute`
  - `NavPanelRoute extends PageRoute<void>` with slide-from-left transition (250ms)
  - `NavScreen`: reads `sessionListProvider`, renders `NavPanel`, tap → `switchSession` + pop
  - New chat: `switchSession('session-${DateTime.now().millisecondsSinceEpoch}')` + pop

- `lib/core/network/sse_parser.dart` — `SseParser.parse(Stream<List<int>>) → Stream<ChatEvent>`
  - Standard SSE: `event:` + `data:` lines, blank line separates events
  - Handles all 8 event types; unknown types return null (skipped)

- `lib/core/providers/session_provider.dart` — `sessionListProvider` (`FutureProvider<List<ChatSession>>`)

- `lib/core/routing/router.dart` — updated
  - `/` → redirect: `HiveSetup.settings.get(settingsKey)?.onboarded == true ? '/room' : '/onboarding'`
  - `/onboarding`, `/room`, `/room/:tripId`, `/_dev/*` routes all present
  - Dev routes NOT guarded by `kReleaseMode` yet (Phase 6 task T6.X or defer to post-v1)

**Tests added:** 13 (room: 3, onboarding: 3, sse_parser: 10)

### Phase 5b — Real Repositories + SSE Pipeline ✅ (commits cfea1aa + 8f96882)

**New files:**
- `lib/core/repositories/real_chat_repository.dart` — `RealChatRepository`
  - `SseStreamOpener` typedef for testability; `factory .withDio(Dio)` for production
  - 8 anti-regression patterns baked in (see §7 tech debt for T36 note)
  - **Critical concurrency fix**: completer claimed synchronously BEFORE first `await`
  - **Cancel safety**: `takeWhile((_) => !cancelCompleter.isCompleted)` — stall-safe
  - **finally identity check**: only removes own completer, never evicts successor's

- `lib/core/repositories/real_session_repository.dart` — Hive-backed
  - `list()` sorts by `createdAt` desc, returns `List.unmodifiable`
  - `create()` generates UUID, persists `Session` entity, returns `ChatSession`
  - `delete(id)` removes from box

- `lib/core/providers/root.dart` — updated
  - `EnvConfig.useRealChat` field → reads `USE_REAL_CHAT` from dotenv
  - `chatRepositoryProvider`: switches mock↔real via `env.useRealChat`
  - `sessionRepositoryProvider`: same
  - Uses `ref.watch(envProvider)` and `ref.watch(dioProvider)` correctly (not `ref.read`)

- `.env.example` — `USE_REAL_CHAT=false` added

**Tests added:** 25 (sse_pipeline: 18, real_session_repository: 7)

**Total tests: 184/184**

---

## 5 · What's still pending

### Phase 5 — COMPLETE ✅

All T5.1-T5.41 done. T5.37 (local device smoke test) skipped — no device available in controller environment.

### Phase 6 — Edge States + Polish (final phase) ← NEXT

Plan section lines ~367-393. 26 sub-tasks T6.1-T6.26.

Components:
- `lib/core/network/connectivity_listener.dart` — connectivity_plus stream → provider
- Wire offline detection in RoomState → EdgeStateBlock(offline) inline
- Rate-limit (429) handling in real_chat_repository → emit rate-limit event
- Wire rate-limit edge surface — disable compose, show countdown
- Error edge surface routing
- Crisis pattern detection (`.metadata` event with `crisis: true`)
- Wire crisis → CareBlock in Kai bubble + EdgeStateBlock(crisis)
- Tide state transitions: idle (no stream), listening (mic), thinking (request pending), responding (streaming), error (abnormal termination)
- Success ephemeral trigger (responding→done → 1200ms flash then revert)
- Memory ephemeral trigger (`.metadata` with `memory_saved=true` → 900ms pop)
- 60s inactivity timer → sleep tide state
- Tests: edge_states + tide_states
- l10n setup (l10n.yaml + app_en.arb + app_ru.arb)
- Replace hardcoded UI strings with AppLocalizations
- Telemetry hook placeholder
- Final iOS smoke test (manual)
- Coverage thresholds: 70% design_system, 60% features, 80% core/repositories
- Commit phase-6, push, local tag, wait for user approval before PR to master

### Final review + finishing-a-development-branch

After Phase 6: dispatch full-implementation code reviewer. Then user decides: PR to master, merge inline, or leave as-is on branch.

---

## 6 · Methodology — SDD flow (use exactly this)

For each phase:

1. **Mark phase task in_progress** in TaskList
2. **Dispatch implementer subagent** with:
   - Full task text inline (don't make them read plan file)
   - Working dir absolute path
   - Branch + HEAD SHA
   - Lock-list reminder
   - "No tag push to origin" reminder
   - Lint constraints
   - Source-of-truth files to read (new-design/...)
3. **Receive report** — possible statuses: DONE / DONE_WITH_CONCERNS / BLOCKED / NEEDS_CONTEXT
   - If BLOCKED or NEEDS_CONTEXT: provide context, re-dispatch
   - If DONE_WITH_CONCERNS: read concerns, decide if blockers or notes
4. **Dispatch spec compliance reviewer** (general-purpose agent) + **code quality reviewer** (`feature-dev:code-reviewer`) **IN PARALLEL**
5. **If spec ❌**: implementer fixes, spec re-reviews
6. **If code quality ❌**: implementer fixes, code quality re-reviews
7. **Mark phase complete, checkpoint with user** — show summary, ask about CI verification + next phase

### Commit + push pattern (per phase)

- Phase implementer commits with format: `phase-N: <name>\n\n<body>\n\nRefs: docs/.../...md Phase N\n\nCo-Authored-By: Claude Opus 4.7 (1M context) <noreply@anthropic.com>`
- Fix commits: `phase-N fix: <issue>\n\n<body>\n\nCo-Authored-By: ...`
- `git push origin claude/hungry-lamport-e41998` (NEVER `--tags`)
- `git tag phase-N-<name>` — LOCAL only

---

## 7 · Known tech debt (don't forget)

1. **Golden tests deferred** (Phase 2). Behavior tests substitute.
2. **Hive adapters hand-rolled** (Phase 3). Must hand-edit adapters when adding fields.
3. **`google_fonts` and `shimmer` removed** (Phase 0). Re-add if needed.
4. **Voice mode not in v1** — NSMicrophoneUsageDescription removed from Info.plist.
5. **No `--tags` push** — all phase tags are LOCAL.
6. **`HiveSetup._initialized` is process-wide static** — risk of flaky tests if re-init needed.
7. **anonymousSessionProvider not keepAlive** — if AuthInterceptor ever reads it via `container.read`, add `ref.keepAlive()` defensively. Phase 5 didn't wire it; Phase 6 may need to.
8. **freezed + hand-rolled Hive adapter** — adding fields requires BOTH `build_runner` AND hand-editing the adapter `read()`/`write()`.
9. **`/_dev/*` routes no `kReleaseMode` guard** — Phase 6 should add or defer to post-v1.
10. **AlertCard structural simplification** — current impl is single Column; canon N-01 has 4 zones. Acceptable for v1.
11. **AlertCard always uses `KaiIconName.alert`** — per-type glyphs deferred.
12. **Idle/sleep `strokePx`/`opacity` in `kai_tide.dart` are dead** — overridden by breathe animation.
13. **T36 microtask yield placement** — fires BEFORE `yield event` in `real_chat_repository.dart`. Spec says "after state event." Current placement pre-flushes cognitive queue before the event is delivered. Non-blocking — acceptable for v1.
14. **T33 test doesn't test error-swallowing** — the T33 group's happy-path test was renamed to accurately reflect what it covers. Genuine error-injection test deferred (requires Hive box override).
15. **messages still typed as `List<Map<String,dynamic>>`** — Phase 5 kept the prototype type. Phase 6 or post-v1: switch `ChatList.messages` and `RoomStateData.messages` to `List<Message>` (the Hive entity).
16. **NavScreen uses `sessionListProvider`** which calls `SessionRepository.list()` — this reads from mock (or real Hive if `USE_REAL_CHAT=true`). Nav panel session list only updates when provider is re-read. Phase 6 may want a watchable stream instead of a one-shot FutureProvider.

---

## 8 · Lessons learned during Phase 0-5 execution

- **Phase 5a implementer deviated on buildTestWidget**: feature-level tests used custom harnesses instead of `buildTestWidget`. Custom harnesses are legitimate (need provider overrides), but the spec required `buildTestWidget`. Going forward: tell implementers that custom wrappers are acceptable IF they're derived from or equivalent to `buildTestWidget`'s ProviderScope+MaterialApp+KaiTheme+Scaffold wrapping.
- **Spec reviewer is sharp**: caught `RoomFrame.live` vs `RoomFrame.streaming` bug — a state machine error invisible to casual reading.
- **Code quality reviewer is sharp**: caught StreamSubscription leak (ref.onDispose missing), raw Color literal, NavPanelRoute barrier not calling closeNavPanel. Trust their findings.
- **Concurrency in async* generators**: Dart generators suspend at every `await`. Mutable shared state (like `_cancelCompleters` map) must be claimed synchronously BEFORE the first `await` to avoid race windows. Lesson learned in Phase 5b.
- **`takeWhile` for cancel-safe `await for`**: checked-flag approach (`cancelCompleter.isCompleted`) works only between events. For a stalled stream, the generator hangs. `takeWhile((_) => !flag)` closes the stream at the Dart level on the next event boundary — sufficient for SSE (server always sends keepalives or closes).
- **`ref.read` vs `ref.watch` in Provider body**: using `ref.read` in Provider body breaks Riverpod's override mechanism (for tests). Always use `ref.watch`.

---

## 9 · User checkpoint pattern

After each phase passes both reviews:
- Mark task complete
- Summarize what was done (commits, files, tests)
- Surface tech debt
- Note CI verification needed (user does manually)
- Ask: "CI зелёный — продолжаем Phase N+1? Или есть вопросы?"

User communicates in Russian. Respond in Russian. Code/commits stay English.

---

## 10 · Your immediate next steps (Phase 6 controller)

1. Read: spec (`docs/superpowers/specs/2026-05-26-kai-app-rebuild-v3-design.md`), plan (`docs/superpowers/plans/2026-05-26-kai-app-rebuild-v3-implementation.md` § Phase 6 lines ~367-393), `new-design/CLAUDE.md`, this file in full.
2. Worktree setup (if fresh environment):
   ```bash
   cp .env.example .env
   dart run build_runner build
   ```
3. Run `git log --oneline -6` — confirm HEAD is `751ae63`. Run `flutter test` — confirm 197 passing. Run `flutter analyze` — confirm clean (2 pre-existing test warnings are OK).
4. **No Phase 0-5 review needed** — go straight to Phase 6.
5. Phase 6 has 26 sub-tasks (T6.1-T6.26) — consider splitting into 6a + 6b if implementer budget is a concern. Natural split: T6.1-T6.13 (connectivity, edge states, tide wiring, timer) vs T6.14-T6.26 (l10n, telemetry, coverage, final smoke, commit).
6. Dispatch Phase 6 implementer — embed full task text inline.
7. After implementer: dispatch spec + code quality reviewers in parallel.
8. Fix, re-review, checkpoint.
9. After Phase 6: dispatch `finishing-a-development-branch` skill OR dispatch a full-codebase code reviewer.
10. Checkpoint with user: "Phase 6 done. CI зелёный? Продолжаем к финальному review и PR?"

**КАЖДАЯ ФАЗА = НОВАЯ СЕССИЯ.** После Phase 6 обновляй этот handoff и пиши промпт для финального review.

Good luck.
