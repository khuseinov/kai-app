import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../design_system/organisms/chat_list.dart';
import '../../design_system/organisms/edge_state_block.dart';
import '../../design_system/organisms/nav_panel.dart';
import '../../design_system/organisms/onboarding_card.dart';
import '../../design_system/theme/kai_theme.dart';
import '../../design_system/tokens/kai_tokens.dart';

class OrganismsShowcaseScreen extends ConsumerStatefulWidget {
  const OrganismsShowcaseScreen({super.key});

  @override
  ConsumerState<OrganismsShowcaseScreen> createState() =>
      _OrganismsShowcaseScreenState();
}

class _OrganismsShowcaseScreenState
    extends ConsumerState<OrganismsShowcaseScreen> {
  var _onboardingStep = 0;
  var _roomFrame = RoomFrame.empty;
  var _edgeSurface = EdgeSurface.offline;
  var _showNav = false;

  static const _sampleMessages = <Map<String, dynamic>>[
    {'role': 'user', 'content': 'Plan a trip to Tokyo'},
    {'role': 'kai', 'content': 'Sure! Tokyo is a fantastic choice.'},
  ];

  static final _navSessions = <SessionPreview>[
    SessionPreview(
      id: 'session-seed-1',
      title: 'Tokyo trip planning',
      timeLabel: '9:41',
      createdAt: DateTime.now(),
    ),
    SessionPreview(
      id: 'session-seed-2',
      title: 'Visa requirements',
      timeLabel: '12 May',
      createdAt: DateTime.now().subtract(const Duration(days: 1)),
    ),
  ];

  @override
  Widget build(BuildContext context) {
    final c = KaiTheme.of(context).colors;
    return Scaffold(
      backgroundColor: c.bg,
      appBar: AppBar(
        backgroundColor: c.bg,
        foregroundColor: c.ink1,
        title: const Text('Organisms'),
      ),
      body: Stack(
        children: [
          ListView(
            padding: const EdgeInsets.all(KaiSpace.s5),
            children: [
              _sectionHeader(context, 'OnboardingCard'),
              const SizedBox(height: KaiSpace.s3),
              _stepSelector(context),
              const SizedBox(height: KaiSpace.s3),
              SizedBox(
                height: 480,
                child: OnboardingCard(
                  stepIndex: _onboardingStep,
                  onComplete: () => setState(() => _onboardingStep = 0),
                ),
              ),
              const SizedBox(height: KaiSpace.s7),
              _sectionHeader(context, 'ChatList'),
              const SizedBox(height: KaiSpace.s3),
              _frameSelector(context),
              const SizedBox(height: KaiSpace.s3),
              SizedBox(
                height: 320,
                child: ChatList(
                  frame: _roomFrame,
                  messages: _roomFrame == RoomFrame.empty
                      ? const []
                      : _sampleMessages,
                  onRetry: () {},
                ),
              ),
              const SizedBox(height: KaiSpace.s7),
              _sectionHeader(context, 'NavPanel'),
              const SizedBox(height: KaiSpace.s3),
              FilledButton(
                onPressed: () => setState(() => _showNav = true),
                child: const Text('Open NavPanel'),
              ),
              const SizedBox(height: KaiSpace.s7),
              _sectionHeader(context, 'EdgeStateBlock'),
              const SizedBox(height: KaiSpace.s3),
              _surfaceSelector(context),
              const SizedBox(height: KaiSpace.s3),
              EdgeStateBlock(
                surface: _edgeSurface,
                onRetry: () {},
                onPlans: () {},
                countdown: _edgeSurface == EdgeSurface.rateLimit
                    ? const Duration(minutes: 1)
                    : null,
              ),
              const SizedBox(height: KaiSpace.s9),
            ],
          ),
          if (_showNav)
            NavPanel(
              activeSessionId: 'session-seed-1',
              sessions: _navSessions,
              pinnedTrip: const TripInfo(
                id: 'trip-japan',
                title: 'Япония · ноябрь',
                subtitle: '12-26 ноя · черновик',
                initial: 'Я',
                chatCount: 3,
              ),
              trips: const [
                TripInfo(
                  id: 'trip-japan',
                  title: 'Япония · ноябрь',
                  subtitle: '12-26 ноя · черновик',
                  initial: 'Я',
                  chatCount: 3,
                ),
              ],
              onClose: () => setState(() => _showNav = false),
            ),
        ],
      ),
    );
  }

  Widget _sectionHeader(BuildContext context, String label) {
    final c = KaiTheme.of(context).colors;
    return Text(
      label,
      style: TextStyle(
        fontSize: 13,
        fontWeight: FontWeight.w600,
        color: c.ink3,
        letterSpacing: 0.5,
      ),
    );
  }

  Widget _stepSelector(BuildContext context) {
    return Row(
      children: List.generate(4, (i) {
        return Padding(
          padding: const EdgeInsets.only(right: KaiSpace.s2),
          child: ChoiceChip(
            label: Text('Step ${i + 1}'),
            selected: _onboardingStep == i,
            onSelected: (_) => setState(() => _onboardingStep = i),
          ),
        );
      }),
    );
  }

  Widget _frameSelector(BuildContext context) {
    return Wrap(
      spacing: KaiSpace.s2,
      children: RoomFrame.values.map((f) {
        return ChoiceChip(
          label: Text(f.name),
          selected: _roomFrame == f,
          onSelected: (_) => setState(() => _roomFrame = f),
        );
      }).toList(),
    );
  }

  Widget _surfaceSelector(BuildContext context) {
    return Wrap(
      spacing: KaiSpace.s2,
      children: EdgeSurface.values.map((s) {
        return ChoiceChip(
          label: Text(s.name),
          selected: _edgeSurface == s,
          onSelected: (_) => setState(() => _edgeSurface = s),
        );
      }).toList(),
    );
  }
}
