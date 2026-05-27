# Kai App Rebuild v3 — Context Transfer for Phase 4b+

**Date**: 2026-05-27 (updated after Phase 4a completion)
**From session**: Phase 4a controller (Phases 0-3 review + Phase 4a organisms)
**To**: new agent session starting Phase 4b
**Reason**: каждая фаза = новая сессия (user requirement)

---

## 1 · Your job

You are the SDD (subagent-driven-development) **controller** continuing execution of the Kai app rebuild v3 plan from **Phase 4b** onwards. Phases 0–4a are DONE. You inherit state, not history.

**Mandatory first action**: read these files before doing anything else:
1. `docs/superpowers/specs/2026-05-26-kai-app-rebuild-v3-design.md` (design spec)
2. `docs/superpowers/plans/2026-05-26-kai-app-rebuild-v3-implementation.md` (134-task plan)
3. `new-design/CLAUDE.md` (design system hard rules — non-negotiable)
4. This file in full.

Then verify state with `git log --oneline -6` and `flutter test` before dispatching any implementer.

**Do NOT run a Phase 0-3 review** — that was already done by the previous controller. Go straight to Phase 4b.

---

## 2 · Hard constraints (NEVER violate)

### Branch & worktree

- **Work ONLY on branch `claude/hungry-lamport-e41998`** (the worktree branch). User explicitly said: "только в одной ветке работаем" (one branch only).
- Working directory: `E:\startup\kai-app\.claude\worktrees\hungry-lamport-e41998`
- DO NOT create new branches.
- DO NOT touch `master` — it's the legacy app, the backup if rebuild fails.
- DO NOT push tags to origin. Phase tags are LOCAL ONLY. The previous wipe (2026-05-26) was caused by force-deleting origin tags; we avoid the scenario entirely.

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

## 3 · Current state (as of 2026-05-27 — after Phase 4a)

### Branch position

- HEAD: `d62e867` on `origin/claude/hungry-lamport-e41998`
- 13 commits since branch off master:
  ```
  d62e867 phase-4a fix: review findings (spec + code quality)
  bc119e9 phase-4a: organisms (onboarding_card, chat_list, nav_panel, edge_state_block)
  f37086d phase-3 fix-2: design canon + ephemeral race
  9f6fdf1 docs(handoff): context transfer for Phase 4+ controller
  cf6ab20 phase-3 fix: error resilience + adapter consistency
  54332c8 phase-3: molecules + storage
  9468721 phase-2 fix: ephemeral cycle stale controller + error wobble duration
  46a2ec5 phase-2: atoms + anonymous session
  25d569d phase-1 fix: code review issues (Important x3, Minor x2)
  1d215dd phase-1: foundation (tokens, theme, fonts, dio skeleton)
  b91b6a2 phase-0 fix: align bootstrap signature with plan T0.3
  cd8ba93 phase-0: wipe lib/ + scaffold blank shell
  0717601 docs(plan): Kai app rebuild v3 implementation plan
  ```

### Local tags (NOT pushed to origin)

- `phase-0-wipe` → `cd8ba93`
- `phase-1-foundation` → `1d215dd`
- `phase-2-atoms` → `46a2ec5`
- `phase-3-molecules` → `54332c8`
- `phase-4a-organisms` → `d62e867`

### Test + lint state

- `flutter analyze` → "No issues found!" (verified at `d62e867`)
- `flutter test` → 131/131 passing (verified at `d62e867`)

### iOS CI

Status unknown to controller (no `gh` CLI). User verifies manually at https://github.com/khuseinov/kai-app/actions filtered by branch `claude/hungry-lamport-e41998`.

---

## 4 · What's been built (Phase 0-3 summary)

### Phase 0 — Wipe ✅

- `git rm -rf lib/ test/` — wiped legacy
- Scaffold: `lib/main.dart` + `lib/bootstrap.dart` (returns `Future<ProviderContainer>`) + `lib/app.dart`
- `pubspec.yaml`: removed `google_fonts`, `shimmer`; added `flutter_dotenv ^5.1.0`, `flutter_svg ^2.0.10`
- `ios/Runner/Info.plist`: removed `NSMicrophoneUsageDescription`
- `.env.example` tracked; `.env` ignored; `.gitignore` has `!.env.example` negation
- `assets/fonts/.gitkeep`, `assets/icons/.gitkeep`

### Phase 1 — Foundation ✅

