import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/providers/root.dart';
import '../../design_system/theme/kai_theme.dart';
import '../../design_system/tokens/kai_tokens.dart';
import '../../design_system/atoms/atoms.dart';
import '../../design_system/primitives/primitives.dart';

/// Visual gallery of every v3 primitive + atom.
///
/// Not a production surface — layout literals in the scaffold are acceptable.
class V3AtomsShowcaseScreen extends ConsumerStatefulWidget {
  const V3AtomsShowcaseScreen({super.key});

  @override
  ConsumerState<V3AtomsShowcaseScreen> createState() =>
      _V3AtomsShowcaseScreenState();
}

class _V3AtomsShowcaseScreenState
    extends ConsumerState<V3AtomsShowcaseScreen> {
  final _lineCtrl = TextEditingController();
  final _pillCtrl = TextEditingController();
  KaiSendState _sendState = KaiSendState.ready;
  int _tideIndex = 0;
  bool _autoCycling = false;
  Timer? _autoCycle;
  bool _toggleOn = true;
  bool _toggleOff = false;

  @override
  void dispose() {
    _lineCtrl.dispose();
    _pillCtrl.dispose();
    _autoCycle?.cancel();
    super.dispose();
  }

  void _cycleSend() {
    setState(() {
      const vals = KaiSendState.values;
      _sendState = vals[(vals.indexOf(_sendState) + 1) % vals.length];
    });
  }

  void _toggleAuto() {
    setState(() => _autoCycling = !_autoCycling);
    if (_autoCycling) {
      _autoCycle = Timer.periodic(const Duration(seconds: 3), (_) {
        if (!mounted) return;
        setState(() => _tideIndex = (_tideIndex + 1) % KaiTide.all.length);
      });
    } else {
      _autoCycle?.cancel();
      _autoCycle = null;
    }
  }

  @override
  Widget build(BuildContext context) {
    final c = KaiTheme.of(context).colors;
    final themeMode = ref.watch(themeModeProvider);
    final tideState = KaiTide.all[_tideIndex];

    return Scaffold(
      backgroundColor: c.bg,
      appBar: AppBar(
        backgroundColor: c.bg,
        foregroundColor: c.ink1,
        title: const Text('v3 — Primitives + Atoms'),
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
          // ── KaiIcon ──────────────────────────────────────────────────────────
          _Section(
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
                    KaiIcon(
                      n,
                      size: 24,
                      color: isNew ? c.accent : null,
                    ),
                    const SizedBox(height: 4),
                    KaiText.micro(
                      n.assetName,
                      color: isNew ? c.accent : c.ink3,
                    ),
                  ],
                );
              }).toList(),
            ),
          ),
          const SizedBox(height: KaiSpace.s7),

          // ── KaiSurface ───────────────────────────────────────────────────────
          _Section(
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
          ),
          const SizedBox(height: KaiSpace.s7),

          // ── KaiGradientBar ───────────────────────────────────────────────────
          const _Section(
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
          ),
          const SizedBox(height: KaiSpace.s7),

          // ── KaiText ──────────────────────────────────────────────────────────
          const _Section(
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
          ),
          const SizedBox(height: KaiSpace.s7),

          // ── KaiButton ────────────────────────────────────────────────────────
          _Section(
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
                KaiButton.ink(
                    onPressed: () {}, label: 'Ink fullWidth', fullWidth: true),
                KaiButton.ghost(onPressed: () {}, label: 'Ghost neutral'),
                KaiButton.ghost(
                    onPressed: () {},
                    label: 'Ghost warning',
                    tone: KaiButtonTone.warning),
                KaiButton.ghost(
                    onPressed: () {},
                    label: 'Ghost negative',
                    tone: KaiButtonTone.negative),
                KaiButton.ghost(
                    onPressed: () {}, label: 'Ghost pill', pill: true),
                KaiButton.text(onPressed: () {}, label: 'Text neutral'),
                KaiButton.text(
                    onPressed: () {},
                    label: 'Text accent',
                    tone: KaiButtonTone.accent),
                KaiButton.text(
                    onPressed: () {},
                    label: 'Text negative',
                    tone: KaiButtonTone.negative),
              ],
            ),
          ),
          const SizedBox(height: KaiSpace.s7),

          // ── KaiIconButton ────────────────────────────────────────────────────
          _Section(
            title: 'KaiIconButton (surface / transparent / bare)',
            child: Wrap(
              spacing: KaiSpace.s4,
              runSpacing: KaiSpace.s4,
              crossAxisAlignment: WrapCrossAlignment.center,
              children: [
                Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    KaiIconButton.surface(
                        onPressed: () {}, icon: KaiIconName.mic),
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
                    KaiIconButton.bare(
                        onPressed: () {}, icon: KaiIconName.close),
                    const SizedBox(height: 4),
                    KaiText.micro('bare', color: c.ink3),
                  ],
                ),
                Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const KaiIconButton.bare(
                      onPressed: null,
                      icon: KaiIconName.lock,
                    ),
                    const SizedBox(height: 4),
                    KaiText.micro('disabled', color: c.ink3),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(height: KaiSpace.s7),

          // ── KaiSendButton ────────────────────────────────────────────────────
          _Section(
            title: 'KaiSendButton (4 states — tap to cycle)',
            child: Row(
              children: [
                KaiSendButton(state: _sendState, onPressed: _cycleSend),
                const SizedBox(width: KaiSpace.s4),
                KaiButton.ghost(
                  onPressed: _cycleSend,
                  label: 'state: ${_sendState.name}',
                ),
              ],
            ),
          ),
          const SizedBox(height: KaiSpace.s7),

          // ── KaiInput ─────────────────────────────────────────────────────────
          _Section(
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
          ),
          const SizedBox(height: KaiSpace.s7),

          // ── KaiToggle ────────────────────────────────────────────────────────
          _Section(
            title: 'KaiToggle (on / off / disabled)',
            child: Row(
              children: [
                KaiToggle(
                  value: _toggleOn,
                  onChanged: (v) => setState(() => _toggleOn = v),
                ),
                const SizedBox(width: KaiSpace.s4),
                KaiToggle(
                  value: _toggleOff,
                  onChanged: (v) => setState(() => _toggleOff = v),
                ),
                const SizedBox(width: KaiSpace.s4),
                const KaiToggle(value: true, onChanged: null),
                const SizedBox(width: KaiSpace.s3),
                KaiText.small('disabled', color: c.ink3),
              ],
            ),
          ),
          const SizedBox(height: KaiSpace.s7),

          // ── KaiChip ──────────────────────────────────────────────────────────
          const _Section(
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
          ),
          const SizedBox(height: KaiSpace.s7),

          // ── KaiBadge ─────────────────────────────────────────────────────────
          const _Section(
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
          ),
          const SizedBox(height: KaiSpace.s7),

          // ── KaiAvatar ────────────────────────────────────────────────────────
          const _Section(
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
          ),
          const SizedBox(height: KaiSpace.s7),

          // ── KaiTideCurve ─────────────────────────────────────────────────────
          _Section(
            title: 'KaiTideCurve — ${tideState.name}',
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                SizedBox(height: 28, child: KaiTideCurve(state: tideState)),
                const SizedBox(height: KaiSpace.s3),
                Row(
                  children: [
                    KaiButton.ghost(
                      onPressed: () => setState(() {
                        _tideIndex = (_tideIndex + 1) % KaiTide.all.length;
                      }),
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
                // All 8 states in a small grid
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
          ),
          const SizedBox(height: KaiSpace.s7),

          // ── KaiDivider ───────────────────────────────────────────────────────
          _Section(
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
          ),
          const SizedBox(height: KaiSpace.s7),

          // ── KaiSheetShell ────────────────────────────────────────────────────
          const _Section(
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
