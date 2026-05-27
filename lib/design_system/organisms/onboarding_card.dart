import 'package:flutter/material.dart';
import 'package:kai_app/l10n/app_localizations.dart';

import '../atoms/kai_button.dart';
import '../atoms/kai_icon.dart';
import '../atoms/kai_tide_curve.dart';
import '../theme/kai_theme.dart';
import '../tokens/kai_tokens.dart';

/// 4-step onboarding — one widget per step.
///
/// Fills the parent's available space (no card wrapper / no box-shadow).
/// Layout: padded Column with step content at top, dots + CTA at bottom.
///
/// Matches `new-design/onboarding.html`:
///   `.ob { padding: 60px 22px 20px; flex:1; flex-direction:column; gap:12px; }`
///   `.ob-bottom { margin-top:auto; gap:12px; }`
class OnboardingCard extends StatelessWidget {
  const OnboardingCard({
    required this.stepIndex,
    this.onComplete,
    super.key,
  }) : assert(
          stepIndex >= 0 && stepIndex <= 3,
          'stepIndex must be 0–3',
        );

  /// 0 = welcome, 1 = tide, 2 = gestures, 3 = context.
  final int stepIndex;

  /// Called when the CTA button is tapped.
  final VoidCallback? onComplete;

  @override
  Widget build(BuildContext context) {
    final tokens = KaiTheme.of(context);
    final l10n = AppLocalizations.of(context);

    // Steps 1–3 have the tide-bar overlay above them (height ~40px from safe
    // area top).  Add extra top padding so content clears the overlay.
    // Step 0: no tide bar → tighter top gap.
    final topPad = stepIndex == 0 ? 40.0 : 60.0;

    return Padding(
      padding: EdgeInsets.fromLTRB(22, topPad, 22, 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          _buildStep(context, tokens, l10n),
          const Spacer(),
          _StepDots(count: 4, active: stepIndex),
          const SizedBox(height: 12),
          _buildCTA(l10n),
        ],
      ),
    );
  }

  Widget _buildStep(
      BuildContext context, KaiTokens tokens, AppLocalizations l10n) {
    switch (stepIndex) {
      case 0:
        return _WelcomeStep(tokens: tokens, l10n: l10n);
      case 1:
        return _TideStep(tokens: tokens, l10n: l10n);
      case 2:
        return _GesturesStep(tokens: tokens, l10n: l10n);
      case 3:
        return _ContextStep(tokens: tokens, l10n: l10n);
      default:
        return const SizedBox.shrink();
    }
  }

  Widget _buildCTA(AppLocalizations l10n) {
    final String label;
    switch (stepIndex) {
      case 1:
        label = l10n.onboardingStep1CTA; // "Понятно"
        break;
      case 3:
        label = l10n.onboardingStart; // "Начать использовать Kai"
        break;
      default:
        label = l10n.onboardingNext; // "Продолжить"
    }
    return SizedBox(
      width: double.infinity,
      child: KaiButton.ink1(onPressed: onComplete, label: label),
    );
  }
}

// ─── Step 0: Welcome ──────────────────────────────────────────────────────────

class _WelcomeStep extends StatelessWidget {
  const _WelcomeStep({required this.tokens, required this.l10n});

  final KaiTokens tokens;
  final AppLocalizations l10n;

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        // Brand glyph: 64×64 rounded rect with tide gradient + inner wave.
        // HTML: `.ob .glyph { width:64px; height:64px; border-radius:20px;
        //   background: linear-gradient(135deg, #1B4FB0, #2BA8C9, #F4B589); }`
        Container(
          width: 64,
          height: 64,
          decoration: BoxDecoration(
            gradient: KaiTide.gradient,
            borderRadius: BorderRadius.circular(20),
          ),
          child: Center(
            child: CustomPaint(
              size: const Size(36, 14),
              painter: _WavePainter(),
            ),
          ),
        ),
        const SizedBox(height: 20),
        // Title — 22px/600, ink1, center.
        Text(
          l10n.onboardingWelcomeTitle,
          style: TextStyle(
            fontFamily: 'Manrope',
            fontSize: 22,
            fontWeight: FontWeight.w600,
            height: 1.2,
            letterSpacing: 22 * -0.02,
            color: tokens.colors.ink1,
          ),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 12),
        // Body — 13px/400, ink2, center.
        Text(
          l10n.onboardingWelcomeBody,
          style: TextStyle(
            fontFamily: 'Manrope',
            fontSize: 13,
            fontWeight: FontWeight.w400,
            height: 1.5,
            color: tokens.colors.ink2,
          ),
          textAlign: TextAlign.center,
        ),
      ],
    );
  }
}

