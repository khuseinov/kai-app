import 'package:flutter/material.dart';
import 'package:kai_app/design_system/atoms/atoms.dart';
import 'package:kai_app/design_system/primitives/primitives.dart';
import 'package:kai_app/design_system/theme/kai_theme.dart';
import 'package:kai_app/design_system/tokens/kai_tokens.dart';

/// Visual severity of the alert.
///
/// Source: `new-design/notifications-chat.html § alert-card` (N-01).
enum KaiAlertType { urgent, warning, positive, neutral }

/// In-feed alert card — v3 port of v2 `AlertCard` with two audit fixes:
///   1. Dead `action` widget param is dropped.
///   2. CTA is rendered as a [KaiButton] (no bespoke pill).
///
/// 2-zone layout (canon: notifications-chat.html):
/// ```
///   .ac-head  (type-coloured headBg, bottom-border 1px rgba(0,0,0,0.06))
///     [icon-box 16×16 r5] [TYPE mono 8 w700 ls 0.1em] [spacer] [time? mono 8 ink4]
///   .ac-body  (padding 9×11/10, column gap 5)
///     [title Manrope 11.5 w600 ink1]
///     [body  Manrope 11 ink2 h1.45]
///     [cta   KaiButton.ghost with tone matching type]
/// ```
///
/// CTA variant: `KaiButton.ghost` — a lightweight bordered button that sits
/// on the coloured wash without competing for primary-action weight.
/// Tone mapping: urgent/warning/positive use their semantic tone; neutral uses
/// KaiButtonTone.neutral (ink1 text + `line` border).
class KaiAlertCard extends StatelessWidget {
  const KaiAlertCard({
    required this.type,
    required this.title,
    this.body,
    this.time,
    this.cta,
    this.onCtaTap,
    super.key,
  });

  final KaiAlertType type;
  final String title;

  /// Optional body / description text.
  final String? body;

  /// Optional mono timestamp shown push-right in the header (e.g. "9:41").
  final String? time;

  /// Optional CTA button label. Renders as [KaiButton.ghost] toned to match
  /// the alert type.
  final String? cta;

  /// Tap handler for the CTA button.
  final VoidCallback? onCtaTap;

