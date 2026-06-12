import 'package:flutter/material.dart';

import '../../../design_system/theme/kai_theme.dart';
import '../../../design_system/tokens/kai_tokens.dart';

/// Animated step-progress dots atom.
///
/// Renders a [Row] of [count] dots centred horizontally.
/// The active dot is an elongated accent pill (width 20, height 8,
/// [KaiRadius.brPill], `c.accent`); inactive dots are small circles
/// (width 8, height 8, `c.ink4`).
///
/// The whole indicator can be scaled via [scale] so it stays legible on
/// tablets and large phones. When [scale] is omitted it defaults to `1.0`.
///
/// Each dot uses [AnimatedContainer] so the active pill animates its width
/// and colour as [active] changes. The animation duration is
/// [KaiMotion.standard] unless `MediaQuery.maybeOf(context)?.disableAnimations`
/// is true, in which case the duration is [Duration.zero] (instant swap).
///
/// ### Usage
/// ```dart
/// KaiStepIndicator(count: 4, active: stepIndex, scale: 1.05)
/// ```
class KaiStepIndicator extends StatelessWidget {
  const KaiStepIndicator({
    required this.count,
    required this.active,
    this.scale = 1.0,
    super.key,
  });

  /// Total number of steps.
  final int count;

  /// Index of the currently active step (0-based).
  final int active;

  /// Visual scale factor for dots and spacing.
  final double scale;

  @override
  Widget build(BuildContext context) {
    final c = KaiTheme.of(context).colors;
    final reduceMotion =
        MediaQuery.maybeOf(context)?.disableAnimations ?? false;
    final duration = reduceMotion ? Duration.zero : KaiMotion.standard;

    final inactiveSize = 8.0 * scale;
    final activeWidth = 20.0 * scale;
    final activeHeight = 8.0 * scale;
    final gap = 4.0 * scale;

    return Row(
      mainAxisSize: MainAxisSize.min,
      children: List.generate(count, (i) {
        final isActive = i == active;
        return AnimatedContainer(
          duration: duration,
          curve: KaiMotion.standardCurve,
          margin: EdgeInsets.symmetric(horizontal: gap / 2),
          width: isActive ? activeWidth : inactiveSize,
          height: isActive ? activeHeight : inactiveSize,
          decoration: BoxDecoration(
            borderRadius: KaiRadius.brPill,
            color: isActive ? c.accent : c.ink4,
          ),
        );
      }),
    );
  }
}
