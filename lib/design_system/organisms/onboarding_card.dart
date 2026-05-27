import 'package:flutter/material.dart';

import '../atoms/kai_button.dart';
import '../atoms/kai_icon.dart';
import '../atoms/kai_text.dart';
import '../atoms/kai_tide_curve.dart';
import '../theme/kai_theme.dart';
import '../tokens/kai_tokens.dart';

/// 4-step onboarding wizard card.
///
/// Renders one step's content; does not drive page transitions.
/// Parent is responsible for stepIndex progression and calling [onComplete].
class OnboardingCard extends StatefulWidget {
  const OnboardingCard({
    required this.stepIndex,
    this.onComplete,
    super.key,
  }) : assert(
          stepIndex >= 0 && stepIndex <= 3,
          'stepIndex must be 0-3',
        );

  /// Which step to render (0 = welcome, 1 = tide, 2 = gestures, 3 = context).
  final int stepIndex;

  /// Called when the user taps "Начать" on the final step (stepIndex == 3).
  final VoidCallback? onComplete;

  @override
  State<OnboardingCard> createState() => _OnboardingCardState();
}

class _OnboardingCardState extends State<OnboardingCard>
    with SingleTickerProviderStateMixin {
  // Used by step 1 (tide chip cycler).
  late final AnimationController _chipController;

  /// Which tide chip / state is highlighted (0=thinking, 1=responding, 2=listening).
  int _activeChip = 0;

  static const _kChipDuration = Duration(milliseconds: 2400);

  @override
  void initState() {
    super.initState();
    _chipController = AnimationController(vsync: this, duration: _kChipDuration)
      ..addStatusListener(_onChipCycle)
      ..repeat();
  }

  void _onChipCycle(AnimationStatus status) {
    if (status == AnimationStatus.completed) {
      if (!mounted) return;
      setState(() => _activeChip = (_activeChip + 1) % 3);
    }
  }

  @override
  void dispose() {
    _chipController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final tokens = KaiTheme.of(context);
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: tokens.colors.surface,
        borderRadius: KaiRadius.br3,
        boxShadow: const [
          BoxShadow(
            color: Color(0x12000000),
            blurRadius: 16,
            offset: Offset(0, 4),
          ),
        ],
      ),
      padding: const EdgeInsets.all(KaiSpace.s6),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          _buildStep(context, tokens),
          const SizedBox(height: KaiSpace.s6),
          _StepDots(count: 4, active: widget.stepIndex),
        ],
      ),
    );
  }

  Widget _buildStep(BuildContext context, KaiTokens tokens) {
    switch (widget.stepIndex) {
      case 0:
        return _WelcomeStep(tokens: tokens);
      case 1:
        return _TideStep(
          tokens: tokens,
          activeChip: _activeChip,
          controller: _chipController,
        );
      case 2:
        return _GesturesStep(tokens: tokens);
      case 3:
        return _ContextStep(tokens: tokens, onComplete: widget.onComplete);
      default:
        return const SizedBox.shrink();
    }
  }
}

// ─── Step 0: Welcome ─────────────────────────────────────────────────────────

class _WelcomeStep extends StatelessWidget {
  const _WelcomeStep({required this.tokens});

  final KaiTokens tokens;

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        // Kai glyph: 64×64 tide gradient circle
        Container(
          width: 64,
          height: 64,
          decoration: const BoxDecoration(
            gradient: KaiTide.gradient,
            shape: BoxShape.circle,
          ),
        ),
        const SizedBox(height: KaiSpace.s5),
        KaiText.h2(
          'Добро пожаловать в Kai',
          color: tokens.colors.ink1,
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: KaiSpace.s3),
        KaiText.body(
          'Kai — ваш персональный ИИ-помощник. '
          'Он всегда рядом, чтобы помочь с планами, вопросами и идеями.',
          color: tokens.colors.ink3,
          textAlign: TextAlign.center,
        ),
      ],
    );
  }
}

// ─── Step 1: Tide ─────────────────────────────────────────────────────────────

const _kChipLabels = ['Думает', 'Отвечает', 'Слушает'];
const _kChipStates = [KaiTide.thinking, KaiTide.responding, KaiTide.listening];

class _TideStep extends StatelessWidget {
  const _TideStep({
    required this.tokens,
    required this.activeChip,
    required this.controller,
  });

  final KaiTokens tokens;
  final int activeChip;
  final AnimationController controller;

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        KaiText.h3('Kai всегда здесь', color: tokens.colors.ink1),
        const SizedBox(height: KaiSpace.s5),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: List.generate(_kChipLabels.length, (i) {
            final isActive = i == activeChip;
            return Padding(
              padding: const EdgeInsets.symmetric(horizontal: KaiSpace.s1),
              child: _StateChip(
                label: _kChipLabels[i],
                active: isActive,
                tokens: tokens,
              ),
            );
          }),
        ),
        const SizedBox(height: KaiSpace.s5),
        KaiTideCurve(state: _kChipStates[activeChip], height: 28),
      ],
    );
  }
}

class _StateChip extends StatelessWidget {
  const _StateChip({
    required this.label,
    required this.active,
    required this.tokens,
  });

  final String label;
  final bool active;
  final KaiTokens tokens;

