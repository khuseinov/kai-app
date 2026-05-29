import 'package:flutter/material.dart';

import '../../../../design_system/atoms/atoms.dart';
import '../../../../design_system/organisms/organisms.dart';
import '../../../../design_system/theme/kai_theme.dart';
import '../../../../design_system/tokens/kai_tokens.dart';
import '../story_registry.dart';
import '_story_helpers.dart';

final List<Story> organismStories = [
  Story(
    layer: StoryLayer.organisms,
    name: 'KaiChatList',
    importPath: 'package:kai_app/design_system/organisms/organisms.dart',
    canonFile: 'new-design/room.html',
    canonSelector: '.chat',
    description:
        'Scrollable chat message list composing all message types. Six '
        'RoomFrame variants control visual mode (empty/live/panel/compose/streaming/error).',
    variants: ['empty', 'live', 'panel', 'compose', 'streaming', 'error'],
    build: (_) => const _KaiChatListStory(),
  ),
  Story(
    layer: StoryLayer.organisms,
    name: 'KaiNavPanel',
    importPath: 'package:kai_app/design_system/organisms/organisms.dart',
    canonFile: 'new-design/nav.html',
    canonSelector: '.panel',
    description:
        'Full-screen side navigation panel — trip folders, session list '
        'grouped by date, account anchor, memory and settings links.',
    variants: [
      'KaiNavPanel(strings: KaiNavStrings.russian, trips, sessions, ...)',
    ],
    build: (_) => const _KaiNavPanelStory(),
  ),
  Story(
    layer: StoryLayer.organisms,
    name: 'KaiEdgeStateBlock',
    importPath: 'package:kai_app/design_system/organisms/organisms.dart',
    canonFile: 'new-design/edge-states.html',
    canonSelector: '.edge-state',
    description:
        'Composable edge-state block for offline, error, rate-limit, and '
        'crisis surfaces. Each surface has a distinct CTA button style.',
    variants: ['offline', 'error', 'rateLimit', 'crisis'],
    build: (_) => const _KaiEdgeStateBlockStory(),
  ),
  Story(
    layer: StoryLayer.organisms,
    name: 'KaiOnboardingCard',
    importPath: 'package:kai_app/design_system/organisms/organisms.dart',
    canonFile: 'new-design/onboarding.html',
    canonSelector: '.ob',
    description:
        'Four-step onboarding card (welcome/tide/gestures/context). Step 0 '
        'uses tide CTA; steps 1–3 use solid ink-1 button.',
    variants: ['step 0 (welcome)', 'step 1 (tide)', 'step 2 (gestures)', 'step 3 (context)'],
    build: (_) => const _KaiOnboardingCardStory(),
  ),

  // ── Unbuilt screens — spec-preview stories ───────────────────────────────────

  Story(
    layer: StoryLayer.organisms,
    name: 'Voice Screen (canon)',
    importPath: 'new-design/voice.html',
    canonFile: 'new-design/voice.html',
    canonSelector: '.voice-screen',
    description:
        'Voice mode surface — always dark (#08080A), never responds to theme. '
        'Karaoke word-reveal + transcript timeline. Not yet built in Dart.',
    variants: ['waiting', 'listening', 'speaking-karaoke', 'transcript'],
    build: (ctx) => const VoiceCanonPreview(),
  ),

  Story(
    layer: StoryLayer.organisms,
    name: 'Memory Screen (canon)',
    importPath: 'new-design/memory.html',
    canonFile: 'new-design/memory.html',
    canonSelector: '.memory-screen',
    description:
        'Memory management screen — facts grouped by category, searchable. '
        'Forget (danger) rows, memory hero card, toggle per-category. '
        'Not yet built in Dart.',
    variants: ['default', 'search active', 'fact expanded', 'category collapsed'],
    build: (ctx) => const MemoryCanonPreview(),
  ),

  Story(
    layer: StoryLayer.organisms,
    name: 'Trip Detail Screen (canon)',
    importPath: 'new-design/trip-detail.html',
    canonFile: 'new-design/trip-detail.html',
    canonSelector: '.trip-screen',
    description:
        'Trip detail — hero card (glyph + name + stats + budget bar), facts grid, '
        'chat items, source list, Q&A chips, "Ask about this" CTA. '
        'Not yet built in Dart.',
    variants: ['default', 'scrolled', 'chat tab'],
    build: (ctx) => const TripDetailCanonPreview(),
  ),

  Story(
    layer: StoryLayer.organisms,
    name: 'KaiForkCard (canon)',
    importPath: 'package:kai_app/design_system/organisms/organisms.dart',
    canonFile: 'new-design/fork.html',
    canonSelector: '.fc',
    description:
        'Multi-country comparison card — in-chat molecule with two-column layout '
        'comparing trip options. Visa chips (8px w600 r999), rating dots (5×5px), '
        'budget rows, country headers (~65px). Not yet built in Dart.',
    variants: ['normal', 'win column highlighted'],
    build: (ctx) => const ForkCardCanonPreview(),
  ),
];

// ── Organisms ─────────────────────────────────────────────────────────────────

class _KaiChatListStory extends StatefulWidget {
  const _KaiChatListStory();

  @override
  State<_KaiChatListStory> createState() => _KaiChatListStoryState();
}

class _KaiChatListStoryState extends State<_KaiChatListStory> {
  RoomFrame _frame = RoomFrame.live;

