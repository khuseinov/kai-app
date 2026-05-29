import 'package:flutter/material.dart';

import '../../../../design_system/atoms/atoms.dart';
import '../../../../design_system/molecules/molecules.dart';
import '../../../../design_system/primitives/primitives.dart';
import '../../../../design_system/theme/kai_theme.dart';
import '../story_page.dart';
import '../story_registry.dart';

final List<Story> moleculeStories = [
  Story(
    layer: StoryLayer.molecules,
    name: 'KaiUserBubble',
    importPath: 'package:kai_app/design_system/molecules/molecules.dart',
    canonFile: 'new-design/components.html',
    canonSelector: '.bub.user',
    description:
        'Right-aligned pill bubble for user messages. Surface-2 background, '
        '13.5px Manrope, asymmetric 18/4 radii.',
    variants: ['KaiUserBubble(text: ...)'],
    build: (_) => const StoryPage(
      title: 'KaiUserBubble',
      layer: 'MOLECULE',
      blurb:
          'Right-aligned message bubble for user text. Surface-2 background, '
          '13.5 px Manrope w500, asymmetric corner radii (18/4 px).',
      sections: [
        StorySection('Variants', [
          StoryCell(
            'short',
            KaiUserBubble(text: 'Привет, Kai!'),
          ),
          StoryCell(
            'long',
            SizedBox(
              width: 240,
              child: KaiUserBubble(
                text: 'Расскажи мне о визовых требованиях для поездки в Японию.',
              ),
            ),
          ),
        ]),
      ],
      usage: "KaiUserBubble(text: 'Привет, Kai!')",
      props: [
        PropDoc('text', 'String', 'required', 'Message content'),
      ],
    ),
  ),

  Story(
    layer: StoryLayer.molecules,
    name: 'KaiKaiBubble',
    importPath: 'package:kai_app/design_system/molecules/molecules.dart',
    canonFile: 'new-design/components.html',
    canonSelector: '.bub.kai',
    description:
        'Left-aligned Kai response bubble with inline citation parsing, '
        'streaming caret, source list, and thumb-up/down reactions.',
    variants: ['normal', 'streaming: true', 'with sources', 'with reactions'],
    build: (_) => const _KaiKaiBubbleStory(),
  ),

  Story(
    layer: StoryLayer.molecules,
    name: 'KaiSystemBubble',
    importPath: 'package:kai_app/design_system/molecules/molecules.dart',
    canonFile: 'new-design/components.html',
    canonSelector: '.bub.system',
    description:
        'Full-width system note injected into the chat feed for memory '
        'updates, warnings, or errors. Three semantic tones.',
    variants: ['neutral', 'warning', 'negative'],
    build: (_) => const StoryPage(
      title: 'KaiSystemBubble',
      layer: 'MOLECULE',
      blurb:
          'Full-width system message injected into the chat feed. Three tones: '
          'neutral (info), warning, negative (error).',
      sections: [
        StorySection('Tones', [
          StoryCell(
            'neutral',
            SizedBox(
              width: 300,
              child: KaiSystemBubble(
                'Kai обновил воспоминание о ваших планах на поездку.',
                tone: KaiSystemTone.neutral,
              ),
            ),
          ),
          StoryCell(
            'warning',
            SizedBox(
              width: 300,
              child: KaiSystemBubble(
                'Внимание — сайт не обновлялся 6 месяцев.',
                bold: 'Внимание —',
                tone: KaiSystemTone.warning,
              ),
            ),
          ),
          StoryCell(
            'negative',
            SizedBox(
              width: 300,
              child: KaiSystemBubble(
                'Ошибка сети при загрузке источника.',
                tone: KaiSystemTone.negative,
              ),
            ),
          ),
        ]),
      ],
      usage: "KaiSystemBubble('Kai обновил воспоминание.', "
          'tone: KaiSystemTone.neutral)',
      props: [
        PropDoc('text', 'String', 'required', 'System message content'),
        PropDoc('tone', 'KaiSystemTone', 'neutral', 'neutral / warning / negative'),
        PropDoc('bold', 'String?', 'null', 'Substring to render bold'),
      ],
    ),
  ),

  Story(
    layer: StoryLayer.molecules,
    name: 'KaiComposeIsland',
    importPath: 'package:kai_app/design_system/molecules/molecules.dart',
    canonFile: 'new-design/components.html',
    canonSelector: '.sheet.compose-sheet .compose',
    description:
        'Pill-shaped chat input bar with growing textarea, optional mic '
        'button, and send button lifecycle states.',
    variants: [
      'KaiComposeIsland(controller, onSend)',
      'onMicTap: ...',
      'sendState: KaiSendState.*',
    ],
    build: (_) => const _KaiComposeIslandStory(),
  ),

  Story(
    layer: StoryLayer.molecules,
    name: 'KaiSourceCard',
    importPath: 'package:kai_app/design_system/molecules/molecules.dart',
    canonFile: 'new-design/components.html',
    canonSelector: '.src-list .src-row',
    description:
        'Source-citation card shown under Kai messages — displays URL, title, '
        'snippet, index chip, and freshness badge.',
    variants: ['fresh: true', 'fresh: false', 'with snippet', 'without snippet'],
    build: (_) => const StoryPage(
      title: 'KaiSourceCard',
      layer: 'MOLECULE',
      blurb:
          'Citation card displayed under Kai messages. Shows index chip, '
          'URL, optional title/snippet, and freshness badge.',
      sections: [
        StorySection('Variants', [
          StoryCell(
            'with snippet · fresh',
            SizedBox(
              width: 280,
              child: KaiSourceCard(
                url: 'booking.com',
                title: 'Hotels in Tokyo — Booking.com',
                snippet: 'Find the best deals on hotels in Tokyo, Japan.',
                index: 1,
                fresh: true,
              ),
            ),
          ),
          StoryCell(
            'no snippet · stale',
            SizedBox(
              width: 280,
              child: KaiSourceCard(
                url: 'tripadvisor.com',
                title: 'Things to Do in Tokyo',
                index: 2,
              ),
            ),
          ),
        ]),
      ],
      usage: 'KaiSourceCard(\n'
          '  url: "mofa.go.jp",\n'
          '  title: "Visa Requirements",\n'
          '  index: 1, fresh: true,\n'
          ')',
      props: [
        PropDoc('url', 'String', 'required', 'Source URL / domain'),
        PropDoc('index', 'int', 'required', 'Citation number chip'),
        PropDoc('title', 'String?', 'null', 'Optional card title'),
        PropDoc('snippet', 'String?', 'null', 'Optional preview text'),
        PropDoc('fresh', 'bool', 'false', 'Show freshness badge'),
      ],
    ),
  ),

  Story(
    layer: StoryLayer.molecules,
    name: 'KaiCareBlock',
    importPath: 'package:kai_app/design_system/molecules/molecules.dart',
    canonFile: 'new-design/edge-states.html',
    canonSelector: '.care-block',
    description:
        'Crisis care block (C3 in-conversation pattern) — coral left-border '
        'block with heading, body, hotline resources, and closing. Never a takeover.',
    variants: ['KaiCareBlock(heading, body, resources, closing)'],
    build: (_) => const StoryPage(
      title: 'KaiCareBlock',
      layer: 'MOLECULE',
      blurb:
          'C3 crisis care block — inline in the chat feed, never a full-screen '
          'takeover. Coral left border, heading, body copy, resources, closing.',
      sections: [
        StorySection('Default', [
          StoryCell(
            'full block',
            SizedBox(
              width: 300,
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
            ),
          ),
        ]),
      ],
      usage: 'KaiCareBlock(\n'
          '  heading: "Я здесь для тебя.",\n'
          '  body: "...",\n'
          '  resources: [KaiCareResource(...)],\n'
          '  closing: "Просто дыши.",\n'
          ')',
      props: [
        PropDoc('heading', 'String', 'required', 'Bold heading text'),
        PropDoc('body', 'String', 'required', 'Supporting copy'),
        PropDoc('resources', 'List<KaiCareResource>', 'required', 'Hotline rows'),
        PropDoc('closing', 'String', 'required', 'Closing reassurance sentence'),
      ],
    ),
  ),

  Story(
    layer: StoryLayer.molecules,
    name: 'KaiAlertCard',
    importPath: 'package:kai_app/design_system/molecules/molecules.dart',
    canonFile: 'new-design/notifications-chat.html',
    canonSelector: '.alert-card',
    description:
        'Proactive alert card injected into the chat feed — two-zone layout '
        '(coloured header + body), four severity types.',
    variants: ['urgent', 'warning', 'positive', 'neutral'],
    build: (_) => _KaiAlertCardStory(),
  ),

  Story(
    layer: StoryLayer.molecules,
    name: 'KaiToast',
    importPath: 'package:kai_app/design_system/molecules/molecules.dart',
    canonFile: 'new-design/components.html',
    canonSelector: '.toast',
    description:
        'Pill toast notification — dark island style, four types. Memory '
        'variant uses tide gradient fill.',
    variants: ['neutral', 'positive', 'negative', 'memory'],
    build: (_) => _KaiToastStory(),
  ),

  Story(
    layer: StoryLayer.molecules,
    name: 'KaiActionSheet',
    importPath: 'package:kai_app/design_system/molecules/molecules.dart',
    canonFile: 'new-design/components.html',
    canonSelector: '.sheet.actions',
    description:
        'Quick-action bottom sheet presented via showKaiActionSheet(). '
        'List of KaiActionItem rows with icon, title, optional meta, danger flag.',
    variants: [
      'KaiActionSheet(items: [KaiActionItem(...)])',
      'danger: true row',
    ],
    build: (_) => const _KaiActionSheetStory(),
  ),

  Story(
    layer: StoryLayer.molecules,
    name: 'KaiSegmentedControl',
    importPath: 'package:kai_app/design_system/molecules/molecules.dart',
    canonFile: 'new-design/settings.html',
    canonSelector: '.seg',
    description:
        'Segmented pill control for mutually-exclusive option sets (e.g. '
        'theme: auto / light / dark). Index-based selection.',
    variants: ['KaiSegmentedControl(options, selectedIndex, onSelected)'],
    build: (_) => const _KaiSegmentedControlStory(),
  ),

  Story(
    layer: StoryLayer.molecules,
    name: 'KaiSettingsRow',
    importPath: 'package:kai_app/design_system/molecules/molecules.dart',
    canonFile: 'new-design/settings.html',
    canonSelector: '.row',
    description:
        'Settings list row with leading icon, title, optional subtitle, '
        'and a trailing widget slot. Danger variant turns text coral.',
    variants: [
      'normal', 'danger: true',
      'trailing: KaiToggle', 'trailing: KaiIcon(chevRight)',
    ],
    build: (_) => const _KaiSettingsRowStory(),
  ),

  Story(
    layer: StoryLayer.molecules,
    name: 'KaiSettingsGroup',
    importPath: 'package:kai_app/design_system/molecules/molecules.dart',
    canonFile: 'new-design/settings.html',
    canonSelector: '.settings-group',
    description:
        'Settings section container — groups multiple KaiSettingsRows under '
        'an optional label. Danger variant shows no label, just coral rows.',
    variants: ['normal with label', 'danger (no label)'],
    build: (_) => const _KaiSettingsGroupStory(),
  ),

  Story(
    layer: StoryLayer.molecules,
    name: 'KaiAccountHero',
    importPath: 'package:kai_app/design_system/molecules/molecules.dart',
    canonFile: 'new-design/settings.html',
    canonSelector: '.acc-hero',
    description:
        'Account card for the top of the settings screen — shows tide '
        'avatar, name, email, and optional plan badge.',
    variants: [
      'KaiAccountHero(name, email, initial)',
      'planLabel: "Pro"',
    ],
    build: (_) => const StoryPage(
      title: 'KaiAccountHero',
      layer: 'MOLECULE',
      blurb:
          'Account hero at the top of the settings screen — tide avatar circle, '
          'name + email stack, optional plan badge pill.',
      sections: [
        StorySection('Variants', [
          StoryCell(
            'with plan badge',
            SizedBox(
              width: 280,
              child: KaiAccountHero(
                name: 'Rustam K.',
                email: 'rustam.wize@gmail.com',
                initial: 'R',
                planLabel: 'Pro',
              ),
            ),
          ),
          StoryCell(
            'no badge',
            SizedBox(
              width: 280,
              child: KaiAccountHero(
                name: 'Rustam K.',
                email: 'rustam.wize@gmail.com',
                initial: 'R',
              ),
            ),
          ),
        ]),
      ],
      usage: 'KaiAccountHero(\n'
          '  name: "Rustam K.",\n'
          '  email: "user@example.com",\n'
          '  initial: "R",\n'
          '  planLabel: "Pro",\n'
          ')',
      props: [
        PropDoc('name', 'String', 'required', 'Display name'),
        PropDoc('email', 'String', 'required', 'Email address'),
        PropDoc('initial', 'String', 'required', 'Avatar letter'),
        PropDoc('planLabel', 'String?', 'null', 'Optional plan badge text'),
      ],
    ),
  ),

  Story(
    layer: StoryLayer.molecules,
    name: 'KaiNavItem',
    importPath: 'package:kai_app/design_system/molecules/molecules.dart',
    canonFile: 'new-design/nav.html',
    canonSelector: '.chat-row',
    description:
        'Side-panel nav row with leading icon, label, and trailing widget. '
        'Active state shows accent-wash background and left accent border.',
    variants: ['inactive', 'active: true', 'trailing: KaiBadge.dot()'],
    build: (_) => _KaiNavItemStory(),
  ),
];