- **Tokens** (7 files in `lib/design_system/tokens/`):
  - `kai_colors.dart` — Light + Dark records, all 20+ colors exact hex from `new-design/colors_and_type.css`
  - `kai_space.dart` — s1..s11 as `double` (4-120, for const EdgeInsets composability)
  - `kai_radius.dart` — r1..r5 + pill, plus `static const BorderRadius` `br1..brPill` (NOT getters — true compile-time const)
  - `kai_motion.dart` — durations + curves (ambient/exit identical-by-design per comment)
  - `kai_type.dart` — 10 TextStyle factories (hero/display/h1..h3/lead/body/small/micro/mono) with em→absolute px letterSpacing
  - `kai_tide.dart` — 3-stop gradient at 115° via `Alignment(-0.906, -0.423)→(0.906, 0.423)` + 8 state configs. `KaiTideState` class (NOT enum) with const instances `KaiTide.idle / .listening / ...`. Idle/sleep have breathe animation per HTML canon (JSON null but HTML wins).
  - `kai_tokens.dart` — composite `KaiTokens` record

- **Theme** (2 files in `lib/design_system/theme/`):
  - `kai_theme.dart` — InheritedWidget `KaiTheme.of(context)`, ConsumerWidget pulling `themeModeProvider`
  - `kai_theme_ext.dart` — Material `ThemeExtension` bridge + `materialLight()` / `materialDark()` factories

- **Fonts** (in `assets/fonts/`):
  - `Manrope.ttf` — variable 300-800, renamed from `Manrope[wght].ttf` (lessons learned: tooling breaks on `[wght]`)
  - `JetBrainsMono.ttf` — variable 400-500, renamed similarly
  - Registered in `pubspec.yaml` with explicit per-weight entries (so variable axis used, no synthetic bold)

- **Backend skeleton** (in `lib/core/network/`):
  - `dio_client.dart` — factory `buildDioClient(baseUrl, interceptors)`, 30s connect / 300s receive
  - 5 interceptors in `lib/core/network/interceptors/`: auth (pass-through TODO), logging (correlation IDs via uuid, debug-only), retry (exp backoff max 3, skip 401/403/429, **attaches Dio via `attach(dio)` to retry through full chain**), connectivity (offline early-fail via connectivity_plus), error (NetworkFailure enum + NetworkException)

- **Riverpod** (in `lib/core/providers/root.dart`):
  - `envProvider` → `EnvConfig`
  - `dioProvider` → Dio with interceptor chain; calls `retry.attach(dio)`
  - `themeModeProvider` → `StateProvider<ThemeMode>` default `ThemeMode.system`
  - `routerProvider` → GoRouter from `lib/core/routing/router.dart`

- **App wiring**:
  - `lib/app.dart` — ConsumerWidget; `MaterialApp.router` with theme + `builder: (ctx, child) => KaiTheme(child: ...)` **inside MaterialApp** (Phase 1 fix: KaiTheme outside breaks `MediaQuery.platformBrightnessOf`)
  - `lib/bootstrap.dart` — `Future<ProviderContainer> bootstrap()`, loads `.env` (try/catch), calls `HiveSetup.init()` (try/catch, logger.e + rethrow on fail), returns ProviderContainer
  - `lib/core/routing/router.dart` — go_router with `/_dev` hub + `/_dev/theme-showcase` + `/_dev/atoms` + `/_dev/molecules` routes

- **Showcases**:
  - `lib/features/dev/theme_showcase_screen.dart` — Colors/Type/Space/Radius/Tide sections + theme cycle

- **Tests**: 15 passing in `test/design_system/tokens_test.dart` + `test/design_system/theme_test.dart`

### Phase 2 — Atoms ✅