/// Paints a white sinusoidal wave — the Kai brand glyph inside the gradient
/// square.  Matches the HTML `<path d="M 2 8 Q 9 2, 18 8 T 34 5" .../>`.
class _WavePainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round
      ..strokeWidth = 2.5
      ..color = Colors.white;

    final sx = size.width / 36.0;
    final sy = size.height / 14.0;

    final path = Path()
      ..moveTo(2 * sx, 8 * sy)
      ..quadraticBezierTo(9 * sx, 2 * sy, 18 * sx, 8 * sy)
      // Reflected Q: control (9,2) reflected across (18,8) → (27,14)
      ..quadraticBezierTo(27 * sx, 14 * sy, 34 * sx, 5 * sy);

    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter old) => false;
}

// ─── Step 1: Tide ─────────────────────────────────────────────────────────────

class _TideStep extends StatelessWidget {
  const _TideStep({required this.tokens, required this.l10n});

  final KaiTokens tokens;
  final AppLocalizations l10n;

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Title
        Text(
          l10n.onboardingTideTitle,
          style: TextStyle(
            fontFamily: 'Manrope',
            fontSize: 22,
            fontWeight: FontWeight.w600,
            height: 1.2,
            letterSpacing: 22 * -0.02,
            color: tokens.colors.ink1,
          ),
        ),
        const SizedBox(height: 8),
        // Body
        Text(
          l10n.onboardingTideBody,
          style: TextStyle(
            fontFamily: 'Manrope',
            fontSize: 13,
            fontWeight: FontWeight.w400,
            height: 1.5,
            color: tokens.colors.ink2,
          ),
        ),
        const SizedBox(height: 16),
        // Tide state legend rows.
        // HTML: `.ob-tide-row { flex-direction:column; gap:10px }`
        // Each row: 40px curve demo + name (mono) + description (small mono)
        _TideStateRow(
          state: KaiTide.idle,
          name: l10n.onboardingTideStateIdleName,
          desc: l10n.onboardingTideStateIdleDesc,
          tokens: tokens,
        ),
        const SizedBox(height: 10),
        _TideStateRow(
          state: KaiTide.thinking,
          name: l10n.onboardingTideStateThinkingName,
          desc: l10n.onboardingTideStateThinkingDesc,
          tokens: tokens,
        ),
        const SizedBox(height: 10),
        _TideStateRow(
          state: KaiTide.responding,
          name: l10n.onboardingTideStateRespondingName,
          desc: l10n.onboardingTideStateRespondingDesc,
          tokens: tokens,
        ),
      ],
    );
  }
}

/// One row in the tide legend.
/// HTML: `.tide-state { grid-template-columns: 40px 1fr; gap:10px; padding: 8px 12px;
///   background:surface-2; border-radius:10px; }`
class _TideStateRow extends StatelessWidget {
  const _TideStateRow({
    required this.state,
    required this.name,
    required this.desc,
    required this.tokens,
  });

