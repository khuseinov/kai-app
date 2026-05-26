import 'package:flutter/material.dart';

import '../theme/kai_theme.dart';
import '../tokens/kai_tokens.dart';

/// Atomic text field — surface-2 fill, ink-1 text, ink-4 placeholder.
///
/// Pill mode flips the radius for inline composer/search use.
class KaiTextField extends StatelessWidget {
  const KaiTextField({
    required this.controller,
    this.placeholder,
    this.maxLines = 1,
    this.pillRadius = false,
    this.focusNode,
    this.onChanged,
    this.onSubmitted,
    super.key,
  });

  final TextEditingController controller;
  final String? placeholder;
  final int maxLines;
  final bool pillRadius;
  final FocusNode? focusNode;
  final ValueChanged<String>? onChanged;
  final ValueChanged<String>? onSubmitted;

  @override
  Widget build(BuildContext context) {
    final tokens = KaiTheme.of(context);
    final c = tokens.colors;
    final radius =
        pillRadius ? KaiRadius.brPill : KaiRadius.br2;
    final textStyle = KaiType.body(color: c.ink1);
    final placeholderStyle = KaiType.body(color: c.ink4);

    return Container(
      decoration: BoxDecoration(
        color: c.surface2,
        borderRadius: radius,
      ),
      padding: const EdgeInsets.symmetric(
        vertical: KaiSpace.s3,
        horizontal: KaiSpace.s4,
      ),
      child: TextField(
        controller: controller,
        focusNode: focusNode,
        maxLines: maxLines,
        minLines: 1,
        style: textStyle,
        cursorColor: c.accent,
        decoration: InputDecoration(
          isCollapsed: true,
          hintText: placeholder,
          hintStyle: placeholderStyle,
          border: InputBorder.none,
          enabledBorder: InputBorder.none,
          focusedBorder: InputBorder.none,
        ),
        onChanged: onChanged,
        onSubmitted: onSubmitted,
      ),
    );
  }
}
