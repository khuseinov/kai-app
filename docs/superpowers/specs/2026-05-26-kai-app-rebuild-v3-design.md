# Kai App — Rebuild v3 Design Spec

**Date**: 2026-05-26
**Author**: rustam.wize@gmail.com (via brainstorming session)
**Status**: Draft — awaiting user review
**Supersedes**: Previous rebuild attempt (wiped 2026-05-26)

---

## 1 · Context & Goal

Снести существующий Flutter UI на master (legacy app до redesign) и пересобрать с нуля по готовой дизайн-системе `new-design/`, используя atomic-design подход: tokens → atoms → molecules → organisms → screens. Backend integration (network, storage, repositories) развивается параллельной решёткой вместе с UI слоями.

**Previous attempt context**: `rebuild/v2` ветка с Phase 0 + Phase 1 была полностью wiped 2026-05-26 (force-deleted branches + tags). master остался как backup. Lessons learned документированы в memory и применяются ниже.

**Source of truth chain** (`new-design/CLAUDE.md`): tokens → foundations → components → nav → room → deeper screens.

---

## 2 · Scope (v1)

### Включено

**Design system implementation**:
- Tokens (colors, space, radius, motion, type, tide states) — codegen из `design-tokens.json`
- Theme (light + dark, InheritedWidget + Material ThemeExtension bridge)
- Atoms: KaiButton (4 variants), KaiInput, KaiBubble, KaiTideCurve (8 states), KaiIcon, KaiText
- Molecules: ComposeIsland, NavItem, SourceCard, AlertCard (N-01 4 types), CareBlock
- Organisms: NavPanel, ChatList, OnboardingCard, EdgeStateBlock

**Screens**:
- Onboarding (4 steps: welcome / tide / gestures / context)
- Room (chat, 6 frames driven by state: empty / live / panel / compose / streaming / error)
- Nav panel (full-screen swipe-from-left drawer)
- Edge states (offline / rate-limit / error / crisis-in-conversation)

**Backend**:
- Anonymous session (device-uuid, flutter_secure_storage)
- Hive storage (chat_sessions_v1, messages_v1, settings_v1 — versioned)
- Dio client + interceptors
- SSE chat streaming (real implementation Phase 5)
- Repository pattern: ChatRepository, SessionRepository (interfaces + mocks → real)

**Tests**:
- Golden tests per atom (light + dark)
- Pixel-tolerant snapshot for TideCurve all 8 states
- Widget behavior tests per molecule
- Integration tests per organism
- Scenario tests per screen
- Hive migration tests per version bump
- SSE pipeline regression suite (ported from legacy T8-T37)

### Не включено в v1

- Voice mode (`voice.html`)
- Memory app (`memory.html`)
- Settings screen (`settings.html`)
- Trip detail (`trip-detail.html`)
- Multi-Country Fork (`fork.html`)
- Notifications chat alerts (`notifications-chat.html`)
- Marketing landing (`landing.html`)
- Authentication (anonymous mode only — auth добавим позже когда design появится)
- Android (iOS-only в v1; android/ существует но не таргетируем)

---

## 3 · Architecture

### Папочная структура `lib/`

```
lib/
├── main.dart                 — entry, runApp(KaiApp)
├── app.dart                  — MaterialApp + KaiTheme + Router
├── bootstrap.dart            — async init (Hive, fonts, dotenv, session id)
│
├── design_system/            — design system implementation
│   ├── tokens/
│   │   ├── kai_tokens.dart   — главный экспорт (codegen из design-tokens.json)
│   │   ├── kai_colors.dart   — Light + Dark records
│   │   ├── kai_space.dart    — s1..s11
│   │   ├── kai_radius.dart   — r1..r5 + pill
│   │   ├── kai_motion.dart   — durations + curves
│   │   ├── kai_type.dart     — hero..mono scale
│   │   └── kai_tide.dart     — gradient stops + 8 state configs
│   ├── theme/
│   │   ├── kai_theme.dart    — InheritedWidget + ThemeMode
│   │   └── kai_theme_ext.dart— Material ThemeExtension bridge
│   ├── atoms/                — KaiButton, KaiInput, KaiBubble, KaiTideCurve, KaiIcon, KaiText
│   ├── molecules/            — ComposeIsland, NavItem, SourceCard, AlertCard, CareBlock
│   └── organisms/            — NavPanel, ChatList, OnboardingCard, EdgeStateBlock
│
├── features/                 — screens compose organisms + state
│   ├── onboarding/
│   ├── room/
│   └── nav/
│
├── core/                     — cross-cutting concerns
│   ├── routing/              — go_router config
│   ├── session/              — anonymous device-uuid provider
│   ├── network/              — Dio + interceptors + SSE client
│   ├── storage/              — Hive boxes setup
│   ├── repositories/         — ChatRepository, SessionRepository
│   └── providers/            — Riverpod root providers
│
└── l10n/                     — Russian + English ARBs
```

