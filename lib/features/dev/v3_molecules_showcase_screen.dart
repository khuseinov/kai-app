import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/providers/root.dart';
import '../../design_system/theme/kai_theme.dart';
import '../../design_system/tokens/kai_tokens.dart';
import '../../design_system/atoms/atoms.dart';
import '../../design_system/molecules/molecules.dart';
import '../../design_system/primitives/primitives.dart';

/// Visual gallery of every v3 molecule.
///
/// Not a production surface — layout literals in the scaffold are acceptable.
class V3MoleculesShowcaseScreen extends ConsumerStatefulWidget {
  const V3MoleculesShowcaseScreen({super.key});

  @override
  ConsumerState<V3MoleculesShowcaseScreen> createState() =>
      _V3MoleculesShowcaseScreenState();
}

class _V3MoleculesShowcaseScreenState
    extends ConsumerState<V3MoleculesShowcaseScreen> {
  final _composeCtrl = TextEditingController();
  int _segIndex = 0;
  bool _toggle = true;

  @override
  void dispose() {
    _composeCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final c = KaiTheme.of(context).colors;
    final themeMode = ref.watch(themeModeProvider);

    return Scaffold(
      backgroundColor: c.bg,
      appBar: AppBar(
        backgroundColor: c.bg,
        foregroundColor: c.ink1,
        title: const Text('v3 — Molecules'),
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
          // ── Bubbles ──────────────────────────────────────────────────────────
          const _Section(
            title: 'KaiUserBubble',
            child: KaiUserBubble(
              text: 'Привет, Kai! Расскажи мне о визе в Японию.',
            ),
          ),
          const SizedBox(height: KaiSpace.s7),

          _Section(
            title: 'KaiKaiBubble (with citation [1] + source)',
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
          const SizedBox(height: KaiSpace.s7),

          const _Section(
            title: 'KaiKaiBubble (streaming)',
            child: KaiKaiBubble(
              text: 'Ищу информацию',
              streaming: true,
            ),
          ),
          const SizedBox(height: KaiSpace.s7),

          const _Section(
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
          ),
          const SizedBox(height: KaiSpace.s7),

          // ── KaiComposeIsland ──────────────────────────────────────────────────
          _Section(
            title: 'KaiComposeIsland',
            child: KaiComposeIsland(
              controller: _composeCtrl,
              onSend: () {},
              onMicTap: () {},
            ),
          ),
          const SizedBox(height: KaiSpace.s7),

          // ── KaiSourceCard ─────────────────────────────────────────────────────
          const _Section(
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
          ),
          const SizedBox(height: KaiSpace.s7),

          // ── KaiCareBlock ──────────────────────────────────────────────────────
          const _Section(
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
          ),
          const SizedBox(height: KaiSpace.s7),

          // ── KaiAlertCard ──────────────────────────────────────────────────────
          _Section(
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
          ),
          const SizedBox(height: KaiSpace.s7),

          // ── KaiToast ──────────────────────────────────────────────────────────
          _Section(
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
          ),
          const SizedBox(height: KaiSpace.s7),

          // ── Sheets (modal triggers) ───────────────────────────────────────────
          _Section(
            title: 'KaiActionSheet + KaiMessageDetailSheet (modal)',
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
          ),
          const SizedBox(height: KaiSpace.s7),

          // ── KaiSegmentedControl ───────────────────────────────────────────────
          _Section(
            title: 'KaiSegmentedControl',
            child: KaiSegmentedControl(
              options: const ['Авто', 'Светлая', 'Тёмная'],
              selectedIndex: _segIndex,
              onSelected: (i) => setState(() => _segIndex = i),
            ),
          ),
          const SizedBox(height: KaiSpace.s7),

          // ── KaiSettingsRow + KaiSettingsGroup ─────────────────────────────────
          _Section(
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
                      trailing: KaiIcon(KaiIconName.chevRight,
                          size: 14, color: c.ink3),
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
          ),
          const SizedBox(height: KaiSpace.s7),

          // ── KaiAccountHero ────────────────────────────────────────────────────
          const _Section(
            title: 'KaiAccountHero',
            child: KaiAccountHero(
              name: 'Rustam K.',
              email: 'rustam.wize@gmail.com',
              initial: 'R',
              planLabel: 'Pro',
            ),
          ),
          const SizedBox(height: KaiSpace.s7),

          // ── KaiNavItem ────────────────────────────────────────────────────────
          _Section(
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
