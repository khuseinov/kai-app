import 'package:flutter/material.dart';

import '../../../../core/design/theme/theme_extensions.dart';
import '../../../../core/design/tokens/kai_spacing.dart';

/// APP-ASYNC-1: Async task progress card (CC-8).
///
/// Shown in the message list while POST /chat/async is polling.
/// States: pending (spinner + elapsed), done (hidden — normal message renders),
/// failed (error card with message).
enum AsyncTaskState { pending, failed }

class AsyncProgressCard extends StatelessWidget {
  final AsyncTaskState state;
  final double elapsedSeconds;
  final String? errorMessage;
  final VoidCallback? onCancel;

  const AsyncProgressCard({
    super.key,
    this.state = AsyncTaskState.pending,
    this.elapsedSeconds = 0,
    this.errorMessage,
    this.onCancel,
  });

  @override
  Widget build(BuildContext context) {
    final colors = context.kaiColors;
    final typography = context.kaiTypography;

    if (state == AsyncTaskState.failed) {
      return Container(
        margin: const EdgeInsets.symmetric(
          horizontal: KaiSpacing.screenPadding,
          vertical: KaiSpacing.xxs,
        ),
        padding: const EdgeInsets.all(KaiSpacing.s),
        decoration: BoxDecoration(
          color: colors.error.withValues(alpha: 0.08),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: colors.error.withValues(alpha: 0.35)),
        ),
        child: Row(
          children: [
            Icon(Icons.error_outline, color: colors.error, size: 18),
            const SizedBox(width: KaiSpacing.xs),
            Expanded(
              child: Text(
                errorMessage ?? 'Kai не смог выполнить запрос',
                style: typography.bodySmall.copyWith(color: colors.error),
              ),
            ),
          ],
        ),
      );
    }

    // Pending state
    final elapsed = elapsedSeconds.toInt();
    final elapsedLabel = elapsed > 0 ? ' · ${elapsed}с' : '';

    return Container(
      margin: const EdgeInsets.symmetric(
        horizontal: KaiSpacing.screenPadding,
        vertical: KaiSpacing.xxs,
      ),
      padding: const EdgeInsets.symmetric(
        horizontal: KaiSpacing.s,
        vertical: KaiSpacing.xs,
      ),
      decoration: BoxDecoration(
        color: colors.surfaceContainer,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: colors.glassBorder),
      ),
      child: Row(
        children: [
          SizedBox(
            width: 16,
            height: 16,
            child: CircularProgressIndicator(
              strokeWidth: 2,
              color: colors.oceanPrimary,
            ),
          ),
          const SizedBox(width: KaiSpacing.xs),
          Expanded(
            child: Text(
              'Kai думает…$elapsedLabel',
              style: typography.bodySmall.copyWith(
                color: colors.textSecondary,
              ),
            ),
          ),
          if (onCancel != null)
            TextButton(
              onPressed: onCancel,
              style: TextButton.styleFrom(
                minimumSize: Size.zero,
                padding: const EdgeInsets.symmetric(
                  horizontal: KaiSpacing.xs,
                  vertical: KaiSpacing.xxxs,
                ),
                tapTargetSize: MaterialTapTargetSize.shrinkWrap,
              ),
              child: Text(
                'Отменить',
                style: typography.labelSmall.copyWith(
                  color: colors.textTertiary,
                ),
              ),
            ),
        ],
      ),
    );
  }
}
