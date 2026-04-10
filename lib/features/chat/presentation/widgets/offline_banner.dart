import 'package:flutter/material.dart';
import '../../../../core/design/theme/theme_extensions.dart';
import '../../../../core/design/tokens/kai_spacing.dart';

/// A thin warning banner shown when the device is offline.
class OfflineBanner extends StatelessWidget {
  final bool isOffline;

  const OfflineBanner({
    super.key,
    required this.isOffline,
  });

  @override
  Widget build(BuildContext context) {
    if (!isOffline) {
      return const SizedBox.shrink();
    }

    final colors = context.kaiColors;
    final typography = context.kaiTypography;

    return Container(
      height: 40.0,
      padding: const EdgeInsets.symmetric(horizontal: KaiSpacing.m),
      decoration: BoxDecoration(
        color: colors.warning.withValues(alpha: 0.1),
        border: Border(
          bottom: BorderSide(color: colors.warning),
        ),
      ),
      child: Row(
        children: [
          Icon(
            Icons.cloud_off,
            size: 16.0,
            color: colors.warning,
          ),
          const SizedBox(width: KaiSpacing.xs),
          Expanded(
            child: Text(
              'Вы не в сети. Сообщения будут отправлены при подключении.',
              style: typography.labelMedium.copyWith(color: colors.warning),
              overflow: TextOverflow.ellipsis,
              maxLines: 1,
            ),
          ),
        ],
      ),
    );
  }
}
