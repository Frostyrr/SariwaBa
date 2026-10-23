import 'package:flutter/material.dart';
import '../../../constants/theme/app_colors.dart';
import '../../../models/classification/classification_result.dart';
import '../widgets/dashboard_charts.dart';

class GradeBreakdownSection extends StatelessWidget {
  final List<ClassificationResult> history;

  const GradeBreakdownSection({super.key, required this.history});

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final isWide = constraints.maxWidth >= 820;

        if (isWide) {
          return Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(child: _buildGradeDistributionCard()),
              const SizedBox(width: 20),
              Expanded(child: _buildConfidenceSummaryCard()),
            ],
          );
        } else {
          return Column(
            children: [
              _buildGradeDistributionCard(),
              const SizedBox(height: 20),
              _buildConfidenceSummaryCard(),
            ],
          );
        }
      },
    );
  }

  Widget _buildGradeDistributionCard() {
    final total = history.length;
    final freshCount = history.where((s) => s.isFresh).length;
    final passRate = total > 0 ? (freshCount / total) * 100 : 87.0;

    return Stack(
      clipBehavior: Clip.none,
      children: [
        Container(
          padding: const EdgeInsets.all(22),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(22),
            border: Border.all(color: SariwaColors.borderLightTeal),
            boxShadow: const [
              BoxShadow(
                color: Color(0x060A2229),
                blurRadius: 14,
                offset: Offset(0, 5),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Freshness Grade Breakdown',
                style: TextStyle(
                  fontFamily: 'Geist',
                  fontSize: 15.5,
                  fontWeight: FontWeight.w600,
                  letterSpacing: -0.3,
                  color: SariwaColors.textPrimaryDark,
                ),
              ),
              const SizedBox(height: 8),
              Row(
                children: [
                  const Text(
                    'Grade A Rate: ',
                    style: TextStyle(
                      fontFamily: 'Geist',
                      fontSize: 12.5,
                      fontWeight: FontWeight.w400,
                      letterSpacing: -0.15,
                      color: SariwaColors.textMutedDark,
                    ),
                  ),
                  Text(
                    '${passRate.toStringAsFixed(1)}%',
                    style: const TextStyle(
                      fontFamily: 'Geist',
                      fontSize: 19,
                      fontWeight: FontWeight.w600,
                      letterSpacing: -0.4,
                      color: SariwaColors.textPrimaryDark,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 4),
              const Row(
                children: [
                  Icon(
                    Icons.trending_up_rounded,
                    size: 14,
                    color: SariwaColors.statusFresh,
                  ),
                  SizedBox(width: 4),
                  Text(
                    '24.5%',
                    style: TextStyle(
                      fontFamily: 'Geist',
                      fontSize: 11.5,
                      fontWeight: FontWeight.w600,
                      letterSpacing: -0.2,
                      color: SariwaColors.statusFresh,
                    ),
                  ),
                  SizedBox(width: 5),
                  Text(
                    'vs last month',
                    style: TextStyle(
                      fontFamily: 'Geist',
                      fontSize: 11,
                      fontWeight: FontWeight.w400,
                      letterSpacing: -0.15,
                      color: SariwaColors.textMutedDark,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 18),
              Row(
                children: [
                  SizedBox(
                    width: 145,
                    height: 145,
                    child: CustomPaint(painter: PolarSectorChartPainter()),
                  ),
                  const SizedBox(width: 18),
                  Expanded(
                    child: Column(
                      children: [
                        _buildLegendRow(
                          color: SariwaColors.brandPrimary,
                          label: 'Grade A (Sariwa)',
                          pct: '38%',
                        ),
                        _buildLegendRow(
                          color: SariwaColors.statusFresh,
                          label: 'Clear Cornea Cue',
                          pct: '26%',
                        ),
                        _buildLegendRow(
                          color: SariwaColors.statusInfo,
                          label: 'Ruby Branchial Gills',
                          pct: '19%',
                        ),
                        _buildLegendRow(
                          color: SariwaColors.statusModerate,
                          label: 'Grade B (Moderate)',
                          pct: '11%',
                        ),
                        _buildLegendRow(
                          color: SariwaColors.statusSpoiled,
                          label: 'Grade C (Spoiled)',
                          pct: '6%',
                          isLast: true,
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
        Positioned(
          top: -2,
          right: -2,
          child: _buildCornerDropdownBadge('This Month'),
        ),
      ],
    );
  }

  Widget _buildLegendRow({
    required Color color,
    required String label,
    required String pct,
    bool isLast = false,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 6),
      decoration: BoxDecoration(
        border: isLast
            ? null
            : const Border(
                bottom: BorderSide(
                  color: SariwaColors.bgDashboardSubtle,
                  width: 1,
                ),
              ),
      ),
      child: Row(
        children: [
          Container(
            width: 7,
            height: 7,
            decoration: BoxDecoration(color: color, shape: BoxShape.circle),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              label,
              style: const TextStyle(
                fontFamily: 'Geist',
                fontSize: 11.5,
                fontWeight: FontWeight.w400,
                letterSpacing: -0.15,
                color: SariwaColors.textPrimaryDark,
              ),
              overflow: TextOverflow.ellipsis,
            ),
          ),
          Text(
            pct,
            style: const TextStyle(
              fontFamily: 'Geist',
              fontSize: 11.5,
              fontWeight: FontWeight.w600,
              letterSpacing: -0.2,
              color: SariwaColors.textMutedDark,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildConfidenceSummaryCard() {
    final total = history.length;
    final avgConfidence = total > 0
        ? (history.fold(0.0, (acc, s) => acc + s.confidence) / total) * 100
        : 96.4;

    return Stack(
      clipBehavior: Clip.none,
      children: [
        Container(
          padding: const EdgeInsets.all(22),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(22),
            border: Border.all(color: SariwaColors.borderLightTeal),
            boxShadow: const [
              BoxShadow(
                color: Color(0x060A2229),
                blurRadius: 14,
                offset: Offset(0, 5),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'AI Confidence & Stability Summary',
                style: TextStyle(
                  fontFamily: 'Geist',
                  fontSize: 15.5,
                  fontWeight: FontWeight.w600,
                  letterSpacing: -0.3,
                  color: SariwaColors.textPrimaryDark,
                ),
              ),
              const SizedBox(height: 8),
              Row(
                children: [
                  const Text(
                    'Mean Precision: ',
                    style: TextStyle(
                      fontFamily: 'Geist',
                      fontSize: 12.5,
                      fontWeight: FontWeight.w400,
                      letterSpacing: -0.15,
                      color: SariwaColors.textMutedDark,
                    ),
                  ),
                  Text(
                    '${avgConfidence.toStringAsFixed(1)}%',
                    style: const TextStyle(
                      fontFamily: 'Geist',
                      fontSize: 19,
                      fontWeight: FontWeight.w600,
                      letterSpacing: -0.4,
                      color: SariwaColors.textPrimaryDark,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 4),
              const Row(
                children: [
                  Icon(
                    Icons.trending_up_rounded,
                    size: 14,
                    color: SariwaColors.statusFresh,
                  ),
                  SizedBox(width: 4),
                  Text(
                    '18.2%',
                    style: TextStyle(
                      fontFamily: 'Geist',
                      fontSize: 11.5,
                      fontWeight: FontWeight.w600,
                      letterSpacing: -0.2,
                      color: SariwaColors.statusFresh,
                    ),
                  ),
                  SizedBox(width: 5),
                  Text(
                    'vs baseline model',
                    style: TextStyle(
                      fontFamily: 'Geist',
                      fontSize: 11,
                      fontWeight: FontWeight.w400,
                      letterSpacing: -0.15,
                      color: SariwaColors.textMutedDark,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 18),
              SizedBox(
                height: 105,
                width: double.infinity,
                child: CustomPaint(painter: PeakAreaChartPainter()),
              ),
              const SizedBox(height: 10),
              Container(
                height: 12,
                padding: const EdgeInsets.symmetric(horizontal: 4),
                decoration: BoxDecoration(
                  color: SariwaColors.bgDashboardSubtle,
                  borderRadius: BorderRadius.circular(999),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: List.generate(
                    18,
                    (index) => Container(
                      width: index == 0 || index == 17 ? 10 : 3,
                      height: index == 0 || index == 17 ? 10 : 3,
                      decoration: BoxDecoration(
                        color: index == 0 || index == 17
                            ? Colors.white
                            : SariwaColors.brandPrimary.withValues(alpha: 0.25),
                        shape: BoxShape.circle,
                      ),
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 8),
              const Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    '50%',
                    style: TextStyle(
                      fontSize: 10.5,
                      color: SariwaColors.textMutedDark,
                    ),
                  ),
                  Text(
                    '65%',
                    style: TextStyle(
                      fontSize: 10.5,
                      color: SariwaColors.textMutedDark,
                    ),
                  ),
                  Text(
                    '75%',
                    style: TextStyle(
                      fontSize: 10.5,
                      color: SariwaColors.textMutedDark,
                    ),
                  ),
                  Text(
                    '85%',
                    style: TextStyle(
                      fontSize: 10.5,
                      color: SariwaColors.textMutedDark,
                    ),
                  ),
                  Text(
                    '95%',
                    style: TextStyle(
                      fontSize: 10.5,
                      color: SariwaColors.textMutedDark,
                    ),
                  ),
                  Text(
                    '99%',
                    style: TextStyle(
                      fontSize: 10.5,
                      color: SariwaColors.textMutedDark,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
        Positioned(
          top: -2,
          right: -2,
          child: _buildCornerDropdownBadge('This Month'),
        ),
      ],
    );
  }

  Widget _buildCornerDropdownBadge(String label) {
    return Container(
      padding: const EdgeInsets.only(left: 8, bottom: 8),
      decoration: const BoxDecoration(
        color: SariwaColors.bgDashboard,
        borderRadius: BorderRadius.only(bottomLeft: Radius.circular(20)),
      ),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(999),
          border: Border.all(color: SariwaColors.borderLightTeal),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              label,
              style: const TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.w600,
                color: SariwaColors.textPrimaryDark,
              ),
            ),
            const SizedBox(width: 4),
            const Icon(
              Icons.keyboard_arrow_down_rounded,
              size: 14,
              color: SariwaColors.textSecondaryDark,
            ),
          ],
        ),
      ),
    );
  }
}
