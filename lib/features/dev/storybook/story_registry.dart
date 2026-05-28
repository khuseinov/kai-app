import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../design_system/atoms/atoms.dart';
import '../../../design_system/molecules/molecules.dart';
import '../../../design_system/organisms/organisms.dart';
import '../../../design_system/primitives/primitives.dart';
import '../../../design_system/theme/kai_theme.dart';
import '../../../design_system/tokens/kai_tokens.dart';

// ── Story model ───────────────────────────────────────────────────────────────

enum StoryLayer { primitives, atoms, molecules, organisms }

class Story {
  const Story({
    required this.layer,
    required this.name,
    required this.build,
  });

  final StoryLayer layer;
  final String name;
  final WidgetBuilder build;
}

// ── Registry ──────────────────────────────────────────────────────────────────

final List<Story> kStories = [
  // ── Primitives ──────────────────────────────────────────────────────────────
  Story(
    layer: StoryLayer.primitives,
    name: 'KaiIcon',
    build: (_) => const _KaiIconStory(),
  ),
  Story(
    layer: StoryLayer.primitives,
    name: 'KaiSurface',
    build: (_) => const _KaiSurfaceStory(),
  ),
  Story(
    layer: StoryLayer.primitives,
    name: 'KaiGradientBar',
    build: (_) => const _KaiGradientBarStory(),
  ),

  // ── Atoms ────────────────────────────────────────────────────────────────────
  Story(
    layer: StoryLayer.atoms,
    name: 'KaiText',
    build: (_) => const _KaiTextStory(),
  ),
  Story(
    layer: StoryLayer.atoms,
    name: 'KaiButton',
    build: (_) => const _KaiButtonStory(),
  ),
  Story(
    layer: StoryLayer.atoms,
    name: 'KaiIconButton',
    build: (_) => const _KaiIconButtonStory(),
  ),
  Story(
    layer: StoryLayer.atoms,
    name: 'KaiSendButton',
    build: (_) => const _KaiSendButtonStory(),
  ),
  Story(
    layer: StoryLayer.atoms,
    name: 'KaiInput',
    build: (_) => const _KaiInputStory(),
  ),
  Story(
    layer: StoryLayer.atoms,
    name: 'KaiToggle',
    build: (_) => const _KaiToggleStory(),
  ),
  Story(
    layer: StoryLayer.atoms,
    name: 'KaiChip',
    build: (_) => const _KaiChipStory(),
  ),
  Story(
    layer: StoryLayer.atoms,
    name: 'KaiBadge',
    build: (_) => const _KaiBadgeStory(),
  ),
  Story(
    layer: StoryLayer.atoms,
    name: 'KaiAvatar',
    build: (_) => const _KaiAvatarStory(),
  ),
  Story(
    layer: StoryLayer.atoms,
    name: 'KaiTideCurve',
    build: (_) => const _KaiTideCurveStory(),
  ),
  Story(
    layer: StoryLayer.atoms,
    name: 'KaiDivider',
    build: (_) => const _KaiDividerStory(),
  ),
  Story(
    layer: StoryLayer.atoms,
    name: 'KaiSheetShell',
    build: (_) => const _KaiSheetShellStory(),
  ),

  // ── Molecules ────────────────────────────────────────────────────────────────
  Story(
    layer: StoryLayer.molecules,
    name: 'KaiUserBubble',
    build: (_) => const _KaiUserBubbleStory(),
  ),
  Story(
    layer: StoryLayer.molecules,
    name: 'KaiKaiBubble',
    build: (_) => const _KaiKaiBubbleStory(),
  ),
  Story(
    layer: StoryLayer.molecules,
    name: 'KaiSystemBubble',
    build: (_) => const _KaiSystemBubbleStory(),
  ),
  Story(
    layer: StoryLayer.molecules,
    name: 'KaiComposeIsland',
    build: (_) => const _KaiComposeIslandStory(),
  ),
  Story(
    layer: StoryLayer.molecules,
    name: 'KaiSourceCard',
    build: (_) => const _KaiSourceCardStory(),
  ),
  Story(
    layer: StoryLayer.molecules,
    name: 'KaiCareBlock',
    build: (_) => const _KaiCareBlockStory(),
  ),
  Story(
    layer: StoryLayer.molecules,
    name: 'KaiAlertCard',
    build: (_) => const _KaiAlertCardStory(),
  ),
  Story(
    layer: StoryLayer.molecules,
    name: 'KaiToast',
    build: (_) => const _KaiToastStory(),
  ),
  Story(
    layer: StoryLayer.molecules,
    name: 'KaiActionSheet',
    build: (_) => const _KaiActionSheetStory(),
  ),
  Story(
    layer: StoryLayer.molecules,
    name: 'KaiSegmentedControl',
    build: (_) => const _KaiSegmentedControlStory(),
  ),
  Story(
    layer: StoryLayer.molecules,
    name: 'KaiSettingsRow',
    build: (_) => const _KaiSettingsRowStory(),
  ),
  Story(
    layer: StoryLayer.molecules,
    name: 'KaiAccountHero',
    build: (_) => const _KaiAccountHeroStory(),
  ),
  Story(
    layer: StoryLayer.molecules,
    name: 'KaiNavItem',
    build: (_) => const _KaiNavItemStory(),
  ),

  // ── Organisms ────────────────────────────────────────────────────────────────
  Story(
    layer: StoryLayer.organisms,
    name: 'KaiChatList',
    build: (_) => const _KaiChatListStory(),
  ),
  Story(
    layer: StoryLayer.organisms,
    name: 'KaiNavPanel',
    build: (_) => const _KaiNavPanelStory(),
  ),
  Story(
    layer: StoryLayer.organisms,
    name: 'KaiEdgeStateBlock',
    build: (_) => const _KaiEdgeStateBlockStory(),
  ),
  Story(
    layer: StoryLayer.organisms,
    name: 'KaiOnboardingCard',
    build: (_) => const _KaiOnboardingCardStory(),
  ),
];

