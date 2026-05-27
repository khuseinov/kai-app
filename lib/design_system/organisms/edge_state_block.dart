import 'package:flutter/material.dart';

import '../atoms/kai_button.dart';
import '../atoms/kai_icon.dart';
import '../atoms/kai_text.dart';
import '../atoms/kai_tide_curve.dart';
import '../molecules/care_block.dart';
import '../theme/kai_theme.dart';
import '../tokens/kai_tokens.dart';

/// Which edge state surface to render.
enum EdgeSurface {
  /// Device is offline.
  offline,

  /// A server/processing error occurred.
  error,

  /// Rate limit reached.
  rateLimit,

  /// Crisis / self-harm signal in conversation.
  crisis,
}

/// Composable edge-state widget.
///
/// Surfaces: [EdgeSurface.offline], [EdgeSurface.error],
/// [EdgeSurface.rateLimit], [EdgeSurface.crisis].
class EdgeStateBlock extends StatelessWidget {
  const EdgeStateBlock({
    required this.surface,
    this.onRetry,
    this.onPlans,
    this.countdown,
    super.key,
  });

  final EdgeSurface surface;

  /// Used by [EdgeSurface.offline] and [EdgeSurface.error].
  final VoidCallback? onRetry;

  /// Used by [EdgeSurface.rateLimit].
  final VoidCallback? onPlans;

  /// Optional countdown timer for [EdgeSurface.rateLimit].
  final Duration? countdown;

  @override
  Widget build(BuildContext context) {
    switch (surface) {
      case EdgeSurface.offline:
        return _OfflineSurface(onRetry: onRetry);
      case EdgeSurface.error:
        return _ErrorSurface(onRetry: onRetry);
      case EdgeSurface.rateLimit:
        return _RateLimitSurface(onPlans: onPlans, countdown: countdown);
      case EdgeSurface.crisis:
        return const _CrisisSurface();
    }
  }
}

// ─── Offline ──────────────────────────────────────────────────────────────────

class _OfflineSurface extends StatelessWidget {
  const _OfflineSurface({this.onRetry});

  final VoidCallback? onRetry;

  @override
  Widget build(BuildContext context) {
    final tokens = KaiTheme.of(context);
    return Container(
      padding: const EdgeInsets.all(KaiSpace.s4),
      decoration: BoxDecoration(
        color: tokens.colors.surface2,
        borderRadius: KaiRadius.br3,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              // Yellow dot — no-network indicator
              Container(
                width: 8,
                height: 8,
                decoration: const BoxDecoration(
                  color: Color(0xFFFFBF00),
                  shape: BoxShape.circle,
                ),
              ),
              const SizedBox(width: KaiSpace.s2),
              KaiText.body('Нет сети', color: tokens.colors.ink1),
            ],
          ),
          const SizedBox(height: KaiSpace.s2),
          KaiButton.ghost(onPressed: onRetry, label: 'Повторить'),
        ],
      ),
    );
  }
}

// ─── Error ────────────────────────────────────────────────────────────────────

class _ErrorSurface extends StatelessWidget {
  const _ErrorSurface({this.onRetry});

  final VoidCallback? onRetry;

  @override
  Widget build(BuildContext context) {
    final tokens = KaiTheme.of(context);
    return Container(
      decoration: BoxDecoration(
        color: tokens.colors.negativeWash,
        borderRadius: KaiRadius.br3,
      ),
      clipBehavior: Clip.hardEdge,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const KaiTideCurve(state: KaiTide.error, height: 28),
          Padding(
            padding: const EdgeInsets.all(KaiSpace.s4),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                KaiText.body(
                  'Ошибка — попробуйте ещё раз',
                  color: tokens.colors.ink1,
                ),
                const SizedBox(height: KaiSpace.s3),
                KaiButton.ink1(
                  onPressed: onRetry,
                  label: 'Продолжить',
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// ─── Rate limit ───────────────────────────────────────────────────────────────

class _RateLimitSurface extends StatelessWidget {
  const _RateLimitSurface({this.onPlans, this.countdown});

  final VoidCallback? onPlans;
  final Duration? countdown;

  @override
  Widget build(BuildContext context) {
    final tokens = KaiTheme.of(context);
    return Container(
      padding: const EdgeInsets.all(KaiSpace.s4),
      decoration: BoxDecoration(
        color: tokens.colors.warningWash,
        borderRadius: KaiRadius.br3,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              KaiIcon(
                KaiIconName.alert,
                size: 18,
                color: tokens.colors.warning,
              ),
              const SizedBox(width: KaiSpace.s2),
              Expanded(
                child: KaiText.body(
                  'Слишком много запросов',
                  color: tokens.colors.ink1,
                ),
              ),
            ],
          ),
          if (countdown != null) ...[
            const SizedBox(height: KaiSpace.s2),
            Text(
              '${countdown!.inSeconds} сек',
              style: KaiType.micro(color: tokens.colors.ink3),
            ),
          ],
          const SizedBox(height: KaiSpace.s3),
          KaiButton.ghost(
            onPressed: onPlans,
            label: 'Посмотреть планы',
          ),
        ],
      ),
    );
  }
}

// ─── Crisis ───────────────────────────────────────────────────────────────────

class _CrisisSurface extends StatelessWidget {
  const _CrisisSurface();

  @override
  Widget build(BuildContext context) {
    final tokens = KaiTheme.of(context);
    return Container(
      decoration: BoxDecoration(
        color: tokens.colors.surface,
        borderRadius: KaiRadius.br3,
      ),
      clipBehavior: Clip.hardEdge,
      child: const Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Opacity(
            opacity: 0.3,
            child: KaiTideCurve(state: KaiTide.idle, height: 28),
          ),
          Padding(
            padding: EdgeInsets.all(KaiSpace.s4),
            child: CareBlock(
              heading: 'Я слышу тебя.',
              body: 'Если тебе сейчас тяжело, ты не один. '
                  'Kai всегда рядом, и помощь доступна прямо сейчас.',
              resources: [
                CareResource(label: 'Телефон доверия', number: '8-800-2000-122'),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
