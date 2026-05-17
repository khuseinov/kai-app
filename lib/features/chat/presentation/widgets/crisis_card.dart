// lib/features/chat/presentation/widgets/crisis_card.dart
import 'package:flutter/material.dart';

import '../../../../core/design/theme/theme_extensions.dart';
import '../../../../core/design/tokens/kai_spacing.dart';

/// Full-bleed crisis card — shown when Kai's crisis-detection fires.
/// Replaces the normal response bubble entirely.
/// Color: warm desaturated coral (calm, not alarming red).
class CrisisCard extends StatelessWidget {
  final String? category;

  const CrisisCard({super.key, this.category});

  @override
  Widget build(BuildContext context) {
    final colors = context.kaiColors;
    final typography = context.kaiTypography;
    const warmCoral = Color(0xFFC17B6B); // warmTrust token placeholder

    return Container(
      width: double.infinity,
      margin: const EdgeInsets.symmetric(
        horizontal: KaiSpacing.screenPadding,
        vertical: KaiSpacing.m,
      ),
      padding: const EdgeInsets.all(KaiSpacing.l),
      decoration: BoxDecoration(
        color: warmCoral.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: warmCoral.withValues(alpha: 0.3)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Icon(Icons.favorite_border, color: warmCoral, size: 32),
          const SizedBox(height: KaiSpacing.m),
          Text(
            'Я слышу, что вам тяжело.',
            style: typography.headlineSmall.copyWith(
              color: colors.textPrimary,
              fontWeight: FontWeight.w600,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: KaiSpacing.xs),
          Text(
            'Сейчас вам поможет:',
            style: typography.bodyLarge.copyWith(color: colors.textSecondary),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: KaiSpacing.l),
          _EmergencyButton(
            icon: Icons.phone_rounded,
            label: 'Позвонить 112',
            color: warmCoral,
            onTap: () {
              // TODO: add url_launcher to pubspec.yaml
              debugPrint('launch: tel:112');
            },
          ),
          const SizedBox(height: KaiSpacing.s),
          _EmergencyButton(
            icon: Icons.chat_bubble_outline,
            label: 'Телефон доверия: 8-800-2000-122',
            color: warmCoral,
            onTap: () {
              // TODO: add url_launcher to pubspec.yaml
              debugPrint('launch: tel:88002000122');
            },
          ),
          const SizedBox(height: KaiSpacing.l),
          Text(
            'Я остаюсь рядом. Пишите.',
            style: typography.bodyMedium.copyWith(
              color: colors.textTertiary,
              fontStyle: FontStyle.italic,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}

class _EmergencyButton extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color color;
  final VoidCallback onTap;

  const _EmergencyButton({
    required this.icon,
    required this.label,
    required this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      child: OutlinedButton.icon(
        onPressed: onTap,
        icon: Icon(icon, size: 18, color: color),
        label: Text(label),
        style: OutlinedButton.styleFrom(
          foregroundColor: color,
          side: BorderSide(color: color.withValues(alpha: 0.5)),
          padding: const EdgeInsets.symmetric(vertical: 14),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        ),
      ),
    );
  }
}