// ── Stateful / interactive story widgets ──────────────────────────────────────

class _KaiKaiBubbleStory extends StatelessWidget {
  const _KaiKaiBubbleStory();

  @override
  Widget build(BuildContext context) {
    return StoryPage(
      title: 'KaiKaiBubble',
      layer: 'MOLECULE',
      blurb:
          'Left-aligned Kai response bubble. Supports inline citation markers '
          '[n], streaming caret, expandable source list, and thumb reactions.',
      sections: [
        StorySection('States', [
          StoryCell(
            'with sources + reactions',
            SizedBox(
              width: 280,
              child: KaiKaiBubble(
                text:
                    'Для туристической визы в Японию [1] нужны: загранпаспорт, '
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
            ),
          ),
          const StoryCell(
            'streaming',
            SizedBox(
              width: 280,
              child: KaiKaiBubble(
                text: 'Ищу информацию',
                streaming: true,
              ),
            ),
          ),
          const StoryCell(
            'plain',
            SizedBox(
              width: 280,
              child: KaiKaiBubble(
                text: 'Прямые рейсы Москва→Токио от 45 000 ₽.',
              ),
            ),
          ),
        ]),
      ],
      usage: 'KaiKaiBubble(\n'
          '  text: "Ответ [1]",\n'
          '  sources: [...],\n'
          '  onThumbUp: () {},\n'
          '  onThumbDown: () {},\n'
          ')',
      props: const [
        PropDoc('text', 'String', 'required', 'Kai response text (citation markers [n] parsed)'),
        PropDoc('streaming', 'bool', 'false', 'Show blinking caret'),
        PropDoc('sources', 'List<Widget>?', 'null', 'Source cards below bubble'),
        PropDoc('sourcesLabel', 'String?', 'null', 'Sources row label text'),
        PropDoc('onThumbUp', 'VoidCallback?', 'null', 'Thumb-up handler'),
        PropDoc('onThumbDown', 'VoidCallback?', 'null', 'Thumb-down handler'),
      ],
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
    return StoryPage(
      title: 'KaiComposeIsland',
      layer: 'MOLECULE',
      blurb:
          'Pill-shaped chat input bar — growing textarea, optional mic button, '
          'and KaiSendButton lifecycle (idle/busy/done).',
      sections: [
        StorySection('Interactive demo', [
          StoryCell(
            'with mic',
            SizedBox(
              width: 320,
              child: KaiComposeIsland(
                controller: _ctrl,
                onSend: () {},
                onMicTap: () {},
              ),
            ),
          ),
          StoryCell(
            'no mic',
            SizedBox(
              width: 320,
              child: KaiComposeIsland(
                controller: TextEditingController(),
                onSend: () {},
              ),
            ),
          ),
        ]),
      ],
      usage: 'KaiComposeIsland(\n'
          '  controller: _ctrl,\n'
          '  onSend: _handleSend,\n'
          '  onMicTap: _handleMic,\n'
          ')',
      props: const [
        PropDoc('controller', 'TextEditingController', 'required', 'Input controller'),
        PropDoc('onSend', 'VoidCallback', 'required', 'Called when send tapped'),
        PropDoc('onMicTap', 'VoidCallback?', 'null', 'Shows mic button when set'),
        PropDoc('sendState', 'KaiSendState', 'idle', 'idle / sending / done'),
      ],
    );
  }
}

class _KaiAlertCardStory extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return StoryPage(
      title: 'KaiAlertCard',
      layer: 'MOLECULE',
      blurb:
          'Proactive alert card injected into the chat feed. Two-zone layout '
          '(coloured header + white body). Four severity types.',
      sections: [
        StorySection('Types', [
          StoryCell(
            'urgent',
            SizedBox(
              width: 280,
              child: KaiAlertCard(
                type: KaiAlertType.urgent,
                title: 'Требуется немедленное внимание',
                body: 'Виза истекает через 3 дня.',
                time: '9:41',
                cta: 'Продлить визу',
                onCtaTap: () {},
              ),
            ),
          ),
          StoryCell(
            'warning',
            SizedBox(
              width: 280,
              child: KaiAlertCard(
                type: KaiAlertType.warning,
                title: 'Предупреждение о погоде',
                body: 'Ожидается дождь в районе маршрута.',
                time: '10:15',
                cta: 'Посмотреть прогноз',
                onCtaTap: () {},
              ),
            ),
          ),
          StoryCell(
            'positive',
            SizedBox(
              width: 280,
              child: KaiAlertCard(
                type: KaiAlertType.positive,
                title: 'Бронирование подтверждено',
                body: 'Ваш отель в Токио забронирован на 3 ночи.',
                time: '11:00',
                cta: 'Посмотреть детали',
                onCtaTap: () {},
              ),
            ),
          ),
          const StoryCell(
            'neutral (no CTA)',
            SizedBox(
              width: 280,
              child: KaiAlertCard(
                type: KaiAlertType.neutral,
                title: 'Напоминание о поездке',
                body: 'Через 5 дней вылет в Токио.',
                time: '12:30',
              ),
            ),
          ),
        ]),
      ],
      usage: 'KaiAlertCard(\n'
          '  type: KaiAlertType.urgent,\n'
          '  title: "...",\n'
          '  body: "...",\n'
          '  time: "9:41",\n'
          '  cta: "Action",\n'
          '  onCtaTap: () {},\n'
          ')',
      props: const [
        PropDoc('type', 'KaiAlertType', 'required', 'urgent / warning / positive / neutral'),
        PropDoc('title', 'String', 'required', 'Alert heading'),
        PropDoc('body', 'String', 'required', 'Alert body text'),
        PropDoc('time', 'String?', 'null', 'Timestamp shown in header'),
        PropDoc('cta', 'String?', 'null', 'Call-to-action button label'),
        PropDoc('onCtaTap', 'VoidCallback?', 'null', 'CTA tap handler'),
      ],
    );
  }
}

