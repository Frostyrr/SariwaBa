import 'dart:ui' as ui;

import 'package:material_ui/material_ui.dart';

import '../../constants/theme/app_colors.dart';
import '../../constants/theme/app_typography.dart';
import '../../models/classification/classification_result.dart';

/// Four crisp white mini-KPI cards (`grid-cols-2 lg:grid-cols-4 gap-4`)
/// showing Total, Fresh, Not Fresh, and Avg. Conf with bold Geist numbers.
class KpiMetricsRow extends StatelessWidget {
  final List<ClassificationResult> history;

  const KpiMetricsRow({
    super.key,
    required this.history,
  });

  static const Color _inkPrimary = Color(0xFF111111);
  static const Color _inkMuted = Color(0xFF737373);
  static const Color _border = Color(0x14171717);

  @override
  Widget build(BuildContext context) {
    final total = history.length;
    final freshCount = history.where((s) => s.isFresh).length;
    final notFreshCount = total - freshCount;
    final avgConfidence = total > 0
        ? (history.fold(0.0, (acc, s) => acc + s.confidence) / total) * 100
        : 0.0;

    final cards = [
      _buildMiniKpiCard(
        label: 'Total',
        value: total.toString(),
        dotColor: const Color(0xFF737373),
      ),
      _buildMiniKpiCard(
        label: 'Fresh',
        value: freshCount.toString(),
        dotColor: SariwaColors.brandPrimary,
      ),
      _buildMiniKpiCard(
        label: 'Not Fresh',
        value: notFreshCount.toString(),
        dotColor: SariwaColors.statusSpoiled,
      ),
      _buildMiniKpiCard(
        label: 'Avg. Conf',
        value: total > 0 ? '${avgConfidence.toStringAsFixed(0)}%' : '—',
        dotColor: const Color(0xFF737373),
      ),
    ];

    return LayoutBuilder(
      builder: (context, constraints) {
        final isWide = constraints.maxWidth >= 680;
        const gap = 16.0;

        if (isWide) {
          return Row(
            children: [
              for (var i = 0; i < cards.length; i++) ...[
                Expanded(child: cards[i]),
                if (i < cards.length - 1) const SizedBox(width: gap),
              ],
            ],
          );
        }

        return Column(
          children: [
            Row(
              children: [
                Expanded(child: cards[0]),
                const SizedBox(width: gap),
                Expanded(child: cards[1]),
              ],
            ),
            const SizedBox(height: gap),
            Row(
              children: [
                Expanded(child: cards[2]),
                const SizedBox(width: gap),
                Expanded(child: cards[3]),
              ],
            ),
          ],
        );
      },
    );
  }

  Widget _buildMiniKpiCard({
    required String label,
    required String value,
    required Color dotColor,
  }) {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: _border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
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
              const SizedBox(width: 6),
              Text(
                label,
                style: const TextStyle(
                  fontFamily: AppTypography.fontFamily,
                  fontSize: 12,
                  fontWeight: FontWeight.w500,
                  color: _inkMuted,
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Text(
            value,
            style: const TextStyle(
              fontFamily: AppTypography.fontFamily,
              fontSize: 26,
              fontWeight: FontWeight.w700,
              height: 1.05,
              fontFeatures: [ui.FontFeature.tabularFigures()],
              letterSpacing: -0.65,
              color: _inkPrimary,
            ),
          ),
        ],
      ),
    );
  }
}
