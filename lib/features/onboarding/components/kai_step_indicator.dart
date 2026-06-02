import 'package:flutter/material.dart';

import '../../../design_system/theme/kai_theme.dart';
import '../../../design_system/tokens/kai_tokens.dart';

/// Animated step-progress dots atom.
///
/// Renders a [Row] of [count] dots centred horizontally.
/// The active dot is an elongated accent pill (width 16, height 6,
/// [KaiRadius.brPill], `c.accent`); inactive dots are small circles
/// (width 6, height 6, `c.ink4`).
///
/// Each dot uses [AnimatedContainer] so the active pill animates its width
/// and colour as [active] changes. The animation duration is
/// [KaiMotion.standard] unless `MediaQuery.maybeOf(context)?.disableAnimations`
/// is true, in which case the duration is [Duration.zero] (instant swap).
///
/// ### Usage
/// ```dart
/// KaiStepIndicator(count: 4, active: stepIndex)
/// ```
class KaiStepIndicator extends StatelessWidget {
  const KaiStepIndicator({
    required this.count,
    required this.active,
    super.key,
  });

  /// Total number of steps.
  final int count;

  /// Index of the currently active step (0-based).
  final int active;

  @override
  Widget build(BuildContext context) {
    final c = KaiTheme.of(context).colors;
    final reduceMotion =
        MediaQuery.maybeOf(context)?.disableAnimations ?? false;
    final duration = reduceMotion ? Duration.zero : KaiMotion.standard;

    return Row(
      mainAxisSize: MainAxisSize.min,
      children: List.generate(count, (i) {
        final isActive = i == active;
        return AnimatedContainer(
          duration: duration,
          curve: KaiMotion.standardCurve,
          margin: const EdgeInsets.symmetric(horizontal: 3),
          width: isActive ? 16.0 : 6.0,
          height: 6.0,
          decoration: BoxDecoration(
            borderRadius: KaiRadius.brPill,
            color: isActive ? c.accent : c.ink4,
          ),
        );
      }),
    );
  }
}