  final KaiTideState state;
  final String name;
  final String desc;
  final KaiTokens tokens;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: tokens.colors.surface2,
        borderRadius: BorderRadius.circular(10),
      ),
      child: Row(
        children: [
          // Mini tide curve — 40×8px.
          SizedBox(
            width: 40,
            height: 8,
            child: KaiTideCurve(state: state, height: 8),
          ),
          const SizedBox(width: 10),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              // State name — 11px/500 Manrope, ink1.
              Text(
                name,
                style: TextStyle(
                  fontFamily: 'Manrope',
                  fontSize: 11,
                  fontWeight: FontWeight.w500,
                  letterSpacing: 11 * -0.005,
                  color: tokens.colors.ink1,
                  height: 1.3,
                ),
              ),
              const SizedBox(height: 1),
              // Description — 9.5px mono, ink3.
              Text(
                desc,
                style: TextStyle(
                  fontFamily: 'JetBrainsMono',
                  fontSize: 9.5,
                  fontWeight: FontWeight.w400,
                  color: tokens.colors.ink3,
                  height: 1.3,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

// ─── Step 2: Gestures ─────────────────────────────────────────────────────────

class _GesturesStep extends StatelessWidget {
  const _GesturesStep({required this.tokens, required this.l10n});

  final KaiTokens tokens;
  final AppLocalizations l10n;

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Title
        Text(
          l10n.onboardingGesturesTitle,
          style: TextStyle(
            fontFamily: 'Manrope',
            fontSize: 22,
            fontWeight: FontWeight.w600,
            height: 1.2,
            letterSpacing: 22 * -0.02,
            color: tokens.colors.ink1,
          ),
        ),
        const SizedBox(height: 8),
        // Subtitle
        Text(
          l10n.onboardingGesturesBody,
          style: TextStyle(
            fontFamily: 'Manrope',
            fontSize: 13,
            fontWeight: FontWeight.w400,
            height: 1.5,
            color: tokens.colors.ink2,
          ),
        ),
        const SizedBox(height: 16),
        // Gesture cards.
        // HTML: `.ob-gestures { flex-direction:column; gap:8px }`
        _GestureRow(
          icon: KaiIconName.chevRight,
          label: l10n.onboardingGestureNavLabel,
          hint: l10n.onboardingGestureNavHint,
          tokens: tokens,
        ),
        const SizedBox(height: 8),
        _GestureRow(
          icon: KaiIconName.arrowUp,
          label: l10n.onboardingGestureInputLabel,
          hint: l10n.onboardingGestureInputHint,
          tokens: tokens,
        ),
        const SizedBox(height: 8),
        _GestureRow(
          icon: KaiIconName.menu,
          label: l10n.onboardingGestureActionsLabel,
          hint: l10n.onboardingGestureActionsHint,
          tokens: tokens,
        ),
      ],
    );
  }
}

/// One gesture row.
/// HTML: `.gest { grid-template-columns:36px 1fr; gap:10px; padding:10px 12px;
///   background:surface-2; border-radius:10px }`
/// Icon: `.gest .ic { width:36px; height:36px; border-radius:9px; background:surface }`
/// Body: `.t { 500 11px ink1 }` / `.s { 9.5px mono ink3 margin-top:1px }`
class _GestureRow extends StatelessWidget {
  const _GestureRow({
    required this.icon,
    required this.label,
    required this.hint,
    required this.tokens,
  });

  final KaiIconName icon;
  final String label;
  final String hint;
  final KaiTokens tokens;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: BoxDecoration(
        color: tokens.colors.surface2,
        borderRadius: BorderRadius.circular(10),
      ),
      child: Row(
        children: [
          // Icon square: 36×36, radius 9, surface background.
          Container(
            width: 36,
            height: 36,
            decoration: BoxDecoration(
              color: tokens.colors.surface,
              borderRadius: BorderRadius.circular(9),
            ),
            child: Center(
              child: KaiIcon(icon, size: 18, color: tokens.colors.ink1),
            ),
          ),
          const SizedBox(width: 10),
          // Label + hint stacked.
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                // Label — bold, ink1.
                Text(
                  label,
                  style: TextStyle(
                    fontFamily: 'Manrope',
                    fontSize: 11,
                    fontWeight: FontWeight.w500,
                    letterSpacing: 11 * -0.005,
                    color: tokens.colors.ink1,
                    height: 1.3,
                  ),
                ),
                const SizedBox(height: 1),
                // Hint — mono, ink3.
                Text(
                  hint,
                  style: TextStyle(
                    fontFamily: 'JetBrainsMono',
                    fontSize: 9.5,
                    fontWeight: FontWeight.w400,
                    color: tokens.colors.ink3,
                    height: 1.3,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// ─── Step 3: Context / Personalise ───────────────────────────────────────────

class _ContextStep extends StatelessWidget {
  const _ContextStep({required this.tokens, required this.l10n});

  final KaiTokens tokens;
  final AppLocalizations l10n;

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Title — multi-line.
        Text(
          l10n.onboardingContextTitle,
          style: TextStyle(
            fontFamily: 'Manrope',
            fontSize: 22,
            fontWeight: FontWeight.w600,
            height: 1.2,
            letterSpacing: 22 * -0.02,
            color: tokens.colors.ink1,
          ),
        ),
        const SizedBox(height: 8),
        // Body.
        Text(
          l10n.onboardingContextBody,
          style: TextStyle(
            fontFamily: 'Manrope',
            fontSize: 13,
            fontWeight: FontWeight.w400,
            height: 1.5,
            color: tokens.colors.ink2,
          ),
        ),
        const SizedBox(height: 16),
        // ── Passport section ─────────────────────────────────────────────────
        // HTML: `.label { 500 10px mono ink3 uppercase letter-spacing:0.08em }`
        Text(
          l10n.onboardingContextPassportLabel.toUpperCase(),
          style: TextStyle(
            fontFamily: 'JetBrainsMono',
            fontSize: 10,
            fontWeight: FontWeight.w500,
            color: tokens.colors.ink3,
            letterSpacing: 10 * 0.08,
            height: 1.4,
          ),
        ),
        const SizedBox(height: 6),
        // Passport input row: flag + country name.
        // HTML: `.input { surface-2 bg; 1px line border; border-radius:10px; padding:10px 12px }`
        Container(
          width: double.infinity,
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
          decoration: BoxDecoration(
            color: tokens.colors.surface2,
            border: Border.all(color: tokens.colors.line, width: 1),
            borderRadius: BorderRadius.circular(10),
          ),
          child: Row(
            children: [
              // Russian flag: 14×14 rounded rect, red/white split.
              // HTML: `.flag { width:14px; height:14px; border-radius:3px;
              //   background: linear-gradient(0deg, #D62718 50%, #FFFFFF 50%) }`
              ClipRRect(
                borderRadius: BorderRadius.circular(3),
                child: SizedBox(
                  width: 14,
                  height: 14,
                  child: Column(
                    children: [
                      Expanded(child: Container(color: Colors.white)),
                      Expanded(child: Container(color: const Color(0xFFD62718))),
                    ],
                  ),
                ),
              ),
              const SizedBox(width: 8),
              Text(
                l10n.onboardingContextCountryPlaceholder,
                style: TextStyle(
                  fontFamily: 'Manrope',
                  fontSize: 12,
                  fontWeight: FontWeight.w400,
                  color: tokens.colors.ink1,
                  height: 1.4,
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 10),
        // ── Languages section ────────────────────────────────────────────────
        Text(
          l10n.onboardingContextLangsLabel.toUpperCase(),
          style: TextStyle(
            fontFamily: 'JetBrainsMono',
            fontSize: 10,
            fontWeight: FontWeight.w500,
            color: tokens.colors.ink3,
            letterSpacing: 10 * 0.08,
            height: 1.4,
          ),
        ),
        const SizedBox(height: 6),
        // 4 language chips: English + Русский active, Türkçe + 日本語 inactive.
        // HTML: `.chip.active { color:accent; bg:accent-wash; border:accent-line }`
        Wrap(
          spacing: 6,
          runSpacing: 6,
          children: [
            _LangChip(label: 'English', active: true, tokens: tokens),
            _LangChip(label: 'Русский', active: true, tokens: tokens),
            _LangChip(label: 'Türkçe', active: false, tokens: tokens),
            _LangChip(label: '日本語', active: false, tokens: tokens),
          ],
        ),
      ],
    );
  }
}

/// Language selection chip.
/// HTML active: `color:accent; bg:accent-wash; border:accent-line`
/// HTML inactive: `color:ink-2; bg:surface-2; border:line`
class _LangChip extends StatelessWidget {
  const _LangChip({
    required this.label,
    required this.active,
    required this.tokens,
  });

  final String label;
  final bool active;
  final KaiTokens tokens;

  @override
  Widget build(BuildContext context) {
    final bg = active ? tokens.colors.accentWash : tokens.colors.surface2;
    final textColor = active ? tokens.colors.accent : tokens.colors.ink2;
    final borderColor = active ? tokens.colors.accentLine : tokens.colors.line;

    return AnimatedContainer(
      duration: const Duration(milliseconds: 200),
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(999),
        border: Border.all(color: borderColor, width: 1),
      ),
      child: Text(
        label,
        style: TextStyle(
          fontFamily: 'Manrope',
          fontSize: 11,
          fontWeight: FontWeight.w500,
          letterSpacing: 11 * -0.005,
          color: textColor,
          height: 1.3,
        ),
      ),
    );
  }
}

// ─── Dots indicator ───────────────────────────────────────────────────────────

/// Step progress dots matching `new-design/onboarding.html`:
///   `.d { width:6px; height:6px; border-radius:50%; background:ink-4 }`
///   `.d.active { background:ink-1; width:16px; border-radius:999px }` ← pill.
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
          width: isActive ? 16 : 6,
          height: 6,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(isActive ? 999 : 3),
            color: isActive ? tokens.colors.ink1 : tokens.colors.ink4,
          ),
        );
      }),
    );
  }
}
