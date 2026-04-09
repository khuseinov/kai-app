import 'package:flutter/material.dart';
import '../theme/theme_extensions.dart';
import '../tokens/kai_radii.dart';

class KaiCard extends StatelessWidget {
  final Widget child;
  final EdgeInsetsGeometry padding;
  final VoidCallback? onTap;
  final bool highlighted;

  const KaiCard({
    super.key,
    required this.child,
    this.padding = const EdgeInsets.all(20.0),
    this.onTap,
    this.highlighted = false,
  });

  @override
  Widget build(BuildContext context) {
    final colors = context.kaiColors;
    final shadows = context.kaiShadows;

    return Container(
      decoration: BoxDecoration(
        color: colors.surface,
        borderRadius: KaiRadii.card,
        boxShadow: highlighted ? shadows.glassGlow : shadows.soft,
        border: Border.all(color: highlighted ? colors.primary.withOpacity(0.5) : colors.glassBorder),
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: KaiRadii.card,
          child: Padding(
            padding: padding,
            child: child,
          ),
        ),
      ),
    );
  }
}