// ── Shared section header ─────────────────────────────────────────────────────

class StorySection extends StatelessWidget {
  const StorySection({super.key, required this.title, required this.child});

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

// ── Primitives ────────────────────────────────────────────────────────────────

class _KaiIconStory extends StatelessWidget {
  const _KaiIconStory();

  @override
  Widget build(BuildContext context) {
    final c = KaiTheme.of(context).colors;
    return StorySection(
      title: 'KaiIcon (${KaiIconName.values.length} icons)',
      child: Wrap(
        spacing: KaiSpace.s4,
        runSpacing: KaiSpace.s4,
        children: KaiIconName.values.map((n) {
          final isNew =
              n == KaiIconName.thumbUp || n == KaiIconName.thumbDown;
          return Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              KaiIcon(n, size: 24, color: isNew ? c.accent : null),
              const SizedBox(height: 4),
              KaiText.micro(
                n.assetName,
                color: isNew ? c.accent : c.ink3,
              ),
            ],
          );
        }).toList(),
      ),
    );
  }
}

class _KaiSurfaceStory extends StatelessWidget {
  const _KaiSurfaceStory();

  @override
  Widget build(BuildContext context) {
    final c = KaiTheme.of(context).colors;
    return StorySection(
      title: 'KaiSurface',
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          KaiSurface(
            color: c.surface,
            radius: KaiRadius.br4,
            border: true,
            padding: const EdgeInsets.all(KaiSpace.s4),
            child: const KaiText.small('surface + border + br4'),
          ),
          const SizedBox(height: KaiSpace.s3),
          KaiSurface(
            color: c.surface2,
            radius: KaiRadius.br3,
            padding: const EdgeInsets.all(KaiSpace.s4),
            shadow: KaiShadow.button,
            child: const KaiText.small('surface2 + shadow + br3'),
          ),
        ],
      ),
    );
  }
}

class _KaiGradientBarStory extends StatelessWidget {
  const _KaiGradientBarStory();

