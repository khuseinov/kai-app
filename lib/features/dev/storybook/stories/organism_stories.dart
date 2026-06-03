import 'package:flutter/material.dart';

import '../../../../design_system/atoms/atoms.dart';
import '../../../nav/components/kai_nav_panel.dart';
import '../../../nav/components/nav_models.dart';
import '../../../onboarding/components/kai_onboarding_card.dart';
import '../../../room/components/kai_chat_list.dart';
import '../../../room/components/kai_edge_state_block.dart';
import '../../../../design_system/theme/kai_theme.dart';
import '../../../../design_system/tokens/kai_tokens.dart';
import '../story_page.dart';
import '../story_registry.dart';
import '_story_helpers.dart';
import '../../../voice/voice_screen.dart';

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
        'crisis surfaces. Rate-limit CTA: ghost(accent, pill). '
        'Offline retry: ghost(warning, pill). Error retry: ghost(negative).',
    variants: ['offline', 'error', 'rateLimit', 'crisis'],
    build: (_) => _KaiEdgeStateBlockStory(),
  ),
  Story(
    layer: StoryLayer.organisms,
    name: 'KaiOnboardingCard',
    importPath: 'package:kai_app/design_system/organisms/organisms.dart',
    canonFile: 'new-design/onboarding.html',
    canonSelector: '.ob',
    description:
        'Four-step onboarding card (welcome/tide/gestures/context). Step 0 '
        'shows ink CTA with tide-flash on tap; steps 1–3 use solid ink-1 button.',
    variants: ['step 0 (welcome)', 'step 1 (tide)', 'step 2 (gestures)', 'step 3 (context)'],
    build: (_) => const _KaiOnboardingCardStory(),
  ),

  // ── Unbuilt screens — spec-preview stories ───────────────────────────────────
  // Voice, Fork, and Trip Detail component stories now live in the atom/molecule
  // layers (KaiKaraokeText, KaiTranscriptView → atoms; KaiForkChip,
  // KaiForkScoreDots, KaiForkCard → atoms/molecules; KaiBudgetBar → atoms).
  // Only Memory remains here as a screen-level placeholder (no single component
  // replaces the full memory screen yet).

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
    build: (_) => const _MemoryCanonStoryPage(),
  ),
  Story(
    layer: StoryLayer.organisms,
    name: 'Voice Screen',
    importPath: 'package:kai_app/features/voice/voice_screen.dart',
    canonFile: 'new-design/voice.html',
    canonSelector: '.voice',
    description:
        'Voice mode screen with 4 interactive states: waiting (idle), '
        'recording (listening), speaking (karaoke response), and '
        'timeline dialog history (transcript). Tap/swipe-driven transitions.',
    variants: const ['interactive screen demo'],
    build: (_) => const _VoiceScreenStoryPage(),
  ),
];

