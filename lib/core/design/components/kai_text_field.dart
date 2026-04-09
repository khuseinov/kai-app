import 'package:flutter/material.dart';
import '../theme/theme_extensions.dart';
import '../tokens/kai_radii.dart';

class KaiTextField extends StatelessWidget {
  final String hintText;
  final TextEditingController? controller;
  final bool obscureText;
  final Widget? prefixIcon;
  final Widget? suffixIcon;
  final ValueChanged<String>? onChanged;

  const KaiTextField({
    super.key,
    required this.hintText,
    this.controller,
    this.obscureText = false,
    this.prefixIcon,
    this.suffixIcon,
    this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    final colors = context.kaiColors;
    final typography = context.kaiTypography;

    return TextField(
      controller: controller,
      obscureText: obscureText,
      onChanged: onChanged,
      style: typography.bodyLarge,
      decoration: InputDecoration(
        hintText: hintText,
        hintStyle: typography.bodyLarge.copyWith(color: colors.textSecondary),
        prefixIcon: prefixIcon,
        suffixIcon: suffixIcon,
        filled: true,
        fillColor: colors.surface,
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
        border: OutlineInputBorder(
          borderRadius: KaiRadii.button,
          borderSide: BorderSide(color: colors.glassBorder),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: KaiRadii.button,
          borderSide: BorderSide(color: colors.glassBorder),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: KaiRadii.button,
          borderSide: BorderSide(color: colors.primary, width: 2),
        ),
      ),
    );
  }
}
