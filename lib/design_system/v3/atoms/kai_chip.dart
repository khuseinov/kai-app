import 'package:flutter/material.dart';

import '../../theme/kai_theme.dart';
import '../../tokens/kai_tokens.dart';

/// Tone variants for [KaiChip.status].
enum KaiChipTone {
  /// No semantic state — muted border + ink3 text, no background fill.
  neutral,

  /// Completed / positive — positiveWash bg + positive text/border.
  done,

  /// Currently active / live — accentWash bg + accent text/border.
  active,
}

/// v3 chip atom. Two named constructors:
///
/// - [KaiChip.status] — non-interactive status pill. Uses JetBrains Mono 12px,
///   uppercased label, 1px border, pill radius. Tone controls color scheme.
/// - [KaiChip.choice] — selectable filter chip. Manrope 14px small, no uppercase
///   transform. Selected: surface bg + ink1 text. Unselected: transparent + ink3.
///   Optionally tappable via [onTap].
class KaiChip extends StatelessWidget {
  // ---------------------------------------------------------------------------
  // Status constructor
  // ---------------------------------------------------------------------------

  /// Non-interactive status pill with a mono-uppercase label.
  ///
  /// [tone] controls the color scheme:
  /// - [KaiChipTone.neutral] → ink3 text, `line` border, no fill.
  /// - [KaiChipTone.done]    → positive text, positiveWash fill, positive border.
  /// - [KaiChipTone.active]  → accent text, accentWash fill, accentLine border.
  const KaiChip.status(
    String label, {
    KaiChipTone tone = KaiChipTone.neutral,
    super.key,
  })  : _label = label,
        _tone = tone,
        _selected = false,
        _onTap = null,
        _variant = _KaiChipVariant.status;

  // ---------------------------------------------------------------------------
  // Choice constructor
  // ---------------------------------------------------------------------------

  /// Selectable filter/segment chip. Label preserves original casing.
  ///
  /// [selected] controls background and text color.
  /// [onTap] is optional — pass null for a static (non-interactive) chip.
  const KaiChip.choice(
    String label, {
    required bool selected,
    VoidCallback? onTap,
    super.key,
  })  : _label = label,
        _tone = KaiChipTone.neutral, // unused for choice
        _selected = selected,
        _onTap = onTap,
        _variant = _KaiChipVariant.choice;

  // ---------------------------------------------------------------------------
  // Fields
  // ---------------------------------------------------------------------------

  final String _label;
  final KaiChipTone _tone;
  final bool _selected;
  final VoidCallback? _onTap;
  final _KaiChipVariant _variant;

  // ---------------------------------------------------------------------------
  // Build
  // ---------------------------------------------------------------------------

  @override
  Widget build(BuildContext context) {
    switch (_variant) {
      case _KaiChipVariant.status:
        return _buildStatus(context);
      case _KaiChipVariant.choice:
        return _buildChoice(context);
    }
  }

  Widget _buildStatus(BuildContext context) {
    final c = KaiTheme.of(context).colors;

    final Color textColor;
    final Color? bgColor;
    final Color borderColor;

    switch (_tone) {
      case KaiChipTone.neutral:
        textColor = c.ink3;
        bgColor = null; // transparent
        borderColor = c.line;
      case KaiChipTone.done:
        textColor = c.positive;
        bgColor = c.positiveWash;
        borderColor = c.positive;
      case KaiChipTone.active:
        textColor = c.accent;
        bgColor = c.accentWash;
        borderColor = c.accentLine;
    }

    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: KaiSpace.s3,
        vertical: KaiSpace.s1,
      ),
      decoration: BoxDecoration(
        color: bgColor,
        border: Border.all(color: borderColor, width: 1),
        borderRadius: KaiRadius.brPill,
      ),
      child: Text(
        _label.toUpperCase(),
        style: KaiType.mono(color: textColor),
      ),
    );
  }

  Widget _buildChoice(BuildContext context) {
    final c = KaiTheme.of(context).colors;

    final textColor = _selected ? c.ink1 : c.ink3;
    final bgColor = _selected ? c.surface : null;

    Widget chip = AnimatedContainer(
      duration: KaiMotion.micro,
      curve: KaiMotion.standardCurve,
      padding: const EdgeInsets.symmetric(
        horizontal: KaiSpace.s3,
        vertical: KaiSpace.s1,
      ),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: KaiRadius.brPill,
      ),
      child: Text(
        _label,
        style: KaiType.small(color: textColor),
      ),
    );

    if (_onTap != null) {
      chip = GestureDetector(
        onTap: _onTap,
        behavior: HitTestBehavior.opaque,
        child: chip,
      );
    }

    return chip;
  }
}

enum _KaiChipVariant { status, choice }
