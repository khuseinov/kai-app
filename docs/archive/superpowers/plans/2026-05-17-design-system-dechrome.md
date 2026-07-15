# Design System Foundation + Dechrome Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Establish a single source of truth for design components (KaiCard, KaiEmptyState, KaiErrorView), eliminate all bespoke duplicate implementations, strip dev-noise chips from the chat bubble metadata row, and delete the redundant History feature.

**Architecture:** Three layers of work — (1) purge dead code so the codebase is clean before we start wiring, (2) wire the existing but unused design-system widgets everywhere their bespoke duplicates live, (3) simplify MessageMetadataRow to user-only signals and remove the dead History screen. No new abstractions — just consolidation of what already exists.

**Tech Stack:** Flutter 3.x, Riverpod, GoRouter, Freezed

---

## File Map

| File | Action |
|---|---|
| `lib/features/chat/presentation/widgets/typing_indicator.dart` | DELETE |
| `lib/core/design/components/kai_connectivity_pill.dart` | DELETE |
| `lib/core/providers/backend_health_provider.dart` | DELETE |
| `lib/core/network/health_poller.dart` | DELETE |
| `lib/features/settings/presentation/sections/language_section.dart` | DELETE |
| `lib/features/settings/presentation/settings_screen.dart` | MODIFY — remove language section |
| `lib/core/config/feature_flags.dart` | MODIFY — remove dead flags |
| `test/core/design/components/kai_connectivity_pill_test.dart` | DELETE |
| `lib/features/chat/presentation/widgets/session_drawer.dart` | MODIFY — replace `_DrawerEmptyState` with `KaiEmptyState` |
| `lib/features/history/presentation/history_screen.dart` | MODIFY — replace all bespoke empty/error/card |
| `lib/features/personal_context/presentation/personal_context_screen.dart` | MODIFY — replace bespoke empty/error |
| `lib/features/chat/presentation/widgets/message_metadata_row.dart` | MODIFY — strip dev chips, add `✓ N источников` + reactions |
| `test/features/chat/widgets/message_metadata_row_test.dart` | MODIFY — update for new interface |
| `lib/features/history/` (whole folder) | DELETE |
| `lib/features/history/logic/history_notifier.dart` | DELETE |
| `lib/features/history/data/history_remote_source.dart` | DELETE |
| `lib/core/providers/router_provider.dart` | MODIFY — remove `/history` route |

---

## Task 1: Purge dead code — unused widget files

**Files:**
- Delete: `lib/features/chat/presentation/widgets/typing_indicator.dart`
- Delete: `lib/core/design/components/kai_connectivity_pill.dart`
- Delete: `lib/core/providers/backend_health_provider.dart`
- Delete: `lib/core/network/health_poller.dart`
- Delete: `test/core/design/components/kai_connectivity_pill_test.dart`

- [ ] **Step 1: Verify zero imports before deleting**

```bash
grep -r "typing_indicator\|kai_connectivity_pill\|backend_health_provider\|health_poller" lib/ --include="*.dart" -l
```

Expected: no output (no files import them). If any file appears, fix the import first before proceeding.

- [ ] **Step 2: Delete the files**

```bash
rm lib/features/chat/presentation/widgets/typing_indicator.dart
rm lib/core/design/components/kai_connectivity_pill.dart
rm lib/core/providers/backend_health_provider.dart
rm lib/core/network/health_poller.dart
rm test/core/design/components/kai_connectivity_pill_test.dart
```

- [ ] **Step 3: Run analyze to confirm no breakage**

```bash
flutter analyze
```

Expected: zero new errors.

- [ ] **Step 4: Commit**

```bash
git add -u
git commit -m "chore: delete unused widgets and providers (TypingIndicator, KaiConnectivityPill, BackendHealthProvider, HealthPoller)"
```

---

## Task 2: Remove dead FeatureFlags and language section