- **6 atom files** in `lib/design_system/atoms/`:
  - `kai_text.dart` — StatelessWidget with named constructors per style; resolves color via `KaiTheme.of(context)`
  - `kai_icon.dart` — `KaiIconName` enum (14 values) + `KaiIcon` widget using flutter_svg + ColorFilter
  - `kai_button.dart` — 4 variants (.tide/.ink1/.ghost/.icon); imports ONLY `KaiIconName` enum from kai_icon.dart (NOT the widget — atomic boundary preserved); inline `SvgPicture.asset(...)` for icon rendering
  - `kai_button_send.dart` — separate atom; `KaiSendState` enum (ready/disabled/sending/streaming); `onPressed: VoidCallback?` (nullable for ComposeIsland double-gate); pulse animation via AnimationController on sending/streaming
  - `kai_input.dart` — KaiTextField with pillRadius toggle + maxLines
  - `kai_bubble.dart` — 3 variants (.user/.kai/.system); kai uses flutter_markdown MarkdownBody
  - `kai_tide_curve.dart` — CustomPainter with 8 animated states. **The crown jewel.** Key implementation details:
    - SVG path `M 0 14 Q 60 8 120 14 T 240 12` → `quadraticBezierTo` (T reflected as `Q 180 20 240 12`)
    - ViewBox 240×28 → scaled to widget size via sx/sy
    - Gradient stroke (not fill), `strokeCap.round`, `PaintingStyle.stroke`
    - Dashed paths via `PathMetric.extractPath` iteration
    - 8 animations: idle (5.5s breathe HTML canon), sleep (7s breathe HTML canon), listening (2.2s bob), thinking (3s flow dash 6/4), responding (1.4s stream dash 12/4), success (1.2s flash × 3 ephemeral), error (700ms wobble × 2 with 1s delay ephemeral), memory (0.9s pop × 3 with 0.5s delay ephemeral)
    - Ephemeral states track `_restoreToState` and revert via `_runEphemeralCycle` with mounted guards (fixed in 9468721: no-gap branch uses fresh recursive call, not stale captured controller)
    - `MediaQuery.disableAnimationsOf` respected — static frame when true

- **Anonymous session** in `lib/core/session/anonymous_session_provider.dart`:
  - `secureStorageProvider` → `FlutterSecureStorage`
  - `anonymousSessionProvider` → FutureProvider<String> generating + persisting uuid v4 under key `anonymous_session_id_v1`
  - NOT using `@Riverpod(keepAlive: true)` annotation — plain FutureProvider keeps state alive while listened, simpler

- **Showcase**: `lib/features/dev/atoms_showcase_screen.dart` with tide state cycle button
- **Tests**: 58 passing (28 widget tests across atoms + session tests)
- **Tech debt**: golden tests deferred (cross-platform CustomPaint shader variance). Behavior tests substitute.

### Phase 3 — Molecules + Storage ✅

- **5 molecules** in `lib/design_system/molecules/`:
  - `compose_island.dart` — pill input + mic LEFT + send RIGHT, ListenableBuilder for reactive send state, double-gate disabled via `onPressed: sendState == disabled ? null : onSend`
  - `nav_item.dart` — icon + label + trailing slots, active state with accent-wash + left border
  - `source_card.dart` — index badge mono + url + timestamp + freshness icon
  - `alert_card.dart` — N-01 4 types (urgent → negativeWash, warning → warningWash, positive → positiveWash, neutral → accentWash)
  - `care_block.dart` — crisis C3 left-border 2px coral `#C44A3C`, heart icon, mono resources, NEVER red

- **Storage** in `lib/core/storage/`:
  - 3 versioned Hive boxes: `chat_sessions_v1`, `messages_v1`, `settings_v1`
  - Entities with `@HiveType`/`@HiveField` annotations (Session typeId 0, Message typeId 1, MessageStatus typeId 2, MessageRole typeId 3, AppThemeMode typeId 4, AppSettings typeId 5)
  - **CRITICAL deviation from plan**: Hive adapters are **HAND-ROLLED**, not generated via build_runner. Reason: `hive_generator ^2.0.1` pins `analyzer <7` which conflicts with `freezed ^2.5.6`'s `analyzer ^7.0.0`. The `@HiveType`/`@HiveField` annotations remain as documentation of wire layout. When you add new fields to entities in future phases, you MUST hand-edit the adapter `read()`/`write()` methods to match. There's no build_runner safety net for these.
  - All adapters use **nullable-cast-with-default pattern** (e.g., `fields[0] as String? ?? ''`) for migration safety. AppSettings/Session/Message adapters all consistent.
  - `hive_setup.dart` — `HiveSetup.init()` with `_initialized` guard; opens all 3 boxes via `Future.wait`
  - `bootstrap.dart` — wraps `HiveSetup.init()` in try/catch with `logger.e + rethrow`

- **Showcase**: `lib/features/dev/molecules_showcase_screen.dart`
- **Tests**: 91 passing after fix-2 (storage roundtrips for all enum values, per-molecule behavior, per-entity adapter roundtrips + B1 regression test)

### Phase 4a — Organisms ✅ (commits bc119e9 + d62e867)

