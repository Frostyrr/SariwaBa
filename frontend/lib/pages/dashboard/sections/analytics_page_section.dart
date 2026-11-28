import 'package:cupertino_ui/cupertino_ui.dart';
import 'package:material_ui/material_ui.dart';
import '../../../models/classification/classification_result.dart';
import '../../../constants/theme/app_colors.dart';
import '../../../constants/theme/app_typography.dart';
import '../../../utils/csv_export.dart';
import '../../../widgets/dashboard/dashboard_atmospheric_banner.dart';
import '../../../widgets/dashboard/frosted_glass_card.dart';
import '../../../widgets/dashboard/kpi_metrics_row.dart';

/// Dedicated Freshness Insights analytics page showing KPI metrics, freshness ratio bar, and anatomical breakdown.
class AnalyticsPageSection extends StatefulWidget {
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
  State<AnalyticsPageSection> createState() => _AnalyticsPageSectionState();
}

class _AnalyticsPageSectionState extends State<AnalyticsPageSection> {
  String _regionFilter = 'all';
  String _freshnessFilter = 'all';

  List<ClassificationResult> get _filteredHistory {
    return widget.history.where((s) {
      if (_regionFilter != 'all' &&
          (s.regionType ?? '').toLowerCase() != _regionFilter) {
        return false;
      }
      if (_freshnessFilter == 'fresh' && !s.isFresh) return false;
      if (_freshnessFilter == 'not_fresh' && !s.isNotFresh) return false;
      return true;
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    final history = _filteredHistory;
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
      controller: widget.scrollController,
      physics: const BouncingScrollPhysics(),
      padding: EdgeInsets.symmetric(
        horizontal: widget.isDesktop ? 36 : 18,
        vertical: widget.isDesktop ? 28 : 20,
      ),
      child: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 1320),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              DashboardAtmosphericBanner(
                content: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    const Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Freshness Insights',
                            style: TextStyle(
                              fontSize: 28,
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
                              color: SariwaColors.colorPale,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 12),
                    FilledButton.icon(
                      key: const Key('export_analytics_csv_button'),
                      onPressed: history.isEmpty
                          ? null
                          : () async {
                              final downloaded = await exportAnalyticsCsv(history);
                              if (context.mounted) {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(
                                    content: Text(
                                      downloaded
                                          ? 'Exported ${history.length} scan records to CSV.'
                                          : 'CSV export is available on Web.',
                                    ),
                                  ),
                                );
                              }
                            },
                      icon: const Icon(CupertinoIcons.arrow_down_doc, size: 16),
                      label: const Text('Export CSV'),
                      style: FilledButton.styleFrom(
                        backgroundColor: SariwaColors.cardSurfaceLight.withValues(alpha: 0.18),
                        foregroundColor: Colors.white,
                        disabledBackgroundColor: SariwaColors.cardSurfaceLight.withValues(alpha: 0.08),
                        disabledForegroundColor: SariwaColors.textSecondaryLight,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                crossAxisAlignment: WrapCrossAlignment.center,
                children: [
                  for (final entry in const [
                    ('all', 'All Regions'),
                    ('eye', 'Eye'),
                    ('gill', 'Gill'),
                  ])
                    ChoiceChip(
                      label: Text(entry.$2),
                      selected: _regionFilter == entry.$1,
                      onSelected: (_) => setState(() => _regionFilter = entry.$1),
                    ),
                  const Padding(
                    padding: EdgeInsets.symmetric(horizontal: 8),
                    child: SizedBox(
                      height: 24,
                      child: VerticalDivider(
                        width: 1,
                        thickness: 1.2,
                        color: SariwaColors.lineSlate,
                      ),
                    ),
                  ),
                  for (final entry in const [
                    ('all', 'All Results'),
                    ('fresh', 'Fresh'),
                    ('not_fresh', 'Not Fresh'),
                  ])
                    ChoiceChip(
                      label: Text(entry.$2),
                      selected: _freshnessFilter == entry.$1,
                      onSelected: (_) =>
                          setState(() => _freshnessFilter = entry.$1),
                    ),
                ],
              ),
              const SizedBox(height: 16),
              KpiMetricsRow(history: history),
              const SizedBox(height: 20),

              // Tightened, balanced proportions: Ratio Distribution + Anatomical Breakdown
              LayoutBuilder(
                builder: (context, constraints) {
                  final ratioCard = FrostedGlassCard(
                    padding: const EdgeInsets.all(20),
                    borderRadius: 20,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Freshness Ratio Distribution',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w500,
                            letterSpacing: AppTypography.defaultLetterSpacing,
                            color: SariwaColors.textPrimaryDark,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          '$freshCount fresh tilapia vs $notFreshCount not fresh tilapia identified',
                          style: const TextStyle(
                            fontSize: 14,
                            letterSpacing: AppTypography.defaultLetterSpacing,
                            color: SariwaColors.textSecondaryDark,
                          ),
                        ),
                        const SizedBox(height: 16),
                        ClipRRect(
                          borderRadius: BorderRadius.circular(999),
                          child: Container(
                            height: 14,
                            color: SariwaColors.surfaceSlateSubtle,
                            child: total == 0
                                ? null
                                : Row(
                                    children: [
                                      if (freshCount > 0)
                                        Expanded(
                                          flex: freshCount,
                                          child: Container(
                                            color: SariwaColors.statusFresh,
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
                              color: SariwaColors.statusFresh,
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
                                fontWeight: FontWeight.w500,
                                letterSpacing: AppTypography.defaultLetterSpacing,
                                color: SariwaColors.inkSlateMuted,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  );

                  final regionBreakdownRow = Row(
                    children: [
                      Expanded(
                        child: FrostedGlassCard(
                          padding: const EdgeInsets.all(16),
                          borderRadius: 20,
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Row(
                                children: [
                                  Icon(
                                    CupertinoIcons.eye,
                                    size: 17,
                                    color: SariwaColors.brandPrimary,
                                  ),
                                  SizedBox(width: 8),
                                  Expanded(
                                    child: Text(
                                      'Eye Inspections',
                                      overflow: TextOverflow.ellipsis,
                                      style: TextStyle(
                                        fontSize: 14,
                                        fontWeight: FontWeight.w500,
                                        letterSpacing:
                                            AppTypography.defaultLetterSpacing,
                                        color: SariwaColors.textPrimaryDark,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 12),
                              Text(
                                '$eyeCount scans',
                                style: const TextStyle(
                                  fontSize: 20,
                                  fontWeight: FontWeight.w500,
                                  letterSpacing:
                                      AppTypography.defaultLetterSpacing,
                                  color: SariwaColors.textPrimaryDark,
                                ),
                              ),
                              Text(
                                total > 0
                                    ? '${((eyeCount / total) * 100).toStringAsFixed(0)}% of total scans'
                                    : 'Default region',
                                style: const TextStyle(
                                  fontSize: 12,
                                  letterSpacing:
                                      AppTypography.defaultLetterSpacing,
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
                          padding: const EdgeInsets.all(16),
                          borderRadius: 20,
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Row(
                                children: [
                                  Icon(
                                    CupertinoIcons.waveform_path,
                                    size: 16,
                                    color: SariwaColors.brandPrimary,
                                  ),
                                  SizedBox(width: 8),
                                  Expanded(
                                    child: Text(
                                      'Gill Inspections',
                                      overflow: TextOverflow.ellipsis,
                                      style: TextStyle(
                                        fontSize: 14,
                                        fontWeight: FontWeight.w500,
                                        letterSpacing:
                                            AppTypography.defaultLetterSpacing,
                                        color: SariwaColors.textPrimaryDark,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 12),
                              Text(
                                '$gillCount scans',
                                style: const TextStyle(
                                  fontSize: 20,
                                  fontWeight: FontWeight.w500,
                                  letterSpacing:
                                      AppTypography.defaultLetterSpacing,
                                  color: SariwaColors.textPrimaryDark,
                                ),
                              ),
                              Text(
                                total > 0
                                    ? '${((gillCount / total) * 100).toStringAsFixed(0)}% of total scans'
                                    : 'Exposed gill view',
                                style: const TextStyle(
                                  fontSize: 12,
                                  letterSpacing:
                                      AppTypography.defaultLetterSpacing,
                                  color: SariwaColors.textSecondaryDark,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  );

                  if (constraints.maxWidth >= 880) {
                    return Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Expanded(flex: 6, child: ratioCard),
                        const SizedBox(width: 16),
                        Expanded(flex: 6, child: regionBreakdownRow),
                      ],
                    );
                  }

                  return Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      ratioCard,
                      const SizedBox(height: 16),
                      regionBreakdownRow,
                    ],
                  );
                },
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
        const SizedBox(width: 8),
        Text(
          label,
          style: const TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w400,
            letterSpacing: AppTypography.defaultLetterSpacing,
            color: SariwaColors.inkSlateSecondary,
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
