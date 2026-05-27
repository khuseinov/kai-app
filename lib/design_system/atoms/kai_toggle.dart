import 'package:flutter/material.dart';

import '../theme/kai_theme.dart';
import '../tokens/kai_tokens.dart';

/// Pill switch — atomic. Canon: `new-design/settings.html § .toggle`.
///
/// ```
/// 34 x 20 pill (radius 999), inner padding 2
/// knob 16 x 16 (radius 50%), white, shadow 0 1px 3px rgba(0,0,0,0.18)
/// track: surface-3 (off) | accent (on)
/// transition: 200ms cubic-bezier(.2, 0, 0, 1)  // KaiMotion.standardCurve
/// knob translates 14px (= 34 - 2*2 - 16) on activation
/// ```
///
/// [onChanged] null disables the toggle (no taps, no visual change).
class KaiToggle extends StatelessWidget {
  const KaiToggle({
    required this.value,
    required this.onChanged,
    super.key,
  });

  final bool value;
  final ValueChanged<bool>? onChanged;

  @override
  Widget build(BuildContext context) {
    final c = KaiTheme.of(context).colors;
    return GestureDetector(
      onTap: onChanged == null ? null : () => onChanged!(!value),
      behavior: HitTestBehavior.opaque,
      child: AnimatedContainer(
        duration: KaiMotion.standard,
        curve: KaiMotion.standardCurve,
        width: 34,
        height: 20,
        padding: const EdgeInsets.all(2),
        decoration: BoxDecoration(
          color: value ? c.accent : c.surface3,
          borderRadius: BorderRadius.circular(999),
        ),
        child: AnimatedAlign(
          duration: KaiMotion.standard,
          curve: KaiMotion.standardCurve,
          alignment: value ? Alignment.centerRight : Alignment.centerLeft,
          child: Container(
            width: 16,
            height: 16,
            decoration: const BoxDecoration(
              color: Color(0xFFFFFFFF),
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(
                  color: Color.fromRGBO(0, 0, 0, 0.18),
                  blurRadius: 3,
                  offset: Offset(0, 1),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
