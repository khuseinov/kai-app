import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../design_system/atoms/kai_bubble.dart';
import '../../design_system/atoms/kai_button.dart';
import '../../design_system/atoms/kai_button_send.dart';
import '../../design_system/atoms/kai_icon.dart';
import '../../design_system/atoms/kai_input.dart';
import '../../design_system/atoms/kai_text.dart';
import '../../design_system/atoms/kai_tide_curve.dart';
import '../../design_system/theme/kai_theme.dart';
import '../../design_system/tokens/kai_tokens.dart';

/// Phase 2 visual demo of every atom + an interactive tide-state cycle.
class AtomsShowcaseScreen extends ConsumerStatefulWidget {
  const AtomsShowcaseScreen({super.key});

  @override
  ConsumerState<AtomsShowcaseScreen> createState() =>
      _AtomsShowcaseScreenState();
}

class _AtomsShowcaseScreenState extends ConsumerState<AtomsShowcaseScreen> {
  final TextEditingController _input = TextEditingController();
  final TextEditingController _pill = TextEditingController();
  KaiSendState _sendState = KaiSendState.ready;
  int _tideIndex = 0;
  Timer? _autoCycle;
  bool _autoCycling = false;

  @override
  void dispose() {
    _input.dispose();
    _pill.dispose();
    _autoCycle?.cancel();
    super.dispose();
  }

  void _toggleAutoCycle() {
    setState(() => _autoCycling = !_autoCycling);
    if (_autoCycling) {
      _autoCycle = Timer.periodic(const Duration(seconds: 3), (_) {
        if (!mounted) return;
        setState(() {
          _tideIndex = (_tideIndex + 1) % KaiTide.all.length;
        });
      });
    } else {
      _autoCycle?.cancel();
      _autoCycle = null;
    }
  }

  void _nextSendState() {
    setState(() {
      const values = KaiSendState.values;
      _sendState = values[(values.indexOf(_sendState) + 1) % values.length];
    });
  }

  @override
  Widget build(BuildContext context) {
    final tokens = KaiTheme.of(context);
    final c = tokens.colors;
    final tideState = KaiTide.all[_tideIndex];

    return Scaffold(
      backgroundColor: c.bg,
      appBar: AppBar(
        backgroundColor: c.bg,
        foregroundColor: c.ink1,
        title: const KaiText.h2('Atoms'),
      ),
      body: ListView(
        padding: const EdgeInsets.all(KaiSpace.s5),
        children: [
          const _Section(title: 'KaiText', child: _TextDemo()),
          const SizedBox(height: KaiSpace.s7),
          const _Section(title: 'KaiIcon (14)', child: _IconDemo()),
          const SizedBox(height: KaiSpace.s7),
          _Section(
            title: 'KaiButton (4 variants)',
            child: _ButtonDemo(
              sendState: _sendState,
              onCycleSendState: _nextSendState,
            ),
          ),
          const SizedBox(height: KaiSpace.s7),
          _Section(
            title: 'KaiInput',
            child: _InputDemo(input: _input, pill: _pill),
          ),
          const SizedBox(height: KaiSpace.s7),
          const _Section(title: 'KaiBubble (3 variants)', child: _BubbleDemo()),
          const SizedBox(height: KaiSpace.s7),
          _Section(
            title: 'KaiTideCurve - ${tideState.name}',
            child: _TideDemo(
              state: tideState,
              autoCycling: _autoCycling,
              onCycle: () {
                setState(() {
                  _tideIndex = (_tideIndex + 1) % KaiTide.all.length;
                });
              },
              onToggleAuto: _toggleAutoCycle,
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
        Text(title.toUpperCase(), style: KaiType.micro(color: c.ink3)),
        const SizedBox(height: KaiSpace.s3),
        child,
      ],
    );
  }
}

class _TextDemo extends StatelessWidget {
  const _TextDemo();

  @override
  Widget build(BuildContext context) {
    return const Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        KaiText.hero('Hero 72'),
        SizedBox(height: KaiSpace.s2),
        KaiText.display('Display 56'),
        SizedBox(height: KaiSpace.s2),
        KaiText.h1('H1 36'),
        KaiText.h2('H2 24'),
        KaiText.h3('H3 18'),
        SizedBox(height: KaiSpace.s2),
        KaiText.lead('Lead 20 — the quick brown fox'),
        KaiText.body('Body 16 — the quick brown fox'),
        KaiText.small('Small 14 — secondary copy'),
        KaiText.micro('MICRO 12'),
        KaiText.mono('mono.code() = 12'),
      ],
    );
  }
}

class _IconDemo extends StatelessWidget {
  const _IconDemo();

