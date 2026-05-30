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
          StoryCell('A · onInteraction (default)', KaiButton.tide(
            label: 'Hover me', onPressed: () {},
            tideAnim: KaiTideAnim.onInteraction)),
          StoryCell('B · onState (busy contexts)', KaiButton.tide(
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
        'Icon-only button — surface/transparent/bare/toggle variants. '
        'Two sizes: sm (16px icon) and md (18px icon, default).',
    variants: const ['surface', 'transparent', 'bare', 'toggle(active)', 'toggle(inactive)'],
    props: const [
      PropDoc('onPressed', 'VoidCallback?', 'required', 'null = disabled'),
      PropDoc('icon', 'KaiIconName', 'required', 'Glyph to render'),
      PropDoc('iconSize', 'KaiIconButtonSize', 'md', 'sm=16px / md=18px icon'),
      PropDoc('size', 'double?', 'null', 'Pixel override — wins over iconSize'),
      PropDoc('color', 'Color?', 'ink2', 'bare only: icon color override'),
      PropDoc('active', 'bool', 'required', 'toggle only: active state'),
    ],
    build: (_) => StoryPage(
      title: 'KaiIconButton',
      layer: 'ATOM',
      blurb: 'Icon-only button — 4 variants. surface: compose slots; '
          'transparent: mic; bare: sheet close / nav actions; '
          'toggle: active/inactive state with accentWash pill.',
      sections: [
        StorySection('Variants', [
          StoryCell('surface', KaiIconButton.surface(
            onPressed: () {}, icon: KaiIconName.mic)),
          StoryCell('transparent', KaiIconButton.transparent(
            onPressed: () {}, icon: KaiIconName.mic)),
          StoryCell('bare', KaiIconButton.bare(
            onPressed: () {}, icon: KaiIconName.close)),
          StoryCell('toggle active', KaiIconButton.toggle(
            active: true, onPressed: () {}, icon: KaiIconName.mic)),
          StoryCell('toggle inactive', KaiIconButton.toggle(
            active: false, onPressed: () {}, icon: KaiIconName.mic)),
        ]),
        StorySection('Sizes', [
          StoryCell('sm (16px)', KaiIconButton.surface(
            onPressed: () {}, icon: KaiIconName.plus,
            iconSize: KaiIconButtonSize.sm)),
          StoryCell('md (18px, default)', KaiIconButton.surface(
            onPressed: () {}, icon: KaiIconName.plus)),
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
          'KaiIconButton.bare(onPressed: _close, icon: KaiIconName.close)\n'
          'KaiIconButton.toggle(active: _isActive, onPressed: _toggle, icon: KaiIconName.mic)',
      props: const [
        PropDoc('onPressed', 'VoidCallback?', 'required', 'null = disabled'),
        PropDoc('icon', 'KaiIconName', 'required', 'Glyph to render'),
        PropDoc('iconSize', 'KaiIconButtonSize', 'md', 'sm=16px / md=18px icon'),
        PropDoc('size', 'double?', 'null', 'Pixel override — wins over iconSize'),
        PropDoc('color', 'Color?', 'ink2', 'bare only: icon color override'),
        PropDoc('active', 'bool', 'required', 'toggle only: active state'),
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
          StoryCell('sending', KaiSendButton(
            state: KaiSendState.sending, onPressed: () {})),
          StoryCell('streaming (stop)', KaiSendButton(
            state: KaiSendState.streaming, onPressed: () {})),
          const StoryCell('disabled', KaiSendButton(
            state: KaiSendState.disabled, onPressed: null)),
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
        'Notification badge — dot (toned) for the memory indicator, count '
        '(with 99+ cap) for numeric counts, tide for the memory-saved signal.',
    variants: const ['dot (tones)', 'count(n)', 'tide'],
    props: const [
      PropDoc('tone', 'KaiBadgeTone', 'accent', 'dot only: semantic fill tone'),
      PropDoc('color', 'Color?', 'null', 'dot only: explicit fill override (wins over tone)'),
      PropDoc('count', 'int', 'required', 'count only: number (capped at 99+)'),
    ],
    build: (_) => const StoryPage(
      title: 'KaiBadge',
      layer: 'ATOM',
      blurb: 'Notification badge — dot (6px circle, 10px ring) supports four '
          'semantic tones; count pill for numbers; tide dot for the memory signal.',
      sections: [
        StorySection('Variants', [
          StoryCell('dot · accent', KaiBadge.dot()),
          StoryCell('dot · positive', KaiBadge.dot(tone: KaiBadgeTone.positive)),
          StoryCell('dot · warning', KaiBadge.dot(tone: KaiBadgeTone.warning)),
          StoryCell('dot · negative', KaiBadge.dot(tone: KaiBadgeTone.negative)),
          StoryCell('count(5)', KaiBadge.count(5)),
          StoryCell('count(99)', KaiBadge.count(99)),
          StoryCell('count(150) → 99+', KaiBadge.count(150)),
          StoryCell('tide (memory)', KaiBadge.tide()),
        ]),
      ],
      usage: 'KaiBadge.dot()                              // accent default\n'
          'KaiBadge.dot(tone: KaiBadgeTone.warning)    // warning\n'
          'KaiBadge.tide()                              // memory signal\n'
          'KaiBadge.count(unreadCount)',
      props: [
        PropDoc('tone', 'KaiBadgeTone', 'accent', 'dot only: semantic fill tone'),
        PropDoc('color', 'Color?', 'null', 'dot only: explicit fill override (wins over tone)'),
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
        'Circular avatar — .user(initial) or .kai (gradient bar mark). '
        'Three sizes (sm/md/lg) and optional breathing pulse.',
    variants: const [
      'user(initial)', 'kai',
      'sm (28)', 'md (40)', 'lg (56)',
      'breathing',
    ],
    props: const [
      PropDoc('avatarSize', 'KaiAvatarSize', 'md', 'sm=28 / md=40 / lg=56'),
      PropDoc('breathing', 'bool', 'false', 'Scale 0.97↔1.03 ambient pulse'),
      PropDoc('initial', 'String', 'required', 'user only: letter at center'),
      PropDoc('size', 'double', '40', 'legacy ctor: diameter override'),
    ],
    build: (_) => const StoryPage(
      title: 'KaiAvatar',
      layer: 'ATOM',
      blurb: 'Circular avatar with tide corner gradient (135°). .user shows an '
          'initial letter; .kai shows the gradient bar mark. Three sizes. '
          'Optional ambient breathing animation.',
      sections: [
        StorySection('User vs Kai', [
          StoryCell('user(R)', KaiAvatar.user('R')),
          StoryCell('user(K)', KaiAvatar.user('K')),
          StoryCell('kai', KaiAvatar.kai()),
        ]),
        StorySection('Sizes', [
          StoryCell('sm (28)', KaiAvatar.user('R', avatarSize: KaiAvatarSize.sm)),
          StoryCell('md (40)', KaiAvatar.user('R')),
          StoryCell('lg (56)', KaiAvatar.user('R', avatarSize: KaiAvatarSize.lg)),
          StoryCell('kai sm', KaiAvatar.kai(avatarSize: KaiAvatarSize.sm)),
          StoryCell('kai lg', KaiAvatar.kai(avatarSize: KaiAvatarSize.lg)),
        ]),
        StorySection('Breathing pulse', [
          StoryCell('user breathing', KaiAvatar.user('K', breathing: true)),
          StoryCell('kai breathing', KaiAvatar.kai(breathing: true)),
        ]),
        StorySection('Legacy ctor (compat)', [
          StoryCell('default (40)', KaiAvatar()),
          StoryCell('size 56', KaiAvatar(size: 56, initial: 'R')),
        ]),
      ],
      usage: 'KaiAvatar.user(user.initial)\n'
          'KaiAvatar.user(initial, avatarSize: KaiAvatarSize.lg)\n'
          'KaiAvatar.kai(breathing: true)',
      props: [
        PropDoc('avatarSize', 'KaiAvatarSize', 'md', 'sm=28 / md=40 / lg=56'),
        PropDoc('breathing', 'bool', 'false', 'Scale 0.97↔1.03 ambient pulse'),
        PropDoc('initial', 'String', 'required', 'user only: letter at center'),
        PropDoc('size', 'double', '40', 'legacy ctor: diameter override'),
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
    name: 'KaiForkChip',
    importPath: 'package:kai_app/design_system/atoms/atoms.dart',
    canonFile: 'new-design/fork.html',
    canonSelector: '.chip',
    description:
        'Fork-card visa-status pill. 8px/600 Manrope, pill radius, three tones: '
        'bad (negativeWash), neutral (surface3 + border), ok (positiveWash).',
    variants: const ['bad', 'neutral', 'ok'],
    props: const [
      PropDoc('label', 'String', 'required', 'Text to display (no uppercase transform)'),
      PropDoc('tone', 'KaiForkChipTone', 'neutral', 'bad / neutral / ok'),
    ],
    build: (_) => const StoryPage(
      title: 'KaiForkChip',
      layer: 'ATOM',
      blurb: 'Visa/weather/crowd status pill used inside ForkCard. JetBrains Mono '
          '8px/600 UPPERCASE (canon fork.html .chip), smaller than KaiChip.status '
          '(12px). Four semantic tones: bad / neutral / ok / warn.',
      sections: [
        StorySection('Tones', [
          StoryCell('bad', KaiForkChip('виза нужна', tone: KaiForkChipTone.bad)),
          StoryCell('neutral', KaiForkChip('14°C')),
          StoryCell('ok', KaiForkChip('без визы', tone: KaiForkChipTone.ok)),
          StoryCell('warn', KaiForkChip('толпы↑', tone: KaiForkChipTone.warn)),
        ]),
        StorySection('More examples', [
          StoryCell('crowds ok', KaiForkChip('толпы↓', tone: KaiForkChipTone.ok)),
          StoryCell('neutral temp', KaiForkChip('10°C')),
        ]),
      ],
      usage: "KaiForkChip('без визы', tone: KaiForkChipTone.ok)\n"
          "KaiForkChip('виза нужна', tone: KaiForkChipTone.bad)\n"
          "KaiForkChip('толпы↑', tone: KaiForkChipTone.warn)\n"
          "KaiForkChip('14°C')  // neutral default · renders UPPERCASE",
      props: [
        PropDoc('label', 'String', 'required', 'Text to display (rendered UPPERCASE)'),
        PropDoc('tone', 'KaiForkChipTone', 'neutral', 'bad / neutral / ok / warn'),
      ],
    ),
  ),
  Story(
    layer: StoryLayer.atoms,
    name: 'KaiForkScoreDots',
    importPath: 'package:kai_app/design_system/atoms/atoms.dart',
    canonFile: 'new-design/fork.html',
    canonSelector: '.fc-score',
    description:
        'Rating row of up to 5 small circles. Filled dots use positive (or custom '
        'fillColor); empty dots use surface3. 5×5px circles, 3px gap.',
    variants: const ['score=4/5', 'score=5/5', 'score=0/5', 'custom fillColor'],
    props: const [
      PropDoc('score', 'int', 'required', 'Number of filled dots'),
      PropDoc('max', 'int', '5', 'Total dot count'),
      PropDoc('fillColor', 'Color?', 'c.positive', 'Override filled-dot color'),
    ],
    build: (_) => const StoryPage(
      title: 'KaiForkScoreDots',
      layer: 'ATOM',
      blurb: 'Compact rating row used inside KaiForkCard. Row of max circles '
          '(default 5); first score dots filled with positive token, rest with '
          'surface3. 5×5px circles, 3px gap — all canon literals from fork.html.',
      sections: [
        StorySection('Scores', [
          StoryCell('4/5', KaiForkScoreDots(score: 4)),
          StoryCell('5/5', KaiForkScoreDots(score: 5)),
          StoryCell('3/5', KaiForkScoreDots(score: 3)),
          StoryCell('0/5', KaiForkScoreDots(score: 0)),
        ]),
        StorySection('Custom fill (tide-2)', [
          StoryCell(
            'tide-2 fill',
            KaiForkScoreDots(
              score: 3,
              fillColor: Color(0xFF2BA8C9),
            ),
          ),
        ]),
      ],
      usage: 'KaiForkScoreDots(score: 4)          // 4/5 positive\n'
          'KaiForkScoreDots(score: 5, max: 5)   // full\n'
          'KaiForkScoreDots(score: 3, fillColor: c.accent)',
      props: [
        PropDoc('score', 'int', 'required', 'Number of filled dots (0..max)'),
        PropDoc('max', 'int', '5', 'Total dot count'),
        PropDoc('fillColor', 'Color?', 'c.positive', 'Override filled-dot color'),
      ],
    ),
  ),
  Story(
    layer: StoryLayer.atoms,
    name: 'KaiStepIndicator',
    importPath: 'package:kai_app/design_system/atoms/atoms.dart',
    canonFile: 'new-design/onboarding.html',
    canonSelector: '.step-dots',
    description:
        'Animated step-progress dots. Active dot = elongated accent pill '
        '(16×6px, brPill); inactive = small circle (6×6px, ink4). '
        'AnimatedContainer transitions width+colour as active changes.',
    variants: const ['active=0', 'active=1', 'active=2', 'active=3'],
    props: const [
      PropDoc('count', 'int', 'required', 'Total number of steps'),
      PropDoc('active', 'int', 'required', 'Index of the active step (0-based)'),
    ],
    build: (_) => const StoryPage(
      title: 'KaiStepIndicator',
      layer: 'ATOM',
      blurb: 'Step-progress dots for multi-step flows (onboarding etc.). '
          'Active dot animates to an elongated accent pill; inactive dots are '
          'small ink4 circles. Respects reduce-motion preference.',
      sections: [
        StorySection('Static positions', [
          StoryCell('active=0', KaiStepIndicator(count: 4, active: 0)),
          StoryCell('active=1', KaiStepIndicator(count: 4, active: 1)),
          StoryCell('active=2', KaiStepIndicator(count: 4, active: 2)),
          StoryCell('active=3', KaiStepIndicator(count: 4, active: 3)),
        ]),
        StorySection('Interactive', [
          StoryCell('prev/next', _StepperDemo()),
        ]),
      ],
      usage: 'KaiStepIndicator(count: 4, active: stepIndex)',
      props: [
        PropDoc('count', 'int', 'required', 'Total number of steps'),
        PropDoc('active', 'int', 'required', 'Index of the active step (0-based)'),
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
  Story(
    layer: StoryLayer.atoms,
    name: 'KaiKaraokeText',
    importPath: 'package:kai_app/design_system/atoms/atoms.dart',
    canonFile: 'new-design/voice.html',
    canonSelector: '.karaoke',
    description:
        'Voice-mode word-reveal atom. Spoken words are full white, '
        'the current "now" word has a tide-3 amber highlight, '
        'future "next" words are dim white. Dark-surface only.',
    variants: const ['currentIndex=1', 'all spoken', 'none spoken'],
    props: const [
      PropDoc('words', 'List<String>', 'required', 'All words in the sentence'),
      PropDoc(
          'currentIndex', 'int', 'required', 'Index of word now being spoken'),
    ],
    build: (_) => const _KaiKaraokeTextStory(),
  ),
  Story(
    layer: StoryLayer.atoms,
    name: 'KaiBudgetBar',
    importPath: 'package:kai_app/design_system/atoms/atoms.dart',
    canonFile: 'new-design/trip-detail.html',
    canonSelector: '.budget-bar',
    description:
        'Segmented horizontal budget bar for trip-detail breakdown. '
        'Pill track (surface3 bg, KaiRadius.brPill) containing proportional '
        'coloured segments via Expanded(flex: (fraction*1000).round()). '
        'Optional legend row with colour swatches and labels. '
        'Canon: new-design/trip-detail.html .budget-bar.',
    variants: const ['4 segments + legend', '2 segments no legend', 'partial fill'],
    props: const [
      PropDoc('segments', 'List<KaiBudgetSegment>', 'required',
          'Proportional coloured segments — fractions should sum ≤ 1.0'),
      PropDoc('height', 'double', '8', 'Track height in logical pixels'),
      PropDoc('showLegend', 'bool', 'false',
          'When true, renders a legend row with colour swatch + label below the track'),
    ],
    build: (_) => const _KaiBudgetBarStory(),
  ),
];

// ── KaiStepIndicator interactive demo ────────────────────────────────────────

class _StepperDemo extends StatefulWidget {
  const _StepperDemo();

  @override
  State<_StepperDemo> createState() => _StepperDemoState();
}

class _StepperDemoState extends State<_StepperDemo> {
  int _active = 0;
  static const _count = 4;

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        KaiStepIndicator(count: _count, active: _active),
        const SizedBox(height: KaiSpace.s3),
        Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            KaiButton.ghost(
              onPressed: _active > 0
                  ? () => setState(() => _active--)
                  : null,
              label: '←',
              size: KaiButtonSize.sm,
            ),
            const SizedBox(width: KaiSpace.s3),
            KaiButton.ghost(
              onPressed: _active < _count - 1
                  ? () => setState(() => _active++)
                  : null,
              label: '→',
              size: KaiButtonSize.sm,
            ),
          ],
        ),
      ],
    );
  }
}

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

// ── KaiKaraokeText dark-surface story ────────────────────────────────────────

class _KaiKaraokeTextStory extends StatelessWidget {
  const _KaiKaraokeTextStory();

  static const _words = ['Найди', 'мне', 'рейс', 'в', 'Токио', 'на', 'пятницу'];
  // Dark voice-field colour — always fixed, never theme-driven.
  static const Color _voiceBg = Color(0xFF08080A);

  @override
  Widget build(BuildContext context) {
    return StoryPage(
      title: 'KaiKaraokeText',
      layer: 'ATOM',
      blurb: 'Voice-mode word-reveal. Spoken words are full white; the "now" word '
          'has a tide-3 amber highlight (Color(0x47F4B589)); "next" words are dim '
          'white (Color(0x52FFFFFF)). Dark-surface only — fixed literals, no '
          'theme tokens.',
      sections: [
        StorySection('Word states', [
          StoryCell(
            'currentIndex=2',
            Container(
              color: _voiceBg,
              padding: const EdgeInsets.all(12),
              child: const KaiKaraokeText(
                words: _words,
                currentIndex: 2,
              ),
            ),
          ),
          StoryCell(
            'currentIndex=0 (first)',
            Container(
              color: _voiceBg,
              padding: const EdgeInsets.all(12),
              child: const KaiKaraokeText(
                words: _words,
                currentIndex: 0,
              ),
            ),
          ),
          StoryCell(
            'all spoken (index=7)',
            Container(
              color: _voiceBg,
              padding: const EdgeInsets.all(12),
              child: KaiKaraokeText(
                words: _words,
                currentIndex: _words.length,
              ),
            ),
          ),
        ]),
      ],
      usage: 'KaiKaraokeText(\n'
          '  words: transcript.words,\n'
          '  currentIndex: currentWordIndex,\n'
          ')',
      props: const [
        PropDoc('words', 'List<String>', 'required', 'All words in the sentence'),
        PropDoc(
            'currentIndex', 'int', 'required', 'Index of word now being spoken'),
      ],
    );
  }
}

// ── KaiBudgetBar story ────────────────────────────────────────────────────────
// Canon: new-design/trip-detail.html .budget-bar

class _KaiBudgetBarStory extends StatelessWidget {
  const _KaiBudgetBarStory();

  // Four canon budget categories from trip-detail.html
  static const _segments = [
    KaiBudgetSegment(
      fraction: 0.40,
      color: Color(0xFF2BA8C9), // tide-2 — flights
      label: 'Авиа',
    ),
    KaiBudgetSegment(
      fraction: 0.30,
      color: Color(0xFFF4B589), // tide-3 warm — stays
      label: 'Отели',
    ),
    KaiBudgetSegment(
      fraction: 0.20,
      color: Color(0xFF5B9BD5), // mid-blue — food
      label: 'Еда',
    ),
    KaiBudgetSegment(
      fraction: 0.10,
      color: Color(0xFFB5CBE3), // light-blue — local
      label: 'Транспорт',
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return const StoryPage(
      title: 'KaiBudgetBar',
      layer: 'ATOM',
      blurb: 'Segmented budget bar from trip-detail.html. Pill track (surface3 bg, '
          'KaiRadius.brPill, 8px default height) containing proportional coloured '
          'segments using Expanded(flex). Optional legend row with swatch + label. '
          'Segment fractions sum to ≤ 1.0 — remainder shows the surface3 track.',
      sections: [
        StorySection('With legend (4 segments)', [
          StoryCell(
            'flights / stays / food / local',
            SizedBox(
              width: 280,
              child: KaiBudgetBar(
                segments: _segments,
                showLegend: true,
              ),
            ),
          ),
        ]),
        StorySection('Without legend', [
          StoryCell(
            '4 segments no legend',
            SizedBox(
              width: 280,
              child: KaiBudgetBar(segments: _segments),
            ),
          ),
        ]),
        StorySection('Partial fill (remainder visible)', [
          StoryCell(
            '2 segments (0.3 + 0.2 = 50%)',
            SizedBox(
              width: 280,
              child: KaiBudgetBar(
                segments: [
                  KaiBudgetSegment(
                    fraction: 0.30,
                    color: Color(0xFF2BA8C9),
                    label: 'Авиа',
                  ),
                  KaiBudgetSegment(
                    fraction: 0.20,
                    color: Color(0xFFF4B589),
                    label: 'Отели',
                  ),
                ],
                showLegend: true,
              ),
            ),
          ),
          StoryCell(
            'tall (height: 16)',
            SizedBox(
              width: 280,
              child: KaiBudgetBar(
                segments: _segments,
                height: 16,
              ),
            ),
          ),
        ]),
      ],
      usage: 'KaiBudgetBar(\n'
          '  segments: [\n'
          '    KaiBudgetSegment(fraction: 0.40, color: Color(0xFF2BA8C9), label: "Авиа"),\n'
          '    KaiBudgetSegment(fraction: 0.30, color: Color(0xFFF4B589), label: "Отели"),\n'
          '  ],\n'
          '  showLegend: true,\n'
          ')',
      props: [
        PropDoc('segments', 'List<KaiBudgetSegment>', 'required',
            'Proportional coloured segments — fractions should sum ≤ 1.0'),
        PropDoc('height', 'double', '8', 'Track height in logical pixels'),
        PropDoc('showLegend', 'bool', 'false',
            'When true renders a legend row with swatch + label below the track'),
      ],
    );
  }
}
