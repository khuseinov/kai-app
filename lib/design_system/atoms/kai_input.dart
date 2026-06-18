import 'package:flutter/material.dart';

import 'package:kai_app/design_system/theme/kai_theme.dart';
import 'package:kai_app/design_system/tokens/kai_tokens.dart';

// ---------------------------------------------------------------------------
// Variant enum
// ---------------------------------------------------------------------------

enum _KaiInputVariant { line, pill }

// ---------------------------------------------------------------------------
// KaiInput
// ---------------------------------------------------------------------------

/// v3 atomic text field — surface-2 fill, 1px line border, ink-1 text.
///
/// Two named constructors:
/// - [KaiInput.line] — `KaiRadius.br2` (r10). Canon: nav search box.
/// - [KaiInput.pill] — `KaiRadius.brPill`. Canon: compose-island textarea.
///
/// Both variants use the canon compact type (13.5 px, Manrope 400, lh 1.4)
/// matching `.compose textarea` in `components.html`.
///
/// Both variants pass an explicit [OutlineInputBorder] so the focused border
/// (using `lineStrong`) is driven by tokens, not Flutter defaults.
///
/// [enabled] = false → dimmed text + disabled TextField (no interaction).
class KaiInput extends StatelessWidget {
  // -------------------------------------------------------------------------
  // line
  // -------------------------------------------------------------------------

  /// Single-line (or constrained) input — br2 radius. Canon: search box.
  const KaiInput.line({
    required this.controller,
    this.placeholder,
    this.maxLines = 1,
    this.minLines,
    this.onChanged,
    this.focusNode,
    this.enabled = true,
    this.prefix,
    super.key,
  }) : _variant = _KaiInputVariant.line;

  // -------------------------------------------------------------------------
  // pill
  // -------------------------------------------------------------------------

  /// Multi-line growing input — brPill radius. Canon: compose-island textarea.
  const KaiInput.pill({
    required this.controller,
    this.placeholder,
    this.maxLines = 1,
    this.minLines,
    this.onChanged,
    this.focusNode,
    this.enabled = true,
    this.prefix,
    super.key,
  }) : _variant = _KaiInputVariant.pill;

  // -------------------------------------------------------------------------
  // Fields
  // -------------------------------------------------------------------------

  final TextEditingController controller;
  final String? placeholder;
  final int maxLines;
  final int? minLines;
  final ValueChanged<String>? onChanged;
  final FocusNode? focusNode;
  final bool enabled;
  final Widget? prefix;

  final _KaiInputVariant _variant;

  // -------------------------------------------------------------------------
  // Build
  // -------------------------------------------------------------------------

  @override
  Widget build(BuildContext context) {
    final c = KaiTheme.of(context).colors;
    final scale = context.scale;
    final textScale = context.textScale;

    final isPill = _variant == _KaiInputVariant.pill;
    final radius = isPill ? KaiRadius.brPill : KaiRadius.br2;

    // Canon compose textarea: 400 13.5px Manrope, line-height 1.4.
    // KaiType.small is 14px/400 — copyWith to 13.5px + lh 1.4 per canon.
    final textStyle = KaiType.small(
      color: enabled ? c.ink1 : c.ink4,
    ).copyWith(fontSize: 13.5 * textScale, height: 1.4);

    final hintStyle = KaiType.small(color: c.ink4)
        .copyWith(fontSize: 13.5 * textScale, height: 1.4);

    // canon: compose pill border = 0.8px solid — verified spec-viewer 2026-05-29.
    // Flutter default BorderSide.width is 1.0; use 0.8 to match exactly.
    const borderWidth = 0.8;
    final enabledBorder = OutlineInputBorder(
      borderRadius: radius,
      borderSide: BorderSide(color: c.line, width: borderWidth),
    );
    final focusedBorder = OutlineInputBorder(
      borderRadius: radius,
      borderSide: BorderSide(color: c.lineStrong, width: borderWidth),
    );
    final disabledBorder = OutlineInputBorder(
      borderRadius: radius,
      borderSide: BorderSide(color: c.line, width: borderWidth),
    );

    // Canon padding:
    //   pill (.compose): padding 5px 5px 5px 14px  → top/bottom 5, right 5, left 14
    //     approximated as: left=14, right=5, top=5, bottom=5
    //   line (search):  symmetric compact — 8px vertical, 12px horizontal
    final contentPadding = isPill
        ? EdgeInsets.only(
            left: 14 * scale, // canon: 14px left padding
            right: 5 * scale, // canon: 5px right padding
            top: 5 * scale, // canon: 5px top padding
            bottom: 5 * scale, // canon: 5px bottom padding
          )
        : EdgeInsets.symmetric(
            horizontal: KaiSpace.s3 * scale, // 12px — compact line input
            vertical: KaiSpace.s2 * scale, // 8px — compact line input
          );

    return TextField(
      controller: controller,
      focusNode: focusNode,
      maxLines: maxLines,
      minLines: minLines,
      enabled: enabled,
      style: textStyle,
      cursorColor: c.accent,
      decoration: InputDecoration(
        filled: true,
        fillColor: c.surface2,
        hintText: placeholder,
        hintStyle: hintStyle,
        contentPadding: contentPadding,
        border: enabledBorder,
        enabledBorder: enabledBorder,
        focusedBorder: focusedBorder,
        disabledBorder: disabledBorder,
        prefixIcon: prefix,
        prefixIconConstraints: prefix != null
            ? BoxConstraints(minWidth: 32 * scale, minHeight: 32 * scale)
            : null,
      ),
      onChanged: onChanged,
    );
  }
}