class _KaiToastStory extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return StoryPage(
      title: 'KaiToast',
      layer: 'MOLECULE',
      blurb:
          'Dark-island pill toast. Four types — neutral/positive/negative share '
          'ink-1 bg; memory uses tide gradient. Presented by KaiToastController.',
      sections: [
        StorySection('Types', [
          const StoryCell(
            'neutral',
            Align(
              alignment: Alignment.centerLeft,
              child: KaiToast(
                type: KaiToastType.neutral,
                label: 'Скопировано в буфер',
              ),
            ),
          ),
          const StoryCell(
            'positive + countdown',
            Align(
              alignment: Alignment.centerLeft,
              child: KaiToast(
                type: KaiToastType.positive,
                label: 'Воспоминание сохранено',
                showCountdown: true,
              ),
            ),
          ),
          StoryCell(
            'negative + action',
            Align(
              alignment: Alignment.centerLeft,
              child: KaiToast(
                type: KaiToastType.negative,
                label: 'Не удалось отправить',
                actionLabel: 'Повторить',
                onAction: () {},
              ),
            ),
          ),
          StoryCell(
            'memory + action',
            Align(
              alignment: Alignment.centerLeft,
              child: KaiToast(
                type: KaiToastType.memory,
                label: 'Kai запомнил это',
                actionLabel: 'Открыть',
                onAction: () {},
              ),
            ),
          ),
        ]),
      ],
      usage: 'KaiToast(\n'
          '  type: KaiToastType.memory,\n'
          '  label: "Kai запомнил это",\n'
          '  actionLabel: "Открыть",\n'
          '  onAction: () {},\n'
          ')',
      props: const [
        PropDoc('type', 'KaiToastType', 'required', 'neutral / positive / negative / memory'),
        PropDoc('label', 'String', 'required', 'Toast message text'),
        PropDoc('actionLabel', 'String?', 'null', 'Optional action button label'),
        PropDoc('onAction', 'VoidCallback?', 'null', 'Action tap handler'),
        PropDoc('showCountdown', 'bool', 'false', 'Show static countdown bar'),
      ],
    );
  }
}

