import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../design_system/atoms/atoms.dart';
import '../../../../design_system/primitives/primitives.dart';
import '../../../../design_system/theme/kai_theme.dart';
import '../../../../design_system/tokens/kai_tokens.dart';
import '../story_registry.dart';
import '_story_helpers.dart';

final List<Story> atomStories = [
  Story(
    layer: StoryLayer.atoms,
    name: 'KaiText',
    importPath: 'package:kai_app/design_system/atoms/atoms.dart',
    canonFile: 'new-design/foundations.html',
    canonSelector: '.type-scale',
    description:
        'Typed text atom with ten named constructors mapping to the full '
        'KaiType scale. Display-tier constructors support gradient: true.',
    variants: [
      'hero', 'display', 'h1', 'h2', 'h3',
      'lead', 'body', 'small', 'micro', 'mono',
    ],
    build: (_) => const _KaiTextStory(),
  ),
  Story(
    layer: StoryLayer.atoms,
    name: 'KaiButton',
    importPath: 'package:kai_app/design_system/atoms/atoms.dart',
    canonFile: 'new-design/components.html',
    canonSelector: '.btn-grid .btn',
    description:
        'Four-variant button atom covering every action weight in the system: '
        'primary tide, solid ink, ghost outline, and text link.',
    variants: ['tide', 'ink', 'ghost', 'text'],
    build: (_) => const _KaiButtonStory(),
  ),
  Story(
    layer: StoryLayer.atoms,
    name: 'KaiIconButton',
    importPath: 'package:kai_app/design_system/atoms/atoms.dart',
    canonFile: 'new-design/components.html',
    canonSelector: '.icon-btn',
    description:
        'Icon-only button with three surface variants — use surface for '
        'compose attachment slots, transparent for mic, bare for sheet actions.',
    variants: ['surface', 'transparent', 'bare'],
    build: (_) => const _KaiIconButtonStory(),
  ),
  Story(
    layer: StoryLayer.atoms,
    name: 'KaiSendButton',
    importPath: 'package:kai_app/design_system/atoms/atoms.dart',
    canonFile: 'new-design/components.html',
    canonSelector: '.compose .send',
    description:
        'Circular send button with a four-state lifecycle (ready / disabled / '
        'sending / streaming); the primary CTA in every compose island.',
    variants: ['ready', 'disabled', 'sending', 'streaming'],
    build: (_) => const _KaiSendButtonStory(),
  ),
  Story(
    layer: StoryLayer.atoms,
    name: 'KaiInput',
    importPath: 'package:kai_app/design_system/atoms/atoms.dart',
    canonFile: 'new-design/components.html',
    canonSelector: '.compose textarea',
    description:
        'Text field atom — line variant for search boxes, pill variant for '
        'the compose-island textarea.',
    variants: ['line', 'pill'],
    build: (_) => const _KaiInputStory(),
  ),
  Story(
    layer: StoryLayer.atoms,
    name: 'KaiToggle',
    importPath: 'package:kai_app/design_system/atoms/atoms.dart',
    canonFile: 'new-design/settings.html',
    canonSelector: '.toggle',
    description:
        'Pill switch atom — 34×20 track, accent when on, surface3 when off. '
        'Used in settings rows for boolean preferences.',
    variants: ['on', 'off', 'disabled (onChanged: null)'],
    build: (_) => const _KaiToggleStory(),
  ),
  Story(
    layer: StoryLayer.atoms,
    name: 'KaiChip',
    importPath: 'package:kai_app/design_system/atoms/atoms.dart',
    canonFile: 'new-design/components.html',
    canonSelector: '.chip',
    description:
        'Status pill (non-interactive, mono-uppercase) and choice chip '
        '(selectable filter). Three tone variants for status.',
    variants: [
      'status neutral', 'status done', 'status active',
      'choice selected', 'choice unselected',
    ],
    build: (_) => const _KaiChipStory(),
  ),
  Story(
    layer: StoryLayer.atoms,
    name: 'KaiBadge',
    importPath: 'package:kai_app/design_system/atoms/atoms.dart',
    canonFile: 'new-design/nav.html',
    canonSelector: '.mem-dot',
    description:
        'Notification badge — dot variant for the memory indicator, count '
        'variant (with 99+ cap) for numeric notification counts.',
    variants: ['dot', 'count(n)'],
    build: (_) => const _KaiBadgeStory(),
  ),
  Story(
    layer: StoryLayer.atoms,
    name: 'KaiAvatar',
    importPath: 'package:kai_app/design_system/atoms/atoms.dart',
    canonFile: 'new-design/settings.html',
    canonSelector: '.acc-hero .avatar',
    description:
        'Circular avatar filled with the tide corner gradient. Shows an '
        'optional single initial letter at center.',
    variants: ['KaiAvatar()', 'initial: "R"', 'size: 56'],
    build: (_) => const _KaiAvatarStory(),
  ),
  Story(
    layer: StoryLayer.atoms,
    name: 'KaiTideCurve',
    importPath: 'package:kai_app/design_system/atoms/atoms.dart',
    canonFile: 'new-design/tide-states.html',
    canonSelector: '.tide-curve',
    description:
        'Kai\'s living tide curve — the brand mark. Eight states (idle, '
        'listening, thinking, responding, success, error, memory, sleep), '
        'each with distinct stroke, opacity, and animation behaviour.',
    variants: [
      'idle', 'listening', 'thinking', 'responding',
      'success', 'error', 'memory', 'sleep',
    ],
    build: (_) => const _KaiTideCurveStory(),
  ),
  Story(
    layer: StoryLayer.atoms,
    name: 'KaiDivider',
    importPath: 'package:kai_app/design_system/atoms/atoms.dart',
    canonFile: 'new-design/foundations.html',
    canonSelector: 'hr, .divider',
    description:
        'Hairline 1px divider in the theme line color. Horizontal fills '
        'available width; vertical fills available height.',
    variants: ['horizontal', 'vertical'],
    build: (_) => const _KaiDividerStory(),
  ),
  Story(
    layer: StoryLayer.atoms,
    name: 'KaiSheetShell',
    importPath: 'package:kai_app/design_system/atoms/atoms.dart',
    canonFile: 'new-design/components.html',
    canonSelector: '.sheet',
    description:
        'Bottom-sheet chrome — 24px top-corner radius, drag indicator, '
        'border-top in line color. Wraps any sheet content.',
    variants: ['KaiSheetShell(child: ...)'],
    build: (_) => const _KaiSheetShellStory(),
  ),
];

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
