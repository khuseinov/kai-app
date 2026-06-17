import 'package:flutter/material.dart';
import 'package:kai_app/design_system/atoms/atoms.dart';
import 'package:kai_app/design_system/primitives/primitives.dart';
import 'package:kai_app/design_system/theme/kai_theme.dart';
import 'package:kai_app/design_system/tokens/kai_tokens.dart';
import 'package:kai_app/features/onboarding/presentation/widgets/kai_onboarding_scale.dart';
import 'package:kai_app/l10n/app_localizations.dart';

/// v4 4-step onboarding — one widget per step.
///
/// Fills the parent's available space (no card wrapper / no box-shadow).
/// Layout: padded Column with step content at top, content centred vertically.
///
/// The whole step is scaled via [scale] so the onboarding feels generous on
/// large phones and tablets without becoming cramped on smaller devices. If
/// [scale] is omitted it is resolved from the viewport.
class KaiOnboardingCard extends StatelessWidget {
  const KaiOnboardingCard({
    required this.stepIndex,
    this.scale,
    super.key,
  }) : assert(
          stepIndex >= 0 && stepIndex <= 3,
          'stepIndex must be 0–3',
        );

  /// 0 = welcome, 1 = tide, 2 = gestures, 3 = context.
  final int stepIndex;

  /// Optional visual scale. When null, computed from [MediaQuery].
  final double? scale;

