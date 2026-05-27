import 'package:flutter/material.dart';

import '../atoms/kai_icon.dart';
import '../atoms/kai_text.dart';
import '../theme/kai_theme.dart';
import '../tokens/kai_tokens.dart';

/// Visual severity of the alert. Source: `new-design/notifications-chat.html
/// § alert-card` (N-01).
enum AlertType { urgent, warning, positive, neutral }

/// In-feed alert card — never a takeover screen.
///
/// Background uses the type-derived wash; the leading icon picks up the
/// matching semantic colour (negative / warning / positive / accent).
///
/// Layout:
///
///   [icon] [title]
///   [body]
///   [action]
class AlertCard extends StatelessWidget {
  const AlertCard({
    required this.type,
    required this.title,
    this.body,
    this.action,
    super.key,
  });

  final AlertType type;
  final String title;

  /// Optional body / description. Renders in [KaiText.small].
  final String? body;

  /// Optional trailing action — typically a [KaiButton.ghost] or chip.
  final Widget? action;

  @override
  Widget build(BuildContext context) {
    final tokens = KaiTheme.of(context);
    final c = tokens.colors;
    final palette = _palette(c, type);

    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: palette.background,
        // Canon: notifications-chat.html N-01 uses border-radius: 12px;
        // closest token is br3 (r3 = 14).
        borderRadius: KaiRadius.br3,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              KaiIcon(KaiIconName.alert, size: 18, color: palette.accent),
              const SizedBox(width: KaiSpace.s2),
              Expanded(child: KaiText.h3(title)),
            ],
          ),
          if (body != null) ...[
            const SizedBox(height: KaiSpace.s2),
            KaiText.small(body!, color: c.ink2),
          ],
          if (action != null) ...[
            const SizedBox(height: KaiSpace.s3),
            Align(
              alignment: Alignment.centerLeft,
              child: action!,
            ),
          ],
        ],
      ),
    );
  }

  _AlertPalette _palette(KaiColorTokens c, AlertType t) {
    switch (t) {
      case AlertType.urgent:
        return _AlertPalette(background: c.negativeWash, accent: c.negative);
      case AlertType.warning:
        return _AlertPalette(background: c.warningWash, accent: c.warning);
      case AlertType.positive:
        return _AlertPalette(background: c.positiveWash, accent: c.positive);
      case AlertType.neutral:
        return _AlertPalette(background: c.accentWash, accent: c.accent);
    }
  }
}

class _AlertPalette {
  const _AlertPalette({required this.background, required this.accent});
  final Color background;
  final Color accent;
}