  @override
  Widget build(BuildContext context) {
    return const StorySection(
      title: 'KaiGradientBar',
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              KaiGradientBar(),
              SizedBox(width: KaiSpace.s4),
              KaiText.small('static (16×4)'),
            ],
          ),
          SizedBox(height: KaiSpace.s3),
          Row(
            children: [
              KaiGradientBar(pulse: true),
              SizedBox(width: KaiSpace.s4),
              KaiText.small('pulse: true'),
            ],
          ),
          SizedBox(height: KaiSpace.s3),
          Row(
            children: [
              KaiGradientBar(width: 10, height: 2.5),
              SizedBox(width: KaiSpace.s4),
              KaiText.small('toast size 10×2.5'),
            ],
          ),
        ],
      ),
    );
  }
}

// ── Atoms ─────────────────────────────────────────────────────────────────────

class _KaiTextStory extends StatelessWidget {
  const _KaiTextStory();

  @override
  Widget build(BuildContext context) {
    return const StorySection(
      title: 'KaiText (all 10 styles)',
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          KaiText.hero('Hero 72'),
          KaiText.display('Display 56'),
          KaiText.h1('H1 36 · gradient', gradient: true),
          KaiText.h2('H2 24'),
          KaiText.h3('H3 18'),
          SizedBox(height: KaiSpace.s2),
          KaiText.lead('Lead 20 — the quick brown fox'),
          KaiText.body('Body 16 — the quick brown fox'),
          KaiText.small('Small 14 — secondary copy'),
          KaiText.micro('MICRO 12'),
          KaiText.mono('mono.code() = 12'),
        ],
      ),
    );
  }
}

class _KaiButtonStory extends StatelessWidget {
  const _KaiButtonStory();

  @override
  Widget build(BuildContext context) {
    return StorySection(
      title: 'KaiButton (all variants)',
      child: Wrap(
        spacing: KaiSpace.s3,
        runSpacing: KaiSpace.s4,
        crossAxisAlignment: WrapCrossAlignment.center,
        children: [
          KaiButton.tide(onPressed: () {}, label: 'Tide normal'),
          KaiButton.tide(
            onPressed: () {},
            label: 'Tide glow',
            emphasis: KaiButtonEmphasis.glow,
          ),
          const KaiButton.tide(onPressed: null, label: 'Tide disabled'),
          KaiButton.ink(onPressed: () {}, label: 'Ink'),
          KaiButton.ghost(onPressed: () {}, label: 'Ghost neutral'),
          KaiButton.ghost(
            onPressed: () {},
            label: 'Ghost warning',
            tone: KaiButtonTone.warning,
          ),
          KaiButton.ghost(
            onPressed: () {},
            label: 'Ghost negative',
            tone: KaiButtonTone.negative,
          ),
          KaiButton.ghost(
            onPressed: () {},
            label: 'Ghost pill',
            pill: true,
          ),
          KaiButton.text(onPressed: () {}, label: 'Text neutral'),
          KaiButton.text(
            onPressed: () {},
            label: 'Text accent',
            tone: KaiButtonTone.accent,
          ),
          KaiButton.text(
            onPressed: () {},
            label: 'Text negative',
            tone: KaiButtonTone.negative,
          ),
        ],
      ),
    );
  }
}

class _KaiIconButtonStory extends StatelessWidget {
  const _KaiIconButtonStory();

  @override
  Widget build(BuildContext context) {
    final c = KaiTheme.of(context).colors;
    return StorySection(
      title: 'KaiIconButton (surface / transparent / bare)',
      child: Wrap(
        spacing: KaiSpace.s4,
        runSpacing: KaiSpace.s4,
        crossAxisAlignment: WrapCrossAlignment.center,
        children: [
          Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              KaiIconButton.surface(onPressed: () {}, icon: KaiIconName.mic),
              const SizedBox(height: 4),
              KaiText.micro('surface', color: c.ink3),
            ],
          ),
          Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              KaiIconButton.transparent(
                  onPressed: () {}, icon: KaiIconName.mic),
              const SizedBox(height: 4),
              KaiText.micro('transparent', color: c.ink3),
            ],
          ),
          Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              KaiIconButton.bare(onPressed: () {}, icon: KaiIconName.close),
              const SizedBox(height: 4),
              KaiText.micro('bare', color: c.ink3),
            ],
          ),
          Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const KaiIconButton.bare(onPressed: null, icon: KaiIconName.lock),
              const SizedBox(height: 4),
              KaiText.micro('disabled', color: c.ink3),
            ],
          ),
        ],
      ),
    );
  }
}