  @override
  Widget build(BuildContext context) {
    final tokens = KaiTheme.of(context);
    final l10n = AppLocalizations.of(context);
    final s = scale ?? onboardingScale(context);
    final m = _OnboardingMetrics(s);

    // Steps 1–2 have the tide-bar overlay above them. Extra top inset keeps
    // content clear of the curve.
    final topPad = (stepIndex == 1 || stepIndex == 2)
        ? m.contentTopTide
        : m.contentTopNoTide;

    return Padding(
      padding: EdgeInsets.symmetric(horizontal: m.hPadding),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          SizedBox(height: topPad),
          Expanded(
            child: Center(
              child: SingleChildScrollView(
                physics: const BouncingScrollPhysics(),
                child: Padding(
                  padding: EdgeInsets.symmetric(vertical: 16 * s),
                  child: _buildStep(context, tokens, l10n, m),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStep(
    BuildContext context,
    KaiTokens tokens,
    AppLocalizations l10n,
    _OnboardingMetrics m,
  ) {
    switch (stepIndex) {
      case 0:
        return _WelcomeStep(tokens: tokens, l10n: l10n, m: m);
      case 1:
        return _TideStep(tokens: tokens, l10n: l10n, m: m);
      case 2:
        return _GesturesStep(tokens: tokens, l10n: l10n, m: m);
      case 3:
        return _ContextStep(tokens: tokens, l10n: l10n, m: m);
      default:
        return const SizedBox.shrink();
    }
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Metrics — all onboarding sizes multiplied by the responsive scale factor.
// ─────────────────────────────────────────────────────────────────────────────

class _OnboardingMetrics {
  _OnboardingMetrics(this.scale);

  final double scale;
  double get s => scale;

  double get hPadding => 24 * s;
  double get contentTopNoTide => 20 * s;
  double get contentTopTide => 40 * s;

  double get logoSize => 80 * s;

  double get titleSize => 28 * s;
  double get bodySize => 15 * s;
  double get labelSize => 14 * s;
  double get descSize => 12 * s;
  double get microSize => 11 * s;
  double get inputTextSize => 14 * s;
  double get chipTextSize => 13 * s;

  double get chipHPadding => 12 * s;
  double get chipVPadding => 7 * s;

  double get rowPaddingV => 12 * s;
  double get rowPaddingH => 14 * s;
  double get rowRadius => 12 * s;
  double get rowGap => 12 * s;
  double get rowInnerGap => 10 * s;

  double get iconSquare => 40 * s;
  double get iconRadius => 10 * s;
  double get iconSize => 20 * s;

  double get flagSize => 16 * s;
  double get flagRadius => 4 * s;

  double get titleBodyGap => 12 * s;
  double get bodyContentGap => 20 * s;
  double get sectionGap => 10 * s;

  TextStyle titleStyle(KaiTokens tokens) => KaiType.h2(color: tokens.colors.ink1)
      .copyWith(
        fontSize: titleSize,
        height: 1.15,
        letterSpacing: titleSize * -0.02,
      );

  TextStyle bodyStyle(KaiTokens tokens) => KaiType.body(color: tokens.colors.ink2)
      .copyWith(
        fontSize: bodySize,
        height: 1.55,
      );

  TextStyle labelStyle(KaiTokens tokens) =>
      KaiType.small(color: tokens.colors.ink1).copyWith(
        fontSize: labelSize,
        fontWeight: FontWeight.w500,
        height: 1.35,
        letterSpacing: 0,
      );

  TextStyle descStyle(KaiTokens tokens) =>
      KaiType.mono(color: tokens.colors.ink3).copyWith(
        fontSize: descSize,
        height: 1.4,
      );

  TextStyle microStyle(KaiTokens tokens) =>
      KaiType.mono(color: tokens.colors.ink3).copyWith(
        fontSize: microSize,
        fontWeight: FontWeight.w500,
        letterSpacing: microSize * 0.08,
        height: 1.4,
      );

  TextStyle inputStyle(KaiTokens tokens) =>
      KaiType.small(color: tokens.colors.ink1).copyWith(
        fontSize: inputTextSize,
        fontWeight: FontWeight.w400,
        height: 1.4,
      );

  TextStyle chipStyle(KaiTokens tokens, {required bool active}) =>
      KaiType.small(color: active ? tokens.colors.accent : tokens.colors.ink2)
          .copyWith(
        fontSize: chipTextSize,
        fontWeight: FontWeight.w500,
        height: 1.3,
        letterSpacing: 0,
      );
}

// ─── Step 0: Welcome ──────────────────────────────────────────────────────────

class _WelcomeStep extends StatelessWidget {
  const _WelcomeStep({
    required this.tokens,
    required this.l10n,
    required this.m,
  });

  final KaiTokens tokens;
  final AppLocalizations l10n;
  final _OnboardingMetrics m;

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        // KaiLogo(size: m.logoSize),
        SizedBox(height: 20 * m.s),
        Text(
          l10n.onboardingWelcomeTitle,
          style: m.titleStyle(tokens),
          textAlign: TextAlign.center,
        ),
        SizedBox(height: m.titleBodyGap),
        Text(
          l10n.onboardingWelcomeBody,
          style: m.bodyStyle(tokens),
          textAlign: TextAlign.center,
        ),
      ],
    );
  }
}

// ─── Step 1: Tide ─────────────────────────────────────────────────────────────

class _TideStep extends StatelessWidget {
  const _TideStep({
    required this.tokens,
    required this.l10n,
    required this.m,
  });

  final KaiTokens tokens;
  final AppLocalizations l10n;
  final _OnboardingMetrics m;

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text(
          l10n.onboardingTideTitle,
          style: m.titleStyle(tokens),
        ),
        SizedBox(height: m.titleBodyGap),
        Text(
          l10n.onboardingTideBody,
          style: m.bodyStyle(tokens),
        ),
        SizedBox(height: m.bodyContentGap),
        _TideStateRow(
          state: KaiTide.idle,
          name: l10n.onboardingTideStateIdleName,
          desc: l10n.onboardingTideStateIdleDesc,
          tokens: tokens,
          m: m,
        ),
        SizedBox(height: m.rowGap),
        _TideStateRow(
          state: KaiTide.thinking,
          name: l10n.onboardingTideStateThinkingName,
          desc: l10n.onboardingTideStateThinkingDesc,
          tokens: tokens,
          m: m,
        ),
        SizedBox(height: m.rowGap),
        _TideStateRow(
          state: KaiTide.responding,
          name: l10n.onboardingTideStateRespondingName,
          desc: l10n.onboardingTideStateRespondingDesc,
          tokens: tokens,
          m: m,
        ),
      ],
    );
  }
}

class _TideStateRow extends StatelessWidget {
  const _TideStateRow({
    required this.state,
    required this.name,
    required this.desc,
    required this.tokens,
    required this.m,
  });

  final KaiTideState state;
  final String name;
  final String desc;
  final KaiTokens tokens;
  final _OnboardingMetrics m;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: m.rowPaddingH,
        vertical: m.rowPaddingV,
      ),
      decoration: BoxDecoration(
        color: tokens.colors.surface2,
        borderRadius: BorderRadius.circular(m.rowRadius),
      ),
      child: Row(
        children: [
          SizedBox(
            width: 40 * m.s,
            height: 8 * m.s,
            child: KaiTideCurve(state: state, height: 8 * m.s),
          ),
          SizedBox(width: m.rowInnerGap),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(name, style: m.labelStyle(tokens)),
              SizedBox(height: 1 * m.s),
              Text(desc, style: m.descStyle(tokens)),
            ],
          ),
        ],
      ),
    );
  }
}

// ─── Step 2: Gestures ─────────────────────────────────────────────────────────

class _GesturesStep extends StatelessWidget {
  const _GesturesStep({
    required this.tokens,
    required this.l10n,
    required this.m,
  });

  final KaiTokens tokens;
  final AppLocalizations l10n;
  final _OnboardingMetrics m;

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text(
          l10n.onboardingGesturesTitle,
          style: m.titleStyle(tokens),
        ),
        SizedBox(height: m.titleBodyGap),
        Text(
          l10n.onboardingGesturesBody,
          style: m.bodyStyle(tokens),
        ),
        SizedBox(height: m.bodyContentGap),
        _GestureRow(
          icon: KaiIconName.chevRight,
          label: l10n.onboardingGestureNavLabel,
          hint: l10n.onboardingGestureNavHint,
          tokens: tokens,
          m: m,
        ),
        SizedBox(height: m.rowGap),
        _GestureRow(
          icon: KaiIconName.arrowUp,
          label: l10n.onboardingGestureInputLabel,
          hint: l10n.onboardingGestureInputHint,
          tokens: tokens,
          m: m,
        ),
        SizedBox(height: m.rowGap),
        _GestureRow(
          icon: KaiIconName.press,
          label: l10n.onboardingGestureActionsLabel,
          hint: l10n.onboardingGestureActionsHint,
          tokens: tokens,
          m: m,
        ),
      ],
    );
  }
}

