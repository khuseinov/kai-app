import 'package:flutter/material.dart';

import '../atoms/kai_icon.dart';
import '../theme/kai_theme.dart';
import '../tokens/kai_tokens.dart';

/// Visual severity of the alert. Source: `new-design/notifications-chat.html
/// § alert-card` (N-01).
enum AlertType { urgent, warning, positive, neutral }

/// In-feed alert card — never a takeover screen.
///
/// 2-zone layout (canon: notifications-chat.html:114-160):
///
///   .ac-head  (padding 7×11/6, type-coloured headBg, bottom-border 1px 6% black)
///     [icon-box 16×16 r5] [TYPE mono 8 w700] [spacer] [time? mono 8 ink4]
///   .ac-body  (padding 9×11/10, column gap 5)
///     [title Manrope 11.5 w600 ink1]
///     [body  Manrope 11 ink2 h1.4]
///     [cta pill? Manrope 10 w600 solid type-bg]
class AlertCard extends StatelessWidget {
  const AlertCard({
    required this.type,
    required this.title,
    this.body,
    this.time,
    this.cta,
    this.onCtaTap,
    // Legacy `action` widget kept for backward-compat; ignored in 2-zone layout.
    // Use `cta` (String) + `onCtaTap` instead.
    this.action,
    super.key,
  });

  final AlertType type;
  final String title;

  /// Optional body / description text.
  final String? body;

  /// Optional mono timestamp shown push-right in the header (e.g. "9:41").
  final String? time;

  /// Optional CTA button label. Renders as a solid pill in header accent colour.
  final String? cta;

  /// Tap handler for the CTA pill.
  final VoidCallback? onCtaTap;

  /// Legacy: ignored in 2-zone layout. Use [cta] + [onCtaTap].
  final Widget? action;

  @override
  Widget build(BuildContext context) {
    final tokens = KaiTheme.of(context);
    final c = tokens.colors;
    final palette = _palette(c, type);

    return Container(
      decoration: BoxDecoration(
        color: palette.bg,
        border: Border.all(color: palette.border, width: 1),
        borderRadius: BorderRadius.circular(14),
      ),
      clipBehavior: Clip.antiAlias,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        mainAxisSize: MainAxisSize.min,
        children: [
          _AcHead(
            type: type,
            time: time,
            palette: palette,
            ink4: c.ink4,
          ),
          _AcBody(
            title: title,
            body: body,
            cta: cta,
            onCtaTap: onCtaTap,
            palette: palette,
            ink1: c.ink1,
            ink2: c.ink2,
          ),
        ],
      ),
    );
  }

  _AlertPalette _palette(KaiColorTokens c, AlertType t) {
    switch (t) {
      case AlertType.urgent:
        return _AlertPalette(
          bg: c.negativeWash,
          border: const Color.fromRGBO(196, 74, 60, 0.18),
          headBg: const Color.fromRGBO(196, 74, 60, 0.08),
          iconBg: const Color.fromRGBO(196, 74, 60, 0.15),
          iconColor: c.negative,
          typeColor: c.negative,
          ctaBg: c.negative,
          ctaText: const Color(0xFFFFFFFF),
          typeLabel: 'URGENT',
          icon: KaiIconName.alert,
        );
      case AlertType.warning:
        return _AlertPalette(
          bg: c.warningWash,
          border: const Color.fromRGBO(181, 122, 11, 0.18),
          headBg: const Color.fromRGBO(181, 122, 11, 0.08),
          iconBg: const Color.fromRGBO(181, 122, 11, 0.15),
          iconColor: c.warning,
          typeColor: c.warning,
          ctaBg: c.warning,
          ctaText: const Color(0xFFFFFFFF),
          typeLabel: 'WARNING',
          icon: KaiIconName.alert,
        );
      case AlertType.positive:
        return _AlertPalette(
          bg: c.positiveWash,
          border: const Color.fromRGBO(27, 142, 78, 0.18),
          headBg: const Color.fromRGBO(27, 142, 78, 0.08),
          iconBg: const Color.fromRGBO(27, 142, 78, 0.15),
          iconColor: c.positive,
          typeColor: c.positive,
          ctaBg: c.positive,
          ctaText: const Color(0xFFFFFFFF),
          typeLabel: 'INFO',
          // Canon: positive alerts carry a check, not a triangle-alert.
          icon: KaiIconName.check,
        );
      case AlertType.neutral:
        // Canon: notifications-chat.html § .alert-card.neutral
        // surface-2 bg + line border + surface-3 headBg + ink-3 type/icon
        return _AlertPalette(
          bg: c.surface2,
          border: c.line,
          headBg: c.surface3,
          iconBg: c.surface2,
          iconColor: c.ink3,
          typeColor: c.ink3,
          ctaBg: c.ink1,
          ctaText: c.surface2,
          typeLabel: 'NOTE',
          // Canon: neutral alerts use an info-circle, not a warning triangle.
          icon: KaiIconName.info,
        );
    }
  }
}

