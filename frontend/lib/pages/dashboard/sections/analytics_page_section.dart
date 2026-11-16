import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import '../../../models/classification/classification_result.dart';
import '../../../constants/theme/app_colors.dart';
import '../../../constants/theme/app_typography.dart';
import '../../../widgets/dashboard/dashboard_atmospheric_banner.dart';
import '../../../widgets/dashboard/frosted_glass_card.dart';
import '../../../widgets/dashboard/kpi_metrics_row.dart';

/// Dedicated Freshness Insights analytics page showing KPI metrics, freshness ratio bar, and anatomical breakdown.
class AnalyticsPageSection extends StatelessWidget {
  final List<ClassificationResult> history;
  final bool isDesktop;
  final ScrollController? scrollController;

  const AnalyticsPageSection({
    super.key,
    required this.history,
    required this.isDesktop,
    this.scrollController,
  });

  @override
  Widget build(BuildContext context) {
    final total = history.length;
    final freshCount = history.where((s) => s.isFresh).length;
    final notFreshCount = history.where((s) => s.isNotFresh).length;
    final avgConf = total > 0
        ? (history.fold<double>(0.0, (acc, s) => acc + s.confidence) / total) *
            100
        : 0.0;
    final freshPct = total > 0
        ? ((freshCount / total) * 100).toStringAsFixed(0)
        : '0';
    final notFreshPct = total > 0
        ? ((notFreshCount / total) * 100).toStringAsFixed(0)
        : '0';
    final eyeCount = history
        .where((s) => (s.regionType ?? '').toLowerCase() == 'eye')
        .length;
    final gillCount = history
        .where((s) => (s.regionType ?? '').toLowerCase() == 'gill')
        .length;

    return SingleChildScrollView(
      controller: scrollController,
      physics: const BouncingScrollPhysics(),
      padding: EdgeInsets.symmetric(
        horizontal: isDesktop ? 36 : 18,
        vertical: isDesktop ? 28 : 20,
      ),
      child: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 1320),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              DashboardAtmosphericBanner(
                content: const Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Freshness Insights',
                      style: TextStyle(
                        fontSize: 26,
                        fontWeight: FontWeight.w500, // Medium
                        letterSpacing: AppTypography.defaultLetterSpacing,
                        color: Colors.white,
                      ),
                    ),
                    SizedBox(height: 4),
                    Text(
                      'Explore your inspection activity and classification patterns.',
                      style: TextStyle(
                        fontSize: 14,
                        letterSpacing: AppTypography.defaultLetterSpacing,
                        color: Color(0xFFD1FAF4),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),
              KpiMetricsRow(history: history),
              const SizedBox(height: 24),

              // Visual Distribution Ratio Bar
              FrostedGlassCard(
                padding: const EdgeInsets.all(22),
                borderRadius: 20,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Freshness Ratio Distribution',
                      style: TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w400,
                        letterSpacing: AppTypography.defaultLetterSpacing,
                        color: SariwaColors.textPrimaryDark,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      '$freshCount fresh tilapia vs $notFreshCount not fresh tilapia identified',
                      style: const TextStyle(
                        fontSize: 12,
                        letterSpacing: AppTypography.defaultLetterSpacing,
                        color: SariwaColors.textSecondaryDark,
                      ),
                    ),
                    const SizedBox(height: 16),
                    ClipRRect(
                      borderRadius: BorderRadius.circular(99),
                      child: Container(
                        height: 14,
                        color: const Color(0xFFE2E8F0),
                        child: total == 0
                            ? null
                            : Row(
                                children: [
                                  if (freshCount > 0)
                                    Expanded(
                                      flex: freshCount,
                                      child: Container(
                                        color: const Color(0xFF16A34A),
                                      ),
                                    ),
                                  if (notFreshCount > 0)
                                    Expanded(
                                      flex: notFreshCount,
                                      child: Container(
                                        color: SariwaColors.notFreshPrimary,
                                      ),
                                    ),
                                ],
                              ),
                      ),
                    ),
                    const SizedBox(height: 12),
                    Row(
                      children: [
                        _buildDistributionLegend(
                          label: 'Fresh: $freshPct%',
                          color: const Color(0xFF16A34A),
                        ),
                        const SizedBox(width: 16),
                        _buildDistributionLegend(
                          label: 'Not Fresh: $notFreshPct%',
                          color: SariwaColors.notFreshPrimary,
                        ),
                        const Spacer(),
                        Text(
                          'Avg Conf: ${avgConf.toStringAsFixed(1)}%',
                          style: const TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w400,
                            letterSpacing: AppTypography.defaultLetterSpacing,
                            color: Color(0xFF64748B),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 20),

              // Anatomical Region Breakdown
              Row(
                children: [
                  Expanded(
                    child: FrostedGlassCard(
                      padding: const EdgeInsets.all(20),
                      borderRadius: 20,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Row(
                            children: [
                              Icon(
                                CupertinoIcons.eye,
                                size: 18,
                                color: SariwaColors.brandPrimary,
                              ),
                              SizedBox(width: 8),
                              Text(
                                'Eye Inspections',
                                style: TextStyle(
                                  fontSize: 14,
                                  fontWeight: FontWeight.w400,
                                  letterSpacing:
                                      AppTypography.defaultLetterSpacing,
                                  color: SariwaColors.textPrimaryDark,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 12),
                          Text(
                            '$eyeCount scans',
                            style: const TextStyle(
                              fontSize: 22,
                              fontWeight: FontWeight.w400,
                              letterSpacing: AppTypography.defaultLetterSpacing,
                              color: SariwaColors.textPrimaryDark,
                            ),
                          ),
                          Text(
                            total > 0
                                ? '${((eyeCount / total) * 100).toStringAsFixed(0)}% of total scans'
                                : 'Default region',
                            style: const TextStyle(
                              fontSize: 12,
                              letterSpacing: AppTypography.defaultLetterSpacing,
                              color: SariwaColors.textSecondaryDark,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: FrostedGlassCard(
                      padding: const EdgeInsets.all(20),
                      borderRadius: 20,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Row(
                            children: [
                              Icon(
                                CupertinoIcons.waveform_path,
                                size: 18,
                                color: Color(0xFF8B5CF6),
                              ),
                              SizedBox(width: 8),
                              Text(
                                'Gill Inspections',
                                style: TextStyle(
                                  fontSize: 14,
                                  fontWeight: FontWeight.w400,
                                  letterSpacing:
                                      AppTypography.defaultLetterSpacing,
                                  color: SariwaColors.textPrimaryDark,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 12),
                          Text(
                            '$gillCount scans',
                            style: const TextStyle(
                              fontSize: 22,
                              fontWeight: FontWeight.w400,
                              letterSpacing: AppTypography.defaultLetterSpacing,
                              color: SariwaColors.textPrimaryDark,
                            ),
                          ),
                          Text(
                            total > 0
                                ? '${((gillCount / total) * 100).toStringAsFixed(0)}% of total scans'
                                : 'Exposed gill view',
                            style: const TextStyle(
                              fontSize: 12,
                              letterSpacing: AppTypography.defaultLetterSpacing,
                              color: SariwaColors.textSecondaryDark,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 36),
              _buildSimpleFooter(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildDistributionLegend({
    required String label,
    required Color color,
  }) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 8,
          height: 8,
          decoration: BoxDecoration(color: color, shape: BoxShape.circle),
        ),
        const SizedBox(width: 6),
        Text(
          label,
          style: const TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w400,
            letterSpacing: AppTypography.defaultLetterSpacing,
            color: Color(0xFF334155),
          ),
        ),
      ],
    );
  }

  Widget _buildSimpleFooter() {
    return Center(
      child: Text(
        '© ${DateTime.now().year} SariwaBa — Fish Freshness Classification. All rights reserved.',
        style: const TextStyle(
          fontSize: 12,
          letterSpacing: AppTypography.defaultLetterSpacing,
          color: SariwaColors.textMutedDark,
        ),
      ),
    );
  }
}
