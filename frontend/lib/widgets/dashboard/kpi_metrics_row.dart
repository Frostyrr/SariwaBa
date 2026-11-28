import 'dart:ui' as ui;
import 'package:material_ui/material_ui.dart';
import '../../models/classification/classification_result.dart';
import '../../constants/theme/app_colors.dart';
import '../../constants/theme/app_typography.dart';

/// Compact, minimal KPI strip showing Total, Fresh, Not Fresh, and Avg. Confidence
/// in one clean bordered surface with minimal vertical footprint.
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
    final notFreshCount = total - freshCount;
    final avgConfidence = total > 0
        ? (history.fold(0.0, (acc, s) => acc + s.confidence) / total) * 100
        : 0.0;

    final items = [
      (
        label: 'Total',
        value: total.toString(),
        dotColor: SariwaColors.brandPrimary,
      ),
      (
        label: 'Fresh',
        value: freshCount.toString(),
        dotColor: SariwaColors.statusFresh,
      ),
      (
        label: 'Not Fresh',
        value: notFreshCount.toString(),
        dotColor: SariwaColors.statusSpoiled,
      ),
      (
        label: 'Avg. Conf.',
        value: total > 0 ? '${avgConfidence.toStringAsFixed(0)}%' : '—',
        dotColor: SariwaColors.statusInfo,
      ),
    ];

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
      decoration: BoxDecoration(
        color: SariwaColors.cardSurfaceLight,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: SariwaColors.colorLine),
      ),
      child: LayoutBuilder(
        builder: (context, constraints) {
          final isWide = constraints.maxWidth >= 560;
          if (isWide) {
            return IntrinsicHeight(
              child: Row(
                children: [
                  for (var i = 0; i < items.length; i++) ...[
                    Expanded(
                      child: _buildCompactCell(
                        label: items[i].label,
                        value: items[i].value,
                        dotColor: items[i].dotColor,
                      ),
                    ),
                    if (i < items.length - 1)
                      const VerticalDivider(
                        width: 16,
                        thickness: 1,
                        color: SariwaColors.colorLineSubtle,
                      ),
                  ],
                ],
              ),
            );
          }

          // Compact 2x2 grid on narrow mobile screens
          return Column(
            children: [
              Row(
                children: [
                  Expanded(
                    child: _buildCompactCell(
                      label: items[0].label,
                      value: items[0].value,
                      dotColor: items[0].dotColor,
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: _buildCompactCell(
                      label: items[1].label,
                      value: items[1].value,
                      dotColor: items[1].dotColor,
                    ),
                  ),
                ],
              ),
              const Padding(
                padding: EdgeInsets.symmetric(vertical: 8),
                child: Divider(height: 1, color: SariwaColors.colorLineSubtle),
              ),
              Row(
                children: [
                  Expanded(
                    child: _buildCompactCell(
                      label: items[2].label,
                      value: items[2].value,
                      dotColor: items[2].dotColor,
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: _buildCompactCell(
                      label: items[3].label,
                      value: items[3].value,
                      dotColor: items[3].dotColor,
                    ),
                  ),
                ],
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _buildCompactCell({
    required String label,
    required String value,
    required Color dotColor,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 6,
                height: 6,
                decoration: BoxDecoration(
                  color: dotColor,
                  shape: BoxShape.circle,
                ),
              ),
              const SizedBox(width: 8),
              Text(
                label,
                style: const TextStyle(
                  fontFamily: AppTypography.fontFamily,
                  fontSize: 12,
                  fontWeight: FontWeight.w400,
                  color: SariwaColors.inkSlateMuted,
                ),
              ),
            ],
          ),
          Text(
            value,
            style: const TextStyle(
              fontFamily: AppTypography.fontFamily,
              fontSize: 20,
              fontWeight: FontWeight.w400,
              height: 1.0,
              fontFeatures: [ui.FontFeature.tabularFigures()],
              letterSpacing: -0.4,
              color: SariwaColors.textPrimaryDark,
            ),
          ),
        ],
      ),
    );
  }
}
