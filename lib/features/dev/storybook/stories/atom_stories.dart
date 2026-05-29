import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../design_system/atoms/atoms.dart';
import '../../../../design_system/primitives/primitives.dart';
import '../../../../design_system/tokens/kai_tokens.dart';
import '../story_page.dart';
import '../story_registry.dart';

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
    variants: const [
      'hero', 'display', 'h1', 'h2', 'h3',
      'lead', 'body', 'small', 'micro', 'mono',
    ],
    props: const [
      PropDoc('text', 'String', 'required', 'Content to render'),
      PropDoc('color', 'Color?', 'ink1', 'Override text color'),
      PropDoc('textAlign', 'TextAlign?', 'null', 'Text alignment'),
      PropDoc('gradient', 'bool', 'false', 'Display-tier only: tide gradient fill'),
    ],
    build: (_) => const StoryPage(
      title: 'KaiText',
      layer: 'ATOM',
      blurb: 'Typed text atom — 10 named constructors map to the full KaiType '
          'scale. Display-tier (hero–h3) supports gradient: true for tide emphasis.',
      sections: [
        StorySection('Type scale', [
          StoryCell('hero', KaiText.hero('Hero 72')),
          StoryCell('display', KaiText.display('Display 56')),
          StoryCell('h1', KaiText.h1('H1 36')),
          StoryCell('h2', KaiText.h2('H2 24')),
          StoryCell('h3', KaiText.h3('H3 18')),
          StoryCell('lead', KaiText.lead('Lead 20')),
          StoryCell('body', KaiText.body('Body 16')),
          StoryCell('small', KaiText.small('Small 14')),
          StoryCell('micro', KaiText.micro('MICRO 12')),
          StoryCell('mono', KaiText.mono('mono.code()')),
        ]),
        StorySection('Gradient emphasis (display tier)', [
          StoryCell('h1 gradient', KaiText.h1('Gradient', gradient: true)),
          StoryCell('h2 gradient', KaiText.h2('Gradient', gradient: true)),
          StoryCell('h3 gradient', KaiText.h3('Gradient', gradient: true)),
        ]),
      ],
      usage: "KaiText.body('Hello')\n"
          "KaiText.h1('Title', gradient: true)\n"
          'KaiText.micro(label, color: c.ink3)',
      props: [
        PropDoc('text', 'String', 'required', 'Content to render'),
        PropDoc('color', 'Color?', 'ink1', 'Override text color'),
        PropDoc('textAlign', 'TextAlign?', 'null', 'Text alignment'),
        PropDoc('gradient', 'bool', 'false', 'Display-tier only: tide gradient fill'),
      ],
    ),
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
    variants: const ['tide', 'ink', 'ghost', 'text'],
    props: const [
      PropDoc('label', 'String', 'required', 'Button text'),
      PropDoc('onPressed', 'VoidCallback?', 'required', 'null = disabled'),
      PropDoc('size', 'KaiButtonSize', 'md', 'sm / md / lg'),
      PropDoc('emphasis', 'KaiButtonEmphasis', 'normal', 'tide glow variant'),
      PropDoc('tideAnim', 'KaiTideAnim', 'onInteraction', 'tide flow trigger'),
      PropDoc('busy', 'bool', 'false', 'onState flow when true'),
      PropDoc('icon', 'KaiIconName?', 'null', 'Optional leading icon'),
    ],
    build: (_) => StoryPage(
      title: 'KaiButton',
      layer: 'ATOM',
      blurb: 'Primary action button. One tide per screen; others ink/ghost/text.',
      sections: [
        StorySection('Variants', [
          StoryCell('tide', KaiButton.tide(label: 'Send', onPressed: () {})),
          StoryCell('ink', KaiButton.ink(label: 'New chat', onPressed: () {})),
          StoryCell('ghost', KaiButton.ghost(label: 'Retry', onPressed: () {})),
          StoryCell('text·accent', KaiButton.text(
            label: 'Open', onPressed: () {}, tone: KaiButtonTone.accent)),
        ]),
        StorySection('Sizes', [
          StoryCell('sm', KaiButton.ink(
            label: 'sm', onPressed: () {}, size: KaiButtonSize.sm)),
          StoryCell('md', KaiButton.ink(
            label: 'md', onPressed: () {}, size: KaiButtonSize.md)),
          StoryCell('lg', KaiButton.ink(
            label: 'lg', onPressed: () {}, size: KaiButtonSize.lg)),
        ]),
        StorySection('Ghost tones', [
          StoryCell('neutral', KaiButton.ghost(label: 'Neutral', onPressed: () {})),
          StoryCell('warning', KaiButton.ghost(
            label: 'Warning', onPressed: () {}, tone: KaiButtonTone.warning)),
          StoryCell('negative', KaiButton.ghost(
            label: 'Negative', onPressed: () {}, tone: KaiButtonTone.negative)),
          StoryCell('pill', KaiButton.ghost(
            label: 'Pill ghost', onPressed: () {}, pill: true)),
        ]),
        StorySection('States', [
          const StoryCell('disabled', KaiButton.tide(label: 'Send', onPressed: null)),
          StoryCell('glow', KaiButton.tide(
            label: 'Upgrade', onPressed: () {},
            emphasis: KaiButtonEmphasis.glow)),
        ]),
        StorySection('Tide animation', [
          StoryCell('onInteraction', KaiButton.tide(
            label: 'Hover me', onPressed: () {},
            tideAnim: KaiTideAnim.onInteraction)),
          StoryCell('onState busy', KaiButton.tide(
            label: 'Sending', onPressed: () {},
            tideAnim: KaiTideAnim.onState, busy: true)),
        ]),
      ],
      usage: "KaiButton.tide(label: 'Send', onPressed: _send,\n"
          '  tideAnim: KaiTideAnim.onState, busy: isStreaming)',
      props: const [
        PropDoc('label', 'String', 'required', 'Button text'),
        PropDoc('onPressed', 'VoidCallback?', 'required', 'null = disabled'),
        PropDoc('size', 'KaiButtonSize', 'md', 'sm / md / lg'),
        PropDoc('emphasis', 'KaiButtonEmphasis', 'normal', 'tide glow variant'),
        PropDoc('tideAnim', 'KaiTideAnim', 'onInteraction', 'tide flow trigger'),
        PropDoc('busy', 'bool', 'false', 'onState flow when true'),
        PropDoc('icon', 'KaiIconName?', 'null', 'Optional leading icon'),
      ],
    ),
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
    variants: const ['surface', 'transparent', 'bare'],
    props: const [
      PropDoc('onPressed', 'VoidCallback?', 'required', 'null = disabled'),
      PropDoc('icon', 'KaiIconName', 'required', 'Glyph to render'),
      PropDoc('size', 'double', '18', 'Glyph size; tap target = size + 12'),
      PropDoc('color', 'Color?', 'ink2', 'bare variant only: icon color override'),
    ],
    build: (_) => StoryPage(
      title: 'KaiIconButton',
      layer: 'ATOM',
      blurb: 'Icon-only button — 3 variants. surface: compose slots; '
          'transparent: mic; bare: sheet close / nav actions.',
      sections: [
        StorySection('Variants', [
          StoryCell('surface', KaiIconButton.surface(
            onPressed: () {}, icon: KaiIconName.mic)),
          StoryCell('transparent', KaiIconButton.transparent(
            onPressed: () {}, icon: KaiIconName.mic)),
          StoryCell('bare', KaiIconButton.bare(
            onPressed: () {}, icon: KaiIconName.close)),
        ]),
        const StorySection('States', [
          StoryCell('disabled', KaiIconButton.bare(
            onPressed: null, icon: KaiIconName.lock)),
        ]),
        StorySection('Icons sampling', [
          StoryCell('settings', KaiIconButton.bare(
            onPressed: () {}, icon: KaiIconName.settings)),
          StoryCell('search', KaiIconButton.surface(
            onPressed: () {}, icon: KaiIconName.search)),
          StoryCell('plus', KaiIconButton.surface(
            onPressed: () {}, icon: KaiIconName.plus)),
        ]),
      ],
      usage: 'KaiIconButton.surface(onPressed: _attach, icon: KaiIconName.plus)\n'
          'KaiIconButton.transparent(onPressed: _mic, icon: KaiIconName.mic)\n'
          'KaiIconButton.bare(onPressed: _close, icon: KaiIconName.close)',
      props: const [
        PropDoc('onPressed', 'VoidCallback?', 'required', 'null = disabled'),
        PropDoc('icon', 'KaiIconName', 'required', 'Glyph to render'),
        PropDoc('size', 'double', '18', 'Glyph size; tap target = size + 12'),
        PropDoc('color', 'Color?', 'ink2', 'bare variant only: icon color override'),
      ],
    ),
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
    variants: const ['ready', 'disabled', 'sending', 'streaming'],
    props: const [
      PropDoc('state', 'KaiSendState', 'required', 'Controls visuals + tap behaviour'),
      PropDoc('onPressed', 'VoidCallback?', 'required', 'Ignored when state=disabled'),
      PropDoc('size', 'double', '30', 'Circle diameter in logical pixels'),
      PropDoc('iconSize', 'double', '12', 'Arrow icon size'),
    ],
    build: (_) => StoryPage(
      title: 'KaiSendButton',
      layer: 'ATOM',
      blurb: 'Circular primary CTA in the compose island. Four states: '
          'ready/disabled/sending/streaming. Tap the interactive cell to cycle.',
      sections: [
        StorySection('States', [
          StoryCell('ready', KaiSendButton(
            state: KaiSendState.ready, onPressed: () {})),
          const StoryCell('disabled', KaiSendButton(
            state: KaiSendState.disabled, onPressed: null)),
          StoryCell('sending', KaiSendButton(
            state: KaiSendState.sending, onPressed: () {})),
          StoryCell('streaming', KaiSendButton(
            state: KaiSendState.streaming, onPressed: () {})),
        ]),
        const StorySection('Sizes', [
          StoryCell('sm (24)', KaiSendButton(
            state: KaiSendState.ready, onPressed: null, size: 24, iconSize: 10)),
          StoryCell('default (30)', KaiSendButton(
            state: KaiSendState.ready, onPressed: null)),
          StoryCell('lg (40)', KaiSendButton(
            state: KaiSendState.ready, onPressed: null, size: 40, iconSize: 16)),
        ]),
        const StorySection('Interactive', [
          StoryCell('tap to cycle', _SendButtonCycler()),
        ]),
      ],
      usage: 'KaiSendButton(\n'
          '  state: isStreaming ? KaiSendState.streaming : KaiSendState.ready,\n'
          '  onPressed: _send,\n'
          ')',
      props: const [
        PropDoc('state', 'KaiSendState', 'required', 'Controls visuals + tap behaviour'),
        PropDoc('onPressed', 'VoidCallback?', 'required', 'Ignored when state=disabled'),
        PropDoc('size', 'double', '30', 'Circle diameter in logical pixels'),
        PropDoc('iconSize', 'double', '12', 'Arrow icon size'),
      ],
    ),
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
    variants: const ['line', 'pill'],
    props: const [
      PropDoc('controller', 'TextEditingController', 'required', 'Text controller'),
      PropDoc('placeholder', 'String?', 'null', 'Hint text'),
      PropDoc('maxLines', 'int', '1', 'Max lines before scroll'),
      PropDoc('minLines', 'int?', 'null', 'Minimum lines to show'),
      PropDoc('onChanged', 'ValueChanged<String>?', 'null', 'Text change callback'),
      PropDoc('focusNode', 'FocusNode?', 'null', 'Focus control'),
      PropDoc('enabled', 'bool', 'true', 'false = dimmed, no interaction'),
    ],
    build: (_) => const StoryPage(
      title: 'KaiInput',
      layer: 'ATOM',
      blurb: 'Text field with two variants: line (search/settings) and pill '
          '(compose island textarea). The pill is half-round — it is designed '
          'to sit inside ComposeIsland, so it looks "cut" when rendered standalone.',
      sections: [
        StorySection('Variants', [
          StoryCell('line · standalone', _InputLineDemo()),
          StoryCell('pill · compose-island field',
              _InputPillComposeDemo()),
        ]),
        StorySection('States', [
          StoryCell('disabled', _InputDisabledDemo()),
        ]),
      ],
      usage: 'KaiInput.line(controller: _ctrl, placeholder: "Поиск...")\n'
          'KaiInput.pill(controller: _ctrl, maxLines: 4, minLines: 1)',
      props: [
        PropDoc('controller', 'TextEditingController', 'required', 'Text controller'),
        PropDoc('placeholder', 'String?', 'null', 'Hint text'),
        PropDoc('maxLines', 'int', '1', 'Max lines before scroll'),
        PropDoc('minLines', 'int?', 'null', 'Minimum lines to show'),
        PropDoc('onChanged', 'ValueChanged<String>?', 'null', 'Text change callback'),
        PropDoc('focusNode', 'FocusNode?', 'null', 'Focus control'),
        PropDoc('enabled', 'bool', 'true', 'false = dimmed, no interaction'),
      ],
    ),
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
    variants: const ['on', 'off', 'disabled (onChanged: null)'],
    props: const [
      PropDoc('value', 'bool', 'required', 'Current toggle state'),
      PropDoc('onChanged', 'ValueChanged<bool>?', 'required', 'null = disabled'),
    ],
    build: (_) => const StoryPage(
      title: 'KaiToggle',
      layer: 'ATOM',
      blurb: 'Pill switch — 34×20 track. Accent fill when on, surface3 when off. '
          'Disabled = opacity 0.5, no tap.',
      sections: [
        StorySection('States (static)', [
          StoryCell('on', KaiToggle(value: true, onChanged: null)),
          StoryCell('off', KaiToggle(value: false, onChanged: null)),
          StoryCell('disabled', KaiToggle(value: true, onChanged: null)),
        ]),
        StorySection('Interactive', [
          StoryCell('tap to toggle', _ToggleDemo()),
        ]),
      ],
      usage: 'KaiToggle(\n'
          '  value: _isOn,\n'
          '  onChanged: (v) => setState(() => _isOn = v),\n'
          ')',
      props: [
        PropDoc('value', 'bool', 'required', 'Current toggle state'),
        PropDoc('onChanged', 'ValueChanged<bool>?', 'required', 'null = disabled'),
      ],
    ),
  ),
  Story(
    layer: StoryLayer.atoms,
    name: 'KaiChip',
    importPath: 'package:kai_app/design_system/atoms/atoms.dart',
    canonFile: 'new-design/components.html',
    canonSelector: '.chip',
    description:
        'Status pill (non-interactive, mono-uppercase) and choice chip '
        '(selectable filter). Six tone variants for status; two size variants.',
    variants: const [
      'status neutral', 'status done', 'status active',
      'status positive', 'status warning', 'status negative',
      'choice selected', 'choice unselected',
    ],
    props: const [
      PropDoc('label', 'String', 'required', 'Chip label text'),
      PropDoc('tone', 'KaiChipTone', 'neutral', 'status only: color scheme'),
      PropDoc('size', 'KaiChipSize', 'md', 'sm (11px) / md (12px) sizing'),
      PropDoc('selected', 'bool', 'required', 'choice only: selected state'),
      PropDoc('onTap', 'VoidCallback?', 'null', 'choice only: tap handler'),
    ],
    build: (_) => const StoryPage(
      title: 'KaiChip',
      layer: 'ATOM',
      blurb: 'Status pill (non-interactive, JetBrains Mono uppercase) and '
          'selectable choice chip (Manrope). Status tones: neutral/done/active/'
          'positive/warning/negative. Two sizes: sm/md.',
      sections: [
        StorySection('Status tones', [
          StoryCell('neutral', KaiChip.status('neutral')),
          StoryCell('done', KaiChip.status('done', tone: KaiChipTone.done)),
          StoryCell('active', KaiChip.status('active', tone: KaiChipTone.active)),
          StoryCell('positive', KaiChip.status('ok', tone: KaiChipTone.positive)),
          StoryCell('warning', KaiChip.status('warn', tone: KaiChipTone.warning)),
          StoryCell('negative', KaiChip.status('error', tone: KaiChipTone.negative)),
        ]),
        StorySection('Sizes', [
          StoryCell('sm · status', KaiChip.status('sm', size: KaiChipSize.sm)),
          StoryCell('md · status (default)', KaiChip.status('md')),
          StoryCell('sm · choice', KaiChip.choice('sm', selected: true, size: KaiChipSize.sm)),
          StoryCell('md · choice (default)', KaiChip.choice('md', selected: true)),
        ]),
        StorySection('Choice chips', [
          StoryCell('selected', KaiChip.choice('Selected', selected: true)),
          StoryCell('unselected', KaiChip.choice('Unselected', selected: false)),
        ]),
      ],
      usage: "KaiChip.status('DONE', tone: KaiChipTone.done)\n"
          "KaiChip.status('warn', tone: KaiChipTone.warning, size: KaiChipSize.sm)\n"
          "KaiChip.choice('Filter', selected: _sel, onTap: _toggle)",
      props: [
        PropDoc('label', 'String', 'required', 'Chip label text'),
        PropDoc('tone', 'KaiChipTone', 'neutral', 'status only: color scheme'),
        PropDoc('size', 'KaiChipSize', 'md', 'sm (11px) / md (12px) sizing'),
        PropDoc('selected', 'bool', 'required', 'choice only: selected state'),
        PropDoc('onTap', 'VoidCallback?', 'null', 'choice only: tap handler'),
      ],
    ),
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
    variants: const ['dot', 'count(n)'],
    props: const [
      PropDoc('color', 'Color?', 'accent', 'dot only: fill color override'),
      PropDoc('count', 'int', 'required', 'count only: number (capped at 99+)'),
    ],
    build: (_) => const StoryPage(
      title: 'KaiBadge',
      layer: 'ATOM',
      blurb: 'Notification badge — dot (6px accent circle, 10px ring) for the '
          'memory indicator; count pill (accent bg) for numeric counts.',
      sections: [
        StorySection('Dot variant', [
          StoryCell('default', KaiBadge.dot()),
        ]),
        StorySection('Count variant', [
          StoryCell('count(5)', KaiBadge.count(5)),
          StoryCell('count(99)', KaiBadge.count(99)),
          StoryCell('count(150) → 99+', KaiBadge.count(150)),
        ]),
      ],
      usage: 'KaiBadge.dot()\n'
          'KaiBadge.count(unreadCount)',
      props: [
        PropDoc('color', 'Color?', 'accent', 'dot only: fill color override'),
        PropDoc('count', 'int', 'required', 'count only: number (capped at 99+)'),
      ],
    ),
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
    variants: const ['KaiAvatar()', 'initial: "R"', 'size: 56'],
    props: const [
      PropDoc('size', 'double', '40', 'Circle diameter in logical pixels'),
      PropDoc('initial', 'String?', 'null', 'Single letter shown at center'),
    ],
    build: (_) => const StoryPage(
      title: 'KaiAvatar',
      layer: 'ATOM',
      blurb: 'Circular avatar with tide corner gradient (135°). Optional initial '
          'letter is uppercased automatically. Default size 40.',
      sections: [
        StorySection('Variants', [
          StoryCell('default (40)', KaiAvatar()),
          StoryCell('initial R', KaiAvatar(initial: 'R')),
          StoryCell('initial K', KaiAvatar(initial: 'K')),
        ]),
        StorySection('Sizes', [
          StoryCell('32', KaiAvatar(size: 32, initial: 'R')),
          StoryCell('40 (default)', KaiAvatar(size: 40, initial: 'R')),
          StoryCell('56', KaiAvatar(size: 56, initial: 'R')),
          StoryCell('72', KaiAvatar(size: 72, initial: 'R')),
        ]),
      ],
      usage: 'KaiAvatar(initial: user.initial)\n'
          'KaiAvatar(size: 56)',
      props: [
        PropDoc('size', 'double', '40', 'Circle diameter in logical pixels'),
        PropDoc('initial', 'String?', 'null', 'Single letter shown at center'),
      ],
    ),
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
    variants: const [
      'idle', 'listening', 'thinking', 'responding',
      'success', 'error', 'memory', 'sleep',
    ],
    props: const [
      PropDoc('state', 'KaiTideState', 'required', 'One of the 8 KaiTide states'),
      PropDoc('height', 'double', '28', 'Render height in logical pixels'),
    ],
    build: (_) => StoryPage(
      title: 'KaiTideCurve',
      layer: 'ATOM',
      blurb: "Kai's brand mark — animated tide curve in 8 states. Ephemeral "
          'states (success/error/memory) auto-revert; demo loop fix comes in C1-T7.',
      sections: [
        StorySection(
          'All 8 states',
          KaiTide.all.map((s) => StoryCell(
            s.name,
            SizedBox(width: 120, height: 28, child: KaiTideCurve(state: s, demoLoop: true)),
          )).toList(),
        ),
        const StorySection('Interactive', [
          StoryCell('tap to cycle', _TideCurveCycler()),
        ]),
      ],
      usage: 'KaiTideCurve(state: tideState)\n'
          '// tideState driven by RoomScreen chat events',
      props: const [
        PropDoc('state', 'KaiTideState', 'required', 'One of the 8 KaiTide states'),
        PropDoc('height', 'double', '28', 'Render height in logical pixels'),
      ],
    ),
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
    variants: const ['horizontal', 'vertical'],
    props: const [
      PropDoc('color', 'Color?', 'line', 'Override divider color'),
    ],
    build: (_) => const StoryPage(
      title: 'KaiDivider',
      layer: 'ATOM',
      blurb: '1px hairline separator in the `line` token. Horizontal fills '
          'available width; vertical fills available height.',
      sections: [
        StorySection('Horizontal', [
          StoryCell('default', KaiDivider()),
        ]),
        StorySection('Vertical (in a Row)', [
          StoryCell(
            'vertical',
            SizedBox(
              height: 40,
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  KaiText.small('left'),
                  SizedBox(width: KaiSpace.s3),
                  KaiDivider.vertical(),
                  SizedBox(width: KaiSpace.s3),
                  KaiText.small('right'),
                ],
              ),
            ),
          ),
        ]),
      ],
      usage: 'KaiDivider()          // horizontal\n'
          'KaiDivider.vertical() // vertical',
      props: [
        PropDoc('color', 'Color?', 'line', 'Override divider color'),
      ],
    ),
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
    variants: const ['KaiSheetShell(child: ...)'],
    props: const [
      PropDoc('child', 'Widget', 'required', 'Sheet body content'),
    ],
    build: (_) => const StoryPage(
      title: 'KaiSheetShell',
      layer: 'ATOM',
      blurb: 'Bottom-sheet chrome — 24px top-corner radius, centered drag '
          'indicator, border-top in the line token. Wraps any sheet body.',
      sections: [
        StorySection('Inline demo', [
          StoryCell(
            'with content',
            KaiSheetShell(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  KaiText.h3('Sheet title'),
                  SizedBox(height: KaiSpace.s2),
                  KaiText.body('Sheet body content here.'),
                ],
              ),
            ),
          ),
        ]),
      ],
      usage: 'showModalBottomSheet(\n'
          '  context: context,\n'
          '  builder: (_) => KaiSheetShell(child: MyContent()),\n'
          ')',
      props: [
        PropDoc('child', 'Widget', 'required', 'Sheet body content'),
      ],
    ),
  ),
];

