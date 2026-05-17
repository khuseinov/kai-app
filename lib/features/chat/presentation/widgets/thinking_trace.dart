import 'package:flutter/material.dart';
import '../../../../core/design/theme/theme_extensions.dart';
import '../../../../core/design/tokens/kai_spacing.dart';

/// STREAM-THINKING-1: inline reasoning trace shown above the final answer
/// when the backend streams `event: thinking` chunks.
///
/// - Streaming: expanded by default with a pulsing icon.
/// - Done: auto-collapses; tap to re-expand.
class ThinkingTrace extends StatefulWidget {
  final String text;
  final bool streaming;

  const ThinkingTrace({super.key, required this.text, required this.streaming});

  @override
  State<ThinkingTrace> createState() => _ThinkingTraceState();
}

class _ThinkingTraceState extends State<ThinkingTrace>
    with SingleTickerProviderStateMixin {
  bool _userCollapsed = false;
  late final AnimationController _pulse;

  @override
  void initState() {
    super.initState();
    _pulse = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    )..repeat(reverse: true);
  }

  @override
  void dispose() {
    _pulse.dispose();
    super.dispose();
  }

  bool get _expanded => widget.streaming && !_userCollapsed;

  @override
  Widget build(BuildContext context) {
    final colors = context.kaiColors;
    final typography = context.kaiTypography;

    return GestureDetector(
      onTap: () => setState(() => _userCollapsed = !_userCollapsed),
      child: Container(
        padding: const EdgeInsets.symmetric(
          horizontal: KaiSpacing.s,
          vertical: KaiSpacing.xs,
        ),
        decoration: BoxDecoration(
          border: Border(
            left: BorderSide(color: colors.cloudLight, width: 2),
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                if (widget.streaming) ...[
                  FadeTransition(
                    opacity:
                        Tween<double>(begin: 0.3, end: 0.9).animate(_pulse),
                    child: Icon(
                      Icons.psychology_outlined,
                      size: 11,
                      color: colors.textTertiary,
                    ),
                  ),
                  const SizedBox(width: 6),
                ] else ...[
                  Icon(
                    Icons.psychology_outlined,
                    size: 11,
                    color: colors.textTertiary,
                  ),
                  const SizedBox(width: 6),
                ],
                Text(
                  widget.streaming
                      ? 'Kai размышляет...'
                      : (_userCollapsed
                          ? 'Развернуть рассуждения'
                          : 'Свернуть'),
                  style: typography.labelSmall.copyWith(
                    color: colors.textTertiary,
                    fontSize: 10,
                    letterSpacing: 0.3,
                  ),
                ),
                const Spacer(),
                if (!widget.streaming)
                  Icon(
                    _userCollapsed ? Icons.expand_more : Icons.expand_less,
                    size: 14,
                    color: colors.textTertiary,
                  ),
              ],
            ),
            if (_expanded || !_userCollapsed && !widget.streaming) ...[
              const SizedBox(height: KaiSpacing.xxs),
              AnimatedSize(
                duration: const Duration(milliseconds: 200),
                alignment: Alignment.topLeft,
                child: Text(
                  widget.text,
                  style: typography.bodySmall.copyWith(
                    color: colors.textSecondary,
                    fontStyle: FontStyle.italic,
                    fontSize: 12,
                    height: 1.45,
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
