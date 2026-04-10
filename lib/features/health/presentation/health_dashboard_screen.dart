import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/design/theme/theme_extensions.dart';
import '../../../core/design/tokens/kai_spacing.dart';
import '../data/health_detail_repository.dart';
import '../data/health_repository.dart';

/// Full-screen Health Dashboard showing all service statuses.
/// Opened by tapping the HealthIndicator dot in the AppBar.
class HealthDashboardScreen extends ConsumerWidget {
  const HealthDashboardScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final healthAsync = ref.watch(healthDetailProvider);
    final colors = context.kaiColors;
    final typography = context.kaiTypography;

    return Scaffold(
      backgroundColor: colors.background,
      appBar: AppBar(
        backgroundColor: colors.background,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: colors.textPrimary),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          'System Status',
          style: typography.titleMedium.copyWith(color: colors.textPrimary),
        ),
        actions: [
          IconButton(
            tooltip: 'Refresh',
            icon: Icon(Icons.refresh, color: colors.textSecondary),
            onPressed: () =>
                ref.read(healthDetailProvider.notifier).refresh(),
          ),
        ],
      ),
      body: healthAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => _ErrorState(message: e.toString()),
        data: (health) => _HealthBody(health: health),
      ),
    );
  }
}

class _HealthBody extends ConsumerWidget {
  final DetailedHealth health;

  const _HealthBody({required this.health});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final colors = context.kaiColors;
    final typography = context.kaiTypography;

    final overallOk = health.status == 'ok' || health.status == 'healthy';
    final overallColor = overallOk ? colors.success : colors.error;
    final overallLabel = overallOk ? 'All Systems Operational' : 'Degraded';

    return RefreshIndicator(
      onRefresh: () => ref.read(healthDetailProvider.notifier).refresh(),
      child: ListView(
        padding: const EdgeInsets.all(KaiSpacing.screenPadding),
        children: [
          // Overall status card
          _StatusCard(
            child: Row(
              children: [
                Container(
                  width: 12,
                  height: 12,
                  decoration: BoxDecoration(
                    color: overallColor,
                    shape: BoxShape.circle,
                    boxShadow: [
                      BoxShadow(
                        color: overallColor.withAlpha(100),
                        blurRadius: 8,
                        spreadRadius: 2,
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: KaiSpacing.s),
                Expanded(
                  child: Text(
                    overallLabel,
                    style: typography.titleMedium.copyWith(
                      color: colors.textPrimary,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
                Text(
                  _formatTime(health.checkedAt),
                  style: typography.labelSmall.copyWith(
                    color: colors.textTertiary,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: KaiSpacing.m),

          // Service list
          if (health.services.isEmpty)
            Padding(
              padding: const EdgeInsets.symmetric(vertical: KaiSpacing.l),
              child: Text(
                'No detailed service data available.',
                style: typography.bodyMedium.copyWith(
                  color: colors.textTertiary,
                ),
                textAlign: TextAlign.center,
              ),
            )
          else
            ...health.services.entries.map(
              (e) => Padding(
                padding: const EdgeInsets.only(bottom: KaiSpacing.xs),
                child: _ServiceRow(service: e.value),
              ),
            ),

          const SizedBox(height: KaiSpacing.l),
          // Legend
          Text(
            'Updates every 30 seconds • Tap ↺ to refresh manually',
            style: typography.labelSmall.copyWith(color: colors.textTertiary),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  String _formatTime(DateTime dt) {
    final h = dt.hour.toString().padLeft(2, '0');
    final m = dt.minute.toString().padLeft(2, '0');
    final s = dt.second.toString().padLeft(2, '0');
    return '$h:$m:$s';
  }
}

class _ServiceRow extends StatelessWidget {
  final ServiceHealth service;

  const _ServiceRow({required this.service});

  @override
  Widget build(BuildContext context) {
    final colors = context.kaiColors;
    final typography = context.kaiTypography;
    final isOk = service.isOk;
    final statusColor = isOk ? colors.success : colors.error;

    return _StatusCard(
      child: Row(
        children: [
          // Status dot
          Container(
            width: 8,
            height: 8,
            decoration: BoxDecoration(
              color: statusColor,
              shape: BoxShape.circle,
            ),
          ),
          const SizedBox(width: KaiSpacing.s),
          // Service name
          Expanded(
            child: Text(
              _serviceLabel(service.name),
              style: typography.bodyMedium.copyWith(
                color: colors.textPrimary,
              ),
            ),
          ),
          // Latency
          if (service.latencyMs != null)
            Text(
              '${service.latencyMs}ms',
              style: typography.labelSmall.copyWith(
                color: colors.textTertiary,
              ),
            ),
          const SizedBox(width: KaiSpacing.xs),
          // Status badge
          Container(
            padding: const EdgeInsets.symmetric(
              horizontal: 8,
              vertical: 2,
            ),
            decoration: BoxDecoration(
              color: statusColor.withAlpha(26),
              borderRadius: BorderRadius.circular(4),
            ),
            child: Text(
              service.status.toUpperCase(),
              style: typography.labelSmall.copyWith(
                color: statusColor,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }

  String _serviceLabel(String name) {
    return switch (name) {
      'redis'  => 'Redis (Cache)',
      'neo4j'  => 'Neo4j (Knowledge Graph)',
      'qdrant' => 'Qdrant (Vector Store)',
      'nats'   => 'NATS (Message Bus)',
      'kai_ft' => 'Kai-FT (Fine-tuned Model)',
      _        => name[0].toUpperCase() + name.substring(1),
    };
  }
}

class _StatusCard extends StatelessWidget {
  final Widget child;

  const _StatusCard({required this.child});

  @override
  Widget build(BuildContext context) {
    final colors = context.kaiColors;

    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: KaiSpacing.m,
        vertical: KaiSpacing.s,
      ),
      decoration: BoxDecoration(
        color: colors.surfaceContainer,
        borderRadius: BorderRadius.circular(12),
      ),
      child: child,
    );
  }
}

class _ErrorState extends StatelessWidget {
  final String message;

  const _ErrorState({required this.message});

  @override
  Widget build(BuildContext context) {
    final colors = context.kaiColors;
    final typography = context.kaiTypography;

    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.cloud_off_outlined, size: 48, color: colors.error),
          const SizedBox(height: KaiSpacing.s),
          Text(
            'Cannot reach server',
            style: typography.titleMedium.copyWith(color: colors.textPrimary),
          ),
          const SizedBox(height: KaiSpacing.xxs),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: KaiSpacing.xl),
            child: Text(
              message,
              style: typography.bodySmall.copyWith(color: colors.textTertiary),
              textAlign: TextAlign.center,
              maxLines: 3,
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    );
  }
}