### Architectural principles

1. **Atomic Design strict**: atoms cannot import molecules; molecules cannot import organisms; organisms used by features only.
2. **Tokens always typed**: no `Color(0xFF...)` outside `design_system/tokens/`. Every color from `KaiTheme.of(context).colors.<name>`.
3. **Theme-independent tide**: `KaiTide` not exposed through `KaiColors`. Gradient identical in light + dark.
4. **One primary action per screen**: only one `KaiButton.tide()` allowed per screen scope (lint-level rule — manual review for v1).
5. **Zero-UI**: no persistent chrome. Nav panel = modal swipe-from-left, compose = sheet swipe-up, never pinned.
6. **State-driven frames**: Room screen renders one of 6 frames based on `RoomState`. Single ChatList widget, frame selector internal.

---

## 4 · Phasing (Phase 0 wipe + 6 phases — Approach B)

| Phase | UI layer | Backend lattice | Deliverable |
|---|---|---|---|
| **0 — Wipe** | `git rm -rf lib/ test/`, scaffold `lib/main.dart` minimal stub, scaffold `lib/bootstrap.dart`, scaffold `lib/app.dart`. iOS CI must still pass (boots to blank screen). | n/a | First commit: clean slate. iOS CI green on empty shell. |
| **1 — Foundation** | tokens, theme, fonts (Manrope + JetBrainsMono local TTF), KaiTheme showcase | Dio client skeleton, .env, interceptor placeholder | `--theme-showcase` demo screen toggling light/dark |
| **2 — Atoms** | KaiButton(4) / KaiInput / KaiBubble / KaiTideCurve(8 states) / KaiIcon / KaiText | Anonymous device-uuid `@Riverpod(keepAlive: true)` provider | `--atoms-showcase` route + golden tests |
| **3 — Molecules + Storage** | ComposeIsland / NavItem / SourceCard / AlertCard / CareBlock | Hive boxes `chat_sessions_v1`, `messages_v1`, `settings_v1`; migration scaffold | `--molecules-showcase` route + Hive integration tests |
| **4 — Organisms + Repo Interfaces** | NavPanel / ChatList / OnboardingCard / EdgeStateBlock | `ChatRepository`, `SessionRepository` interfaces + mock impls | Routable demo of every organism |
| **5 — Screens + Real Backend** | Onboarding (4 steps), Room (6 frames), Nav panel host, routing | SSE chat client (real), Riverpod glue (`chatProvider`), Hive incremental writes | First working chat end-to-end |
| **6 — Edge States + Polish** | offline / rate-limit / error / crisis UI surfaces; tide state wiring to RoomState; 60s sleep timer | connectivity_plus listener, retry policy, telemetry hook | Full v1 |

### Per-phase exit criteria

- iOS CI зелёный (`.github/workflows/ios_build.yml`).
- Tests добавлены для нового layer.
- Local tag `phase-N-<name>` создан. **НЕ push в origin до v1 complete** (avoid repeating force-delete wipe).

---

## 5 · Components — detailed specs

### KaiButton variants