  @override
  Widget build(BuildContext context) {
    final bg = active ? tokens.colors.accentWash : Colors.transparent;
    final textColor = active ? tokens.colors.accent : tokens.colors.ink3;
    final border = active
        ? BorderSide.none
        : BorderSide(color: tokens.colors.line, width: 1);

    return AnimatedContainer(
      duration: const Duration(milliseconds: 200),
      padding: const EdgeInsets.symmetric(
        horizontal: KaiSpace.s3,
        vertical: KaiSpace.s1,
      ),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: KaiRadius.brPill,
        border: Border.fromBorderSide(border),
      ),
      child: Text(
        label,
        style: KaiType.small(color: textColor),
      ),
    );
  }
}

// ─── Step 2: Gestures ─────────────────────────────────────────────────────────

class _GesturesStep extends StatelessWidget {
  const _GesturesStep({required this.tokens});

  final KaiTokens tokens;

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        KaiText.h3('Жесты', color: tokens.colors.ink1),
        const SizedBox(height: KaiSpace.s5),
        _GestureCard(
          icon: KaiIconName.chevRight,
          label: 'Открыть навигацию',
          description: 'Свайп вправо',
          tokens: tokens,
        ),
        const SizedBox(height: KaiSpace.s2),
        _GestureCard(
          icon: KaiIconName.arrowUp,
          label: 'Открыть ввод',
          description: 'Свайп вверх',
          tokens: tokens,
        ),
        const SizedBox(height: KaiSpace.s2),
        _GestureCard(
          icon: KaiIconName.menu,
          label: 'Быстрые действия',
          description: 'Долгое нажатие',
          tokens: tokens,
        ),
      ],
    );
  }
}

class _GestureCard extends StatelessWidget {
  const _GestureCard({
    required this.icon,
    required this.label,
    required this.description,
    required this.tokens,
  });

  final KaiIconName icon;
  final String label;
  final String description;
  final KaiTokens tokens;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: KaiSpace.s4,
        vertical: KaiSpace.s3,
      ),
      decoration: BoxDecoration(
        color: tokens.colors.surface2,
        borderRadius: KaiRadius.br2,
      ),
      child: Row(
        children: [
          KaiIcon(icon, size: 20, color: tokens.colors.ink3),
          const SizedBox(width: KaiSpace.s3),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                description,
                style: KaiType.small(color: tokens.colors.ink3),
              ),
              const SizedBox(height: 2),
              Text(
                label,
                style: KaiType.body(color: tokens.colors.ink1),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

// ─── Step 3: Context ──────────────────────────────────────────────────────────

class _ContextStep extends StatelessWidget {
  const _ContextStep({required this.tokens, this.onComplete});

  final KaiTokens tokens;
  final VoidCallback? onComplete;

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        KaiText.h3('Настройки', color: tokens.colors.ink1),
        const SizedBox(height: KaiSpace.s5),
        // Country dropdown placeholder
        Container(
          width: double.infinity,
          padding: const EdgeInsets.symmetric(
            horizontal: KaiSpace.s4,
            vertical: KaiSpace.s3,
          ),
          decoration: BoxDecoration(
            color: tokens.colors.surface2,
            borderRadius: KaiRadius.brPill,
          ),
          child: Text(
            '🌍 Страна',
            style: KaiType.body(color: tokens.colors.ink3),
          ),
        ),
        const SizedBox(height: KaiSpace.s4),
        // Language chips
        Row(
          children: [
            _LangChip(label: 'RU', selected: true, tokens: tokens),
            const SizedBox(width: KaiSpace.s2),
            _LangChip(label: 'EN', selected: false, tokens: tokens),
          ],
        ),
        const SizedBox(height: KaiSpace.s6),
        SizedBox(
          width: double.infinity,
          child: KaiButton.tide(
            onPressed: onComplete,
            label: 'Начать',
          ),
        ),
      ],
    );
  }
}

class _LangChip extends StatelessWidget {
  const _LangChip({
    required this.label,
    required this.selected,
    required this.tokens,
  });

  final String label;
  final bool selected;
  final KaiTokens tokens;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: KaiSpace.s4,
        vertical: KaiSpace.s2,
      ),
      decoration: BoxDecoration(
        color: selected ? tokens.colors.accent : Colors.transparent,
        borderRadius: KaiRadius.brPill,
        border: Border.all(
          color: selected ? tokens.colors.accent : tokens.colors.ink4,
          width: 1,
        ),
      ),
      child: Text(
        label,
        style: KaiType.small(
          color: selected ? const Color(0xFFFFFFFF) : tokens.colors.ink4,
        ),
      ),
    );
  }
}

// ─── Dots indicator ───────────────────────────────────────────────────────────

class _StepDots extends StatelessWidget {
  const _StepDots({required this.count, required this.active});

  final int count;
  final int active;

  @override
  Widget build(BuildContext context) {
    final tokens = KaiTheme.of(context);
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: List.generate(count, (i) {
        final isActive = i == active;
        return AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          margin: const EdgeInsets.symmetric(horizontal: 3),
          width: 6,
          height: 6,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: isActive ? tokens.colors.accent : tokens.colors.ink4,
          ),
        );
      }),
    );
  }
}

