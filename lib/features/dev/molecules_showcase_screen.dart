import 'package:flutter/material.dart';

import '../../design_system/atoms/kai_button.dart';
import '../../design_system/atoms/kai_icon.dart';
import '../../design_system/atoms/kai_text.dart';
import '../../design_system/molecules/alert_card.dart';
import '../../design_system/molecules/care_block.dart';
import '../../design_system/molecules/compose_island.dart';
import '../../design_system/molecules/nav_item.dart';
import '../../design_system/molecules/source_card.dart';
import '../../design_system/theme/kai_theme.dart';
import '../../design_system/tokens/kai_tokens.dart';

/// Phase 3 dev surface — visual checkpoint for every molecule.
class MoleculesShowcaseScreen extends StatefulWidget {
  const MoleculesShowcaseScreen({super.key});

  @override
  State<MoleculesShowcaseScreen> createState() =>
      _MoleculesShowcaseScreenState();
}

class _MoleculesShowcaseScreenState extends State<MoleculesShowcaseScreen> {
  final TextEditingController _compose = TextEditingController();
  ComposeState _composeState = ComposeState.idle;

  @override
  void dispose() {
    _compose.dispose();
    super.dispose();
  }

  void _cycleComposeState() {
    setState(() {
      const values = ComposeState.values;
      _composeState = values[(values.indexOf(_composeState) + 1) % values.length];
    });
  }

  @override
  Widget build(BuildContext context) {
    final c = KaiTheme.of(context).colors;

    return Scaffold(
      backgroundColor: c.bg,
      appBar: AppBar(
        backgroundColor: c.bg,
        foregroundColor: c.ink1,
        title: const KaiText.h2('Molecules'),
      ),
      body: ListView(
        padding: const EdgeInsets.all(KaiSpace.s5),
        children: [
          _Section(
            title: 'ComposeIsland — ${_composeState.name}',
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                ComposeIsland(
                  controller: _compose,
                  onSend: () {
                    debugPrint('send: ${_compose.text}');
                  },
                  onMicToggle: () {
                    debugPrint('mic toggle');
                  },
                  state: _composeState,
                ),
                const SizedBox(height: KaiSpace.s3),
                Align(
                  alignment: Alignment.centerLeft,
                  child: KaiButton.ghost(
                    onPressed: _cycleComposeState,
                    label: 'cycle state',
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: KaiSpace.s7),
          _Section(
            title: 'NavItem',
            child: Column(
              children: [
                NavItem(label: 'Inbox', onTap: () {}),
                NavItem(
                  label: 'Folders',
                  icon: KaiIconName.search,
                  onTap: () {},
                ),
                NavItem(
                  label: 'Saved',
                  icon: KaiIconName.heart,
                  trailing: _Badge(text: '3', color: c.ink3),
                  onTap: () {},
                ),
                NavItem(
                  label: 'Виза для Японии',
                  icon: KaiIconName.search,
                  trailing: KaiText.mono('сейчас', color: c.accent),
                  active: true,
                  onTap: () {},
                ),
              ],
            ),
          ),
          const SizedBox(height: KaiSpace.s7),
          const _Section(
            title: 'SourceCard',
            child: Column(
              children: [
                SourceCard(index: 1, url: 'visa.gov', timestamp: 'fresh'),
                SourceCard(
                  index: 2,
                  url: 'timatic.iata.org',
                  timestamp: '5d',
                  freshness: SourceFreshness.stale,
                ),
                SourceCard(
                  index: 3,
                  url: 'an-extremely-long-domain.embassy.example/visa/'
                      'requirements/long/path.html',
                  freshness: SourceFreshness.unknown,
                ),
              ],
            ),
          ),
          const SizedBox(height: KaiSpace.s7),
          _Section(
            title: 'AlertCard',
            child: Column(
              children: [
                AlertCard(
                  type: AlertType.urgent,
                  title: 'Срочно: рейс отменён',
                  body: 'Авиакомпания подтвердила отмену AY-150 в 14:30.',
                  action: KaiButton.ghost(
                    onPressed: () {},
                    label: 'Подробнее',
                  ),
                ),
                const SizedBox(height: KaiSpace.s3),
                AlertCard(
                  type: AlertType.warning,
                  title: 'Документ может устареть',
                  body: 'Visa requirements page last verified 5 days ago.',
                  action: KaiButton.ghost(
                    onPressed: () {},
                    label: 'Освежить',
                  ),
                ),
                const SizedBox(height: KaiSpace.s3),
                const AlertCard(
                  type: AlertType.positive,
                  title: 'Готово',
                  body: 'Бронь подтверждена.',
                ),
                const SizedBox(height: KaiSpace.s3),
                const AlertCard(
                  type: AlertType.neutral,
                  title: 'Заметка',
                  body: 'Kai обновил воспоминание о поездке.',
                ),
              ],
            ),
          ),
          const SizedBox(height: KaiSpace.s7),
          const _Section(
            title: 'CareBlock',
            child: CareBlock(
              heading: 'Я слышу тебя.',
              body: 'Звучит очень тяжело. Я здесь, и есть люди, специально '
                  'обученные помогать в таких ситуациях.',
              resources: [
                CareResource(
                  label: 'Телефон доверия кризисной помощи',
                  number: '988',
                ),
                CareResource(label: 'Напиши «ПОМОЩЬ»', number: '741741'),
              ],
              closing: 'Без давления. Можем продолжить разговор.',
            ),
          ),
          const SizedBox(height: KaiSpace.s11),
        ],
      ),
    );
  }
}

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
        Text(
          title.toUpperCase(),
          style: KaiType.micro(color: c.ink3),
        ),
        const SizedBox(height: KaiSpace.s3),
        child,
      ],
    );
  }
}

class _Badge extends StatelessWidget {
  const _Badge({required this.text, required this.color});

  final String text;
  final Color color;

  @override
  Widget build(BuildContext context) {
    final c = KaiTheme.of(context).colors;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
      decoration: BoxDecoration(
        color: c.surface2,
        borderRadius: KaiRadius.brPill,
      ),
      child: Text(text, style: KaiType.mono(color: color)),
    );
  }
}
