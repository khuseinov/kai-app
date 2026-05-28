import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/providers/root.dart';
import '../../design_system/organisms/nav_panel.dart'
    show SessionPreview, TripInfo;
import '../../design_system/theme/kai_theme.dart';
import '../../design_system/tokens/kai_tokens.dart';
import '../../design_system/v3/atoms/atoms.dart';
import '../../design_system/v3/organisms/organisms.dart';

/// Visual gallery of every v3 organism.
///
/// Not a production surface — layout literals in the scaffold are acceptable.
class V3OrganismsShowcaseScreen extends ConsumerStatefulWidget {
  const V3OrganismsShowcaseScreen({super.key});

  @override
  ConsumerState<V3OrganismsShowcaseScreen> createState() =>
      _V3OrganismsShowcaseScreenState();
}

class _V3OrganismsShowcaseScreenState
    extends ConsumerState<V3OrganismsShowcaseScreen> {
  RoomFrame _chatFrame = RoomFrame.live;
  int _onboardingStep = 0;

  // ── Fixtures ─────────────────────────────────────────────────────────────────

  static final _messages = <Map<String, dynamic>>[
    {'role': 'user', 'content': 'Привет, Kai! Расскажи про визу в Японию.'},
    {
      'role': 'kai',
      'content':
          'Для туристической визы нужны загранпаспорт, фото и выписка из банка.',
      'sourcesLabel': '2 источника',
    },
    {
      'role': 'system',
      'content': 'Kai обновил воспоминание о поездке.',
    },
    {
      'role': 'alert',
      'alertType': 'warning',
      'content': 'Погода на маршруте изменилась',
      'body': 'Ожидается дождь в Токио на следующей неделе.',
      'time': '10:15',
    },
    {
      'role': 'user',
      'content': 'А сколько стоит перелёт?',
    },
    {
      'role': 'kai',
      'content': 'Прямые рейсы Москва→Токио от 45 000 ₽.',
    },
  ];

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
    final c = KaiTheme.of(context).colors;
    final themeMode = ref.watch(themeModeProvider);

    return Scaffold(
      backgroundColor: c.bg,
      appBar: AppBar(
        backgroundColor: c.bg,
        foregroundColor: c.ink1,
        title: const Text('v3 — Organisms'),
        actions: [
          IconButton(
            tooltip: 'Toggle light/dark',
            icon: Icon(
              themeMode == ThemeMode.dark
                  ? Icons.light_mode_outlined
                  : Icons.dark_mode_outlined,
              color: c.ink2,
            ),
            onPressed: () {
              ref.read(themeModeProvider.notifier).state =
                  themeMode == ThemeMode.dark
                      ? ThemeMode.light
                      : ThemeMode.dark;
            },
          ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.all(KaiSpace.s5),
        children: [
          // ── KaiChatList ───────────────────────────────────────────────────────
          _Section(
            title: 'KaiChatList — frame picker',
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Wrap(
                  spacing: KaiSpace.s2,
                  runSpacing: KaiSpace.s2,
                  children: RoomFrame.values.map((f) {
                    return KaiButton.ghost(
                      onPressed: () => setState(() => _chatFrame = f),
                      label: f.name,
                      tone: _chatFrame == f
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
                        frame: _chatFrame,
                        messages: _chatFrame == RoomFrame.empty
                            ? const []
                            : _messages,
                        partialContent: _chatFrame == RoomFrame.streaming
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
          const SizedBox(height: KaiSpace.s7),

          // ── KaiNavPanel ───────────────────────────────────────────────────────
          _Section(
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
          ),
          const SizedBox(height: KaiSpace.s7),

          // ── KaiEdgeStateBlock ─────────────────────────────────────────────────
          _Section(
            title: 'KaiEdgeStateBlock (all 4 surfaces)',
            child: Column(
              children: [
                KaiEdgeStateBlock(
                  surface: KaiEdgeSurface.offline,
                  onRetry: () {},
                ),
                const SizedBox(height: KaiSpace.s4),
                KaiEdgeStateBlock(
                  surface: KaiEdgeSurface.error,
                  onRetry: () {},
                ),
                const SizedBox(height: KaiSpace.s4),
                KaiEdgeStateBlock(
                  surface: KaiEdgeSurface.rateLimit,
                  onPlans: () {},
                  countdown: const Duration(seconds: 42),
                ),
                const SizedBox(height: KaiSpace.s4),
                const KaiEdgeStateBlock(
                  surface: KaiEdgeSurface.crisis,
                ),
              ],
            ),
          ),
          const SizedBox(height: KaiSpace.s7),

          // ── KaiOnboardingCard ─────────────────────────────────────────────────
          _Section(
            title: 'KaiOnboardingCard (steps 0–3)',
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Wrap(
                  spacing: KaiSpace.s2,
                  runSpacing: KaiSpace.s2,
                  children: List.generate(4, (i) {
                    return KaiButton.ghost(
                      onPressed: () => setState(() => _onboardingStep = i),
                      label: 'Step $i',
                      tone: _onboardingStep == i
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
                        stepIndex: _onboardingStep,
                        onNext: () => setState(() {
                          if (_onboardingStep < 3) _onboardingStep++;
                        }),
                        onComplete: () => setState(() {
                          _onboardingStep = 0;
                        }),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: KaiSpace.s11),
        ],
      ),
    );
  }
}

// ── Shared section header ─────────────────────────────────────────────────────

class _Section extends StatelessWidget {
  const _Section({required this.title, required this.child});

  final String title;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    final c = KaiTheme.of(context).colors;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(title.toUpperCase(), style: KaiType.micro(color: c.ink3)),
        const SizedBox(height: KaiSpace.s3),
        child,
      ],
    );
  }
}