class _GestureRow extends StatelessWidget {
  const _GestureRow({
    required this.icon,
    required this.label,
    required this.hint,
    required this.tokens,
    required this.m,
  });

  final KaiIconName icon;
  final String label;
  final String hint;
  final KaiTokens tokens;
  final _OnboardingMetrics m;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: m.rowPaddingH,
        vertical: m.rowPaddingV,
      ),
      decoration: BoxDecoration(
        color: tokens.colors.surface2,
        borderRadius: BorderRadius.circular(m.rowRadius),
      ),
      child: Row(
        children: [
          Container(
            width: m.iconSquare,
            height: m.iconSquare,
            decoration: BoxDecoration(
              color: tokens.colors.surface,
              borderRadius: BorderRadius.circular(m.iconRadius),
            ),
            child: Center(
              child: KaiIcon(icon, size: m.iconSize, color: tokens.colors.ink1),
            ),
          ),
          SizedBox(width: m.rowInnerGap),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(label, style: m.labelStyle(tokens)),
                SizedBox(height: 1 * m.s),
                Text(hint, style: m.descStyle(tokens)),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// ─── Step 3: Context / Personalise ────────────────────────────────────────────

class _ContextStep extends StatelessWidget {
  const _ContextStep({
    required this.tokens,
    required this.l10n,
    required this.m,
  });

  final KaiTokens tokens;
  final AppLocalizations l10n;
  final _OnboardingMetrics m;

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text(
          l10n.onboardingContextTitle,
          style: m.titleStyle(tokens),
        ),
        SizedBox(height: m.titleBodyGap),
        Text(
          l10n.onboardingContextBody,
          style: m.bodyStyle(tokens),
        ),
        SizedBox(height: m.bodyContentGap),
        Text(
          l10n.onboardingContextPassportLabel.toUpperCase(),
          style: m.microStyle(tokens),
        ),
        SizedBox(height: 6 * m.s),
        Container(
          width: double.infinity,
          padding: EdgeInsets.symmetric(
            horizontal: m.rowPaddingH,
            vertical: m.rowPaddingV,
          ),
          decoration: BoxDecoration(
            color: tokens.colors.surface2,
            border: Border.all(color: tokens.colors.line),
            borderRadius: BorderRadius.circular(m.rowRadius),
          ),
          child: Row(
            children: [
              ClipRRect(
                borderRadius: BorderRadius.circular(m.flagRadius),
                child: SizedBox(
                  width: m.flagSize,
                  height: m.flagSize,
                  child: Column(
                    children: [
                      Expanded(child: Container(color: Colors.white)),
                      Expanded(
                        child: Container(
                          // canon: Russian flag red #D62718
                          color: const Color(0xFFD62718),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              SizedBox(width: 8 * m.s),
              Text(
                l10n.onboardingContextCountryPlaceholder,
                style: m.inputStyle(tokens),
              ),
            ],
          ),
        ),
        SizedBox(height: m.sectionGap),
        Text(
          l10n.onboardingContextLangsLabel.toUpperCase(),
          style: m.microStyle(tokens),
        ),
        SizedBox(height: 6 * m.s),
        Wrap(
          spacing: 8 * m.s,
          runSpacing: 8 * m.s,
          children: [
            _LangChip(label: 'English', active: true, tokens: tokens, m: m),
            _LangChip(label: 'Русский', active: true, tokens: tokens, m: m),
            _LangChip(label: 'Türkçe', active: false, tokens: tokens, m: m),
            _LangChip(label: '日本語', active: false, tokens: tokens, m: m),
          ],
        ),
      ],
    );
  }
}

class _LangChip extends StatelessWidget {
  const _LangChip({
    required this.label,
    required this.active,
    required this.tokens,
    required this.m,
  });

  final String label;
  final bool active;
  final KaiTokens tokens;
  final _OnboardingMetrics m;

  @override
  Widget build(BuildContext context) {
    final bg = active ? tokens.colors.accentWash : tokens.colors.surface2;
    final borderColor = active ? tokens.colors.accentLine : tokens.colors.line;

    return AnimatedContainer(
      duration: const Duration(milliseconds: 200),
      padding: EdgeInsets.symmetric(
        horizontal: m.chipHPadding,
        vertical: m.chipVPadding,
      ),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(999),
        border: Border.all(color: borderColor),
      ),
      child: Text(
        label,
        style: m.chipStyle(tokens, active: active),
      ),
    );
  }
}