class _KaiSendButtonStory extends ConsumerStatefulWidget {
  const _KaiSendButtonStory();

  @override
  ConsumerState<_KaiSendButtonStory> createState() =>
      _KaiSendButtonStoryState();
}

class _KaiSendButtonStoryState extends ConsumerState<_KaiSendButtonStory> {
  KaiSendState _state = KaiSendState.ready;

  void _cycle() {
    setState(() {
      const vals = KaiSendState.values;
      _state = vals[(vals.indexOf(_state) + 1) % vals.length];
    });
  }

  @override
  Widget build(BuildContext context) {
    return StorySection(
      title: 'KaiSendButton (4 states — tap to cycle)',
      child: Row(
        children: [
          KaiSendButton(state: _state, onPressed: _cycle),
          const SizedBox(width: KaiSpace.s4),
          KaiButton.ghost(
            onPressed: _cycle,
            label: 'state: ${_state.name}',
          ),
        ],
      ),
    );
  }
}

class _KaiInputStory extends StatefulWidget {
  const _KaiInputStory();

  @override
  State<_KaiInputStory> createState() => _KaiInputStoryState();
}

class _KaiInputStoryState extends State<_KaiInputStory> {
  final _lineCtrl = TextEditingController();
  final _pillCtrl = TextEditingController();

  @override
  void dispose() {
    _lineCtrl.dispose();
    _pillCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return StorySection(
      title: 'KaiInput (line + pill)',
      child: Column(
        children: [
          KaiInput.line(
            controller: _lineCtrl,
            placeholder: 'Line input — search…',
          ),
          const SizedBox(height: KaiSpace.s3),
          KaiInput.pill(
            controller: _pillCtrl,
            placeholder: 'Pill input — compose…',
            maxLines: 4,
          ),
          const SizedBox(height: KaiSpace.s3),
          KaiInput.line(
            controller: TextEditingController(text: 'disabled field'),
            enabled: false,
          ),
        ],
      ),
    );
  }
}

class _KaiToggleStory extends StatefulWidget {
  const _KaiToggleStory();

  @override
  State<_KaiToggleStory> createState() => _KaiToggleStoryState();
}

class _KaiToggleStoryState extends State<_KaiToggleStory> {
  bool _on = true;
  bool _off = false;

  @override
  Widget build(BuildContext context) {
    final c = KaiTheme.of(context).colors;
    return StorySection(
      title: 'KaiToggle (on / off / disabled)',
      child: Row(
        children: [
          KaiToggle(value: _on, onChanged: (v) => setState(() => _on = v)),
          const SizedBox(width: KaiSpace.s4),
          KaiToggle(value: _off, onChanged: (v) => setState(() => _off = v)),
          const SizedBox(width: KaiSpace.s4),
          const KaiToggle(value: true, onChanged: null),
          const SizedBox(width: KaiSpace.s3),
          KaiText.small('disabled', color: c.ink3),
        ],
      ),
    );
  }
}

class _KaiChipStory extends StatelessWidget {
  const _KaiChipStory();

  @override
  Widget build(BuildContext context) {
    return const StorySection(
      title: 'KaiChip (status: done/active/neutral; choice: sel/unsel)',
      child: Wrap(
        spacing: KaiSpace.s3,
        runSpacing: KaiSpace.s3,
        children: [
          KaiChip.status('done', tone: KaiChipTone.done),
          KaiChip.status('active', tone: KaiChipTone.active),
          KaiChip.status('neutral'),
          KaiChip.choice('Selected', selected: true),
          KaiChip.choice('Unselected', selected: false),
        ],
      ),
    );
  }
}

class _KaiBadgeStory extends StatelessWidget {
  const _KaiBadgeStory();