| Variant | Use | Visual |
|---|---|---|
| `KaiButton.tide()` | one primary per screen (Send, "Start using Kai") | tide gradient fill, white text, `0 2px 8px rgba(43,168,201,0.18)` shadow |
| `KaiButton.ink1()` | secondary actions | ink-1 fill, white text, no shadow |
| `KaiButton.ghost()` | tertiary, cancel | transparent + 1px line border |
| `KaiButton.icon()` | inside inputs (mic, send), hug edge | pill radius, never overflow rounded corner |

### KaiButton.send states (canon-locked)

| State | Visual |
|---|---|
| `ready` | tide gradient + soft shadow |
| `disabled` | `ink-4` fill, opacity 0.5 (NOT ink-1 — canon forbids black-in-pill as fake CTA) |
| `sending` / `streaming` | tide gradient + micro scale-pulse (120ms) |

### KaiTideCurve — 8 states (from `design-tokens.json § tide-states`)

| State | Stroke | Color | Opacity | Animation |
|---|---|---|---|---|
| idle | 1.5px | ink-4 | 0.4 | none |
| listening | 2px | tide gradient | 0.8 | bob 2200ms ambient |
| thinking | 2px | tide gradient (dash `6 4`) | 0.85 | flow R→L 3000ms linear |
| responding | 2.5px | tide gradient (dash `12 4`) | 1.0 | stream R→L 1400ms linear |
| success | 2.5px | gradient-success | 1.0 | flash 1200ms ease-out (ephemeral) |
| error | 2px | gradient-error | 0.95 | wobble 600ms × 2 (ephemeral) |
| memory | 2px | tide gradient | 1.0 | pop 900ms ease-out (ephemeral) |
| sleep | 1px | ink-4 | 0.2 | none (after 60s inactivity) |

**Implementation note**: HTML визуальный canon важнее JSON для разногласий (lessons learned re: `tide-states.html` показывает breath для idle/sleep хотя JSON говорит `animation: null`).

### KaiBubble — 3 variants

| Variant | Background | Use |
|---|---|---|
| user | `surface-2` | user message |
| kai | `bg` | Kai reply |
| system | inline text | system notice (rate-limit warning, etc.) |

### Molecules

- **ComposeIsland**: pill input (`radius: pill`) + mic toggle (icon button hugs LEFT edge) + send (KaiButton.send hugs RIGHT edge). Icons never overflow corner.
- **NavItem**: list tile (trip / date / app entry).
- **SourceCard**: tool receipt under each Kai message, mono font for URLs.
- **AlertCard** (N-01): 4 types — urgent (negative wash) / warning (warning wash) / positive (positive wash) / neutral (accent wash).
- **CareBlock**: crisis C3 left-border accent inside Kai reply, warm coral `#C44A3C` (never red).

### Organisms

- **NavPanel**: full-screen swipe-from-left drawer (NOT pinned). Drag handler in Room screen. Contains trips + dates + apps section (Memory, Settings).
- **ChatList**: state-driven 6-frame rendering — empty / live / panel / compose / streaming / error. Single widget, internal frame selector.
- **OnboardingCard**: 4-screen wizard (welcome / tide / gestures / context).
- **EdgeStateBlock**: composable surfaces for offline / rate-limit / error / crisis.

---

## 6 · Backend Lattice

### Anonymous session

- Device-uuid generated на first run, stored in `flutter_secure_storage`.
- Riverpod provider `anonymousSessionProvider` — `@Riverpod(keepAlive: true)` (singleton, lessons learned: autoDispose default).
- Header `X-Anonymous-Session: <uuid>` added by Dio interceptor.

### Network

- Dio client base URL from `.env` (loaded via `flutter_dotenv` in bootstrap).
- Interceptors: anonymous session, request/response logging (debug only), retry policy.
- SSE streaming: Dio response stream + manual SSE parser. Pattern restored from legacy lessons:
  - `error` and `done` events terminate stream
  - Cancel path → message status `error` (not `failed`)
  - `Completer.complete()` always guarded: `if (!c.isCompleted) c.complete(...)`
  - `failedUserMessage` emitted via `onUpdate` in error/cancel paths
  - Microtask yield in state handler preserves `KaiCognitiveStatus` queue

### Storage

