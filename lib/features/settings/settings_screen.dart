import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../core/providers/root.dart';
import '../../design_system/theme/kai_theme.dart';
import '../../design_system/tokens/kai_tokens.dart';
import '../../design_system/atoms/atoms.dart';
import '../../design_system/molecules/molecules.dart';
import '../../design_system/primitives/primitives.dart';

/// Settings screen. Canon: `new-design/settings.html`.
///
/// Sections (top → bottom):
/// 1. Account hero (avatar + name + email + plan badge)
/// 2. Внешний вид — Тема (segmented Авто/Светлая/Тёмная), reduce-motion toggle
/// 3. Голос — voice input toggle, Kai voice replies toggle
/// 4. Данные — Память (chev), Язык (text + chev) + danger "Удалить мои данные"
/// 5. Приватность — PII audit (positive "чисто"), auto-forget ("вкл"), tokenisation (chev)
/// 6. Аккаунт — Тарифный план (chev), Выйти (negative title, no trail)
/// 7. О приложении — Версия (text)
///
/// Theme mode is wired to [themeModeProvider]. Other toggles are local-only
/// for now — TODO: wire to a `settingsProvider` once that ships.
class SettingsScreen extends ConsumerStatefulWidget {
  const SettingsScreen({super.key});

  @override
  ConsumerState<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends ConsumerState<SettingsScreen> {
  // Local state — TODO wire to settings provider when added.
  bool _reduceMotion = false;
  bool _voiceInput = true;
  bool _voiceReplies = false;

  static int _themeIndex(ThemeMode m) => switch (m) {
        ThemeMode.system => 0,
        ThemeMode.light => 1,
        ThemeMode.dark => 2,
      };

  static ThemeMode _modeFromIndex(int i) => switch (i) {
        0 => ThemeMode.system,
        1 => ThemeMode.light,
        2 => ThemeMode.dark,
        _ => ThemeMode.system,
      };

  @override
  Widget build(BuildContext context) {
    final c = KaiTheme.of(context).colors;
    final themeMode = ref.watch(themeModeProvider);

    return Scaffold(
      backgroundColor: c.bg,
      body: SafeArea(
        bottom: false,
        child: Column(
          children: [
            _SettingsTopBar(),
            // Tide curve — idle state, 4 px below appbar top.
            const SizedBox(
              height: 14,
              child: Padding(
                padding: EdgeInsets.symmetric(horizontal: 18),
                child: KaiTideCurve(state: KaiTide.idle),
              ),
            ),
            Expanded(
              child: ListView(
                padding: const EdgeInsets.fromLTRB(14, 16, 14, 24),
                children: [
                  // 1. Account hero
                  const KaiAccountHero(
                    name: 'Aibek',
                    email: 'aibek@wize.ai',
                    initial: 'A',
                    planLabel: 'plus',
                  ),
                  const SizedBox(height: 12),

                  // 2. Внешний вид
                  KaiSettingsGroup(
                    label: 'внешний вид',
                    children: [
                      KaiSettingsRow(
                        icon: KaiIconName.palette,
                        title: 'Тема',
                        trailing: KaiSegmentedControl(
                          options: const ['Авто', 'Светлая', 'Тёмная'],
                          selectedIndex: _themeIndex(themeMode),
                          onSelected: (i) {
                            ref.read(themeModeProvider.notifier).state =
                                _modeFromIndex(i);
                          },
                        ),
                      ),
                      KaiSettingsRow(
                        icon: KaiIconName.motion,
                        title: 'Уменьшить анимацию',
                        subtitle: 'кривая прилива становится статичной',
                        trailing: KaiToggle(
                          value: _reduceMotion,
                          onChanged: (v) =>
                              setState(() => _reduceMotion = v),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),

                  // 3. Голос
                  KaiSettingsGroup(
                    label: 'голос',
                    children: [
                      KaiSettingsRow(
                        icon: KaiIconName.mic,
                        title: 'Голосовой ввод',
                        subtitle: 'нажмите орб для начала прослушивания',
                        trailing: KaiToggle(
                          value: _voiceInput,
                          onChanged: (v) => setState(() => _voiceInput = v),
                        ),
                      ),
                      KaiSettingsRow(
                        icon: KaiIconName.speaker,
                        title: 'Kai отвечает голосом',
                        subtitle: 'голосовые ответы на голосовые запросы',
                        trailing: KaiToggle(
                          value: _voiceReplies,
                          onChanged: (v) =>
                              setState(() => _voiceReplies = v),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),

                  // 4. Данные
                  KaiSettingsGroup(
                    label: 'данные',
                    children: [
                      KaiSettingsRow(
                        icon: KaiIconName.memory,
                        title: 'Память',
                        subtitle: '23 факта · вкл',
                        trailing: const _ChevTrail(),
                        onTap: () {},
                      ),
                      KaiSettingsRow(
                        icon: KaiIconName.globe,
                        title: 'Язык',
                        subtitle: 'интерфейс',
                        trailing: const _TextChevTrail(text: 'Русский'),
                        onTap: () {},
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  KaiSettingsGroup(
                    danger: true,
                    children: [
                      KaiSettingsRow(
                        icon: KaiIconName.trash,
                        title: 'Удалить мои данные',
                        subtitle: 'необратимо · GDPR',
                        danger: true,
                        trailing: _ChevTrail(color: c.negative),
                        onTap: () {},
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),

                  // 5. Приватность
                  KaiSettingsGroup(
                    label: 'приватность',
                    children: [
                      KaiSettingsRow(
                        icon: KaiIconName.shield,
                        title: 'PII-аудит',
                        subtitle: '0 утечек · 30-дневный мониторинг',
                        trailing: _StatusTrail(
                          text: 'чисто',
                          weight: FontWeight.w600,
                          color: c.positive,
                        ),
                        onTap: () {},
                      ),
                      KaiSettingsRow(
                        icon: KaiIconName.clock,
                        title: 'Авто-забывание',
                        subtitle: 'временные выводы истекают через 24ч',
                        trailing: _StatusTrail(
                          text: 'вкл',
                          color: c.positive,
                        ),
                      ),
                      KaiSettingsRow(
                        icon: KaiIconName.lock,
                        title: '3-уровневая токенизация',
                        subtitle: 'имя, геолокация, паспорт защищены',
                        trailing: const _ChevTrail(),
                        onTap: () {},
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),

                  // 6. Аккаунт
                  KaiSettingsGroup(
                    label: 'аккаунт',
                    children: [
                      KaiSettingsRow(
                        icon: KaiIconName.info,
                        title: 'Тарифный план',
                        subtitle: 'Kai Plus · \$9/мес',
                        trailing: const _ChevTrail(),
                        onTap: () {},
                      ),
                      KaiSettingsRow(
                        icon: KaiIconName.logout,
                        title: 'Выйти',
                        danger: true,
                        onTap: () {},
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),

                  // 7. О приложении
                  KaiSettingsGroup(
                    label: 'о приложении',
                    children: [
                      KaiSettingsRow(
                        icon: KaiIconName.info,
                        title: 'Версия',
                        trailing: Text(
                          '0.2.0',
                          style: TextStyle(
                            fontFamily: 'Manrope',
                            fontSize: 11,
                            fontWeight: FontWeight.w500,
                            color: c.ink3,
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ─── Top bar — appbar 28 height ─────────────────────────────────────────────

class _SettingsTopBar extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final c = KaiTheme.of(context).colors;
    return Padding(
      // Canon: appbar top 16, left/right 16, height 28.
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 0),
      child: SizedBox(
        height: 28,
        child: Row(
          children: [
            // Back button — 28×28 circle, surface-2 bg, ink-1 chev-left.
            GestureDetector(
              onTap: () {
                if (context.canPop()) context.pop();
              },
              child: Container(
                width: 28,
                height: 28,
                decoration: BoxDecoration(
                  color: c.surface2,
                  shape: BoxShape.circle,
                ),
                alignment: Alignment.center,
                child: Transform.flip(
                  flipX: true,
                  child: KaiIcon(
                    KaiIconName.chev,
                    size: 14,
                    color: c.ink1,
                  ),
                ),
              ),
            ),
            // Centred title — true centring achieved via Spacer on both sides.
            Expanded(
              child: Center(
                child: Text(
                  'Настройки',
                  style: TextStyle(
                    fontFamily: 'Manrope',
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    color: c.ink1,
                    letterSpacing: -0.005 * 13,
                  ),
                ),
              ),
            ),
            // Right spacer — matches back-button width so the title stays
            // perfectly centred. Canon settings.html uses `width:28px` here.
            const SizedBox(width: 28),
          ],
        ),
      ),
    );
  }
}

// ─── Trailing widgets ───────────────────────────────────────────────────────

class _ChevTrail extends StatelessWidget {
  const _ChevTrail({this.color});

  final Color? color;

  @override
  Widget build(BuildContext context) {
    final c = KaiTheme.of(context).colors;
    return KaiIcon(
      KaiIconName.chev,
      size: 13,
      color: color ?? c.ink3,
    );
  }
}

class _TextChevTrail extends StatelessWidget {
  const _TextChevTrail({required this.text});

  final String text;

  @override
  Widget build(BuildContext context) {
    final c = KaiTheme.of(context).colors;
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          text,
          style: TextStyle(
            fontFamily: 'Manrope',
            fontSize: 11,
            fontWeight: FontWeight.w500,
            color: c.ink3,
          ),
        ),
        const SizedBox(width: 5),
        KaiIcon(KaiIconName.chev, size: 13, color: c.ink3),
      ],
    );
  }
}

class _StatusTrail extends StatelessWidget {
  const _StatusTrail({
    required this.text,
    required this.color,
    this.weight = FontWeight.w500,
  });

  final String text;
  final Color color;
  final FontWeight weight;

  @override
  Widget build(BuildContext context) {
    return Text(
      text,
      style: TextStyle(
        fontFamily: 'JetBrainsMono',
        fontSize: 10,
        fontWeight: weight,
        color: color,
      ),
    );
  }
}