**Files:**
- Modify: `lib/core/config/feature_flags.dart`
- Delete: `lib/features/settings/presentation/sections/language_section.dart`
- Modify: `lib/features/settings/presentation/settings_screen.dart`
- Modify: `lib/core/providers/settings_provider.dart` (remove `setLanguage`)

- [ ] **Step 1: Remove dead feature flags**

Open `lib/core/config/feature_flags.dart`. The file currently has `voiceEnabled` and `pushNotificationsEnabled` that nothing reads. Replace the whole file:

```dart
// Feature flags — all unused flags have been removed.
// Add flags here when a new feature is gated behind a server-side toggle.
class FeatureFlags {
  FeatureFlags._();
}
```

- [ ] **Step 2: Verify nothing reads the removed flags**

```bash
grep -r "voiceEnabled\|pushNotificationsEnabled" lib/ --include="*.dart"
```

Expected: no output.

- [ ] **Step 3: Delete language_section.dart**

```bash
rm lib/features/settings/presentation/sections/language_section.dart
```

- [ ] **Step 4: Remove language section from SettingsScreen**

Open `lib/features/settings/presentation/settings_screen.dart`. Remove the `LanguageSection` import and the `_Section('Язык', ...)` block:

```dart
import 'package:flutter/material.dart';

import '../../../core/design/theme/theme_extensions.dart';
import '../../../core/design/tokens/kai_spacing.dart';
import 'sections/delete_data_section.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final colors = context.kaiColors;
    final typography = context.kaiTypography;

    return Scaffold(
      backgroundColor: colors.background,
      appBar: AppBar(
        title: const Text('Настройки'),
        backgroundColor: colors.background,
        elevation: 0,
      ),
      body: ListView(
        padding: const EdgeInsets.all(KaiSpacing.l),
        children: [
          const _Section(
            title: 'Данные',
            children: [DeleteDataSection()],
          ),
          const SizedBox(height: KaiSpacing.l),
          _Section(
            title: 'О приложении',
            children: [
              ListTile(
                leading: const Icon(Icons.info_outline),
                title: const Text('Версия'),
                subtitle: Text(
                  '0.1.0',
                  style: typography.bodyMedium
                      .copyWith(color: colors.textSecondary),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
```