  @override
  Widget build(BuildContext context) {
    return const StorySection(
      title: 'KaiBadge (dot + count)',
      child: Row(
        children: [
          KaiBadge.dot(),
          SizedBox(width: KaiSpace.s4),
          KaiBadge.count(5),
          SizedBox(width: KaiSpace.s4),
          KaiBadge.count(99),
          SizedBox(width: KaiSpace.s4),
          KaiBadge.count(150),
        ],
      ),
    );
  }
}

class _KaiAvatarStory extends StatelessWidget {
  const _KaiAvatarStory();

  @override
  Widget build(BuildContext context) {
    return const StorySection(
      title: 'KaiAvatar (sizes + initial)',
      child: Row(
        children: [
          KaiAvatar(),
          SizedBox(width: KaiSpace.s4),
          KaiAvatar(initial: 'R'),
          SizedBox(width: KaiSpace.s4),
          KaiAvatar(size: 56, initial: 'K'),
          SizedBox(width: KaiSpace.s4),
          KaiAvatar(size: 32),
        ],
      ),
    );
  }
}

class _KaiTideCurveStory extends StatefulWidget {
  const _KaiTideCurveStory();

  @override
  State<_KaiTideCurveStory> createState() => _KaiTideCurveStoryState();
}

class _KaiTideCurveStoryState extends State<_KaiTideCurveStory> {
  int _index = 0;
  bool _autoCycling = false;
  Timer? _autoCycle;

  @override
  void dispose() {
    _autoCycle?.cancel();
    super.dispose();
  }

  void _toggleAuto() {
    setState(() => _autoCycling = !_autoCycling);
    if (_autoCycling) {
      _autoCycle = Timer.periodic(const Duration(seconds: 3), (_) {
        if (!mounted) return;
        setState(() => _index = (_index + 1) % KaiTide.all.length);
      });
    } else {
      _autoCycle?.cancel();
      _autoCycle = null;
    }
  }

  @override
  Widget build(BuildContext context) {
    final c = KaiTheme.of(context).colors;
    final tideState = KaiTide.all[_index];
    return StorySection(
      title: 'KaiTideCurve — ${tideState.name}',
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          SizedBox(height: 28, child: KaiTideCurve(state: tideState)),
          const SizedBox(height: KaiSpace.s3),
          Row(
            children: [
              KaiButton.ghost(
                onPressed: () => setState(
                    () => _index = (_index + 1) % KaiTide.all.length),
                label: 'next state',
              ),
              const SizedBox(width: KaiSpace.s3),
              KaiButton.ghost(
                onPressed: _toggleAuto,
                label: _autoCycling ? 'auto: on' : 'auto: off',
              ),
            ],
          ),
          const SizedBox(height: KaiSpace.s3),
          Wrap(
            spacing: KaiSpace.s3,
            runSpacing: KaiSpace.s4,
            children: KaiTide.all.map((s) {
              return Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  SizedBox(
                    width: 80,
                    height: 20,
                    child: KaiTideCurve(state: s),
                  ),
                  const SizedBox(height: 2),
                  KaiText.micro(s.name, color: c.ink3),
                ],
              );
            }).toList(),
          ),
        ],
      ),
    );
  }
}

class _KaiDividerStory extends StatelessWidget {
  const _KaiDividerStory();