class _KaiActionSheetStory extends StatelessWidget {
  const _KaiActionSheetStory();

  @override
  Widget build(BuildContext context) {
    return StoryPage(
      title: 'KaiActionSheet',
      layer: 'MOLECULE',
      blurb:
          'Bottom-sheet action menu presented via showKaiActionSheet(). '
          'KaiActionItem rows: icon + title + optional meta; danger flag turns coral.',
      sections: [
        StorySection('Triggers', [
          StoryCell(
            'action sheet',
            KaiButton.ghost(
              label: 'Open action sheet',
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
          ),
          StoryCell(
            'detail sheet',
            KaiButton.ghost(
              label: 'Open detail sheet',
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
          ),
        ]),
      ],
      usage: 'showKaiActionSheet(\n'
          '  context,\n'
          '  items: [\n'
          '    KaiActionItem(icon: KaiIconName.copy, title: "Copy", onTap: () {}),\n'
          '  ],\n'
          ')',
      props: const [
        PropDoc('items', 'List<KaiActionItem>', 'required', 'Action rows'),
        PropDoc('icon', 'KaiIconName', 'required', 'Row leading icon'),
        PropDoc('title', 'String', 'required', 'Row label'),
        PropDoc('meta', 'String?', 'null', 'Trailing meta text (e.g. shortcut)'),
        PropDoc('danger', 'bool', 'false', 'Coral text + icon tint'),
      ],
    );
  }
}

class _KaiSegmentedControlStory extends StatefulWidget {
  const _KaiSegmentedControlStory();

  @override
  State<_KaiSegmentedControlStory> createState() =>
      _KaiSegmentedControlStoryState();
}

class _KaiSegmentedControlStoryState extends State<_KaiSegmentedControlStory> {
  int _index = 0;

  @override
  Widget build(BuildContext context) {
    return StoryPage(
      title: 'KaiSegmentedControl',
      layer: 'MOLECULE',
      blurb:
          'Pill segmented control for mutually-exclusive options. '
          'Index-based selection; selected pill animates to surface-2 with shadow.',
      sections: [
        StorySection('Interactive', [
          StoryCell(
            '3 options',
            SizedBox(
              width: 240,
              child: KaiSegmentedControl(
                options: const ['Авто', 'Светлая', 'Тёмная'],
                selectedIndex: _index,
                onSelected: (i) => setState(() => _index = i),
              ),
            ),
          ),
        ]),
      ],
      usage: 'KaiSegmentedControl(\n'
          '  options: ["Авто", "Светлая", "Тёмная"],\n'
          '  selectedIndex: _index,\n'
          '  onSelected: (i) => setState(() => _index = i),\n'
          ')',
      props: const [
        PropDoc('options', 'List<String>', 'required', 'Tab labels'),
        PropDoc('selectedIndex', 'int', 'required', 'Active tab index'),
        PropDoc('onSelected', 'ValueChanged<int>', 'required', 'Selection callback'),
      ],
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
    return StoryPage(
      title: 'KaiSettingsRow',
      layer: 'MOLECULE',
      blurb:
          'Settings list row — leading icon, title, optional subtitle, trailing '
          'widget slot. Danger variant renders title + icon in coral (#C44A3C).',
      sections: [
        StorySection('Variants', [
          StoryCell(
            'toggle trailing',
            SizedBox(
              width: 280,
              child: KaiSettingsRow(
                icon: KaiIconName.palette,
                title: 'Тема',
                subtitle: 'системная',
                trailing: KaiToggle(
                  value: _toggle,
                  onChanged: (v) => setState(() => _toggle = v),
                ),
                onTap: () {},
              ),
            ),
          ),
          StoryCell(
            'chevron trailing',
            SizedBox(
              width: 280,
              child: KaiSettingsRow(
                icon: KaiIconName.motion,
                title: 'Уменьшить анимацию',
                subtitle: 'прилив становится статичным',
                trailing: KaiIcon(KaiIconName.chevRight, size: 14, color: c.ink3),
                onTap: () {},
              ),
            ),
          ),
          StoryCell(
            'danger',
            SizedBox(
              width: 280,
              child: KaiSettingsRow(
                icon: KaiIconName.trash,
                title: 'Удалить мои данные',
                danger: true,
                onTap: () {},
              ),
            ),
          ),
        ]),
      ],
      usage: 'KaiSettingsRow(\n'
          '  icon: KaiIconName.palette,\n'
          '  title: "Тема",\n'
          '  trailing: KaiToggle(...),\n'
          '  onTap: () {},\n'
          ')',
      props: const [
        PropDoc('icon', 'KaiIconName', 'required', 'Leading icon'),
        PropDoc('title', 'String', 'required', 'Row label'),
        PropDoc('subtitle', 'String?', 'null', 'Optional subtitle text'),
        PropDoc('trailing', 'Widget?', 'null', 'Trailing widget (toggle, chevron, etc.)'),
        PropDoc('danger', 'bool', 'false', 'Coral text + icon'),
        PropDoc('onTap', 'VoidCallback?', 'null', 'Row tap handler'),
      ],
    );
  }
}

class _KaiSettingsGroupStory extends StatefulWidget {
  const _KaiSettingsGroupStory();

  @override
  State<_KaiSettingsGroupStory> createState() => _KaiSettingsGroupStoryState();
}

class _KaiSettingsGroupStoryState extends State<_KaiSettingsGroupStory> {
  bool _toggle = false;

  @override
  Widget build(BuildContext context) {
    final c = KaiTheme.of(context).colors;
    return StoryPage(
      title: 'KaiSettingsGroup',
      layer: 'MOLECULE',
      blurb:
          'Settings section container — groups KaiSettingsRows under an optional '
          'label. Danger variant: no label, row text goes coral.',
      sections: [
        StorySection('Variants', [
          StoryCell(
            'normal with label',
            SizedBox(
              width: 280,
              child: KaiSettingsGroup(
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
                    trailing: KaiIcon(KaiIconName.chevRight, size: 14, color: c.ink3),
                    onTap: () {},
                  ),
                ],
              ),
            ),
          ),
          StoryCell(
            'danger group',
            SizedBox(
              width: 280,
              child: KaiSettingsGroup(
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
            ),
          ),
        ]),
      ],
      usage: 'KaiSettingsGroup(\n'
          '  label: "внешний вид",\n'
          '  children: [KaiSettingsRow(...)],\n'
          ')',
      props: const [
        PropDoc('label', 'String?', 'null', 'Section header label (uppercased)'),
        PropDoc('children', 'List<Widget>', 'required', 'KaiSettingsRow children'),
        PropDoc('danger', 'bool', 'false', 'Suppress label; coral styling'),
      ],
    );
  }
}

class _KaiNavItemStory extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return StoryPage(
      title: 'KaiNavItem',
      layer: 'MOLECULE',
      blurb:
          'Side-panel nav row — leading icon, label, optional trailing widget. '
          'Active state: accent-wash bg + left accent border.',
      sections: [
        StorySection('States', [
          StoryCell(
            'inactive',
            SizedBox(
              width: 240,
              child: KaiNavItem(
                label: 'Поездка в Токио',
                icon: KaiIconName.folder,
                onTap: () {},
              ),
            ),
          ),
          StoryCell(
            'active',
            SizedBox(
              width: 240,
              child: KaiNavItem(
                label: 'Текущий чат',
                icon: KaiIconName.memory,
                active: true,
                onTap: () {},
              ),
            ),
          ),
          const StoryCell(
            'with badge',
            SizedBox(
              width: 240,
              child: KaiNavItem(
                label: 'Память',
                icon: KaiIconName.memory,
                trailing: KaiBadge.dot(),
              ),
            ),
          ),
        ]),
      ],
      usage: 'KaiNavItem(\n'
          '  label: "Поездка",\n'
          '  icon: KaiIconName.folder,\n'
          '  active: true,\n'
          '  onTap: () {},\n'
          ')',
      props: const [
        PropDoc('label', 'String', 'required', 'Nav row label'),
        PropDoc('icon', 'KaiIconName', 'required', 'Leading icon'),
        PropDoc('active', 'bool', 'false', 'Highlighted active state'),
        PropDoc('trailing', 'Widget?', 'null', 'Trailing widget (badge, etc.)'),
        PropDoc('onTap', 'VoidCallback?', 'null', 'Row tap handler'),
      ],
    );
  }
}