- **4 organism files** in `lib/design_system/organisms/`:
  - `onboarding_card.dart` — 4-step wizard (welcome/tide/gestures/context). Step 1 auto-cycles 3 tide chips every 2400ms, KaiTideCurve tracks active chip. `_syncController()` + `didUpdateWidget` ensures animation only runs on step 1. Props: `stepIndex (int 0-3)`, `onComplete (VoidCallback?)`.
  - `chat_list.dart` — 6 frames via `RoomFrame` enum (empty/live/panel/compose/streaming/error). `RoomFrame` enum defined in this file. Messages typed as `List<Map<String, dynamic>>` (Phase 5 will replace with `List<Message>`). `_syncStream()` + `didUpdateWidget` ensures streaming animation only runs on streaming frame. Panel frame uses `IgnorePointer(child: Opacity(0.25, ...))`.
  - `nav_panel.dart` — full-screen drawer: close button (28px circle) + "Kai" title + new chat (KaiButton.ink1) + read-only search box + sessions list (NavItem per session) + apps section (Memory/Settings) + account anchor pushed to bottom via Expanded sessions. Prop name: `activeSessionId` (String?, singular). Swipe-left (velocity < -200) fires onClose.
  - `edge_state_block.dart` — 4 surfaces via `EdgeSurface` enum (offline/error/rateLimit/crisis). Offline: `tokens.colors.warning` dot + retry ghost button. Error: negativeWash + KaiTideCurve(KaiTide.error) + **KaiButton.ghost('Повторить')** (not ink1). RateLimit: warningWash + countdown text if provided. Crisis: KaiTideCurve at 0.3 opacity + CareBlock embedded.

- **Shared test helper** created: `test/test_helpers.dart` — `buildTestWidget(Widget)` wraps with ProviderScope + KaiTheme + Scaffold (was missing from codebase; created in Phase 4a).

- **Tests**: 131 passing (+40 organism tests; all use `buildTestWidget` from test/test_helpers.dart).

- **Key design decisions**:
  - `Color(0xFFC44A3C)` coral: established allowed raw color (CareBlock + EdgeStateBlock error icon)
  - `tokens.colors.warning` used for offline yellow dot (confirmed token exists: `#B57A0B` light / `#D69E3E` dark)
  - `tokens.colors.surface` for selected language chip text in OnboardingCard step 3

---

## 5 · What's still pending

### Phase 4b — Repo Interfaces + Mocks (T4.30-T4.44) ← NEXT

Plan section: `docs/superpowers/plans/2026-05-26-kai-app-rebuild-v3-implementation.md` § "Phase 4" around line 350-370.

**T4.30** `lib/core/repositories/chat_repository.dart` — abstract interface:
```dart
abstract class ChatRepository {
  Stream<ChatEvent> sendMessage(String text, String sessionId);
  Future<void> cancelStreaming(String sessionId);
}
```

**T4.31** Define `ChatEvent` sealed class — 8 variants (message/thinking/state/metadata/approval/correction/done/error). Prefer hand-written sealed class (avoids codegen). If using freezed, committed `.freezed.dart` is tracked in git.

**T4.32** Run `dart run build_runner build` ONLY if using freezed codegen (plain, no `--delete-conflicting-outputs`).

**T4.33** `lib/core/repositories/mock_chat_repository.dart` — in-memory + faked streaming with realistic delays (100-300ms). Cover: multi-chunk message, correction event, done, error path, cancel (cancelStreaming completes stream).

**T4.34** `test/core/mock_chat_repository_test.dart` — event ordering, cancel, error scenarios

**T4.35** `lib/core/repositories/session_repository.dart` — abstract: `list()`, `create({String? tripId})`, `delete(String id)`

**T4.36** `lib/core/repositories/mock_session_repository.dart` — in-memory list

**T4.37** `test/core/mock_session_repository_test.dart`

**T4.38** Update `lib/core/providers/root.dart` — add `chatRepositoryProvider` and `sessionRepositoryProvider` pointing to mock implementations

**T4.39** `lib/features/dev/organisms_showcase_screen.dart` — visual demo of all 4 organisms with switchers

**T4.40** Update `lib/core/routing/router.dart` — add `/_dev/organisms` route pointing to organisms showcase

**T4.41** `flutter test` — all 131+ tests pass

**T4.42** Commit: `phase-4b: repo interfaces + mocks + showcase`

**T4.43** Push: `git push -u origin claude/hungry-lamport-e41998` (NEVER `--tags`)