  @override
  Widget build(BuildContext context) {
    final c = KaiTheme.of(context).colors;
    return StorySection(
      title: 'KaiDivider (horizontal + vertical)',
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const KaiDivider(),
          const SizedBox(height: KaiSpace.s3),
          SizedBox(
            height: 40,
            child: Row(
              children: [
                KaiText.small('left', color: c.ink2),
                const SizedBox(width: KaiSpace.s3),
                const KaiDivider.vertical(),
                const SizedBox(width: KaiSpace.s3),
                KaiText.small('right', color: c.ink2),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _KaiSheetShellStory extends StatelessWidget {
  const _KaiSheetShellStory();

  @override
  Widget build(BuildContext context) {
    return const StorySection(
      title: 'KaiSheetShell (inline demo)',
      child: KaiSheetShell(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            KaiText.h3('Sheet child content'),
            SizedBox(height: KaiSpace.s2),
            KaiText.body('Drag handle + border-radius top.'),
          ],
        ),
      ),
    );
  }
}

// ── Molecules ─────────────────────────────────────────────────────────────────

class _KaiUserBubbleStory extends StatelessWidget {
  const _KaiUserBubbleStory();

  @override
  Widget build(BuildContext context) {
    return const StorySection(
      title: 'KaiUserBubble',
      child: KaiUserBubble(
        text: 'Привет, Kai! Расскажи мне о визе в Японию.',
      ),
    );
  }
}

class _KaiKaiBubbleStory extends StatelessWidget {
  const _KaiKaiBubbleStory();

  @override
  Widget build(BuildContext context) {
    return StorySection(
      title: 'KaiKaiBubble (with citation [1] + streaming)',
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          KaiKaiBubble(
            text: 'Для туристической визы в Японию [1] нужны: загранпаспорт, '
                'фото, выписка из банка и маршрут поездки.',
            sourcesLabel: '1 источник · только что проверено',
            sources: const [
              KaiSourceCard(
                url: 'mofa.go.jp',
                title: 'Visa — Ministry of Foreign Affairs of Japan',
                snippet: 'Requirements for tourist visas to Japan…',
                index: 1,
                fresh: true,
              ),
            ],
            onThumbUp: () {},
            onThumbDown: () {},
          ),
          const SizedBox(height: KaiSpace.s4),
          const KaiKaiBubble(
            text: 'Ищу информацию',
            streaming: true,
          ),
        ],
      ),
    );
  }
}

class _KaiSystemBubbleStory extends StatelessWidget {
  const _KaiSystemBubbleStory();

  @override
  Widget build(BuildContext context) {
    return const StorySection(
      title: 'KaiSystemBubble (3 tones)',
      child: Column(
        children: [
          KaiSystemBubble(
            'Kai обновил воспоминание о ваших планах на поездку.',
            tone: KaiSystemTone.neutral,
          ),
          SizedBox(height: KaiSpace.s3),
          KaiSystemBubble(
            'Внимание — сайт не обновлялся 6 месяцев.',
            bold: 'Внимание —',
            tone: KaiSystemTone.warning,
          ),
          SizedBox(height: KaiSpace.s3),
          KaiSystemBubble(
            'Ошибка сети при загрузке источника.',
            tone: KaiSystemTone.negative,
          ),
        ],
      ),
    );
  }
}

class _KaiComposeIslandStory extends StatefulWidget {
  const _KaiComposeIslandStory();

  @override
  State<_KaiComposeIslandStory> createState() => _KaiComposeIslandStoryState();
}

class _KaiComposeIslandStoryState extends State<_KaiComposeIslandStory> {
  final _ctrl = TextEditingController();

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return StorySection(
      title: 'KaiComposeIsland',
      child: KaiComposeIsland(
        controller: _ctrl,
        onSend: () {},
        onMicTap: () {},
      ),
    );
  }
}

class _KaiSourceCardStory extends StatelessWidget {
  const _KaiSourceCardStory();

  @override
  Widget build(BuildContext context) {
    return const StorySection(
      title: 'KaiSourceCard',
      child: Column(
        children: [
          KaiSourceCard(
            url: 'booking.com',
            title: 'Hotels in Tokyo — Booking.com',
            snippet: 'Find the best deals on hotels in Tokyo, Japan.',
            index: 1,
            fresh: true,
          ),
          SizedBox(height: KaiSpace.s3),
          KaiSourceCard(
            url: 'tripadvisor.com',
            title: 'Things to Do in Tokyo',
            index: 2,
          ),
        ],
      ),
    );
  }
}

class _KaiCareBlockStory extends StatelessWidget {
  const _KaiCareBlockStory();

