import 'package:flutter/material.dart';
import '../theme/theme_extensions.dart';

class KaiCard extends StatelessWidget {
  final Widget child;
  final EdgeInsetsGeometry padding;
  final bool highlighted;

  const KaiCard({
    super.key,
    required this.child,
    this.padding = const EdgeInsets.all(16.0),
    this.highlighted = false,
  });

  @override
  Widget build(BuildContext context) {
    final colors = context.kaiColors;

    return Container(
      padding: padding,
      decoration: BoxDecoration(
        color: highlighted
            ? colors.oceanPrimary.withValues(alpha: 0.05)
            : colors.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: highlighted ? colors.oceanPrimary : colors.cloudLight,
          width: highlighted ? 1.5 : 1.0,
        ),
      ),
      child: child,
    );
  }
}
