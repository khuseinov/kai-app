import 'package:flutter/material.dart';
import 'package:kai_app/l10n/app_localizations.dart';

import '../../../design_system/theme/kai_theme.dart';
import '../../../design_system/tokens/kai_tokens.dart';
import '../../../design_system/atoms/atoms.dart';
import '../../../design_system/primitives/primitives.dart';
import 'cards/kai_care_block.dart';

/// Which edge state surface to render.
///
/// Mirrors v2 [EdgeSurface] for near-drop-in W4 migration.
enum KaiEdgeSurface {
  /// Device is offline.
  offline,

  /// A server/processing error occurred.
  error,

  /// Rate limit reached.
  rateLimit,

  /// Crisis / self-harm signal in conversation.
  crisis,
}

/// v3 composable edge-state widget.
///
/// Surfaces: [KaiEdgeSurface.offline], [KaiEdgeSurface.error],
/// [KaiEdgeSurface.rateLimit], [KaiEdgeSurface.crisis].
///
/// All buttons delegate to v3 [KaiButton] atoms — no bespoke containers.
/// Tone mapping:
///   - offline retry  → ghost, tone: warning, pill: true
///   - error retry    → ghost, tone: negative
///   - rateLimit CTA  → ghost, tone: accent, pill: true (soft upgrade prompt)
///   - crisis         → [KaiCareBlock] molecule (no button)
///
/// ZERO hardcoded colors outside tokens.
class KaiEdgeStateBlock extends StatelessWidget {
  const KaiEdgeStateBlock({
    required this.surface,
    this.onRetry,
    this.onPlans,
    this.countdown,
    super.key,
  });

  final KaiEdgeSurface surface;

  /// Used by [KaiEdgeSurface.offline] and [KaiEdgeSurface.error].
  final VoidCallback? onRetry;

  /// Used by [KaiEdgeSurface.rateLimit].
  final VoidCallback? onPlans;

  /// Optional countdown timer for [KaiEdgeSurface.rateLimit].
  final Duration? countdown;

  @override
  Widget build(BuildContext context) {
    switch (surface) {
      case KaiEdgeSurface.offline:
        return _OfflineSurface(onRetry: onRetry);
      case KaiEdgeSurface.error:
        return _ErrorSurface(onRetry: onRetry);
      case KaiEdgeSurface.rateLimit:
        return _RateLimitSurface(onPlans: onPlans, countdown: countdown);
      case KaiEdgeSurface.crisis:
        return const _CrisisSurface();
    }
  }
}

// ─── Offline ──────────────────────────────────────────────────────────────────

class _OfflineSurface extends StatelessWidget {
  const _OfflineSurface({this.onRetry});

  final VoidCallback? onRetry;

  @override
  Widget build(BuildContext context) {
    final tokens = KaiTheme.of(context);
    final c = tokens.colors;
    final l10n = AppLocalizations.of(context);
    // Canon: edge-states.html § .inline-note.warning — warning-wash bg + border.
    // padding 14×11, borderRadius 12, body 12.5px.
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 11),
      decoration: BoxDecoration(
        color: c.warningWash,
        // canon: 12px corner radius (between KaiRadius.r2=10 and r3=12; r3 matches)
        borderRadius: KaiRadius.br3,
        border: Border.all(
          color: c.warning.withValues(alpha: 0.18),
          width: 1,
        ),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              // bare icon — matches .inline-note svg pattern (no circle container)
              KaiIcon(KaiIconName.wifiOff, size: 18, color: c.warning),
              const SizedBox(width: KaiSpace.s2),
              Text(
                l10n.offlineTitle,
                style: TextStyle(
                  fontFamily: 'Manrope',
                  fontSize: 11.5,
                  fontWeight: FontWeight.w600,
                  color: c.warning,
                  letterSpacing: -0.005 * 11.5,
                ),
              ),
            ],
          ),
          const SizedBox(height: 7),
          // Body copy — 12.5px
          Text(
            l10n.offlineBody,
            style: TextStyle(
              fontFamily: 'Manrope',
              fontSize: 12.5,
              color: c.ink2,
              height: 1.45,
            ),
          ),
          const SizedBox(height: 9),
          // Retry pill — KaiButton.ghost, tone: warning, pill: true.
          // R1 audit fix: replaces bespoke GestureDetector+Container pill from v2.
          if (onRetry != null)
            KaiButton.ghost(
              onPressed: onRetry,
              label: l10n.retry,
              icon: KaiIconName.retry,
              tone: KaiButtonTone.warning,
              pill: true,
            ),
        ],
      ),
    );
  }
}