  @override
  Widget build(BuildContext context) {
    return const StorySection(
      title: 'KaiCareBlock',
      child: KaiCareBlock(
        heading: 'Я здесь для тебя.',
        body: 'Если тебе сейчас тяжело — ты не один. '
            'Поговори с кем-то, кто поможет.',
        resources: [
          KaiCareResource(
              label: 'Телефон доверия', number: '8-800-2000-122'),
          KaiCareResource(label: 'Кризисный чат', number: '112'),
        ],
        closing: 'Ты в порядке — просто дыши.',
      ),
    );
  }
}

class _KaiAlertCardStory extends StatelessWidget {
  const _KaiAlertCardStory();

  @override
  Widget build(BuildContext context) {
    return StorySection(
      title: 'KaiAlertCard (all 4 types)',
      child: Column(
        children: [
          KaiAlertCard(
            type: KaiAlertType.urgent,
            title: 'Требуется немедленное внимание',
            body: 'Виза истекает через 3 дня.',
            time: '9:41',
            cta: 'Продлить визу',
            onCtaTap: () {},
          ),
          const SizedBox(height: KaiSpace.s3),
          KaiAlertCard(
            type: KaiAlertType.warning,
            title: 'Предупреждение о погоде',
            body: 'Ожидается дождь в районе маршрута.',
            time: '10:15',
            cta: 'Посмотреть прогноз',
            onCtaTap: () {},
          ),
          const SizedBox(height: KaiSpace.s3),
          KaiAlertCard(
            type: KaiAlertType.positive,
            title: 'Бронирование подтверждено',
            body: 'Ваш отель в Токио забронирован на 3 ночи.',
            time: '11:00',
            cta: 'Посмотреть детали',
            onCtaTap: () {},
          ),
          const SizedBox(height: KaiSpace.s3),
          const KaiAlertCard(
            type: KaiAlertType.neutral,
            title: 'Напоминание о поездке',
            body: 'Через 5 дней вылет в Токио.',
            time: '12:30',
          ),
        ],
      ),
    );
  }
}

class _KaiToastStory extends StatelessWidget {
  const _KaiToastStory();

  @override
  Widget build(BuildContext context) {
    return StorySection(
      title: 'KaiToast (all 4 types, inline)',
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const KaiToast(
            type: KaiToastType.neutral,
            label: 'Скопировано в буфер',
          ),
          const SizedBox(height: KaiSpace.s3),
          const KaiToast(
            type: KaiToastType.positive,
            label: 'Воспоминание сохранено',
            showCountdown: true,
          ),
          const SizedBox(height: KaiSpace.s3),
          KaiToast(
            type: KaiToastType.negative,
            label: 'Не удалось отправить',
            actionLabel: 'Повторить',
            onAction: () {},
          ),
          const SizedBox(height: KaiSpace.s3),
          KaiToast(
            type: KaiToastType.memory,
            label: 'Kai запомнил это',
            actionLabel: 'Открыть',
            onAction: () {},
          ),
        ],
      ),
    );
  }
}

class _KaiActionSheetStory extends StatelessWidget {
  const _KaiActionSheetStory();

  @override
  Widget build(BuildContext context) {
    return StorySection(
      title: 'KaiActionSheet + KaiMessageDetailSheet (modal triggers)',
      child: Row(
        children: [
          KaiButton.ghost(
            label: 'Action sheet',
            onPressed: () {
              showKaiActionSheet(
                context,
                items: [
                  KaiActionItem(
                    icon: KaiIconName.copy,
                    title: 'Скопировать',
                    meta: '⌘C',
                    onTap: () {},
                  ),
                  KaiActionItem(
                    icon: KaiIconName.retry,
                    title: 'Повторить запрос',
                    onTap: () {},
                  ),
                  KaiActionItem(
                    icon: KaiIconName.trash,
                    title: 'Удалить сообщение',
                    danger: true,
                    onTap: () {},
                  ),
                ],
              );
            },
          ),
          const SizedBox(width: KaiSpace.s3),
          KaiButton.ghost(
            label: 'Detail sheet',
            onPressed: () {
              showKaiMessageDetailSheet(
                context,
                sources: const [
                  KaiDetailSource(
                    number: 1,
                    url: 'mofa.go.jp',
                    freshness: KaiSourceFreshness.fresh,
                  ),
                  KaiDetailSource(
                    number: 2,
                    url: 'japan-guide.com',
                    freshness: KaiSourceFreshness.stale,
                    freshnessLabel: '5d',
                  ),
                ],
                actions: [
                  KaiDetailAction(
                    icon: KaiIconName.copy,
                    label: 'Скопировать',
                    onTap: () {},
                  ),
                  KaiDetailAction(
                    icon: KaiIconName.heart,
                    label: 'Сохранить',
                    style: KaiDetailActionStyle.primary,
                    onTap: () {},
                  ),
                  KaiDetailAction(
                    icon: KaiIconName.trash,
                    label: 'Удалить',
                    style: KaiDetailActionStyle.danger,
                    onTap: () {},
                  ),
                ],
              );
            },
          ),
        ],
      ),
    );
  }
}

