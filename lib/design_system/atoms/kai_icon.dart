import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

import '../theme/kai_theme.dart';

/// Named SVG asset registry. Each enum value maps to a kebab-case file under
/// `assets/icons/<assetName>.svg`.
enum KaiIconName {
  arrowUp('arrow-up'),
  mic('mic'),
  plus('plus'),
  chevRight('chev-right'),
  person('person'),
  settings('settings'),
  send('send'),
  close('close'),
  search('search'),
  menu('menu'),
  retry('retry'),
  alert('alert'),
  heart('heart'),
  copy('copy'),
  wifiOff('wifi-off'),
  clock('clock'),
  folder('folder'),
  chev('chev'),
  memory('memory'),
  press('press');

  const KaiIconName(this.assetName);
  final String assetName;
}

/// Icon atom — renders a tinted SVG from `assets/icons/`.
///
/// Default size 18, default color `ink2` from the active theme. Pass [color]
/// to override (e.g. white on a tide-gradient button).
class KaiIcon extends StatelessWidget {
  const KaiIcon(this.name, {this.size = 18, this.color, super.key});

  final KaiIconName name;
  final double size;
  final Color? color;

  @override
  Widget build(BuildContext context) {
    final c = color ?? KaiTheme.of(context).colors.ink2;
    return SvgPicture.asset(
      'assets/icons/${name.assetName}.svg',
      width: size,
      height: size,
      colorFilter: ColorFilter.mode(c, BlendMode.srcIn),
    );
  }
}
