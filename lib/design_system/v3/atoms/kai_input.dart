import 'package:flutter/material.dart';

import '../../theme/kai_theme.dart';
import '../../tokens/kai_tokens.dart';

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

  final _KaiInputVariant _variant;

  // -------------------------------------------------------------------------
  // Build
  // -------------------------------------------------------------------------

  @override
  Widget build(BuildContext context) {
    final c = KaiTheme.of(context).colors;

    final radius =
        _variant == _KaiInputVariant.pill ? KaiRadius.brPill : KaiRadius.br2;

    final textStyle = KaiType.body(
      color: enabled ? c.ink1 : c.ink4,
    );
    final hintStyle = KaiType.body(color: c.ink4);

    final enabledBorder = OutlineInputBorder(
      borderRadius: radius,
      borderSide: BorderSide(color: c.line),
    );
    final focusedBorder = OutlineInputBorder(
      borderRadius: radius,
      borderSide: BorderSide(color: c.lineStrong),
    );
    final disabledBorder = OutlineInputBorder(
      borderRadius: radius,
      borderSide: BorderSide(color: c.line),
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
        contentPadding: const EdgeInsets.symmetric(
          horizontal: KaiSpace.s3,
          vertical: KaiSpace.s2,
        ),
        border: enabledBorder,
        enabledBorder: enabledBorder,
        focusedBorder: focusedBorder,
        disabledBorder: disabledBorder,
      ),
      onChanged: onChanged,
    );
  }
}