Note: Keep the `_Section` private class as-is (it's defined at the bottom of the same file).

- [ ] **Step 5: Remove `language` and `setLanguage` from settings provider**

Open `lib/core/providers/settings_provider.dart`. Find and remove:
- the `language` field from `AppSettings`
- the `setLanguage` method from the notifier

Search for these with:
```bash
grep -n "language\|setLanguage" lib/core/providers/settings_provider.dart
```

Remove only the `language` field and `setLanguage` method. Leave all other fields intact.

- [ ] **Step 6: Run analyze**

```bash
flutter analyze
```

Expected: zero errors. If `settings_provider.dart` is referenced elsewhere for `.language`, those references are already dead (backend ignores it) — remove them too.

- [ ] **Step 7: Commit**

```bash
git add -u
git commit -m "chore: remove dead FeatureFlags, broken language setting, and language section from Settings"
```

---

## Task 3: Wire KaiEmptyState — replace _DrawerEmptyState in SessionDrawer

**Files:**
- Modify: `lib/features/chat/presentation/widgets/session_drawer.dart`

The drawer has a private `_DrawerEmptyState` widget (at the bottom of the file). We delete it and use `KaiEmptyState` from the design system instead.

- [ ] **Step 1: Add KaiEmptyState import to session_drawer.dart**

At the top of `lib/features/chat/presentation/widgets/session_drawer.dart`, add:

```dart
import '../../../../core/design/components/kai_empty_state.dart';
```

- [ ] **Step 2: Replace _DrawerEmptyState usage**

Find the line that says `const _DrawerEmptyState()` (inside the `sessionState.sessions.isEmpty` branch). Replace it with:

```dart
const KaiEmptyState(
  icon: Icons.chat_bubble_outline,
  title: 'Нет разговоров',
  subtitle: 'Начните новый разговор',
),
```

- [ ] **Step 3: Delete the _DrawerEmptyState class**

Find and delete the entire `_DrawerEmptyState` class at the bottom of `session_drawer.dart`. It looks like:

```dart
class _DrawerEmptyState extends StatelessWidget {
  // ...
}
```

Delete it completely.

- [ ] **Step 4: Run analyze**

```bash
flutter analyze
```

Expected: zero errors.

- [ ] **Step 5: Commit**

```bash
git add lib/features/chat/presentation/widgets/session_drawer.dart
git commit -m "refactor(drawer): replace bespoke _DrawerEmptyState with KaiEmptyState"
```

---

## Task 4: Wire KaiEmptyState + KaiErrorView in HistoryScreen

**Files:**
- Modify: `lib/features/history/presentation/history_screen.dart`

The HistoryScreen has two bespoke patterns: an error block (Icon+Text) and an empty state (Icon+Text+Text). Replace both.

- [ ] **Step 1: Add imports to history_screen.dart**

At the top of `lib/features/history/presentation/history_screen.dart`, add:

```dart
import '../../../core/design/components/kai_empty_state.dart';
import '../../../core/design/components/kai_error_view.dart';
```

- [ ] **Step 2: Replace the bespoke error block in _SessionListView**

Find the `if (state.error != null)` block (lines ~54-70). Replace the entire block:

```dart
if (state.error != null) {
  return Center(
    child: KaiErrorView(
      message: state.error!,
      icon: Icons.cloud_off_outlined,
      onRetry: () =>
          ref.read(historyNotifierProvider.notifier).loadSessions(),
      retryLabel: 'Повторить',
    ),
  );
}
```

Note: `KaiErrorView` requires a `WidgetRef ref` in scope — `_SessionListView` is a `StatelessWidget`. Change the builder to `Consumer` to get `ref`, OR pass `onRetry` as a callback from the parent. The simplest approach: pass `onRetry` as a parameter:

Change `_SessionListView` to:

```dart
class _SessionListView extends StatelessWidget {
  final HistoryState state;
  final VoidCallback onRetry;

  const _SessionListView({required this.state, required this.onRetry});

  @override
  Widget build(BuildContext context) {
    if (state.isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (state.error != null) {
      return Center(
        child: KaiErrorView(
          message: state.error!,
          icon: Icons.cloud_off_outlined,
          onRetry: onRetry,
          retryLabel: 'Повторить',
        ),
      );
    }

    if (state.sessions.isEmpty) {
      return const Center(
        child: KaiEmptyState(
          icon: Icons.history,
          title: 'История пуста',
          subtitle: 'Ваши разговоры появятся здесь',
        ),
      );
    }

    return Consumer(
      builder: (context, ref, _) => ListView.separated(
        itemCount: state.sessions.length,
        separatorBuilder: (_, __) => Divider(
          color: Theme.of(context).dividerColor,
          height: 1,
        ),
        itemBuilder: (context, index) {
          final session = state.sessions[index];
          return _SessionTile(
            session: session,
            onTap: () => ref
                .read(historyNotifierProvider.notifier)
                .selectSession(session.sessionId),
          );
        },
      ),
    );
  }
}
```

- [ ] **Step 3: Update the call site in HistoryScreen.build**

In `HistoryScreen.build`, the call to `_SessionListView(state: state)` needs the new `onRetry` parameter:

```dart
body: state.selectedSessionId != null
    ? _MessagesView(sessionId: state.selectedSessionId!)
    : _SessionListView(
        state: state,
        onRetry: () =>
            ref.read(historyNotifierProvider.notifier).loadSessions(),
      ),
```

- [ ] **Step 4: Run analyze**

```bash
flutter analyze
```

Expected: zero errors.

- [ ] **Step 5: Commit**

```bash
git add lib/features/history/presentation/history_screen.dart
git commit -m "refactor(history): replace bespoke empty/error states with KaiEmptyState + KaiErrorView"
```

---

## Task 5: Wire KaiCard in HistoryScreen _MessageBubbleSimple

**Files:**
- Modify: `lib/features/history/presentation/history_screen.dart`

`_MessageBubbleSimple` has an inline `Container(decoration: BoxDecoration(borderRadius:..., border:..., color:...))`. Replace with `KaiCard`.

- [ ] **Step 1: Add KaiCard import to history_screen.dart**

```dart
import '../../../core/design/components/kai_card.dart';
```

- [ ] **Step 2: Replace _MessageBubbleSimple**

Find the `_MessageBubbleSimple` class (~lines 280-316). Replace its `build` method:

```dart
class _MessageBubbleSimple extends StatelessWidget {
  final HistoryMessage message;

  const _MessageBubbleSimple({required this.message});

  @override
  Widget build(BuildContext context) {
    final colors = context.kaiColors;
    final typography = context.kaiTypography;
    final isUser = message.role == 'user';

    return Align(
      alignment: isUser ? Alignment.centerRight : Alignment.centerLeft,
      child: ConstrainedBox(
        constraints: BoxConstraints(
          maxWidth: MediaQuery.of(context).size.width * 0.75,
        ),
        child: Padding(
          padding: const EdgeInsets.only(bottom: KaiSpacing.s),
          child: KaiCard(
            padding: const EdgeInsets.symmetric(
              horizontal: KaiSpacing.s,
              vertical: KaiSpacing.xs,
            ),
            highlighted: isUser,
            child: Text(
              message.content,
              style: typography.bodySmall.copyWith(color: colors.textPrimary),
            ),
          ),
        ),
      ),
    );
  }
}
```

- [ ] **Step 3: Run analyze**

```bash
flutter analyze
```

- [ ] **Step 4: Commit**

```bash
git add lib/features/history/presentation/history_screen.dart
git commit -m "refactor(history): replace bespoke _MessageBubbleSimple container with KaiCard"
```

---

## Task 6: Wire KaiEmptyState + KaiErrorView in PersonalContextScreen

**Files:**
- Modify: `lib/features/personal_context/presentation/personal_context_screen.dart`

PersonalContextScreen has a bespoke inline empty state (~line 73) and a `_ErrorChip` private class. Replace both.

- [ ] **Step 1: Add imports**

```dart
import '../../../core/design/components/kai_empty_state.dart';
import '../../../core/design/components/kai_error_view.dart';
```

- [ ] **Step 2: Replace bespoke empty state**

Find the `if (state.items.isEmpty && !state.isLoading)` block (~lines 73-90) and replace the inline `Column(children: [Icon(...), Text(...), Text(...)])` with:

```dart
if (state.items.isEmpty && !state.isLoading)
  const Center(
    child: KaiEmptyState(
      icon: Icons.person_outline,
      title: 'Нет инструкций',
      subtitle: 'Добавьте инструкции, чтобы Kai лучше вас понимал',
    ),
  ),
```

- [ ] **Step 3: Replace _ErrorChip with KaiErrorView**

Find `if (state.error != null)` block that shows `_ErrorChip(message: state.error!)`. Replace:

```dart
if (state.error != null) ...[
  KaiErrorView(message: state.error!),
  const SizedBox(height: KaiSpacing.m),
],
```

- [ ] **Step 4: Delete the _ErrorChip class**

Find and delete the entire `_ErrorChip` class from the bottom of the file.

- [ ] **Step 5: Run analyze**

```bash
flutter analyze
```

- [ ] **Step 6: Commit**

```bash
git add lib/features/personal_context/presentation/personal_context_screen.dart
git commit -m "refactor(personal-context): replace bespoke empty/error states with KaiEmptyState + KaiErrorView"
```

---

## Task 7: Simplify MessageMetadataRow — strip dev chips, add source count + reactions

**Files:**
- Modify: `lib/features/chat/presentation/widgets/message_metadata_row.dart`
- Modify: `test/features/chat/widgets/message_metadata_row_test.dart`

The row currently shows: mode badge, tool chips (9 types), revision count, scope escalation chip, advisor chip.

**New behaviour:**
- If `message.sources.isNotEmpty` → show `✓ Проверено в N источниках`
- Always show 👍 / 👎 reaction buttons (placeholder — `onPressed` shows a snackbar "Спасибо!")
- Return `SizedBox.shrink()` only if no sources AND message is user message

- [ ] **Step 1: Rewrite message_metadata_row.dart**

Replace the entire file content:

```dart
import 'package:flutter/material.dart';

import '../../../../core/design/theme/theme_extensions.dart';
import '../../../../core/design/tokens/kai_spacing.dart';
import '../../../../core/models/chat_message.dart';

/// User-facing message footer — shown under Kai responses only.
///
/// Shows:
///   • source verification count  (when tool sources exist)
///   • 👍 / 👎 reaction buttons   (always)
///
/// All dev signals (mode, tool names, provider, tokens, revision, advisor,
/// scope chip) are intentionally removed — available in the long-press
/// Detail Sheet when it ships.
class MessageMetadataRow extends StatelessWidget {
  final ChatMessage message;

  const MessageMetadataRow({super.key, required this.message});

  @override
  Widget build(BuildContext context) {
    if (message.isUser) return const SizedBox.shrink();

    final colors = context.kaiColors;
    final typography = context.kaiTypography;
    final sourceCount = message.sources.length;

    return Padding(
      padding: const EdgeInsets.only(
        top: KaiSpacing.xxxs,
        left: KaiSpacing.screenPadding,
        right: KaiSpacing.screenPadding,
        bottom: KaiSpacing.xxs,
      ),
      child: Row(
        children: [
          // Source verification count
          if (sourceCount > 0) ...[
            Icon(
              Icons.verified_outlined,
              size: 12,
              color: colors.textTertiary,
            ),
            const SizedBox(width: 4),
            Text(
              'Проверено в $sourceCount ${_sourcesLabel(sourceCount)}',
              style: typography.labelSmall.copyWith(
                color: colors.textTertiary,
                fontSize: 10,
              ),
            ),
          ],

          const Spacer(),

          // 👍 / 👎 reactions
          _ReactionButton(
            icon: Icons.thumb_up_outlined,
            onPressed: () => _showThanks(context),
          ),
          const SizedBox(width: 4),
          _ReactionButton(
            icon: Icons.thumb_down_outlined,
            onPressed: () => _showThanks(context),
          ),
        ],
      ),
    );
  }

  static String _sourcesLabel(int count) {
    if (count == 1) return 'источнике';
    if (count >= 2 && count <= 4) return 'источниках';
    return 'источниках';
  }

  static void _showThanks(BuildContext context) {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Спасибо за отзыв!'),
        duration: Duration(seconds: 2),
        behavior: SnackBarBehavior.floating,
      ),
    );
  }
}

class _ReactionButton extends StatelessWidget {
  final IconData icon;
  final VoidCallback onPressed;

  const _ReactionButton({required this.icon, required this.onPressed});

  @override
  Widget build(BuildContext context) {
    final colors = context.kaiColors;

    return GestureDetector(
      onTap: onPressed,
      child: Icon(
        icon,
        size: 14,
        color: colors.textTertiary,
      ),
    );
  }
}
```

- [ ] **Step 2: Update the test file**

Open `test/features/chat/widgets/message_metadata_row_test.dart`. Replace it with tests for the new interface:

```dart
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:kai_app/core/models/chat_message.dart';
import 'package:kai_app/core/models/tool_source.dart';
import 'package:kai_app/features/chat/presentation/widgets/message_metadata_row.dart';

import '../../../helpers/test_helpers.dart';

void main() {
  group('MessageMetadataRow', () {
    testWidgets('returns empty for user messages', (tester) async {
      final msg = _userMessage();
      await tester.pumpWidget(buildTestWidget(MessageMetadataRow(message: msg)));
      expect(find.byType(SizedBox), findsOneWidget);
      expect(find.byIcon(Icons.thumb_up_outlined), findsNothing);
    });

    testWidgets('shows reactions for Kai message with no sources', (tester) async {
      final msg = _kaiMessage(sources: []);
      await tester.pumpWidget(buildTestWidget(MessageMetadataRow(message: msg)));
      expect(find.byIcon(Icons.thumb_up_outlined), findsOneWidget);
      expect(find.byIcon(Icons.thumb_down_outlined), findsOneWidget);
      expect(find.byIcon(Icons.verified_outlined), findsNothing);
    });

    testWidgets('shows source count when sources present', (tester) async {
      final msg = _kaiMessage(sources: [_source(), _source()]);
      await tester.pumpWidget(buildTestWidget(MessageMetadataRow(message: msg)));
      expect(find.text('Проверено в 2 источниках'), findsOneWidget);
      expect(find.byIcon(Icons.verified_outlined), findsOneWidget);
    });

    testWidgets('does NOT show mode chip or tool chip', (tester) async {
      final msg = _kaiMessage(
        requestType: 'orchestrator',
        executedToolCalls: ['visa_checker'],
      );
      await tester.pumpWidget(buildTestWidget(MessageMetadataRow(message: msg)));
      expect(find.text('инструменты'), findsNothing);
      expect(find.text('виза'), findsNothing);
    });

    testWidgets('does NOT show revision or advisor chip', (tester) async {
      final msg = _kaiMessage(revisionCount: 2, advisorTriggered: true);
      await tester.pumpWidget(buildTestWidget(MessageMetadataRow(message: msg)));
      expect(find.text('перепроверено'), findsNothing);
      expect(find.text('Kai уточнил ответ ✓'), findsNothing);
    });
  });
}

ChatMessage _userMessage() => ChatMessage(
      id: '1',
      content: 'Привет',
      isUser: true,
      timestamp: DateTime.now(),
    );

ChatMessage _kaiMessage({
  List<ToolSource> sources = const [],
  String? requestType,
  List<String> executedToolCalls = const [],
  int? revisionCount,
  bool advisorTriggered = false,
}) =>
    ChatMessage(
      id: '2',
      content: 'Ответ Kai',
      isUser: false,
      timestamp: DateTime.now(),
      sources: sources,
      requestType: requestType,
      executedToolCalls: executedToolCalls,
      revisionCount: revisionCount,
      advisorTriggered: advisorTriggered,
    );

ToolSource _source() => const ToolSource(
      tool: 'visa_checker',
      source: 'https://example.com',
      fetchedAt: '2026-05-17T12:00:00Z',
    );
```

Note: `buildTestWidget` is a helper in `test/helpers/test_helpers.dart` that wraps a widget in `MaterialApp + ProviderScope` with the KAI theme applied. If this helper doesn't exist, create it:

```dart
// test/helpers/test_helpers.dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:kai_app/core/design/theme/app_theme.dart';

Widget buildTestWidget(Widget child) {
  return ProviderScope(
    child: MaterialApp(
      theme: AppTheme.dark(),
      home: Scaffold(body: child),
    ),
  );
}
```

- [ ] **Step 3: Run the metadata row tests**

```bash
flutter test test/features/chat/widgets/message_metadata_row_test.dart -v
```

Expected: all pass.

- [ ] **Step 4: Run full test suite**

```bash
flutter test
```

Expected: all pass (some tests for removed chips may fail — fix those in this step).

- [ ] **Step 5: Run analyze**

```bash
flutter analyze
```

- [ ] **Step 6: Commit**

```bash
git add lib/features/chat/presentation/widgets/message_metadata_row.dart \
        test/features/chat/widgets/message_metadata_row_test.dart \
        test/helpers/test_helpers.dart
git commit -m "feat(chat): simplify MessageMetadataRow — strip dev chips, add source count + reactions"
```

---

## Task 8: Delete History feature — folder + route

**Files:**
- Delete: `lib/features/history/` (all files)
- Modify: `lib/core/providers/router_provider.dart`
- Delete or modify: any test files in `test/features/history/`

- [ ] **Step 1: Check for references to HistoryScreen and historyNotifierProvider**

```bash
grep -r "HistoryScreen\|historyNotifierProvider\|history_screen\|history_notifier\|history_remote_source" lib/ --include="*.dart" -l
```

Expected files: `lib/core/providers/router_provider.dart`, `lib/features/history/` (the feature itself). If any file OUTSIDE `lib/features/history/` references the history feature, handle that first.

- [ ] **Step 2: Update router_provider.dart — remove /history route**

Replace `lib/core/providers/router_provider.dart` with:

```dart
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../features/auth/presentation/login_screen.dart';
import '../../features/auth/presentation/register_screen.dart';
import '../../features/chat/presentation/chat_screen.dart';
import '../../features/personal_context/presentation/personal_context_screen.dart';
import '../../features/settings/presentation/settings_screen.dart';

final routerProvider = Provider<GoRouter>((ref) {
  return GoRouter(
    initialLocation: '/chat',
    routes: [
      GoRoute(
        path: '/chat',
        builder: (context, state) => const ChatScreen(),
      ),
      GoRoute(
        path: '/login',
        builder: (context, state) => const LoginScreen(),
      ),
      GoRoute(
        path: '/register',
        builder: (context, state) => const RegisterScreen(),
      ),
      GoRoute(
        path: '/settings',
        builder: (context, state) => const SettingsScreen(),
      ),
      GoRoute(
        path: '/personal-context',
        builder: (context, state) => const PersonalContextScreen(),
      ),
    ],
  );
});
```

- [ ] **Step 3: Delete the history feature folder**

```bash
rm -rf lib/features/history/
```

- [ ] **Step 4: Delete history tests if they exist**

```bash
rm -rf test/features/history/
```

- [ ] **Step 5: Run analyze**

```bash
flutter analyze
```

Expected: zero errors. If any file still imports from `features/history`, fix that import now.

- [ ] **Step 6: Run tests**

```bash
flutter test
```

Expected: all pass.

- [ ] **Step 7: Commit**

```bash
git add -u
git rm -r lib/features/history/ 2>/dev/null || true
git commit -m "feat(nav): delete History screen — drawer covers sessions; remove /history route"
```

---

## Task 9: Remove BiaseTipCard and VerifyWarningCard from message_bubble

**Files:**
- Modify: `lib/features/chat/presentation/widgets/message_bubble.dart`
- Delete: `lib/features/chat/presentation/widgets/bias_tip_card.dart`
- Delete: `lib/features/chat/presentation/widgets/verify_warning_card.dart`

These two cards are dev-noise (BiasTipCard: performative epistemics nobody expands; VerifyWarningCard: superseded by source chips). Remove them from the bubble and delete the files.

- [ ] **Step 1: Find all usages in message_bubble.dart**

```bash
grep -n "BiasTipCard\|VerifyWarningCard\|bias_tip_card\|verify_warning_card" lib/features/chat/presentation/widgets/message_bubble.dart
```

Note the line numbers.

- [ ] **Step 2: Remove imports and usages from message_bubble.dart**

In `message_bubble.dart`, remove:
1. The import lines for `bias_tip_card.dart` and `verify_warning_card.dart`
2. Any `BiasTipCard(...)` widget usage inside the build method
3. Any `VerifyWarningCard(...)` widget usage inside the build method

The lines to remove will be of the form:
```dart
import 'bias_tip_card.dart';
import 'verify_warning_card.dart';
// and inside build:
if (message.biasSuggestions.isNotEmpty)
  BiasTipCard(suggestions: message.biasSuggestions),
if (!message.verificationPassed)
  VerifyWarningCard(reason: message.verificationFailReason),
```

Delete those lines (the `if (...)` + the widget call for each).

- [ ] **Step 3: Delete the widget files**

```bash
rm lib/features/chat/presentation/widgets/bias_tip_card.dart
rm lib/features/chat/presentation/widgets/verify_warning_card.dart
```

- [ ] **Step 4: Delete matching test files**

```bash
rm -f test/features/chat/widgets/bias_tip_card_test.dart
```

- [ ] **Step 5: Run analyze**

```bash
flutter analyze
```

- [ ] **Step 6: Run tests**

```bash
flutter test
```

- [ ] **Step 7: Commit**

```bash
git add -u
git commit -m "feat(chat): remove BiasTipCard and VerifyWarningCard — dev-noise removed from bubble"
```

---

## Task 10: Remove async_progress_card from message_bubble — merge into typing indicator

**Files:**
- Modify: `lib/features/chat/presentation/widgets/message_bubble.dart`
- Modify: `lib/features/chat/presentation/widgets/message_list.dart`

The `AsyncProgressCard` shows a spinner + elapsed time as a separate bubble when async tasks are pending. This should just be the existing `ChatLoadingIndicator` at the bottom of the list (which already shows when `isLoading == true`). Remove `AsyncProgressCard` from the bubble.

- [ ] **Step 1: Check how AsyncProgressCard is used**

```bash
grep -n "AsyncProgressCard\|async_progress_card" lib/features/chat/presentation/widgets/message_bubble.dart
```

Note the condition — typically `message.status == 'async_pending'` or similar.

- [ ] **Step 2: Remove AsyncProgressCard from message_bubble.dart**

Delete:
1. The import for `async_progress_card.dart`
2. The `if (...)` block that renders `AsyncProgressCard(...)`

- [ ] **Step 3: Delete the file**

```bash
rm lib/features/chat/presentation/widgets/async_progress_card.dart
rm -f test/features/chat/widgets/async_progress_card_test.dart
```

- [ ] **Step 4: Run analyze + test**

```bash
flutter analyze && flutter test
```

- [ ] **Step 5: Commit**

```bash
git add -u
git commit -m "feat(chat): remove AsyncProgressCard — async state shown via existing loading indicator"
```

---

## Self-Review

**Spec coverage check:**

| Spec requirement | Covered by task |
|---|---|
| Delete `typing_indicator.dart` | Task 1 |
| Delete `kai_connectivity_pill.dart` | Task 1 |
| Delete `backend_health_provider.dart` + `health_poller.dart` | Task 1 |
| Remove dead FeatureFlags | Task 2 |
| Remove language section (broken) | Task 2 |
| Wire `KaiEmptyState` in SessionDrawer | Task 3 |
| Wire `KaiEmptyState` + `KaiErrorView` in HistoryScreen | Task 4 |
| Wire `KaiCard` in HistoryScreen | Task 5 |
| Wire `KaiEmptyState` + `KaiErrorView` in PersonalContextScreen | Task 6 |
| Strip dev chips from MessageMetadataRow | Task 7 |
| Add `✓ N источников` source count | Task 7 |
| Add 👍👎 reactions | Task 7 |
| Delete History feature + route | Task 8 |
| Delete `BiasTipCard` + `VerifyWarningCard` | Task 9 |
| Delete `AsyncProgressCard` | Task 10 |

**Not in this plan (separate plans):**
- D8: InputSheet redesign (replace invisible pill with visible input bar + mic)
- D9: Zero-UI empty state on KaiScreen (only Kai sphere)
- D3: Unified ApprovalSurface (needs backend `POST /chat/confirm`)
- D4: CrisisCard full-bleed
- D6: Memory Screen (rebrand PersonalContext)
- D13: Liquid Glass + calm palette tokens

**Placeholder scan:** None found. All steps have concrete code.

**Type consistency:** `ChatMessage.sources: List<ToolSource>` used in Task 7 — matches the Freezed model definition in `lib/core/models/chat_message.dart:48`. `ToolSource` imported correctly.

---

Plan complete and saved to `docs/superpowers/plans/2026-05-17-design-system-dechrome.md`.
