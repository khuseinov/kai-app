import 'package:flutter/material.dart';

import 'package:kai_app/design_system/theme/kai_theme.dart';
import 'package:kai_app/design_system/tokens/kai_tokens.dart';

/// Size variants for [KaiChip].
///
/// - [sm] — label 11px / w500 (compact status indicators, tight contexts).
/// - [md] — current default sizing.
enum KaiChipSize {
  /// Compact: JetBrains Mono 11px / w500 for status; Manrope 12px for choice.
  sm,

  /// Default: JetBrains Mono 12px for status; Manrope 14px for choice.
  md,
}

/// Tone variants for [KaiChip.status].
enum KaiChipTone {
  /// No semantic state — muted border + ink3 text, no background fill.
  neutral,

  /// Completed / positive — positiveWash bg + positive text/border.
  done,

  /// Currently active / live — accentWash bg + accent text/border.
  active,

  /// Semantic positive state — positiveWash bg + positive text/border.
  positive,

  /// Semantic warning state — warningWash bg + warning text/border.
  warning,

  /// Semantic negative state — negativeWash bg + negative text/border.
  negative,
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
  /// - [KaiChipTone.neutral]  → ink3 text, `line` border, no fill.
  /// - [KaiChipTone.done]     → positive text, positiveWash fill, positive border.
  /// - [KaiChipTone.active]   → accent text, accentWash fill, accentLine border.
  /// - [KaiChipTone.positive] → positive text, positiveWash fill, positive border.
  /// - [KaiChipTone.warning]  → warning text, warningWash fill, warning border.
  /// - [KaiChipTone.negative] → negative text, negativeWash fill, negative border.
  ///
  /// [size] controls label sizing (default [KaiChipSize.md]).
  const KaiChip.status(
    String label, {
    KaiChipTone tone = KaiChipTone.neutral,
    KaiChipSize size = KaiChipSize.md,
    super.key,
  })  : _label = label,
        _tone = tone,
        _size = size,
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
  /// [size] controls label sizing (default [KaiChipSize.md]).
  const KaiChip.choice(
    String label, {
    required bool selected,
    VoidCallback? onTap,
    KaiChipSize size = KaiChipSize.md,
    super.key,
  })  : _label = label,
        _tone = KaiChipTone.neutral, // unused for choice
        _size = size,
        _selected = selected,
        _onTap = onTap,
        _variant = _KaiChipVariant.choice;

  // ---------------------------------------------------------------------------
  // Fields
  // ---------------------------------------------------------------------------

  final String _label;
  final KaiChipTone _tone;
  final KaiChipSize _size;
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
      case KaiChipTone.positive:
        textColor = c.positive;
        bgColor = c.positiveWash;
        borderColor = c.positive;
      case KaiChipTone.warning:
        textColor = c.warning;
        bgColor = c.warningWash;
        borderColor = c.warning;
      case KaiChipTone.negative:
        textColor = c.negative;
        bgColor = c.negativeWash;
        borderColor = c.negative;
    }

    // sm: 11px / w500; md: 12px / w400 (mono default)
    final textStyle = _size == KaiChipSize.sm
        ? KaiType.mono(color: textColor).copyWith(
            fontSize: 11,
            fontWeight: FontWeight.w500,
          )
        : KaiType.mono(color: textColor);

    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: KaiSpace.s3,
        vertical: KaiSpace.s1,
      ),
      decoration: BoxDecoration(
        color: bgColor,
        border: Border.all(color: borderColor),
        borderRadius: KaiRadius.brPill,
      ),
      child: Text(
        _label.toUpperCase(),
        style: textStyle,
      ),
    );
  }

  Widget _buildChoice(BuildContext context) {
    final c = KaiTheme.of(context).colors;

    final textColor = _selected ? c.ink1 : c.ink3;
    final bgColor = _selected ? c.surface : null;

    // sm: 12px; md: 14px (small default)
    final textStyle = _size == KaiChipSize.sm
        ? KaiType.small(color: textColor).copyWith(fontSize: 12)
        : KaiType.small(color: textColor);

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
        style: textStyle,
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
