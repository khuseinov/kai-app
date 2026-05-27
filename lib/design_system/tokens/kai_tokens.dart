import 'kai_colors.dart';

export 'kai_colors.dart';
export 'kai_motion.dart';
export 'kai_radius.dart';
export 'kai_space.dart';
export 'kai_tide.dart';
export 'kai_type.dart';

/// Composite of resolved tokens for the current theme.
///
/// Colors are theme-dependent; the rest (space/radius/motion/type/tide)
/// are theme-independent and accessed via their static classes.
class KaiTokens {
  const KaiTokens({required this.colors});

  /// Color tokens for the active theme (light or dark).
  final KaiColorTokens colors;

  /// Resolves to the light token set.
  static const KaiTokens light = KaiTokens(colors: KaiColors.light);

  /// Resolves to the dark token set.
  static const KaiTokens dark = KaiTokens(colors: KaiColors.dark);
}