// ── Built organism stories ────────────────────────────────────────────────────

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

  /// Human-readable description for each frame variant.
  static String _frameDescription(RoomFrame f) => switch (f) {
        RoomFrame.empty => 'empty — no messages; Kai glyph + suggestion chips',
        RoomFrame.live => 'live — active conversation, messages shown',
        RoomFrame.panel =>
          'panel — nav panel open; chat dims to 25% opacity, non-interactive',
        RoomFrame.compose =>
          'compose — compose island expanded; dark scrim over chat',
        RoomFrame.streaming =>
          'streaming — Kai response in progress; animated tide bar at top',
        RoomFrame.error =>
          'error — shows retry prompt below messages',
      };

  @override
  Widget build(BuildContext context) {
    final c = KaiTheme.of(context).colors;
    return StoryPage(
      title: 'KaiChatList',
      layer: 'ORGANISM',
      blurb:
          'Scrollable chat feed composing all v3 bubble types. Frame controls '
          'the visual mode — use the picker below to switch frames.\n\n'
          'Note: panel and compose frames do not have their own overlay UI '
          'here — those layers are driven by RoomScreen. In this demo, panel '
          'dims the chat content and compose shows a dark scrim as specified.',
      sections: [
        StorySection('Frame picker', [
          StoryCell(
            'interactive',
            SizedBox(
              width: 360,
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
                  const SizedBox(height: KaiSpace.s2),
                  Text(
                    _frameDescription(_frame),
                    style: TextStyle(
                      fontFamily: 'JetBrainsMono',
                      fontSize: 9,
                      color: c.ink3,
                    ),
                  ),
                  const SizedBox(height: KaiSpace.s3),
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
            ),
          ),
        ]),
      ],
      usage: 'KaiChatList(\n'
          '  frame: RoomFrame.streaming,\n'
          '  messages: messages,\n'
          '  partialContent: partial,\n'
          '  onRetry: _retry,\n'
          ')',
      props: const [
        PropDoc('frame', 'RoomFrame', 'required',
            'empty/live/panel/compose/streaming/error'),
        PropDoc('messages', 'List<Map<String,dynamic>>', '[]',
            'Chat messages — role: user/kai/system/alert/care'),
        PropDoc('partialContent', 'String?', 'null',
            'Streaming partial text for the live Kai bubble'),
        PropDoc('onRetry', 'VoidCallback?', 'null',
            'Retry handler shown in error frame'),
      ],
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
    return StoryPage(
      title: 'KaiNavPanel',
      layer: 'ORGANISM',
      blurb:
          'Full-screen side navigation panel — trip folders, session list '
          'grouped by date, account anchor, memory + settings links. '
          'Constrained to 360 px wide in this demo (full-screen in RoomScreen).',
      sections: [
        StorySection('Default', [
          StoryCell(
            'full panel',
            SizedBox(
              width: 360,
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
          ),
        ]),
      ],
      usage: 'KaiNavPanel(\n'
          '  strings: KaiNavStrings.russian,\n'
          '  trips: trips,\n'
          '  sessions: sessions,\n'
          '  activeSessionId: id,\n'
          '  onSessionTap: (id) {},\n'
          ')',
      props: const [
        PropDoc('strings', 'KaiNavStrings', 'required', 'Localised labels'),
        PropDoc('trips', 'List<TripInfo>', '[]', 'Trip folder list'),
        PropDoc('sessions', 'List<SessionPreview>', '[]',
            'Session list (date-bucketed internally)'),
        PropDoc('activeSessionId', 'String?', 'null', 'Highlighted session'),
        PropDoc('pinnedTrip', 'TripInfo?', 'null', 'Pinned trip at top'),
      ],
    );
  }
}

class _KaiEdgeStateBlockStory extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return StoryPage(
      title: 'KaiEdgeStateBlock',
      layer: 'ORGANISM',
      blurb:
          'Composable edge-state block — inline in the chat feed or as a '
          'full-surface replacement. Four surfaces: offline, error, rateLimit, crisis.',
      sections: [
        StorySection('Surfaces', [
          StoryCell(
            'offline',
            SizedBox(
              width: 300,
              child: KaiEdgeStateBlock(
                surface: KaiEdgeSurface.offline,
                onRetry: () {},
              ),
            ),
          ),
          StoryCell(
            'error',
            SizedBox(
              width: 300,
              child: KaiEdgeStateBlock(
                surface: KaiEdgeSurface.error,
                onRetry: () {},
              ),
            ),
          ),
          StoryCell(
            'rateLimit',
            SizedBox(
              width: 300,
              child: KaiEdgeStateBlock(
                surface: KaiEdgeSurface.rateLimit,
                onPlans: () {},
                countdown: const Duration(seconds: 42),
              ),
            ),
          ),
          const StoryCell(
            'crisis',
            SizedBox(
              width: 300,
              child: KaiEdgeStateBlock(surface: KaiEdgeSurface.crisis),
            ),
          ),
        ]),
      ],
      usage: 'KaiEdgeStateBlock(\n'
          '  surface: KaiEdgeSurface.offline,\n'
          '  onRetry: _retry,\n'
          ')',
      props: const [
        PropDoc('surface', 'KaiEdgeSurface', 'required',
            'offline / error / rateLimit / crisis'),
        PropDoc('onRetry', 'VoidCallback?', 'null', 'Retry CTA (offline/error)'),
        PropDoc('onPlans', 'VoidCallback?', 'null', 'Upgrade CTA (rateLimit)'),
        PropDoc('countdown', 'Duration?', 'null', 'Cooldown timer (rateLimit)'),
      ],
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
    return StoryPage(
      title: 'KaiOnboardingCard',
      layer: 'ORGANISM',
      blurb:
          'Four-step onboarding card (welcome/tide/gestures/context). '
          'Step 0 CTA uses tide gradient; steps 1–3 use solid ink-1 button.',
      sections: [
        StorySection('Interactive (steps 0–3)', [
          StoryCell(
            'step picker',
            SizedBox(
              width: 360,
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
                  const SizedBox(height: KaiSpace.s3),
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
            ),
          ),
        ]),
      ],
      usage: 'KaiOnboardingCard(\n'
          '  stepIndex: 0,\n'
          '  onNext: () {},\n'
          '  onComplete: () {},\n'
          ')',
      props: const [
        PropDoc('stepIndex', 'int', 'required', '0–3'),
        PropDoc('onNext', 'VoidCallback', 'required', 'Advance to next step'),
        PropDoc('onComplete', 'VoidCallback', 'required',
            'Called after step 3 (last step)'),
      ],
    );
  }
}

// ── Canon spec-preview story wrapper — Memory only ────────────────────────────
//
// Voice, Fork, and Trip Detail component stories now live in atom/molecule
// layers. Memory remains here as a screen-level placeholder — no single
// component covers the full memory screen yet.

class _MemoryCanonStoryPage extends StatelessWidget {
  const _MemoryCanonStoryPage();

  @override
  Widget build(BuildContext context) {
    return const StoryPage(
      title: 'Memory Screen',
      layer: 'ORGANISM',
      blurb:
          'Canon spec preview — not yet built in Dart (Cycle 2).\n'
          'Facts grouped by category, searchable. '
          'Forget (danger) rows, memory hero card, toggle per-category.',
      sections: [
        StorySection('Spec preview', [
          StoryCell('memory.html', MemoryCanonPreview()),
        ]),
      ],
    );
  }
}

class _VoiceScreenStoryPage extends StatelessWidget {
  const _VoiceScreenStoryPage();

  @override
  Widget build(BuildContext context) {
    return const StoryPage(
      title: 'Voice Screen',
      layer: 'ORGANISM',
      blurb:
          'Fully interactive screen demo of the Voice mode. Includes '
          'speech-simulation timer, wave morph animation controls, and transcript history.',
      sections: [
        StorySection('Interactive Phone Frame', [
          StoryCell(
            'phone layout',
            SizedBox(
              width: 320,
              height: 568,
              child: ClipRRect(
                borderRadius: BorderRadius.all(Radius.circular(32)),
                child: VoiceScreen(),
              ),
            ),
          ),
        ]),
      ],
      usage: 'VoiceScreen()',
    );
  }
}