// ─── Header strip (.ac-head) ─────────────────────────────────────────────────

class _AcHead extends StatelessWidget {
  const _AcHead({
    required this.type,
    required this.time,
    required this.palette,
    required this.ink4,
  });

  final AlertType type;
  final String? time;
  final _AlertPalette palette;
  final Color ink4;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(11, 7, 11, 6),
      decoration: BoxDecoration(
        color: palette.headBg,
        border: const Border(
          bottom: BorderSide(
            // Canon: rgba(0,0,0,0.06)
            color: Color.fromRGBO(0, 0, 0, 0.06),
            width: 1,
          ),
        ),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          // .ac-icon — 16×16 r5 box
          Container(
            width: 16,
            height: 16,
            decoration: BoxDecoration(
              color: palette.iconBg,
              borderRadius: BorderRadius.circular(5),
            ),
            child: Center(
              child: KaiIcon(palette.icon, size: 10, color: palette.iconColor),
            ),
          ),
          const SizedBox(width: 6),
          // .ac-type — mono 8 w700 uppercase ls 0.1em
          Text(
            palette.typeLabel,
            style: TextStyle(
              fontFamily: 'JetBrainsMono',
              fontSize: 8,
              fontWeight: FontWeight.w700,
              letterSpacing: 0.1 * 8,
              color: palette.typeColor,
            ),
          ),
          const Spacer(),
          // .ac-time — mono 8 w400 ink4 (push-right)
          if (time != null)
            Text(
              time!,
              style: TextStyle(
                fontFamily: 'JetBrainsMono',
                fontSize: 8,
                fontWeight: FontWeight.w400,
                color: ink4,
              ),
            ),
        ],
      ),
    );
  }
}

// ─── Body (.ac-body) ─────────────────────────────────────────────────────────

class _AcBody extends StatelessWidget {
  const _AcBody({
    required this.title,
    required this.body,
    required this.cta,
    required this.onCtaTap,
    required this.palette,
    required this.ink1,
    required this.ink2,
  });

  final String title;
  final String? body;
  final String? cta;
  final VoidCallback? onCtaTap;
  final _AlertPalette palette;
  final Color ink1;
  final Color ink2;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(11, 9, 11, 10),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          // .ac-title — Manrope 11.5 w600 ink1
          Text(
            title,
            style: TextStyle(
              fontFamily: 'Manrope',
              fontSize: 11.5,
              fontWeight: FontWeight.w600,
              color: ink1,
              letterSpacing: -0.008 * 11.5,
              height: 1.3,
            ),
          ),
          if (body != null) ...[
            const SizedBox(height: 5),
            // .ac-text — Manrope 11 ink2 h1.45
            Text(
              body!,
              style: TextStyle(
                fontFamily: 'Manrope',
                fontSize: 11,
                fontWeight: FontWeight.w400,
                color: ink2,
                height: 1.45,
              ),
            ),
          ],
          if (cta != null) ...[
            const SizedBox(height: 5),
            // .ac-cta — solid pill, type-specific bg
            GestureDetector(
              onTap: onCtaTap,
              child: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: 5,
                ),
                decoration: BoxDecoration(
                  color: palette.ctaBg,
                  borderRadius: BorderRadius.circular(999),
                ),
                child: Text(
                  cta!,
                  style: TextStyle(
                    fontFamily: 'Manrope',
                    fontSize: 10,
                    fontWeight: FontWeight.w600,
                    color: palette.ctaText,
                  ),
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }
}

// ─── Palette model ────────────────────────────────────────────────────────────

class _AlertPalette {
  const _AlertPalette({
    required this.bg,
    required this.border,
    required this.headBg,
    required this.iconBg,
    required this.iconColor,
    required this.typeColor,
    required this.ctaBg,
    required this.ctaText,
    required this.typeLabel,
    required this.icon,
  });

  final Color bg;
  final Color border;
  final Color headBg;
  final Color iconBg;
  final Color iconColor;
  final Color typeColor;
  final Color ctaBg;
  final Color ctaText;
  final String typeLabel;
  final KaiIconName icon;
}