Hive boxes (versioned):
- `chat_sessions_v1` — `Session(id, title, createdAt, tripId?)`
- `messages_v1` — `Message(id, sessionId, role, status, content, createdAt)`
- `settings_v1` — `Settings(themeMode, locale)`

Migration scaffold from day 1 — when bumping a box version, write migration function with regression test (legacy T25/T26 pattern).

### Repositories

```dart
abstract class ChatRepository {
  Stream<ChatEvent> sendMessage(String text, String sessionId);
  Future<void> cancelStreaming(String sessionId);
}

abstract class SessionRepository {
  Future<List<Session>> list();
  Future<Session> create({String? tripId});
  Future<void> delete(String id);
}
```

Phase 4: mock implementations (in-memory + faked streaming with delays). Phase 5: real implementations bound to Dio + Hive.

### Routing — go_router

```
/                  → bootstrap redirect (onboarding done? → /room ELSE → /onboarding)
/onboarding        → onboarding flow (4 steps via inner pages)
/room              → chat (default session)
/room/:tripId      → trip-scoped chat
```

Side panel: modal route with custom transition (swipe from left), not part of declarative tree. Bottom tabs forbidden (Zero-UI canon).

---

## 7 · Testing Strategy

| Layer | Tests | Tools |
|---|---|---|
| Atoms | Golden (light + dark, all variants) | `flutter_test` goldens |
| TideCurve | Pixel-tolerant snapshot per state (tolerance 0.02) | `flutter_test` |
| Molecules | Widget behavior (interaction, render per prop) | `flutter_test` |
| Organisms | Integration (state transitions, gestures) | `flutter_test` |
| Screens | Scenario (onboarding flow, send-message E2E) | `flutter_test` + mock repos |
| Storage | Hive migration tests per box version bump | `hive_test` |
| SSE pipeline | Regression suite ported from legacy T8-T37 | `mockito` |

Coverage target: 70% for `design_system/`, 60% for `features/`, 80% for `core/repositories/`.

---

## 8 · Risk Management

### Lessons learned baked in (memory)

| Trap | Mitigation |
|---|---|
| Riverpod 3 autoDispose default | `@Riverpod(keepAlive: true)` for session, settings, root state |
| Completer race in SSE | Always `if (!c.isCompleted) c.complete(...)` |
| Variable TTF tooling | Rename `Manrope-VariableFont_wght.ttf` → `Manrope.ttf` before adding to assets |
| build_runner `--delete-conflicting-outputs` deprecated (2.5+) | Plain `dart run build_runner build` |
| `tide-states.html` visual canon vs JSON | Implementation matches HTML when JSON says `animation: null` but HTML shows breath |
| auto_route v10 part-builder | N/A — we use go_router |
| Codegen freezed/json_serializable | iOS CI runs `dart run build_runner build` (existing `ios_build.yml` line preserved) |

### Branch & history protection

- Work in worktree branch `claude/hungry-lamport-e41998`.
- Master untouched until v1 complete and user approves merge.
- Per-phase tag is LOCAL only — do not push tags to origin until v1 complete (avoid repeating force-delete wipe).
- If rebuild needs restart: `git reset --hard origin/master` (master = legacy backup, intact).

### Lock-list (NEVER touch)

- `ios/Runner.xcodeproj/project.pbxproj` — iOS CI signing (root `CLAUDE.md`)
- `.github/workflows/ios_build.yml`
- `android/`, `web/`, `windows/`, `macos/`, `linux/`
- `pubspec.yaml` name field (`kai_app`)

### Dependency stability

`pubspec.yaml` deps remain largely as-is. Additions for v1:
- `flutter_dotenv` (env config)
- `flutter_svg` (KaiIcon)

Removals deferred — only after v1 complete, audit unused deps.

---

## 9 · Open Questions

None at design time. If implementation reveals ambiguity, ask before coding.

---

## 10 · Deliverable

End of Phase 6: working iOS build with onboarding → room flow, real chat streaming, 4 edge-state surfaces, full design system fundamental implementation, tests на каждом layer. iOS CI зелёный. master не тронут до user-approved merge.