  @override
  Widget build(BuildContext context) {
    final c = KaiTheme.of(context).colors;
    final palette = _palette(c, type);

    return Container(
      decoration: BoxDecoration(
        color: palette.bg,
        border: Border.all(color: palette.border),
        // canon: 14px card corner radius (between r3=14 — matches exactly)
        borderRadius: BorderRadius.circular(KaiRadius.r3),
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
            ctaTone: palette.ctaTone,
          ),
        ],
      ),
    );
  }

  _AlertPalette _palette(KaiColorTokens c, KaiAlertType t) {
    switch (t) {
      case KaiAlertType.urgent:
        return _AlertPalette(
          bg: c.negativeWash,
          // canon: rgba(196,74,60,0.18)
          border: const Color.fromRGBO(196, 74, 60, 0.18),
          // canon: rgba(196,74,60,0.08)
          headBg: const Color.fromRGBO(196, 74, 60, 0.08),
          // canon: rgba(196,74,60,0.15)
          iconBg: const Color.fromRGBO(196, 74, 60, 0.15),
          iconColor: c.negative,
          typeColor: c.negative,
          ctaTone: KaiButtonTone.negative,
          typeLabel: 'URGENT',
          icon: KaiIconName.alert,
        );
      case KaiAlertType.warning:
        return _AlertPalette(
          bg: c.warningWash,
          // canon: rgba(181,122,11,0.18)
          border: const Color.fromRGBO(181, 122, 11, 0.18),
          // canon: rgba(181,122,11,0.08)
          headBg: const Color.fromRGBO(181, 122, 11, 0.08),
          // canon: rgba(181,122,11,0.15)
          iconBg: const Color.fromRGBO(181, 122, 11, 0.15),
          iconColor: c.warning,
          typeColor: c.warning,
          ctaTone: KaiButtonTone.warning,
          typeLabel: 'WARNING',
          icon: KaiIconName.alert,
        );
      case KaiAlertType.positive:
        return _AlertPalette(
          bg: c.positiveWash,
          // canon: rgba(27,142,78,0.18)
          border: const Color.fromRGBO(27, 142, 78, 0.18),
          // canon: rgba(27,142,78,0.08)
          headBg: const Color.fromRGBO(27, 142, 78, 0.08),
          // canon: rgba(27,142,78,0.15)
          iconBg: const Color.fromRGBO(27, 142, 78, 0.15),
          iconColor: c.positive,
          typeColor: c.positive,
          // KaiButtonTone has no `positive` — neutral gives ink-1 ghost which
          // contrasts cleanly on the positiveWash background.
          ctaTone: KaiButtonTone.neutral,
          typeLabel: 'INFO',
          // Canon: positive alerts carry a check, not a triangle-alert.
          icon: KaiIconName.check,
        );
      case KaiAlertType.neutral:
        // Canon: notifications-chat.html § .alert-card.neutral
        // surface-2 bg + line border + surface-3 headBg + ink-3 type/icon
        return _AlertPalette(
          bg: c.surface2,
          border: c.line,
          headBg: c.surface3,
          iconBg: c.surface2,
          iconColor: c.ink3,
          typeColor: c.ink3,
          ctaTone: KaiButtonTone.neutral,
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

  final KaiAlertType type;
  final String? time;
  final _AlertPalette palette;
  final Color ink4;

  @override
  Widget build(BuildContext context) {
    return Container(
      // canon: padding 7×11/6 (top 7, right 11, bottom 6, left 11)
      padding: const EdgeInsets.fromLTRB(11, 7, 11, 6),
      decoration: BoxDecoration(
        color: palette.headBg,
        border: const Border(
          bottom: BorderSide(
            // canon: rgba(0,0,0,0.06)
            color: Color.fromRGBO(0, 0, 0, 0.06),
          ),
        ),
      ),
      child: Row(
        children: [
          // .ac-icon — 16×16 r5 box
          Container(
            width: 16,
            height: 16,
            decoration: BoxDecoration(
              color: palette.iconBg,
              // canon: r5 = 5px (not a KaiRadius step; literal from HTML)
              borderRadius: BorderRadius.circular(5),
            ),
            child: Center(
              child: KaiIcon(palette.icon, size: 10, color: palette.iconColor),
            ),
          ),
          // canon: 6px gap (between s1=4 and s2=8)
          const SizedBox(width: 6),
          // .ac-type — mono 8 w700 uppercase ls 0.1em
          Text(
            palette.typeLabel,
            style: TextStyle(
              fontFamily: 'JetBrainsMono',
              fontSize: 8,
              fontWeight: FontWeight.w700,
              // canon: letterSpacing 0.1em × 8px
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
    required this.ctaTone,
  });

  final String title;
  final String? body;
  final String? cta;
  final VoidCallback? onCtaTap;
  final KaiButtonTone ctaTone;

  @override
  Widget build(BuildContext context) {
    return Padding(
      // canon: padding 9×11/10 (top 9, right 11, bottom 10, left 11)
      padding: const EdgeInsets.fromLTRB(11, 9, 11, 10),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          // .ac-title — Manrope 11.5 w600 ink1
          Text(
            title,
            style: const TextStyle(
              fontFamily: 'Manrope',
              fontSize: 11.5,
              fontWeight: FontWeight.w600,
              // canon: letterSpacing -0.008em × 11.5px
              letterSpacing: -0.008 * 11.5,
              height: 1.3,
            ),
          ),
          if (body != null) ...[
            // canon: 5px gap between title and body
            const SizedBox(height: 5),
            // .ac-text — Manrope 11 ink2 h1.45
            Text(
              body!,
              style: const TextStyle(
                fontFamily: 'Manrope',
                fontSize: 11,
                fontWeight: FontWeight.w400,
                height: 1.45,
              ),
            ),
          ],
          if (cta != null) ...[
            // canon: 5px gap before CTA
            const SizedBox(height: 5),
            // Audit fix: CTA is a KaiButton.ghost (not a bespoke pill).
            // ghost + tone gives a lightweight bordered button that sits on
            // the coloured wash without competing for primary-action weight.
            // pill: true → brPill corners matching the original rounded pill.
            Align(
              alignment: Alignment.centerLeft,
              child: KaiButton.ghost(
                label: cta!,
                onPressed: onCtaTap,
                tone: ctaTone,
                pill: true,
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
    required this.ctaTone,
    required this.typeLabel,
    required this.icon,
  });

  final Color bg;
  final Color border;
  final Color headBg;
  final Color iconBg;
  final Color iconColor;
  final Color typeColor;
  final KaiButtonTone ctaTone;
  final String typeLabel;
  final KaiIconName icon;
}