// ── KaiInput demo helpers (StatefulWidget — need controllers) ─────────────────

class _InputLineDemo extends StatefulWidget {
  const _InputLineDemo();

  @override
  State<_InputLineDemo> createState() => _InputLineDemoState();
}

class _InputLineDemoState extends State<_InputLineDemo> {
  final _ctrl = TextEditingController();

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 220,
      child: KaiInput.line(
        controller: _ctrl,
        placeholder: 'Search…',
      ),
    );
  }
}

class _InputPillComposeDemo extends StatefulWidget {
  const _InputPillComposeDemo();

  @override
  State<_InputPillComposeDemo> createState() => _InputPillComposeDemoState();
}

class _InputPillComposeDemoState extends State<_InputPillComposeDemo> {
  final _ctrl = TextEditingController();

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // Wrap in a SizedBox to simulate the compose-island context.
    return SizedBox(
      width: 260,
      child: Row(
        children: [
          Expanded(
            child: KaiInput.pill(
              controller: _ctrl,
              placeholder: 'Напишите…',
              maxLines: 4,
              minLines: 1,
            ),
          ),
          const SizedBox(width: KaiSpace.s2),
          KaiIconButton.transparent(
            onPressed: () {},
            icon: KaiIconName.mic,
          ),
          const SizedBox(width: KaiSpace.s1),
          KaiSendButton(state: KaiSendState.ready, onPressed: () {}),
        ],
      ),
    );
  }
}