**T4.44** Local tag: `git tag phase-4-organisms` (final Phase 4 tag, local only — NEVER push)

### Phase 5 — Screens + Real SSE backend (41 sub-tasks T5.1-T5.41)

Plan section around line 370-415. The biggest deliverable phase: real SSE chat with the 8 baked-in legacy patterns from T8-T37 (optimistic persist-then-stream, cancel-aware drain via Future.any + cancelCompleter, session-switch guard, microtask yield for cognitive status, correction-replaces-not-appends, _safelyPersistMessages, stream-started guard, emit failedUserMessage first).

Components:
- `lib/features/onboarding/onboarding_screen.dart` — 4-step PageView
- `lib/features/room/room_screen.dart` + `room_state.dart` — Riverpod notifier driving ChatList frame + tide state
- `lib/features/nav/nav_screen.dart` — side panel host
- Router: `/`, `/onboarding`, `/room`, `/room/:tripId` with bootstrap redirect on `settings.onboarded` flag
- `lib/core/network/sse_parser.dart` — UTF-8 line splitter, 8 event types
- `lib/core/repositories/real_chat_repository.dart` — implements ChatRepository with all 8 legacy patterns
- `lib/core/repositories/real_session_repository.dart` — Hive-backed
- Switch mocks → real in providers/root.dart

### Phase 6 — Edge States + Polish (26 sub-tasks T6.1-T6.26)

Plan section around line 415-440. Final phase:
- Offline detection → EdgeStateBlock inline
- Rate-limit (429) → soft message + disable compose
- Crisis pattern detection → CareBlock in Kai bubble
- Tide state transitions wired to RoomState
- 60s inactivity → sleep state
- l10n setup (en + ru ARBs)
- Telemetry hook placeholder
- Final smoke test, coverage thresholds (design_system 70%, features 60%, core/repositories 80%)

### Final review + finishing-a-development-branch

After Phase 6: dispatch full-implementation code reviewer agent. Then user decides: PR to master, or merge inline, or leave as-is on branch.

---

## 6 · Methodology — SDD flow (use exactly this)

For each phase:

1. **Mark phase task in_progress** in TodoWrite/TaskList
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
4. **Dispatch spec compliance reviewer** (general-purpose agent)
   - "Don't trust implementer's report — verify by reading actual code"
   - Specifies what to verify
5. **If spec ❌**: implementer fixes, spec re-reviews
6. **Once spec ✅, dispatch code quality reviewer** (`feature-dev:code-reviewer` agent)
   - Focuses on craft, not spec compliance
7. **If code quality ❌**: implementer fixes, code quality re-reviews
8. **Mark phase complete, checkpoint with user** — show summary, ask about CI verification + next phase
9. **Repeat for next phase**

### Implementer dispatch tips