class _KaiSegmentedControlStory extends StatefulWidget {
  const _KaiSegmentedControlStory();

  @override
  State<_KaiSegmentedControlStory> createState() =>
      _KaiSegmentedControlStoryState();
}

class _KaiSegmentedControlStoryState
    extends State<_KaiSegmentedControlStory> {
  int _index = 0;

  @override
  Widget build(BuildContext context) {
    return StorySection(
      title: 'KaiSegmentedControl',
      child: KaiSegmentedControl(
        options: const ['Авто', 'Светлая', 'Тёмная'],
        selectedIndex: _index,
        onSelected: (i) => setState(() => _index = i),
      ),
    );
  }
}

class _KaiSettingsRowStory extends StatefulWidget {
  const _KaiSettingsRowStory();

  @override
  State<_KaiSettingsRowStory> createState() => _KaiSettingsRowStoryState();
}

class _KaiSettingsRowStoryState extends State<_KaiSettingsRowStory> {
  bool _toggle = true;

  @override
  Widget build(BuildContext context) {
    final c = KaiTheme.of(context).colors;
    return StorySection(
      title: 'KaiSettingsRow + KaiSettingsGroup',
      child: Column(
        children: [
          KaiSettingsGroup(
            label: 'внешний вид',
            children: [
              KaiSettingsRow(
                icon: KaiIconName.palette,
                title: 'Тема',
                subtitle: 'системная',
                trailing: KaiToggle(
                  value: _toggle,
                  onChanged: (v) => setState(() => _toggle = v),
                ),
                onTap: () {},
              ),
              KaiSettingsRow(
                icon: KaiIconName.motion,
                title: 'Уменьшить анимацию',
                subtitle: 'прилив становится статичным',
                trailing:
                    KaiIcon(KaiIconName.chevRight, size: 14, color: c.ink3),
                onTap: () {},
              ),
            ],
          ),
          const SizedBox(height: KaiSpace.s4),
          KaiSettingsGroup(
            danger: true,
            children: [
              KaiSettingsRow(
                icon: KaiIconName.trash,
                title: 'Удалить мои данные',
                danger: true,
                onTap: () {},
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _KaiAccountHeroStory extends StatelessWidget {
  const _KaiAccountHeroStory();

  @override
  Widget build(BuildContext context) {
    return const StorySection(
      title: 'KaiAccountHero',
      child: KaiAccountHero(
        name: 'Rustam K.',
        email: 'rustam.wize@gmail.com',
        initial: 'R',
        planLabel: 'Pro',
      ),
    );
  }
}

class _KaiNavItemStory extends StatelessWidget {
  const _KaiNavItemStory();

  @override
  Widget build(BuildContext context) {
    return StorySection(
      title: 'KaiNavItem (inactive + active + with badge)',
      child: Column(
        children: [
          KaiNavItem(
            label: 'Поездка в Токио',
            icon: KaiIconName.folder,
            onTap: () {},
          ),
          KaiNavItem(
            label: 'Текущий чат',
            icon: KaiIconName.memory,
            active: true,
            onTap: () {},
          ),
          const KaiNavItem(
            label: 'Память',
            icon: KaiIconName.memory,
            trailing: KaiBadge.dot(),
          ),
        ],
      ),
    );
  }
}

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
