import 'package:flutter/material.dart';
import '../theme/theme_extensions.dart';
import '../tokens/kai_spacing.dart';
import 'kai_button.dart';

/// A universal error state widget with an icon, message, and optional retry button.
class KaiErrorView extends StatelessWidget {
  final String message;
  final IconData icon;
  final VoidCallback? onRetry;
  final String? retryLabel;

  const KaiErrorView({
    super.key,
    required this.message,
    this.icon = Icons.error_outline,
    this.onRetry,
    this.retryLabel,
  });

  @override
  Widget build(BuildContext context) {
    final colors = context.kaiColors;
    final typography = context.kaiTypography;

    return Padding(
      padding: const EdgeInsets.all(KaiSpacing.screenPadding),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            icon,
            size: 64.0,
            color: colors.error,
          ),
          const SizedBox(height: KaiSpacing.m),
          Text(
            message,
            style: typography.bodyLarge.copyWith(color: colors.textSecondary),
            textAlign: TextAlign.center,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
          if (onRetry != null) ...[
            const SizedBox(height: KaiSpacing.l),
            KaiButton(
              label: retryLabel ?? 'Попробовать снова',
              type: KaiButtonType.secondary,
              onPressed: onRetry!,
            ),
          ],
        ],
      ),
    );
  }
}
