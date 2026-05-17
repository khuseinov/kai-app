import 'package:flutter/material.dart';
import '../../../../core/design/theme/theme_extensions.dart';
import '../../../../core/design/tokens/kai_spacing.dart';

/// APP-SIM-CARD-1: structured S-loop simulation preview card.
/// Shown when special_mode="S" and content contains `[S-LOOP` marker.
///
/// Parses backend format:
///   Simulation: {action} -> heuristic success estimate X%, heuristic
///   expected cost $Y (Z p95), risks {level}: {breakdown}.
///   Recommendation: {text}. Proceed?
class SimulationCard extends StatelessWidget {
  final String sloopText;

  const SimulationCard({super.key, required this.sloopText});

  static final _successRe = RegExp(r'success estimate\s+([\d.]+%)');
  static final _costRe = RegExp(r'expected cost\s+\$([0-9.,]+)');
  static final _p95Re = RegExp(r'\(\$([0-9.,]+)\s+p95\)');
  static final _riskLevelRe = RegExp(r'risks\s+(low|medium|high|extreme)\s*:');
  static final _risksBodyRe =
      RegExp(r'risks\s+(?:low|medium|high|extreme)\s*:\s*([^.]+)\.');
  static final _recommendationRe = RegExp(r'Recommendation:\s*([^.]+)\.');

  static ({
    bool isHeuristic,
    String? successRate,
    String? cost,
    String? costP95,
    String? riskLevel,
    String? risksBreakdown,
    String? recommendation,
  }) _parse(String text) {
    final isHeuristic = text.contains('[S-LOOP HEURISTIC');
    return (
      isHeuristic: isHeuristic,
      successRate: _successRe.firstMatch(text)?.group(1),
      cost: _costRe.firstMatch(text)?.group(1),
      costP95: _p95Re.firstMatch(text)?.group(1),
      riskLevel: _riskLevelRe.firstMatch(text)?.group(1),
      risksBreakdown: _risksBodyRe.firstMatch(text)?.group(1)?.trim(),
      recommendation: _recommendationRe.firstMatch(text)?.group(1)?.trim(),
    );
  }

  static (Color, IconData) _riskStyle(String? level, dynamic colors) {
    return switch (level?.toLowerCase()) {
      'low' => (colors.success as Color, Icons.check_circle_outline),
      'medium' => (colors.warning as Color, Icons.warning_amber_outlined),
      'high' => (colors.error as Color, Icons.dangerous_outlined),
      'extreme' => (colors.error as Color, Icons.emergency_outlined),
      _ => (colors.textTertiary as Color, Icons.help_outline),
    };
  }

  static String _riskLabel(String? level) => switch (level?.toLowerCase()) {
        'low' => 'низкий',
        'medium' => 'средний',
        'high' => 'высокий',
        'extreme' => 'критический',
        _ => level ?? '—',
      };

  @override
  Widget build(BuildContext context) {
    final colors = context.kaiColors;
    final typography = context.kaiTypography;
    final p = _parse(sloopText);
    final (riskColor, riskIcon) = _riskStyle(p.riskLevel, colors);

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: colors.stateThinking.withValues(alpha: 0.06),
        borderRadius: BorderRadius.circular(10),
        border:
            Border.all(color: colors.stateThinking.withValues(alpha: 0.30)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.science_outlined,
                  size: 15, color: colors.stateThinking),
              const SizedBox(width: 6),
              Text(
                p.isHeuristic
                    ? 'Kai S-Loop — эвристический прогноз'
                    : 'Kai S-Loop — симуляция',
                style: typography.labelMedium.copyWith(
                  color: colors.stateThinking,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),

          if (p.isHeuristic) ...[
            const SizedBox(height: 2),
            Text(
              'Приблизительная оценка. Проверьте актуальные данные перед принятием решений.',
              style: typography.labelSmall.copyWith(
                color: colors.textTertiary,
                fontSize: 10,
                fontStyle: FontStyle.italic,
              ),
            ),
          ],

          const SizedBox(height: 10),

          Wrap(
            spacing: KaiSpacing.xs,
            runSpacing: KaiSpacing.xxs,
            children: [
              if (p.successRate != null)
                _SimStat(
                  icon: Icons.trending_up_outlined,
                  label: 'Успех',
                  value: p.successRate!,
                  color: colors.success,
                  typography: typography,
                ),
              if (p.cost != null)
                _SimStat(
                  icon: Icons.attach_money_outlined,
                  label: 'Стоимость',
                  value:
                      '\$${p.cost!}${p.costP95 != null ? " (\$${p.costP95!} p95)" : ""}',
                  color: colors.oceanPrimary,
                  typography: typography,
                ),
              if (p.riskLevel != null)
                _SimStat(
                  icon: riskIcon,
                  label: 'Риск',
                  value: _riskLabel(p.riskLevel),
                  color: riskColor,
                  typography: typography,
                ),
            ],
          ),

          if (p.risksBreakdown != null &&
              !p.risksBreakdown!.contains('no elevated')) ...[
            const SizedBox(height: 8),
            Text(
              p.risksBreakdown!,
              style: typography.bodySmall.copyWith(
                color: colors.textSecondary,
                fontSize: 11,
              ),
            ),
          ],

          if (p.recommendation != null) ...[
            const SizedBox(height: 6),
            Text(
              p.recommendation!,
              style: typography.bodySmall.copyWith(
                color: colors.textPrimary,
                fontStyle: FontStyle.italic,
                fontSize: 11,
              ),
            ),
          ],
        ],
      ),
    );
  }
}

class _SimStat extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;
  final Color color;
  final dynamic typography;

  const _SimStat({
    required this.icon,
    required this.label,
    required this.value,
    required this.color,
    required this.typography,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: color.withValues(alpha: 0.30)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 11, color: color),
          const SizedBox(width: 4),
          Text(
            '$label: $value',
            style: (typography.labelSmall as TextStyle).copyWith(
              color: color,
              fontSize: 11,
            ),
          ),
        ],
      ),
    );
  }
}
