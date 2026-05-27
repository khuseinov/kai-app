import 'package:flutter/material.dart';
import 'package:kai_app/l10n/app_localizations.dart';

import '../atoms/kai_button.dart';
import '../atoms/kai_icon.dart';
import '../atoms/kai_text.dart';
import '../molecules/care_block.dart';
import '../theme/kai_theme.dart';
import '../tokens/kai_tokens.dart';

/// Which edge state surface to render.
enum EdgeSurface {
  /// Device is offline.
  offline,

  /// A server/processing error occurred.
  error,

  /// Rate limit reached.
  rateLimit,

  /// Crisis / self-harm signal in conversation.
  crisis,
}

/// Composable edge-state widget.
///
/// Surfaces: [EdgeSurface.offline], [EdgeSurface.error],
/// [EdgeSurface.rateLimit], [EdgeSurface.crisis].
class EdgeStateBlock extends StatelessWidget {
  const EdgeStateBlock({
    required this.surface,
    this.onRetry,
    this.onPlans,
    this.countdown,
    super.key,
  });

  final EdgeSurface surface;

  /// Used by [EdgeSurface.offline] and [EdgeSurface.error].
  final VoidCallback? onRetry;

  /// Used by [EdgeSurface.rateLimit].
  final VoidCallback? onPlans;

  /// Optional countdown timer for [EdgeSurface.rateLimit].
  final Duration? countdown;

  @override
  Widget build(BuildContext context) {
    switch (surface) {
      case EdgeSurface.offline:
        return _OfflineSurface(onRetry: onRetry);
      case EdgeSurface.error:
        return _ErrorSurface(onRetry: onRetry);
      case EdgeSurface.rateLimit:
        return _RateLimitSurface(onPlans: onPlans, countdown: countdown);
      case EdgeSurface.crisis:
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
    // Canon: edge-states.html § .inline-note.warning — warning-wash bg + border
    // H3: padding 14×11, borderRadius 12, body 12.5px (was 13×11, KaiRadius.br3, 11px)
    // H4: bare wifi-off icon, no circle wrapper (matches .inline-note bare svg)
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 11),
      decoration: BoxDecoration(
        color: c.warningWash,
        borderRadius: BorderRadius.circular(12),
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
              // H4: bare icon, no circle container — matches .inline-note svg pattern
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
          // Body copy — H3: 12.5px (was 11px)
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
          // Retry pill — ghost border in warning color
          if (onRetry != null)
            GestureDetector(
              onTap: onRetry,
              child: Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 11, vertical: 5),
                decoration: BoxDecoration(
                  color: Colors.transparent,
                  border: Border.all(
                    color: c.warning.withValues(alpha: 0.25),
                    width: 1,
                  ),
                  borderRadius: KaiRadius.brPill,
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    KaiIcon(KaiIconName.retry, size: 12, color: c.warning),
                    const SizedBox(width: 4),
                    Text(
                      l10n.retry,
                      style: TextStyle(
                        fontFamily: 'Manrope',
                        fontSize: 10.5,
                        fontWeight: FontWeight.w500,
                        color: c.warning,
                      ),
                    ),
                  ],
                ),
              ),
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
          KaiButton.ghost(onPressed: onRetry, label: l10n.retry),
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
    // Canon: edge-states.html § .rate-limit — clock icon (not alert), countdown body
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
              // clock icon — canon change from alert to clock
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
          KaiButton.ghost(
            onPressed: onPlans,
            label: l10n.viewPlans,
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
    // Canon: edge-states.html § .care-block — left-border 2px negative, rgba(196,74,60,0.04) bg.
    // CareBlock itself carries the correct left-border + bg treatment.
    // No internal KaiTideCurve — tide lives at the top of the screen (Zero-UI).
    return CareBlock(
      heading: l10n.crisisHeading,
      body: l10n.crisisBody,
      resources: [
        CareResource(
          label: l10n.crisisResourceLabelPhone,
          number: l10n.crisisResourceNumberPhone,
        ),
        CareResource(
          label: l10n.crisisResourceLabelText,
          number: l10n.crisisResourceNumberText,
        ),
      ],
    );
  }
}
