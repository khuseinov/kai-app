import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../../../core/design/theme/theme_extensions.dart';
import '../../../../core/design/tokens/kai_spacing.dart';

/// Render Approve/Reject buttons for a Kai message that has
/// `pendingConfirmation == true`. Backend interprets the next chat
/// message as the user's decision; this widget just sends pre-canned text
/// matched against `_CONFIRM_YES_RE` in services/kai-core/src/api/security_scan.py.
class ApprovalActions extends StatelessWidget {
  final String? confirmationType;
  final bool isBusy;
  final VoidCallback onApprove;
  final VoidCallback onReject;

  const ApprovalActions({
    super.key,
    required this.confirmationType,
    required this.onApprove,
    required this.onReject,
    this.isBusy = false,
  });

  @override
  Widget build(BuildContext context) {
    final colors = context.kaiColors;
    final typography = context.kaiTypography;
    // In-flight guard: while a previous chat request is streaming, block
    // additional approve/reject taps. Without this a double-tap would fire
    // two parallel sendMessage calls; the second arrives after the backend
    // has already consumed the pending-confirmation key, and "да" then
    // hits the LLM as plain free-text.
    final disabledColor = colors.textSecondary.withValues(alpha: 0.4);

    return Padding(
      padding: const EdgeInsets.only(top: KaiSpacing.xs),
      child: Row(
        children: [
          _ApprovalButton(
            label: 'Подтвердить',
            icon: Icons.check_rounded,
            color: isBusy ? disabledColor : colors.oceanPrimary,
            textStyle: typography.labelMedium,
            onTap: isBusy
                ? null
                : () {
                    HapticFeedback.lightImpact();
                    onApprove();
                  },
          ),
          const SizedBox(width: KaiSpacing.s),
          _ApprovalButton(
            label: 'Отменить',
            icon: Icons.close_rounded,
            color: isBusy ? disabledColor : colors.textSecondary,
            textStyle: typography.labelMedium,
            onTap: isBusy
                ? null
                : () {
                    HapticFeedback.lightImpact();
                    onReject();
                  },
          ),
        ],
      ),
    );
  }
}

class _ApprovalButton extends StatelessWidget {
  final String label;
  final IconData icon;
  final Color color;
  final TextStyle textStyle;
  final VoidCallback? onTap;

  const _ApprovalButton({
    required this.label,
    required this.icon,
    required this.color,
    required this.textStyle,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(8),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 16, color: color),
            const SizedBox(width: 6),
            Text(label, style: textStyle.copyWith(color: color)),
          ],
        ),
      ),
    );
  }
}
