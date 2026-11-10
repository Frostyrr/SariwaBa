import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import '../../models/classification_result.dart';
import '../../theme/app_colors.dart';
import '../../theme/app_typography.dart';
import '../common/staggered_reveal.dart';
import 'frosted_glass_card.dart';

/// KPI Metrics strip showing Total Scans, Sariwa (Fresh), Not Fresh Alerts, and Average Confidence.
class KpiMetricsRow extends StatelessWidget {
  final List<ClassificationResult> history;

  const KpiMetricsRow({
    super.key,
    required this.history,
  });

  @override
  Widget build(BuildContext context) {
    final total = history.length;
    final freshCount = history.where((s) => s.isFresh).length;
    final cautionCount = total - freshCount;
    final avgConfidence = total > 0
        ? (history.fold(0.0, (acc, s) => acc + s.confidence) / total) * 100
        : 0.0;

    return LayoutBuilder(
      builder: (context, constraints) {
        final isDesktop = constraints.maxWidth >= 700;

        final cards = [
          _buildMetricBox(
            title: 'Total Scans',
            value: total.toString(),
            subtitle: 'Saved inspections',
            icon: CupertinoIcons.chart_bar_square,
            iconColor: SariwaColors.brandPrimary,
            iconBg: SariwaColors.brandPrimary.withValues(alpha: 0.10),
          ),
          _buildMetricBox(
            title: 'Sariwa (Fresh)',
            value: freshCount.toString(),
            subtitle: total > 0
                ? '${((freshCount / total) * 100).toStringAsFixed(0)}% of total scans'
                : 'Fresh Tilapia count',
            icon: CupertinoIcons.checkmark_seal,
            iconColor: SariwaColors.statusFresh,
            iconBg: SariwaColors.statusFresh.withValues(alpha: 0.10),
          ),
          _buildMetricBox(
            title: 'Not Fresh Alerts',
            value: cautionCount.toString(),
            subtitle: 'Needs attention',
            icon: CupertinoIcons.exclamationmark_triangle,
            iconColor: SariwaColors.notFreshPrimary,
            iconBg: SariwaColors.notFreshIconBg,
          ),
          _buildMetricBox(
            title: 'Avg. Confidence',
            value: total > 0 ? '${avgConfidence.toStringAsFixed(1)}%' : '—',
            subtitle: 'Average across scans',
            icon: CupertinoIcons.speedometer,
            iconColor: SariwaColors.statusInfo,
            iconBg: SariwaColors.statusInfo.withValues(alpha: 0.10),
          ),
        ];

        if (isDesktop) {
          return Row(
            children: List.generate(
              cards.length,
              (i) => Expanded(
                child: Padding(
                  padding: EdgeInsets.only(
                    left: i == 0 ? 0 : 6,
                    right: i == cards.length - 1 ? 0 : 6,
                  ),
                  child: StaggeredReveal(staggerIndex: i + 1, child: cards[i]),
                ),
              ),
            ),
          );
        } else {
          return Wrap(
            spacing: 12,
            runSpacing: 12,
            children: List.generate(
              cards.length,
              (i) => SizedBox(
                width: (constraints.maxWidth - 12) / 2,
                child: StaggeredReveal(staggerIndex: i + 1, child: cards[i]),
              ),
            ),
          );
        }
      },
    );
  }

  Widget _buildMetricBox({
    required String title,
    required String value,
    required String subtitle,
    required IconData icon,
    required Color iconColor,
    required Color iconBg,
  }) {
    return FrostedGlassCard(
      padding: const EdgeInsets.all(16),
      borderRadius: 20,
      blurSigma: 18,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Text(
                  title,
                  style: const TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    letterSpacing: AppTypography.defaultLetterSpacing,
                    color: SariwaColors.textSecondaryDark,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              const SizedBox(width: 6),
              Container(
                padding: const EdgeInsets.all(7),
                decoration: BoxDecoration(
                  color: iconBg,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(icon, size: 16, color: iconColor),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Text(
            value,
            style: const TextStyle(
              fontFamily: 'Geist',
              fontSize: 24,
              fontWeight: FontWeight.w800,
              letterSpacing: AppTypography.defaultLetterSpacing,
              color: SariwaColors.textPrimaryDark,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            subtitle,
            style: const TextStyle(
              fontSize: 11,
              letterSpacing: AppTypography.defaultLetterSpacing,
              color: SariwaColors.textMutedDark,
            ),
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }
}