// ─── Error ────────────────────────────────────────────────────────────────────

class _ErrorSurface extends StatelessWidget {
  const _ErrorSurface({this.onRetry});

  final VoidCallback? onRetry;

  @override
  Widget build(BuildContext context) {
    final tokens = KaiTheme.of(context);
    final c = tokens.colors;
    final l10n = AppLocalizations.of(context);
    // Canon: edge-states.html § .inline-note.error
    // No internal KaiTideCurve — tide lives at the top of the screen (Zero-UI).
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 13, vertical: 11),
      decoration: BoxDecoration(
        color: c.negativeWash,
        borderRadius: KaiRadius.br3,
        border: Border.all(
          color: c.negative.withValues(alpha: 0.18),
          width: 1,
        ),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              KaiIcon(KaiIconName.alert, size: 18, color: c.negative),
              const SizedBox(width: KaiSpace.s2),
              Expanded(
                child: KaiText.body(l10n.errorTitle, color: c.ink1),
              ),
            ],
          ),
          const SizedBox(height: KaiSpace.s3),
          // KaiButton.ghost, tone: negative — R1 audit fix: v2 had KaiButton.ghost
          // but from the v2 layer; here we use the v3 KaiButton.ghost directly.
          KaiButton.ghost(
            onPressed: onRetry,
            label: l10n.retry,
            tone: KaiButtonTone.negative,
          ),
        ],
      ),
    );
  }
}

// ─── Rate limit ───────────────────────────────────────────────────────────────

class _RateLimitSurface extends StatelessWidget {
  const _RateLimitSurface({this.onPlans, this.countdown});

  final VoidCallback? onPlans;
  final Duration? countdown;

  @override
  Widget build(BuildContext context) {
    final tokens = KaiTheme.of(context);
    final c = tokens.colors;
    final l10n = AppLocalizations.of(context);
    // Canon: edge-states.html § .rate-limit — clock icon, countdown body.
    // Upgrade CTA uses tide(emphasis: glow) — money-gate glowing primary canon.
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 13, vertical: 11),
      decoration: BoxDecoration(
        color: c.warningWash,
        borderRadius: KaiRadius.br3,
        border: Border.all(
          color: c.warning.withValues(alpha: 0.18),
          width: 1,
        ),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              // clock icon — rate-limit canon (not alert)
              KaiIcon(KaiIconName.clock, size: 18, color: c.warning),
              const SizedBox(width: KaiSpace.s2),
              Expanded(
                child: Text(
                  l10n.rateLimitTitle,
                  style: TextStyle(
                    fontFamily: 'Manrope',
                    fontSize: 11.5,
                    fontWeight: FontWeight.w600,
                    color: c.warning,
                    letterSpacing: -0.005 * 11.5,
                  ),
                ),
              ),
            ],
          ),
          if (countdown != null) ...[
            const SizedBox(height: 7),
            Text(
              '${l10n.rateLimitBodyPrefix} ${l10n.rateLimitSecondsRemaining(countdown!.inSeconds)}. ${l10n.rateLimitUpgradeHint}',
              style: TextStyle(
                fontFamily: 'Manrope',
                fontSize: 11,
                color: c.ink2,
                height: 1.45,
              ),
            ),
          ],
          const SizedBox(height: 9),
          // Upgrade CTA — ghost accent pill (soft, non-alarming upgrade nudge).
          // Cycle 3 change: replaced tide(glow) with ghost(accent, pill:true)
          // so the rate-limit surface stays calm rather than drawing hero
          // attention with a gradient flash.
          KaiButton.ghost(
            onPressed: onPlans,
            label: l10n.viewPlans,
            tone: KaiButtonTone.accent,
            pill: true,
          ),
        ],
      ),
    );
  }
}

// ─── Crisis ───────────────────────────────────────────────────────────────────

class _CrisisSurface extends StatelessWidget {
  const _CrisisSurface();

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    // Canon: edge-states.html § .care-block
    // KaiCareBlock carries correct left-border + bg treatment.
    // No internal KaiTideCurve — tide lives at the top of the screen (Zero-UI).
    return KaiCareBlock(
      heading: l10n.crisisHeading,
      body: l10n.crisisBody,
      resources: [
        KaiCareResource(
          label: l10n.crisisResourceLabelPhone,
          number: l10n.crisisResourceNumberPhone,
        ),
        KaiCareResource(
          label: l10n.crisisResourceLabelText,
          number: l10n.crisisResourceNumberText,
        ),
      ],
    );
  }
}