  static final _messages = <Map<String, dynamic>>[
    {'role': 'user', 'content': 'Привет, Kai! Расскажи про визу в Японию.'},
    {
      'role': 'kai',
      'content':
          'Для туристической визы нужны загранпаспорт, фото и выписка из банка.',
      'sourcesLabel': '2 источника',
    },
    {'role': 'system', 'content': 'Kai обновил воспоминание о поездке.'},
    {
      'role': 'alert',
      'alertType': 'warning',
      'content': 'Погода на маршруте изменилась',
      'body': 'Ожидается дождь в Токио на следующей неделе.',
      'time': '10:15',
    },
    {'role': 'user', 'content': 'А сколько стоит перелёт?'},
    {'role': 'kai', 'content': 'Прямые рейсы Москва→Токио от 45 000 ₽.'},
  ];

  @override
  Widget build(BuildContext context) {
    final c = KaiTheme.of(context).colors;
    return StorySection(
      title: 'KaiChatList — frame picker',
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Wrap(
            spacing: KaiSpace.s2,
            runSpacing: KaiSpace.s2,
            children: RoomFrame.values.map((f) {
              return KaiButton.ghost(
                onPressed: () => setState(() => _frame = f),
                label: f.name,
                tone: _frame == f
                    ? KaiButtonTone.accent
                    : KaiButtonTone.neutral,
              );
            }).toList(),
          ),
          const SizedBox(height: KaiSpace.s4),
          SizedBox(
            height: 320,
            child: ClipRRect(
              borderRadius: KaiRadius.br3,
              child: ColoredBox(
                color: c.bg,
                child: KaiChatList(
                  frame: _frame,
                  messages:
                      _frame == RoomFrame.empty ? const [] : _messages,
                  partialContent: _frame == RoomFrame.streaming
                      ? 'Ищу информацию о рейсах…'
                      : null,
                  onRetry: () {},
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _KaiNavPanelStory extends StatelessWidget {
  const _KaiNavPanelStory();

  static final _trips = <TripInfo>[
    const TripInfo(
      id: 'trip-1',
      title: 'Токио 2026',
      subtitle: 'апр — май 2026',
      initial: 'Т',
      chatCount: 4,
    ),
    const TripInfo(
      id: 'trip-2',
      title: 'Бали',
      subtitle: 'июнь 2026',
      initial: 'Б',
      chatCount: 2,
    ),
  ];

  static final _sessions = <SessionPreview>[
    SessionPreview(
      id: 'session-1',
      title: 'Виза в Японию',
      timeLabel: '9:41',
      createdAt: DateTime.now(),
    ),
    SessionPreview(
      id: 'session-2',
      title: 'Отели в Токио',
      timeLabel: '10:15',
      createdAt: DateTime.now().subtract(const Duration(hours: 2)),
    ),
    SessionPreview(
      id: 'session-3',
      title: 'Маршрут по Бали',
      timeLabel: '12 мая',
      createdAt: DateTime.now().subtract(const Duration(days: 8)),
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return StorySection(
      title: 'KaiNavPanel',
      child: SizedBox(
        height: 520,
        child: ClipRRect(
          borderRadius: KaiRadius.br3,
          child: KaiNavPanel(
            strings: KaiNavStrings.russian,
            onClose: () {},
            onNewChat: () {},
            trips: _trips,
            sessions: _sessions,
            activeSessionId: 'session-1',
            onSessionTap: (_) {},
            onTripTap: (_) {},
            accountInitial: 'R',
            accountName: 'Rustam K.',
            accountPlan: 'Pro',
            hasUnseenMemory: true,
            onMemoryTap: () {},
            onSettingsTap: () {},
            pinnedTrip: _trips.first,
          ),
        ),
      ),
    );
  }
}

class _KaiEdgeStateBlockStory extends StatelessWidget {
  const _KaiEdgeStateBlockStory();

  @override
  Widget build(BuildContext context) {
    return StorySection(
      title: 'KaiEdgeStateBlock (all 4 surfaces)',
      child: Column(
        children: [
          KaiEdgeStateBlock(surface: KaiEdgeSurface.offline, onRetry: () {}),
          const SizedBox(height: KaiSpace.s4),
          KaiEdgeStateBlock(surface: KaiEdgeSurface.error, onRetry: () {}),
          const SizedBox(height: KaiSpace.s4),
          KaiEdgeStateBlock(
            surface: KaiEdgeSurface.rateLimit,
            onPlans: () {},
            countdown: const Duration(seconds: 42),
          ),
          const SizedBox(height: KaiSpace.s4),
          const KaiEdgeStateBlock(surface: KaiEdgeSurface.crisis),
        ],
      ),
    );
  }
}

class _KaiOnboardingCardStory extends StatefulWidget {
  const _KaiOnboardingCardStory();

  @override
  State<_KaiOnboardingCardStory> createState() =>
      _KaiOnboardingCardStoryState();
}

class _KaiOnboardingCardStoryState extends State<_KaiOnboardingCardStory> {
  int _step = 0;

  @override
  Widget build(BuildContext context) {
    final c = KaiTheme.of(context).colors;
    return StorySection(
      title: 'KaiOnboardingCard (steps 0–3)',
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Wrap(
            spacing: KaiSpace.s2,
            runSpacing: KaiSpace.s2,
            children: List.generate(4, (i) {
              return KaiButton.ghost(
                onPressed: () => setState(() => _step = i),
                label: 'Step $i',
                tone: _step == i
                    ? KaiButtonTone.accent
                    : KaiButtonTone.neutral,
              );
            }),
          ),
          const SizedBox(height: KaiSpace.s4),
          SizedBox(
            height: 480,
            child: ClipRRect(
              borderRadius: KaiRadius.br3,
              child: ColoredBox(
                color: c.bg,
                child: KaiOnboardingCard(
                  stepIndex: _step,
                  onNext: () => setState(() {
                    if (_step < 3) _step++;
                  }),
                  onComplete: () => setState(() => _step = 0),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
