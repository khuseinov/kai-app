import 'package:flutter/material.dart';

import '../../../../core/design/theme/theme_extensions.dart';
import '../../../../core/design/tokens/kai_colors.dart';
import '../../../../core/design/tokens/kai_radii.dart';
import '../../../../core/design/tokens/kai_spacing.dart';
import '../../../../core/design/tokens/kai_typography.dart';

class MessageMetadata extends StatefulWidget {
  final String? model;
  final String? provider;
  final String? requestType;
  final double? confidence;
  final int? latencyMs;
  final int? tokensUsed;
  final bool? piiBlocked;
  final String? language;
  final String? correlationId;

  const MessageMetadata({
    super.key,
    this.model,
    this.provider,
    this.requestType,
    this.confidence,
    this.latencyMs,
    this.tokensUsed,
    this.piiBlocked,
    this.language,
    this.correlationId,
  });

  @override
  State<MessageMetadata> createState() => _MessageMetadataState();
}

class _MessageMetadataState extends State<MessageMetadata> {
  bool _expanded = false;

  bool get _hasAnyMetadata {
    return widget.model != null ||
        widget.provider != null ||
        widget.requestType != null ||
        widget.confidence != null ||
        widget.latencyMs != null ||
        widget.tokensUsed != null ||
        widget.piiBlocked == true ||
        widget.language != null ||
        widget.correlationId != null;
  }

  @override
  Widget build(BuildContext context) {
    if (!_hasAnyMetadata) {
      return const SizedBox.shrink();
    }

    final colors = context.kaiColors;
    final typography = context.kaiTypography;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        GestureDetector(
          onTap: () => setState(() => _expanded = !_expanded),
          behavior: HitTestBehavior.opaque,
          child: SizedBox(
            width: 16,
            height: 16,
            child: Icon(
              Icons.info_outline,
              size: 16,
              color: colors.textTertiary,
            ),
          ),
        ),
        AnimatedSize(
          duration: const Duration(milliseconds: 200),
          curve: Curves.easeInOut,
          alignment: Alignment.topCenter,
          child: _expanded
              ? Container(
                  margin: const EdgeInsets.only(top: KaiSpacing.xs),
                  padding: const EdgeInsets.all(KaiSpacing.s),
                  decoration: BoxDecoration(
                    color: colors.surfaceContainer,
                    borderRadius: KaiRadii.m,
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      if (widget.confidence != null)
                        _buildConfidenceRow(
                            colors, typography, widget.confidence!),
                      if (widget.model != null || widget.provider != null)
                        _buildModelProviderRow(colors, typography),
                      if (widget.latencyMs != null)
                        _buildLatencyRow(colors, typography),
                      if (widget.tokensUsed != null)
                        _buildTokensRow(colors, typography),
                      if (widget.piiBlocked == true)
                        _buildPiiWarningRow(colors, typography),
                      if (widget.requestType != null)
                        _buildRequestTypeRow(colors, typography),
                      if (widget.language != null)
                        _buildLanguageRow(colors, typography),
                    ],
                  ),
                )
              : const SizedBox.shrink(),
        ),
      ],
    );
  }

  Widget _buildConfidenceRow(
      KaiColors colors, KaiTypography typography, double confidence) {
    final barColor = confidence > 0.8
        ? colors.success
        : confidence >= 0.5
            ? colors.warning
            : colors.error;

    return Padding(
      padding: const EdgeInsets.only(bottom: KaiSpacing.xs),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            'Уверенность: ${(confidence * 100).toStringAsFixed(0)}%',
            style: typography.bodySmall.copyWith(color: colors.textSecondary),
          ),
          const SizedBox(height: 4),
          ClipRRect(
            borderRadius: KaiRadii.pill,
            child: LinearProgressIndicator(
              value: confidence.clamp(0.0, 1.0),
              minHeight: 4,
              backgroundColor: colors.textTertiary.withValues(alpha: 0.2),
              valueColor: AlwaysStoppedAnimation<Color>(barColor),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildModelProviderRow(KaiColors colors, KaiTypography typography) {
    final parts = <String>[
      if (widget.model != null) widget.model!,
      if (widget.provider != null) widget.provider!,
    ];

    return Padding(
      padding: const EdgeInsets.only(bottom: KaiSpacing.xxs),
      child: Text(
        'Модель: ${parts.join(' · ')}',
        style: typography.bodySmall.copyWith(color: colors.textSecondary),
      ),
    );
  }

  Widget _buildLatencyRow(KaiColors colors, KaiTypography typography) {
    return Padding(
      padding: const EdgeInsets.only(bottom: KaiSpacing.xxs),
      child: Text(
        'Время ответа: ${widget.latencyMs} мс',
        style: typography.bodySmall.copyWith(color: colors.textSecondary),
      ),
    );
  }

  Widget _buildTokensRow(KaiColors colors, KaiTypography typography) {
    return Padding(
      padding: const EdgeInsets.only(bottom: KaiSpacing.xxs),
      child: Text(
        'Токены: ${widget.tokensUsed}',
        style: typography.bodySmall.copyWith(color: colors.textSecondary),
      ),
    );
  }

  Widget _buildPiiWarningRow(KaiColors colors, KaiTypography typography) {
    return Padding(
      padding: const EdgeInsets.only(bottom: KaiSpacing.xxs),
      child: Row(
        children: [
          Icon(Icons.shield, size: 14, color: colors.warning),
          const SizedBox(width: KaiSpacing.xxs),
          Expanded(
            child: Text(
              'PII обнаружены и заблокированы',
              style: typography.bodySmall.copyWith(color: colors.warning),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildRequestTypeRow(KaiColors colors, KaiTypography typography) {
    return Padding(
      padding: const EdgeInsets.only(bottom: KaiSpacing.xxs),
      child: Text(
        'Тип запроса: ${widget.requestType}',
        style: typography.bodySmall.copyWith(color: colors.textTertiary),
      ),
    );
  }

  Widget _buildLanguageRow(KaiColors colors, KaiTypography typography) {
    return Padding(
      padding: const EdgeInsets.only(bottom: KaiSpacing.xxs),
      child: Text(
        'Язык: ${widget.language}',
        style: typography.bodySmall.copyWith(color: colors.textTertiary),
      ),
    );
  }
}