  @override
  Widget build(BuildContext context) {
    return Wrap(
      spacing: KaiSpace.s4,
      runSpacing: KaiSpace.s3,
      children: KaiIconName.values
          .map(
            (n) => Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                KaiIcon(n, size: 24),
                const SizedBox(height: KaiSpace.s1),
                KaiText.micro(n.assetName),
              ],
            ),
          )
          .toList(growable: false),
    );
  }
}

class _ButtonDemo extends StatelessWidget {
  const _ButtonDemo({required this.sendState, required this.onCycleSendState});

  final KaiSendState sendState;
  final VoidCallback onCycleSendState;

  @override
  Widget build(BuildContext context) {
    return Wrap(
      spacing: KaiSpace.s4,
      runSpacing: KaiSpace.s4,
      crossAxisAlignment: WrapCrossAlignment.center,
      children: [
        KaiButton.tide(onPressed: () {}, label: 'Tide'),
        KaiButton.ink1(onPressed: () {}, label: 'Ink-1'),
        KaiButton.ghost(onPressed: () {}, label: 'Ghost'),
        KaiButton.icon(onPressed: () {}, icon: KaiIconName.mic),
        const KaiButton.tide(onPressed: null, label: 'Disabled'),
        Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            KaiButtonSend(state: sendState, onPressed: () {}),
            const SizedBox(width: KaiSpace.s3),
            KaiButton.ghost(
              onPressed: onCycleSendState,
              label: 'send: ${sendState.name}',
            ),
          ],
        ),
      ],
    );
  }
}

class _InputDemo extends StatelessWidget {
  const _InputDemo({required this.input, required this.pill});

  final TextEditingController input;
  final TextEditingController pill;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        KaiTextField(
          controller: input,
          placeholder: 'Tell Kai something...',
          maxLines: 3,
        ),
        const SizedBox(height: KaiSpace.s3),
        KaiTextField(
          controller: pill,
          placeholder: 'Search',
          pillRadius: true,
        ),
      ],
    );
  }
}

class _BubbleDemo extends StatelessWidget {
  const _BubbleDemo();

  @override
  Widget build(BuildContext context) {
    return const Column(
      children: [
        KaiBubble.user('Привет, Kai. Что нового?'),
        SizedBox(height: KaiSpace.s2),
        KaiBubble.kai(
          'Сегодня свежий ветер и **спокойное море**.\n\n'
          '- Утром: лёгкая прогулка\n'
          '- Днём: чтение\n'
          '- Вечером: тишина',
        ),
        SizedBox(height: KaiSpace.s2),
        KaiBubble.system('Kai обновил воспоминание'),
      ],
    );
  }
}

class _TideDemo extends StatelessWidget {
  const _TideDemo({
    required this.state,
    required this.autoCycling,
    required this.onCycle,
    required this.onToggleAuto,
  });

  final KaiTideState state;
  final bool autoCycling;
  final VoidCallback onCycle;
  final VoidCallback onToggleAuto;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        SizedBox(
          height: 28,
          child: KaiTideCurve(state: state),
        ),
        const SizedBox(height: KaiSpace.s3),
        Row(
          children: [
            KaiButton.ghost(onPressed: onCycle, label: 'next state'),
            const SizedBox(width: KaiSpace.s3),
            KaiButton.ghost(
              onPressed: onToggleAuto,
              label: autoCycling ? 'auto: on' : 'auto: off',
            ),
          ],
        ),
      ],
    );
  }
}
