import 'package:flutter/material.dart';

import '../../../../design_system/atoms/atoms.dart';
import '../../../../design_system/molecules/molecules.dart';
import '../../../../design_system/primitives/primitives.dart';
import '../../../../design_system/theme/kai_theme.dart';
import '../../../../design_system/tokens/kai_tokens.dart';
import '../story_registry.dart';
import '_story_helpers.dart';

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
    build: (_) => const _KaiUserBubbleStory(),
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
    build: (_) => const _KaiSystemBubbleStory(),
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
    build: (_) => const _KaiSourceCardStory(),
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
    variants: [
      'KaiCareBlock(heading, body, resources, closing)',
    ],
    build: (_) => const _KaiCareBlockStory(),
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
    build: (_) => const _KaiAlertCardStory(),
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
    build: (_) => const _KaiToastStory(),
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
    variants: [
      'KaiSegmentedControl(options, selectedIndex, onSelected)',
    ],
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
    build: (_) => const _KaiAccountHeroStory(),
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
    build: (_) => const _KaiNavItemStory(),
  ),
];

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
