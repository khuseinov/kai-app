import 'package:flutter/material.dart';

import '../../tokens/kai_tokens.dart';

/// v3 avatar atom.
///
/// A circular surface filled with [KaiTide.gradientCorner] (135° diagonal —
/// correct for square/circle brand surfaces per design rules).
///
/// ```
/// KaiAvatar()                    // 40px circle, no initial
/// KaiAvatar(initial: 'R')        // 40px circle + centered white 'R'
/// KaiAvatar(size: 64, initial: 'K')  // custom size
/// ```
///
/// Dimension constant:
/// - [_defaultSize] = 40 logical pixels (canonical avatar diameter for lists
///   and inline uses; matches the settings + nav account hero pattern).
class KaiAvatar extends StatelessWidget {
  /// Creates a circular avatar with the tide corner gradient.
  ///
  /// [size] sets the diameter in logical pixels. Defaults to 40.
  /// [initial] is an optional single character shown at center in white.
  ///   If null or empty, no label is rendered.
  const KaiAvatar({
    this.size = _defaultSize,
    this.initial,
    super.key,
  });

  /// Default avatar diameter — 40 logical pixels.
  ///
  /// This is a component dimension literal (not a design-scale token). It
  /// matches the standard list/nav account avatar size in the canon HTML.
  static const double _defaultSize = 40;

  /// Diameter of the avatar circle in logical pixels.
  final double size;

  /// Optional uppercase initial to show inside the circle.
  ///
  /// Null or empty string renders no label.
  final String? initial;

  @override
  Widget build(BuildContext context) {
    final hasInitial = initial != null && initial!.isNotEmpty;

    return Container(
      constraints: BoxConstraints.tightFor(width: size, height: size),
      decoration: const BoxDecoration(
        gradient: KaiTide.gradientCorner,
        shape: BoxShape.circle,
      ),
      alignment: Alignment.center,
      child: hasInitial
          ? Text(
              initial!.toUpperCase(),
              style: KaiType.small(
                color: const Color(0xFFFFFFFF), // sanctioned white-on-fill
              ),
            )
          : null,
    );
  }
}