class _InputDisabledDemo extends StatelessWidget {
  const _InputDisabledDemo();

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 220,
      child: KaiInput.line(
        controller: TextEditingController(text: 'disabled field'),
        enabled: false,
      ),
    );
  }
}

// ── KaiToggle interactive demo ────────────────────────────────────────────────

class _ToggleDemo extends StatefulWidget {
  const _ToggleDemo();

  @override
  State<_ToggleDemo> createState() => _ToggleDemoState();
}

class _ToggleDemoState extends State<_ToggleDemo> {
  bool _value = false;

  @override
  Widget build(BuildContext context) {
    return KaiToggle(
      value: _value,
      onChanged: (v) => setState(() => _value = v),
    );
  }
}

// ── KaiSendButton cycle demo ──────────────────────────────────────────────────

class _SendButtonCycler extends ConsumerStatefulWidget {
  const _SendButtonCycler();

  @override
  ConsumerState<_SendButtonCycler> createState() => _SendButtonCyclerState();
}

class _SendButtonCyclerState extends ConsumerState<_SendButtonCycler> {
  KaiSendState _state = KaiSendState.ready;

  void _cycle() {
    setState(() {
      const vals = KaiSendState.values;
      _state = vals[(vals.indexOf(_state) + 1) % vals.length];
    });
  }

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        KaiSendButton(state: _state, onPressed: _cycle),
        const SizedBox(width: KaiSpace.s3),
        KaiButton.ghost(
          onPressed: _cycle,
          label: _state.name,
        ),
      ],
    );
  }
}

// ── KaiTideCurve cycle demo ───────────────────────────────────────────────────

class _TideCurveCycler extends StatefulWidget {
  const _TideCurveCycler();

  @override
  State<_TideCurveCycler> createState() => _TideCurveCyclerState();
}

class _TideCurveCyclerState extends State<_TideCurveCycler> {
  int _index = 0;

  @override
  Widget build(BuildContext context) {
    final tideState = KaiTide.all[_index];
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        SizedBox(width: 200, height: 28, child: KaiTideCurve(state: tideState)),
        const SizedBox(height: KaiSpace.s3),
        KaiButton.ghost(
          onPressed: () =>
              setState(() => _index = (_index + 1) % KaiTide.all.length),
          label: tideState.name,
        ),
      ],
    );
  }
}