- Embed full task text — don't make subagent open plan file (preserves their context budget)
- Be explicit about file paths
- Mention that previous phase work is already in HEAD — they can read existing files
- Tell them what to do if they run out of budget mid-task (report what's working, BLOCK with details)
- Limit code-gen complexity (e.g., for Hive adapters, hand-rolled is the established pattern in Phase 3 due to analyzer conflict)

### Commit + push pattern (per phase)

- Phase implementer commits with format: `phase-N: <name>\n\n<body>\n\nRefs: docs/.../...md Phase N\n\nCo-Authored-By: Claude Opus 4.7 (1M context) <noreply@anthropic.com>`
- Fix commits: `phase-N fix: <issue>\n\n<body>\n\nCo-Authored-By: ...`
- `git push -u origin claude/hungry-lamport-e41998` (NEVER `--tags`)
- `git tag phase-N-<name>` — LOCAL only

---

## 7 · Known tech debt (don't forget)

1. **Golden tests deferred** (Phase 2). Behavior tests substitute. Document for follow-up after v1 — generate on macOS CI runner.
2. **Hive adapters hand-rolled** (Phase 3). Must hand-edit adapters when adding fields. Watch for the analyzer pin conflict if upgrading deps.
3. **`google_fonts` and `shimmer` removed from pubspec** (Phase 0). If a future feature wants them, re-add explicitly.
4. **Voice mode not in v1** — `NSMicrophoneUsageDescription` removed from Info.plist. If voice is added later, restore the key.
5. **No `--tags` push** — all phase tags are LOCAL. Don't push them to avoid replaying the 2026-05-26 wipe incident.
6. **`HiveSetup._initialized` is process-wide static** — risks flaky tests if any future test calls `HiveSetup.init()` after `tearDownTestHive()`. No fix today (no current test triggers it). Recommended: add test-only `reset()` if Phase 5+ tests need full re-init.
7. **anonymousSessionProvider not keepAlive** — in Riverpod 2.x plain FutureProvider does not autodispose by default (handoff §4 is correct), but in Phase 5 the AuthInterceptor will read sessionId via `container.read` — that's a one-shot read with no listener. Add `ref.keepAlive()` defensively to the provider when wiring AuthInterceptor in Phase 5, OR establish a long-lived listener in app bootstrap.
8. **freezed entity field additions require BOTH `build_runner` AND hand-edited Hive adapter** — `.g.dart` / `.freezed.dart` regenerate on `dart run build_runner build`, but the hand-rolled Hive adapter is silent if a field is added to the freezed class. Update comment in session/message/settings adapter files (or hive_setup.dart) to mention this explicitly.
9. **`/_dev/*` routes have no `kReleaseMode` guard** — known Phase 5 work. The current `/` redirect targets `/_dev` unconditionally; Phase 5 implementer must rewire to `/onboarding` or `/room` based on `settings.onboarded` flag AND guard dev routes behind `kReleaseMode` (or strip via build flavor).
10. **AlertCard is structurally simpler than canon N-01** — current impl is single Column (icon + title + body + action). Canon `notifications-chat.html` has 4 zones: `.ac-head` (type chip + timestamp + dismiss), `.ac-icon`, `.ac-body`, `.ac-actions`. Acceptable for current scope; revisit when AlertCard is composed into Phase 4 organisms or first real proactive alert use-case lands.
11. **AlertCard always uses `KaiIconName.alert` glyph** — canon N-01 has per-type glyphs (alert-triangle / info / check / bell). Either expose `icon` param to caller or derive from type. Some icons may need adding to `KaiIconName` enum.
12. **Idle/sleep `strokePx`/`opacity` in `kai_tide.dart` are dead during breathe** — values declared but overridden by `breatheStroke/Opacity From/To` at runtime. Confusing for readers. Add inline comment OR drop the base values.

---

## 8 · Lessons learned during Phase 0-3 execution

- **Implementer budget**: Phase 2 implementer hit budget mid-T2.5 without committing. Symptom: agent returns abruptly with partial work in untracked files. Recovery: dispatch fresh agent with explicit "pick up from T2.X" prompt, verify untracked state, finish remaining tasks. **Recommendation**: for Phase 4 (44 sub-tasks), pre-emptively split into 4a + 4b.
- **Code reviewer is sharp**: caught a real bug each phase (Phase 1 KaiTheme above MaterialApp, Phase 2 stale controller in ephemeral, Phase 3 bootstrap no try/catch). Trust their findings; verify with grep/read; dispatch fix; re-review.
- **Spec reviewer rigour**: also caught real things (Phase 0 bootstrap signature didn't match plan T0.3 — my mistake in implementer prompt). Always verify against the plan text, not just the implementer's summary.
- **flutter analyze must stay clean**: every phase must keep `flutter analyze` returning "No issues found!". Lints are strict (prefer_single_quotes, omit_local_variable_types, always_declare_return_types, avoid_print).
- **HTML > JSON for design canon**: when `new-design/tide-states.html` and `new-design/design-tokens.json` disagree, HTML wins (e.g. idle/sleep breathe in HTML even though JSON says `animation: null`).

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

## 10 · Your immediate next steps (Phase 4b controller)

1. Read: spec, plan, new-design/CLAUDE.md, this file.
2. Run `git log --oneline -6` — confirm HEAD is `d62e867`. Run `flutter test` — confirm 131 passing. Run `flutter analyze` — confirm clean.
3. **No Phase 0-3 review needed** — already done. Go straight to Phase 4b.
4. Dispatch Phase 4b implementer subagent with the T4.30-T4.44 task text from Section 5 above.
5. After implementer: dispatch spec compliance reviewer + code quality reviewer in parallel.
6. Fix any issues found.
7. Checkpoint with user: CI зелёный? Продолжаем Phase 5?

**КАЖДАЯ ФАЗА = НОВАЯ СЕССИЯ.** После Phase 4b обновляй этот handoff-документ (Section 3, 4, 5, 10) и пиши контекст-промпт для следующей сессии.

Good luck.
